### OpenVPN
```sh
bash <(curl -fsS https://packages.openvpn.net/as/install.sh) --yes
```

Включите Kill Switch и/или Always VPN. Если туннель отвалится, трафик должен блокироваться, а не тихо уходить напрямую
dest/SNI: должен указывать на реальный, доступный сайт, желательно живущий рядом с твоим сервером по IP-пространству.
Выбор транспорта: VLESS с транспортом XHTTP / или gRPC для Hysteria2
