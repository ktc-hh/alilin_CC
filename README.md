# Pinly 📌
A Pinterest-style inspiration app built with Flutter & Dart (CC 302 Final Project).

## Setup
```bash
flutter create . --project-name pinly   # generates android/ ios/ etc. (keeps lib/ and pubspec.yaml)
flutter pub get
flutter run
```
Android release builds need `<uses-permission android:name="android.permission.INTERNET"/>`
in `android/app/src/main/AndroidManifest.xml`.

## API
Picsum Photos – https://picsum.photos/v2/list?page=1&limit=20 (no API key)
