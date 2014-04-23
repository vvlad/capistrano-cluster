namespace :setup do

  task :cache  do
    on roles(:cache) do
      unless test "[ -f /etc/redis/redis.conf ]"
        install "redis-server"
        upload_as :root, file("redis/redis.conf"), "/etc/redis/redis.conf"
        sudo 'nohup /etc/init.d/redis-server restart'
      end
    end
  end

end


after "setup:system", "setup:cache"
