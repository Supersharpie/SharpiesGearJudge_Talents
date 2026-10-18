# Sharpie's Gear Judge [Talents] - Version History

## 🚀 v1.2.1

### ⚔️ New: PvP Leveling Builds (Experimental)
- Every talent tree of every class now has a **PvP Leveling** build for open-world PvP while you level, listed under Leveling with a red PvP tag. Choosing one also switches Gear Judge to its PvP weights at every level.
- The builds come from a new duel simulation that fights each build against all nine classes at every level from 10 to 59, with each class's real tools: heals that cost cast time and mana, stuns, fears, roots and silences with their real durations, cooldowns and diminishing returns from the game client, kiting, gap closers, spell pushback and pets. The opponents are tuned to real level-30 duel results (the wowforeverranked.com ladder and The Forever Open qualifier); the model picks the winner of 63 of 72 real class matchups.
- Some picks stand out: Feral duels in Bear Form, Restoration Shaman and Discipline/Holy Priest win by outlasting, Survival shoots rather than melees, and Warriors mostly lose the average duel below 40.
- They're model-only and marked **Experimental**: nobody has tried these exact builds in game yet, and everything above level 30 is an estimate until the beta goes past 30.

### 📏 Builds Checked Against the Game's Own Ability Data
- Gear Judge's leveling models now take every ability's cooldown, duration, cast time and cost from the Forever client itself, and a few didn't match. Druid shapeshifting costs 55% of base mana in Cat and Bear Form (we had 30-35%), Rage of the Farseer has a 3-minute cooldown (we had 2), Sniper Shot has a 4-second cast, Aimed Shot a 2-second one, and Aspect of the Cheetah isn't learned until 20. Every affected leveling build was searched again; almost all are unchanged.
- **Fire: Solo Leveling** is rebuilt and levels faster: Improved Fire Blast by 14, Ignite at 18, Master of Elements to save mana, and no Arcane Blast or Arcane Wrath. It's now about 66% slower than AoE leveling, from 75%.
- The "% slower" lines are updated for Beast Mastery solo (15%) and Arcane solo (72%).

## 🚀 v1.2.0

### 🎨 Talent Builds Page Redesigned
- **One row of tabs, every build in view.** Max Level, Leveling, Farming and PvP sit in one row at the top; the Tank / Healer / DPS and Solo / Dungeon button rows are gone. Every build for the chosen tab is listed below, grouped under Tank, Healer and DPS headers with their role icons, so the whole choice is in front of you without clicking through filters.
- **Tags on each build:** Solo or Dungeon, Fastest, Experimental, and how much slower the other solo builds level. Your current build says Active.
- **Build header:** the spec icon of the build's main tree, its category, and a bar showing how its points split between the three trees (tree names in your language, from the game).
- **Progress box** for your active build: a progress bar, the next talent with the level it's planned for, points waiting to be spent and any points outside the build. "Use This Build" becomes an Active mark when the build is already yours.
- **Talent order:** each line has the talent's icon and a stripe in its tree's colour; single-rank talents (abilities like Holy Shield) are outlined. A talent you're part way through is split, so the points you've taken show green and the rest gold. The list scrolls to your next talent.

