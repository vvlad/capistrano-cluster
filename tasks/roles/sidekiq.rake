namespace :deploy do
  before :starting, "deploy:sidekiq:deployment_hooks"

  namespace :sidekiq do
    task :deployment_hooks do
      after "deploy:starting",  "deploy:sidekiq:stop"
      after "deploy:updated",   "deploy:sidekiq:update"
      after "deploy:reverted",  "deploy:sidekiq:stop"
      after "deploy:published", "deploy:sidekiq:start"
    end

    task :update do
      on roles(:sidekiq) do
        service "#{fetch(:application)}-sidekiq" do
          user fetch(:user)
          working_dir current_path
          args = "-e '#{fetch(:framework_env)}' -C '#{current_path}/config/sidekiq.yml'"
          args << " -L '#{current_path}/log/sidekiq.log'"
          args << " -P '#{current_path}/tmp/pids/sidekiq.pid' #{fetch(:sidekiq_options)}"
          start "bundle exec sidekiq #{args}"
          stop "bundle exec sidekiqctl stop '#{current_path}/tmp/pids/sidekiq.pid' 10"
        end
      end
    end

    task :start do
      on roles(:sidekiq) do
        sudo "/etc/init.d/#{fetch(:application)}-sidekiq", :start
      end
    end

    task :stop do
      on roles(:sidekiq) do
        sudo "/etc/init.d/#{fetch(:application)}-sidekiq stop || true"
      end
    end

    task restart: [:stop, :start]
  end
end
