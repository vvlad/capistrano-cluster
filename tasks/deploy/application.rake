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
          "RUBY_HEAP_MIN_SLOTS" => 800000,
          "RUBY_FREE_MIN" => 100000,
          "RUBY_GC_MALLOC_LIMIT" => 59000000
        }
        fetch(:secrets, {}).merge(gc_settings).each_pair do |key,value|
          env.puts "export #{"#{key}".upcase}=#{value}"
        end
        env.rewind
        upload! env, shared_path.join(".env")
      end

    end


  end

end

before "deploy:symlink:linked_files", "check:application"
before "deploy:check:directories", "check:application"

