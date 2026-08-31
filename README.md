# Risutaku 🌸
An expressive, modern Material 3 AniList client for Android and iOS.

---

## About Risutaku
**Risutaku** is a personal, heavily customized AI-assisted fork of [Otraku](https://github.com/lotusprey/otraku). Built with Flutter, it reimagines the AniList tracking experience around **Material 3 Expressive (M3E)** design principles, Bento information cards, and tactile interactions.

### ✨ Key Features
- **Material 3 Expressive Design**: Dynamic tonal colors, rounded geometry, and modern elevation.
- **Bento Overview Cards**: Glanceable metric cards for media scores, rankings, airing countdowns, and genres.
- **Floating Quick-Action Dock**: Fast 1-tap list status updates and `+1` episode/chapter increments with haptic feedback.
- **Sticky Filter Chips**: Quick horizontal scrolling chips for library collections and discover screens.
- **Lucide Iconography**: Clean, unified Lucide vector icons across the entire app.
- **Rate-Limit & Request Safety**: In-flight query deduplication and active AniList rate-limit protection.

---

## 💖 Credits
- **[AniList](https://anilist.co/)**: For the platform and public GraphQL API.
- **[lotusprey](https://github.com/lotusprey)**: Creator of **[Otraku](https://github.com/lotusprey/otraku)**, which served as the codebase starting point for this fork.

---

## 🛠️ Building from Source

### Android (Modern ARM64)
```bash
flutter build apk --release --target-platform android-arm64
```

### iOS
```bash
flutter build ios --no-codesign
```
