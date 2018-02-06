class GraphBulk
  def self.get_minmax(metric)
    script = <<-CYPHER
      MATCH (n:Person)
      RETURN max(n.#{metric}), MIN(n.#{metric})
    CYPHER
    Graph.execute(script).first
  end

  def self.scale_metric!(metric, minmax: nil)
    min, max = minmax.present ? minmax : self.get_minmax(metric)
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
      MATCH (p:Person)-[:email]-() RETURN DISTINCT id(p) as id
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
    Graph.execute(cypher, params, transaction: true)
  end


  def self.add_labels_to_nodes!(klass)
    klass.where.not(email: nil).find_each do |i|
      return unless i.graph_node.present?
      i.graph_node.add_label(klass.name)
      i.graph_node[:model_id] = i.id
    end
  end
end
