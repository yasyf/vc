class Graph
  extend Concerns::Ignorable

  def self.server
    Thread.current[:neo] ||= Neography::Rest.new
  end

  def self.relationship_indexes
    @relationship_indexes ||= server.list_relationship_indexes
  end

  def self.shortest_paths(n1, n2, type: :rels)
    return [] unless n1.present? && n2.present?
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
    result = server.execute_query(script, attrs)['data']
    return [] unless result.present?
    result.map { |r| r.first['nodes'].map { |rel| Neography::Node.load(rel, db=server) } }
  end

  def self.fetch_rels(script, attrs = {})
    result = server.execute_query(script, attrs)['data']
    return [] unless result.present?
    result.map { |r| r.first['relationships'].map { |rel| Neography::Relationship.load(rel, db=server) } }
  end

  def self.all_sp_query(match, where, limit = 4)
    <<-CYPHER
      MATCH (#{match}), path = shortestPath((me)-[*1..#{limit}]-(other))
      WHERE #{where}
      RETURN path, reduce(count = 0, r IN relationships(path) | count + coalesce(r.count, 0)) AS total
      ORDER BY total DESC;
    CYPHER
  end

  def self.connect(type, n1, n2)
    Neography::Relationship.create_unique(
      "connected_on_#{type}",
      type,
      "#{n1[type]} -> #{n2[type]}",
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

  def self.get(addr)
    find(addr) || add(addr)
  end

  def self.add(addr)
    node = Neography::Node.create({ name: addr.name, email: addr.address, domain: addr.domain }, server)
    begin
      node.set_labels('Person')
    rescue Neography::BadInputException
      node.del
      get addr
    else
      node
    end
  end

  def self.find(addr)
    results = retry_([Excon::Error::Socket, Neography::NeographyError]) { server.find_nodes_labeled('Person', {email: addr.address}) }
    Neography::Node.load(results.first, server) if results.present?
  end

  def self.init!
    add_constraint! 'Person', 'email'
    ensure_index! 'Person', 'domain'
    ensure_relationship_index! 'email'
  end

  def self.add_constraint!(name, property)
    server.execute_query("CREATE CONSTRAINT ON (#{name.downcase}:#{name}) ASSERT #{name.downcase}.#{property} IS UNIQUE")
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