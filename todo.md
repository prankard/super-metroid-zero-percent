# TODO

### Core

- [x] Health needs to update visually
- [x] reserve needs to update visually
- [x] xray/grapple/beams to remove to check and call end level
- [x] morphing ball disappeared (smile editor learn)
- [x] way to finish game
- [x] allow missiles/super missiles/power bombs to have less than 5 remaining
- [x] needs to start with 230 ammo or start on zebes
- [x] Needs to minus ammo count (and no negative)
- [x] need to start with correct beams/items
- [x] Minus max health/ammo/pb
- [x] needs to remove equipment
- [x] needs to remove beams
- [x] needs to awaken zebes

### Wanted

- [x] remove grapple/xray icon (maybe missiles too)
- [x] prevent murder beam
- [x] basic varia tweaks (certain block to make it easier to travel and prevent softlock)
- [x] remove missile/supermissile/powerbomb icons when complete
- [x] turn on auto reserves by default
- [ ] speed up fanfare for collecting items
- [ ] want to have item graphics to be put back (start empty, return full)
- [ ] have game equip spazer when removing plasma
- [x] make health not increase when getting it (too easy)

### Maybe wanted

- [ ] want to kill ridley in a few hits (maybe not needed if start on zebes)
- [ ] make zebes sleep when completing or morph ball?
- [ ] do you want to save the animals? not possible
- [ ] can we run the lava animation backwards?

### Bugs

- [x] When collecting grapple/xray, you can still use it after selection until you change hud index
- [ ] turn off auto reserve when collecting last reserve tank (to stop icon)
- [x] bug - reserve keep on reserving all the time (animates from 100 - 99, then refills back to 100), meaning you can't get rid of them to crystal flash (I'm pretty certain this is a bug with bizhawk, as save file was fine in bsnes accuracy)
- [x] gravity suit (and probably varia suit) animation plays and messes up with your equipment by re-equipping
- [x] bt activates when you have bombs, not when you don't have bombs
- [x] 1% completion as due to morphing ball id change
- [x] bomb counter goes up after powerbombs selected



# Notes

#### Resources

65816 CPU Learning: https://wiki.superfamicom.org/learning-65816-assembly
65816 CPU Reference: https://wiki.superfamicom.org/65816-reference

Disassembly GitHub:
https://github.com/strager/supermetroid

Super Metroid Banks documentation:
http://patrickjohnston.org/bank/index.html

- [Bank 80](http://patrickjohnston.org/bank/80) - System routines
- [Bank 81](http://patrickjohnston.org/bank/81) - B2CB - New Game
- [Bank 82](http://patrickjohnston.org/bank/82) - Main game routines
- [Bank 84](http://patrickjohnston.org/bank/84) - Collect items, beams, power ups

Event States: http://www.metroidconstruction.com/SMMM/room_state_disassembly.txt
Ram Map: https://jathys.zophar.net/supermetroid/kejardon/RAMMap.txt



Super Metroid Memory Breakdown for cheating:
https://gamefaqs.gamespot.com/snes/588741-super-metroid/faqs/39409

Assembly Tutorial:
http://wiki.metroidconstruction.com/doku.php?id=super:asm_lessons#lesson_2

Assembly Stylesheet:
http://wiki.metroidconstruction.com/doku.php?id=super:expert_guides:asm_stylesheet

PLM Reference:
https://jathys.zophar.net/supermetroid/kejardon/PLM_Details.txt



### Assembly References
New Game Varia: https://github.com/theonlydude/RandomMetroidSolver/blob/master/itemrandomizerweb/patches/new_game.asm

Practice Hack 100%: https://github.com/tewtal/sm_practice_hack/blob/master/src/presets/hundo_data.asm

