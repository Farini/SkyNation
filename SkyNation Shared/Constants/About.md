#  About
Some files and folder structures explained

- Data Ops
    - LocalDatabase: Files to store, with save() and load() functions
    - ServerAPI: All Server requests are made here
    - ServerData: Data fetched from server is stored locally here.

- Game Logic
    - GameLogic: Notification Names + Limits, boundaries, and constraints set by the game. 
    - GameError: An object to easily identify errors in the game
    - SKNConsumable + Store: Test in App Purchases + Main AppStore Objects
    
- Game Assets
    - GameImages + Image Extensions
    - GameSounds: Soundtracks + Sound Effects
    - GameFonts: Fonts + Formatters (Date, Number, TimeInterval)

## Development

### Cloc Result
Lines of code

> cloc .../SkyNation

-------------------------------------------------------------------------------
Language                  files          blank        comment         code
-------------------------------------------------------------------------------
Swift                          142           7236          7001             23124
JSON                          68              0                0                  1654
XML                            18              0               14                 1225
Markdown                    4             82               0                   481
GLSL                          10             86             186                 161
-------------------------------------------------------------------------------
SUM:                           242           7404           7201          26645
-------------------------------------------------------------------------------
PROJECT SIZE: 572MB

## Credits

### Music:
App: DM1
App: GarageBand

In Dreams by Scott Buckley | www.scottbuckley.com.au
Music promoted by https://www.chosic.com/free-music/all/
Attribution 4.0 International (CC BY 4.0)
https://creativecommons.org/licenses/by/4.0/

Adventure by Alexander Nakarada | https://www.serpentsoundstudios.com
Music promoted by https://www.chosic.com/free-music/all/
Attribution 4.0 International (CC BY 4.0)
https://creativecommons.org/licenses/by/4.0/

Main Theme (Overture) | The Grand Score by Alexander Nakarada | https://www.serpentsoundstudios.com
Music promoted by https://www.chosic.com/free-music/all/
Attribution 4.0 International (CC BY 4.0)
https://creativecommons.org/licenses/by/4.0/

### Sound FX:
App: DM1
App: GarageBand

### Programming - SwiftUI
Code With Chris: https://www.youtube.com/channel/UC2D6eRvCeMtcF5OGHf1-trw


### Server side
Vapor: https://docs.vapor.codes/4.0/
Tim (Swift Vapor Team)

### Shaders (Programming)
Shadertoy: https://www.shadertoy.com
Inigo Quilez: https://iquilezles.org

### 2D Images
NASA: Reference Images
Naun Project: TheNaunProject.com
Google: Reference Images

### Fonts
Google Fonts: https://fonts.google.com


### 3D Models
App: Blender https://blender.org
Blender Guru: https://www.youtube.com/channel/UCOKHwx1VCdgnxwbjyb9Iu1g
Josh Gambrell: https://www.youtube.com/channel/UCXfGjwohMgPm4Ng2e1FXySw

 
PBX Texturing (Atlasses)
Animations

## Guild Missions

- GuildMission - Equivalent to GameCenter's Achievements
    - Update Roads
    - Other Updates
    - Unlock Outposts
    - Rewards

- GuildMapItem - Items posted in map scene
    - road segments
    - Guild E-Vehicle
    - Unlock Outposts



## 📝 Done Items - Past

- [X] Project created: "SkyTestSceneKit" - Farini on 7/30/20.
- [X] 1/1 Improved Ingredients list (includes Lithium, Iron, Silicates, wasteLiquid)
- [X] 1/1 Player Entity
- [X] 1/1 Peripherals -> On/Off
- [X] 3/3 Create the real project - "SkyNation"
- [X] 1/1 When shopping Battery, add battery to right place (Truss)
- [X] Add Antenna and levels - to make money
- [X] Add Antenna Upgrades to Tech Tree
- [X] Modules Positions
- [X] Earth vs Payload Ship
- [X] Earth Animation
- [X] Airlock + positions
- [X] 3/3 Implement GarageView like the other Views - Header, List, Right View
- [X] 1/1 SpaceVehicle
- [X] 1/1 Module -> Skins 
- [X] 1/1 Human Selection View
- [X] 1/1 tComponents on Truss
- [X] 3/3 Cuppola
- [X] Make Game work on iPad
- [X] 1/1 Overlay Improvements

