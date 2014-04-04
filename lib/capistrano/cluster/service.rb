module Capistrano
  module Cluster
    class Service
      attr :name, :cmd
      def initialize(name, &block)
        @name = name
        instance_eval(&block)
      end

      def start(*args)
        @start = args.first if args.length > 0
        @start || fail("no start command defined for #{@name}")
      end

      def working_dir(*args)
        @working_dir = args.first if args.length > 0
        @working_dir || "/tmp"
      end

      def pid_file(*args)
        @pid_file = args.first if args.length > 0
        @pid_file || "/var/run/#{@name}.pid"
      end

      def reload(*args)
        @reload = args.first if args.length > 0
        @reload || "stop;start"
      end

      def stop(*args)
        @stop = args.first if args.length > 0
        @stop || "kill -TERM $(< #{pid_file})"
      end

      def user(*args)
        @user = args.first if args.length > 0
        @user
      end

      def script
        file("service", name: name, start_cmd: start, pid_file: pid_file, working_dir: working_dir, reload_cmd: reload, stop_cmd: stop, user: user)
      end

      module DSL

        def service(name, &block)
          service = Capistrano::Cluster::Service.new(name, &block)
          upload_as :root, service.script, "/etc/init.d/#{name}"
          sudo :chmod, "0777", "/etc/init.d/#{name}"
          sudo "update-rc.d", name, :defaults
        end

      end

    end

  end

end



include Capistrano::Cluster::Service::DSL


