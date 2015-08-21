Rails.application.routes.draw do
  namespace :frontkiq do
    root to: "dashboard#index"

    resources :busy_workers, only: %i(index)
    post 'busy_workers',     to: 'busy_workers#update', 
                             as: :busy_workers_update

    resources :queued_jobs, only: %i(index show)
    post 'queued_jobs/:name',        to: 'queued_jobs#delete_queue',
                                     as: :delete_queue
    post 'queued_jobs/:name/delete', to: 'queued_jobs#delete_job',
                                     as: :delete_job

    resources :pending_retries, only: %i(index)
    get  'pending_retries/show/:key',   to: 'pending_retries#show_job',
                                        as: :pending_retry,
                                        constraints: { key: /[^\/]+/ }
                                        # the . makes rails think that the
                                        # score float is a format
    post 'pending_retries/selected',    to: 'pending_retries#update_selected',
                                        as: :update_selected_retries
    get  'pending_retries/:jid/kill',   to: 'pending_retries#kill_job',
                                        as: :kill_retry
    get  'pending_retries/:jid/delete', to: 'pending_retries#delete_job',
                                        as: :delete_retry
    get  'pending_retries/delete/all',  to: 'pending_retries#delete_all',
                                        as: :delete_retries
    get  'pending_retries/:jid/retry',  to: 'pending_retries#retry_job',
                                        as: :retry
    get  'pending_retries/retry/all',   to: 'pending_retries#retry_all',
                                        as: :retry_retries
    resources :scheduled_jobs,  only: %i(index)
    resources :abandoned_jobs,  only: %i(index)
  end
end
