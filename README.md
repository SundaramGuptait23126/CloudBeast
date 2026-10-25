# 🎵 CloudBeats - Google Drive Cloud Music Player

A sleek, modern Flutter music player that connects directly to your personal Google Drive, scans your audio tracks, and streams or caches them for playback.

---

## ✨ Features

- **Google Drive Integration**: Fetches audio files (`.mp3`, `.m4a`, `.wav`, `.flac`, `.aac`, `.ogg`) using Google Drive API v3.
- **Smart Folder Categorization**: Automatically groups your songs by their Drive folders ("Lo-Fi", "Acoustic", "Hindi Songs", etc.).
- **High-Fidelity Audio Streaming**: Powered by `just_audio` with direct OAuth Bearer Token streaming.
- **Offline Caching**: Download and cache your favorite Drive tracks to local storage for instant seek and offline listening.
- **Now Playing Experience**:
  - Vinyl disc rotation animation.
  - Interactive seek bar with buffered progress.
  - Shuffle, Loop (all/single), Next/Previous controls.
  - Real-time file extension and size badges.
- **Persistent Mini Player**: Floating bar with quick controls and tap-to-expand.
- **Instant Demo Mode**: Includes high-quality demo audio streams so you can explore the app immediately even without setting up Google Cloud OAuth.

---

## 🛠️ Google Cloud OAuth Setup (For Live Drive Connection)

To connect your personal Google Drive account in a release APK or local run:

1. Go to the [Google Cloud Console](https://console.cloud.google.com/).
2. Create a new project (e.g. `CloudBeats Player`).
3. Enable the **Google Drive API**:
   - Go to **APIs & Services > Library** -> Search for `Google Drive API` -> Click **Enable**.
4. Configure OAuth Consent Screen:
   - Select **External** (or Internal for Workspace).
   - Add App name, support email, and add scope `https://www.googleapis.com/auth/drive.readonly`.
   - Add your Google email under **Test Users**.
5. Create OAuth Client ID:
   - Go to **APIs & Services > Credentials** -> **Create Credentials > OAuth Client ID**.
   - **For Android**:
     - Package name: `com.cloudbeats.app`
     - SHA-1 fingerprint: run `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey` and paste the SHA-1.
   - **For Web**:
     - Authorized JavaScript origins: `http://localhost:port`
6. (Optional for Android) Download `google-services.json` and place it in `android/app/`.

---

## 🚀 Running the Project

```bash
# Get dependencies
flutter pub get

# Run on Chrome (Web)
flutter run -d chrome

# Run on Windows
flutter run -d windows

# Run on connected Android phone / emulator
flutter run -d android
```
