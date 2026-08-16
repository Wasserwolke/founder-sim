# Founder Sim - Asset Generation Prompts

Diese Datei ist die kanonische Prompt-Grundlage fuer alle Founder-Sim-Assets. Alte Einzel-Promptdateien werden hier konsolidiert, damit es nur eine gepflegte Quelle gibt.

## Global Style Lock
```text
FOUNDER SIM STYLE LOCK

Create assets for one cohesive 2D pixel-art management game universe.

STYLE:
- modern detailed pixel art
- crisp pixel clusters and stepped edges
- readable silhouettes
- grounded realistic proportions
- cozy but practical small-business atmosphere
- warm indoor light + cool night/rain light where appropriate
- slightly moody startup feeling
- consistent pixel density, perspective, materials, scale, contrast and saturation
- no painterly look
- no photorealism
- no 3D-render look
- no chunky primitive 8-bit style
- no anime/chibi look
- no random decorative clutter
- no watermark
- no branding unless explicitly requested

CONSISTENCY:
Use supplied Founder Sim reference images as canonical style anchors.
WORLD, SPOT and ICON must depict the same exact design and preserve colors,
materials, shape and identifying details.
Do not add text inside an asset unless explicitly requested.
Use transparent backgrounds for isolated assets.
```

## Output Package
For physical assets create, when applicable:
- `WORLD` = representation used inside the game world
- `SPOT` = larger clean shop/detail/selection representation
- `ICON` = simplified small UI/inventory/menu representation

## Environment
```text
[GLOBAL STYLE LOCK]
CATEGORY: ENVIRONMENT
ENVIRONMENT: [ROOM / LOCATION]
TIER: [STARTER / EARLY GROWTH / ESTABLISHED / PREMIUM]
PURPOSE: [WHAT THE PLAYER DOES HERE]
TIME: [DAY / EVENING / NIGHT]
WEATHER: [CLEAR / RAIN / SNOW / NONE]

REQUIREMENTS:
- stable reusable geometry
- fixed gameplay camera where appropriate
- readable free surfaces for dynamic objects and hotspots
- economic status may be visible through room size, materials and view
- do not permanently bake dynamic inventory into reusable backgrounds
- no characters unless explicitly requested

WORLD = full playable environment
SPOT = clean room preview
ICON = simplified room/location icon
```

## Furniture
```text
[GLOBAL STYLE LOCK]
CATEGORY: FURNITURE
OBJECT: [ITEM]
TIER: [STARTER / STANDARD / PROFESSIONAL / PREMIUM]
MATERIAL: [MATERIAL / COLOR]
CONDITION: [NEW / USED / WORN / PREMIUM]

REQUIREMENTS:
- believable physical dimensions
- match Founder Sim room perspective
- visually communicate quality tier
- reusable modular asset
- no surrounding room
- transparent background

WORLD = room-perspective asset
SPOT = clean product/detail view
ICON = simplified furniture icon
```

## Equipment
```text
[GLOBAL STYLE LOCK]
CATEGORY: EQUIPMENT
OBJECT: [ITEM]
MODEL / DESIGN: [MODEL OR SHORT DESCRIPTION]
TIER: [STARTER / STANDARD / PROFESSIONAL / PREMIUM]
FUNCTION: [GAMEPLAY PURPOSE]
CONDITION: [NEW / USED / WORN / DAMAGED]

REQUIREMENTS:
- realistic functional parts
- readable at gameplay scale
- isolated reusable asset
- transparent background
- keep screen areas clean for dynamic UI overlays where relevant

WORLD = in-world equipment
SPOT = clean shop/detail view
ICON = simplified inventory/shop icon
```

## Consumable
```text
[GLOBAL STYLE LOCK]
CATEGORY: CONSUMABLE
ITEM: [ITEM]
VARIANT: [TYPE / COLOR / SIZE / QUALITY]
QUANTITY STATE: [LOW / MEDIUM / HIGH / FULL]

REQUIREMENTS:
- clear readable quantity state
- same footprint and angle across quantity variants
- suitable for shelf/crate/storage placement
- transparent background

WORLD = visible storage quantity state
SPOT = product/detail view
ICON = simplified inventory icon
```

