# Obese Food Next Steps

This file tracks the most useful work after the MVP recovery pass.

## Immediate Next Steps

### 1. Replace the baseline classifier with a real meal dataset

The current CoreML model is good enough for a supported-dish MVP, but the next step is to train on real food images instead of synthetic feature centroids.

Recommended path:

1. Collect real training images for the current supported dishes
2. Add an `Unknown` / `Other` class with real non-matching food images
3. Retrain the model and regenerate `BaselineFoodClassifier.mlmodel`
4. Measure precision and recall on held-out meal photos

### 2. Add camera capture

The app currently uses photo-library selection only. A natural next step is:

- camera capture
- photo retake flow
- better empty and permission states

### 3. Persist profile images properly

The profile avatar interaction was intentionally trimmed back for the MVP because there is no storage pipeline yet.

To add it back:

1. Upload profile images to Firebase Storage
2. Save the download URL on `userProfiles/{userId}`
3. Cache the image locally for faster profile loads

### 4. Expand nutrition coverage

Current nutrition values are static estimates in `FoodCatalog`.

Good next additions:

- serving-size adjustments
- richer micronutrient data
- local nutrition lookup by portion size
- optional API enrichment for foods outside the supported dish list

## Product Hardening

### Firebase

- Add staging and production Firebase projects
- Store environment-specific plist files securely
- Add App Check if the app moves beyond internal/demo use

### Testing

- Add unit tests for `FoodAnalyzer` feature extraction
- Add tests for `DataManager` profile seeding and sync behavior
- Add UI tests for auth, scan, and save-to-history flow

### UX

- Add onboarding for supported dishes and confidence handling
- Improve accessibility labels and dynamic type support
- Add clearer success toasts after saving a scan

## Release Prep

Before TestFlight or App Store distribution:

1. Replace placeholder Firebase config locally with a real project
2. Train and validate a real meal classifier
3. Add a privacy policy and terms links
4. Run the GitHub Actions workflow successfully
5. Verify sign-in, scan, history, and profile flows on device
