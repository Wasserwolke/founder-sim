# Founder Sim - Compact Asset Prompt Set v1.0

## 0. GLOBAL STYLE LOCK
Use this block at the top of EVERY asset prompt.

```text
FOUNDER SIM STYLE LOCK

Create assets for one cohesive 2D pixel-art management game universe.

STYLE:
- modern detailed pixel art
- crisp pixel clusters and stepped edges
- readable silhouettes
- grounded realistic proportions
- cozy but practical small-business atmosphere
- warm indoor light + cool night light where appropriate
- slightly moody startup feeling
- no painterly look
- no photorealism
- no 3D-render look
- no chunky primitive 8-bit style
- no anime/chibi look
- no random decorative clutter
- no watermark
- no branding unless explicitly requested

CONSISTENCY:
Match the supplied canonical Founder Sim references in:
- pixel density
- perspective
- material rendering
- contrast
- saturation
- lighting
- scale
- edge treatment
- overall atmosphere

CANONICAL REFERENCES:
A = Starter desk scene
B = Storage room scene
C = Premium penthouse desk scene

OUTPUT PACKAGE:
Generate the requested asset as one coherent 3-part set:
1. WORLD = object/environment as used inside the game world
2. SPOT = larger clean selection/shop/detail representation
3. ICON = simplified small UI/inventory/menu representation

RULES:
- WORLD and SPOT must clearly depict the same exact design
- ICON must be a simplified version of the same design
- keep colors, materials and identifying features consistent across all 3 outputs
- no text inside the asset unless explicitly requested
- use transparent background for isolated assets
- environments may use a full background
```

## 1. ENVIRONMENT
Use for: rooms, apartment, office, storage room, garage, warehouse, premium office, new home stage.

```text
[GLOBAL STYLE LOCK]

CATEGORY: ENVIRONMENT

ENVIRONMENT:
[ROOM / LOCATION]

PROGRESSION TIER:
[STARTER / EARLY GROWTH / ESTABLISHED / PREMIUM]

PURPOSE:
[WHAT THE PLAYER DOES HERE]

TIME:
[DAY / EVENING / NIGHT]

WEATHER:
[CLEAR / RAIN / SNOW / NONE]

REQUIREMENTS:
- fixed front-facing gameplay camera
- stable reusable geometry
- readable empty surfaces for dynamic objects
- economic status visible through room size, furniture quality, materials and view
- do not permanently fill shelves/desks with inventory that should change dynamically
- no characters
- leave clear hotspot areas

OUTPUTS:
WORLD = full playable environment scene
SPOT = clean room preview for selection/upgrade screen
ICON = simplified room/location icon
```

## 2. FURNITURE
Use for: desk, chair, shelf, bed, cabinet, lamp, sofa, table.

```text
[GLOBAL STYLE LOCK]

CATEGORY: FURNITURE

OBJECT:
[FURNITURE ITEM]

TIER:
[STARTER / STANDARD / PROFESSIONAL / PREMIUM]

MATERIAL:
[MATERIAL / COLOR]

CONDITION:
[NEW / USED / WORN / PREMIUM]

REQUIREMENTS:
- believable physical dimensions
- match Founder Sim room perspective
- visually communicate price/quality tier
- reusable modular asset
- no surrounding room
- transparent background

OUTPUTS:
WORLD = furniture placed in room perspective
SPOT = clean larger product/detail view
ICON = simplified furniture icon
```

## 3. EQUIPMENT
Use for: vacuum, printer, computer, monitor, cleaning machine, tool case, mop system, office device.

```text
[GLOBAL STYLE LOCK]

CATEGORY: EQUIPMENT

OBJECT:
[EQUIPMENT]

MODEL / DESIGN:
[MODEL OR SHORT DESCRIPTION]

TIER:
[STARTER / STANDARD / PROFESSIONAL / PREMIUM]

FUNCTION:
[GAMEPLAY PURPOSE]

CONDITION:
[NEW / USED / WORN / DAMAGED]

REQUIREMENTS:
- realistic functional parts
- clear quality difference by tier
- match Founder Sim world perspective
- readable at gameplay scale
- isolated asset
- transparent background
- if it has a screen, keep the screen area clean for dynamic UI overlay

OUTPUTS:
WORLD = in-world equipment asset
SPOT = larger clean shop/detail asset
ICON = simplified inventory/shop icon
```

## 4. CONSUMABLES
Use for: cleaner, gloves, cloths, paper, trash bags, sponges, refill products.

