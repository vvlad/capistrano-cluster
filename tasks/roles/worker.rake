
namespace :deploy do
  before :starting, "deploy:worker:add_default_hooks"
end



namespace :setup do


  desc "Setup worker"
  task :worker do

    on roles(:worker) do
      if test "[ -z $(which foreman) ]"
        sudo :gem, 'install', 'foreman'
      end
    end

  end

end


namespace :deploy do

  task :worker do

    on roles(:worker) do
      config = {
        framework_env: fetch(:framework_env),
        current_path: current_path,
        processes: fetch(:workers, {})
      }
      upload! file("Procfile", config), "#{shared_path}/Procfile-workers"

      sudo "foreman export upstart /etc/init --app=#{fetch(:application)}-worker --user=#{fetch(:user)}  --root=#{current_path} --procfile=#{shared_path}/Procfile-workers --log=#{shared_path}/log/ --env=#{shared_path}/.env"

    end

  end

  namespace :worker do

    task :add_default_hooks do
      after 'deploy:starting',  'deploy:worker:stop'
      after 'deploy:updated',   'deploy:worker:stop'
      after 'deploy:reverted',  'deploy:worker:stop'
      after 'deploy:published', 'deploy:worker:start'
    end

    task :start do
      on roles(:worker) do
        sudo "bash -c 'start #{fetch(:application)}-worker'"
      end
    end

    task :stop do
      on roles(:worker) do
        sudo "bash -c 'stop #{fetch(:application)}-worker || true'"
      end
    end

    task :restart do
      invoke "deploy:worker:stop"
      invoke "deploy:worker:start"
    end

  end

end


