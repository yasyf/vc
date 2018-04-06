class Investment < ApplicationRecord
  belongs_to :company
  belongs_to :competitor
  belongs_to :investor

  after_commit :add_graph_relationship!, on: :create

  def self.assign_to_investor(investor, company, featured: false, no_replace: false)
    scope = where(competitor: investor.competitor, company: company)
    if (existing = scope.first).present?
      existing.investor = investor unless no_replace
      existing.featured = featured if featured
      existing.tap(&:save!)
    else
      scope.first_or_create!(investor: investor, featured: featured)
    end
  end

  def fund_type
    [funding_type, series && "series_#{series}"].compact
  end

  def bulk_graph_rels
    return [] unless investor.present?
    company.founders.map do |founder|
      [
        :create_unique_relationship,
        Graph.rel_index_name(:invest),
        :invest,
        Graph.rel_value(investor.graph_node, founder.graph_node),
        :invest,
        investor.graph_node,
        founder.graph_node,
      ]
    end
  end

  private

  def add_graph_relationship!
    return unless investor.present?
    company.founders.each do |founder|
      investor.connect_to! founder, :invest
    end
  end
end
