Vatican::Application.routes.draw do
  devise_for :users, :controllers => {:registrations => 'registrations'}
  match 'auth/:provider/callback' => 'authentications#create'

  match 'entities/:id/rdf' => 'entities#rdf', :as => :rdf_entities

  resources :authentications
  resources :entities do
    member do
      get :revisions
      delete :revert, :action => :revert
    end
  end
  resources :groups
  resources :namespaces do
    resources :types
  end
  
  resources :main do
  end
  
  namespace :backend do
    resources :groups
    resources :types

    resources :jobs do
      collection do
        get :queue
        get :log
        delete :log, :action => :destroy_log
      end
    end
    
    resources :namespaces
    
    resource :main do
      collection do
        get :index
        get :entities_to_check
      end
    end
    root :to => "main#index"
  end  

  root :to => "main#index"
end
