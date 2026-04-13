#!/bin/bash

# --- CONFIGURATION (Замени на свои или сделай ввод через read) ---
PRIV_KEY="6kY4qlox1iR2qf2IrlwF4gt1dYexkAlCaJbG/IrO5fE="
PUB_KEY="bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo="
ENDPOINT="162.159.192.1:4500"
ADDR_V4="172.16.0.2/32"
ADDR_V6="2606:4700:110:8254:2b16:dcb:5541:7a3a/128"
BRIDGE_PORT=18081

echo "🛡 Начинаем развертывание Bridge-Fortress..."

# 1. Установка AmneziaWG
echo "📦 Установка зависимостей..."
apt update && apt install -y amneziawg python3 sqlite3 wget tar

# 2. Настройка конфигурации ядра
mkdir -p /etc/amnezia
cat << EOF > /etc/amnezia/awg0_kernel.conf
[Interface]
PrivateKey = $PRIV_KEY
Jc = 4; Jmin = 40; Jmax = 70; H1 = 1; H2 = 2; H3 = 3; H4 = 4
[Peer]
PublicKey = $PUB_KEY
Endpoint = $ENDPOINT
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF
chmod 600 /etc/amnezia/awg0_kernel.conf

# 3. Сервис AmneziaWG (Автозагрузка интерфейса)
cat << EOF > /etc/systemd/system/awg-warp.service
[Unit]
Description=AmneziaWG WARP Tunnel
After=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStartPre=-/usr/bin/ip link delete dev awg0
ExecStart=/usr/bin/ip link add dev awg0 type amneziawg
ExecStartPost=/usr/bin/awg setconf awg0 /etc/amnezia/awg0_kernel.conf
ExecStartPost=/usr/bin/ip address add $ADDR_V4 dev awg0
ExecStartPost=/usr/bin/ip -6 address add $ADDR_V6 dev awg0
ExecStartPost=/usr/bin/ip link set mtu 1280 up dev awg0
ExecStop=/usr/bin/ip link delete dev awg0

[Install]
WantedBy=multi-user.target
EOF

# 4. Установка Gost v3
if [ ! -f /usr/bin/gost ]; then
    echo "📦 Загрузка Gost v3..."
    wget -qO- https://github.com/go-gost/gost/releases/download/v3.0.0-rc10/gost_3.0.0-rc10_linux_amd64.tar.gz | tar -xvz
    mv gost /usr/bin/gost
    chmod +x /usr/bin/gost
fi

# 5. Сервис Gost (HTTP-мост через awg0)
cat << EOF > /etc/systemd/system/awg-bridge.service
[Unit]
Description=Gost AWG Bridge
After=awg-warp.service
Requires=awg-warp.service

[Service]
ExecStart=/usr/bin/gost -L "http://127.0.0.1:$BRIDGE_PORT?interface=awg0"
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# 6. Внедрение в базу 3X-UI (Routing + Outbound)
echo "💉 Интеграция с базой 3X-UI..."
DB_PATH="/etc/x-ui/x-ui.db"
if [ -f "$DB_PATH" ]; then
    systemctl stop x-ui
    python3 -c "
import sqlite3, json
try:
    conn = sqlite3.connect('$DB_PATH')
    # Ищем шаблон конфигурации в вашей версии панели
    res = conn.execute(\"SELECT value FROM settings WHERE key='xrayTemplateConfig'\").fetchone()
    if res:
        config = json.loads(res[0])
        # Добавляем Shadowsocks в правила WARP, если его нет
        for rule in config.get('routing', {}).get('rules', []):
            if rule.get('outboundTag') == 'WARP':
                tags = rule.get('inboundTag', [])
                if 'inbound-45550' not in tags:
                    tags.append('inbound-45550')
                    rule['inboundTag'] = tags
        conn.execute(\"UPDATE settings SET value=? WHERE key='xrayTemplateConfig'\", (json.dumps(config),))
        conn.commit()
        print('✅ Правила маршрутизации обновлены.')
    conn.close()
except Exception as e:
    print(f'⚠️ Ошибка БД: {e}')
"
fi

# 7. Запуск сервисов
systemctl daemon-reload
systemctl enable --now awg-warp.service awg-bridge.service
systemctl start x-ui

echo "-------------------------------------------------------"
echo "✅ Установка завершена!"
echo "📍 HTTP Proxy: 127.0.0.1:$BRIDGE_PORT"
echo "📍 Проверь IP: curl --proxy http://127.0.0.1:$BRIDGE_PORT https://ifconfig.me"
echo "-------------------------------------------------------"
