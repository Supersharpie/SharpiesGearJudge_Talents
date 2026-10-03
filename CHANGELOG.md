# Sharpie's Gear Judge [Talents] - Version History

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
