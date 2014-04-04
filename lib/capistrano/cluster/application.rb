require 'securerandom'
set :applications, []


module Capistrano
  module Cluster
    class Application

      def initialize(&configurator)
        @configurator = configurator
      end

      def configure!
        @configurator.call
      end

    end


    module DSL

      def application(&block)
        fetch(:applications) << Application.new(&block)
      end

      def configure_application(application)
        original_env = Capistrano::Configuration.env
        Capistrano::Configuration.env = original_env.copy
        application.configure!
        original_env
      end

      def with_application(application, &block)
        original_env = configure_application(application)
        yield
      ensure
        Capistrano::Configuration.env = original_env
      end

      def applications(*names, &block)
        names.compact!
        fetch(:applications).map do |application|
          with_application application do
            if names.include? "#{fetch(:application)}" or names.empty?
              yield if block_given?
              application
            end
          end
        end.compact
      end

    end
  end
end


include Capistrano::Cluster::DSL


Capistrano::Configuration.class_eval do

  def self.env=(value)
    @env = value
  end

end
