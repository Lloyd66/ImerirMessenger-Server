Rails.application.routes.draw do

  namespace :api, :defaults => {:format => :json}do
    namespace :v1 do
      resources :user, :only => [:create, :connect] do
        collection do
          post 'connect'
          put '', :to => "user#update"
        end
      end
      resources :channel do
        post :join
        delete :quit

        resources :message, :only => [:create, :index]
      end
    end
  end

  resources :documentation, :only => :index

  root :to => "documentation#index"
end
