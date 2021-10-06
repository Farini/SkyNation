# SkyNation
Welcome to the SkyNation repository. This is a space exploration MMO type of game. I've been working on it for a few years. 
The recent technology allows the combination of SwiftUI, SceneKit, and SpriteKit to work together and make this game's production easier and faster.
The reason this repository is public for now is that I would like to find people like you. People that are browsing projects, and trying to find something cool to work on.
I intend to pull this project out of its **public** state to a **private repository** around February, 2021.
If you are a Blender artist, or can program in Swift any of the frameworks mentioned above, or Swift Vapor for this game's server, don't hesitate to contact me.
Feel free to take a look at the *ToDo* list, make suggestions, etc.

![Screenshot1](https://drive.google.com/uc?export=view&id=1AjoeIrnVmOfZsoLK7KWuX3uWooEkEmtr)


# 📝 Projects
SkyNation is broken down into 5 projects.
The contributors to these projects shall have a **fair** share of the game, and therefore receive their share of the profits generated by the game and its related projects mentioned below.

- [X] **SkyNation** - This game's project: MacOS, iOS, TVOS
- [X] **SceneMachine** - 3D Framework to help with scenes, shaders, special FX, etc.
- [X] **SKNServer** - The server hosting game info - Host the database, players interactions, and some geometry + material assets

# 🏆 Milestones

- [X] Test Project created: "SkyTestSceneKit" - Farini on 7/30/20.
- [X] SkyNation Project created: 12/18/2020
- [X] Server Project SKNServer - A server for this game written in Vapor.
- [X] Apple Store Product Registration
- [ ] Product Version 1.0

### Methodology 
**ToDo** Items are a part of a **Component** of the Game. Completing these items will ultimately generate one or more stars, that indicates the progress of that component. A Component will be fully complete when 5 stars are reached - in which case it means that no more work is required for that component.

### 📝 Difficulty Levels
- 1. 1 hour or less
- 3. 1h < 1d
- 5. 1d < 3d
- 8. 3d < 7d
- 13. 7d, or more

### Star Rating

> ★ Completed components get a *filled* star.
> ☆ Empty stars indicate that component is incomplete.
 
 # Completeness
 Each Item gets a grade 1-5 (stars) that rerpresents how complete the item is.
 
 ## Programming (Front End)
 
 - [ ] ★★★★☆ Module, Hab, Lab, Bio
 - [ ] ★★★★★ Earth Order
 - [ ] ★★★☆☆ Garage
 - [ ] ★★★☆☆ Accounting System
 - [ ] ★★★★☆ Truss
 - [ ] ★★★★☆ Life Support Systems
 - [ ] ★★★☆☆ Vehicles Travelling Views/Scenes
 
 - [ ] ★★★☆☆ Mars Scene
 - [ ] ★★☆☆☆ Mars City
 - [ ] ★★★☆☆ Mars Outposts
 - [ ] ★★★☆☆ Game Chats, Messages, Achievements
 - [ ] ★★★☆☆ Game Store + Use of `GameToken`
 - [ ] ★★★☆☆ Player(object) + settings + playability + Purchases
 
 ## Programming (Back End)
 
 - [ ] ★★★★☆ Player
 - [ ] ★★★☆☆ Guild
 - [ ] ★★★☆☆ City + Outposts
 - [ ] ★★★☆☆ Guild Chat
 - [ ] ★☆☆☆☆ Bonus - New Features
 
 ## Art Assets -  Graphics 2D
 
 - [ ] ★★★★☆ Humans + Skills
 - [ ] ★★★★☆ Tanks, Containers, Ingredients, Peripherals
 - [ ] ★★★☆☆ Scenes Overlay (Camera, Vehicles list, etc.)
 - [ ] ★★★☆☆ Action Icons - Buy, Cancel, Cheat, Tokens, etc.
 - [ ] ★★☆☆☆ Icons - App Icon
 
 ## Art Assets -  Scenes 3D
 
 - [ ] ★★★★☆ Space Station
 - [ ] ★★★★☆ Delivery Vehicle
 - [ ] ★★★☆☆ Mars Colony
 - [ ] ★★★★☆ Space Vehicle
 
 ## Art Assets - Audio
 
 - [ ] ★★☆☆☆ Sound Effects
 - [ ] ★★☆☆☆ Music / Soudtrack

 
 ## Completeness
 Example calculation of *fair share*
 
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


## 📝 Doing - Present
If looking for things to do and don't know where to start, go to *Find Navigator* and search for **FIXME**, or **TODO**

10/03/2021
- [X] Game Shopping Testable
- [X] Game Shopping Player not receiving anything
- [X] Station - HabModule - End of study with Tokens result in Person NOT learning!
- [X] City View - Outpost RSS Collection
- [X] City View - Hab - Show population limit
- [X] City View - Bio View
- [X] City View - Person Details
- [X] Outpost - supply method
- [X] Outpost View - Contribution Request
- [X] Outpost View - Contribution Ranking
- [X] Chat Bubble (Reorganize)
- [X] Chat Bubble - Election
- [X] Chat Bubble - Vote in an Election
- [X] Chat Bubble - Search Icon - View Other Players (Search by name) + Request
- [X] Chat Bubble - Test Search Player
- [X] Model - Election
- [X] Model - City - Energy Collection
- [X] Model - Guild - Invite Request
- [X] Model - Outpost rss Collecting
- [X] Model - Accounting Improve Human (PHI - Person Happiness Index)
- [X] Overlay - Remake PlayerCard

- [X] Accounting - Implement (Station+Account.swift)
- [X] Accounting - Finish Accounting cycle (Station+Account.swift)
- [ ] Accounting - Fix Human Report Lines w/ weird emojis

- [X] Overlays - CamControl - Fix Buttons & reverse actions (forward = backward)
- [X] Overlays - SpaceVehicle - Progress is wrong
- [ ] Overlays - GameCamera - Fix Awkward cam transitions

- [ ] Settings - ServerTab - Test Leave Guild

- [ ] Chat Bubble - Fix Freebie
- [ ] Chat Bubble - Post PlayerID in Chat?
- [ ] Chat Bubble - Send free `.Entry` token. -> Or transform into 10 tokens.
- [ ] Chat Bubble - Test Election Results
- [ ] GameMessagesGuildTab - President functions (Invite, Kickout, Modify Guild)

- [ ] City View - Bio View Improvements
- [ ] City View - Test Tech Tree
- [ ] City View - Test Lab Recipes
- [ ] City View - Lab Recipes - DetailView(making recipe)
- [ ] City View - Review Outpost RSS Collection
- [ ] City Peripherals (AirTrap, AlloyMaker, PowerGenerator(ch4))
- [ ] City Model Add Tech BioTech, (number of boxes of food allowed)

- [ ] Outpost - SKNS request for `Outpost` upgrades
- [ ] Outpost - fix bug with contribution - SKNS can't decode OutpostData
- [ ] Outpost View - non .contributing states views
- [ ] Outpost - Posdex remake with Hotel, Arena, Observatory, 2x Biospheres, 4x Power Plants, Etc.

- [ ] Model - Mars Accounting improvements
- [ ] Model - Fix accounting - too easy
- [ ] Model - Fix cost of things (Outpost level ups)
- [ ] Model - Road Updates
- [ ] Model - E-Vehicle/Bot

- [ ] 2D Graphics - iOS app icon

- [ ] Blender - Individual Tanks
- [ ] Blender - Biosphere -> WallL3 needs grass UV
- [ ] Blender - Biosphere -> Add trees + water
- [ ] Blender - Observatory - Make UVs

- [X] Mars Scene - Go back to Space Station
- [ ] Mars Scene - Animations - SpaceVehicle arriving
- [ ] Mars Scene - Garage - Vehicle Validation (when arriving (orbit))

- [X] Station Scene - SceneBuilder Improvements (to reload scene back from Mars)
- [ ] Station Scene - Background HDRI image
- [ ] Station Scene - New Modules not 'clickable' after Tech research. 

- [ ] Sound - 2 more Sound FXs (Vehicle departing, News appearing) -> Look under Dektop -> Useful Assets -> Sounds
- [ ] Sound - 2 more music (better ones)

- [ ] Basic Views - Error messages (red)
- [ ] Basic Views - Alert messages (orange)

- [ ] iOS - Views are too large
- [ ] iOS - Font modifiers
- [ ] iOS - Window Sizes + View Sizes
- [ ] iOS - Neumorphic Button smaller
- [ ] iOS - Popover sizes

## Wishlist + Questionable
Features that are requested, but are not required to launch the game

- [ ] Free Supply Drop-offs -> Tokens for more 
- [ ] Reskin Delivery Vehicle
- [ ] Remodel Space Vehicle
- [ ] Rebake Garage Skin x 2 (Choices)
- [ ] Lights (Roboarm, Garage in, Garage out, Cuppola, Airlock) + User control
- [ ] Person var stress?
- [ ] Peripheral Upgrades
- [ ] Activity name enum?
- [ ] BioBox DNA enum
- [ ] 2D Graphics - Custom SFFonts
- [ ] 2D Graphics - Blender individual tanks
- [ ] 2D Graphics - Better Engine Icons
- [ ] Mars Scene - Random Rocks
- [ ] Mars Scene - City - Gate Color?
- [ ] Mars Scene - City + Solar Panel(s)
- [ ] Mars Scene - Gate Lights changing (Day/Night)
- [ ] Station Scene - Make the Earth bright again?
