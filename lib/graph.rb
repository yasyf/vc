class Graph
  def self.shortest_path(n1, n2, limit = 3)
    n1.shortest_path_to(n2).depth(limit).nodes
  end

  def self.connect(type, n1, n2)
    Neography::Relationship.create(type, n1, n2)
    Neography::Relationship.create(type, n2, n1)
  end

  def self.add(type, id)
    Neography::Node.create(type: type, id: id)
  end
end