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
 
 - [ ] ★★☆☆☆ Mars Scene
 - [ ] ★★☆☆☆ Mars City
 - [ ] ★★☆☆☆ Mars Outposts
 - [ ] ★★★☆☆ Game Chats, Messages, Achievements
 - [ ] ★★★☆☆ Game Store + Use of `GameTokens`
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

[8/13/2021 - ?]
- [X] EarthOrder - People list not refreshing.
- [X] GameLogic - Person - personStudyTime
- [X] Settings - Eliminate `GuildController` altogether. Merge With GameSettingsController.
- [X] Settings - Logic -> ServerManager.init() -> Check LocalPlayer -> Login
- [X] City View - Garage (Receiving Vehicles)
- [X] Station Garage View - Building Vehicle - Remove unnecessary views (solar panel, add bot)
- [X] Station Garage View - Building Vehicle - Make ScrollView take the whole space
- [X] Station Garage View - Built Vehicles - Remove Inventory Button, have only 'Descent' button
- [X] Station Garage View - Space Vehicle Registration (when launch)
- [X] Overlays - Guild Chat
- [X] Model - City Tech
- [X] Model - Mars City in `LocalDatabase`
- [X] Model - Guild Chat
- [X] Basic Views - PlayerContent, or PlayerCard
8/17/2021 = 14 of 61 (23 %)
- [X] City View - Tech implementation
- [X] City View - Recipes Implementation
- [X] EarthRequest - Fix weird Time to renew staff.
- [X] Mars Scene - City - Gate Node
- [X] Mars Scene - Outpost Node
- [X] Overlays - Cameras
- [X] Mars Scene - Animations - Camera entrance
8/22/2021 = 21 of 72 (29 %)

8/30/2021 to ....
- [X] Station Garage View - People not going in Vehicle.
- [X] Station Garage View - Building Vehicle - Reduce difficulty for bigger engines
- [X] Station LSS View - Tank -> Release (if O2, or Air)
9/1/2021 = 24 of 82 (29%)
- [X] Order View - Use Scroll only on the items collection
- [X] Order View - Person Selected indicator
- [X] Overlays - Cameras - Mars cameras not working properly
- [X] Overlays - Mars LSS View
- [X] Model - Tanks & Boxes -> Don't throw away
- [X] Model - City Accounting
- [X] Mars Scene - Animations - Camera change not working!
- [X] 2D Graphics - Avatars remake
- [X] 2D Graphics - SkyNation Entrance
9/3/2021
- [X] Blender - Consolidate Materials
- [X] Blender - Terrain + EmptyNodes (Cameras, Lights, Roads, ETC.)
- [X] Blender - new HDRI
- [X] Blender - Outpost Levels: 5x PowerPlant
- [X] Blender - GuildMap placeholders - Cities + Outposts + Roads + POVs + Animations Positions: EVehicle 3DPath
- [X] Blender - Outpost Levels: 5x Biosphere
- [X] Blender - Outpost Levels: 3x Mining
- [X] Blender - Outpost Levels: 1x Observatory
- [X] Blender - Outpost Levels: 1x LPad
- [X] Blender - Terrain - Roads
- [X] Blender - EVehicle Mesh + UVMaps simplification
- [X] Blender - EDL Animation
9/4/2021
- [X] Mars Scene - City - Gate Position + Angles
- [X] Mars Scene - Background
- [X] Mars Scene - Outposts with Levels
- [X] Mars Scene - Animations - Transportation - [See Gist](https://gist.github.com/Farini/ede665cab4e736480d4f399fbb4ca4f3)
- [X] Mars Scene - Guild map improvements (x8)
9/5/2021 41 of 97 (42%)
- [X] Model - Roads
- [X] Model - Create OutpostData
- [X] StorageBoxView - Improvements
- [X] Outpost View - Remodelling
- [X] Outpost View - Create OutpostData
- [ ] Outpost View - Contribution Request


- [ ] Finish Outpost View
- [ ] Finish City View

- [ ] Blender - Biosphere quick fix with floor + Trees
- [ ] Blender - Individual Tanks
- [ ] Blender - Biosphere -> Inset floor to improve visual
- [ ] Blender - Biosphere -> WallL3 needs grass UV

- [ ] Mars Scene - Random Rocks
- [ ] Mars Scene - Go back to Space Station
- [ ] Mars Scene - City - Gate Color?
- [ ] Mars Scene - City + Solar Panel(s)
- [ ] Mars Scene - Animations - SpaceVehicle arriving
- [ ] Mars Scene - Animations - Outposts Particle emitters
- [ ] Mars Scene - Garage - Vehicle Validation (when arriving (orbit))
- [ ] Mars Scene - Gate Lights changing (Day/Night)

- [ ] Station Scene - Breakdown Scene in Main Components - Nodes, Modules, Lights, Camera, etc.
- [ ] Station Scene - Background HDRI image
- [ ] Station Scene - Make the Earth bright again?
- [ ] Station Scene - New Modules not 'clickable' after Tech research. 

- [ ] Station Garage View - EDL - Test all resources going into SpaceVehicle
- [ ] Station Garage View - Improve departure animation
- [ ] Station Garage View - Notify Overlay of New Vehicles
- [ ] Station Garage View - View size too small (on launch) - use scrollview
- [ ] Station Garage View - Vehicles not updating upon selection
- [ ] Station Garage View - Not removing batteries from station when building vehicle
- [ ] Space Vehicle - Fix Optionals (remove)
- [ ] Space Vehicle - Remove irrelevant properties


- [ ] Station LSS View - Tank -> Test "discardEmptyTank"
- [ ] Station LSS View - (Peripheral Selection) - not updating

- [ ] Overlays - Election
- [ ] Overlays - Outpost rss Collecting
- [ ] Overlays - GameCamera - Fix Awkward cam transitions



- [ ] Model - E-Vehicle/Bot
- [ ] Model - Outpost rss Collecting
- [ ] Model - Election
- [ ] Model - Mars Accounting
- [ ] Model - Guild - Write Invite
- [ ] Model - Use more energy (Peripherals + Modules + Person)
- [ ] Model - Road Updates

- [ ] 2D Graphics - iOS app icon
- [ ] 2D Graphics - Blender individual tanks
- [ ] 2D Graphics - Better Engine Icons

- [ ] Settings - ServerTab - Leave Guild
- [ ] Settings - ServerTab - Create Guild

- [ ] City View - Election
- [ ] City View - LSS View + (Accounting Status)

- [ ] Outpost - supply method + SKNS request for `Outpost` upgrades

- [ ] Sound - 2 more Sound FXs (Vehicle departing, News appearing) -> Look under Dektop -> Useful Assets -> Sounds
- [ ] Sound - 2 more music (better ones)

- [ ] Basic Views - SelectionIndicator -> ● + ○
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
