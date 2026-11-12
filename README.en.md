# Muslim-Fit-pro

**An Arabic-first fitness app for home and gym**, built with Flutter.  
العربية: [README.md](./README.md).

## At a glance

- **100 exercises** across bodyweight, dumbbell, and gym equipment, with target muscles, difficulty, instructions, and tips.
- Procedural 2D rig illustrations; related variations may share an illustrative motion.
- Six ready-to-run routines with a preparation countdown, timer, pause, skip, and automatic transitions, plus three training plans.
- Custom exercise sets, a rest timer, workout logging, and progress history.
- An interactive nutrition section with flexible goal-based meal ideas, Islamic fasting guidance, safety notes, and references.
- A global error screen that shows exception details and stack traces, with copy and share actions.
- Right-to-left Arabic UI and light/dark themes.

## Platforms and stack

| Area | Technology |
| --- | --- |
| App | Flutter / Dart |
| Platforms built by the current workflow | Android and Windows |
| Cloud sign-in | Firebase Anonymous Authentication |
| Cloud data | Cloud Firestore |
| Motion and screen wake lock | Local 2D rigging and `wakelock_plus` |
| External links | `url_launcher` |
| Sharing error reports | `share_plus` |

Exercise, routine, plan, and nutrition content is bundled locally. Browsing it and running built-in routines does not require an internet connection. Firebase configuration is still required at build and app initialization. Anonymous sign-in and cloud features need a connection on first use; after sign-in, Firestore caches changes locally and syncs them when connectivity returns.

## Get started

### Requirements

- Flutter on the stable channel and a Dart SDK compatible with [`pubspec.yaml`](./pubspec.yaml).
- Android Studio or Visual Studio, depending on the target platform.
- A Firebase project with **Anonymous Authentication** and **Cloud Firestore** enabled if you want to use cloud features.

### Setup and run

1. Clone the repository and change into its directory.
2. Generate local platform projects; they are intentionally not committed:

   ```bash
   flutter create . --platforms=android,windows --org com.muslimfit
   flutter pub get
   ```

3. Pass Firebase configuration to Flutter with `--dart-define`. Set these values in your local environment before running the command; never commit credentials or signing keys:

   ```bash
   flutter run \
     --dart-define=FB_API_KEY="$FB_API_KEY" \
     --dart-define=FB_APP_ID="$FB_APP_ID" \
     --dart-define=FB_SENDER_ID="$FB_SENDER_ID" \
     --dart-define=FB_PROJECT_ID="$FB_PROJECT_ID"
   ```

   The names correspond to the constants in [`lib/main.dart`](./lib/main.dart). Firebase configuration is required for app initialization, even when using local features offline.

4. Enable Anonymous Authentication and Firestore in Firebase Console, then deploy [`firestore.rules`](./firestore.rules). Do not use open/public Firestore rules.

### Local checks and builds

```bash
flutter analyze
flutter build apk --release \
  --dart-define=FB_API_KEY="$FB_API_KEY" \
  --dart-define=FB_APP_ID="$FB_APP_ID" \
  --dart-define=FB_SENDER_ID="$FB_SENDER_ID" \
  --dart-define=FB_PROJECT_ID="$FB_PROJECT_ID"
flutter build windows --release \
  --dart-define=FB_API_KEY="$FB_API_KEY" \
  --dart-define=FB_APP_ID="$FB_APP_ID" \
  --dart-define=FB_SENDER_ID="$FB_SENDER_ID" \
  --dart-define=FB_PROJECT_ID="$FB_PROJECT_ID"
```

There is currently no `test/` directory. Add focused tests when introducing new logic, then run `flutter test`.

## Project map

