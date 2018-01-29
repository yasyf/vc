class Search
  def self.search_investors(params, condition: :and)
    <<-SQL
      SELECT
        competitors.id AS id,
        investors.id AS match_id,
        #{[
          params[:first_name] && Util.sanitize_sql('COALESCE(similarity(investors.first_name, ?), 0)', params[:first_name]),
          params[:last_name] && Util.sanitize_sql('COALESCE(similarity(investors.last_name, ?), 0)', params[:last_name]),
          params[:firm_name] && Util.sanitize_sql('COALESCE(similarity(competitors.name, ?), 0)', params[:firm_name]),
        ].compact.join(' + ')} AS rank
      FROM investors
      INNER JOIN competitors on investors.competitor_id = competitors.id
      WHERE
        #{[
          params[:first_name] && Util.sanitize_sql('((investors.first_name % ?) OR (investors.first_name ILIKE ?))', params[:first_name], "#{params[:first_name]}%"),
          params[:last_name] && Util.sanitize_sql('((investors.last_name % ?) OR (investors.last_name ILIKE ?))', params[:last_name], "#{params[:last_name]}%"),
          params[:firm_name] && Util.sanitize_sql('((competitors.name % ?) OR (competitors.name ILIKE ?))', params[:firm_name], "#{params[:firm_name]}%"),
        ].compact.join(" #{condition.to_s.upcase} ")}
    SQL
  end
end