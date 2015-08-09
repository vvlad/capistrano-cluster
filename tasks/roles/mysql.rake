#TODO (vvlad): tune using pgtune
namespace :setup do
  namespace :db do
    task :mysql do

      on roles(:db) do
        sudo "DEBIAN_FRONTEND=noninteractive aptitude install -y mysql-server-5.6"
        sudo :sed, "-i", "\"s/bind-address.*/bind-address = 0.0.0.0/\" /etc/mysql/my.cnf"

        if test "[ ! -f /var/lib/mysql/.first-time ]"
          sudo :service, "mysql", :restart
          sudo :touch, '/var/lib/mysql/.first-time'
        else
          sudo :service, "mysql", :reload
        end
      end

    end

  end
end

namespace :deploy do
  namespace :application do
    namespace :db do
      task :mysql do
        unless fetch(:database,{}).empty?
          db_user = fetch(:database)[:username]
          db_pass = fetch(:database)[:password]
          db_name = fetch(:database).fetch(:name, fetch(:application))
          enconding = fetch(:database)[:enconding] || "utf-8"

          on roles(:db) do
            execute :mysql, "-u", "root", "-e", "\"CREATE DATABASE IF NOT EXISTS #{db_name} CHARACTER SET utf8 COLLATE utf8_general_ci;\""
            roles(:app).each do |server|
              [server.hostname.to_s, server.properties.private_ip].compact.each do |host|
                execute :mysql, "-u", "root", "-e", "\"GRANT ALL ON \\\`#{db_name}\\\`.* TO '#{db_user}'@'#{host}' IDENTIFIED BY '#{db_pass}'\";"
              end
            end
          end

          on roles(:app) do
            defaults = {
              environment: fetch(:framework_env),
              hostname: primary(:db),
              name: db_name,
              adapter: 'mysql2',
              encoding: 'utf8',
              options:{}
            }
            settings = defaults.merge(fetch(:database))
            upload! file("database.yml", settings), "#{shared_path}/config/database.yml"
          end
        end
      end
    end
  end
end
