# 🚀 VPN Fortress: Bridge Edition

> **AmneziaWG Stealth Tunnel** • **Gost v3 HTTP Bridge** • **3x‑ui Integration**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%20|%2022.04%20|%2024.04-orange)](https://ubuntu.com)
[![Version](https://img.shields.io/badge/Version-8.0_Bridge-green)](https://github.com/fdoo24/3x-ui-autoinstall/releases)

<p align="center">
  <strong>VPN Fortress: Bridge Edition</strong> — это автоматизированный скрипт развертывания для 3x-ui, который внедряет обфусцированный туннель <strong>AmneziaWG</strong> через локальный HTTP-мост. Решение оптимизировано для обхода глубокой инспекции пакетов (DPI) и обеспечения стабильной работы в условиях жестких региональных блокировок.
</p>

## ✨ Основные особенности

| Функция | Описание |
|---------|-------------|
| 🛡️ **AmneziaWG Anti-DPI** | Использование модифицированного WireGuard с параметрами обфускации (Jc/Jmin/Jmax) для защиты от блокировок по протоколу. |
| 🌉 **Gost v3 Bridge** | Локальный HTTP-мост на `127.0.0.1:18081`, который позволяет обходить ограничения панели 3x-ui по управлению интерфейсами. |
| 🔒 **Systemd Persistence** | Автоматический запуск интерфейса `awg0` и моста Gost в виде системных сервисов сразу после загрузки сервера. |
| 🛠️ **No-Patch Integration** | Добавление исходящих соединений (Outbounds) в 3x-ui как обычных прокси-серверов без вмешательства в ядро панели. |
| 🌐 **Cloudflare WARP** | Маскировка реального IP-адреса VPS за адресами Cloudflare для повышения анонимности и обхода гео-ограничений. |

## ⚙️ Предварительные требования
1. Чистый сервер на базе **Ubuntu** (20.04, 22.04 или 24.04).
2. Установленная панель **3x-ui** (рекомендуется версия от MHSanaei).
3. Доступ уровня `root` к серверу.

## ⚡ Быстрый старт (Установка в 1 клик)

Для автоматической настройки туннеля и моста выполните команду:

```bash
wget -qO setup_bridge.sh https://raw.githubusercontent.com/fdoo24/3x-ui-autoinstall/main/setup_bridge.sh && bash setup_bridge.sh
```

## 🔧 Настройка Outbound в 3x-ui

После завершения установки вы можете вручную добавить выход через WARP:

1. **Add Outbound**:
   - **Protocol**: `http`
   - **Tag**: `WARP-BRIDGE`
   - **Address**: `127.0.0.1`
   - **Port**: `18081`
2. **Routing Rule**:
   - Направьте трафик нужных входящих соединений на `Outbound Tag: WARP-BRIDGE`.

## 🤝 Благодарности

Проект использует разработки:
- **[AmneziaWG](https://github.com/amnezia-vpn/amneziawg-linux_kernel_module)** — за протокол с защитой от DPI.
- **[Gost](https://github.com/go-gost/gost)** — за универсальный сетевой мост.
- **[3x-ui](https://github.com/MHSanaei/3x-ui)** — за удобную панель управления.

---
*VPN Fortress: Bridge Edition — создано для обеспечения свободы интернета.*
