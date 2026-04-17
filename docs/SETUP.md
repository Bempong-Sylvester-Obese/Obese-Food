# Obese Food Setup Guide

This guide covers the current MVP repo layout and the minimum setup needed to run the app locally.

## Requirements

- Xcode 15 or newer
- iOS 14 simulator or device
- A Firebase project
- Apple developer signing set up in Xcode if you want to run on a device

## 1. Firebase Project

Create a Firebase project and enable:

- Authentication with Email/Password
- Firestore Database

Storage and Functions are not required for the current MVP flow.

## 2. Add the iOS App in Firebase

Register an iOS app with bundle identifier:

`com.obesefood.app`

Then download `GoogleService-Info.plist`.

## 3. Configure the Local Repo

From the repo root:

```bash
cp ObeseFoodApp/GoogleService-Info.sample.plist ObeseFoodApp/GoogleService-Info.plist
```

Replace the placeholder values in `ObeseFoodApp/GoogleService-Info.plist` with the real Firebase config you downloaded.

## 4. Open the Project

```bash
open ObeseFoodApp.xcodeproj
```

When Xcode opens:

1. Let Swift Package Manager resolve the Firebase packages.
2. Confirm the `ObeseFoodApp` scheme is selected.
3. Choose an iOS 14+ simulator or device.

## 5. Firestore Rules and Indexes

This repo now includes:

- `firebase.json`
- `firestore.rules`
- `firestore.indexes.json`

Deploy them with:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

The included index supports the app query that filters `foodScans` by `userId` and orders by `timestamp`.

## 6. Run the App

The main MVP flow is:

1. Sign up or sign in
2. Pick a meal image from the photo library
3. Run the on-device classifier
4. Review or manually correct the predicted meal
5. Save the scan to history

## 7. Regenerate the Baseline Model

If you change the feature extraction logic or supported dishes:

```bash
python3.11 -m venv .venv-modelgen
.venv-modelgen/bin/pip install coremltools scikit-learn==1.5.1
.venv-modelgen/bin/python scripts/generate_baseline_food_model.py
```

That updates `ObeseFoodApp/BaselineFoodClassifier.mlmodel`.

## Troubleshooting

### Build fails because `GoogleService-Info.plist` is missing

Make sure `ObeseFoodApp/GoogleService-Info.plist` exists locally. The sample plist is only a template.

### Firebase auth or Firestore calls fail

Check:

- the Firebase bundle ID matches `com.obesefood.app`
- Email/Password auth is enabled
- Firestore rules and indexes are deployed

### `xcodebuild` fails locally before the project compiles

If your local Xcode installation reports missing first-launch components, run the usual Xcode setup on your machine before retrying.
