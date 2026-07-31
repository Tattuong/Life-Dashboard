# DayPlanner Pro

Quản lý công việc, lịch hẹn và mục tiêu hằng ngày — giao diện Navy & White, hiện đại.

## Application ID

`com.dayplannerpromng.dayplannerpro`

## Google Play IAP Products

| Product | ID | Type |
|---------|-----|------|
| Star pack 1–10 | `dpp_pack_1` … `dpp_pack_10` | Consumable |
| Remove ads | `dpp_remove_ads` | Non-consumable |

Remote IAP config: `https://api2.blwsmartware.net/N215.json`

When `disable=1`, Google Billing UI is hidden; the shop remains available for star purchases.

See `docs/iap_products.json` for the management JSON template.

## Features

- Home: greeting, today's schedule, completion %, priority & upcoming tasks
- Task manager: CRUD, priority, due dates, notes, categories, reminders
- Calendar: day / week / month views
- Statistics: completed tasks, streak, productivity chart
- Goals: weekly/monthly targets with progress
- Shop: earn stars or buy packs; unlock themes, backgrounds, skins, features

## Build

```bash
flutter pub get
python3 tool/generate_logo.py
dart run flutter_launcher_icons
flutter build appbundle --release
```

## Logo

Square 1024×1024 PNG at `assets/logo.png` (no rounded corners on the logo file itself).
