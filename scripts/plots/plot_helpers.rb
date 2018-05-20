module PlotHelpers
  def all_founders
    Founder.where.not(logged_in_at: nil)
  end

  def fundraised_founders
    all_founders.joins(:emails).joins(:target_investors).where('target_investors.stage > 3').group('founders.id')
  end

  def fundraising_range(founder)
    [
      founder.target_investors.order(created_at: :asc).first.created_at,
      founder.target_investors.order(updated_at: :desc).first.updated_at,
    ]
  end

  def fundraising_emails(founder)
    founder.emails.where.not(investor: nil).where(bulk: false)
  end

  def average_round_sizes
    @avg_round_sizes ||= Competitor::INDUSTRIES.keys.each_with_object({}) do |industry, h|
      query = Company
        .where('companies.industry @> ?', "{#{industry}}")
        .joins(:investments)
        .select('investments.round_size')
        .to_sql
      h[industry] = Company.connection.select_value("SELECT AVG(round_size) FROM (#{query}) AS sizes").to_i
    end.with_indifferent_access
  end

  def total_funding(companies)
    companies.find_each.map do |company|
      sql = Investment
        .where(company: company)
        .group('investments.funding_type, investments.series')
        .select('MAX(investments.round_size)')
        .to_sql
      funding_from_rounds = Investment.connection.select_values(sql).compact.sum
      amount = [company.capital_raised, funding_from_rounds].max.to_f

      blended_avg_round_size = if company.industry.present?
        average_round_sizes.slice(*company.industry).values.sum / company.industry.length
      else
        average_round_sizes.values.sum / average_round_sizes.values.length
      end.to_f
      amount / blended_avg_round_size
    end.sum
  end

  def parallel_map(founders, &block)
    results = []
    founders.in_batches do |rel|
      Parallel.each(rel, in_threads: 32) do |founder|
        ActiveRecord::Base.connection_pool.with_connection do
          results << block.call(founder)
        end
      end
    end
    results
  end

  def save_data(data, name)
    open("ml/experiments/founder_rank/data/plots/#{name}.py", 'w') do |f|
      f.write('data = ')
      f.write(data.to_json)
    end
  end
end
