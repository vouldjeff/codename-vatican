Vatican::Application.routes.draw do
  devise_for :users, :controllers => {:registrations => 'registrations'}
  match 'auth/:provider/callback' => 'authentications#create'

  match 'entities/:id/rdf' => 'entities#rdf', :as => :rdf_entities

  resources :authentications
  resources :entities  
  resources :namespaces do
    resources :types
  end

  root :to => "namespaces#index"
end
