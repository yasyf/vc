class GraphBulkJob < ApplicationJob
  queue_as :long

  DAMPING_FACTOR = 0.85

  def perform
    GraphBulk.add_labels_to_nodes! Founder
    GraphBulk.add_labels_to_nodes! Investor
    calculate! :pagerank
    # calculate! :betweenness
    # calculate! :harmonic
  end

  private

  # PageRank

  def run_vanilla_pagerank!
    options = <<-CYPHER
      {graph: 'cypher', iterations: 20, dampingFactor: {dampingFactor}, write: true}
    CYPHER
    GraphBulk.run_vanilla_metric! 'pageRank', options, params: { dampingFactor: DAMPING_FACTOR }
  end

  def scale_pagerank!
    r_low = GraphBulk.get_minmax(:pagerank).last
    normalize = <<-CYPHER
      CALL apoc.periodic.iterate(
        "MATCH (n:Person) RETURN n",
        "SET n.pagerank = n.pagerank / #{r_low}",
        {batchSize: 1000, parallel: true, iterateList: true}
      );
    CYPHER
    Graph.execute(normalize)
    GraphBulk.scale_metric! :pagerank
  end

  # Betweenness

  def run_vanilla_betweenness!
    options = <<-CYPHER
      {graph: 'cypher', direction: 'outgoing', writeProperty: 'betweenness',  write: true, stats: true}
    CYPHER
    result = GraphBulk.run_vanilla_metric! 'betweenness', options, yields: 'minCentrality, maxCentrality'
    @betweenness_minmax = result.first
  end

  def scale_betweenness!
    GraphBulk.scale_metric! :betweenness, minmax: @betweenness_minmax
  end

  # Harmonic

  def run_vanilla_harmonic!
    options = <<-CYPHER
      {graph: 'cypher', writeProperty: 'harmonic',  write: true}
    CYPHER
    GraphBulk.run_vanilla_metric! 'closeness.harmonic', options
  end

  def scale_harmonic!
    GraphBulk.scale_metric! :harmonic
  end

  # Shared

  def calculate!(name)
    send("run_vanilla_#{name}!")
    send("scale_#{name}!")
  end
end
