-- Seed Initial Data for QRent System

-- 1. Insert Locations
INSERT INTO locations (location_id, name, latitude, longitude, radius_meters) VALUES
(1, 'CE Innovation Center (CE-402)', 13.7367170, 100.5231860, 50),
(2, 'Lab AV-101 (Audiovisual Lab)', 13.7371000, 100.5238000, 40),
(3, 'Media & Production Lab (Building 5)', 13.7362000, 100.5225000, 60)
ON CONFLICT (location_id) DO NOTHING;

-- 2. Insert Users
-- Password for all test users is: password123
-- Bcrypt hash: $2b$10$uDq3mE8MvJ5Nq7a6Ew4DxeFkR8wK7zH6rJk0V4E4K9y8l7v4DxeFk
INSERT INTO users (student_id, password_hash, first_name, last_name, fcm_token, role) VALUES
('65070214', '$2b$10$tZzCvy8x5Lw7H0dYc1cQzeY9iW7/m5v8G/k01jHk4tW4c.G7QYqK6', 'นภัสสร', 'ธนวัฒน์', 'mock_fcm_token_65070214', 'student'),
('68112269', '$2b$10$tZzCvy8x5Lw7H0dYc1cQzeY9iW7/m5v8G/k01jHk4tW4c.G7QYqK6', 'วีรภัทร', 'ใจดี', 'mock_fcm_token_68112269', 'student'),
('admin01', '$2b$10$tZzCvy8x5Lw7H0dYc1cQzeY9iW7/m5v8G/k01jHk4tW4c.G7QYqK6', 'อาจารย์ผู้ดูแล', 'ระบบแล็บ', 'mock_fcm_token_admin', 'admin')
ON CONFLICT (student_id) DO NOTHING;

-- 3. Insert Equipments
INSERT INTO equipments (equipment_id, name, description, image_url, status, location_id) VALUES
('EQ-00124', 'Lenovo ThinkPad X1 Carbon', 'Intel Core i7, 16GB RAM, 512GB SSD สำหรับงานคำนวณและเขียนโค้ด', 'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=400&q=80', 'borrowed', 1),
('EQ-00125', 'Epson 4K Projector Pro', 'โปรเจกเตอร์ 4K 4000 Lumens สำหรับนำเสนองานและแล็บมีเดีย', 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=400&q=80', 'borrowed', 2),
('EQ-00142', 'Sony FE 24-70mm GM II', 'เลนส์ซูม F2.8 G Master II สำหรับบันทึกภาพถ่ายและวิดีโอ', 'https://images.unsplash.com/photo-1617005082133-548c4dd27f35?w=400&q=80', 'available', 3),
('EQ-00088', 'DJI RS 3 Pro Gimbal', 'กิมบอลกันสั่น 3 แกนสำหรับกล้อง Cinema และ DSLR ขนาดใหญ่', 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=400&q=80', 'borrowed', 3),
('EQ-00099', 'iPad Pro 11" M2 + Apple Pencil', 'แท็บเล็ตสำหรับงานสเก็ตช์ภาพ ออกแบบ UI และทดสอบแอปพลิเคชัน', 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400&q=80', 'available', 1),
('EQ-00052', 'Rode Wireless GO II Mic', 'ชุดไมโครโฟนไร้สาย 2 ตัวส่ง 1 ตัวรับ พร้อมกล่องชาร์จ', 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=400&q=80', 'available', 3)
ON CONFLICT (equipment_id) DO NOTHING;

-- 4. Insert Transactions
INSERT INTO transactions (transaction_id, student_id, equipment_id, borrow_date, due_date, return_date, status) VALUES
('11111111-1111-1111-1111-111111111111', '65070214', 'EQ-00124', '2026-11-03 09:30:00', '2026-11-10 16:30:00', NULL, 'active'),
('22222222-2222-2222-2222-222222222222', '65070214', 'EQ-00125', '2026-11-05 13:00:00', '2026-11-15 17:00:00', NULL, 'active'),
('33333333-3333-3333-3333-333333333333', '65070214', 'EQ-00099', '2026-10-25 10:00:00', '2026-11-02 16:00:00', '2026-11-02 15:45:00', 'returned'),
('44444444-4444-4444-4444-444444444444', '65070214', 'EQ-00052', '2026-10-20 11:30:00', '2026-10-28 17:00:00', '2026-10-28 16:30:00', 'returned'),
('55555555-5555-5555-5555-555555555555', '68112269', 'EQ-00088', '2026-11-06 14:00:00', '2026-11-13 16:30:00', NULL, 'active')
ON CONFLICT (transaction_id) DO NOTHING;

-- 5. Insert Sample Reports
INSERT INTO reports (report_id, student_id, equipment_id, category, note, image_url, report_date, status) VALUES
('66666666-6666-6666-6666-666666666666', '65070214', 'EQ-00124', 'ฮาร์ดแวร์ชำรุด / แตกหัก', 'ปุ่มคีย์บอร์ดแถวบนหลุด 1 ปุ่ม ใช้งานได้แต่กดติดยาก', 'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=400&q=80', '2026-11-08 14:20:00', 'pending')
ON CONFLICT (report_id) DO NOTHING;
