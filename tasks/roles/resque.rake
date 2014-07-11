
namespace :deploy do
  before :starting, "deploy:resque:deployment_hooks"

  namespace :resque do

    task :deployment_hooks do
      after 'deploy:starting',  'deploy:resque:stop'
      after 'deploy:updated',   'deploy:resque:update'
      after 'deploy:reverted',  'deploy:resque:stop'
      after 'deploy:published', 'deploy:resque:start'
    end

    task :stop do
      on roles(:resque) do
        service = [fetch(:application), fetch(:stage), 'resque', '*'].join("-")
        execute :find, "/etc/init.d", "-type f", "-name #{service}", "-exec {} stop \\;"
      end
      on primary :resque_scheduler do
        execute "/etc/init.d/#{fetch(:application)}-scheduler stop || true"
      end

    end


    task update: :stop do
      on roles(:resque) do |host|

        match = [fetch(:application), fetch(:stage), 'resque', '*'].join("-")
        sudo :find, "/etc/init.d", "-type f", "-name '#{match}'", "-exec rm -f {} \\;"

        if test "[ -f /etc/init/#{fetch(:application)}-worker.conf ]"
          sudo "stop '#{fetch(:application)}-worker' || true"
          sudo "rm -f /etc/init/#{fetch(:application)}-worker*.conf"
        end

        host.properties.workers.to_i.times do |worker_id|

          service_name = [fetch(:application), fetch(:stage), 'resque', worker_id].join("-")
          service service_name do
            user fetch(:user)
            working_dir release_path

            pid_file shared_path.join("tmp/pids/resque-#{worker_id}.pid")
            log_file shared_path.join("log/resque-#{worker_id}.log")

            start "bundle exec rake resque:work RAILS_ENV=#{fetch(:framework_env)} 'QUEUE=*' PIDFILE=#{pid_file} INTERVAL=#{fetch(:resque_interval, 0.1)} LOGFILE=#{log_file}"
            stop "kill -QUIT $(cat '#{pid_file}')"

          end
        end

      end

      on primary :resque_scheduler do

        service "#{fetch(:application)}-scheduler" do
          user fetch(:user)
          working_dir release_path

          pid_file shared_path.join("tmp/pids/resque-scheduler.pid")
          log_file shared_path.join("log/resque-scheduler.log")

          start "bundle exec rake environment resque:scheduler RAILS_ENV=#{fetch(:framework_env)} 'QUEUE=*' PIDFILE=#{pid_file} RESQUE_SCHEDULER_INTERVAL=#{fetch(:resque_interval, 0.1)} LOGFILE=#{log_file}"
          stop "kill -QUIT $(cat '#{pid_file}')"
        end

      end
    end


    task :start do
      on roles(:resque) do

        host.properties.workers.to_i.times do |worker_id|
          service_name = [fetch(:application), fetch(:stage), 'resque', worker_id].join("-")
          run "/etc/init.d/#{service_name} start"
        end
      end

      on primary :resque_scheduler do
        if test "[ -f '/etc/init.d/#{fetch(:application)}-scheduler' ]"
          execute "/etc/init.d/#{fetch(:application)}-scheduler", :start
        end
      end

    end

    task restart: [:stop, :start]


  end

end


