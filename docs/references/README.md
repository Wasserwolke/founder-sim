# Visual References

Canonical generated reference images can be stored here if desired.

The exact 2048x2048 Founder Sim object production grid is reproducible with:

```bash
python3 -m pip install -r requirements.txt
python3 scripts/generate_asset_grid.py
```

Generated file:
`docs/references/object_sheet_grid_2048.png`

Grid contract:
- WORLD: 896 px
- SPOT: 768 px
- ICON: 384 px
- 4 rows x 512 px

The importer does not depend on the object being perfectly centered inside a cell. It trims and recenters each detected object automatically.
