# AGENTS.md

## Project Overview

Project Exodus is a 2D industrial survival strategy game.

The player gathers limited planetary resources,
builds automated factories,
researches technology,
and launches a rocket to reach a nearby planet, then upgrades further to escape the solar system.

Core themes:
- scarcity
- industrial expansion
- environmental collapse
- survival through automation

---

# Tech Stack

Engine:
- Godot 4

Language:
- GDScript

Editor:
- VSCode

---

# Project Rules

- Keep systems simple.
- Avoid overengineering.
- Prioritize playable features over perfect architecture.
- Never introduce unnecessary abstractions.
- Keep scripts under 300 lines when possible.
- Prefer composition over inheritance.
- Use data-driven design for buildings and items.

---

# Coding Style

- snake_case naming
- descriptive variable names
- no magic numbers
- avoid deeply nested logic
- comment only complex systems

---

# Folder Rules

Scenes:
- /scenes

Scripts:
- /scripts

Game data:
- /data

Assets:
- /assets

---

# Gameplay Priorities

Highest priority:
1. Core gameplay loop
2. Responsiveness
3. Readability
4. Performance

Lower priority:
- visual polish
- particle effects
- advanced animations

---

# Forbidden Features (First Version)

Do NOT implement:
- multiplayer
- online systems
- procedural galaxies
- realistic physics simulation
- complex NPC AI
- space combat
- open world systems

---

# UI Rules

- Minimal UI
- High readability
- Avoid visual clutter
- Industrial aesthetic
- Dark muted colors

---

# Development Philosophy

Build small.
Finish systems completely.
Avoid endless refactoring.

A playable prototype is more valuable than ambitious unfinished systems.