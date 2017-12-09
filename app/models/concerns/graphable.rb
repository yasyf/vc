module Concerns
  module Graphable
    extend ActiveSupport::Concern

    def path_to(other)
      path = Graph.shortest_path(graph_node, other.graph_node).first
      return nil unless path.present?
      if path.length == 1
        { direct: true, first_hop_via: path.first.rel_type }
      else
        first, *rest = path[0...-1].map(&:end_node).map(&:to_h)
        through = [first] + rest.map { |h| h.slice(:name) }
        { direct: false, first_hop_via: path.first.rel_type, through: through }
      end
    end

    def path_to_addr(addr)
      return nil unless (other = self.class.node_from_addr(addr)).present?
      path_to other
    end

    def connect_to!(other, type)
      Graph.connect(type, graph_node, other.graph_node)
    end

    def connect_from!(other, type)
      Graph.connect(type, other.graph_node, graph_node)
    end

    def connect_to_addr!(addr, type)
      return nil unless (other = self.class.node_from_addr(addr)).present?
      connect_to! other, type
    end

    def connect_from_addr!(addr, type)
      return nil unless (other = self.class.node_from_addr(addr)).present?
      connect_from! other, type
    end

    def graph_node
      @graph_node ||= Graph.get(name, email)
    end

    private

    def self.node_from_addr(addr)
      if (found = Graph.find(addr.address))
        found
      else
        Graph.add(addr.name,addr.address) if addr.name.present?
      end
    end
  end
end
