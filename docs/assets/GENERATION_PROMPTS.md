# Founder Sim - Compact Asset Generation Prompts

## Global Style Lock
```text
Create assets for one cohesive 2D pixel-art management game universe.
Modern detailed pixel art, crisp pixel clusters and stepped edges, grounded realistic proportions, cozy/moody/practical startup atmosphere, warm indoor light plus cool night/rain light, clear readable silhouettes, consistent pixel density/perspective/materials/scale. No photorealism, no 3D render, no painterly look, no anime/chibi, no primitive 8-bit look, no watermark.
Use supplied Founder Sim reference images as canonical style anchors.
For physical assets create the same exact design in WORLD, SPOT and ICON. Preserve colors, materials, shape and identifying details.
```

## Environment
```text
[GLOBAL STYLE LOCK]
CATEGORY: ENVIRONMENT
ENVIRONMENT: [ROOM / LOCATION]
TIER: [STARTER / EARLY GROWTH / ESTABLISHED / PREMIUM]
PURPOSE: [GAMEPLAY PURPOSE]
TIME: [DAY / EVENING / NIGHT]
WEATHER: [CLEAR / RAIN / SNOW / NONE]
WORLD = full playable environment
SPOT = clean room preview
ICON = simplified room/location icon
Keep reusable geometry and free surfaces for dynamic objects.
```

## Furniture
```text
[GLOBAL STYLE LOCK]
CATEGORY: FURNITURE
OBJECT: [ITEM]
TIER: [STARTER / STANDARD / PROFESSIONAL / PREMIUM]
MATERIAL: [MATERIAL / COLOR]
CONDITION: [NEW / USED / WORN]
WORLD = room-perspective asset
SPOT = clean product/detail view
ICON = simplified icon
Transparent background.
```

## Equipment
```text
[GLOBAL STYLE LOCK]
CATEGORY: EQUIPMENT
OBJECT: [ITEM]
MODEL: [MODEL / SHORT DESIGN]
TIER: [STARTER / STANDARD / PROFESSIONAL / PREMIUM]
FUNCTION: [GAMEPLAY PURPOSE]
CONDITION: [NEW / USED / WORN / DAMAGED]
WORLD = in-world equipment
SPOT = clean shop/detail view
ICON = simplified icon
Transparent background.
```

## Consumable
```text
[GLOBAL STYLE LOCK]
CATEGORY: CONSUMABLE
ITEM: [ITEM]
VARIANT: [TYPE / COLOR / QUALITY]
QUANTITY: [LOW / MEDIUM / HIGH / FULL]
WORLD = visible storage quantity state
SPOT = product/detail view
ICON = simplified inventory icon
Transparent background.
```

## Desk Object
```text
[GLOBAL STYLE LOCK]
CATEGORY: DESK OBJECT
OBJECT: [ITEM]
VARIANT: [COLOR / MATERIAL / DESIGN]
TIER: [STARTER / STANDARD / PREMIUM]
STATE: [IDLE / FULL / EMPTY / ACTIVE / USED]
WORLD = desk representation
SPOT = larger detail/shop view
ICON = simplified hotspot/UI icon
Transparent background.
```

## Vehicle
```text
[GLOBAL STYLE LOCK]
CATEGORY: VEHICLE
VEHICLE: [MAKE / MODEL / TYPE]
YEAR: [OPTIONAL]
COLOR: [COLOR]
CONDITION: [OLD / USED / GOOD / NEW]
ROLE: [PRIVATE / FIRST BUSINESS / CARGO / PREMIUM]
VIEW: 3/4 front-side
WORLD = in-world vehicle
SPOT = clean purchase/detail view
ICON = simplified vehicle/map icon
Transparent background.
```

## Map
```text
[GLOBAL STYLE LOCK]
CATEGORY: MAP
ASSET: [BASE MAP / DISTRICT / BUILDING / MARKER]
LOCATION TYPE: [HOME / CLIENT / HARDWARE STORE / BANK / TAX OFFICE / SUPPLIER / OTHER]
Prioritize gameplay readability and consistent map perspective.
WORLD = map/building asset
SPOT = larger preview
ICON = simplified marker
```

## UI
```text
[GLOBAL STYLE LOCK]
CATEGORY: UI
FUNCTION: [FINANCES / CLIENTS / HR / VEHICLE / STORAGE / MARKETING / TAX / SETTINGS / OTHER]
STATE: [DEFAULT / HOVER / ACTIVE / DISABLED / ALERT]
Strong silhouette, small-size readability, consistent pixel weight, no text unless requested.
```