### 🔗 Every Build Can Be Learned In Game
- Forever's talent trees have arrows: some talents need another talent at full rank before you can put a point in them (Mortal Strike needs Sweeping Strikes, Shield Slam needs Concussion Blow, Shadowform needs Vampiric Embrace, Bestial Wrath needs Intimidation, Soul Link needs Demonic Sacrifice, and so on). Our build checker and talent searches ignored them, so **48 builds** across all nine classes asked for a talent before the game allows it. Every build now follows the arrows, and the checker refuses any build that doesn't.
- **Leveling builds** were searched again with the arrows in place. Most come out within half a percent of before:
	- **Warrior**: Arms takes Sweeping Strikes before Mortal Strike (now at 44) and fills Improved Tactical Mastery for Anger Management, about 1% slower solo and in dungeons. Protection takes Concussion Blow before Shield Slam at the same speed. Fury: Dungeon Leveling came out about 1.5% faster.
	- **Mage**: Frost solo drops Ice Barrier (it needs Cold Snap) at the same speed. Fire solo is rebuilt (Improved Fireball, Pyroblast at 23, Arcane Blast before Arcane Wrath) and about 3% faster. The search also found faster dungeon builds: **Fire** about 5% (Ice Shards, Piercing Ice and Frost Channeling for Blizzard in place of Critical Mass, Combustion and Blast Wave) and **Arcane** about 1.5% (Arcane Mind, Arcane Instability, Shatter and Improved Cone of Cold in place of the Fire talents).
	- **Druid**: Feral solo takes Shredding Attacks for Shifting Power and drops Thick Hide, Leader of the Pack and Berserk, about 0.6% slower. Cat: Dungeon Leveling is rebuilt and about 2% faster. Bear tanking gets Primal Bite at 51, after Savage Fury.
	- **Priest**: Vampiric Embrace now comes before Shadowform (Shadow solo and dungeon). Discipline takes Soul Warding before Renewed Hope, and Discipline solo drops Power Infusion (it needs Penance).
	- **Hunter**: Beast Mastery solo takes Intimidation for Bestial Wrath and Survival takes Deterrence for Counterattack, both within 0.3%. Beast Mastery: Dungeon Leveling now gets Summon Hawk at 25.
	- **Rogue**: Combat solo drops Improved Slice and Dice and gets Blade Flurry at 45, about 0.5% slower. Assassination: Dungeon Leveling came out about 0.7% faster with Combat talents (Dual Wield Specialization, Blade Flurry at 53, Hack and Slash) in place of Lethality, Vile Poisons and Seal Fate.
	- **Paladin**: Retribution dungeon takes Sanctified Judgement before Vengeance, and Holy solo takes Reverence for Illumination, at the same speed.
- **Raid builds** move one to four points each, at no cost in the simulator or our healing model: Beast Mastery takes Intimidation, Frost takes Cold Snap, Arms takes Improved Tactical Mastery 5/5 and Sweeping Strikes (for Improved Charge and Improved Execute), Restoration Druid takes Naturalist 5/5 (for Subtlety), Holy Priest takes Spirit of Redemption and Discipline takes Soul Warding.
- **Farming and PvP builds** take the missing talents in place of points their notes don't rely on: Shadow farming fills Blackout and Improved Power Word: Shield, Demonology farming and PvP: Soul Link take Demonic Sacrifice (never use it), the Curse of Exhaustion builds take Amplify Curse, Marksmanship PvP takes Trueshot Aura, the Retribution PvP builds take Sanctified Judgement, and Shockadin takes Redoubt in place of Anticipation.
- Build notes are updated where a level or talent changed, in all eight languages.

### 🛡️ Warrior: A Leveling Build for Every Tree
- Every Warrior talent tree now has a **Solo Leveling** and a **Dungeon Leveling** build, found by a full talent search on Gear Judge's leveling models, now checked against beta combat logs.
	- **Solo Leveling**: Arms (two-hander) is still the fastest. **Fury** (dual wield) is new and levels about 1% slower. **Protection** (sword and board) is new: about 22% slower, but you take far less damage and rarely stop to eat. Fury with a two-hander came out about 15% slower than dual wield, so the Fury builds assume two one-handers.
	- **Dungeon Leveling**: Arms is retuned (Sweeping Strikes for packs at 30). **Fury** is new, about 11% behind Arms in groups. **Protection** tanking is retuned: 31 Protection points, then Arms talents for rage and threat, for about 3% faster runs.
	- **Arms: Solo Leveling** is retuned too: Bloodthrill and Weaponmaster now come before Mortal Strike.
- Protection: AoE Farming stays as it is: a new level-60 check in the simulator found it still the best farmer, about 4-6% ahead of the new Protection builds.
- Some builds end with a few points the model gives no value (Booming Voice, Lingering Rage). Their notes say so.

