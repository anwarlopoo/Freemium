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
```diff
+ Universal Stand Parry: Auto-parries all 15 Stands barrages & skills (GE, TW, SC, SP, CD, WS, WoU, TWOH, SF, The Hand, S&W, KC, Cream, SPTW, D4C)
+ Continuous Barrage Defense: 0.05s parry loop with instant miss-cooldown wiping to block every barrage hit without guard break
+ Spin & Hamon Defense: Auto-parries Steel Ball Throw, Blender, Hamon Slam and Overdrive with projectile trajectory tracking
+ Exam & Class QTE Unstuck Fix: PlayerModule controls explicitly re-enabled, Desk.Modal focus cleared, and CAS key bindings released upon passing
+ Stand Arrow Auto-Tween: Instant smooth navigation to newly spawned Stand Arrows with automatic grab
+ Stand Arrow Notifier: In-game Kyoka banner alerts when rare items or arrows appear on the map
+ Stand Clash 100% Win: Frame-perfect QTE solver for BarrageClash minigames
- Infinite Jump: Removed obsolete jump multiplier (incompatible with custom game gravity)
```

### Arcane Lineage — Anti-Ban & Safeguards Update
```diff
+ Adonis AntiCheat Bypass: Complete hook on Detected and Kill methods + debug.info sanity check neutralization
+ Tree & Obstacle Noclip Safeguard: Active directional raycasting disables collisions on trees, trunks, branches, rocks, and foliage during tweens
+ Anti-Clipping Velocity Tuning: Reduced horizontal cruise speed (24 studs/s) and descent speed (18 studs/s) under server threshold
+ Max Height Adjustment: Capped flight ceiling at 780 studs to prevent sky-limit and void-detection flags
+ Physics Spike Prevention: Controlled BodyVelocity MaxForce (4e5) preventing rubberbanding and collision ban triggers
+ Character Collision Control: Automatic full noclip while airborne with clean ground re-enable on arrival
```

