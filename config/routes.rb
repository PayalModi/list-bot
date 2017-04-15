Rails.application.routes.draw do
  root 'welcome#homepage'
  get 'welcome/homepage'
  post '/', to: 'welcome#homepage'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
