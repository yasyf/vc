class Graph
  def self.server
    Thread.current[:neo] ||= Neography::Rest.new
  end

  def self.relationship_indexes
    @relationship_indexes ||= server.list_relationship_indexes
  end

  def self.shortest_path(n1, n2, limit = 3)
    n1.shortest_path_to(n2).depth(limit).rels.to_a
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

  def self.get(name, email)
    find(email) || add(name, email)
  end

  def self.add(name, email)
    Neography::Node.create({name: name, email: email}, server).tap do |node|
      node.set_labels('Person')
    end
  end

  def self.find(email)
    results = server.find_nodes_labeled('Person', {email: email})
    Neography::Node.load(results.first, server) if results.present?
  end

  def self.init!
    add_constraint! 'Person', 'email'
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