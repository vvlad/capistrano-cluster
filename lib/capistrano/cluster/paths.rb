module Capistrano
  module Cluster
    module Paths

      def home_path
        fetch(:home_path, "/home/#{fetch(:user)}")
      end

    end
  end
end



include Capistrano::Cluster::Paths