[01/16/2020]
- [X] 8/21 Scene Improvements [01/16/2020]
- [X] Cleanup Original Scene
- [X] SCNNodes Classes (Roboarm, Antenna, Radiator, Delivery Vehicle)
- [X] 3/3 Ship Animation (Needs better particle emitter, plus open the shell)
- [X] Particle emitter on all engines
- [X] Animate particle emission correctly
- [X] Fix Model underneath lid
- [X] Earth with Emission
- [X] Implement 'Skin' on all Modules
- [X] Earth Revealage
- [X] Load more items of Scene in StationBuilder
- [X] Camera positions + Sphere node
- [X] StationBuilder Object - 01/16/2021
- [X] Make Skin Work
- [X] Remake of Builder -> SceneBuilder to replace 'BuildItem'
- [X] Simplify Builder
- [X] Add Modules 7 ... 10
- [X] Make Nodes Work (right amount)
- [X] Transfer StationBuilder to a new Folder 'Model' -> 'Builder' and import SceneKit
- [X] StationBuilder should build the whole scene
- [X] Add Truss Items (Solar Panels, Radiator)
- [X] Make Earth Node
- [X] [02/08/2020] Add Items for Tech (Roboarm, Cuppola, Airlock, Garage, Antenna)
- [X] 3/3 GameMessage Object - [1/19/2021]
- [X] Add Messages to LocalDatabase
- [X] Load Messages
- [X] Fix Earth order Tank size
- [X] Fix Hab Module size (Bigger)
- [X] WaterFilter in Recipes and PeripheralType
- [X] Biosolidifier in Recipes and PeripheralType
- [X] Lab Module Make Recipe Icon in List
- [X] Fix Earth order Person View
- [X] Add Radiator to Truss
- [X] Loading Screen / User Registry
- [X] Route to create player
- [X] Modify Entry Point MacOS, iOS
- [X] Person menu -> Fire, Medicate, Workout, Study
- [X] LSS View 3/3 -> Each Peripheral should have its own Detail View and actions
- [X] Fix LSS View update issues
- [X] LSS View -> Improve Peripherals
- [X] Accounting should use all of the energy generated first, then from batteries

[02/08/2021]
- [X] Custom Game Buttons
- [X] Rounded Buttons
- [X] Better Delivery Order Ticket (Popover)
- [X] Person happiness going over 100?
- [X] Update Scene Overlay **PlayerCardNode**
- [X] GameLoop: Auto-Accounting
- [X] LSS View -> Make 1 tab for tanks & ingredients, and another for Peripherals

[2/17 to 3/1/2021]
- [X] Ingredients and sufficiency
- [X] Create a general Header View in SwiftUI for all SwiftUI base views
- [X] Improve People Selection View - Add a mark so user knows when they are selected
- [X] Improve Timer View
- [X] Improve Game Buttons (buttonStyle)
- [X] Module View -> If no other modules, only hab is available
- [X] GameLoop: Look for dates (Lab Activities, Human Activities, Vehicles)
- [X] Timing of Activity according to people's happiness, teamwork and intelligence
- [X] Garage -> Implement new people picker
- [X] Remake TrussView
- [X] Player avatar picker
- [X] Load Scene automatically
- [X] Player Avatar on Overlay
- [X] View with GameMessages (where chat is)
- [X] More realistic numbers on building things
- [X] Lab Module needs to update list when research is finished
- [X] Lab Module needs to estabilish the time for humans as well (the correct, lowered one)
- [X] Lab Module - Select from tree
- [X] Lab Module - Change boost for Token, and update button style
- [X] Make Settings View (and open from PlayerCard)
- [X] Implement Player Edit
- [X] Highlight PlayerCard
- [X] Don't let game start before name and avatar are chosen
- [X] Update Player avatar on Overlay View
- [X] GameLoop: Look for dates (Lab Activities, Human Activities, Vehicles) (In Mid-Game)
- [X] Store (Tokens + Packages) View
- [X] Freebies TokenLevels
- [X] GameGenerators + Encoding64
- [X] People generator - every hour. Pay for more. And generate Materials engineer first
- [X] Freebies Generator
- [X] Where to display freebies? -> Accounting, add new game message (not achievement)

