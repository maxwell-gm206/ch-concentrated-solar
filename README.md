# Cheese's Concentrated Solar

![banner art](non_mod/banner.png)

This mod adds concentrated solar power to Factorio, in two components:

- **Heliostat Mirrors** - A mirror that rotates to send 110KW of solar power to the closest tower within their range of 35 tiles.
- **Solar Towers**
    - Including the Solar Power Tower, which turns solar energy into up to 60MW of heat.
    - The Solar Laser Tower, which concentrates solar energy into up to 60MW of solar devastation.

![banner art](non_mod/banner2.png)

## Performance

Most work is done on building placement and deletion, then each group of a single tower and all it's mirrors are updated at once, making this quite performant. For UPS oriented megabases this is clearly not the way for the same reason as nuclear power; fluid.

## Mod Compatibility

- **Glass** - adds glass and other ingredients to recipes when available.
- **K2** - 1.9 times power multiplier (changeable in settings), Tweaked crafting recipes (included glass, lithium-chloride, etc.).
- **Space Exploration** - Towers can be placed in space, requires space science.
