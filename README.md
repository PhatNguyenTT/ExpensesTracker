# 💰 Money Tracker - Ứng dụng Quản lý Chi tiêu

Ứng dụng mobile quản lý chi tiêu cá nhân được xây dựng bằng Flutter và Firebase, giúp bạn theo dõi thu chi một cách hiệu quả và trực quan.

## ✨ Tính năng chính

### 📊 **Dashboard & Thống kê**
- **Tổng quan tài chính**: Hiển thị tổng thu nhập, chi tiêu và số dư
- **Thống kê theo tháng**: Xem chi tiết thu chi từng tháng  
- **Báo cáo trực quan**: Biểu đồ cột và biểu đồ tròn theo danh mục
- **Lịch sử giao dịch**: Xem toàn bộ giao dịch với bộ lọc nâng cao

### 💳 **Quản lý Giao dịch**
- **Thêm giao dịch nhanh**: Interface đơn giản, thân thiện
- **Phân loại danh mục**: Quản lý chi tiêu theo từng nhóm (Đồ ăn, Mua sắm, Giao thông...)
- **Ghi chú chi tiết**: Thêm mô tả cho mỗi giao dịch
- **Chỉnh sửa & xóa**: Quản lý giao dịch linh hoạt

### 📅 **Lịch & Lọc dữ liệu**
- **Calendar View**: Xem giao dịch theo ngày/tháng
- **Lọc theo thời gian**: Tùy chỉnh khoảng thời gian xem
- **Tìm kiếm nâng cao**: Tìm theo tên, danh mục, số tiền

### ⚙️ **Cài đặt & Tùy chỉnh**  
- **Quản lý danh mục**: Tạo, sửa, xóa categories
- **Dark/Light Theme**: Giao diện tối/sáng tùy chỉnh
- **Báo cáo tùy chỉnh**: Xuất báo cáo theo nhu cầu

## 🛠️ Tech Stack

### **Frontend**
- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language
- **BLoC Pattern** - State management
- **Material Design** - UI/UX guidelines

### **Backend & Database**
- **Firebase Firestore** - NoSQL database
- **Firebase Auth** - Authentication (ready for future)
- **Cloud Functions** - Serverless backend (planned)

### **Architecture**
- **Clean Architecture** - Separation of concerns
- **Repository Pattern** - Data abstraction layer
- **BLoC** - Business Logic Components
- **Dependency Injection** - Loose coupling

## 📱 Screenshots

| Dashboard | Add Expense | Statistics | Calendar |
|-----------|-------------|------------|----------|
| ![Dashboard](assets/screenshots/dashboard.png) | ![Add](assets/screenshots/add.png) | ![Stats](assets/screenshots/stats.png) | ![Calendar](assets/screenshots/calendar.png) |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Firebase account

### Installation

1. **Clone repository**
```bash
git clone https://github.com/PhatNguyenTT/ExpensesTracker.git
cd ExpensesTracker
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Firebase Setup**
- Tạo project mới trên [Firebase Console](https://console.firebase.google.com/)
- Thêm Android/iOS app vào project
- Download `google-services.json` và đặt vào `android/app/`
- Enable Firestore Database

4. **Run application**
```bash
flutter run
```

## 📁 Project Structure

```
lib/
├── main.dart                 # Entry point
├── app.dart                  # App configuration  
├── appView.dart             # Main app view
├── data/                    # Sample data
├── resources/              # Colors, themes
├── screens/                # UI screens
│   ├── home/               # Dashboard & main
│   ├── addExpense/         # Add/edit transactions
│   ├── calendar/           # Calendar view
│   ├── stats/              # Statistics & charts
│   └── settings/           # Settings & preferences
├── services/               # Business services
└── utils/                  # Utilities & helpers

packages/
└── expense_repository/     # Data layer
    ├── lib/src/
    │   ├── entities/       # Firestore entities
    │   ├── models/         # Business models  
    │   └── firebase_expense_repo.dart
    └── pubspec.yaml
```

## 🎯 Key Features Details

### **BLoC State Management**
- `GetExpensesBloc` - Quản lý danh sách giao dịch
- `CreateExpenseBloc` - Tạo giao dịch mới
- `GetCategoriesBloc` - Quản lý danh mục
- `GetSummaryBloc` - Thống kê tổng quan

### **Repository Pattern**
```dart
abstract class ExpenseRepository {
  Future<List<Expense>> getExpenses();
  Future<void> createExpense(Expense expense);
  Future<List<Category>> getCategories();
  // ... more methods
}
```

### **Clean Architecture Layers**
1. **Presentation Layer** - UI components, BLoC
2. **Domain Layer** - Business logic, entities  
3. **Data Layer** - Repository implementation, Firebase

## 🔄 Recent Updates

### Version 2.0.0 - Settings Edition
- ✅ **New Settings Screen** - Light theme, organized layout
- ✅ **Category Management** - View, create, edit categories
- ✅ **Improved Navigation** - Better user experience
- ✅ **Performance Optimizations** - Faster loading times
- ✅ **UI/UX Enhancements** - Modern, clean interface

## 🚧 Roadmap

### **Upcoming Features**
- [ ] **User Authentication** - Firebase Auth integration
- [ ] **Data Backup & Sync** - Cloud synchronization
- [ ] **Budget Planning** - Set monthly budgets
- [ ] **Recurring Transactions** - Auto expenses/income
- [ ] **Export Reports** - PDF/Excel export
- [ ] **Multiple Currencies** - International support
- [ ] **Notifications** - Smart reminders
- [ ] **Widgets** - Home screen widgets

### **Technical Improvements**
- [ ] **Offline Support** - Local storage cache
- [ ] **Performance** - Further optimizations
- [ ] **Testing** - Unit & integration tests
- [ ] **CI/CD** - Automated deployment
- [ ] **Documentation** - Developer guides

## 🤝 Contributing

1. Fork the project
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Contact

**Phat Nguyen** - [@PhatNguyenTT](https://github.com/PhatNguyenTT)

**Project Link**: [https://github.com/PhatNguyenTT/ExpensesTracker](https://github.com/PhatNguyenTT/ExpensesTracker)

---

⭐ **Nếu project hữu ích, hãy cho 1 star nhé!** ⭐
