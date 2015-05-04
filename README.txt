SHADoW93's Project TF2Danmaku Presents:
	
The Blitzkrieg - The original Rocket Hell FF2 Boss
	
Some code snippets from EP, MasterOfTheXP, pheadxdll, & Wolvan
Special thanks to BBG_Theory, M76030, Ravensbro, Transit of Venus, and VoiDED for pointing out bugs
	
Many thanks to sarysa for many fixes, improvements and enhancements.

	How to configure his rounds:
	
		blitzkrieg_config
			arg1 - Difficulty Level
				0 - Always Random
				1 - Easy
				2 - Normal
				3 - Intermediate
				4 - Difficult
				5 - Lunatic
				6 - Insane
				7 - Godlike
				8 - Rocket Hell
				9 - Total Blitzkrieg
				
			arg2 - Combat Style
				1 - Rocket Launcher Only
				0 - Rocket Launcher + Melee
				
			arg3 - Use Custom Weaponset?
				1 - Enable
				0 - Disable
				
			arg4 - Ability Activation notification
				1 - Voice Lines
				0 - Generic Sound
				
			arg5 - Ammo on RAGE (default 180)
			
			arg6 - Ammo on life loss (default 360)
			
			arg7 - Round Start Mode (if arg2 = 0)
				1 - Start with rocket launcher equipped
				0 - Start with only Melee
				
			arg8 - Allow Medics to revive players
				1 - Enable revive markers with a fixed # of revives
				0 - Disable revive markers
				-1 - Enable revive markers with no revive limit
				
			arg9 - Revive Marker Duration (default 30 seconds)
			
				arg10-arg11 only if arg1 is set to 0
			arg10 - What is the minimum level to select? (Default 2)
			arg11 - What is the maximum level to select? (Default 5)
			
			arg12 - Reroll a different difficulty level? (1 & 0 only function if on random mode, 2 will work independent of this setting)
				2 - Level Up
				1 - Reroll
				0 - Retain same level
				
			arg13 - RAGE on Kill? (default is no RAGE on kill)
			arg14 - Projectile bounce?
		
		mini_blitzkrieg
			arg0 - Ability Slot
			arg1 - Kritzkrieg Duration
			
		blitzkrieg_barrage
			arg0 - Ability Slot
			arg1 - Ubercharge duration
			arg2 - Kritzkrieg Duration
			arg3 - Rampage duration (if arg1 = 1, will switch to normal rocket launchers)
				
		point_teleport
		
			slot (arg0) simply determines if normal rage (0) or death rage (-1) fills charges
			arg1 - activation key. 1 is left click, 2 is right click, 3 is reload, 4 is middle mouse
			arg2 - number of uses per rage.
			arg3 - max distance
			arg4 - hint text string
			arg5 - particle effect (old location)
			arg6 -  particle effect (old location)
			arg7 - war3source/blinkarrival.wav" //"buttons/blip1.wav" // sound to play on teleport
			arg8 - if this is 1, preserves momentum (same as otokiru version)
			arg9 - if this is 1, charges are added to your total (different from otokiru version)
			arg10 - if this is 1, your clip is emptied upon teleport. really this feature is _only_ for blitzkrieg. at high difficulties without this you'd get cheap(er) kills.
			arg11 - attack delay set on all weapons upon point teleport. again, mainly just for Blitzkrieg. won't do squat if he rages after.
		
		blitzkrieg_strings
			arg1 - good_luck
			arg2 - combatmode_nomelee
			arg3 - combatmode_withmelee
			arg4 - blitz_inactive
			arg5 - blitz_inactive2
			arg6 - blitz_difficulty
			arg7 - blitz_difficulty2
			arg8 - help_scout
			arg9 - help_soldier
			arg10 - help_pyro
			arg11 - help_demo
			arg12 - help_heavy
			arg13 - help_engy
			arg14 - help_medic
			arg15 - help_sniper
			arg16 - help_spy
		
		blitzkrieg_misc_overrides
			arg1 - rocket model override
			arg2 - rocket recolors, standard weapons
			arg3 - rocket recolors, total blitzkrieg
			arg4 - damage multiplier while crits are active. use this to reduce (or increase) crit damage, which is a 3.0 multiplier
			arg5 - damage multiplier while strength is active. use this to reduce (or increase) strength damage, which is a 2.0 multiplier
			arg6 - explosion radius modifiers based on difficulty level.
			arg7 - disable the sound that plays before the round start (and the outro sound). why do it here? it's easier.
		
			medic stuff -- excess medics will be stripped of their minigun but given a very powerful crossbow
			arg8 - max standard medics. it can either be a solid value (1-31) or a percentage (0.00001 to 0.99999...) [set to 0 to not use]
			arg9 - crossbow weapon index (305 = normal, 1079 = festive)
			arg10 - attributes
			arg11 - random selection notification
			arg12 -  medic limit notification
			arg13 - override for straight goomba damage, leave blank or set to zero to not use
			arg14 - override for HP factor goomba damage, leave blank or set to zero to not use
			arg15 - needed for medic limit
			arg16 - Round time limit. Specify a value in seconds to enable.

			arg19 - various flags, add them up for desired results
				0x0001: Never change the player model.
				0x0002: Never change the player class
				0x0004: Never change the melee weapon
				0x0008: Don't spawn a parachute.
				0x0010: Don't allow novelty difficulties.
				0x0020: Block random crits.
				0x0040: Ensure explosion radius modifiers stack properly with automatic ones. (direct hit 0.3, air strike 0.85)
				0x0080: No MVM alert sounds.
				0x0100: Disable the Blitzkrieg voice messages.
				0x0200: Disable the match begin Administrator messages.
				0x0400: Disable the match end Administrator messages.
				0x0800: Disable class reaction messages.
				0x1000: Disable goombas entirely.
				0x8000: VSP-specific workaround for the head collection problem. If you're not VSP, don't include this flag.


		blitzkrieg_map_difficulty_override
		
			note: since I'm making default difficulty level 1, arg2-arg9 will correspond with standard difficulty levels
			arg10-arg19 I'll use for spillover, since I limit each string to 512 characters
			to speed things up, PARTIAL NAME MATCHES ARE NOT ALLOWED! argument skips are allowed.
			arg1 - default difficulty for arg2-arg19
			arg2-arg19 - map names

		blitzkrieg_weapon_override0 - there can be up to 10 of these, from 0 to 9
		
			and args 1-18 will just be weapon index, weapon attributes, over and over
			allows for server specific weapon stat overrides
			what you see is very VSP specific, and not suitable for other servers.
			note that sequential breaks ARE allowed, so if you have 12 args and delete 7 and 8 later
			it won't break 9-12
			
			arg1 (and odd # args)	- index
			arg2 (and even # args)	- attributes