desc "Bootstraps the servers"
task :setup do

  invoke "setup:users"
  invoke "setup:hostnames"
  invoke "setup:packages"
  invoke "setup:firewall"
  invoke "setup:customizations"
  invoke "setup:db"
  invoke "setup:indexer"
  invoke "setup:cache"
  invoke "setup:app"
  invoke "setup:web"
  invoke "setup:worker"
  invoke "setup:proxy"

end


namespace :setup do

  task :users do
    on roles(:all) do |host|

      host.user = :root if host
      user = fetch(:user)

      unless test "id -u #{user}"
        execute :useradd, "--home", "/home/#{user}", "-m", "--shell", "/bin/bash", user
        execute :mkdir, "-p", "#{home_path}/.ssh"
        execute :chmod, "0700", "#{home_path}/.ssh"
        execute :chown, "-R", "#{user}:#{user}", "#{home_path}"
        upload! StringIO.new("#{user} ALL=NOPASSWD:ALL"), "/etc/sudoers.d/#{user}"
      end

      upload! file('ssh/authorized_keys', keys: fetch(:deploy_keys,[])), "#{home_path}/.ssh/authorized_keys"
      upload! file('ssh/config', keys: fetch(:deploy_keys,[])), "#{home_path}/.ssh/config"
      execute :chmod, "0600", "#{home_path}/.ssh/authorized_keys #{home_path}/.ssh/config"
      execute :chown, "#{user}:#{user}", "#{home_path}/.ssh/authorized_keys #{home_path}/.ssh/config"

      host.user = fetch(:user) if host
    end

  end

  task :hostnames do

    on roles(:all) do
      sudo "bash -c 'echo \"127.0.0.1 $(hostname)\" >> /etc/hosts'"
    end

  end

  task :packages do

    on roles(:all) do
      update_apt_source_list
      install fetch(:default_packages,[])
      upload_as :root, file("apt.conf.d/10periodic"), "/etc/apt/apt.conf.d/10periodic"
      upload_as :root, file("apt.conf.d/50unattended-upgrades"), "/etc/apt/apt.conf.d/50unattended-upgrades"
    end

  end

  task :customizations do
    on roles(:all) do
      upload_as :root, file("tmux.conf"), "/etc/tmux.conf"
      sudo :chmod, "0644", "/etc/tmux.conf"
      upload_as :root, file("sshd_config"), "/etc/ssh/sshd_config"
      upload_as :root, file("issue.net"), "/etc/issue.net"
      sudo :service, 'ssh', 'reload'
      if test "[ ! -f /swap ]"
        sudo "dd if=/dev/zero of=/swap count=$(cat /proc/meminfo | head -1  | awk '{ print $2*2 }') bs=1KB"
        sudo "mkswap /swap"
        sudo "swapon /swap"
      end

    end
  end


  task :package_sources do
    on roles(:all) do

      unless test "[ -f /etc/apt/sources.list.d/pgdg.list ]"
        execute %q[wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -]
        upload_as :root, file("pgdg.list"), "/etc/apt/sources.list.d/pgdg.list"
        update_apt_source_list forced: true
      end

    end
  end

end


