module Concerns
  module Graphable
    extend ActiveSupport::Concern

    def path_to(other)
      Graph.shortest_path(graph_node, other.graph_node)
    end

    def graph_node
      @graph_node ||= Graph.get(self.class.name, self.id)
    end
  end
end
