# Contributing

Thanks for contributing to Obese Food.

## Before You Start

- Read `README.md` and `docs/SETUP.md`
- Use a real `ObeseFoodApp/GoogleService-Info.plist` locally if you need Firebase-backed flows
- Keep the current MVP scope in mind before adding new UI surface area

## Development Guidelines

- Prefer changes that keep the SwiftUI flow simple and testable
- Keep `DataManager` as the main source of truth for profile and scan history
- Keep `GamificationManager` focused on points, streaks, and achievements
- If you change the feature extraction logic or supported foods, regenerate `ObeseFoodApp/BaselineFoodClassifier.mlmodel`

## Pull Requests

Each pull request should include:

- a short summary of the user-facing change
- any Firebase or config prerequisites
- test notes or verification steps

## High-Value Areas

Good next contributions include:

- better CoreML training data and evaluation
- camera capture support
- Firebase Storage-backed profile images
- stronger unit and UI test coverage
