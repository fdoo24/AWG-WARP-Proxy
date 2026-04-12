# 🚀 VPN Fortress: Bridge Edition

> **AmneziaWG Stealth Tunnel** • **Gost v3 HTTP Bridge** • **3x‑ui Integration**

<p align="center">
  <img src="https://img.shields.io/badge/Ubuntu-20.04%2B-orange?style=for-the-badge&logo=ubuntu" alt="Ubuntu">
  <img src="https://img.shields.io/badge/WireGuard-AmneziaWG-blue?style=for-the-badge&logo=wireguard" alt="AmneziaWG">
  <img src="https://img.shields.io/badge/Gost-v3-green?style=for-the-badge" alt="Gost v3">
  <img src="https://img.shields.io/badge/3x--ui-Panel-red?style=for-the-badge" alt="3x-ui">
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" alt="License">
</p>

<p align="center">
  <strong>VPN Fortress: Bridge Edition</strong> — это автоматизированный скрипт развертывания, который внедряет обфусцированный туннель <strong>AmneziaWG</strong> через локальный HTTP-мост.
</p>

## ✨ Основные особенности

| Функция | Описание |
|---------|-------------|
| 🛡️ **AmneziaWG Anti-DPI** | Использование модифицированного WireGuard с параметрами обфускации (Jc/Jmin/Jmax) для защиты от блокировок по протоколу. |
| 🌉 **Gost v3 Bridge** | Локальный HTTP-мост на `127.0.0.1:18081`, который позволяет обходить ограничения панели 3x-ui по управлению интерфейсами. |
| 🔒 **Systemd Persistence** | Автоматический запуск интерфейса `awg0` и моста Gost в виде системных сервисов сразу после загрузки сервера. |
| 🛠️ **No-Patch Integration** | Добавление исходящих соединений (Outbounds) в 3x-ui как обычных прокси-серверов без вмешательства в ядро панели. |

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
