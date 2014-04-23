

namespace :setup do

  task :web do

    on roles(:web) do
      install %w[nginx]
      upload_as :root, file("lb-sysctl.conf"), "/etc/sysctl.d/20-web.conf"
      sudo :sysctl, "-p", "/etc/sysctl.d/20-web.conf"

      sudo :mkdir, "-p", "/etc/nginx/servers"
      upload_as :root, file("nginx/nginx.conf", user: fetch(:user)), "/etc/nginx/nginx.conf"
      sudo :rm, "-f", *%w[fastcgi_params proxy_params scgi_params uwsgi_params].map { |file| file.prepend("/etc/nginx/") }
      sudo :rm, "-rf", *%w[sites-available sites-enabled conf.d].map { |file| file.prepend("/etc/nginx/") }
      sudo "nginx -s reload || sudo service nginx restart"
    end

  end

end

after "setup:customizations", "setup:web"

namespace :deploy do

  namespace :application do

    task :web do

      on roles(:web) do |host|

        upload! file("unicorn.rb", instances: host.properties.instances ), shared_path.join("config/unicorn.rb")
        upload! file("nginx/application.conf"), shared_path.join("config/nginx.conf")

        service "#{fetch(:application)}-web" do
          user fetch(:user)
          working_dir current_path
          start "bundle exec unicorn_rails -E '#{fetch(:framework_env)}' -l '#{shared_path.join("tmp/sockets/nginx.sock")}' -c '#{shared_path.join("config/unicorn.rb")}'"
          stop "kill -TERM $(cat '#{shared_path.join("tmp/pids/unicorn.pid")}')"
          reload "kill -USR2 $(cat '#{shared_path.join("tmp/pids/unicorn.pid")}') || start "
        end

      end
    end



    task :reload do
      on roles(:web) do
        sudo "nginx -s reload || sudo service nginx restart"
      end
    end



  end

end



namespace :deploy do
  after :restart, "application:reload"
end

