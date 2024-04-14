## BBR
- enable BBR on linux server
```
 bash <(curl -s 'https://raw.githubusercontent.com/samimifar/unknown/main/bbr.sh' --ipv4)
```
## Marzban-Node
- Installing Marzban-node (with xray-core v1.8.8 - stable version)
```
 bash <(curl -s 'https://raw.githubusercontent.com/samimifar/unknown/main/marzban_node.sh' --ipv4)
```
also add this line in 'Environment' section of `docker-compose.yaml` file!
```
XRAY_EXECUTABLE_PATH: "/var/lib/marzban/xray-core/xray"
```
and add this line in 'Volumes' section of `docker-compose.yaml` file!
```
/var/lib/marzban:/var/lib/marzban
```
