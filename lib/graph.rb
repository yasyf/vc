class Graph
  extend Concerns::Ignorable

  def self.server
    Thread.current[:neo] ||= Neography::Rest.new
  end

  def self.relationship_indexes
    @relationship_indexes ||= server.list_relationship_indexes
  end

  def self.shortest_path(n1, n2, limit = 4)
    return [] unless n1.present? && n2.present?
    n1.shortest_path_to(n2).depth(limit).rels.to_a.first
  end

  def self.shortest_path_to_domain(n, domain, limit = 4)
    script = <<-CYPHER
      MATCH (other:Person { domain: {domain} }), path = shortestPath((me)-[*1..#{limit}]-(other))
      WHERE id(me) = {neo_id}
      RETURN path
    CYPHER
    result = server.execute_query(script, neo_id: n.neo_id.to_i, domain: domain)['data']
    return [] unless result.present?
    result.first.first['relationships'].map { |rel| Neography::Relationship.load(rel, db=server) }
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

  def self.get(addr)
    find(addr) || add(addr)
  end

  def self.add(addr)
    node = Neography::Node.create({name: addr.name, email: addr.address, domain: addr.domain}, server)
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
    results = retry_([Excon::Error::Socket]) { server.find_nodes_labeled('Person', {email: addr.address}) }
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