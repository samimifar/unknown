sudo apt install unzip
sudo mkdir -p /var/lib/marzban/xray-core
cd /var/lib/marzban/xray-core
https://github.com/XTLS/Xray-core/releases/download/v1.8.24/Xray-linux-64.zip
unzip Xray-linux-64.zip
rm Xray-linux-64.zip
sudo mkdir -p /var/lib/marzban-node
sudo nano /var/lib/marzban-node/ssl_client_cert.pem --noread
sudo ufw disable
sudo curl -fsSL https://get.docker.com | sh
cd
git clone https://github.com/Gozargah/Marzban-node
cd Marzban-node
rm docker-compose.yml
wget https://raw.githubusercontent.com/samimifar/unknown/main/assets/docker-compose.yml
sudo docker compose up -d
