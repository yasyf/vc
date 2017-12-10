module CompetitorLists::Base::ClassSortable
  SORTS = {
    name: 'name',
    full_name: "first_name || ' ' || last_name",
    last_response: 'last_response',
    hq: 'COALESCE(hq, location[1])',
    fund_type: { asc: 'fund_type[1]', desc: 'fund_type[array_length(fund_type, 1)]' },
    stage: "COALESCE(stage, #{TargetInvestor::STAGES.length - 1})",
  }

  def order_sql_from_sort(sort)
    sort
      .select { |s, d| d != 0 }
      .map do |s, d|
        direction = d == 1 ? 'ASC' : 'DESC'
        fragment = SORTS[s].is_a?(Hash) ? SORTS[s][direction.downcase.to_sym] : SORTS[s]
        "#{fragment} #{direction} NULLS LAST"
      end.join(', ')
  end
end