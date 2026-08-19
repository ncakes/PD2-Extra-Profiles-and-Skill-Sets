# Changelog

## v3.0

*2026-08-19 - Update 247.1*

- Changes to any setting are only saved after clicking "Save Settings" button (previously only applied to number of profiles).
- Added a restart prompt if a restart is needed to apply changes to settings.
- Added an option to display the profile number before the profile name (off by default).
- Fixes for auto-equipping skill sets.
	- Fixed an issue where changes to the current profile were not saved (thanks PalkoVvodets, Jon8903247).
	- Bugfix for moving profiles when there are suspended skill sets.
	- When a suspended skill set becomes available again, it will be automatically bound to the correct profile.

## v2.1

*2026-02-28 - Update 243*

- Moving profiles will also move corresponding skill set if auto-equip skill sets is active (thanks Bucus).

## v2.0.3

*2026-02-11 - Update 242.2*

- Fixed an issue where autobind was activated for legacy users. Sorry to anyone who was affected. Autobind has now been disabled by default for everyone and has to be manually re-enabled.

## v2.0.2

*2026-02-10 - Update 242.2*

- Added an extra check to prevent a possible crash.

## v2.0.1

*2026-02-09 - Update 242.2*

- When autobind skill sets is enabled, manually switching skill sets is blocked unless the skill set corresponding to the profile is suspended.
- Fixed an issue where autobind skill sets would not equip the corresponding perk deck.

## v2.0

*2026-02-08 - Update 242.2*

- Minimum number of profiles is automatically set to base game value (currently 30).
- Default number of profiles increased to 45 (your current settings will not be affected).
- Maximum number of profiles increased to 120.
- All skill sets are unlocked automatically (including base game ones).
- Added an option to automatically switch to the corresponding skill set (if not suspended) when equipping a profile. Enabled by default.
- Added an option to lower the minimum number of profiles below the base game value. Disabled by default.

## v1.0

*2020-02-28 - Update 199 Mark II*

- Initial release.
