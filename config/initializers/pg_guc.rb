module ApplyPgGuc
  def new_connection
    super.tap do |conn|
      Rails.configuration.pg_guc.each do |name, conf|
        if conf[:function].present?
          conn.execute("SELECT #{conf[:function]}(#{conf[:value]});")
        else
          conn.execute("SET #{name} = #{conf[:value]};")
        end
      end
    end
  end
end

ActiveRecord::ConnectionAdapters::ConnectionPool.prepend ApplyPgGuc unless Rails.env.test?