sudo apt install unzip
sudoi mkdir -p /var/lib/marzban/xray-core
cd /var/lib/marzban/xray-core
wget https://github.com/XTLS/Xray-core/releases/download/v1.8.8/Xray-linux-64.zip
unzip Xray-linux-64.zip
rm Xray-linux-64.zip
sudo ufw disable
sudo curl -fsSL https://get.docker.com | sh
cd
git clone https://github.com/Gozargah/Marzban-node
cd Marzban-node
sudo mkdir /var/lib/marzban-node
sudo nano /var/lib/marzban-node/ssl_client_cert.pem
sudo nano docker-compose.yml
sudo docker compose up -d