[3/1/2021 - 3/28/2021]
- [X] Post Launch Scene
- [X] Server SpaceVehicle
- [X] Bring Scene in - Desktop:SpaceVehilce2.dae
- [X] Model Upgrade
- [X] Player -> Avatar
- [X] Player. var avatar (required)
- [X] Skin -> convert from String to Skin type
- [X] Accounting (problems + notes)
- [X] SpaceVehicle. var boxes (required)
- [X] Fix Server Tab View
- [X] Fix Settings Tab View
- [X] Delete Person from GameGenerator after hiring
- [X] Increase the chances of generating a .handy `person`
- [X] iPad multi-touch bug fixed
- [X] Antenna bug: not making more money in higher levels
- [X] LSS View -> Fix peripheral Selection bug
- [X] LSS View -> Empty Tanks and Boxes must have a way to define type.
- [X] LSS View -> Let wasteWater, and wasteSolid be an **orderable** product (empty)
- [X] 8/8 Recoding Accounting system
- [X] Make sure Solid Waste and Liquid Waste come in empty
- [X] LSS View -> Resources need Icon
- [X] LSS View -> Make Peripheral `Power Off` button
- [X] LSS View -> Better Station Accounting & Reporting + Accounting Bug Fix
- [X] LSS View -> Sort Tanks and Boxes by type
- [X] LSS View -> Tutorial View
- [X] LSS View -> Account & Reporting inside a ScrollView
- [X] Icons - Water Filter
- [X] Icons - biosolids
- [X] Icons - app (game) icon
- [X] Icons - electrolizer
- [X] Icons - waste water
- [X] Icons - waste solid
- [X] Icons - silica
- [X] Add 1 Melody for Soundtrack
- [X] Truss View creation
- [X] Solar Panel positions
- [X] Control where each solar panel goes
- [X] 1/3 Notify scene when tech is ready (not working)
- [X] Update Scene
- [X] Scene is showing Serial builder ahead of time. Check isUnlocked vs isResearched
- [X] Roboarm animation
- [X] Unbuild Module
- [X] Choose Skin + Persistency
- [X] GameCamera: A better camera control
- [X] Build Dock 3D Model
- [X] Control where each Radiator goes
- [X] Straighten Radiator
- [X] Restore Delivery Animations
- [X] Implement Dock 3d model
- [X] 5 Models of Antenna
- [X] Show  News
- [X] Player
- [X] Camera Control
- [X] LSS - Air Control
- [X] Improve Player View 
- [X] Mars
- [X] Vehicles Table
- [X] Better framing
- [X] Slider that controls Scene camera's X axis
- [X] News (Centered)
- [X] Fix iOS Colors
- [X] Coin Icon
- [X] Bring Regular Camera Closer to Scene
- [X] Helmet Icon - Time Token
- [X] Perspective view
- [X] Garage View - CameraBack
- [X] Front View - CameraFront
- [X] LOOK@ Camera constraints
- [X] Time to create SpaceVehicle
- [X] Circular progress View
- [X] Transfer Building Vehicles to Built Vehicles automatically
- [X] Vehicle Row improvements
- [X] Better Vehicle Assembly
- [X] Post Launch View
- [X] GameButtons
- [X] Descent Inventory View
- [X] Add StorageBox to Vehicle Data
- [X] Post Launch Scene
- [X] Basic Accounting (testable)
- [X] Person's happiness (if cuppola, airlock, etc.)
- [X] View Accounting Problems
- [X] Accounting Problems
- [X] Accounting Report object
- [X] Present view on iPad
- [X] iPad View dismissal

