# 📖 Al-Munir (المنير)

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-2.18+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

**Al-Munir** is a comprehensive, beautifully designed, and feature-rich Flutter application dedicated to the Holy Quran. It provides a seamless and immersive experience for reading, listening, and engaging with the Quran and daily Azkar.

---

## ✨ Key Features

### 📖 Quran Reading
-   **High-Quality Text**: Crystal clear Uthmanic text with support for multiple high-quality fonts (Amiri, Cairo, Uthmanic, KFGQPC).
-   **Tafseer & Translation**: Access to Tafseer (exegesis) and translations in multiple languages directly from the verse options.
-   **Bookmark & Favorites**: Easily bookmark your progress or mark verses as favorites for quick access.
-   **Share**: Share verses as text or images with beautiful backgrounds.

### 🎧 Audio Playback
-   **Gapless Playback**: Enjoy verse-by-verse recitation from world-renowned reciters.
-   **Wide Selection**: Choose from a vast library of reciters including:
    -   Mishary Rashid Alafasy
    -   Abdul Basit Abdul Samad
    -   Al-Minshawi
    -   Maher Al-Muaiqly
    -   **Yasser Al-Dosari** (New!)
    -   And many more...
-   **Background Audio**: Listen to the Quran while using other apps or when the screen is off.
-   **Audio Controls**: Play, pause, skip, and repeat verses or entire Surahs.

### 🌍 Multi-Language Support
-   Fully localized interface supporting:
    -   🇺🇸 English
    -   🇸🇦 Arabic (العربية)
    -   🇹🇷 Turkish (Türkçe)
    -   🇷🇺 Russian (Русский)
    -   🇲🇾 Malay (Bahasa Melayu)
    -   And more...

### 🔔 Smart Reminders & Azkar
-   **Daily Ayah**: Receive a notification with a random verse to reflect upon every day.
-   **Zikr Reminders**: Periodic notifications for Azkar (Tasbeeh, Istighfar) to keep your tongue moist with the remembrance of Allah.
-   **Overlay Notifications**: Unique, non-intrusive overlay reminders for Zikr.

### 🎨 Modern UI/UX
-   **Themes**: Toggle between Light and Dark modes for comfortable reading in any lighting condition.
-   **Animations**: Smooth and elegant animations powered by `animate_do` and `lottie`.
-   **Responsive**: Optimized for various screen sizes using `flutter_screenutil`.

---

## 🛠️ Tech Stack

Built with ❤️ using **Flutter** and a robust ecosystem of packages:

-   **State Management**: [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) - Predictable state management.
-   **Audio**: [`just_audio`](https://pub.dev/packages/just_audio) & [`just_audio_background`](https://pub.dev/packages/just_audio_background) - Feature-rich audio player.
-   **Storage**: [`hive`](https://pub.dev/packages/hive) & [`shared_preferences`](https://pub.dev/packages/shared_preferences) - Fast, local storage.
-   **Localization**: [`easy_localization`](https://pub.dev/packages/easy_localization) - Internationalization made easy.
-   **Background Tasks**: [`workmanager`](https://pub.dev/packages/workmanager) - Handling background jobs.
-   **Notifications**: [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications).

---

## 🚀 Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/al-munir.git
    cd al-munir
    ```

2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the App**:
    ```bash
    flutter run
    ```

---

## 📱 Screenshots

| Home Screen | Quran Page | Audio Player |
|:-----------:|:----------:|:------------:|
| <img src="assets/images1/al-munner.png" width="200" /> | *(Add Screenshot)* | *(Add Screenshot)* |

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
