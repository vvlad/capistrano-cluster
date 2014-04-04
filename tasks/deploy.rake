require 'shellwords'

namespace :deploy do

  task :restart do

    on roles(:web) do
      sudo "/etc/init.d/#{fetch(:application)}-web", :reload
    end

  end

end


class Rake::Task
  def overwrite(&block)
    @actions.clear
    prerequisites.clear
    enhance(&block)
  end
  def abandon
    prerequisites.clear
    @actions.clear
  end
end

namespace :deploy do
  after :publishing, :restart
end

Rake::Task["deploy:check:linked_files"].overwrite do
  next unless any? :linked_files
  on release_roles :app do |host|
    linked_files(shared_path).each do |file|
      unless test "[ -f #{file} ]"
        error t(:linked_file_does_not_exist, file: file, host: host)
        exit 1
      end
    end
  end
end


Rake::Task["deploy"].clear

desc 'Deploy a new release.'

task :deploy, :app do |t,options|

  applications options[:app] do
    %w{ starting started
        updating updated
        publishing published
        finishing finished }.each do |task|

      invoke "deploy:#{task}"
    end

  end

end



desc "On app"
task :application, :app do |t,options|
  if application = applications(options[:app]).first
    configure_application application
  end
end
