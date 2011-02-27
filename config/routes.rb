Vatican::Application.routes.draw do
  devise_for :users, :controllers => {:registrations => 'registrations'}
  match 'auth/:provider/callback' => 'authentications#create'

  match 'entities/:id/rdf' => 'entities#rdf', :as => :rdf_entities

  resources :authentications
  resources :entities  
  resources :namespaces do
    resources :types
  end
  
  namespace :backend do
    resources :jobs do
      collection do
        get :queue
        get :log
        delete :log, :action => :destroy_log
      end
    end
  end  

  root :to => "namespaces#index"
end
