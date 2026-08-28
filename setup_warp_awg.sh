#!/bin/bash
set -e

echo "======================================================="
echo "🛡 AmneziaWG WARP + SOCKS5 Bridge Installer"
echo "======================================================="

# Запрос приватного ключа
read -rp "🔑 Введите ваш AmneziaWG/WARP PrivateKey: " PRIV_KEY

if [ -z "$PRIV_KEY" ]; then
    echo "❌ Ошибка: PrivateKey не может быть пустым!"
    exit 1
fi

# ==========================================
# ДЕФОЛТНЫЕ ПАРАМЕТРЫ CLOUDFLARE WARP
# ==========================================
PUB_KEY="bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo="
ENDPOINT="162.159.192.1:4500"
ADDR_V4="172.16.0.2/32"
ADDR_V6="2606:4700:110:8254:2b16:dcb:5541:7a3a/128"
BRIDGE_PORT=18081

echo "📦 Установка системных зависимостей и PPA AmneziaWG..."
apt update && apt install -y software-properties-common wget tar curl
add-apt-repository -y ppa:amnezia/ppa
apt update
apt install -y amneziawg-dkms amneziawg-tools linux-headers-$(uname -r)

# Загрузка модуля ядра
modprobe amneziawg || true

# Создание конфигурации интерфейса ядра
mkdir -p /etc/amnezia
cat << EOF > /etc/amnezia/awg0_kernel.conf
[Interface]
PrivateKey = $PRIV_KEY
Jc = 4
Jmin = 40
Jmax = 70
H1 = 1
H2 = 2
H3 = 3
H4 = 4

[Peer]
PublicKey = $PUB_KEY
Endpoint = $ENDPOINT
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF
chmod 600 /etc/amnezia/awg0_kernel.conf

# Создание Systemd-сервиса интерфейса AmneziaWG
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

# Установка Gost v3
if [ ! -f /usr/bin/gost ]; then
    echo "📦 Загрузка Gost v3..."
    wget -qO- https://github.com/go-gost/gost/releases/download/v3.0.0-rc10/gost_3.0.0-rc10_linux_amd64.tar.gz | tar -xvz -C /tmp/
    mv /tmp/gost /usr/bin/gost
    chmod +x /usr/bin/gost
fi

# Создание Systemd-сервиса Gost (SOCKS5 через awg0)
cat << EOF > /etc/systemd/system/awg-bridge.service
[Unit]
Description=Gost AWG SOCKS5 Bridge
After=awg-warp.service
Requires=awg-warp.service

[Service]
ExecStart=/usr/bin/gost -L "socks5://127.0.0.1:$BRIDGE_PORT?interface=awg0"
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Запуск и включение автозагрузки
systemctl daemon-reload
systemctl enable --now awg-warp.service awg-bridge.service

sleep 2

echo "-------------------------------------------------------"
echo "✅ Установка успешно завершена!"
echo "📍 Локальный SOCKS5 порт: 127.0.0.1:$BRIDGE_PORT"
echo "-------------------------------------------------------"

# Проверка рукопожатия и пинга
awg show

echo "Тест подключения к Telegram API:"
curl -s -o /dev/null -w "%{http_code}\n" -x socks5h://127.0.0.1:$BRIDGE_PORT https://api.telegram.org && echo "🚀 Туннель полностью работоспособен!" || echo "⚠️ Нет связи с Telegram API, проверьте правильность PrivateKey или Endpoint"