```text
[GLOBAL STYLE LOCK]

CATEGORY: CONSUMABLE

ITEM:
[CONSUMABLE]

VARIANT:
[TYPE / COLOR / SIZE / QUALITY]

QUANTITY STATE:
[LOW / MEDIUM / HIGH / FULL]

REQUIREMENTS:
- clear readable quantity state
- same footprint and angle across quantity variants
- suitable for shelf/crate/storage placement
- transparent background
- no surrounding room

OUTPUTS:
WORLD = visible storage-world quantity state
SPOT = clean product/detail representation
ICON = simplified inventory icon
```

## 5. DESK OBJECTS
Use for: coffee mug, phone, keys, notebook, pen, wallet, calculator, small plant, alarm clock.

```text
[GLOBAL STYLE LOCK]

CATEGORY: DESK OBJECT

OBJECT:
[OBJECT]

VARIANT:
[COLOR / MATERIAL / DESIGN / QUALITY]

TIER:
[STARTER / STANDARD / PREMIUM]

STATE:
[IDLE / FULL / EMPTY / ACTIVE / NOTIFICATION / USED]

REQUIREMENTS:
- small interactive hotspot object
- clear silhouette
- match desk perspective
- no surrounding desk
- transparent background
- same exact design across all outputs

OUTPUTS:
WORLD = object as seen on the desk
SPOT = larger clean interactive/shop view
ICON = simplified UI/hotspot icon
```

## 6. VEHICLES
Use for: car, van, wagon, transporter, company vehicle.

```text
[GLOBAL STYLE LOCK]

CATEGORY: VEHICLE

VEHICLE:
[MAKE / MODEL / VEHICLE TYPE]

YEAR / GENERATION:
[OPTIONAL]

COLOR:
[COLOR]

CONDITION:
[OLD / USED / GOOD / NEW]

ROLE:
[PRIVATE CAR / FIRST BUSINESS CAR / CARGO VAN / PREMIUM VEHICLE]

VIEW:
[3/4 FRONT-SIDE / SIDE]

REQUIREMENTS:
- grounded real-world proportions
- recognizable body type
- visually communicate age, cargo capacity and quality
- no driver
- no full environment
- transparent background

OUTPUTS:
WORLD = vehicle for travel/map/garage scene
SPOT = larger clean vehicle purchase/detail view
ICON = simplified vehicle/map icon
```

## 7. MAP
Use for: city map, district, building marker, client location, hardware store, bank, tax office, supplier.

```text
[GLOBAL STYLE LOCK]

CATEGORY: MAP

ASSET:
[BASE MAP / DISTRICT / BUILDING / LOCATION MARKER]

LOCATION TYPE:
[HOME / CLIENT / HARDWARE STORE / BANK / TAX OFFICE / SUPPLIER / FUEL / OTHER]

CITY / AREA:
[OPTIONAL]

REQUIREMENTS:
- gameplay readability first
- consistent map perspective and scale
- clear roads/areas if base map
- clear silhouette if marker/building
- no permanent route unless requested
- no permanent text label unless requested

OUTPUTS:
WORLD = map asset or location building/marker
SPOT = larger location preview/detail image
ICON = simplified map marker icon
```

## 8. UI
Use for: menu icon, inventory icon, status icon, button symbol, category symbol, notification symbol.

```text
[GLOBAL STYLE LOCK]

CATEGORY: UI

FUNCTION:
[FINANCES / CLIENTS / HR / VEHICLE / STORAGE / MARKETING / TAX / SETTINGS / OTHER]

SYMBOL IDEA:
[OPTIONAL]

STATE:
[DEFAULT / HOVER / ACTIVE / DISABLED / ALERT]

REQUIREMENTS:
- simple strong silhouette
- readable at small size
- consistent pixel weight
- minimal detail
- no text unless explicitly requested
- transparent background

OUTPUTS:
WORLD = optional larger UI panel symbol if needed
SPOT = medium UI/category symbol
ICON = final small menu/status icon
```

## QUICK USE
Copy only:
1. GLOBAL STYLE LOCK
2. one category block
3. replace bracket values

Example request:

```text
CATEGORY: DESK OBJECT
OBJECT: ceramic coffee mug
VARIANT: cheap white mug with thin blue stripe
TIER: STARTER
STATE: FULL
```

The generation should return:
- WORLD coffee mug
- SPOT coffee mug
- ICON coffee mug

## FILE NAMING
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

vacuum_basic_01_world.png
vacuum_basic_01_spot.png
vacuum_basic_01_icon.png
```
