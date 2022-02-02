# SkyNation
Welcome to the SkyNation repository. This is a space exploration MMO type of game. I've been working on it for a few years. 
The recent technology allows the combination of SwiftUI, SceneKit, and SpriteKit to work together and make this game's production easier and faster.
The reason this repository is public for now is that I would like to find people like you. People that are browsing projects, and trying to find something cool to work on.
If you are a Blender artist, or can program in Swift any of the frameworks mentioned above, or Swift Vapor for this game's server, don't hesitate to contact me.

![Screenshot1](https://drive.google.com/uc?export=view&id=1AjoeIrnVmOfZsoLK7KWuX3uWooEkEmtr)

Website: https://cfarini.com/SKNS/web/
Youtube Video: 

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

- [X] (02/01/2022) 🏁 Launch iOS v1.2 + mac v1.3?
- [X] NewsNode - Correctly waiting for the next, without overlapping
- [X] GameController - Builder Pause scene + unpause when `super.init()` ->> Smooth Entrance
- [X] Tutorial node improvements

- [ ] Settings View - Fix Guild Browser

- [ ] Front View - Prepare A/B test Shaders vs Earth image
- [ ] Front View - (Settings) Delete this game (start over)

- [ ] Analytics: reportData(string:String)
- [ ] Analytics - Report when build hab, lab, bio
- [ ] Analytics - Report when ordering
- [ ] Analytics - Report more useful data

- [ ] Store - Build list of bonus (kits) depending on prev. purchases
- [ ] Store - more visual improvements

- [ ] Guild Navigator - `addToJoinList` vs `acceptGuildInvitation` vs `joinUnlockedGuild`
- [ ] Allow player to see guilds before first purchase
- [ ] Leaving a Guild Problems. Needs to fix it. API not decoding correctly (but it happens in server. It crashes.)

- [ ] News - Special FX can be achieved with the `BusyCircuitry` shader.

- [ ] Prepare Scene Objects https://developer.apple.com/documentation/scenekit/scnscenerenderer/1522798-prepare
```swift
sceneRenderer.prepare(objects:[Any], completionHandler: ((Bool) -> Void))
object
An SCNScene, SCNNode, SCNGeometry, or SCNMaterial instance.
```

- [ ] ServerData - Use GuildFlags to show new items. in GuildRoom
- [ ] Guild Room - Election not updating
- [ ] Mars Scene - All Guild Vehicles arriving
- [ ] City View - Bio - "Evolve" not updating the list
- [ ] City View - Foreign City not being shown

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
- [X] iOS - List View Backgrounds. See: https://peterfriese.dev/swiftui-listview-part3/
- [ ] Views that need ScrollViews inside
- [ ] iOS Views - Mars Views (remake)

### Scene Models

- [ ] Blender - EDL Remake #5
- [ ] Blender - EVehicle remove/remake UV maps
- [ ] Blender - Arena + levels
- [ ] Blender - Hotel + levels
- [ ] Blender - Dock 3.0
- [ ] Blender - City Gate Skin

### Tests

- [ ] Election Results
- [ ] Tutorial Intro
- [ ] Create Player
- [ ] Outpost Update
- [ ] Leaving a Guild - Failing test
- [ ] Election not updating
- [X] UI Test - `iPad Pro 9.7 inch`
- [X] Space Station Building time: 0.916 seconds.

### GameCenter

- [ ] Game Center - Achievement - Air Scrubber
- [ ] Game Center - Achievement - Garage
- [ ] Game Center - Achievement - Vehicle Launch

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
