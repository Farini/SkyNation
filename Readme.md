# SkyNation
Welcome to the SkyNation repository. This is a space exploration MMO type of game. I've been working on it for a few years. 
The recent technology allows the combination of SwiftUI, SceneKit, and SpriteKit to work together and make this game's production easier and faster.
The reason this repository is public for now is that I would like to find people like you. People that are browsing projects, and trying to find something cool to work on.
If you are a Blender artist, or can program in Swift any of the frameworks mentioned above, or Swift Vapor for this game's server, don't hesitate to contact me.

![Screenshot1](https://drive.google.com/uc?export=view&id=1AjoeIrnVmOfZsoLK7KWuX3uWooEkEmtr)

Website: https://cfarini.com/SKNS/web/

# 📝 Projects
SkyNation is broken down into 3 projects.

- [X] **SkyNation** - This game's project: MacOS, iOS, TVOS
- [X] **SceneMachine** - 3D Framework to help with scenes, shaders, special FX, etc.
- [X] **SKNServer** - The server hosting game info - Host the database, players interactions, and some geometry + material assets

# 🏆 Milestones

- [X] Test Project created: "SkyTestSceneKit" - Farini on 7/30/20.
- [X] SkyNation Project created: 12/18/2020
- [X] Server Project SKNServer - A server for this game written in Vapor.
- [X] Apple Store Product Registration
- [X] TestFlight: https://testflight.apple.com/join/lGBrKxTQ
- [X] Product (macOS) Version 1.0 build 40 - 12/29/2021
- [X] Product (iOS) Version 1.0 - 01/14/2022
- [ ] Product (tvOS) Version 1.0

### Methodology 
**ToDo** Items are a part of a **Component** of the Game. 
Completing these items will ultimately generate one or more stars, that indicates the progress of that component.
 
## Game Completeness
Each Item gets a grade 1-5 (stars) that rerpresents how complete the item is.
 
## Programming (Front End)
 
    ★★★★☆ Module, Hab, Lab, Bio
    ★★★★★ Earth Order
    ★★★★☆ Garage
    ★★★★☆ Accounting System
    ★★★★★ Truss
    ★★★★★ Life Support Systems
    ★★★★☆ Vehicles Travelling Views/Scenes
 
    ★★★★☆ Mars Scene
    ★★★★☆ Mars City
    ★★★☆☆ Mars Outposts
    ★★★☆☆ Guild Missions
    ★★★★☆ Game Chats, Messages, Achievements
    ★★★★☆ Game Store + Use of `GameToken`
    ★★★★☆ Player(object) + settings + playability + Purchases
    ★★★☆☆ Tutorials
 
## Programming (Back End)
 
    ★★★★☆ Player
    ★★★★☆ Guild
    ★★★☆☆ City + Outposts
    ★★★☆☆ Guild Chat
    ★★☆☆☆ Bonus - New Features
 
## Art Assets -  Graphics 2D
 
    ★★★★☆ Humans + Skills
    ★★★★☆ Tanks, Containers, Ingredients, Peripherals
    ★★★★☆ Scenes Overlay (Camera, Vehicles list, etc.)
    ★★★★☆ Action Icons - Buy, Cancel, Cheat, Tokens, etc.
    ★★★★☆ Icons - App Icon
    ★★★☆☆ Typography
 
## Art Assets -  Scenes 3D
 
    ★★★★☆ Space Station
    ★★★★☆ Delivery Vehicle
    ★★★☆☆ Mars Colony
    ★★★★☆ Space Vehicle
 
## Art Assets - Audio
 
    ★★☆☆☆ Sound Effects
    ★★★★☆ Music / Soudtrack
 
----------

## Completeness - History
 
@ October 29, 2020
- ★/☆: 5/70 = 7.14%
- ★ (1 Star) = 1.43%
- To Do's: 6/64 = 9.37%
 
@ December 24, 2020
- ★/☆: 26/105 = 24.76%
- ★ (1 Star) = 0.95%
- To Do's: 52/152 = 34.21%

@ August 13, 2021
- ★/☆: 79/145 = 54.48%
- ★ (1 Star) = 0.69%
- To Do's: 239/289 = 83%

@ October 27, 2021
- ★/☆: 101/150 = 67.33%
- ★ (1 Star) = 0.66%
- To Do's: 402/437 = 92%

@ December 29, 2021
- ★/☆: 118/160 = 73.75%
- To Do's: 528/553 = 95.47%

-------

## 📝 To Do list
If looking for things to do and don't know where to start, go to *Find Navigator* and search for **FIXME**, or **TODO**

12/29/2021 - 

- [X] macOS Force Dark Theme
- [X] Guild Substitution: `GuildMap` for `GuildFullContent`
- [X] Player Flags
- [X] Guild Flags
- [X] ServerData fixes
- [X] Tutorial - Place finger in middle of module.
- [X] Tutorial - remove finger
- [X] Tutorial - move new finger
- [X] City Disappeared!
- [X] Player Login Updates with Flags - See `ServerData.swift` - missing full review of errors and consequences.
- [X] Guild Room - Fix & Improve elections (not showing + wrong messages)
- [X] Election - Update Guild (in controller) after election does update
- [X] Nailed the Hand Tutorial !
- [X] 🏆 App macOS v 1.1 (New Player Login)
- [X] macOS - app not quitting
- [X] Fixed bug with app store not giving an Entry for a $5 purchase.
- [X] Receive Gifts
- [X] Reduce water filter skills required
- [X] Overlay - HUD Labels
- [X] Settings - HUD Labels
- [X] Overlay HUD badges count.
- [X] Overlay Scene with Labels + Badges & Display Option in `GameSettings`
- [X] SKNS.postCreate(newGuildID:UUID.... sub `GuildMap`
- [X] Method to 'dismiss' the badges on SideMenu
- [X] Guild View reframe
- [X] Game Center - iOS can't open GameCenter controller
- [X] Settings - ask before spend token
- [X] Animated Airlock
- [X] Game Camera - `stareAtNode()`
- [X] Laboratory View preloading !!
- [X] animate camera to show nodes like Airlock, Cuppola, Antenna, etc.
- [X] Implement new Station Modules from Blender
- [X] Milky Way background
- [X] Game Settings (start) - Bring view to textfield, and make it active.
- [X] 🏆 Launch iOS v 1.0 - Jan 14th, 2021
- [X] Fancy `NewsNode`
- [X] Settings - Move start game button to center of the view.
- [X] LSS - Remove (Let d) ??? + Instant Use -> Power use.
- [X] Station Scene - Fix green glass
- [X] GameCenter Achievements: **WaterFilter, Condensator, Airlock**
- [X] Implement the new `NewsNode`

- [X] Launch macOS v 1.2

- [X] Intro - Before Hand Tutorial
- [X] Report game Center experience when app going to background
- [X] News Overlapping eachother
- [X] LSS Peripheral Detail Views
- [X] 👀 Launch Scene improvements
- [X] GameController - on touch(camera zoom), zoom in on the point of the touch, instead of center of geometry.
- [X] GameController - display node info when zooming in
- [X] LabView - Tech with new Detail Images
- [X] Station Scene - Make the Earth bright again

- [ ] LabView substitute "Loading View" for something more useful

- [ ] Front View - Game Settings shown only at the game start
- [ ] No need to check for state. `buttonDisabled()` Better model.
- [ ] Allow player to see guilds before first purchase
- [ ] Progress View for scene loading?
- [ ] Astronomy Images?
- [ ] Astronomy Blog link?
- [ ] Leaving a Guild Problems. Needs to fix it. API not decoding correctly (but it happens in server. It crashes.)
- [ ] Guild Navigator - `addToJoinList` vs `acceptGuildInvitation` vs `joinUnlockedGuild`
- [ ] Settings - Delete this game (start over)
- [ ] Entry Shaders? StarNest.fsh, BusyCircuitry.fsh

- [ ] News - Special FX can be achieved with the `BusyCircuitry` shader.
- [ ] If accounting goes for too long, save the city (not currently saving, just accrueing time)

- [ ] Prepare Scene Objects https://developer.apple.com/documentation/scenekit/scnscenerenderer/1522798-prepare
```swift
sceneRenderer.prepare(objects:[Any], completionHandler: ((Bool) -> Void))
object
An SCNScene, SCNNode, SCNGeometry, or SCNMaterial instance.
```

- [X] ServerData - Set GuildFullContent to nil in any case. Prepare to deprecate
- [ ] ServerData - Use GuildFlags to show new items. in GuildRoom
- [ ] Guild Room - Election not updating
- [ ] Mars Scene - All Guild Vehicles arriving
- [ ] City View - Bio - "Evolve" not updating the list
- [ ] City View - Foreign City not being shown

- [ ] Store - needs visual improvements
- [ ] Store - Build list of bonus (kits) depending on prev. purchases

- [ ] Game Settings - Save camera?
- [ ] Remove `GuildFullContent` from ServerData (mac v 1.3, iOS v 1.3)
- [ ] Remove `GuildFullContent` object



### Game Recording Plan

1. Show Order
2. Launch View Scene
3. EDL scene
4. Lab Activity

### iOS

- [X] iOS Views - Corner Radius:12
- [X] iOS Views - Hab Module Selection
- [X] iOS - List View Backgrounds. See: https://peterfriese.dev/swiftui-listview-part3/
- [X] iOS - Button being pushed.
- [X] iOS - Garage - prepare for launch is unusable
- [X] iOS - increase bloom in camera? - or find a way to make scene brighter.
- [X] Setup Graphics Options (multisampling on UIViewController's `view`)

- [ ] Views that need ScrollViews inside
- [ ] iOS Views - Mars Views (remake)

### Scene Models

- [X] Blender - Substitute Space Vehicles Solar Panels
- [X] Blender - XCode - Delete old solar panels
- [X] Blender - Cuppola 2.0
- [X] Blender - Airlock 2.0
- [X] Blender - New Module Skins

- [ ] Blender - EDL Remake #5
- [ ] Blender - EVehicle remove/remake UV maps
- [ ] Blender - Arena + levels
- [ ] Blender - Hotel + levels
- [ ] Blender - Dock 2.0
- [ ] Blender - City Gate Skin

### Tests

- [X] Mining Scene Nodes (waiting to be unlocked)
- [X] GuildRoom Markdown - and with quote
- [X] Election Results - Guild governor - pending update of Guild.
- [X] Tutorial finger
- [X] Create Player
- [X] UI Test - `iPad Pro 9.7 inch`
- [X] Space Station Building time: 0.916 seconds.
- [ ] Outpost Update
- [ ] Leaving a Guild - Failing test
- [ ] Election not updating

### GameCenter

- [X] Game Center - Player Auth.
- [X] Game Center - Leaderboards (Experience)
- [X] Game Center - 🏆 Achievements (WaterFilter, Condensator, Airlock)
- [ ] Game Center - Achievement - Air Scrubber
- [ ] Game Center - Achievement - Garage

## Wishlist + Questionable
Features that are requested, but are not required to launch the game

- [X] Free Supply Drop-offs -> Tokens for more 
- [ ] Reskin Delivery Vehicle
- [ ] Remodel Space Vehicle
- [ ] Peripheral Upgrades
- [ ] BioBox DNA enum
- [ ] 2D Graphics - Custom SFFonts
- [ ] 2D Graphics - Blender individual tanks
- [ ] Mars Scene - Random Rocks
- [ ] Mars Scene - City - Gate Color?
- [ ] Mars Scene - City + Solar Panel(s)
- [ ] Mars Scene - Gate Lights changing (Day/Night)
- [ ] Blender - Individual Tanks
- [ ] Model - E-Vehicle/Bot
- [ ] BioModule - DNA Animation remake
- [ ] BioModule - Extra functions (expand)
- [ ] Store - Save receipt in a file
- [ ] Mars Scene - City Garage - Vehicle Validation (when arriving (orbit)) - needs a token, if not valid.
- [ ] Mars Scene - City Garage - Delete Vehicle from Guild at end of `unload`

## Promoting
Once the app is released.

### App Screenshots

- [X] Video - macOS
- [ ] Video - iPad

version: `macOS`
One of the following, with a 16:10 aspect ratio.
1. 1280 x 800 pixels
2. 1440 x 900 pixels
3. 2560 x 1600 pixels
4. 2880 x 1800 pixels
