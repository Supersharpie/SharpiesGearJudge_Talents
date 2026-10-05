# Sharpie's Gear Judge [Talents] - Version History

## 🚀 v1.1.2

### 🌍 Translations
- **Translated**: The Talents plugin is now translated into every language WoW Forever launches with: German, Spanish (Spain and Latin America), French, Brazilian Portuguese, Russian, Korean and Traditional Chinese. Build names, build summaries and talent names are translated; talent names use the game's own names.
- **Fixed: Builds on Non-English Clients**: The plugin compared your talents to its builds by English name, but the game reports talent names in your language, so build tracking (next talent, on-track count, off-build points) couldn't work on non-English clients. It now matches the game's names to the builds' talents.

### ⚡ Performance
- **Less Work per Talent Point**: Spending a point fired three talent events, and each one read your whole talent tree several times (10–15 reads per point). The plugin now reads the tree once and refreshes once per change.

## 🚀 v1.1.1

### 🖼️ Redesigned for the Bigger Window
Gear Judge 3.2.0 makes the main window wider and taller, and the Talent Builds page now uses the room in three columns.
- **Left**: the category buttons (Max Level, Leveling or Farming; Tank, Healer or DPS; Solo or Dungeon) and the build list.
- **Middle**: the chosen build's name, summary, weights and progress, with **Use This Build** and **Clear** under them and the three settings at the bottom.
- **Right**: the talent order, which now scrolls the full height of the window with a colour key (taken, next, later). Before, it only got the space left under the build details, so a long summary left it very short.
- With all eight builds listed, the settings no longer run off the bottom of the page.
- **Fixed: Talent Order Out of Line**: A long talent line (for example "Improved Hammer of Justice 1-2/3") could wrap onto a second line, which pushed every talent below it one line away from its level. Each talent now has its own row beside its level, and a name too long for the column is cut short instead of wrapping.

---
## 🚀 v1.1.0

### ✨ Improvements
- **Builds Sorted by What You're Doing**: The Talent Builds page now groups builds the way you'd look for them. Choose **Max Level** (raid builds), **Leveling** or **Farming**, then **Tank**, **Healer** or **DPS**, then **Solo** or **Dungeon** for leveling builds. The role and Solo/Dungeon buttons show how many builds they hold, empty groups are greyed out, and the page opens on your active build's group (otherwise Max Level at 60 and Leveling before that). `/sgjt list` groups builds the same way.
- **Weights Labels Match the Builds**: The build page now names Gear Judge's profiles the same way as the builds (for example "Holy: Dungeon Leveling" while leveling, "Holy: Raid" at 60), and always shows the same name for a leveling profile. Gear Judge's own profiles were renamed to match every class's builds.
- **Builds for Every Class**: Each class now has raid builds and, where they make sense, Dungeon Leveling and Farming builds beside its Solo Leveling build. They were built with the wowsims Forever simulator (level-60 damage and tanking) and our leveling, healing and tank models, and each Dungeon Leveling build uses Gear Judge's matching Dungeon Leveling weights. The numbers quoted below come from those runs.

