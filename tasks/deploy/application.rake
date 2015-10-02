namespace :deploy do
  namespace :check do
    task :application do
      on roles(:app) do
        sudo :mkdir, "-p", deploy_to, shared_path.join("config")
        sudo :chown, "-R", fetch(:user), deploy_to, shared_path.join("config")
      end

      invoke "deploy:application:secrets"
      invoke "deploy:application:web"
      invoke "deploy:application:indexer"
      invoke "deploy:application:db"
      invoke "deploy:application:proxy"
    end
  end

  namespace :application do
    task :secrets do
      on roles(:app) do
        env = StringIO.new
        gc_settings = {
          "RUBY_HEAP_MIN_SLOTS" => 800_000,
          "RUBY_FREE_MIN" => 100_000,
          "RUBY_GC_MALLOC_LIMIT" => 59_000_000
        }

        fetch(:secrets, {}).merge(gc_settings).each_pair do |key, value|
          env.puts "export #{"#{key}".upcase}='#{Shellwords.shellescape(value)}'"
        end
        env.rewind

        upload! env, shared_path.join(".env")
        yaml = StringIO.new({ "#{fetch(:framework_env)}" => fetch(:secrets, {}) }.to_yaml)

        upload! yaml, shared_path.join("config/secrets.yml")
      end
    end
  end
end

before "deploy:symlink:linked_files", "check:application"
before "deploy:check:directories", "check:application"
