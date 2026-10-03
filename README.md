# Sharpie's Gear Judge [Talents]

> ⚠️ **Experimental: WoW Forever is in beta.** Blizzard changes talents, spells and level caps often between beta builds, sometimes several times a week. The builds and stat weights in this plugin are updated to keep up, but there can be a short gap after each patch where a build is out of date or a talent has moved. If something looks wrong after a patch, please report it on the [Discord](https://discord.gg/aYmhmtGxYs).

**A talent build guide for WoW Forever, built into Sharpie's Gear Judge.**

Pick a build once and the plugin walks you from level 10 to 60. It tells you which talent to take each time you level, highlights it in the talent window, and makes Gear Judge's stat weights follow the build. The gear advice always matches the spec you're playing.

> Requires **Sharpie's Gear Judge**. Made for **WoW Forever** (it does nothing on Classic Era or TBC).

---

## Features

- **Next-talent reminders.** Every level-up names the next talent to take, in chat and on screen.
- **Talent window highlight.** The next talent glows in the talent window. A panel beside the window shows your progress, the next five talents with the level each is planned for, and any points spent outside the build.
- **Talent Builds page.** A new page in the Gear Judge window lists your class's builds. Click one to see:
  - what it's for;
  - which stat weights it uses;
  - the full level-by-level talent order, with points you've spent in green and the next one in gold.
- **Gear advice that follows your build.** Choosing a build tells Gear Judge which weight profile to use, from your first talent point to level 60. A Protection tank build gets tank weights right away, before its tank talents would normally switch you over.
- **Planned respecs.** Some builds switch spec partway through. At that level you're told to reset your talents. Once you have, the guide and the weights move to the new spec.
- **Every build is checked** against WoW Forever's current talent trees: one point per level from 10, tier requirements, minimum levels and maximum ranks.

---

## Builds

Every class has a **Solo Leveling** build. It's the fastest way to level alone without being a glass cannon: each spec was compared on kill speed, time spent resting, and surviving a second mob.

| Class | Solo Leveling build |
|---|---|
| Warrior | Arms (two-hander) |
| Paladin | Protection / Retribution (pulls packs) |
| Rogue | Combat (swords) |
| Hunter | Marksmanship / Beast Mastery (pet tanks) |
| Mage | Frost |
| Priest | Shadow |
| Warlock | Affliction to 30, then a respec to Demonology (Soul Link) |
| Shaman | Enhancement |
| Druid | Feral Cat (with Shifting Power) |

**Paladins** also get five Protection builds:
- **Bulwark (Dungeon / Raid):** the default tank build.
- **Consecrator (Pack-Puller):** big pulls, mana-neutral with Consecration down.
- **Bastion (Max Prot):** every Protection talent.
- **Arbiter (Holy Strike):** Judgement and Holy Strike focused.
- **Vanguard (Battle Tank):** more damage for a little less survival.

**Druids** also get a **Balance (Moonkin)** build. It's slower than Cat until about 45, then faster and safer.

---

## Commands

| Command | What it does |
|---|---|
| `/sgjt` | Show the build panel |
| `/sgjt list` | List your class's builds |
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
