Rake::Task['assets:precompile'].enhance do
  Rake::Task['sitemap:refresh'].invoke
end
