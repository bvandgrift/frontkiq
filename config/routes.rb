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

    resources :pending_retries, only: %i(index show)
    post 'pending_retries/:jid/kill',   to: 'pending_retries#kill',
                                        as: :kill_retry
    post 'pending_retries/:jid/delete', to: 'pending_retries#delete',
                                        as: :delete_retry
    post 'pending_retries/delete_all',  to: 'pending_retries#delete_all',
                                        as: :delete_retries
    post 'pending_retries/:jid/retry',  to: 'pending_retries#retry',
                                        as: :retry
    post 'pending_retries/retry_all',   to: 'pending_retries#retry_all',
                                        as: :retry_retries
    resources :scheduled_jobs,  only: %i(index)
    resources :abandoned_jobs,  only: %i(index)
  end
end
