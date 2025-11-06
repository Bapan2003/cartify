# 🛒 Cartify — Amazon Clone App

> **Cartify** is a full-featured **Amazon Clone** built with **Flutter**, supporting **Android**, **iOS**, and **Web**.
> It provides a seamless e-commerce experience — from product browsing to checkout — all in a single cross-platform app.

---

## 📱 Platforms Supported

✅ Android
✅ iOS
✅ Web

---

## 🚀 Features

* 🏷️ Browse products across multiple categories
* 🔍 Search and filter items dynamically
* ❤️ Add/remove items from wishlist
* 🛒 Add to cart and manage quantities
* 👤 User authentication & profile management
* 🌐 Real-time data sync with backend (e.g., Firebase / REST API)
* 💬 Product reviews and ratings

---

## 🧩 Tech Stack

| Layer                    | Technology                                                      |
| ------------------------ | --------------------------------------------------------------- |
| **Framework**            | Flutter (≥ 3.x.x)                                               |
| **Language**             | Dart                                                            |
| **UI Design System**     | Material Design (Android) & Cupertino (iOS)                     |
| **State Management**     | Provider                                                        |
| **Dependency Injection** | Provider                                                        |
| **Backend**              | Firebase                                                        |
| **Database**             | Firebase Firestore                                              |
| **Authentication**       | Firebase Auth / Google Sign-In                                  |
| **Storage**              | Firebase Storage                                                |
| **Deployment**           | Android, iOS, and Web                                           |

---

## ⚙️ Installation & Setup

### 1️⃣ Prerequisites

Make sure you have installed:

* [Flutter SDK](https://flutter.dev/docs/get-started/install)
* Android Studio or VS Code with Flutter/Dart plugins
* A configured emulator or physical device
* (Optional) Chrome for web testing

### 2️⃣ Clone the Repository

```bash
git clone https://github.com/Bapan2003/cartify.git
cd cartify
```

### 3️⃣ Install Dependencies

```bash
flutter pub get
```

### 4️⃣ Run the App

#### Android:

```bash
flutter run -d android
```

#### iOS:

```bash
flutter run -d ios
```

#### Web:

```bash
flutter run -d chrome
```

---

## 🧱 Project Structure

```plaintext
lib/
 ├── main.dart                # App entry point
 ├── core/                    # App-wide constants, themes, utils
 ├── data/                    # Models, repositories, services
 ├── presentations/           # UI: screens, widgets, views
 ├── providers/               # State management logic
 ├── repo/                    # Authentication and data repositories
 └── routes/                  # Navigation and route management
```

---

## 🧪 Running Tests

```bash
flutter test
```

(Optional: Include integration tests for checkout or authentication flows.)

---

## 🌐 Build for Production

#### Android (APK / AppBundle)

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

#### iOS

```bash
flutter build ios --release
```

#### Web

```bash
flutter build web --release
```

---

## 🧰 Environment Variables

If your app connects to external APIs or Firebase, create a `.env` file:

```bash
API_URL=https://api.cartify.app
APP_ENV=production
FIREBASE_API_KEY=your_firebase_key
```

Then load it using [`flutter_dotenv`](https://pub.dev/packages/flutter_dotenv).

---

## 🧑‍💻 Contributing

We welcome contributions to **Cartify**!

1. Fork this repository
2. Create a new branch: `git checkout -b feature/your-feature`
3. Make your changes
4. Commit: `git commit -m "Add new feature"`
5. Push: `git push origin feature/your-feature`
6. Open a Pull Request

---

## 🐛 Known Issues

* [ ] Add payment gateway support
* [ ] Optimize image caching for large catalogs
* [ ] Implement dark mode toggle

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 🙌 Acknowledgements

* [Flutter](https://flutter.dev) — the magic behind the app
* [Firebase](https://firebase.google.com) — for backend & authentication
* [Material Icons](https://fonts.google.com/icons) — for modern UI icons

---

## 📸 Screenshots

| Platform | Screenshot                                     |
| -------- | ---------------------------------------------- |
| Mobile   |<p align="center"><img src="https://github.com/user-attachments/assets/95032cf5-a9f1-4ef1-9dcc-c4fe248eda5c" width="220"/> <img src="https://github.com/user-attachments/assets/9d3cdcf7-ea96-4cca-a193-acd7beec947c" width="220"/> <img src="https://github.com/user-attachments/assets/87742029-3b2f-47a9-bbf0-99163a333d27" width="220"/> <img src="https://github.com/user-attachments/assets/2c1f0bab-c059-412a-9ce3-2c922434fc7d" width="220"/> <img src="https://github.com/user-attachments/assets/4fca1891-7043-49b7-a902-10eca576ddf8" width="220"/> <img src="https://github.com/user-attachments/assets/56f6fca6-7221-44d3-990c-273ba7a6a83f" width="220"/> </p>|
| Web      | <p align="center"><img src="https://github.com/user-attachments/assets/f8433beb-de3e-4277-aadd-a461386f4c96" width="660"/> <img src="https://github.com/user-attachments/assets/a364169b-0e6f-476d-a63d-928a991b7c1a" width="660"/> <img src="https://github.com/user-attachments/assets/10fbe24b-3b0e-49e4-9a70-0fbb83db2a19" width="660"/></p>|

---

