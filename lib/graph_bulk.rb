class GraphBulk
  def self.scale_metric!(metric, minmax: nil)
    if minmax.present?
      min, max = minmax
    else
      script = <<-CYPHER
        MATCH (n:Person)
        RETURN max(n.#{metric}), MIN(n.#{metric})
      CYPHER
      min, max = Graph.execute(script).first
    end

    scale = <<-CYPHER
      CALL apoc.periodic.iterate(
        "MATCH (n:Person) RETURN n",
        "SET n.#{metric} = (n.#{metric} - #{min}) / (#{max - min})",
        {batchSize: 1000, parallel: true, iterateList: true}
      );
    CYPHER
    Graph.execute(scale)
  end

  def self.run_vanilla_metric!(name, options, params: {}, yields: nil)
    nodes = <<-CYPHER
      MATCH (p:Person) RETURN id(p) as id
    CYPHER
    rels = <<-CYPHER
      MATCH (p1:Person)-[r1:email]->(p2:Person), (p2)-[r2:email]->(p1)
      WHERE r1.count > 1 AND r2.count > 1
      RETURN id(p1) as source, id(p2) as target
    CYPHER
    cypher = <<-CYPHER
      CALL algo.#{name}(
        '#{nodes}',
        '#{rels}',
        #{options}
      )
      #{yields ? "YIELD #{yields};" : ';'}
    CYPHER
    Graph.execute(cypher, params)
  end


  def self.add_labels_to_nodes!(klass)
    klass.where.not(email: nil).find_each do |i|
      i.graph_node&.add_label(klass.name)
    end
  end
end
