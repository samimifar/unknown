#!/bin/bash

# Prompt the user for initial information
read -p "Enter your Telegram bot token: " bot_token
read -p "Enter your Telegram chat ID: " chat_id
read -p "Enter your panel name: " panel_name

# Get the server's public IP address
server_ip=$(curl -s http://whatismyip.akamai.com/)

# Create the backup script with static values
backup_script="backup_script.sh"
cat <<EOF > $backup_script
#!/bin/bash

# Static values
bot_token="$bot_token"
chat_id="$chat_id"
panel_name="$panel_name"
server_ip="$server_ip"

# Find the wgdashboard directory starting from the home directory
directory=\$(find ~/ -type d -name "wgdashboard" 2>/dev/null)

# Check if the directory was found
if [ -z "\$directory" ]; then
    echo "wgdashboard directory not found."
    exit 1
else
    echo "wgdashboard directory found at: \$directory"
fi

# Create a temporary directory to collect files
temp_dir=\$(mktemp -d)

# Copy the wg-dashboard.ini file
wg_dashboard_ini="\$directory/src/wg-dashboard.ini"
if [ -f "\$wg_dashboard_ini" ]; then
    cp "\$wg_dashboard_ini" "\$temp_dir/"
else
    echo "File \$wg_dashboard_ini not found."
    exit 1
fi

# Copy the .conf files from /etc/wireguard/
conf_files=\$(find /etc/wireguard/ -type f -name "*.conf")
if [ -z "\$conf_files" ]; then
    echo "No .conf files found in /etc/wireguard/."
    exit 1
else
    cp \$conf_files "\$temp_dir/"
fi

# Dump and rewrite the SQLite database
db_path="\$directory/db/wgdashboard.db"
backup_db_path="\$directory/db/backup_wgdashboard.db"
if [ -f "\$db_path" ]; then
    sqlite3 "\$db_path" ".dump venusdb" > "\$temp_dir/dump.sql"
    sqlite3 "\$backup_db_path" < "\$temp_dir/dump.sql"
    cp "\$backup_db_path" "\$temp_dir/"
else
    echo "Database file \$db_path not found."
    exit 1
fi

# Compress the collected files into a zip archive named after the panel name
zip_file="\${panel_name}.zip"
zip -r "\$zip_file" "\$temp_dir"

# Clean up the temporary directory
rm -rf "\$temp_dir"

# Send the zip file to Telegram
curl -s -X POST https://api.telegram.org/bot\$bot_token/sendDocument \
    -F chat_id=\$chat_id \
    -F document=@\$zip_file \
    -F caption="Panel: \$panel_name\nIP: \$server_ip"

echo "Backup completed. Archive sent to Telegram: \$zip_file"
EOF

# Make the backup script executable
chmod +x $backup_script

# Add the backup script to the crontab to run every hour
(crontab -l 2>/dev/null; echo "0 * * * * /bin/bash $(pwd)/$backup_script") | crontab -

echo "Installer completed. The backup script has been created and scheduled to run every hour."