### ✝️ Paladin: Leveling Builds Retuned
- The Paladin's leveling builds were re-searched on the same models, each tree starting in its own tree from level 10.
	- **Solo Leveling**: **Protection** is now the fastest Paladin leveler in our model, about 7% faster than its previous version: from 20 you pull two mobs at a time, from 35 three, with Holy Shield at 40. **Retribution** levels about 21% slower (about 1% faster than before) and **Holy** about 29% slower. Holy now opens with Divine Strength and Improved Seals so you start in your own tree, which costs about 3% against its previous version (that one opened in Retribution). The Protection result comes from Gear Judge's model (a solo pull mode of the Protection tank model), not the simulator.
	- **Dungeon Leveling**: **Retribution** gets about 5% more damage (Retribution 28 / Holy 23: Holy Shock and Purifying Power in place of Repentance and Instrument of Law, which add no damage). **Protection** tanking runs about 5% faster (Iron Creed and Templar's Bulwark before Holy Shield, then Benediction and Holy Conduit). **Holy** is unchanged: the search found nothing better.
	- Protection: AoE Farming stays as it is; the level-60 farming model still rates it first.
	- **Re-checked after the 2026-10-15 beta patch** (Consecration's spell power share cut by more than half, Champion of the Light halved, Seal of Righteousness and Judgement of Righteousness spell power fixed, Reckoning storing up to 4 charges, Righteous Fury's threat up): no build changed, since each is still within 1% of the best the search finds. Protection solo leveling is about 1.5% slower than before the patch and still the fastest, and Protection: AoE Farming still farms best.

### 🐾 Druid: A Leveling Build for Every Tree
- Every Druid talent tree now has a **Solo Leveling** and a **Dungeon Leveling** build. Balance and Restoration solo use a new caster model in Gear Judge (Wrath, Starfire, Moonfire, Insect Swarm, Hurricane on dungeon packs, from the Forever client's spell values).
	- **Solo Leveling**: **Feral** (Bear Form until 20, then Cat) is still the fastest, and about 2% faster than before. **Balance** is new, about 31% slower: Moonkin Form at 40, Starfire with Moonfire. **Restoration** is new, about 41% slower: its damage comes from the Balance talents, and the Restoration points keep it your main tree but add little to solo leveling.
	- **Dungeon Leveling**: **Cat** is retuned (about 4% more damage; Claw instead of Shred, since with Ferocity it does more per Energy). **Balance** is new, about 18% behind Cat in groups, with Hurricane on packs from 40. **Restoration** healing is retuned: about 3% more healing per pull, Wild Growth at 40. **Bear** tanking keeps its talents: the search found nothing better.

### 🏹 Hunter: A Leveling Build for Every Tree
- Every Hunter talent tree now has a **Solo Leveling** and a **Dungeon Leveling** build. Survival uses a new melee model in Gear Judge (Raptor Strike, Strider Kick, Mongoose Bite, Counterattack, Immolation Trap, a two-hander or two one-handers), checked against the Survival Hunters in the beta dungeon logs: every one of them melees.
	- **Solo Leveling**: **Survival** (melee) is new and now the fastest Hunter leveler in our model, about 15% faster than the old Beast Mastery build (roughly 20 hours less /played to 60), mostly because melee costs far less mana than shooting, so you drink much less. **Beast Mastery** is retuned (about 2% faster than before, Pathfinding early, Summon Hawk at 36) and levels about 14% slower than Survival. **Marksmanship** is new, about as fast as Beast Mastery. There are no solo logs to check the melee result against yet.
	- **Dungeon Leveling**: **Beast Mastery** now starts in its own tree (the old build opened in Marksmanship) at the same damage. **Marksmanship** is new, level with Beast Mastery. **Survival** (melee) is new, about 12% behind them in our model; in the logs the melee Survival players did at least as well as the shooters, so that gap may be smaller in play.
	- **Survival: Dungeon Leveling** now uses its own dungeon weights in Gear Judge (Survival: Melee Dungeon Leveling) instead of the solo melee ones.

### 🔮 Mage: A Leveling Build for Every Tree
- Every Mage talent tree now has a **Solo Leveling** and a **Dungeon Leveling** build, each played with its own tree's spells, built on the **2026-10-15 beta patch** talent tree (Missile Barrage in the first row, Arcane Wrath, Improved Fire Blast in place of Wake of Fire, the new Arcane Blast, Fire Power and Winter's Chill). Gear Judge's Mage model now covers Arcane Missiles, Arcane Blast, Arcane Wrath, Pyroblast with Heating Up, Blast Wave, Master of Elements, Combustion and Cone of Cold with Winter's Chill, from the Forever client's spell values.
	- **Solo Leveling**: **Frost: AoE Leveling** is the fastest (about 1% slower than before the patch). Single-target **Frost** takes about 59% longer than AoE grinding but is the easiest way to level; the patch's Ice Lance cut (x3 on frozen targets, was x4) makes it about 13% slower than before, and it now takes Winter's Chill for Cone of Cold. **Arcane** (Arcane Missiles and Arcane Wrath, four Arcane Blasts first from about 50) is new and takes about 73% longer. **Fire** (Fireball, Fire Blast and Pyroblast at 3 Heating Up stacks) is new and takes about 75% longer.
	- **Dungeon Leveling**: **Arcane** is new and now the strongest Mage in groups: four Arcane Blasts (each adds Spell Damage for 15 seconds), then Arcane Missiles. **Frost** is about 3% behind it (about 5% less damage than before the patch). **Fire** is new, about 20% behind. Before the patch the beta dungeon logs had Arcane at about 0.88 and Fire at 0.71 of Frost's boss damage.
	- Bosses can no longer be frozen in the dungeon model (Frost Nova and Frostbite counted on them before).
- Frost: AoE Farming stays as it is: the level-60 farming model still rates it first.

### ✨ Priest: A Leveling Build for Every Tree
- Every Priest talent tree now has a **Solo Leveling** and a **Dungeon Leveling** build, on the 2026-10-15 talent tree. Gear Judge has a new Priest damage model for them (Shadow Word: Pain, Mind Blast, Mind Flay, Devouring Plague, Starshards, Shadow Word: Death, Smite, Holy Fire, Penance and the wand, from the Forever client's spell values), checked against the Shadow Priests in the beta dungeon logs.
	- **Solo Leveling**: the Priest model now counts damage over time crits (the beta logs show they crit in Forever) and lets you use the wand between spells, which favours the Discipline mana talents. **Discipline** (Smite) is new and now the fastest Priest leveler in our model. **Shadow** is about 2% slower, with more Shadow points (Shadow Weaving, Darkness, Improved Mind Flay, Dark Inspiration) and Shadowform at 40. **Holy** (Smite) is new, about 3% slower.
	- **Shadow: Solo Leveling (No Shadowform)** is new and marked **(Experimental)**: the build the search finds fastest on that model, Shadow with the Discipline mana talents in place of Shadowform and Vampiric Embrace, about 3% faster than Shadow: Solo Leveling. Nobody has tried it in game yet, so treat it as a model result.
	- **Dungeon Leveling**: **Shadow** deals about 8% more damage: Shadow Word: Pain on every mob in a pack, Mind Blast only now and then, as logged players do (it makes a lot of threat). **Holy** healing is about 6% better per pull and is now the stronger Priest healer; **Discipline** is about 3% better and about 5% behind Holy. Both healers are now scored with the log-calibrated healing model the other healers use.
	- **Shadow: Multi-DoT Farming** keeps its talents; Devouring Plague's shorter cooldown and Devouring Contagion now spreading to 2 mobs make it stronger.

### 🗡️ Rogue: A Leveling Build for Every Tree
- Every Rogue talent tree now has a **Solo Leveling** and a **Dungeon Leveling** build, each searched with swords and with daggers (and a mace for Combat). Gear Judge's Rogue model now also counts Cold Blood, Venom, Vigor, Quietus, Cutthroat, Setup and Riposte, and dungeons use the logged pull mix.
	- **Solo Leveling**: all three trees level within about 2% of each other in our model. **Subtlety** (two daggers: Ambush opener, Ghostly Strike, Hemorrhage from 33) is new and the fastest by a hair. **Combat** (swords) is retuned, about 2% faster than before and about 2% slower than Subtlety; a mace levels about as fast. **Assassination** (two daggers, Mutilate at 42) is new, about 2% slower.
	- **Dungeon Leveling**: **Combat** with daggers (Backstab) stays the strongest, about 1% more damage than before. **Assassination** (Mutilate from 43) is new, about 1.5% behind. **Subtlety** is new, about 5% behind; in groups it Backstabs rather than using Hemorrhage or Ghostly Strike.
	- The 2026-10-15 patch made Cold Blood get used up by Mutilate crits. Before that, Mutilate crit about 99% of the time in the beta logs; Gear Judge never counted that bug, so the Assassination builds don't depend on it.

### ⚡ Shaman: A Leveling Build for Every Tree
- Every Shaman talent tree now has a **Solo Leveling** and a **Dungeon Leveling** build, on the 2026-10-15 talent tree (Elemental Mastery as the 31-point talent, Lava Burst at 21 points, Trial by Fire in place of Improved Fire Nova, the cheaper Stormstrike and Chain Lightning, the weaker Fire Nova). Gear Judge has a new caster model for Elemental and Restoration (Lightning Bolt, Chain Lightning, Flame Shock, Earth Shock, Lava Burst, Fire Nova, Searing and Magma Totems, from the Forever client's spell values).
	- **Solo Leveling**: **Enhancement** is still the fastest and about 6% faster than before. **Elemental** is new, about 33% slower: casters spend more time drinking. **Restoration** is new, about 35% slower, played like Elemental.
	- **Dungeon Leveling**: **Enhancement** stays as it is (within 1% of the best the search found). **Elemental** is new, about 8% behind: Fire Nova and Magma Totem on packs; Lava Burst isn't worth a point in groups in our model. **Restoration** healing is about 6% better per pull and is now scored with the log-calibrated healing model. **Tank: Dungeon Leveling** runs about 1.4% faster.
	- **Tank: AoE Farming** now takes Mental Dexterity in place of Flurry (Flurry needs Mental Dexterity at full rank first), for the same speed: about 150 mobs an hour with 4 mobs.

### 🩹 Priest, Shaman and Warlock: Kept Legal After the Patch
- The 2026-10-15 beta patch removed Shadow Affinity (Priest), Call of Thunder (Shaman) and Malediction (Warlock), and moved Improved Power Word: Shield, Mental Strength, Totemic Focus and Tidal Focus to other rows. The builds that used them now take a stand-in in the same tree (Dark Inspiration, Trial by Fire, Grim Reach and the build's own Affliction talents) and learn moved talents once their row opens. Priest and Shaman have since had their full leveling pass (above).

### 🏁 Fastest Solo Build Marked
- With more than one Solo Leveling build per class, the fastest one is now tagged **(Fastest)** in the build list. Each of the others says how much slower it levels in our model.
- Builds that come only from our model and haven't been tried in game are tagged **(Experimental)**, and their build info says so.

### ⚔️ Retribution: Dungeon Leveling Tip
- The build note now says to keep **Judgement of the Crusader** up on bosses (about a fifth more damage) and to skip it on trash, where each mob dies before it pays back. Beta combat logs show most Retribution Paladins never use it. Gear Judge's dungeon weights for this build now assume you do, on bosses. Updated in all eight languages.

### 🌍 Talent Names From the Game
- Talent names in the build guide now come from Gear Judge itself, which uses the game's own name in every language. They read the same as before, except in Russian, where Shifting Power and Improved Shifting Power now show in English, as the current Forever client does.
- Two older Cat build notes now write Natural Instinct in English in every language, and the Russian Cat notes do the same for Shifting Power, matching the names the Forever client shows.

## 🚀 v1.1.4

### ⚔️ Enhancement: Raid Rebuilt
- **New Talents**: Enhancement: Raid is now Enhancement 33 / Restoration 16 / Elemental 2 instead of Elemental 19 / Enhancement 32. A full talent search on the current wowsims Forever simulator found it about 6% stronger against both raid and dungeon bosses. Tidal Focus adds 5% melee hit, and Mana Tide Totem and Mindfulness carry the mana that Fire Nova and the shocks burn through. Spirit Weapons is gone (it added no damage) and Ancestral Knowledge goes to 5.
- **Leveling Order**: The new order still levels faster than Enhancement: Solo Leveling (about 5% in our model). Mana Tide Totem is the last point, at 60.
- The build note is updated in all eight languages.

### 🐻 Bear: Raid Rebuilt
- **New Talents**: Bear: Raid is now Balance 9 / Feral 42. It drops Furor, Naturalist, Primal Bite and Berserk (worth nothing or less against a raid boss in the simulator) for Heart of the Wild, Rend and Tear and Shredding Attacks: about 12% more threat and 16% more health at the same damage taken.
- **Level With Bear: Dungeon Leveling**: Bear: Raid no longer shares its talents with Bear: Dungeon Leveling, which still levels faster (Furor and Primal Bite help on packs). Level with that one and respec at 60.
- The build note is updated in all eight languages.

### 🩸 Affliction: Solo Leveling Drains
- **New Order, Same Talents**: Affliction: Solo Leveling now takes Improved Drains at 17-19 and Fel Concentration at 20 (they used to come in the 50s), and from there plays Drain Life instead of the wand to fill each fight. Forever's Drain Life deals its damage and heals you for it, so you rarely stop to eat. Pandemic and Malevolence follow at 22-28, Soul Siphon and Siphon Life at 30-33, and Malediction moves to 42-46. The 51 talents at 60 are the same.
- **About 22% Less Leveling Time** than the same build with a wand, in our model. The model can't see damage pushing back your channel; Fel Concentration is there to cut that.
- The build note is updated in all eight languages.

### ✨ Easier-to-See Next Talent
- **Gold Highlight**: The glow on the next talent to learn is now gold and brighter instead of green. Before, it blended into the green border that every learnable talent already has.
- **Order Numbers on the Tree**: Every talent your build still puts points into now shows a number in the top-left corner of its icon: the step of its next point in the build (1 is your first point at level 10, 51 your last at 60). Read the numbers in order to see the whole build on the tree; as you learn a rank, that talent's number moves on to its next step.
- **Steps in the Tooltip**: Hover a numbered talent to see every step the build puts into it, with the level of each, such as "12 (L21), 13 (L22), 20 (L29)". Ranks you already have are greyed out. Translated into all eight languages.

## 🚀 v1.1.3

### 📊 Build Notes Re-Simulated
- **Updated Build Notes**: The level-60 builds were re-run on the current wowsims Forever simulator (the 2026-10-08 build). No talents change, but eight build notes quoted old numbers and now say what the simulator says today: Arcane is within a few percent of Frost (Frost stays the raid build for Winter's Chill and its freezes); Summon Hawk is a smaller share of Beast Mastery's damage and its leads over Marksmanship and Survival are 10% and 20%; the Cat skips Furor because Forever refunds no energy for shifting, and Intellect no longer counts for it; Bear makes about the same threat as a Protection Warrior; Combat's leads over Mutilate and Hemorrhage are 10% and 14%; Enhancement is about 1.7 times Elemental. All eight languages updated.

### ⚔️ PvP Builds
- **New: PvP Category**: The Builds page has a fourth group, PvP, next to Max Level, Leveling and Farming, with DPS and Healer builds. A PvP build is a full 10-to-60 talent order for open-world PvP while leveling and for battlegrounds at 60.
- **PvP Weights Follow the Build**: With a PvP build active, Gear Judge scores your gear with its PvP weights at every level (more Stamina, armor and burst; hit stops at the player-vs-player caps), even if Gear for PvP is off.


### 🔀 Dual Specialization
- **A Build for Each Spec**: WoW Forever unlocks a second spec at level 40. Each spec now keeps its own build: reminders, the "next talent", off-build warnings and respec prompts follow the spec you're in, and Gear Judge's weights switch with it. Your current build choice moves to the spec you're in.
- **Talent Window Tabs**: the highlight and the panel follow the Primary or Secondary tab you're looking at, so you can plan your other spec with its own build.
- **Builds Page**: once you have two specs, Primary and Secondary buttons at the top choose which spec's build you're picking (* marks the active one).
- **Gear Judge's Other-Spec Line**: Gear Judge's tooltip line for your other spec uses that spec's build (including a PvP build's PvP weights).
- Nothing changes for characters with one spec. Dual Specialization can't be reached in the beta yet (level cap 30), so this has only been tested with simulated specs.

### 🛠️ Beta Patch 1.60.1.70291
- **Warrior Builds Updated**: The patch removed Boundless Rage, Improved Cleave, Precision and Toughness, added Furious Precision, Lingering Rage and Gore Drinker, and moved several talents (Anticipation is now Protection tier 2, Bastion tier 6, and Iron Will moved from Fury to Protection tier 1). The builds that used them would have stopped short of 51 points:
	- Arms: Raid takes Booming Voice instead of Boundless Rage (it now also lowers your shouts' rage cost). Arms: Dungeon Leveling and Arms: Solo Leveling take Lingering Rage, which keeps your rage longer between pulls.
	- Protection: Raid, Dungeon Leveling and AoE Farming spend Toughness's 5 points on Improved Sunder Armor, Concussion Blow, Vanguard and Last Stand (Improved Shield Wall and Iron Will for farming), in a new order for the moved tiers. Shield Slam still comes at 43 (48 for farming).
	- PvP: Arms keeps 3 points of Iron Will in Protection and adds Booming Voice to stay deep enough in Fury.
- **Druid Builds**: Predatory Instincts is now called Natural Instinct (and also adds healing from Intellect). The 6 builds with it use the new name.
---

## 🚀 v1.1.2

### 🌍 Translations
- **Translated**: The Talents plugin is now translated into every language WoW Forever launches with: German, Spanish (Spain and Latin America), French, Brazilian Portuguese, Russian, Korean and Traditional Chinese. Build names, build summaries and talent names are translated; talent names use the game's own names.
- **Fixed: Builds on Non-English Clients**: The plugin compared your talents to its builds by English name, but the game reports talent names in your language, so build tracking (next talent, on-track count, off-build points) couldn't work on non-English clients. It now matches the game's names to the builds' talents.

### 🐛 Bug Fixes
- **Fixed: Talents That Share a Translated Name**: In some languages two talents of one class have the same name (Portuguese Arcane Concentration and Arcane Focus, Portuguese Bane and Ruin, Korean Bane and Wrack, Traditional Chinese Divine Strength and Holy Power). One of them looked unlearned, so the panel asked for points you had already spent and called others off-build. Talents are now matched by their spell, not their name, so every talent is read correctly in every language.
- **Fixed: Talents From Other Classes' Builds**: In German, Spanish and other languages, a talent name could be mistaken for another class's talent with the same translation. Only your own class's talents are matched now.
- **Fixed: Missing Builds in the Talent Window**: The build picker beside the talent window had room for 8 buttons, so Paladins couldn't pick 5 of their 13 builds and classes with 8 builds lost "No build". It now shows every build.
- **Fixed: Panel Jumping Back**: The build panel snapped back beside the talent window every time it refreshed, even after you dragged it away. It now stays where you put it until you close and reopen the talent window.
- **Fixed: Gear Judge's "Back" and "Clear" Wording**: In German, French and Spanish the plugin's Back and Clear buttons changed the wording of Gear Judge's own Back (cloak) slot and Clear Baseline button. They now have their own text ("Go Back" and "Clear Build"), and shared words (slot, stat and profile names) use Gear Judge's own translations.
- **Fixed: Korean Protection Build Names**: In Korean, Warrior and Paladin Protection builds showed the same tree name. Paladin builds now say 보호 and Warrior builds 방어, like the game.
- **Fixed: Characters With the Same First Name**: WoW Forever names have two parts, and characters sharing a first name shared one build choice. Each character now keeps its own; your current choice carries over.

### ⚡ Performance
- **Less Work per Talent Point**: Spending a point fired three talent events, and each one read your whole talent tree several times (10–15 reads per point). The plugin now reads the tree once and refreshes once per change.
- **Faster Panel Updates**: The panel and the highlight now update as soon as you pick a talent in the window.

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
