# Capistrano::Cluster

Setup tasks and role additions for capistrano

## Installation

Add this line to your application's Gemfile:

    gem 'capistrano-cluster'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-cluster

## Usage

```ruby
  deploy_path = Pathname(Dir.pwd).join "deploy"

  set :deploy_config_path,  deploy_path.join("config.rb")
  set :stage_config_path,   deploy_path.join("environments")


  require 'capistrano/cluster'


## Contributing

1. Fork it ( http://github.com/<my-github-username>/capistrano-environment/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