[6/29/2021 - 8/13/2021]
- [X] GameMessages showing strange dates
- [X] Mars Button -> Display Guild Settings, or Server down, if there is no info. Only a Player that has a SpaceVehicle built
- [X] Make all Tutorial points (Questionmarks).
- [X] Display Person's recently eaten
- [X] Bugfix: Humans dying too quickly
- [X] Fix buttons getting green and not returning to white
- [X] 1/3 Camera options + animations
- [X] Adjust camera LOOK@ constraints
- [X] Remodel Garage (Garage4.scn)
- [X] Have 3 Background music
- [X] Person Workout not incrementing health
- [X] GameSettings -> Sound
- [X] iOS Force Dark Mode
- [X] Accounting: waste (pee, and poop) not subtracting when Peripheral is working
- [X] Accounting: When station doesn't have people -> Don't make money
- [X] Make sure that Air adjustments AND Oxygen adjustments are working - Accounting
- [X] LSS View -> Define Tank not working properly (remove scrollview)
- [X] Animate Satellite Opening Solar Panel (if there is one)
- [X] Scene Alert (News) -> Low Oxygen
- [X] Scene Alert (News) -> Bad AirQualities
- [X] Scene Alert (News) -> Low Water
- [X] Biobox still not saving when done (needs testing)
- [X] Bio View - DNA animation (needs testing)
- [X] Settings in `LocalDatabase`
- [X] Game Store Improvements
- [X] Game Token Object
- [X] Shopped Object (data for purchased items on `Player`)
- [X] Implement `Purchase.Kit` in `GameShoppingView`.
- [X] App Store products registration
- [X] LSS View -> Ability to sort tanks from empty to full
- [X] HabModule -> Person Detail View -> Finish Activity with tokens.
- [X] Player -> convenient function to use token (getAToken, and useToken) -> Copy from `Shopped`
- [X] Player -> Mars Entry - Only get to Mars if player has an `.Entry` type of token, used. 
- [X] Player -> Mars Entry `func marsEntryPass()` and `requestEntryToken` need testing
- [X] Player -> Mars Entry  -> Scene Loading When loading Mars Scene, test `marsEntryPass()` and `requestEntryToken`
- [X] Server re-structure (Model)
- [X] GameSettings -> Object in `LocalDatabase`
- [X] GameSettings -> Auto merge tanks
- [X] Game Settings -> BioBox -> Source of food (Bool) -> Station Accounting
- [X] Resources View Example (Copy from `EDLInventoryView`)
- [X] Resources Tab
- [X] Resources Selection + Callback
- [X] SettingsServerTab -> Display my Guild
- [X] SettingsServerTab -> Join Guild
- [X] CityView -> Claim City Button
- [X] Test if wasteLiquid, and wasteSolid are not being removed when empty. Fixed under `Truss.mergeTanks()`
- [X] Reduce Travel Time to 3 days
- [X] City View - My City
- [X] City View - Other Cities
- [X] City View - Unclaimed City
- [X] Gamesettings -> SoundFX
- [X] Sound - Add a couple of SoundFX
- [X] 2D Graphics - SpaceVehicle engine icons
- [X] 2D Graphics - Guild Icons
- [X] 2D Graphics - Engines Images

