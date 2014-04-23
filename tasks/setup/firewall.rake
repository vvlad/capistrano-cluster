namespace :setup do

  task :firewall do

    def ufw(*rule)
      sudo :ufw, *rule
    end

    on roles(:all) do
      upload_as :root, file("ufw"), "/etc/default/ufw"
      ufw :allow, "in ssh"
    end

    on roles(:db) do
      roles(:app).each do |server|
        ufw :allow, "proto tcp from #{server.hostname} to any port postgresql"
      end
    end

    on roles(:indexer) do
      roles(:app).each do |server|
        ufw :allow, "proto tcp from #{server.hostname} to any port 8983"
      end
    end

    on roles(:cache) do
      roles(:app).each do |server|
        ufw :allow, "proto tcp from #{server.hostname} to any port 6379"
      end
    end

    on roles(:web) do
      roles(:proxy).each do |server|
        ufw :allow, "proto tcp from #{server.hostname} to any port http"
      end
    end


    on roles(:proxy).each do |server|
      ufw :allow, "in http"
      ufw :allow, "in https"
    end

    on roles(:all) do
      execute :yes, "| sudo ufw enable"
    end

  end

end


before "setup:finished", "setup:firewall"
