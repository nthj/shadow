desc 'create a new draft post'
task :post do
  require 'date'
  title = ENV['TITLE']
  slug = "#{Date.today}-#{title.downcase.gsub(/[^\w]+/, '-')}"

  file = File.join(
    File.dirname(__FILE__),
    '_posts',
    slug + '.markdown'
  )

  File.open(file, "w") do |f|
    f << <<-EOS.gsub(/^    /, '')
    ---
    layout: default
    title: #{title}
    published: false
    categories: #{ENV['CATEGORIES']}
    ---

    EOS
  end

  system ("#{ENV['EDITOR']} #{file}")
end

desc 'publish short url' 
task :publish do
  system("heroku rake add DESTINATION=#{ENV['DESTINATION']} KEY=#{ENV['KEY']} --app b-nthj")
end
