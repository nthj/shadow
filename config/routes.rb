Shadow::Application.routes.draw do
  mount Resque::Server.new => '/jobs'
end