### ⚔️ Warrior
- **Arms: Raid** (`/sgjt set arms`): the level-60 build (Arms 34 / Fury 17, two-hander). Keep Rend up so Bloodthrill procs Overpower, Mortal Strike on cooldown, Slam and Spearing Strike to fill. About 12% more damage than dual-wield Fury and 20% more than two-hander Fury in the simulator.
- **Protection: Raid** (`/sgjt set prot`): the level-60 tank (Prot 38 with Deflection, Improved Heroic Strike and Cruelty). Improved Thunder Clap in place of Improved Sunder Armor; more threat and less damage taken than the Fury-Prot and Arms-Prot hybrids in the simulator.
- **Arms: Solo Leveling** (`/sgjt set solo`, updated): Improved Rend first and Bloodthrill at 30 (Overpower procs on a bleeding target), with Deflection, Improved Charge and Unbridled Wrath kept and Improved Heroic Strike and Sweeping Strikes dropped. About 11% faster than the old order in our model. At 60 it uses Gear Judge's Arms: Raid weights.
- **Arms: Dungeon Leveling** (`/sgjt set armsdungeon`): the solo Arms core with Sweeping Strikes at 30 for packs and Improved Heroic Strike in place of Deflection.
- **Protection: Dungeon Leveling** (`/sgjt set protdungeon`): tanking groups from 15 to 59. Avoidance first (the healer's mana slows a group most), Improved Revenge and Improved Thunder Clap for pack threat, then Toughness, Bastion, Cruelty and Shield Slam.
- **Protection: AoE Farming** (`/sgjt set farm`): level-60 pack farming. A Protection Warrior kills 3-5 level-60 mobs about as fast as Arms or Fury but takes a third of the damage: about 200 mobs an hour against 150. The raid tank's talents with Improved Sunder Armor in place of Defiance.

### 🛡️ Paladin
- **Raid tanks**: the Protection builds are listed as Max Level tank builds.
	- **Protection: Vanguard (Raid)** (was "Vanguard (Battle Tank)"), now the recommended raid tank: in the simulator's tank test it makes the most threat of the Paladin tank builds and takes the least damage, about 5% more threat and 4% less damage taken than Bulwark, because Vindication lowers the boss's attack power.
	- **Protection: Bulwark (Long Fights)** (was "Bulwark (Dungeon / Raid)"): keeps its cheaper seals, Judgements and Consecration for fights long enough to run Vanguard out of mana. Your selection stays as it is.
	- **Bastion** and **Arbiter**: unchanged.
- **Retribution: Raid** (`/sgjt set ret`): the level-60 build (Retribution 33 / Holy 18), built around seal-twisting with Twist of Light at 40: put Seal of Righteousness up just before each swing, then Seal of Command again, and the Echo applies the replaced seal on your next swing. About 19% more damage than without Twist of Light in the simulator, but it means re-sealing before almost every swing. Takes Instrument of Law for 20% less threat; no Holy Shock (Twist of Light leaves too few Holy points for it).
- **Holy: Raid** (`/sgjt set holy`): the level-60 raid healer, one of the first healer builds. Healing Light, Divine Favor, Reverence and Illumination first; Flash of Light is your main heal before raid gear, with Holy Light, Holy Shock and Light's Vigil for spikes. Pursuit of Justice and Guardian's Favor for raid utility.
- **Protection: Solo Leveling** (`/sgjt set solo`): renamed from Protection/Retribution Solo Leveling and listed as a Solo Leveling tank build.
- **Protection: Dungeon Leveling** (`/sgjt set protdungeon`): tanking groups through dungeons from 15 to 59. Precision early so your attacks land, Improved Seal of Fury at 20 (more mana back from higher-level dungeon mobs), Swift Judgement at 25 as an emergency taunt, Templar's Bulwark at 30, then Reckoning for threat in the 30s, Holy Shield at 40, then Benediction and Holy Conduit for cheaper Consecration, then Iron Creed.
- **Retribution: Solo Leveling** (`/sgjt set retsolo`) and **Retribution: Dungeon Leveling** (`/sgjt set retdungeon`): two-hander Retribution (Retribution 30 / Holy 21), split by how you play. Solo takes Pursuit of Justice (+15% speed) in the 20s for faster travel between mobs. Dungeon adds Repentance at 30 (crowd control for humanoids) and Instrument of Law at 40 (20% less threat, instant Hammer of Wrath), with Holy Conduit earlier for cheaper Consecration on packs and Purifying Power earlier for Exorcism against the Undead.

	All Retribution builds take Seal of Command at 20 and Sacred Arbiter at 25. Open each fight with Seal of the Crusader and Judgement: your melee hits keep Judgement of the Crusader on the target, and it adds its full bonus to Seal of Command, Holy Strike, Judgement, Exorcism and Holy Shock.
- **Holy: Solo Leveling** (`/sgjt set holysolo`): questing alone as Holy. Divine Strength and Improved Seals for damage, Holy Shock at 30, Light's Vigil at 40 (Vigil your target, then Holy Shock it again with no cooldown), then Retribution for Seal of Command and Pursuit of Justice. Slower than Retribution until the 50s, as expected for a healer.
- **Holy: Dungeon Leveling** (`/sgjt set holydungeon`): healing groups through dungeons. Mana talents first (your rest between pulls slows the group most), Holy Shock at 30, Light's Vigil at 40 for party healing, then Toughness, Guardian's Favor and Sacred Duty for when mobs turn on you.
- **Protection: AoE Farming** (`/sgjt set farm`): the first Farming build, replacing Consecrator (anyone who had Consecrator selected moves to it automatically). Gather 15-20 normal mobs, keep Consecration and Holy Shield up, and let Retribution Aura (30 + 10% of your spell power on every hit you take) do most of the killing. Holy Shield and Templar's Bulwark let you pull big packs, and Pursuit of Justice gathers the next pack faster.

### 🗡️ Rogue
- **Combat: Raid** (`/sgjt set combat`): the level-60 build (Assassination 18 / Combat 33) with swords. Slice and Dice up, Sinister Strike, Eviscerate at five combo points, Adrenaline Rush and Blade Flurry on cooldown. About 4% more damage than Backstab daggers, 8% more than Mutilate and 19% more than Hemorrhage in the simulator. It also farms best: Blade Flurry on two mobs at a time.
- **Combat: Solo Leveling** (`/sgjt set solo`): unchanged; checked against the new model, it's within 1% of the fastest Rogue leveling build. At 60 it now uses Gear Judge's Combat: Raid weights.
- **Combat: Dungeon Leveling** (`/sgjt set dungeon`): daggers for leveling through dungeons, where you stand behind the mob and can Backstab. Puncturing Wounds and Opportunity early, Murder for the many humanoid dungeon mobs, Blade Flurry for packs.

### 🏹 Hunter
- **Beast Mastery: Raid** (`/sgjt set bm`): the level-60 build (BM 34 / MM 17), with Trueshot Aura in place of Intimidation (bosses ignore the stun). About 19% more damage than Marksmanship and 23% more than Survival in the simulator.
- **Beast Mastery: Solo Leveling** (`/sgjt set solo`, replaces Marksmanship/Beast Mastery: Solo Leveling): Summon Hawk at 25, cast whenever it's ready to keep two hawks attacking (about 9% more kills an hour on its own), then Lethal Attacks, Efficiency, Ferocity, Careful Aim, Frenzy and Bestial Wrath at 40. About 7% faster than the old build in our model.
- **Beast Mastery: Dungeon Leveling** (`/sgjt set dungeon`): the same talents ordered for groups (your own damage talents first, Summon Hawk at 38).

### 🔮 Mage
- **Frost: Raid** (`/sgjt set frost`): the level-60 build. Ice Lance whenever Fingers of Frost is up. About 6% more damage than Arcane and 17% more than Fire in the simulator.
- **Frost: Solo Leveling** (`/sgjt set solo`): unchanged; it's still the best single-target leveling build in our model. At 60 it now uses Gear Judge's Frost: Raid weights.
- **Frost: AoE Leveling** (`/sgjt set aoe`): AoE grinding, the Mage leveling staple. Pull packs, Frost Nova, Blizzard. Harder to learn, but about 30% less leveling time than single-target Frost in our model. Mages get two solo leveling builds because not everyone can AoE grind.
- **Frost: Dungeon Leveling** (`/sgjt set dungeon`): the single-target Frost talents ordered for groups, with Blizzard and Cone of Cold on held packs.
- **Frost: AoE Farming** (`/sgjt set farm`): level-60 pack farming with Ice Barrier and Ice Block for safer big pulls.

### ✝️ Priest
- **Shadow: Raid** (`/sgjt set shadow`): the level-60 build (Discipline 20 / Shadow 31). Shadow Affinity, Shadow Reach and Silence in place of the solo build's Spirit Tap and Improved Psychic Scream. About 35-60% more damage than Smite in the simulator.
- **Holy: Raid** (`/sgjt set holy`) and **Discipline: Raid** (`/sgjt set disc`): the level-60 healers. Holy (Prayer of Mending, Spiritual Guidance) heals about 15% more in our model; Discipline (Penance, Divine Aegis, Power Infusion) is the stronger tank healer and brings Power Infusion.
- **Shadow: Solo Leveling** (`/sgjt set solo`): unchanged; it's still the fastest Priest leveling build in our model. At 60 it now uses Gear Judge's Shadow: Raid weights.
- **Shadow: Dungeon Leveling** (`/sgjt set shadowdungeon`): Shadow Affinity early for less threat, Mind Flay and Vampiric Embrace so your damage heals the group, Silence for casters, Shadowform at 40.
- **Holy: Dungeon Leveling** (`/sgjt set holydungeon`) and **Discipline: Dungeon Leveling** (`/sgjt set discdungeon`): healing groups through dungeons, mana talents first since your rest between pulls slows the group most. Discipline is about 6% faster until Prayer of Mending; Holy grows into the Holy raid healer.
- **Shadow: Multi-DoT Farming** (`/sgjt set farm`): Shadow Word: Pain and Devouring Plague on 4-5 mob packs, with shields and fears. Risky, but about 225 mobs an hour against 120 single-target in our rough model.

### 💀 Warlock
- **Demonology: Raid** (`/sgjt set demo`): the level-60 Demonic Pact build. About 19% more damage than Affliction and 28% more than DS/Ruin in the simulator.
- **Affliction: Solo Leveling** (`/sgjt set solo`): now Affliction all the way, with no respec at 30. About 20% faster than the old Affliction-to-Demonology respec in our model, and no respec cost. If you already made the old respec to Demonology, the guide will now flag those points as off-build: switch to Demonology: Raid (it levels as Demonology too), or reset to Affliction at a trainer.
- **Affliction: Dungeon Leveling** (`/sgjt set dungeon`): the Affliction talents ordered for groups, DoTs on every pack mob.
- **Demonology: AoE Farming** (`/sgjt set farm`): Soul Link with Rain of Fire or Hellfire on 4-5 mob packs. Rough and risky, but several times the kills of single-target farming.

### ⚡ Shaman
- **Enhancement: Raid** (`/sgjt set enh`): the level-60 two-hander build (Elemental 19 / Enhancement 32), with Elemental Devastation turning shock crits into melee crits. About 1.8 times the damage of Elemental in the simulator, and it levels about 2.6% faster than the solo build in our model.
- **Elemental: Raid** (`/sgjt set ele`): Elemental 31 with Enhancement and Restoration mana talents. About 43% behind Enhancement in the simulator, because Elemental runs out of mana in Forever.
- **Restoration: Raid** (`/sgjt set resto`): Chain Heal with Riptide, Water Shield (mana back on heal crits), Mana Tide and Nature's Swiftness. Heals about as much as a Holy Priest in our model.
- **Enhancement: Solo Leveling** (`/sgjt set solo`): unchanged. At 60 it now uses Gear Judge's Enhancement: Raid weights.
- **Enhancement: Dungeon Leveling** (`/sgjt set enhdungeon`): the raid talents ordered for groups.
- **Restoration: Dungeon Leveling** (`/sgjt set restodungeon`): the Restoration raid talents with the mana talents first.
- **Tank: Dungeon Leveling** (`/sgjt set tank`): a one-hander, a shield and Rockbiter Weapon with Spirit Weapons (+30% threat), Earth Shock, Fire Nova, Lightning Shield and Stormstrike. Weaker than a Warrior below 25, then about 10-17% faster runs in our model.
- **Tank: AoE Farming** (`/sgjt set farm`): pull about 4 normal mobs at 60 and burn them with Magma Totem, Fire Nova and Lightning Shield. About 170 mobs an hour against 78 single-target in our rough model.

### 🐾 Druid
- **Cat: Raid** (`/sgjt set cat`): the level-60 Feral build (Balance 9 / Feral 35 / Restoration 7), the same talents as the solo build. About 49% more damage than Balance in the simulator.
- **Balance: Raid** (`/sgjt set balance`), replacing Balance: Leveling (anyone who had it selected moves to it automatically): Improved Starfire instead of Improved Wrath, Reflection and Subtlety, Moonkin Form at 42. About a third behind Cat in the simulator.
- **Restoration: Raid** (`/sgjt set resto`): Rejuvenation and Regrowth with Nature's Splendor, Wild Growth, Swiftmend and Nature's Swiftness.
- **Bear: Raid** (`/sgjt set bear`): Maul, Swipe and Primal Bite with Thick Hide, Feral Swiftness, Natural Reaction and Furor. In the simulator's raid test it takes about 6% less damage than a Warrior but makes about 13% less threat.
- **Feral Cat: Solo Leveling** (`/sgjt set solo`, updated): now the Cat raid talents in a questing order, dropping Furor and Natural Shapeshifter: in the simulator, powershifting loses about 5% damage, so don't powershift. About 3% faster in our model, and no respec at 60. If you followed the old build, the guide will flag your Furor and Natural Shapeshifter points as off-build.
- **Cat: Dungeon Leveling** (`/sgjt set catdungeon`): the raid talents ordered for groups, where you can Shred from behind.
- **Restoration: Dungeon Leveling** (`/sgjt set restodungeon`): the Restoration raid talents with the mana talents first.
- **Bear: Dungeon Leveling** (`/sgjt set beardungeon`): the Bear: Raid talents. About as fast a dungeon tank as a Protection Warrior from 20 in our model (weak before Swipe).

-------------------------------------------------------------------------

## 🚀 v1.0.0

### ✨ New Plugin
- **Talent Build Guide for WoW Forever**: Pick a talent build and the plugin guides you from level 10 to 60:
	- On level-up it names the next talent to take, in chat and on screen.
	- In the talent window the next talent glows, and a panel beside the window shows your progress, the next five talents with the level each is planned for, and any points spent off-build.
	- When a point goes into a talent the build doesn't use, you get a one-time warning.
	- Builds can include a respec: at the set level you're told to reset your talents at a trainer, and once you have, the guide and the stat weights switch to the new spec. A respec that differs from the build by a few points still counts. The guide ends the old spec the level before the respec, so it never plans points you won't spend.
	- Gear Judge's stat weights follow the build: its leveling role (for example the Protection tank weights) applies from your first point, and its level-60 profile applies at 60. Turn this off with `/sgjt link off`.
- **Builds at Launch**: Every class has a **Solo Leveling** build, listed first: the fastest way to level alone without being a glass cannon. Each spec was compared on kill speed, time spent resting and surviving an extra mob:
	- **Warrior:** Arms with a two-hander.
	- **Paladin:** Protection with a Retribution dip, built for pulling packs.
	- **Rogue:** Combat swords.
	- **Hunter:** Marksmanship/Beast Mastery, with the pet tanking.
	- **Mage:** Frost.
	- **Priest:** Shadow.
	- **Warlock:** Affliction to 30, then a respec to Demonology (Soul Link) for the rest of the way.
	- **Shaman:** Enhancement.
	- **Druid:** Feral Cat, with Shifting Power.

	Paladins also get five Protection builds:
	- **Bulwark (Dungeon / Raid)**: the default tank build.
	- **Consecrator (Pack-Puller)**: big pulls, mana-neutral with Consecration down.
	- **Bastion (Max Prot)**: every Protection talent.
	- **Arbiter (Holy Strike)**: Judgement and Holy Strike focused.
	- **Vanguard (Battle Tank)**: more damage for a little less survival.

	Druids also get a Balance (Moonkin) leveling build, slower than Cat to about 45 but faster and safer after that. Every build is checked against Forever's talent rules: one point per level from 10, tier requirements, minimum levels and maximum ranks.
- **Talent Builds Page in the Gear Judge Window**: A new sidebar button opens a page listing your class's builds. Click one to see:
	- what it's for;
	- which Gear Judge weight profiles it uses while leveling and at 60, and its respec if it has one;
	- your progress and next talent;
	- the full level-by-level talent order, with points you've already spent in green and the next one in gold.

	**Use This Build** and **Clear** set the build. Checkboxes turn on or off whether the weights follow the build, the level-up reminders, and the panel beside the talent window.
- **Commands**: `/sgjt` opens the build panel. The panel's **Change Build** button picks a build. You can also use these commands:
	- `/sgjt list` lists your class's builds.
	- `/sgjt set <name>` picks one, for example `/sgjt set solo` or `/sgjt set bulwark`.
	- `/sgjt next` shows the next talent.
	- `/sgjt clear` removes the build.
	- `/sgjt remind on|off` turns the level-up reminders on or off.
