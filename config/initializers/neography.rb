if Rails.env.production?
  uri = URI.parse(ENV['GRAPHENEDB_URL'])
  Neography.configure do |conf|
    conf.server = uri.host
    conf.port = uri.port
    conf.protocol = "#{uri.scheme}://"
    conf.authentication = 'basic'
    conf.username = uri.user
    conf.password = uri.password
  end
else
  Neography.configure do |conf|
    conf.username = 'neo4j'
    conf.password = ENV['NEO4J_PASSWORD']
  end
end

Graph.init!