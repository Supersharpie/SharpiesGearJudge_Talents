# Sharpie's Gear Judge [Talents]

> ⚠️ **Experimental: WoW Forever is in beta.** Blizzard changes talents, spells and level caps often between beta builds, sometimes several times a week. The builds and stat weights in this plugin are updated to keep up, but there can be a short gap after each patch where a build is out of date or a talent has moved. If something looks wrong after a patch, please report it on the [Discord](https://discord.gg/aYmhmtGxYs).

**A talent build guide for WoW Forever, built into Sharpie's Gear Judge.**

Pick a build once and the plugin walks you from level 10 to 60. It tells you which talent to take each time you level, highlights it in the talent window, and makes Gear Judge's stat weights follow the build. The gear advice always matches the spec you're playing.

> Requires **Sharpie's Gear Judge**. Made for **WoW Forever** (it does nothing on Classic Era or TBC).

**See every build online:** [Forever Class Builds](https://sharpiesgearjudge.web.app) shows all the builds, class by class, with their talent order by level and the leveling stat weights Gear Judge uses. It's updated as builds change, so it can be a little ahead of the latest release.

---

## Features

- **Next-talent reminders.** Every level-up names the next talent to take, in chat and on screen.
- **Talent window highlight.** The next talent glows gold in the talent window. Every talent your build still puts points into shows a number on its icon: the step of its next point in the build (1 is your first point, 51 your last). Hover a numbered talent to see every step the build puts into it, with the level of each. A panel beside the window shows your progress, the next five talents with the level each is planned for, and any points spent outside the build.
- **Talent Builds page.** A page in the Gear Judge window with three columns:
  - **Your class's builds:** pick **Max Level** (raid builds), **Leveling**, **Farming** or **PvP** at the top, and every build for it is listed, grouped under **Tank**, **Healer** and **DPS**. Tags under each name show **Solo** or **Dungeon**, **Fastest** for your class's fastest solo build, **Experimental** for builds that come only from our model, and how much slower the other solo builds level. Your current build is marked **Active**.
  - **The build:** its spec icon, a bar showing how its points split between the three trees, what it's for and which stat weights it uses. For your active build, a progress bar shows how far along you are and the next talent with the level it's planned for.
  - **The talent order:** level by level, each talent with its icon and its tree's colour. Points you've spent are green, the next one gold, and the list scrolls to where you are.
- **Gear advice that follows your build.** Choosing a build tells Gear Judge which weight profile to use, from your first talent point to level 60. A Protection tank build gets tank weights right away, before its tank talents would normally switch you over.
- **Dual Specialization.** From level 40 each spec keeps its own build. The talent window highlight follows the Primary or Secondary tab you're viewing, and the Builds page lets you pick a build for either spec.
- **Every build is checked** against WoW Forever's current talent trees: one point per level from 10, tier requirements, talents that need another talent at full rank first (the arrows in the tree), minimum levels and maximum ranks. Every build can be learned in game in the order shown.

---

## Builds

Every talent tree has a **Solo Leveling** and a **Dungeon Leveling** build (Warlocks have Affliction builds for now). Each one starts in its own tree at level 10, so you never pay for a respec while leveling. Leveling builds are ranked by how fast they get you to 60 in Gear Judge's leveling models, checked against beta combat logs where there are any.

Where a class has more than one solo build, the fastest is tagged **(Fastest)** and the others say how much slower they level. **(Experimental)** builds are what our model rates best, but nobody has tried them in game yet.

### Leveling

| Class | Solo Leveling | Dungeon Leveling |
|---|---|---|
| Warrior | **Arms (Fastest)**, Fury, Protection | Arms, Fury, Protection (tank) |
| Paladin | **Protection (Fastest)**, Retribution, Holy | Retribution, Protection (tank), Holy (healer) |
| Rogue | **Subtlety (Fastest)**, Combat, Assassination | Combat, Assassination, Subtlety |
| Hunter | **Survival (Fastest, melee)**, Beast Mastery, Marksmanship | Beast Mastery, Marksmanship, Survival (melee) |
| Mage | **Frost: AoE Leveling (Fastest)**, Frost, Arcane, Fire | Arcane, Frost, Fire |
| Priest | **Discipline (Fastest)**, Shadow, Shadow (No Shadowform) **(Experimental)**, Holy | Shadow, Holy (healer), Discipline (healer) |
| Warlock | Affliction | Affliction |
| Shaman | **Enhancement (Fastest)**, Elemental, Restoration | Enhancement, Elemental, Restoration (healer), Tank (shield) |
| Druid | **Feral Cat (Fastest)**, Balance, Restoration | Cat, Balance, Restoration (healer), Bear (tank) |

### Max Level and Farming

| Class | Max Level (Raid) | Farming |
|---|---|---|
| Warrior | Arms, Protection (tank) | Protection: AoE Farming |
| Paladin | Retribution, Holy (healer), four Protection tanks: Vanguard, Bulwark, Bastion, Arbiter | Protection: AoE Farming |
| Rogue | Combat | |
| Hunter | Beast Mastery | |
| Mage | Frost | Frost: AoE Farming |
| Priest | Shadow, Holy (healer), Discipline (healer) | Shadow: Multi-DoT Farming |
| Warlock | Demonology (Demonic Pact) | Demonology: AoE Farming |
| Shaman | Enhancement, Elemental, Restoration (healer) | Tank: AoE Farming |
| Druid | Cat, Balance (Moonkin), Restoration (healer), Bear (tank) | |

The four **Paladin** raid tanks:
- **Vanguard (Raid):** the recommended raid tank: the most threat and the least damage taken in the simulator.
- **Bulwark (Long Fights):** cheaper seals, Judgements and Consecration for fights long enough to run Vanguard out of mana.
- **Bastion (Max Prot):** every Protection talent.
- **Arbiter (Holy Strike):** Judgement and Holy Strike focused.

### PvP builds

For open-world PvP while leveling and battlegrounds at 60. Each one is a full talent order from 10 to 60, with the control and survival talents placed as early as the talent tree allows (most land by level 30). Picking a PvP build also switches Gear Judge to its PvP weights at every level: Stamina, armor and burst count for more, and hit stops at the player-vs-player caps. These builds come from the talent data and a PvP model, not a simulator, since there's no sim for fights against players.

| Class | PvP builds |
|---|---|
| Warrior | Arms (Mortal Strike) |
| Paladin | Retribution, Reck-Bomb (Reckoning stores up to 4 extra attacks for one big hit), Shockadin (Holy Shock) |
| Rogue | Hemorrhage (swords or maces), Cold Blood Daggers |
| Hunter | Marksmanship Utility (Scatter Shot, traps, Deterrence) |
| Mage | Frost (Shatter, Ice Lance, Ice Block) |
| Priest | Shadow, Discipline Healer |
| Warlock | Soul Link, Nightfall / Conflagrate |
| Shaman | Elemental, Restoration Healer |
| Druid | Feral (Cat), Restoration Healer |

---

## Commands

| Command | What it does |
|---|---|
| `/sgjt` | Show the build panel |
| `/sgjt list` | List your class's builds, grouped the same way |
| `/sgjt set <name>` | Choose a build, e.g. `/sgjt set solo` or `/sgjt set bulwark` |
| `/sgjt next` | Show the next talent to take |
| `/sgjt clear` | Stop following a build |
| `/sgjt link on/off` | Turn whether Gear Judge's weights follow the build on or off |
| `/sgjt remind on/off` | Turn the level-up reminders on or off |

You can also do all of this from the **Talent Builds** page in the Gear Judge window (`/sgj`).

---

## Good to know

- **Works in every WoW Forever language.** Build names, notes and talent names are translated into German, Spanish (Spain and Latin America), French, Brazilian Portuguese, Russian, Korean and Traditional Chinese, and talent names match what your game client shows.
- **Builds plan one point per level from 10.** If your character gets talent points earlier (such as from WoW Forever's Legacy Talented perk), keep following the build's order: you'll just reach each step sooner than the level shown.
- **Your choices stay yours.** If you spend points outside the build, the plugin lists them and keeps guiding you through the rest.

---

## Feedback

Found a bug, think a build could be faster, or want a build for your playstyle? Come say hi on the **[Discord](https://discord.gg/aYmhmtGxYs)**.
