## _Horizon Bingo_
A basic open source bingo script made for QB-core

## _Dependencies_
1. [OX Lib](https://overextended.dev/ox_lib)
2. [QB-Core](https://github.com/qbcore-framework/qb-core)
3. [QB-Target](https://github.com/qbcore-framework/qb-target)
4. [OXMysql](https://github.com/overextended/oxmysql)

## Setup
1. run db.sql
2. Configure config.lua for target locations, items etc
3. edit script.js const webhookUrl = ''; // Replace with your Discord webhook URL

## Features
* Peristent cards based on citizen ID
* Draw Numbers at random
* Post to Discord results for verification by host
* Reset cards after bingo results confirmed

## Example Item - QB-Core items.lua
```lua
 bingo_card 			= {name = 'bingo_card',  	     				label = 'Bingo Card',	 			weight = 100, 		type = 'item', 		image = 'bingo_card.png', 		unique = false, 	useable = true, 	shouldClose = true,   	combinable = nil,   description = 'A bingo card to mark your numbers and play BINGO!' },


```

## Support and Customisation
No support is provided for this resource, feel free to fork and customise to your liking.