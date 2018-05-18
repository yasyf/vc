class GraphBulk
  def self.get_minmax(metric)
    script = <<-CYPHER
      MATCH (n:Person)
      RETURN MIN(n.#{metric}), MAX(n.#{metric})
    CYPHER
    Graph.execute(script).first
  end

  def self.scale_metric!(metric, minmax: nil)
    min, max = minmax.present? ? minmax : self.get_minmax(metric)
    scale = <<-CYPHER
      CALL apoc.periodic.iterate(
        "MATCH (n:Person) RETURN n",
        "SET n.#{metric} = (n.#{metric} - #{min}) / (#{max - min})",
        {batchSize: 1000, parallel: true, iterateList: true}
      );
    CYPHER
    Graph.execute(scale)
  end

  EMAIL_NODES = <<-CYPHER
    MATCH (p:Person)-[:email]-() RETURN DISTINCT id(p) as id
  CYPHER

  EMAIL_RELS = <<-CYPHER
    MATCH (p1:Person)-[r1:email]->(p2:Person), (p2)-[r2:email]->(p1)
    WHERE r1.count > 1 AND r2.count > 1
    RETURN id(p1) as source, id(p2) as target
  CYPHER

  INVEST_NODES = <<-CYPHER
    MATCH (p:Person)-[:invest|:cofound]-() RETURN DISTINCT id(p) as id
  CYPHER

  INVEST_RELS = <<-CYPHER
    MATCH (p1:Person)-[r1:invest|:cofound]-(p2:Person)
    RETURN id(p1) as source, id(p2) as target
  CYPHER

  EMAIL_AND_INVEST_NODES = <<-CYPHER
    #{EMAIL_NODES}
    UNION
    #{INVEST_NODES}
  CYPHER

  EMAIL_AND_INVEST_RELS = <<-CYPHER
    #{EMAIL_RELS}
    UNION
    #{INVEST_RELS}
  CYPHER

  def self.run_vanilla_metric!(name, options, params: {}, yields: nil)
    nodes = EMAIL_AND_INVEST_NODES
    rels = EMAIL_AND_INVEST_RELS
    cypher = <<-CYPHER
      CALL algo.#{name}(
        '#{nodes}',
        '#{rels}',
        #{options}
      )
      #{yields ? "YIELD #{yields};" : ';'}
    CYPHER
    Graph.execute(cypher, params: params)
  end

  def self.add_labels_to_nodes!(klass)
    klass.find_in_batches do |batch|
      ids = batch.map(&:id)
      nodes = batch.map(&:graph_node).compact.reject { |n| n[:model_id].present? }
      ops = nodes.flat_map.with_index do |node, i|
        [[:set_node_property, node, { model_id: ids[i] }], [:add_label, node, klass.name]]
      end
      next unless ops.present?
      Graph.server.batch *ops
    end
  end
end
