namespace :setup do

  namespace :app do
    task :packages do
      on roles(:app) do
        install fetch(:app_packages)
        if test "[ ! -f /etc/gemrc ]"
          upload_as :root, StringIO.new("install: --no-rdoc --no-ri\nupdate:  --no-rdoc --no-ri"), "/etc/gemrc"
          sudo :chmod, '0644', "/etc/gemrc"
        end

        if test "[ -z $(which bundler) ]"
          sudo :gem, 'install', 'bundler'
        end

      end
    end
  end
end

after "setup:system", "setup:app:packages"

set :app_packages, %w[
  autoconf
  bind9-host
  bison
  build-essential
  curl
  daemontools
  dnsutils
  ed
  git
  imagemagick
  iputils-tracepath
  libcurl4-openssl-dev
  libevent-dev
  libglib2.0-dev
  libjpeg-dev
  libjpeg62
  libpng12-0
  libpng12-dev
  libmagickcore-dev
  libmagickwand-dev
  libmcrypt-dev
  libmysqlclient-dev
  libpq-dev
  libsqlite3-dev
  libssl-dev
  libssl0.9.8
  libxml2-dev
  libxslt-dev
  mercurial
  netcat-openbsd
  ruby2.0-dev
  ruby2.0
  socat
  sqlite3
  telnet
  zlib1g-dev
  postgresql-client-9.3
  jpegoptim
  libv8-dev
]
