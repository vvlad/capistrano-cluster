require 'erb'
require 'ostruct'
require 'delegate'

module Capistrano
  module Cluster
    module Packages
      module DSL

        def install(*packages)
          update_apt_source_list
          sudo "apt-get", "-q", "-y", "--force-yes","install", *packages.flatten
        end

        class TemplateContext < SimpleDelegator
          def initialize(obj, variables={})
            __setobj__(obj)
            @vars = variables
            variables.each_pair do |name, value|
              class <<self; self;end.send(:define_method,name, &->(){ value })
            end
          end

        end

        def file(source, locals={})

          if file = file_path(source)
            content = if file =~ /\.erb$/
              ERB.new(File.read(file)).result(TemplateContext.new(self, locals).instance_eval { binding })
            else
              File.read(file)
            end
            StringIO.new(content)
          else
            raise "File #{source} not found"
          end

        end

        def file_path(source)
          lookup_paths = [fetch(:files_path), fetch(:default_templates_path)].compact
          lookup_paths.map do |path|
            [File.join(path, "#{source}"), File.join(path, "#{source}.erb")]
          end.flatten.select do |file|
            File.exists? file
          end.first
        end

        def update_apt_source_list(forced: false)
          sudo "apt-get", "-q", "-y", "update" if forced or test "[ ! -z $(find /var/lib/apt/periodic/update-success-stamp -mmin +120) ]"
        end

      end
    end
  end
end


include Capistrano::Cluster::Packages::DSL

set :files_path, fetch(:files_path, Pathname(fetch(:deploy_config_path, "./deploy")).dirname.join("files"))
