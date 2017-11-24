if Rails.application.vcwiz?
  Rake::Task['assets:precompile'].enhance do
    Rake::Task['sitemap:refresh'].invoke unless Rails.env.test?
  end
end