require 'nokogiri'
module Capistrano
  module Cluster
    module Files
      module DSL

        def remote_file(url, file, checksum: nil)
          file = File.expand_path(file)

          if test "[ -f '#{file}' ]"
            if checksum
              return if checksum == capture("sha256sum '#{file}' | awk '{ print $1}'")
              execute :rm, "-f", file
            else
              return
            end
          end
          execute :mkdir, "-p", File.dirname(file)
          execute :wget, "-q", "-o", "/dev/null" , "-O", file, url
        end

        def upload_as(user, file, remote_file, options={})
          group = options.fetch(:group, user)

          tmp_name = "/tmp/#{SecureRandom.uuid}"
          upload! file, tmp_name

          sudo :mv, tmp_name, remote_file

          unless test "[[ -d #{File.dirname(remote_file)} ]]"
            sudo :mkdir, "-p", File.dirname(remote_file)
            sudo :chown, "-R", "#{user}:#{group}", File.dirname(remote_file)

          end

          sudo :chown, "#{user}:#{group}", remote_file
          sudo :chmod, options.fetch(:mode, 644), remote_file

        end

        def item(identifier)
          consume = false
          xml = File.read(caller.first.match(/(?<file>.*):(?<line_number>\d+):/)["file"]).lines.select { |l| consume ||= l =~/^__END__$/ || consume}[1..-1].join()
          doc = Nokogiri::HTML(xml)
          doc.css("##{identifier}").inner_html
        end

      end
    end
  end
end



include Capistrano::Cluster::Files::DSL


