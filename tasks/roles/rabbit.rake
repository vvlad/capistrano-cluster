
namespace :setup do

  before :package_sources, :"rabbitmq:sources"


  namespace :rabbitmq do
    task :sources do

      on roles(:rabbitmq) do
        unless test "[ -f /etc/apt/sources.list.d/rabbitmq.list ]"
          execute %q[wget --quiet -O - http://www.rabbitmq.com/rabbitmq-signing-key-public.asc | sudo apt-key add -]
          upload_as :root, StringIO.new("deb http://www.rabbitmq.com/debian/ testing main"), "/etc/apt/sources.list.d/rabbitmq.list"
        end
      end

    end
  end

  task :rabbitmq do

    on roles(:rabbitmq) do
      install "rabbitmq-server"
    end

  end

end

after "setup:system", "setup:rabbitmq"


namespace :deploy do
  task :rabbitmq do
  end
end


before "deploy:publishing", "deploy:rabbitmq"
