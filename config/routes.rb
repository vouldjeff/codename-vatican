Vatican::Application.routes.draw do
  devise_for :users, :controllers => {:registrations => 'registrations'}
  match 'auth/:provider/callback' => 'authentications#create'

  match 'entities/show/:key' => 'entities#show', :as => :entity
  match 'rdf/entity/:key' => 'entities#show_rdf', :as => :entity_rdf
  match 'entities/list/:namespace/:key' => 'entities#list', :as => :entities_list

  resources :authentications
  resources :entities  
  resources :namespaces do
    resources :types
  end

  root :to => "namespaces#index"
end
