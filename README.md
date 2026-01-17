# LinSec - Linux Security Setup

**LinSec** = **Lin**ux **Sec**urity Auto-Configuration Script

ระบบตั้งค่าความปลอดภัย Linux แบบอัตโนมัติพร้อมแจ้งเตือนผ่าน Telegram

## คุณสมบัติ

- สร้างผู้ใช้ใหม่ (กำหนดเองหรือสุ่ม)
- เปลี่ยน SSH Port (กำหนดเองหรือสุ่ม 20000-40000)
- ตั้งค่า Firewall (UFW)
- เปิดใช้ Fail2Ban
- แจ้งเตือน SSH Login ผ่าน Telegram
- แจ้งเตือนเมื่อเซิร์ฟเวอร์รีสตาร์ท

## การใช้งาน

### สิ่งที่ต้องมี

- Ubuntu/Debian Server (ติดตั้งใหม่)
- Telegram Bot Token (สร้างที่ [@BotFather](https://t.me/BotFather))
- Telegram Chat ID (หาได้ที่ [@userinfobot](https://t.me/userinfobot))

### คำสั่งติดตั้ง (แบบสุ่ม user/password/port)

```bash
export TELEGRAM_TOKEN="your_bot_token_here"
export TELEGRAM_CHAT_ID="your_chat_id_here"
curl -fsSL https://raw.githubusercontent.com/thanadon-dev/linsec/main/setup.sh | sudo -E bash
```

### คำสั่งติดตั้ง (กำหนดเอง)

```bash
export TELEGRAM_TOKEN="your_bot_token_here"
export TELEGRAM_CHAT_ID="your_chat_id_here"
export SSH_USER="myuser"
export SSH_PASSWORD="MySecurePass123"
export SSH_PORT="22222"
curl -fsSL https://raw.githubusercontent.com/thanadon-dev/linsec/main/setup.sh | sudo -E bash
```

### ตัวอย่างการใช้งานจริง

```bash
export TELEGRAM_TOKEN="7123456789:ABCdefGHIjklMNOpqrsTUVwxyz"
export TELEGRAM_CHAT_ID="123456789"
export SSH_USER="admin"
export SSH_PASSWORD="SuperSecret2024"
export SSH_PORT="33333"
curl -fsSL https://raw.githubusercontent.com/thanadon-dev/linsec/main/setup.sh | sudo -E bash
```

## ตัวแปร Environment

| ตัวแปร | บังคับ | ค่าเริ่มต้น | คำอธิบาย |
|--------|--------|-------------|----------|
| `TELEGRAM_TOKEN` | ✅ | - | Bot Token จาก BotFather |
| `TELEGRAM_CHAT_ID` | ✅ | - | Chat ID สำหรับรับแจ้งเตือน |
| `SSH_USER` | ❌ | สุ่ม (u + 6 ตัว) | ชื่อผู้ใช้ SSH |
| `SSH_PASSWORD` | ❌ | สุ่ม 16 ตัว | รหัสผ่าน SSH |
| `SSH_PORT` | ❌ | สุ่ม 20000-40000 | พอร์ต SSH |

## ความปลอดภัย

| คุณสมบัติ | รายละเอียด |
|-----------|-------------|
| SSH Hardening | ปิด Root Login + เปลี่ยน Port |
| UFW Firewall | เปิดเฉพาะ SSH Port |
| Fail2Ban | แบน IP ที่พยายามเข้าผิด 5 ครั้ง |
| Telegram Alert | แจ้งเตือนทุกการเข้าระบบ |
| Timezone | Asia/Bangkok |
| Auto Update | เปิดใช้ unattended-upgrades |

## การแจ้งเตือน

- ✅ Setup Completed - ข้อมูลเข้าสู่ระบบ
- 🔐 SSH Login - ทุกครั้งที่มีคนเข้าระบบ
- 🚫 Fail2Ban Alert - เมื่อมี IP ถูกแบน
- 🔄 Server Reboot - เมื่อเซิร์ฟเวอร์รีสตาร์ท

## ข้อควรระวัง

- ⚠️ ห้ามใส่ Telegram Token ใน GitHub
- ⚠️ ใช้กับเซิร์ฟเวอร์ใหม่เท่านั้น
- ⚠️ บันทึกข้อมูลจาก Telegram ทันที

## ติดตั้งแบบ Manual

```bash
git clone https://github.com/thanadon-dev/linsec.git
cd linsec
export TELEGRAM_TOKEN="your_token"
export TELEGRAM_CHAT_ID="your_chat_id"
export SSH_USER="myuser"        # optional
export SSH_PASSWORD="mypass"    # optional
export SSH_PORT="22222"         # optional
sudo -E bash setup.sh
```

## License

MIT License

---

**Thanadon-dev**