[8/13/2021 - 9/5/2021]
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
- [X] City View - Tech implementation
- [X] City View - Recipes Implementation
- [X] EarthRequest - Fix weird Time to renew staff.
- [X] Mars Scene - City - Gate Node
- [X] Mars Scene - Outpost Node
- [X] Overlays - Cameras
- [X] Mars Scene - Animations - Camera entrance
- [X] Station Garage View - People not going in Vehicle.
- [X] Station Garage View - Building Vehicle - Reduce difficulty for bigger engines
- [X] Station LSS View - Tank -> Release (if O2, or Air)
- [X] Order View - Use Scroll only on the items collection
- [X] Order View - Person Selected indicator
- [X] Overlays - Cameras - Mars cameras not working properly
- [X] Overlays - Mars LSS View
- [X] Model - Tanks & Boxes -> Don't throw away
- [X] Model - City Accounting
- [X] Mars Scene - Animations - Camera change not working!
- [X] 2D Graphics - Avatars remake
- [X] 2D Graphics - SkyNation Entrance
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
- [X] Mars Scene - City - Gate Position + Angles
- [X] Mars Scene - Background
- [X] Mars Scene - Outposts with Levels
- [X] Mars Scene - Animations - Transportation - [See Gist](https://gist.github.com/Farini/ede665cab4e736480d4f399fbb4ca4f3)
- [X] Mars Scene - Guild map improvements (x8)
- [X] Model - Roads
- [X] Model - Create OutpostData
- [X] StorageBoxView - Improvements
- [X] Outpost View - Remodelling
- [X] Outpost View - Create OutpostData

[9/11/2021 - 10/03/2021]
- [X] Station Garage View - Update Overlay with Travelling Vehicles
- [X] Added People and Biobox to Vehicle's Trunk View
- [X] Station Garage View - View size too small (on launch) - use scrollview
- [X] Station Garage View - VehicleTrun View - improvements
- [X] Station Garage View - EDL - Test all resources going into SpaceVehicle
- [X] Space Vehicle - Fix Optionals (remove)
- [X] Space Vehicle - Remove irrelevant properties
- [X] Station LSS View - (Peripheral Selection) - not updating
- [X] Station LSS View - Total Remake
- [X] Basic Views - Player vs Ranking (Keyval pair view)
- [X] Station LSS View - Fix Peripherals Scroll View
- [X] Station LSS View - In-depth Testing after remake
- [X] 9/30/2021 - Remake of LocalDatabase
- [X] Settings - ServerTab - Leave Guild
- [X] Settings - ServerTab - Create Guild
- [X] Settings - ServerTab - Show status for guildless player, tell them they need to buy an .Entry ticket (purchasing any product)
- [X] Settings - ServerTab - Missing Guilds
- [X] Station Garage View - Correct Building Time.
- [X] Station Garage View - Improve departure animation
- [X] Station Garage View - Register Vehicle with Authentication (server side)
- [X] Station Garage View - Vehicles not updating correctly upon selection (travelling ones)

[10/03/2021 - 10/27/2021]
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
- [X] City View - Test Tech Tree
- [X] City View - Review Outpost RSS Collection
- [X] City Peripherals (AirTrap, AlloyMaker, PowerGenerator(ch4))
- [X] City Model Add Tech BioTech, (number of boxes of food allowed)
- [X] City View - Tech tree not showing completed items
- [X] City View - Calculate how much food is allowed in BioTab
- [X] City View - Vehicle Arrival - Dismiss food if not enough bioboxes
- [X] City View - Test Lab Recipes
- [X] City View - Lab Recipes - DetailView(making recipe)
- [X] City View - Bio View Improvements
- [X] Overlays - CamControl - Fix Buttons & reverse actions (forward = backward)
- [X] Overlays - SpaceVehicle - Progress is wrong
- [X] Chat Bubble - Fix Freebie
- [X] Chat Bubble - Fix Callouts
- [X] Chat Bubble - Gift `.Entry` token. -> Or transform into 10 tokens.
- [X] Chat Bubble - Invite Player, when there is no Guild President
- [X] Chat Bubble - Receive, Claim Gift `.Entry` token. -> Or transform into 10 tokens.
- [X] Mars Scene - Go back to Space Station
- [X] Station Scene - SceneBuilder Improvements (to reload scene back from Mars)
- [X] Outpost - SKNS request for `Outpost` upgrades
- [X] Outpost - fix bug with contribution - SKNS can't decode OutpostData
- [X] Outpost View - non .contributing states views
- [X] Accounting - Implement (Station+Account.swift)
- [X] Accounting - Finish Accounting cycle (Station+Account.swift)
- [X] Accounting - Fix Human Report Lines w/ weird emojis
- [X] Accounting - Copy Station - in Mars (New Methods)
- [X] Model - Outpost `Posdex` remake with Hotel, Arena, Observatory, 2x Biospheres, 4x Power Plants, Etc.
- [X] Blender - Observatory - Make UVs
- [X] Blender - Biosphere -> WallL3 needs grass UV
- [X] Blender - Biosphere -> Add trees
- [X] Blender - Biosphere -> Add new geometries
- [X] Blender - Station Truss -> Use Trimsheet
- [X] Station Scene - New Modules not 'clickable' after Tech research.
- [X] Station Scene - Background HDRI image
- [X] Tests - (Outpost) - Test SKNS request for `Outpost` upgrades. -> Server side working, but needs to update the view with ".finished" state
- [X] Blender - Arrival Scene - Animations - SpaceVehicle Sub-Materials
- [X] 2D Graphics - iOS app icon
- [X] Chat Bubble - Chat not showing after posting a message
- [X] Settings - Better Player Registration
- [X] Settings - Game Autostart
- [X] Model - Launching a Vehicle should also be an Achievement
- [X] Tests - (Settings) - ServerTab - Test Leave Guild
- [X] Basic Views - Error messages - GameResponse? (success, or error)
- [X] Store - Fix Price not showing.
- [X] Modules Views - Be able to change all modules
- [X] Import and fix Landpad
- [X] Add Music: InDreams, Adventure, MainTheme
- [X] Credits
- [X] Sound - 2 more music (better ones)
- [X] Garage Module - Remove Settings
- [X] Added Fonts + Info.plist
- [X] Blender - All Vehicle Paths
- [X] Blender - Export Roads
