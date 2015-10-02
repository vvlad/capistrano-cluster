
require "capistrano/setup"
require "capistrano/deploy"
require "capistrano/bundler"
require "capistrano/rails/assets"
require "capistrano/rails/migrations"
require "capistrano/rails"

require "capistrano/cluster/version"
require "capistrano/cluster/core_ext/object"
require "capistrano/cluster/application"
require "capistrano/cluster/packages"
require "capistrano/cluster/files"
require "capistrano/cluster/paths"
require "capistrano/cluster/service"

set :default_templates_path, File.expand_path("../../../files", __FILE__)

module Capistrano
  module Cluster
  end
end

tasks_path = Pathname(File.expand_path("../../../tasks/", __FILE__))

import tasks_path.join("setup.rake")
import tasks_path.join("setup/firewall.rake")

Dir.glob(tasks_path.join("*/*.rake")).each do |r|
  import r
end

import tasks_path.join("deploy.rake")
import tasks_path.join("deploy/application.rake")
