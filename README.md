# Extra Profiles and Skill Sets

## Overview

Key features and options:

- **Extra Profiles and Skill Sets:** Increases the total number of profiles and skill sets to 30 (from 15 in the base game).
- **Longer Profile Names:** Extends the maximum number of characters in a profile name to 30 (from 15 in the base game).
- **Options Menu for Customizing Amount of Profiles:** If 30 profiles still isn't enough, you can easily increase the number of profiles in the options menu. To prevent accidental profile wipes, changes are not saved automatically. You need to click the "Save Settings" button after making changes.

WARNING: If you start the game without the mod, your extra profiles and skill sets will be deleted.

Your profiles should still be fine if Overkill decides to change the number of profiles/skill sets in the future (assuming they don't drastically change the implementation).

## Implementation

This section describes the implementation of this mod and how it differs from "Oh No! More Skillsets" and "Oh Shit! More Profiles". You don't need to read this section unless you want to know how the mod works.

Oh No! More Skillsets extends the number of skill sets by overwriting the tables located in `SkillTreeTweakData` and `MoneyTweakData`. The number of entries in these tables corresponds to the number of skill sets. To change the number of skill sets, you need to manually add or remove entries from these tables.

Extra Profiles and Skill Sets uses a different implementation. You specify the number of profiles (and hence skill sets) that you want in the mod options. A loop is then used to automatically extend the tables until their lengths match the number of profiles specified. This makes changing the number of profiles much easier. Additionally, since the loop pads the tables until they match the specified length, it will still work even if Overkill decides to change the number of skill sets in the base game. In the event that the number of skill sets in the base game exceeds the user-specified number of profiles, the loop does nothing: the number of skill sets is lower-bounded by the amount in the base game. If this ever happens in a future game update, this mod will also be updated so that the minimum profile setting matches the amount in the base game.

With regard to profiles, Extra Profiles and Skill Sets is implemented in the same way as Oh Shit! More Profiles. Due to the way the game works, there is no easy way to check the number of profiles in the base game before you overwrite it. Therefore, the number of profiles is set to whatever value is specified in the settings. This does mean that if Overkill adds more profiles than you already have, you will not have access to them (but you can always change your settings to get more profiles so it makes no difference).

Extra Profiles and Skill Sets also extends the maximum number of characters in a profile name to 30. Oh Shit! More Profiles does this by overwriting the entire `MultiProfileItemGui:init()` function, which causes conflicts with other mods. Extra Profiles and Skill Sets uses a post-hook which avoids this issue.

## Installation

This mod requires [SuperBLT](https://superblt.znix.xyz).

Download `Extra-Profiles-and-Skill-Sets_<ver>.zip` from the [latest release page](https://github.com/ncakes/PD2-Extra-Profiles-and-Skill-Sets/releases/latest) and extract the entire contents to your `mods` folder.

```
C:\Program Files (x86)\Steam\steamapps\common\PAYDAY 2\mods
```

## Acknowledgments

This mod is based on TdlQ's [Oh No! More Skillsets](https://modworkshop.net/mod/13442) mod and Iron Predator's [Oh Shit! More Profiles](https://modworkshop.net/mod/17609) mod. Big thanks to the original authors for laying out the groundwork that made this mod possible.
