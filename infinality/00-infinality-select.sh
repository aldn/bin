#!/bin/sh
# Set the USE_STYLE variable below to try each example.
# Make sure to set your style in /etc/fonts/infinality.conf too.
#
# Possible options:
#
# DEFAULT       - Use above settings. A compromise that should please most people.
# OSX           - Simulate OSX rendering
# IPAD          - Simulate iPad rendering
# UBUNTU        - Simulate Ubuntu rendering
# LINUX         - Generic "Linux" style - no snapping or certain other tweaks
# WINDOWS       - Simulate Windows rendering
# WINDOWS7      - Simulate Windows rendering with normal glyphs
# WINDOWS7LIGHT - Simulate Windows 7 rendering with lighter glyphs
# WINDOWS       - Simulate Windows rendering
# VANILLA       - Just subpixel hinting
# CUSTOM        - Your own choice.  See below
# ----- Infinality styles -----
# CLASSIC       - Infinality rendering circa 2010.  No snapping.
# NUDGE         - CLASSIC with lightly stem snapping and tweaks
# PUSH          - CLASSIC with medium stem snapping and tweaks
# SHOVE         - Full stem snapping and tweaks without sharpening
# SHARPENED     - Full stem snapping, tweaks, and Windows-style sharpening
# INFINALITY    - Settings I use
# DISABLED      - Act as though running without the extra infinality enhancements (just subpixel hinting).

export USE_STYLE=VANILLA
