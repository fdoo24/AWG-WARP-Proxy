#!/bin/bash
# Проверяем доступность через прокси
if ! curl --proxy http://127.0.0.1:18081 --connect-timeout 5 https://google.com > /dev/null 2>&1; then
    echo "$(date): Связь потеряна, перезапуск AWG..."
    systemctl restart awg-warp
    systemctl restart awg-bridge
fi
