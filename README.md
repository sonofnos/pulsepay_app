# PulsePay

Flutter client for [pulsepay-api](https://github.com/sonofnos/pulsepay-api).
Covers the whole API surface rather than a single demo screen: auth, wallet
balances and transfers, a P2P crypto market with the full escrow flow
(initiate, confirm payment, release, or cancel), and bill payment.

Riverpod for state, one `Notifier`/`AsyncNotifier` per API resource (auth,
wallets, p2p offers, p2p trades, bill payments), GoRouter for navigation and
deep links, Dio for networking.

## Layout

```
lib/
  core/        api_client, secure_storage, money formatting, notifications
  providers/   one Notifier per API resource
  features/    auth/ wallet/ p2p/ bills/
  router.dart  auth-gated redirects + deep-link routes
```

## Deep links and notifications

`pulsepay://app/p2p/trades/{id}` resolves through GoRouter to the trade
detail screen, wired into both the Android intent-filter and iOS
`CFBundleURLTypes`. `flutter_local_notifications` fires on trade/bill-payment
status changes. It's a stand-in for push (`show()` is the call an FCM/APNs
handler would make once a real push backend exists), not a fake: on a real
device it produces a real system notification.

## Running

```bash
# backend first
cd ../pulsepay-api && docker compose up -d && php artisan serve --port=8123

cd ../pulsepay_app
flutter pub get
flutter run --dart-define=PULSEPAY_API_BASE_URL=http://127.0.0.1:8123/api
```

Defaults to `127.0.0.1:8123` on iOS/web and `10.0.2.2:8123` on the Android
emulator if you skip the dart-define.

```bash
flutter analyze
flutter test
```

## Bugs this caught

`AuthNotifier._restoreSession()` called `SecureStorage.readToken()` outside
its try/catch. A storage failure (missing platform channel, locked keychain,
anything) threw unhandled, and since nothing ever set `state` afterward, the
app sat on the loading spinner forever instead of crashing or recovering. A
widget test that never got past the spinner is what surfaced it. The fix was
just moving the read inside the same try/catch as everything else.

Requesting notification permission at launch, before the user's done
anything, is bad practice on both platforms, and in this build environment
it also meant a pending system permission sheet blocked the UI with no way
to dismiss it. Permission is now requested lazily on first `show()` call
instead.

Xcode's simulator floor moved to iOS 15. `flutter create` still scaffolds a
13.0 deployment target, so the build failed until `Podfile` and
`Runner.xcodeproj` were both bumped. `flutter_local_notifications` v22 also
switched `initialize()`/`show()` to named parameters, caught by `flutter
analyze`, not at runtime.

## Verified, with one caveat

`flutter analyze` is clean, `flutter test` passes, and the app actually
builds and runs on a real iOS Simulator against the live backend. The system
notification-permission dialog showing up confirms the native integration is
real. What I couldn't do: interactive tap-through in this particular build
environment, which has no GUI simulator window and no `idb`. The business
logic behind every screen is the same logic already verified end-to-end
against the live API, see pulsepay-api's test suite and
`concurrency_demo.sh`.
