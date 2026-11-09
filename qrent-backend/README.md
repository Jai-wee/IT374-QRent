# QRent Backend API (Node.js / Express + PostgreSQL)

ระบบ Backend RESTful API สำหรับโปรเจกต์ **QRent - ระบบยืม-คืนอุปกรณ์ด้วย QR Code** (วิชา IT374)

---

## 🛠️ Tech Stack
- **Runtime:** Node.js (Express Framework)
- **Database:** PostgreSQL
- **Authentication:** JSON Web Token (JWT) + bcrypt
- **Architecture:** MVC (Controllers, Routes, Middlewares, Config)

---

## 📁 โครงสร้างโปรเจกต์
```
qrent-backend/
├── .env                  # Environment Variables
├── .env.example          # ตัวอย่างค่าคอนฟิก
├── server.js             # เซิร์ฟเวอร์หลัก Express
├── config/
│   └── db.js             # การเชื่อมต่อ PostgreSQL Connection Pool
├── database/
│   ├── schema.sql        # คำสั่งสร้างตารางทั้ง 5 ตาราง (USERS, LOCATIONS, EQUIPMENTS, TRANSACTIONS, REPORTS)
│   ├── seed.sql          # ข้อมูลเริ่มต้นสำหรับทดสอบ (Users, Labs, Devices)
│   └── initDb.js         # สคริปต์รัน Schema & Seed อัตโนมัติ
├── middlewares/
│   └── authMiddleware.js # ตรวจสอบความถูกต้องของ JWT Token
├── controllers/          # Business Logic
│   ├── authController.js
│   ├── equipmentController.js
│   ├── transactionController.js
│   ├── locationController.js
│   └── reportController.js
└── routes/               # API Endpoints
    ├── authRoutes.js
    ├── equipmentRoutes.js
    ├── transactionRoutes.js
    ├── locationRoutes.js
    └── reportRoutes.js
```

---

## 🚀 วิธีการติดตั้งและรันเซิร์ฟเวอร์

### 1. ติดตั้ง Dependencies
```bash
cd qrent-backend
npm install
```

### 2. ตั้งค่า Database (.env)
แก้ไขไฟล์ `.env` ให้ตรงกับ PostgreSQL บนเครื่องของคุณ:
```env
PORT=5000
DB_USER=postgres
DB_PASSWORD=your_postgres_password
DB_HOST=localhost
DB_PORT=5432
DB_NAME=qrent_db
JWT_SECRET=supersecretkey_qrent_2026_jwt_token_secret
```

### 3. สร้างตารางและใส่ข้อมูลตัวอย่าง (Seed Data)
```bash
npm run init-db
```

### 4. รันเซิร์ฟเวอร์
```bash
# รันแบบ Development (Auto Reload ด้วย nodemon)
npm run dev

# หรือรันแบบ Production ปกติ
npm start
```

---

## 📡 สรุป API Endpoints

### 1. Authentication (`/api/auth`)
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| POST | `/api/auth/login` | เข้าสู่ระบบด้วย student_id และ password | No |
| POST | `/api/auth/register` | สมัครสมาชิกนักศึกษาใหม่ | No |
| PUT | `/api/auth/fcm-token` | อัปเดต FCM Token สำหรับ Push Notification | Yes (Bearer Token) |
| GET | `/api/auth/me` | ดึงข้อมูลโปรไฟล์ของตนเอง | Yes (Bearer Token) |

### 2. Equipments (`/api/equipments`)
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| GET | `/api/equipments` | ดึงรายการอุปกรณ์ทั้งหมด (ค้นหา/กรองสถานะได้) | No |
| GET | `/api/equipments/:id` | สแกนหรือค้นหาอุปกรณ์ตามรหัส QR Code (เช่น EQ-00124) | No |
| POST | `/api/equipments` | เพิ่มอุปกรณ์ใหม่เข้าระบบ | Yes (Admin) |

### 3. Transactions (`/api/transactions`)
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| POST | `/api/transactions/borrow` | ทำรายการยืมอุปกรณ์ (ตรวจสอบ Geofence รัศมีห้องแล็บ) | Yes (Bearer Token) |
| POST | `/api/transactions/return` | ทำรายการคืนอุปกรณ์ | Yes (Bearer Token) |
| GET | `/api/transactions/my-active` | รายการอุปกรณ์ที่กำลังยืมอยู่ ณ ปัจจุบัน | Yes (Bearer Token) |
| GET | `/api/transactions/my-history` | ประวัติการยืม-คืนอุปกรณ์ทั้งหมด | Yes (Bearer Token) |

### 4. Locations & Geofence (`/api/locations`)
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| GET | `/api/locations` | รายชื่อห้องแล็บและจุดบริการพร้อมพิกัด GPS | No |
| GET | `/api/locations/:id` | ข้อมูลห้องแล็บตามรหัส | No |
| POST | `/api/locations/verify` | ส่งพิกัดผู้ใช้ (lat, lon) เพื่อเช็คว่าอยู่ในรัศมี Geofence หรือไม่ | No |

### 5. Issue Reports (`/api/reports`)
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| POST | `/api/reports` | ส่งรายงานแจ้งอุปกรณ์ชำรุด/เปิดไม่ติด พร้อมรูปภาพและข้อความ | Yes (Bearer Token) |
| GET | `/api/reports` | ดึงรายการปัญหาที่เคยแจ้ง | Yes (Bearer Token) |
| PUT | `/api/reports/:id/resolve`| ปิดงาน/แก้ไขรายงานปัญหา | Yes (Admin) |

---

## 🔑 ข้อมูลผู้ใช้สำหรับทดสอบ (Seed Users)
- **นักศึกษา 1:** Student ID: `65070214` / Password: `password123` (มีอุปกรณ์ยืมค้างไว้ 2 รายการ)
- **นักศึกษา 2:** Student ID: `68112269` / Password: `password123`
- **อาจารย์ / ผู้ดูแล:** Student ID: `admin01` / Password: `password123`
