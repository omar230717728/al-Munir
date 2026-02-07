# 📖 Al-Munir (المنير)

**Al-Munir** is a comprehensive and beautifully designed Flutter application dedicated to the Holy Quran. It provides a rich experience for reading, listening, and engaging with the Quran and daily Azkar.

## ✨ Key Features

-   **📖 Interactive Quran Reading**: High-quality Uthmanic text with support for various fonts (Amiri, Cairo, Uthmanic, etc.) for a comfortable reading experience.
-   **🎧 Audio Playback**: Listen to your favorite reciters with background playback support, seamless audio controls, and reciter selection.
-   **🌍 Multi-Language Support**: Fully localized interface supporting Arabic, English, German, Malay, Turkish, Russian, and more.
-   **🔔 Smart Notifications**: 
    -   **Daily Ayah**: Receive a random verse to reflect upon.
    -   **Zikr Reminders**: Periodic notifications for Azkar (Supplications) to keep you connected.
    -   **Overlay Reminders**: Non-intrusive overlay popups for quick Zikr reminders.
-   **🎨 Beautiful UI/UX**: Modern, responsive design using `flutter_screenutil` and sleek animations.
-   **🌙 Dark/Light Mode**: (If applicable, specialized themes for reading).
-   **💾 Offline Access**: Download content and recitations for offline use (backed by Hive for local storage).

## 🛠️ Tech Stack

Built with ❤️ using **Flutter** and a robust set of packages:

-   **State Management**: `flutter_bloc`
-   **Audio**: `just_audio`, `just_audio_background`
-   **Local Storage**: `hive`, `shared_preferences`
-   **Localization**: `easy_localization`
-   **Background Tasks**: `workmanager`, `flutter_local_notifications`
-   **UI Components**: `flutter_screenutil`, `shimmer`, `lottie`, `animate_do`
-   **Navigation**: `go_router` (or standard navigation if simpler)

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

## 📱 Screenshots

| Home Screen | Quran Page | Audio Player |
|:-----------:|:----------:|:------------:|
| ![Home](assets/images1/al-munner.png) | *(Add Screenshot)* | *(Add Screenshot)* |

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
