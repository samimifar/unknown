#!/bin/bash

read -p "Enter your Telegram bot token: " bot_token
read -p "Enter your Telegram chat ID: " chat_id
read -p "Enter your panel name: " panel_name
server_ip=$(curl -s http://whatismyip.akamai.com/)
mkdir -p /opt/samimifar
backup_script="/opt/samimifar/backup.sh"
cat <<EOF > $backup_script
#!/bin/bash

bot_token="$bot_token"
chat_id="$chat_id"
panel_name="$panel_name"
server_ip="$server_ip"
directory=\$(find ~/ -type d -name "wgdashboard" 2>/dev/null)
if [ -z "\$directory" ]; then
    echo "wgdashboard directory not found."
    exit 1
else
    echo "wgdashboard directory found at: \$directory"
fi
temp_dir=\$(mktemp -d)
wg_dashboard_ini="\$directory/src/wg-dashboard.ini"
if [ -f "\$wg_dashboard_ini" ]; then
    cp "\$wg_dashboard_ini" "\$temp_dir/"
else
    echo "File \$wg_dashboard_ini not found."
    exit 1
fi
conf_files=\$(find /etc/wireguard/ -type f -name "*.conf")
if [ -z "\$conf_files" ]; then
    echo "No .conf files found in /etc/wireguard/."
    exit 1
else
    cp \$conf_files "\$temp_dir/"
fi
db_path="\$directory/src/db/wgdashboard.db"
backup_db_path="\$directory/src/db/backup_wgdashboard.db"
if [ -f "\$db_path" ]; then
    sqlite3 "\$db_path" ".dump venusdb" > "\$temp_dir/dump.sql"
    sqlite3 "\$backup_db_path" < "\$temp_dir/dump.sql"
    cp "\$backup_db_path" "\$temp_dir/"
else
    echo "Database file \$db_path not found."
    exit 1
fi
zip_file="\${panel_name}.zip"
zip -r "\$zip_file" "\$temp_dir"
rm -rf "\$temp_dir"
caption="Panel: \$panel_name\nIP: \$server_ip"
curl -s -X POST https://api.telegram.org/bot\$bot_token/sendDocument \
    -F chat_id=\$chat_id \
    -F document=@\$zip_file \
    -F caption="Panel: \$panel_name\nIP: \$server_ip" 2>/dev/null
rm "\$zip_file"
EOF
chmod +x $backup_script
(crontab -l 2>/dev/null; echo "0 * * * * /bin/bash $(pwd)/$backup_script") | crontab -
echo "Installer completed. The backup script has been created and scheduled to run every hour."
