# Architecture | بنية التطبيق

This note describes the current implementation. See the [Arabic README](../README.md) or [English README](../README.en.md) for setup and release instructions.

هذا الملف يشرح البنية الحالية للمشروع؛ راجع [الدليل العربي](../README.md) أو [الدليل الإنجليزي](../README.en.md) للتشغيل والإصدارات.

## Runtime flow | تدفق التشغيل

1. `main()` creates the Flutter binding, installs Flutter/Dart uncaught-error handlers, and starts `FitPro`.
2. `Boot` initializes Firebase using compile-time `--dart-define` values and enables Firestore persistence. This initialization is required even for offline use, but it does not sign in at app launch.
3. `Home` presents five destinations: exercises, routines, custom sets, progress, and nutrition.
4. Bundled exercise/routine/nutrition content is local. `CloudAccessGate` requests anonymous sign-in only when a cloud-backed view is opened.
5. After sign-in, Firestore streams and writes use the active anonymous UID. Cached data and pending writes can be synchronized when connectivity returns.
6. Uncaught framework, platform-dispatcher, and Dart-zone errors, plus selected caught operation failures, are reported through `lib/error_reporter.dart`. The global error screen displays the exception and stack trace and lets the user copy or share the report. Reports are not uploaded automatically. Native process termination and OS force-closes cannot be caught by an in-app Flutter screen.

## Source map | خريطة الملفات

| File | Role |
| --- | --- |
| `lib/main.dart` | App shell, navigation, exercise search/detail, custom sets, `gifOf`, and the `Detail` route |
| `lib/data.dart` | Exercise, routine, plan, and step models plus bundled catalog data |
| `lib/player.dart` | Timed routine playback, controls, transitions, and completion logging |
| `lib/extras.dart` | Rest timer, set logging, progress charts, and training plans |
| `lib/nutrition.dart` | Local meal-plan ideas, goal selection, session-only checklists, water counter, cautions, and references |
| `lib/cloud_access.dart` | Anonymous sign-in gate for cloud-only screens |
| `lib/error_reporter.dart` | Global uncaught-error reporting and copy/share screen |
| `lib/splash.dart` | Startup UI, Firebase initialization, and Firestore persistence |
| `lib/rig.dart` | Poses, animation frames, equipment hints, rig aliases, and canvas rendering |
| `lib/parts_data.dart` | Sprite dimensions and joint-pivot coordinates |
| `assets/rig/` | Character sprite parts loaded by `rootBundle` |
| `firestore.rules` | Authorization rules for `logs` and `sets` |

## Exercise and animation model | التمارين والحركة

`Ex` contains a stable `id`, Arabic display name, muscle group, equipment key, difficulty, ordered instructions, safety tip, and a conventional GIF asset path. The current 100 catalog entries are in `exercises`.

The renderer first looks up a direct key in `rigs`; if none exists, it looks up `exerciseRigAliases`. The alias reuses a related motion to provide a visual illustration for exercise variants. The detail page explicitly labels motion as illustrative, so written instructions remain authoritative. If neither key exists, `gifOf` falls back to the asset loader and an accessible placeholder.

`RStep` refers to `Ex.id`, plus repetitions and seconds. `reps == 0` represents a timed hold. `stepsOf` accepts newer Firestore documents with a `steps` array and older documents containing only `ids`; preserve this compatibility when evolving the document shape.

**Exercise IDs are persisted identifiers.** Renaming one can orphan saved sets and logs; add a migration or keep the existing ID.

## Firestore model and authorization | البيانات والصلاحيات

### `logs`

Documents written by the app contain `owner` (anonymous Firebase UID), `ex` (exercise ID), `reps`, `kg`, and `at` (server timestamp). Reads and deletes are restricted to the owner; creates require authentication and a valid repetitions field.

### `sets`

Documents contain `name`, `ids`, `steps` when available, `public`, `owner`, and `at`. Reads are allowed to the owner or to authenticated users for public documents; writes are owner-scoped according to [`firestore.rules`](../firestore.rules). The current UI creates private sets.

The Firestore rules are the security boundary. Do not rely on hidden buttons or client-side checks to protect records.

## Offline behavior | العمل دون اتصال

- The catalog, built-in routines/plans, and nutrition examples are bundled with the app.
- Firebase options must still be supplied and Firebase must initialize on app launch.
- First-time anonymous sign-in and cloud reads require a connection. After sign-in, Firestore persistence supports cached reads and pending writes.
- Nutrition selections, checkmarks, and the water counter are temporary widget state; they are not currently stored in Firestore or a local database.
- External nutrition references open in the system browser and require internet access.

## Extending the project | توسيع المشروع

- Add exercises to `lib/data.dart`; keep IDs unique and stable and add a direct rig or suitable alias.
- Add built-in timed routines with `Routine`/`RStep`; verify every referenced ID exists.
- Keep health content cautious, sourced, and consistent with the in-app medical notice.
- Review `PRIVACY.md` when introducing a new data field, analytics package, external service, or persisted user preference.
- The CI workflow generates Android/Windows platform projects because those generated folders are ignored by Git. Each push to `main` gets the next patch version and a GitHub Release; release workflows are queued to avoid duplicate versions. APK and Windows ZIP artifacts are built every time, while AAB output is conditional on signing secrets.

