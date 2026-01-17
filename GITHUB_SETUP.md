# 🚀 วิธีอัพโหลดขึ้น GitHub

## ขั้นตอนที่ 1: สร้าง Repository บน GitHub

1. ไปที่ https://github.com/new
2. ตั้งชื่อ Repository: `linsec`
3. เลือก **Public** (เพื่อใช้ raw URL)
4. **ไม่ต้อง** เลือก "Add README.md" (เรามีอยู่แล้ว)
5. กด **Create repository**

---

## ขั้นตอนที่ 2: เชื่อมต่อกับ GitHub

หลังจากสร้าง Repository แล้ว รันคำสั่งนี้ใน Terminal:

```powershell
# เปลี่ยน USERNAME เป็นชื่อ GitHub ของคุณ
git remote add origin https://github.com/USERNAME/linsec.git
git push -u origin main
```

---

## ขั้นตอนที่ 3: ทดสอบใช้งาน

หลังจาก Push แล้ว คุณสามารถใช้คำสั่งนี้บนเซิร์ฟเวอร์ Linux:

```bash
TELEGRAM_TOKEN="your_token" \
TELEGRAM_CHAT_ID="your_chat_id" \
curl -fsSL https://raw.githubusercontent.com/USERNAME/linsec/main/setup.sh | sudo -E bash
```

**แทนที่:**
- `USERNAME` = ชื่อ GitHub ของคุณ
- `your_token` = Telegram Bot Token
- `your_chat_id` = Telegram Chat ID

---

## ✅ เสร็จแล้ว!

Repository พร้อมใช้งาน ไฟล์ทั้งหมดอยู่ที่:
- https://github.com/USERNAME/linsec

สคริปต์อยู่ที่:
- https://raw.githubusercontent.com/USERNAME/linsec/main/setup.sh

---

## 📝 หมายเหตุ

- ✅ ไฟล์ทั้งหมดถูกสร้างแล้วใน `c:\Users\markt\Desktop\linsec`
- ✅ Git repository ถูก initialize แล้ว
- ✅ ไฟล์ทั้งหมดถูก commit แล้ว (branch: main)
- ⏳ รอเพียงแค่ Push ขึ้น GitHub

---

## 🔐 ความปลอดภัย

- ❌ **ไม่มี** Telegram Token ใน Repository
- ✅ มี `.gitignore` ป้องกันไฟล์ sensitive
- ✅ Token รับจาก Environment Variable เท่านั้น
