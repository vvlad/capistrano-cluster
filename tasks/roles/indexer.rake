solr_version = fetch(:solr_version, "4.9.0")

set :solr_version, solr_version
set :solr_url, fetch(:solr_url, "http://www.eu.apache.org/dist/lucene/solr/#{solr_version}/solr-#{solr_version}.tgz")
set :solr_checksum, 'ae47a89f35b5e2a6a4e55732cccc64fb10ed9779'
set :solr_data, "/var/lib/solr"
set :solr_dist, "/opt/solr"
set :solr_user, "solr"


namespace :setup do

  desc "Boostraps solr nodes"
  task :indexer do

    on roles(:indexer) do

      solr_dist = fetch(:solr_dist)
      solr_data = fetch(:solr_data)


      if test "[ ! -e '/etc/init.d/solr' ]"


        install "openjdk-7-jre-headless"

        sudo :mkdir, "-p", solr_dist
        sudo :chown, "-R", "#{fetch(:user)}:#{fetch(:user)}", solr_dist
        archive = "/tmp/solr-#{fetch(:solr_version)}.tgz"
        remote_file fetch(:solr_url), archive, checksum: fetch(:solr_checksum)

        execute :tar, "-xzC", solr_dist, "-f", archive, "--strip-components", "1"

        sudo :mkdir, "-p", solr_data
        sudo :chown, "-R", "#{fetch(:user)}:#{fetch(:user)}", solr_data

        upload! file("solr/solr.xml"), "#{solr_data}/solr.xml"
        service "solr" do
          pid_file "/tmp/solr.pid"
          user fetch(:user)
          working_dir "#{solr_dist}/example"
          start "/usr/bin/java -server -Dsolr.solr.home='#{solr_data}' -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true -DSTOP.PORT=8079 -DSTOP.KEY=stopkey -Djetty.port=8983 -jar start.jar"
          stop "pidof java && kill -TERM $(pidof java)"
        end

      end

      sudo "nohup /etc/init.d/solr restart"

    end


  end

end

after "setup:system", "setup:indexer"

namespace :deploy do
  namespace :application do

    task :indexer do

      config = { application: fetch(:application), name: fetch(:solr_core) }

      on roles(:indexer) do
        solr_data = fetch(:solr_data)
        if test "[ ! -d '#{solr_data}/#{config[:name]}/data' ]"
          execute :mkdir, "-p", "#{solr_data}/#{config[:name]}/data"

          fetch(:solr_core_files).each do |core_file|
            execute :mkdir, "-p", File.dirname("#{solr_data}/#{config[:name]}/#{core_file}")
            upload! file("solr/#{core_file}"), "#{solr_data}/#{config[:name]}/#{core_file}"
          end
          execute :touch, "#{solr_data}/#{config[:name]}/core.properties"
        end

      end if config[:name]

    end

  end
end


set :solr_core_files , %w[
  conf/mapping-FoldToASCII.txt
  conf/schema.xml
  conf/solrconfig.xml
  conf/stopwords.txt
  conf/lang/contractions_ca.txt
  conf/lang/contractions_fr.txt
  conf/lang/contractions_ga.txt
  conf/lang/contractions_it.txt
  conf/lang/hyphenations_ga.txt
  conf/lang/stemdict_nl.txt
  conf/lang/stoptags_ja.txt
  conf/lang/stopwords_ar.txt
  conf/lang/stopwords_bg.txt
  conf/lang/stopwords_ca.txt
  conf/lang/stopwords_cz.txt
  conf/lang/stopwords_da.txt
  conf/lang/stopwords_de.txt
  conf/lang/stopwords_el.txt
  conf/lang/stopwords_en.txt
  conf/lang/stopwords_es.txt
  conf/lang/stopwords_eu.txt
  conf/lang/stopwords_fa.txt
  conf/lang/stopwords_fi.txt
  conf/lang/stopwords_fr.txt
  conf/lang/stopwords_ga.txt
  conf/lang/stopwords_gl.txt
  conf/lang/stopwords_hi.txt
  conf/lang/stopwords_hu.txt
  conf/lang/stopwords_hy.txt
  conf/lang/stopwords_id.txt
  conf/lang/stopwords_it.txt
  conf/lang/stopwords_ja.txt
  conf/lang/stopwords_lv.txt
  conf/lang/stopwords_nl.txt
  conf/lang/stopwords_no.txt
  conf/lang/stopwords_pt.txt
  conf/lang/stopwords_ro.txt
  conf/lang/stopwords_ru.txt
  conf/lang/stopwords_sv.txt
  conf/lang/stopwords_th.txt
  conf/lang/stopwords_tr.txt
  conf/lang/userdict_ja.txt
]



