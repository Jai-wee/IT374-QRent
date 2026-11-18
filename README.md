# IT374-QRent - Smart Campus Equipment Borrow & Return System

ระบบยืม-คืนอุปกรณ์ด้วย QR Code สำหรับนักศึกษาและอาจารย์ (โปรเจกต์วิชา IT374 - Mobile Application Development)

---

## 📱 ภาพรวมระบบ (System Overview)
QRent พัฒนาขึ้นเพื่อแก้ปัญหาการยืม-คืนอุปกรณ์ในมหาวิทยาลัย เช่น แล็ปท็อป กล้อง เลนส์ และอุปกรณ์ฮาร์ดแวร์ โดยผู้ใช้สามารถ:
1. **สแกน QR Code** ที่ติดอยู่บนตัวเครื่องเพื่อตรวจสอบข้อมูล สถานะ และกดทำรายการยืม-คืนได้ทันที
2. **ระบบ Geofencing & Map** ตรวจสอบพิกัด GPS ผู้ใช้ว่าอยู่ในรัศมีบริการของห้องแล็บ (เช่น CE-402 รัศมี 50 เมตร) ก่อนอนุญาตให้กดยืมหรือคืน เพื่อป้องกันการสแกนจากภาพถ่ายนอกสถานที่
3. **ระบบแจ้งซ่อมและรายงานความเสียหาย** ถ่ายภาพความเสียหาย พร้อมระบุหมวดหมู่ปัญหาและรายละเอียดส่งให้ผู้ดูแลระบบ
4. **Offline & Local Caching** แคชรายการอุปกรณ์ที่กำลังยืมไว้บนเครื่อง ทำให้เปิดดูรายการของที่ถืออยู่ได้แม้ไม่มีอินเทอร์เน็ต
5. **ระบบยืนยันตัวตน JWT** และเตรียมพร้อมสำหรับการแจ้งเตือนผ่าน **Firebase Cloud Messaging (FCM)**

---

## 🛠️ เทคโนโลยีที่ใช้ (Tech Stack)
- **Mobile Frontend:** [Flutter](https://flutter.dev) (Dart) - รองรับ Android, iOS, Web
- **Backend API:** [Node.js](https://nodejs.org) (Express Framework)
- **Database:** [PostgreSQL](https://www.postgresql.org) (Normalized 5 Tables)
- **Authentication:** JSON Web Token (JWT) + bcrypt
- **Containerization:** Docker & Docker Compose

---

## 📁 โครงสร้างโปรเจกต์ (Project Structure)
```
IT374_Project/
├── docker-compose.yml        # ตัวสั่งรัน PostgreSQL + Backend API ด้วย Docker
├── qrent-backend/            # ระบบเซิร์ฟเวอร์ RESTful API (Express + pg)
│   ├── server.js
│   ├── config/db.js
│   ├── database/             # schema.sql, seed.sql, initDb.js
│   ├── controllers/
│   ├── routes/
│   └── middlewares/
└── qrent_mobile/             # แอปพลิเคชันมือถือ (Flutter)
    ├── lib/
    │   ├── main.dart
    │   ├── config/           # Theme (#15609D) และ API Config
    │   ├── models/           # User, Equipment, Transaction, Location
    │   ├── services/         # API Service (พร้อม Offline Mode) และ Storage Service
    │   └── screens/          # Login, Home, Scanner, Location, Report
    └── pubspec.yaml
```

---

## 💻 ขั้นตอนการรันครั้งแรกบนเครื่องใหม่ (Quick Setup สำหรับย้ายเครื่อง / พรีเซนต์)

### โปรแกรมที่ต้องติดตั้งบนเครื่องใหม่
1. **Node.js** (แนะนำ v18 ขึ้นไป)
2. **PostgreSQL** (แนะนำติดตั้งพร้อม pgAdmin 4)
3. **Flutter SDK** และเบราว์เซอร์ **Google Chrome**

### ขั้นตอนการติดตั้งและรันใช้งาน (เรียงตามลำดับ)

1. **ดึงโปรเจกต์ลงเครื่องใหม่:**
   ```bash
   git clone https://github.com/Jai-wee/IT374-QRent.git
   cd IT374-QRent
   ```

2. **ตั้งค่ารหัสผ่าน Database ในไฟล์ `qrent-backend/.env`:**
   * เปิดไฟล์ `qrent-backend/.env` แล้วแก้ไขค่า `DB_PASSWORD` ให้ตรงกับรหัสผ่าน PostgreSQL ที่ตั้งไว้บนเครื่องใหม่:
     ```env
     DB_PASSWORD=รหัสผ่าน_PostgreSQL_ของเครื่องใหม่
     ```

3. **สร้างฐานข้อมูลเปล่าชื่อ `qrent_db`:**
   * **วิธีที่ 1 (pgAdmin 4):** เปิด pgAdmin 4 → คลิกขวาที่ **Databases** → **Create** → **Database...** → ตั้งชื่อว่า **`qrent_db`** → กด Save
   * **วิธีที่ 2 (Command Line):**
     ```bash
     psql -U postgres -h localhost -p 5432 -c "CREATE DATABASE qrent_db;"
     ```

4. **รันฝั่ง Backend API (เปิด Terminal หน้าต่างที่ 1):**
   ```bash
   cd qrent-backend
   npm install
   npm run init-db
   npm start
   ```
   > `npm run init-db` จะสร้างตารางฐานข้อมูลทั้งหมดและใส่ข้อมูลตัวอย่าง (Seed Data) เข้าไปใน `qrent_db` อัตโนมัติ

5. **รันฝั่ง Frontend บน Chrome (เปิด Terminal หน้าต่างที่ 2):**
   ```bash
   cd qrent_mobile
   flutter pub get
   flutter run -d chrome
   ```
   * **วิธีปรับหน้าจอ Chrome ให้แสดงผลขนาดมือถือสำหรับพรีเซนต์:**
     1. กด **`F12`** (หรือ `Ctrl + Shift + I`) เพื่อเปิด Developer Tools
     2. กด **`Ctrl + Shift + M`** (Toggle Device Toolbar) แล้วเลือกรุ่นมือถือ เช่น **iPhone 14 Pro** หรือขนาด **390 × 844**
     3. กด **`F5`** รีเฟรชหน้าเว็บ 1 ครั้ง เพื่อให้ Flutter ปรับ Layout เป็นโหมดมือถือ

---

## 🚀 วิธีการติดตั้งและรันงาน (Getting Started)

### 1. รันฝั่ง Mobile App (Flutter)
```bash
cd qrent_mobile
flutter pub get
flutter run
```
*หรือเปิดบนเบราว์เซอร์:*
```bash
flutter run -d chrome
```

### 2. รันฝั่ง Backend & Database ด้วย Docker
```bash
docker compose up -d
```

### 3. หรือรัน Backend แบบ Local (Node.js)
```bash
cd qrent-backend
npm install
npm run init-db
npm run dev
```

---

## 👥 บัญชีสำหรับทดสอบ (Test Accounts)
- **นักศึกษา:** รหัส `65070214` / รหัสผ่าน: `password123`
- **ผู้ดูแลระบบ (Admin):** รหัส `admin01` / รหัสผ่าน: `password123`
