# Rise

Rise is an iOS alarm app that forces users to physically get up by requiring them to tap an NFC sticker to dismiss their alarm.

## Architecture

Rise is built with SwiftUI + SwiftData (iOS 17+), using a strict protocol-driven module architecture with Combine for inter-module communication.

### Modules

| Module | Branch | Owner |
|--------|--------|-------|
| DataLayer | `feature/data-layer` | Teammate 1 |
| AlarmEngine | `feature/alarm-engine` | Teammate 1 |
| NFCHandler | `feature/nfc-handler` | Teammate 2 |
| AudioLibrary | `feature/audio-library` | Teammate 2 |
| CheckInModule | `feature/checkin-module` | Teammate 2 |
| Gamification | `feature/gamification` | Teammate 3 |
| OnboardingFlow | `feature/onboarding-flow` | Teammate 3 |
| HomeScreen | `feature/home-screen` | Teammate 3 |

## Branch Strategy

- `main` — production, protected, requires PR + review
- `develop` — integration branch, all feature branches merge here first
- `feature/*` — one branch per module

## Setup

1. Clone the repo
2. Open `RiseApp/RiseApp.xcodeproj` in Xcode 15+
3. Ensure you have an NFC-capable device for testing (iPhone 7+)
4. Add your development team ID in project settings

## Adding Collaborators

```bash
# TODO: Run these commands to add your teammates
gh repo add-collaborator <teammate-1-username> --permission write
gh repo add-collaborator <teammate-2-username> --permission write
gh repo add-collaborator <teammate-3-username> --permission write
```

## Requirements

- iOS 17.0+
- Xcode 15+
- Swift 5.9+
- Physical iPhone with NFC (for NFC features)

## License

MIT
