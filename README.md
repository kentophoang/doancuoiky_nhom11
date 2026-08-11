# 📱 Đồ Án Cuối Kỳ - Nhóm 11 | Final Project - Group 11

*Scroll down for English version | Kéo xuống để xem bản tiếng Anh*

---

## 🇻🇳 Tiếng Việt

Chào mừng đến với kho lưu trữ mã nguồn Đồ án cuối kỳ của Nhóm 11! Đây là một ứng dụng di động được xây dựng bằng **Flutter**, tích hợp các tính năng giao tiếp và theo dõi cảm xúc cá nhân.

### ✨ Tính Năng Nổi Bật
*   **🔐 Xác Thực Người Dùng:** Đăng nhập và đăng ký tài khoản an toàn (sử dụng Firebase).
*   **💬 Trò Chuyện (Chat):** Gửi và nhận tin nhắn theo thời gian thực.
*   **😊 Theo Dõi Cảm Xúc (Mood Tracker):** Ghi chép và theo dõi trạng thái tâm lý, cảm xúc hàng ngày.
*   **🚀 Trải Nghiệm Mượt Mà:** Màn hình giới thiệu (Onboarding) thân thiện cho người dùng mới.
*   **⚙️ Cài Đặt (Settings):** Tùy chỉnh các thông số và giao diện ứng dụng theo ý thích.

### 🛠️ Công Nghệ & Kiến Trúc
*   **Frontend:** [Flutter](https://flutter.dev/) (Dart) - Giao diện đa nền tảng.
*   **Backend/BaaS:** [Firebase](https://firebase.google.com/) - Quản lý dữ liệu và xác thực.
*   **State Management:** Provider (`auth_provider`, `chat_provider`, `mood_provider`, `settings_provider`).
*   **Kết nối mạng:** Tích hợp gọi API thông qua `api_service`.
*   **Kiến trúc:** Dự án được chia theo cấu trúc MVC/MVVM thân thiện với thư mục `models`, `screens`, `providers`, và `services`.

### 📂 Cấu Trúc Thư Mục Chính
```text
lib/
├── models/             # Định nghĩa cấu trúc dữ liệu
├── providers/          # Quản lý trạng thái ứng dụng
├── screens/            # Các màn hình giao diện UI
├── services/           # Xử lý logic gọi API và backend
├── firebase_options.dart # Cấu hình Firebase
└── main.dart           # Điểm bắt đầu của ứng dụng
```

### 🚀 Hướng Dẫn Cài Đặt Khởi Chạy
1. **Clone dự án về máy:**
   ```bash
   git clone <URL_REPO_CUA_BAN>
   cd doancuoiky_nhom11
   ```
2. **Tải các gói thư viện:**
   ```bash
   flutter pub get
   ```
3. **Chạy ứng dụng:**
   ```bash
   flutter run
   ```

---

## 🇬🇧 English

Welcome to the source code repository of Group 11's Final Project! This is a mobile application built with **Flutter**, featuring real-time communication and a personal mood tracker.

### ✨ Key Features
*   **🔐 User Authentication:** Secure login and registration (powered by Firebase).
*   **💬 Real-time Chat:** Send and receive messages instantly.
*   **😊 Mood Tracker:** Log and monitor daily emotional and psychological states.
*   **🚀 Smooth Experience:** Friendly onboarding screens for new users.
*   **⚙️ Settings:** Customize app parameters and user interface preferences.

### 🛠️ Technology Stack & Architecture
*   **Frontend:** [Flutter](https://flutter.dev/) (Dart) - Cross-platform UI toolkit.
*   **Backend/BaaS:** [Firebase](https://firebase.google.com/) - Authentication and database management.
*   **State Management:** Provider pattern (`auth_provider`, `chat_provider`, `mood_provider`, `settings_provider`).
*   **Networking:** API integration handling via `api_service`.
*   **Architecture:** The project follows an MVC/MVVM-friendly structure organized into `models`, `screens`, `providers`, and `services`.

### 📂 Main Folder Structure
```text
lib/
├── models/             # Data structure definitions
├── providers/          # Application state management
├── screens/            # UI screens
├── services/           # API and backend logic handlers
├── firebase_options.dart # Firebase configuration file
└── main.dart           # Application entry point
```

### 🚀 Getting Started
1. **Clone the repository:**
   ```bash
   git clone <YOUR_REPO_URL>
   cd doancuoiky_nhom11
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Run the app:**
   ```bash
   flutter run
   ```

---
*Phát triển bởi Nhóm 11 / Developed by Group 11.*
