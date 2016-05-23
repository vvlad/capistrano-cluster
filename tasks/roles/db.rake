# TODO: (vvlad): tune using pgtune

Kernel::require('resolv')

namespace :setup do
  task :db do
    on roles(:db) do
      install "postgresql-9.3", "postgresql-9.3-postgis-2.1"
      allowed_hosts = roles(:app).map(&:to_s)
      upload_as :postgres, file("pg_hba.conf", allowed_hosts: allowed_hosts),
        "/etc/postgresql/9.3/main/pg_hba.conf"
      upload_as :postgres, file("postgresql.conf", allowed_hosts: allowed_hosts),
        "/etc/postgresql/9.3/main/postgresql.conf"

      if test "[ ! -f /var/lib/postgresql/.first-time ]"
        sudo :service, "postgresql", :restart
        sudo :touch, "/var/lib/postgresql/.first-time"
      else
        sudo :service, "postgresql", :reload
      end
    end
  end
end

after "setup:system", "setup:db"

namespace :deploy do
  namespace :application do
    task :db do
      unless fetch(:database, {}).empty?
        db_user = fetch(:database)[:username]
        db_pass = fetch(:database)[:password]
        db_name = fetch(:database).fetch(:name, fetch(:application))
        enconding = fetch(:database)[:enconding] || "utf-8"

        on roles(:db) do
          if capture(:psql, "-U", "postgres", "template1", "-t", "-c", "SELECT 1 FROM pg_catalog.pg_user WHERE usename = '#{db_user}'".shellescape).empty?
            execute :psql, "-U", "postgres", "-c", "CREATE ROLE #{db_user} LOGIN PASSWORD '#{db_pass}';".shellescape
          end

          if capture(:psql, "-U", "postgres", "template1", "-t", "-c", "SELECT 1 FROM pg_catalog.pg_database WHERE datname = '#{db_name}'".shellescape).empty?
            execute :psql, "-U", "postgres", "-c", "CREATE DATABASE #{db_name} ENCODING '#{enconding}' OWNER #{db_user};".shellescape
            execute :psql, "-U", "postgres", "#{db_name}", "-c", "CREATE EXTENSION postgis;".shellescape
          end
        end

        on roles(:app) do
          defaults = {
            environment: fetch(:framework_env),
            hostname: primary(:db),
            name: db_name,
            adapter: 'postgresql',
            encoding: 'utf-8',
            options: {}
          }
          settings = defaults.merge(fetch(:database))
          upload! file("database.yml", settings), "#{shared_path}/config/database.yml"
        end
      end
    end
  end
end
