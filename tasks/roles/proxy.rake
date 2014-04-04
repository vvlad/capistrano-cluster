
namespace :setup do

  task :proxy do

      on roles(:proxy) do

        install "nginx"

        upload_as :root, file("lb-sysctl.conf"), "/etc/sysctl.d/20-web.conf"
        sudo :sysctl, "-p", "/etc/sysctl.d/20-web.conf"
        sudo :mkdir, "-p", "/etc/nginx/servers"
        upload_as :root, file("nginx/lb-nginx.conf", user: fetch(:user)), "/etc/nginx/nginx.conf", mode: 644

        sudo :rm, "-f", *%w[fastcgi_params proxy_params scgi_params uwsgi_params].map { |file| file.prepend("/etc/nginx/") }
        sudo :rm, "-rf", *%w[sites-available sites-enabled conf.d].map { |file| file.prepend("/etc/nginx/") }

        sudo "bash -c 'nginx -s reload || service nginx restart'"

      end

  end

end


namespace :deploy do

  namespace :application do

    task :proxy do

      on roles(:proxy) do

        shared_path = Pathname.new("/etc/nginx/servers/#{fetch(:application)}-#{fetch(:framework_env)}")

        sudo :mkdir, '-p', shared_path
        sudo :chown, "-R", fetch(:user), shared_path

        if ssl_certificate = fetch(:ssl_certificate)
          upload_as :root, StringIO.new(ssl_certificate), shared_path.join("ssl.pem")
        end
        upload_as :root, file("nginx/lb-application.conf", ssl: ssl_certificate), shared_path.join("nginx.conf")

        sudo "bash -c 'nginx -s reload || service nginx restart'"

      end

    end

  end

end