## Desk Object
```text
[GLOBAL STYLE LOCK]
CATEGORY: DESK OBJECT
OBJECT: [ITEM]
VARIANT: [COLOR / MATERIAL / DESIGN / QUALITY]
TIER: [STARTER / STANDARD / PREMIUM]
STATE: [IDLE / FULL / EMPTY / ACTIVE / NOTIFICATION / USED]

REQUIREMENTS:
- small interactive hotspot object
- clear silhouette
- match desk perspective
- no surrounding desk
- transparent background

WORLD = desk representation
SPOT = larger detail/shop view
ICON = simplified hotspot/UI icon
```

## Vehicle
```text
[GLOBAL STYLE LOCK]
CATEGORY: VEHICLE
VEHICLE: [MAKE / MODEL / TYPE]
YEAR / GENERATION: [OPTIONAL]
COLOR: [COLOR]
CONDITION: [OLD / USED / GOOD / NEW]
ROLE: [PRIVATE / FIRST BUSINESS / CARGO / PREMIUM]
VIEW: [3/4 FRONT-SIDE / SIDE]

REQUIREMENTS:
- grounded real-world proportions
- recognizable body type
- communicate age, cargo capacity and quality
- no driver
- no full surrounding environment
- transparent background

WORLD = in-world vehicle
SPOT = purchase/detail view
ICON = vehicle/map icon
```

## Map
```text
[GLOBAL STYLE LOCK]
CATEGORY: MAP
ASSET: [BASE MAP / DISTRICT / BUILDING / MARKER]
LOCATION TYPE: [HOME / CLIENT / HARDWARE STORE / BANK / TAX OFFICE / SUPPLIER / FUEL / OTHER]

REQUIREMENTS:
- gameplay readability first
- consistent map perspective and scale
- no permanent route unless requested
- no permanent text label unless requested

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

REQUIREMENTS:
- simple strong silhouette
- readable at small size
- consistent pixel weight
- minimal detail
- no text unless requested
- transparent background
```

## Naming
```text
[item_id]_world.png
[item_id]_spot.png
[item_id]_icon.png
```

Examples:
```text
coffee_starter_white_world.png
coffee_starter_white_spot.png
coffee_starter_white_icon.png

vacuum_starter_basic_world.png
vacuum_starter_basic_spot.png
vacuum_starter_basic_icon.png
```

## Concrete Reference Prompts
These four prompts are retained from the original asset-generation notes as style references.

### Starter Desk Room
```text
Create a 3-panel Founder Sim pixel-art reference sheet in modern detailed pixel art. Show the same asset in three columns: WORLD, SPOT, ICON. Asset: starter founder desk room at night. WORLD: a front-facing playable small apartment office with large dual monitors, warm desk lamp, rain outside the window, city lights, modest furniture, clean logical surfaces, no characters. SPOT: a framed upgrade/shop preview of the same room. ICON: a simplified room icon. Cozy startup vibe, grounded realistic proportions, crisp pixel art, dark UI presentation.
```

### Startup Desk Set
```text
Create a 3-panel Founder Sim pixel-art reference sheet in modern detailed pixel art. Show the same furniture asset in three columns: WORLD, SPOT, ICON. Asset: startup desk set. WORLD: the desk set placed in a cozy founder room, including wooden desk, office chair, monitor, keyboard, mouse, small drawer unit, notebook and small plant. SPOT: a clean isolated shop/detail preview of the same desk set. ICON: a simplified furniture icon. Grounded realistic proportions, crisp pixel art, practical startup atmosphere, dark UI presentation.
```

### First Cleaning Company Van
```text
Create a 3-panel Founder Sim pixel-art reference sheet in modern detailed pixel art. Show the same vehicle asset in three columns: WORLD, SPOT, ICON. Asset: first cleaning-company van. WORLD: a small white cargo van in a street scene outside a cleaning business. SPOT: a clean isolated detail/shop preview of the same van in 3/4 view. ICON: a simplified small vehicle icon. Grounded real-world proportions, readable silhouette, practical business look, crisp pixel art, dark UI presentation.
```

### Cheap Coffee Mug
```text
Create a 3-panel Founder Sim pixel-art reference sheet in modern detailed pixel art. Show the same desk object in three columns: WORLD, SPOT, ICON. Asset: cheap coffee mug. WORLD: a white ceramic mug with a thin blue stripe, filled with hot coffee, sitting on a founder desk near notebook and keyboard. SPOT: a clean isolated close-up preview of the same mug. ICON: a simplified small mug icon. Cozy startup vibe, crisp pixel art, grounded proportions, dark UI presentation.
```
