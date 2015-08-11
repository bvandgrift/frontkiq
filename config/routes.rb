Rails.application.routes.draw do
  namespace :frontkiq do
    root to: "dashboard#index"

    resources :busy_workers,    only: %i(index)
    post 'busy_workers',        to: 'busy_workers#update', 
                                as: :busy_workers_update

    resources :queued_jobs,        only: %i(index show)
    post 'queued_jobs/:id',        to: 'queued_jobs#delete_queue',
                                   as: :delete_queue
    post 'queued_jobs/:id/delete', to: 'queued_jobs#delete_job',
                                   as: :delete_job

    resources :pending_retries, only: %i(index)
    resources :scheduled_jobs,  only: %i(index)
    resources :abandoned_jobs,  only: %i(index)
  end
end
