module Concerns
  module Graphable
    extend ActiveSupport::Concern

    class_methods do
      def node_from_addr(addr)
        if (found = Graph.find(addr))
          found
        else
          Graph.add(addr) if addr.name.present?
        end
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
      Graph.increment(type, graph_node, other.graph_node)
    end

    def connect_from!(other, type)
      Graph.increment(type, other.graph_node, graph_node)
    end

    def connect_to_addr!(addr, type)
      return nil unless (other = self.class.node_from_addr(addr)).present?
      Graph.increment(type, graph_node, other)
    end

    def connect_from_addr!(addr, type)
      return nil unless (other = self.class.node_from_addr(addr)).present?
      Graph.increment(type, other, graph_node)
    end

    def graph_node
      @graph_node ||= Graph.get(Mail::Address.new("\"#{name}\" <#{email}>")) if email.present?
    end

    private

    def describe_path(path)
      return nil unless path.present?
      puts path.to_s
      list = node_list_from_path(path).map(&:to_h)
      through = list.each_with_index.map do |node, i|
        person = Founder.where(email: node[:email]).first || Investor.where(email: node[:email]).first
        first_name, last_name = Util.split_name(node[:name])
        email = i == 0 ? node[:email] : nil
        { first_name: first_name, last_name: last_name, email: email, linkedin: person&.linkedin, twitter: person&.twitter, photo: person&.photo }
      end
      { first_hop_via: path.first.rel_type, through: through }
    end

    def node_list_from_path(path)
      nodes = [graph_node]
      path.each do |rel|
        nodes << (rel.start_node == nodes.last ? rel.end_node : rel.start_node)
      end
      nodes.drop(1)
    end
  end
end
