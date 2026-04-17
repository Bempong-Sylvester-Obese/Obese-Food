# Obese Food

Obese Food is a SwiftUI iOS app for recognizing a small set of Ghanaian meals, attaching nutrition estimates, and syncing user progress with Firebase.

## MVP Status

The current repo is set up for an MVP, not a full production release yet.

What works now:
- Email/password authentication with Firebase Auth
- On-device meal analysis using a bundled CoreML model
- Nutrition history saved locally and synced to Firestore
- Editable profile and calorie-goal data
- Gamification progress with streaks, points, and achievements
- Low-confidence fallback that lets the user choose a supported meal manually

Supported dishes in the baseline classifier:
- `Jollof Rice`
- `Waakye`
- `Banku and Tilapia`
- `Fufu and Light Soup`

## Tech Stack

- iOS: Swift, SwiftUI, Combine
- ML: CoreML
- Backend: Firebase Auth and Firestore
- CI: GitHub Actions with `xcodebuild`
- Local tooling: Python script for regenerating the baseline model

## Repo Layout

```text
Obese-Food/
├── ObeseFoodApp/                 # iOS app source
├── ObeseFoodApp.xcodeproj/       # Xcode project
├── ObeseFoodAppTests/            # Unit tests
├── docs/                         # Setup and architecture notes
├── scripts/                      # Utility scripts
├── firebase.json                 # Firebase CLI config
├── firestore.rules               # Firestore security rules
├── firestore.indexes.json        # Firestore composite indexes
└── .github/workflows/ios.yml     # CI workflow
```

## Getting Started

### Requirements

- Xcode 15+
- iOS 14+
- A Firebase project with Auth and Firestore enabled

### Local Setup

1. Clone the repo.
2. Copy `ObeseFoodApp/GoogleService-Info.sample.plist` to `ObeseFoodApp/GoogleService-Info.plist`.
3. Replace the placeholder values in `GoogleService-Info.plist` with your Firebase app config.
4. Open `ObeseFoodApp.xcodeproj` in Xcode.
5. Let Swift Package Manager resolve the Firebase dependencies.
6. Build and run the `ObeseFoodApp` scheme.

### Firebase Setup

1. Enable Email/Password authentication.
2. Create a Firestore database.
3. Deploy the included rules and indexes:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

## Model Regeneration

The repository includes a baseline CoreML model at `ObeseFoodApp/BaselineFoodClassifier.mlmodel`.

If you change the engineered features or supported dishes, regenerate it with:

```bash
python3.11 -m venv .venv-modelgen
.venv-modelgen/bin/pip install coremltools scikit-learn==1.5.1
.venv-modelgen/bin/python scripts/generate_baseline_food_model.py
```

## Current Limitations

- The bundled classifier is a small baseline model tuned for the supported MVP dishes only.
- Profile images are not uploaded to Firebase Storage yet.
- Firebase Functions and richer nutrition enrichment are not implemented yet.
- CI uses a placeholder Firebase plist for build and unit-test coverage.

## Documentation

- [Setup Guide](docs/SETUP.md)
- [Architecture](docs/architecture.md)
- [Next Steps](docs/NEXT_STEPS.md)
- [Contributing](CONTRIBUTING.md)

## License

MIT. See [LICENSE](LICENSE).


