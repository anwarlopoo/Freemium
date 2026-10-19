# NW Hub — Free

Scripts gratuits, sans cle. Loadstring client :

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/anwarlopoo/Freemium/refs/heads/main/FreemiumLoader"))()
```

Le loader detecte le jeu et charge le fichier correspondant :

- `games/slayers2.lua`
- `games/slayers2_dungeon.lua`
- `games/the_veil.lua`
- `games/arcane_lineage.lua`
- `games/rh2.lua`
- `games/coldwar.lua`
- `games/bloxstrike.lua`
- `games/forgotten_stories.lua`
- `games/clover_time.lua`
- `games/dahood.lua`
- `games/morioh_high.lua`
- `games/ttk.lua`
- `games/stand_out.lua`
- `games/hollow.lua`

Pas de version free (paid only) : aba, bloodlines, deepwoken.

---

## Update Log

### [SPIN] Morioh High — Update v2.0
- **Universal Multi-Layer Stand Auto-Parry**:
  - Full coverage for **all 15 Stands** (Gold Experience, The World, Silver Chariot, Star Platinum, Crazy Diamond, Whitesnake, Wonder of U, TWOH, Sticky Fingers, The Hand, Soft & Wet, King Crimson, Cream, SPTW, D4C) and custom skins.
  - Added multi-layer detection: `StandController.Active.Visuals`, `Workspace.StandVisuals.ChildAdded` (FX parts), Stand model animators, and incoming `StandMoveRequest` packets.
  - Zero-latency continuous barrage parry (`0.05s` interval + instant `NextParryTime = 0` miss wipe) to guard and parry every hit of a barrage without guard breaks.
- **Spin & Hamon Auto-Parry**:
  - Added dedicated parry toggles for Spin moves (Steel Ball Throw, Blender) and Hamon moves (Slam, Overdrive).
  - High-frequency steel ball and projectile trajectory tracking in `Workspace.SpinEffects` and `Workspace.HamonEffects`.
- **QTE & Exam Solver Unstuck Fix**:
  - Fixed player freeze after passing class mini-games and sports QTEs.
  - Explicitly restores Roblox `PlayerModule:GetControls():Enable()`, releases `ContextActionService` key bindings (`ClassGameKeys`, `SportsAction`), resets character attributes (`InSport`, `ClassGame`), and clears invisible `Desk.Modal` cursor locks.
- **Stand Arrow Auto-Tween & Notifier**:
  - Clean linear tween navigation to newly spawned Stand Arrows on the map with automatic pickup on arrival.
  - In-game notification banner alerts when rare items or arrows spawn.
- **Movement & Utilities Overhaul**:
  - Cleaned up obsolete infinite jump (game has fixed jump physics).
  - WalkSpeed boost hooked directly into `MovementSpeedController` with smooth CFrame offset fallback.
  - 100% win solver for `BarrageClash` QTEs.

### Arcane Lineage
- **Status Hold**: Script kept on hold with stable Halloween story & pumpkin routine per instructions.

