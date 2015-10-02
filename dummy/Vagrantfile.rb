Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end

  1.upto(3).each do |i|
    config.vm.define "box-#{i}" do |box|
      box.vm.hostname = "box-#{i}"
      box.vm.network "private_network", ip: "192.168.50.1#{i}"
    end
  end

  config.vm.provision :shell, inline: <<-SH
  FILE="/root/.ssh/authorized_keys"
  mkdir -p $(dirname "${FILE}")
  grep "verestiuc.vlad@gmail.com" "${FILE}" || echo "ssh-dss AAAAB3NzaC1kc3MAAACBAMLKdDOr2nexZgTV0S5ZFcLfJ/wc1BdZbo2rFq+iohacaON2enQFAR+ldfQVwWzaVAhAPLc4xqOap/ljkNQDqboz+TXLuqFvVv4pNg98AZ5puIaCMjKTc1SwUOsGBBIPE3UIK4hemZc6qT7R++pboBBs9harZvXCaMn70ddT2il7AAAAFQD2ns7a9C7G6FIJ4x5yqlirDilvvQAAAIEAgIOmRX/zzPnQic+cCZaMcMAcMGEFt20xs8/DQ26ZhU65RESlCNOThMyzb8YcVER1f+9jdCnKgA5ZXRsnee+oD4A3Fsf5ab9lb3uQBhkUFyyunAkVA4QmU/XAhv2PHbpQC/FdIu0Z4EtupYIMMg5Gfbp61oRHbjA3qpASW7lxSEkAAACBAIJ1urC06ijX2k5lOQtQAPTkmIf6BpViUSeZjX8+beY24F9p5ZTdeovx+x/K9Im/XuFN2MkcH6skJ4K8iR1ALPYEyhRC3BtDAx1bNB5CupqL5053rsR68h/fqthN4ADLnun70Fvkt0gznN30rLe+lD6PDqQjCpZ4z2p07eZ33Rw4 Verestiuc Vlad Ovidiu <verestiuc.vlad@gmail.com>" > "${FILE}"
  chmod 644 "${FILE}"
  SH
end
