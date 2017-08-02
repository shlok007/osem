Osem::Application.routes.draw do

  constraints DomainConstraint do
    get '/', to: 'conferences#show'
  end

  if ENV['OSEM_ICHAIN_ENABLED'] == 'true'
    devise_for :users, controllers: { registrations: :registrations }
  else
    devise_for :users,
               controllers: {
                   registrations: :registrations, confirmations: :confirmations,
                   omniauth_callbacks: 'users/omniauth_callbacks' },
               path: 'accounts'
  end

  # Use letter_opener_web to open mails in browser (e.g. necessary for Vagrant)
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  resources :users, except: [:new, :index, :create, :destroy] do
    resources :openids, only: :destroy
  end

  namespace :admin do
    resources :organizations
    resources :users do
      member do
        patch :toggle_confirmation
      end
    end
    resources :comments, only: [:index]
    resources :conferences do
      member do
        get :custom_domain
      end
      resource :contact, except: [:index, :new, :create, :show, :destroy]
      resources :schedules, only: [:index, :create, :show, :update, :destroy]
      resources :event_schedules, only: [:create, :update, :destroy]
      get 'commercials/render_commercial' => 'commercials#render_commercial'
      resources :commercials, only: [:index, :create, :update, :destroy]
      get '/volunteers_list' => 'volunteers#show'
      get '/volunteers' => 'volunteers#index', as: 'volunteers_info'
      patch '/volunteers' => 'volunteers#update', as: 'volunteers_update'

      resources :booths do
        member do
          patch :accept
          patch :restart
          patch :withdrawn
          patch :to_accept
          patch :reject
          patch :reset
          patch :to_reject
          patch :cancel
        end
      end

      resources :registrations, except: [:create, :new] do
        member do
          patch :toggle_attendance

        end
      end

      # Singletons
      resource :splashpage
      resource :venue do
        get 'venue_commercial/render_commercial' => 'venue_commercials#render_commercial'
        resource :venue_commercial, only: [:create, :update, :destroy]
        resources :rooms, except: [:show]
      end
      resource :registration_period
      resource :program do
        resources :cfps
        resources :tracks do
          member do
            patch :toggle_cfp_inclusion
          end
        end
        resources :event_types
        resources :difficulty_levels
        resources :events do
          member do
            patch :toggle_attendance
            get :registrations
            post :comment
            patch :accept
            patch :confirm
            patch :cancel
            patch :reject
            patch :unconfirm
            patch :restart
            get :vote
          end
        end
        resources :reports, only: :index
      end

      resources :resources
      resources :tickets
      resources :sponsors, except: [:show]
      resources :lodgings, except: [:show]
      resources :targets, except: [:show]
      resources :campaigns, except: [:show]
      resources :emails, only: [:show, :update, :index]
      resources :physical_ticket, only: [:index]
      resources :roles, only: [:edit]
      resources :roles, except: [ :new, :create, :edit ] do
        member do
          post :toggle_user
          get ':track_name' => 'roles#show', as: 'track'
          get ':track_name/edit' => 'roles#edit', as: 'track_edit'
          patch ':track_name' => 'roles#update'
          put ':track_name' => 'roles#update'
          post ':track_name/toggle_user' => 'roles#toggle_user', as: 'toggle_user_track'
        end
      end

      resources :sponsorship_levels, except: [:show] do
        member do
          patch :up
          patch :down
        end
      end

      resources :questions do
        collection do
          patch :update_conference
        end
      end
    end

    get '/revision_history' => 'versions#index'
    get '/revision_history/:id/revert_object' => 'versions#revert_object', as: 'revision_history_revert_object'
    get '/revision_history/:id/revert_attribute' => 'versions#revert_attribute', as: 'revision_history_revert_attribute'
  end
  resources :organizations, only: [:index]
  resources :conferences, only: [:index, :show] do
    resource :program, only: [] do
      resources :proposals, except: :destroy do
        get 'commercials/render_commercial' => 'commercials#render_commercial'
        resources :commercials, only: [:create, :update, :destroy]
        member do
          get :registrations
          patch '/withdraw' => 'proposals#withdraw'
          get :registrations
          patch '/confirm' => 'proposals#confirm'
          patch '/restart' => 'proposals#restart'
        end
      end
      resources :tracks, except: :destroy
    end

    # TODO: change conference_registrations to singular resource
    resource :conference_registration, path: 'register'
    resources :tickets, only: [:index]
    resources :ticket_purchases, only: [:create, :destroy, :index]
    resources :payments, only: [:index, :new, :create]
    resources :physical_ticket, only: [:index, :show]
    resource :subscriptions, only: [:create, :destroy]
    resource :schedule, only: [:show] do
      member do
        get :events
      end
    end
  end

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :conferences, only: [ :index, :show ] do
        resources :rooms, only: :index
        resources :tracks, only: :index
        resources :speakers, only: :index
        resources :events, only: :index
      end
      resources :rooms, only: :index
      resources :tracks, only: :index
      resources :speakers, only: :index
      resources :events, only: :index
    end
  end

  get '/admin' => redirect('/admin/conferences')

  root to: 'conferences#index', via: [:get, :options]
end
