# BabyCare Notes — Google Play IAP Products

**Application ID:** `com.babycarenotesmng.babycarenotes`  
**Remote config URL:** https://api2.blwsmartware.net/N216.json

## Remote config (`disable` field)

- `disable=0` → Google Billing enabled (coin purchase popup visible)
- `disable=1` → Hide Google Billing UI; shop still works with stars earned in-app

## Consumable coin packs (10 products)

| Product ID   | Stars |
|-------------|-------|
| bcn_pack_1  | 50    |
| bcn_pack_2  | 100   |
| bcn_pack_3  | 200   |
| bcn_pack_4  | 350   |
| bcn_pack_5  | 500   |
| bcn_pack_6  | 750   |
| bcn_pack_7  | 1000  |
| bcn_pack_8  | 1500  |
| bcn_pack_9  | 2200  |
| bcn_pack_10 | 3000  |

## One-time purchase

| Product ID      | Description   |
|----------------|---------------|
| bcn_remove_ads | Remove ads    |

Create these exact product IDs in Google Play Console → Monetize → Products.
