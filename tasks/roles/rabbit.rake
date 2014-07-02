
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
      upload_as :rabbitmq, StringIO.new("[rabbitmq_management,rabbitmq_management_visualiser,rabbitmq_stomp,rabbitmq_amqp1_0,rabbitmq_mqtt]."), "/etc/rabbitmq/enabled_plugins"
    end

  end

end

after "setup:system", "setup:rabbitmq"


namespace :deploy do
  task :rabbitmq do
  end
end

namespace :firewall do
  task :rabbitmq do
    on roles(:rabbitmq) do |server|
      sudo :ufw, :allow, :in, :epmd
      sudo :ufw, :allow, :in, :amqp
      sudo :ufw, :allow, :in, :'25672'
      sudo :ufw, :allow, :in, :'15672'
    end
  end
end


before "deploy:publishing", "deploy:rabbitmq"
after "setup:firewall", "firewall:rabbitmq"
