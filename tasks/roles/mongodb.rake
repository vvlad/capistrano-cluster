namespace :setup do
  namespace :mongodb do

    task :sources do

      on roles(:mongodb) do
        unless test "[ -f /etc/apt/sources.list.d/mongodb-org-3.0.list ]"
          sudo %q[apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10]
          execute %q[echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list]
        end
      end

    end

  end

  task :mongodb do

    on roles(:mongodb) do
      install "mongodb-org"
      upload_as :root, file("etc/mongod.conf"), "/etc/mongod.conf"
      sudo "restart mongod || start mongod"
    end

  end

end

namespace :deploy do
  task :rabbitmq do
  end
end

namespace :firewall do
  task :mongodb do
    on roles(:mongodb) do |server|
      sudo :ufw, :allow, :in, 27017
      sudo :ufw, :allow, :in, 27018
      sudo :ufw, :allow, :in, 27019
      sudo :ufw, :allow, :in, 28017
    end
  end
end


before "deploy:publishing", "deploy:mongodb"
after "setup:firewall", "firewall:mongodb"
after "setup:system", "setup:mongodb"
before "setup:packages", "setup:mongodb:sources"
