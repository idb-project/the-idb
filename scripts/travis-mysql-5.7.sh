export DEBIAN_FRONTEND=noninteractive
echo mysql-apt-config mysql-apt-config/select-server select mysql-5.7 | sudo debconf-set-selections
wget http://dev.mysql.com/get/mysql-apt-config_0.8.1-1_all.deb
sudo dpkg --install mysql-apt-config_0.8.1-1_all.deb
sudo apt-get update -q
sudo apt-get install -qq --allow-unauthenticated --force-yes -o Dpkg::Options::=--force-confnew -o Dpkg::Options::=--force-bad-verify mysql-server
sudo mysql_upgrade
