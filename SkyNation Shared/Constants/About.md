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


