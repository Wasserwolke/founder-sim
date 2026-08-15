# Architektur v0.5
Founder Sim trennt Privatperson, Gruenderrolle, Unternehmen und Aussenwelt.

Der Browser-Prototyp ist datengetrieben:
`scenes.json -> AssetRegistry -> Runtime Assets -> Hotspots`.

Texte kommen aus `locales/`, Spielwerte aus `data/`, Grafiken aus `assets/`.
Mods greifen ueber eine stabile API zu, nicht durch zufaellige DOM-Manipulationen.
