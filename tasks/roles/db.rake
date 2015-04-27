namespace :setup do
  task :db, :app do |t,options|
    applications do
      invoke "setup:db:#{fetch(:database_type, :postgresql)}"
    end
  end
end

after "setup:system", "setup:db"

namespace :deploy do
  namespace :application do
    task :db do
      applications do
        invoke "deploy:application:db:#{fetch(:database_type, :postgresql)}"
      end
    end
  end
end