| Path | Responsibility |
| --- | --- |
| [`lib/main.dart`](./lib/main.dart) | Entry point, theme and navigation, exercise list/details, user sets, and motion rendering |
| [`lib/data.dart`](./lib/data.dart) | `Ex` model, 100 exercises, routines, training plans, and player steps |
| [`lib/player.dart`](./lib/player.dart) | Workout timer, preparation, pause, skip, and automatic transitions |
| [`lib/extras.dart`](./lib/extras.dart) | Rest timer, workout logging, progress page, and plans |
| [`lib/nutrition.dart`](./lib/nutrition.dart) | Offline interactive nutrition content and references |
| [`lib/rig.dart`](./lib/rig.dart) and [`lib/parts_data.dart`](./lib/parts_data.dart) | Character rig, motion frames, and body-part pivots |
| [`lib/splash.dart`](./lib/splash.dart) | Splash screen, Firebase initialization, and Firestore local persistence |
| [`lib/cloud_access.dart`](./lib/cloud_access.dart) | Sign-in gate for cloud features |
| [`lib/error_reporter.dart`](./lib/error_reporter.dart) | Flutter/Dart error capture and copyable/shareable reports |
| [`firestore.rules`](./firestore.rules) | Firestore read/write access rules |
| [`.github/workflows/build.yml`](./.github/workflows/build.yml) | Android/Windows builds and release artifacts |
| [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md) | App flow and data model |

For character-art requirements, see [`docs/AI_CHARACTER_PROMPT.md`](./docs/AI_CHARACTER_PROMPT.md). For contribution guidance, see [`CONTRIBUTING.md`](./CONTRIBUTING.md).

## Add an exercise

1. Add an `Ex` entry to `exercises` in [`lib/data.dart`](./lib/data.dart), including a **unique, stable ID**, Arabic name, muscle group, equipment (`none`, `dumbbell`, or `gym`), difficulty, steps, and a tip.
2. Add a dedicated rig in [`lib/rig.dart`](./lib/rig.dart), or map the exercise to a suitable illustrative motion using `exerciseRigAliases`. Shared motions are illustrative; the written steps remain the primary instructions.
3. Use the same ID in an `RStep` if adding it to a built-in routine. Custom sets enumerate `exercises` automatically.
4. Verify the ID is unique and the exercise appears in search, details, and the player.

**Do not change an exercise ID after release without migrating stored data:** Firestore sets and logs refer to `Ex.id`.

## Firebase and data

- `logs`: `owner`, `ex`, `reps`, `kg`, `at`.
- `sets`: `name`, `ids`, `steps` (optional for legacy sets), `public`, `owner`, `at`.
- Sign-in is anonymous; no name or email is required. Firebase retains the anonymous identity on the device. Clearing app data or reinstalling may make a previous anonymous identity unrecoverable.
- Current rules restrict logs and private sets to their owner, while signed-in users can read public sets. Review the rules before changing sharing behavior.
- Firebase client keys are not secrets by themselves; security relies on Firestore rules and API-key restrictions. **Never commit a keystore, passwords, or Firebase secret files.**

See the [Privacy Policy](./PRIVACY.md) for data and service details.

## Releases

The workflow in [`.github/workflows/build.yml`](./.github/workflows/build.yml) builds and publishes a GitHub Release for every commit pushed to `main`. It also runs for stable `vX.Y.Z` tags and manual dispatch:

1. Automatically increments the patch version from the latest stable version tag, falling back to the base version in `pubspec.yaml`.
2. Generates Android and Windows platform projects, then builds a version-named APK and Windows ZIP. The Android build number is the GitHub Actions run number.
3. Builds an Android App Bundle when these signing secrets are configured: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, and `ANDROID_KEY_ALIAS`.
4. Creates a new version tag and GitHub Release, such as `v1.2.1`, and uploads the artifacts. Releases are queued to avoid duplicate version numbers when commits arrive close together.

The four Firebase secrets `FB_API_KEY`, `FB_APP_ID`, `FB_SENDER_ID`, and `FB_PROJECT_ID` must be configured in GitHub Actions; the workflow fails clearly if one is missing. Update the base version in [`pubspec.yaml`](./pubspec.yaml) when starting a new major/minor series; the app's displayed release version is injected automatically during builds.

The current Android application ID is `com.muslimfit.muslim_fit_pro`; do not change it after publishing to an app store.

## Notices

- Exercise and nutrition content is general education, not diagnosis or treatment. Consult a clinician or registered dietitian about health conditions, medications, pregnancy, or children.
- Nutrition content does not recommend changing diabetes treatment or starting iron supplements without a clinician.
- This project is licensed under [MIT](./LICENSE).

