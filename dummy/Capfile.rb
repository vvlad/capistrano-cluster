module CapFile #:nodoc:
end

require "capistrano/cluster"

set :stage, :development
set :user, :deploy

set :format, :pretty
set :log_level, :debug
set :pty, true

set :ssh_options,
  forward_agent: true,
  user: "deploy",
  paranoid: true

server "192.168.50.11", roles: %w[proxy], no_release: true, user: "deploy"
server "192.168.50.12", roles: %w[proxy], no_release: true, user: "deploy"
server "192.168.50.13", roles: %w[app web], no_release: true, user: "deploy"

set :deploy_keys, [
  "ssh-dss AAAAB3NzaC1kc3MAAACBAMLKdDOr2nexZgTV0S5ZFcLfJ/wc1BdZbo2rFq+iohacaON2enQFAR+ldfQVwWzaVAhAPLc4xqOap/ljkNQDqboz+TXLuqFvVv4pNg98AZ5puIaCMjKTc1SwUOsGBBIPE3UIK4hemZc6qT7R++pboBBs9harZvXCaMn70ddT2il7AAAAFQD2ns7a9C7G6FIJ4x5yqlirDilvvQAAAIEAgIOmRX/zzPnQic+cCZaMcMAcMGEFt20xs8/DQ26ZhU65RESlCNOThMyzb8YcVER1f+9jdCnKgA5ZXRsnee+oD4A3Fsf5ab9lb3uQBhkUFyyunAkVA4QmU/XAhv2PHbpQC/FdIu0Z4EtupYIMMg5Gfbp61oRHbjA3qpASW7lxSEkAAACBAIJ1urC06ijX2k5lOQtQAPTkmIf6BpViUSeZjX8+beY24F9p5ZTdeovx+x/K9Im/XuFN2MkcH6skJ4K8iR1ALPYEyhRC3BtDAx1bNB5CupqL5053rsR68h/fqthN4ADLnun70Fvkt0gznN30rLe+lD6PDqQjCpZ4z2p07eZ33Rw4"
]
