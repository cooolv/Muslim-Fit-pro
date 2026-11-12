# Contributing | المساهمة

Thank you for helping improve Muslim-Fit-pro. The app is Arabic-first, offline-friendly for bundled content, and targets Android and Windows.

شكرًا لمساهمتك في تطوير Muslim-Fit-pro. التطبيق عربي أولًا، ومحتواه المضمّن يعمل دون اتصال، والمنصتان المستهدفتان حاليًا هما Android وWindows.

## Before you start | قبل البدء

- Read the [Arabic README](./README.md) or [English README](./README.en.md), the [architecture guide](./docs/ARCHITECTURE.md), and the [privacy policy](./PRIVACY.md).
- For substantial behavior or UI changes, open an issue or discuss the proposed approach before implementation.
- Keep changes focused. Avoid committing generated platform directories, build output, credentials, signing keys, or local Firebase configuration.
- Add dependencies only when the feature needs them and the Flutter SDK does not already provide the capability.

## Development workflow | خطوات التطوير

1. Create a branch from the current default branch.
2. Make a focused change using the existing Flutter/Dart patterns.
3. Format changed Dart files with `dart format`.
4. Run `flutter analyze`. Add or update focused tests for new behavior; run `flutter test` when tests are present.
5. Update the Arabic and English documentation when behavior, setup, data handling, or release steps change.
6. Open a pull request describing the user impact, implementation, and validation performed.

Do not include Firebase values, `.env` files, keystores, passwords, or other credentials in commits or pull-request screenshots.

## Adding exercises | إضافة التمارين

- Add a unique, stable `Ex.id` to `exercises` in [`lib/data.dart`](./lib/data.dart). Existing Firestore workout sets and logs refer to these IDs.
- Include a useful Arabic name, muscle group, equipment (`none`, `dumbbell`, or `gym`), difficulty, clear ordered steps, and one practical safety tip.
- Add a dedicated `Rig` to [`lib/rig.dart`](./lib/rig.dart) or an appropriate `exerciseRigAliases` entry. If an animation is shared, treat it as an illustration, not an exact biomechanical demonstration.
- If adding the exercise to a built-in `Routine` or `Plan`, use its existing ID and confirm it resolves through the exercise catalog.
- Do not describe an exercise as a treatment or promise injury prevention.

## Nutrition and health content | محتوى التغذية والصحة

- Keep nutrition material educational and general. Do not diagnose, prescribe, recommend changing medication, or suggest supplements as treatment.
- Use reputable sources and link them in the in-app references when adding health claims.
- Preserve visible cautions for diabetes, anemia, fasting, medication, pregnancy, children, and other situations requiring individualized care.
- Do not present an example meal plan as a personalized calorie or medical prescription.

## UI and localization | الواجهة والتعريب

- Keep Arabic text natural and maintain the app-wide right-to-left layout.
- Use theme colors and existing Material 3 components; verify long Arabic labels on both phone-sized and desktop layouts.
- Keep bundled content usable without a network connection. Make cloud authentication and network failures explicit in cloud-only features.
- Keep accessibility in mind: tooltips for icon-only controls, readable contrast, and controls that do not rely on color alone.

## Pull request checklist | قائمة مراجعة طلب الدمج

- [ ] The change is focused and its visible behavior is described.
- [ ] IDs and Firestore compatibility are preserved, or a migration is documented.
- [ ] `dart format` and `flutter analyze` were run when Flutter tooling is available.
- [ ] Focused tests were added or updated for new behavior where appropriate.
- [ ] Arabic/English docs and health/privacy notices are updated when relevant.
- [ ] No secrets, generated platform folders, or build artifacts are included.

