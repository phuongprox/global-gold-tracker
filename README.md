# 🏦 Tích Chỉ - Gold Tracker App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![Node.js](https://img.shields.io/badge/Node.js-18.x-green.svg)
![MySQL](https://img.shields.io/badge/MySQL-8.0-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

**Ứng dụng theo dõi giá vàng và quản lý tích lũy vàng thông minh**

[🌟 Tính năng](#-tính-năng) • [📱 Cài đặt](#-cài-đặt) • [🚀 Chạy ứng dụng](#-chạy-ứng-dụng) • [📁 Cấu trúc](#-cấu-trúc-dự-án) • [🤝 Đóng góp](#-đóng-góp)

</div>

---

## 📱 Giới thiệu

**Tích Chỉ** là ứng dụng di động giúp người dùng theo dõi giá vàng thế giới và trong nước theo thời gian thực, quản lý sổ vàng cá nhân (ghi lại lịch sử mua/bán vàng), xem tin tức về vàng, nhận cảnh báo giá, và tùy chỉnh giao diện theo sở thích.

---

## 🌟 Tính năng

### 💰 Quản lý giá vàng
| Tính năng | Mô tả |
|-----------|-------|
| **Giá vàng thế giới** | Xem giá XAU/USD real-time từ GoldAPI.io |
| **Giá vàng trong nước** | SJC, PNJ, DOJI, Bảo Tín Minh Châu |
| **Biểu đồ tương tác** | Hỗ trợ các mốc 1W, 1M, 3M, 6M, 1Y |
| **Chỉ báo kỹ thuật** | RSI, MA7, MA25, MA50 |
| **Live Ticker** | Giá vàng chạy ngang màn hình |

### 📒 Quản lý sổ vàng
| Tính năng | Mô tả |
|-----------|-------|
| **Thêm giao dịch** | Mua/bán vàng với số lượng, giá, ngày |
| **Lịch sử giao dịch** | Xem danh sách đã thực hiện |
| **Tính lãi/lỗ** | Tự động tính toán theo giá hiện tại |
| **Xóa giao dịch** | Xóa khi cần thiết |
| **Lưu database** | Dữ liệu lưu trên MySQL server |

### 📰 Tin tức vàng
| Tính năng | Mô tả |
|-----------|-------|
| **Nhiều nguồn tin** | VnEconomy, CafeF, Kitco, Bloomberg |
| **Lọc danh mục** | Tất cả / Giá vàng / Kinh tế / Thế giới |
| **Tìm kiếm** | Tìm kiếm tin tức theo từ khóa |
| **Xem chi tiết** | Đọc nội dung và mở link gốc |

### 🔔 Cảnh báo giá
| Tính năng | Mô tả |
|-----------|-------|
| **Tạo cảnh báo** | Đặt ngưỡng giá trên/dưới |
| **Bật/Tắt** | Kích hoạt hoặc tạm dừng |
| **Thông báo** | Nhận thông báo khi giá đạt ngưỡng |

### ⚙️ Cài đặt
| Tính năng | Mô tả |
|-----------|-------|
| **Chế độ tối** | Chuyển đổi giao diện sáng/tối |
| **Mã PIN** | Bảo vệ màn hình Sổ vàng |
| **Kích thước chữ** | Điều chỉnh font size |
| **Chia sẻ** | Giới thiệu ứng dụng |

---

## 🛠️ Công nghệ sử dụng

### Frontend (Flutter)
| Công nghệ | Vai trò |
|-----------|---------|
| **Flutter 3.x** | Framework UI |
| **Dart** | Ngôn ngữ lập trình |
| **Provider** | State management |
| **fl_chart** | Biểu đồ giá |
| **http** | Gọi API |
| **shared_preferences** | Lưu cài đặt |
| **marquee** | Live ticker |

### Backend (Node.js)
| Công nghệ | Vai trò |
|-----------|---------|
| **Node.js 18+** | Runtime |
| **Express** | Web framework |
| **MySQL2** | Database driver |
| **dotenv** | Quản lý biến môi trường |
| **CORS** | Xử lý cross-origin |

### Database
| Công nghệ | Vai trò |
|-----------|---------|
| **MySQL 8.0** | Database chính |
| **MariaDB 10.4** | (XAMPP) |

### API tích hợp
| API | Công dụng |
|-----|-----------|
| **GoldAPI.io** | Giá vàng thế giới |
| **RSS2JSON** | Chuyển đổi RSS feed |
| **ExchangeRate-API** | Tỷ giá USD/VND |

---

## 📥 Cài đặt

### Yêu cầu
- Flutter SDK (>= 3.0.0)
- Node.js (>= 18.x)
- MySQL / MariaDB (>= 10.4)
- Git

### 1. Clone dự án

```bash
git clone https://github.com/phuongprox/gold_app_tracker.git
cd gold_app_tracker
