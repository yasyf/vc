module Concerns
  module Graphable
    extend ActiveSupport::Concern

    def describe_path(path)
      return nil unless path.present?
      if path.length == 1
        { direct: true, first_hop_via: path.first.rel_type }
      else
        first, *rest = path[0...-1].map do |rel|
          rel.start_node == graph_node ? rel.end_node : rel.start_node
        end.map(&:to_h)
        through = [first] + rest.map { |h| h.slice(:name) }
        { direct: false, first_hop_via: path.first.rel_type, through: through }
      end
    end

    def path_to_node(node)
      describe_path Graph.shortest_path(graph_node, node)
    end

    def path_to_addr(addr)
      return nil unless (other = self.class.node_from_addr(addr)).present?
      path_to other
    end

    def path_to(other)
      path_to_node other.graph_node
    end

    def path_to_domain(domain)
      describe_path Graph.shortest_path_to_domain(graph_node, domain)
    end

    def connect_to!(other, type)
      Graph.connect(type, graph_node, other.graph_node)
    end

    def connect_from!(other, type)
      Graph.connect(type, other.graph_node, graph_node)
    end

    def connect_to_addr!(addr, type)
      return nil unless (other = self.class.node_from_addr(addr)).present?
      Graph.connect(type, graph_node, other)
    end

    def connect_from_addr!(addr, type)
      return nil unless (other = self.class.node_from_addr(addr)).present?
      Graph.connect(type, other, graph_node)
    end

    def graph_node
      @graph_node ||= Graph.get(Mail::Address.new("\"#{name}\" <#{email}>")) if email.present?
    end

    class_methods do
      def node_from_addr(addr)
        if (found = Graph.find(addr))
          found
        else
          Graph.add(addr) if addr.name.present?
        end
      end
    end
  end
end
