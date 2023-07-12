# SWX1-Klipper-Waggster

Klipper config files for a Sidewinder X1 running the Waggster BLTouch mod

This is a setup for multiple printers, where a script sets up each printer's config folder. 
To make it work for 1, there are changes that need to be made. 
- Set the MCU ID
- Install KAMP and & follow their guide

## Printer Mods / Changes

- BLTouch by Waggster -> https://www.thingiverse.com/thing:3716043 (not using the bracket)
- BLTouch bracket from Ethereal Project 3D: https://than.gs/m/378090
- Removed Z-axis sync belt (Z-TILT is used to keep them synced)
- Filament runout sensor connected to X+ (wire must be moved)

## Notes

Printer will only probe the area of the print (not full bed).
