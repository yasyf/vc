class Graph
  extend Concerns::Ignorable

  def self.server
    Thread.current[:neo] ||= Neography::Rest.new
  end

  def self.relationship_indexes
    @relationship_indexes ||= server.list_relationship_indexes
  end

  def self.shortest_paths(n1, n2, type: :rels)
    return [] unless n1.present? && n2.present? && n1 != n2
    script = all_sp_query 'other:Person', 'id(me) = {neo_id_1} AND id(other) = {neo_id_2}'
    attrs = { neo_id_1: n1.neo_id.to_i, neo_id_2: n2.neo_id.to_i }
    method("fetch_#{type}").call(script, attrs)
  end

  def self.shortest_paths_to_domain(n, domain, type: :rels)
    script = all_sp_query 'other:Person { domain: {domain} }', 'id(me) = {neo_id}'
    attrs = { neo_id: n.neo_id.to_i, domain: domain }
    method("fetch_#{type}").call(script, attrs)
  end

  def self.fetch_nodes(script, attrs = {})
    result = execute(script, params: attrs)
    return [] unless result.present?
    result.map do |r|
      Parallel.map(r.first['nodes'], in_threads: 16) { |node| Neography::Node.load(node, db=server) }
    end
  end

  def self.fetch_rels(script, attrs = {})
    result = execute(script, params: attrs)
    return [] unless result.present?
    result.map do |r|
      Parallel.map(r.first['relationships'], in_threads: 16) { |rel| Neography::Relationship.load(rel, db=server) }
    end
  end

  def self.all_sp_query(match, where, limit = 4)
    <<-CYPHER
      MATCH (#{match}), path = shortestPath((me)-[*1..#{limit}]-(other))
      WHERE #{where}
      RETURN path, reduce(count = 0, r IN relationships(path) | count + coalesce(r.count, 0)) AS total
      ORDER BY total DESC
      LIMIT 10;
    CYPHER
  end

  def self.connect(type, n1, n2)
    return if n1 == n2
    return unless n1.present? && n2.present?
    Neography::Relationship.create_unique(
      "connected_on_#{type}",
      type,
      "#{n1.email} -> #{n2.email}",
      type,
      n1,
      n2
    )
  end

  def self.increment(type, n1, n2)
    connect(type, n1, n2).tap do |rel|
      rel[:count] = (rel[:count] || 0) + 1 if rel.present?
    end
  end

  def self.increment_or_connect(type, n1, n2)
    if type.to_sym == :email
      increment type, n1, n2
    else
      connect type, n1, n2
    end
  end

  def self.get(addr)
    find(addr) || add(addr)
  end

  def self.add(addr)
    script = <<-CYPHER
      CREATE (n:Person { name: {name}, email: {email}, domain: {domain} })
      RETURN n;
    CYPHER
    result = execute(script, params: { name: addr.name, email: addr.address, domain: addr.domain })
    Neography::Node.load(result.first, server)
  rescue Neography::NeographyError
    find addr
  end

  def self.execute(script, params: {}, transaction: false)
    if transaction
      tx = server.begin_transaction
      thread = Thread.new do
        server.keep_transaction(tx)
        sleep(1)
      end
      result = server.execute_query(script, params)['data']
      thread.kill.join
      server.commit_transaction(tx)
      result
    else
      server.execute_query(script, params)['data']
    end
  end

  def self.find(addr, label: 'Person')
    results = retry_([Excon::Error::Socket, Neography::NeographyError]) { server.find_nodes_labeled(label, {email: addr.address}) }
    Neography::Node.load(results.first, server) if results.present?
  end

  def self.init!
    add_constraint! 'Person', 'email'
    ensure_index! 'Person', 'domain'
    ensure_relationship_index! 'email'
    ensure_relationship_index! 'invest'
  end

  def self.add_constraint!(name, property)
    execute("CREATE CONSTRAINT ON (#{name.downcase}:#{name}) ASSERT #{name.downcase}.#{property} IS UNIQUE")
  end

  def self.ensure_index!(name, properties)
    wrapped = Array.wrap(properties)
    return if server.get_schema_index(name).find { |s| s['property_keys'] == wrapped }.present?
    server.create_schema_index(name, wrapped)
  end

  def self.ensure_relationship_index!(name)
    server.create_relationship_index("connected_on_#{name}")
  end
end
