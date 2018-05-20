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

  def total_funding(companies)
    funding_from_companies = companies.sum('companies.capital_raised')

    sql = Investment.where(company: companies).group('investments.funding_type, investments.series').select('MAX(investments.round_size)').to_sql
    funding_from_rounds = Investment.connection.select_values(sql).compact.sum

    [funding_from_companies, funding_from_rounds].max
  end

  def parallel_map(founders, &block)
    results = []
    founders.in_batches do |rel|
      Parallel.each(rel, in_threads: 16) do |founder|
        results << block.call(founder)
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
