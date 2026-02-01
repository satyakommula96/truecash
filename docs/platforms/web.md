# Web Platform

TrueLedger provides a premium, responsive web experience that mirrors the native desktop and mobile applications.

## 🚀 Live Demo

You can try the live version of TrueLedger at:
**[https://trueledger.satyakommula.com](https://trueledger.satyakommula.com)**

## 🛠️ Technical Implementation

The web platform is built with Flutter and uses several modern web technologies to ensure a "local-first" experience.

### 1. Database & Persistence
Unlike many web apps that rely on cloud storage, TrueLedger Web uses **SQLite WASM** for data storage.
- **Engine**: `sqlite3.wasm` is used to run the full SQLite engine inside the browser.
- **Persistence**: Data is persisted in the browser's **IndexedDB** using `sqflite_common_ffi_web`.
- **Encryption**: While the native apps use SQLCipher, the web version currently focuses on local-only unencrypted storage (browser security model).

### 2. URL Strategy
TrueLedger uses the **Path URL Strategy**, meaning URLs look like standard website paths:
- `trueledger.com/dashboard` instead of `trueledger.com/#/dashboard`.
- This requires the server to be configured to redirect all paths to `index.html`.

### 3. File Exports/Imports
Since browsers do not have direct file system access:
- **Exports**: Data exports (CSV, JSON backups) are generated in-memory and triggered as browser downloads.
- **Imports**: File imports use the browser's file picker API (`file_picker`) to read file bytes into the application state.

## 💻 Local Development

To run or build the web version locally:

### Run in Debug Mode
```bash
flutter run -d chrome
```

### Build for Production
```bash
flutter build web --release
```

## 🏗️ Deployment

To deploy the web version (e.g., to GitHub Pages or a custom VPS):

1. **Build**: Run the release build command above.
2. **Upload**: Upload the contents of `build/web/` to your hosting provider.
3. **SPA Configuration**: Ensure your server is configured for Single Page Applications (SPA). For example, if using Nginx:
   ```nginx
   location / {
       try_files $uri $uri/ /index.html;
   }
   ```

## ⚠️ Known Limitations

- **No Native Notifications**: Browser-based notifications are not yet implemented (standard notifications are skipped).
- **No Native Secure Storage**: The web version uses local storage and IndexedDB, which are subject to regular browser security rules and can be cleared if the user wipes their browser data.
- **Auto-Backup**: Native file-system-based auto-backups are disabled on the web. Users are encouraged to manually export backups for data safety.
