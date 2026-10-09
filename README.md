# Sharpie's Gear Judge [Talents]

> ⚠️ **Experimental: WoW Forever is in beta.** Blizzard changes talents, spells and level caps often between beta builds, sometimes several times a week. The builds and stat weights in this plugin are updated to keep up, but there can be a short gap after each patch where a build is out of date or a talent has moved. If something looks wrong after a patch, please report it on the [Discord](https://discord.gg/aYmhmtGxYs).

**A talent build guide for WoW Forever, built into Sharpie's Gear Judge.**

Pick a build once and the plugin walks you from level 10 to 60. It tells you which talent to take each time you level, highlights it in the talent window, and makes Gear Judge's stat weights follow the build. The gear advice always matches the spec you're playing.

> Requires **Sharpie's Gear Judge**. Made for **WoW Forever** (it does nothing on Classic Era or TBC).

---

## Features

- **Next-talent reminders.** Every level-up names the next talent to take, in chat and on screen.
- **Talent window highlight.** The next talent glows in the talent window. A panel beside the window shows your progress, the next five talents with the level each is planned for, and any points spent outside the build.
- **Talent Builds page.** A new page in the Gear Judge window lists your class's builds, sorted by what you're doing: **Max Level** (raid builds), **Leveling**, **Farming** or **PvP**, then **Tank**, **Healer** or **DPS**, then **Solo** or **Dungeon** for leveling builds. The role and Solo/Dungeon buttons show how many builds they hold. Click a build to see:
  - what it's for;
  - which stat weights it uses;
  - the full level-by-level talent order, with points you've spent in green and the next one in gold.
- **Gear advice that follows your build.** Choosing a build tells Gear Judge which weight profile to use, from your first talent point to level 60. A Protection tank build gets tank weights right away, before its tank talents would normally switch you over.
- **Dual Specialization.** From level 40 each spec keeps its own build. The talent window highlight follows the Primary or Secondary tab you're viewing, and the Builds page lets you pick a build for either spec.
- **Planned respecs.** Some builds switch spec partway through. At that level you're told to reset your talents. Once you have, the guide and the weights move to the new spec.
- **Every build is checked** against WoW Forever's current talent trees: one point per level from 10, tier requirements, minimum levels and maximum ranks.

---

## Builds

Every class has a **Solo Leveling** build. It's the fastest way to level alone without being a glass cannon: each spec was compared on kill speed, time spent resting, and surviving a second mob.

| Class | Solo Leveling build |
|---|---|
| Warrior | Arms (two-hander) |
| Paladin | Protection, with a Retribution dip (pulls packs) |
| Rogue | Combat (swords) |
| Hunter | Beast Mastery (pet tanks, Summon Hawk at 25) |
| Mage | Frost (plus Frost: AoE Leveling for AoE grinding) |
| Priest | Shadow |
| Warlock | Affliction (no respec) |
| Shaman | Enhancement |
| Druid | Feral Cat (Shifting Power, no powershifting) |

**Paladins** also get four Max Level Protection builds and a Farming build:
- **Vanguard (Raid):** the recommended raid tank: the most threat and the least damage taken in the simulator.
- **Bulwark (Long Fights):** cheaper seals, Judgements and Consecration for fights long enough to run Vanguard out of mana.
- **Bastion (Max Prot):** every Protection talent.
- **Arbiter (Holy Strike):** Judgement and Holy Strike focused.
- **Protection: AoE Farming:** gather big packs of normal mobs at 60 and kill them with Consecration, Holy Shield and Retribution Aura. Stack spell power.

**Paladins** also get three Holy builds: **Holy: Raid**, **Holy: Dungeon Leveling** and **Holy: Solo Leveling**.

**Paladins** also get a **Protection: Dungeon Leveling** build for tanking groups through dungeons, and three Retribution builds (two-hander):
- **Retribution: Solo Leveling:** questing alone, with Pursuit of Justice (+15% speed) for faster travel.
- **Retribution: Dungeon Leveling:** leveling through dungeons, with Repentance for crowd control, Instrument of Law for less threat, cheaper Consecration for packs and Exorcism for the Undead.
- **Retribution: Raid:** the level-60 build, seal-twisting with Twist of Light (Seal of Righteousness before each swing, then Seal of Command), with Instrument of Law for less threat.

**Warriors** also get five more builds, checked in the wowsims Forever simulator and our leveling models:
- **Arms: Raid:** the level-60 build (Arms 34 / Fury 17, two-hander). It beats Fury in the simulator.
- **Arms: Dungeon Leveling:** the solo Arms core with Sweeping Strikes at 30 for packs.
- **Protection: Raid:** the level-60 tank, with Shield Slam, Improved Thunder Clap, Defiance and Focused Rage.
- **Protection: Dungeon Leveling:** tanking groups through dungeons, avoidance first.
- **Protection: AoE Farming:** a Protection Warrior farms packs at 60 faster than Arms or Fury, because it hardly needs to eat.

**Rogues** also get **Combat: Raid** (the level-60 build with swords, which also farms best with Blade Flurry on two mobs) and **Combat: Dungeon Leveling** (daggers and Backstab from behind the mob).

**Hunters** also get **Beast Mastery: Raid** (the level-60 build) and **Beast Mastery: Dungeon Leveling**.

**Mages** also get **Frost: AoE Leveling** (AoE grinding, faster but hard to learn), **Frost: Raid**, **Frost: Dungeon Leveling** and **Frost: AoE Farming**.

**Warlocks** also get **Demonology: Raid** (Demonic Pact), **Affliction: Dungeon Leveling** and **Demonology: AoE Farming**.

**Priests** also get **Shadow: Raid**, **Shadow: Dungeon Leveling**, **Shadow: Multi-DoT Farming**, and two healer choices: **Holy: Raid** and **Discipline: Raid**, each with a Dungeon Leveling build.

**Shamans** also get **Enhancement: Raid**, **Enhancement: Dungeon Leveling**, **Elemental: Raid**, **Restoration: Raid**, **Restoration: Dungeon Leveling**, a shield tank for dungeons (**Tank: Dungeon Leveling**) and **Tank: AoE Farming**.

**Druids** also get **Cat: Raid**, **Cat: Dungeon Leveling**, **Balance: Raid** (Moonkin), **Restoration: Raid**, **Restoration: Dungeon Leveling**, and two Bear tank builds: **Bear: Dungeon Leveling** and **Bear: Raid**.

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

- **Talent names are matched in English,** so the plugin needs an English game client for now.
- **Your choices stay yours.** If you spend points outside the build, the plugin lists them and keeps guiding you through the rest.

---

## Feedback

Found a bug, think a build could be faster, or want a build for your playstyle? Come say hi on the **[Discord](https://discord.gg/aYmhmtGxYs)**.
