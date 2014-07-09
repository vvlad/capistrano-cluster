
set :default_packages, %w{tmux htop vim-nox software-properties-common curl wget unattended-upgrades bash-completion git lsof ufw ngrep}
set :packages, fetch(:packages, [])

desc "Bootstraps the servers"
task prepare: %w{setup:system setup:finished}


namespace :setup do

  task system: [:hostname, :swap, :users, :package_sources, :packages, :customizations]

  task :users do
    on roles(:all) do |host|

      login_as(:root, on: host) do
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

      end

    end

  end

  task :finished

  task :hostname do

    on roles(:all) do |host|
      login_as :root, on: host do
        unless (hostname = capture(:hostname).strip).empty?
          upload_as :root, file("etc/hosts", hostname: hostname), "/etc/hosts"
        end
      end
    end

  end

  task :packages do

    on roles(:all) do
      upload_as :root, file("apt.conf.d/10periodic"), "/etc/apt/apt.conf.d/10periodic"
      upload_as :root, file("apt.conf.d/50unattended-upgrades"), "/etc/apt/apt.conf.d/50unattended-upgrades"
      packages = fetch(:default_packages,[]) + fetch(:packages,[])
      install *packages unless packages.empty?
    end

  end

  task :customizations do
    on roles(:all) do
      upload_as :root, file("tmux.conf"), "/etc/tmux.conf"
      sudo :chmod, "0644", "/etc/tmux.conf"
      upload_as :root, file("sshd_config"), "/etc/ssh/sshd_config"
      upload_as :root, file("issue.net"), "/etc/issue.net"
      sudo :service, 'ssh', 'reload'
    end
  end

  task :swap do
    on roles(:swap) do
      if test "[ ! -f /swap ]"
        sudo "dd if=/dev/zero of=/swap count=$(cat /proc/meminfo | head -1  | awk '{ print $2*2 }') bs=1KB"
        sudo "mkswap /swap"
        sudo "swapon /swap"
        sudo "echo '/swap none            swap    sw              0       0' >> /etc/fstab "
      end
    end
  end


  task :package_sources do
    on roles(:all) do
      unless test "[ -f /etc/apt/sources.list.d/pgdg.list ]"
        execute %q[wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -]
        sudo %q[echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -c | awk '{print $2}'`-pgdg main" >/etc/apt/sources.list.d/pgdg.list]
      end
    end
  end

end


