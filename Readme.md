# SkyNation
Welcome to the SkyNation repository. This is a space exploration MMO type of game. I've been working on it for a few years. 
The recent technology allows the combination of SwiftUI, SceneKit, and SpriteKit to work together and make this game's production easier and faster.
The reason this repository is public for now is that I would like to find people like you. People that are browsing projects, and trying to find something cool to work on.
I intend to pull this project out of its **public** state to a **private repository** around February, 2021.
If you are a Blender artist, or can program in Swift any of the frameworks mentioned above, or Swift Vapor for this game's server, don't hesitate to contact me.
Feel free to take a look at the *ToDo* list, make suggestions, etc.

![Screenshot](https://drive.google.com/file/d/1AjoeIrnVmOfZsoLK7KWuX3uWooEkEmtr/view?usp=sharing)


# 📝 Projects
SkyNation is broken down into 5 projects.
The contributors to these projects shall have a **fair** share of the game, and therefore receive their share of the profits generated by the game and its related projects mentioned below.

- [X] **SkyNation** - This game's project: MacOS, iOS, TVOS
- [X] **SceneMachine** - 3D Framework to help with scenes, shaders, special FX, etc.
- [ ] **SKNServer** - The server hosting game info - Host the database, players interactions, and some geometry + material assets
- [ ] **Gamebase2D** - 2D Framework (SpriteKit) created for this and other games

# 🏆 Milestones

- [X] Test Project created: "SkyTestSceneKit" - Farini on 7/30/20.
- [X] SkyNation Project created: 12/18/2020
- [ ] Server Project SKNServer - A server for this game written in Vapor.
- [ ] Apple Store Product Registration
- [ ] Product Version 1.0

## Methodology 
The completion of each **ToDo** item will lead to the earning of **Stars**, which represent a feature of the game.
Each **ToDo** item has a difficulty level. As each item is different, and requires some amount of work, a ToDo item should have its difficulty level indicated on the ToDo list, as described below:

> ★ Completed features get a *filled* star.
>> ☆ Features that need work done, are incomplete, or not yet started, get an empty star.


### 📝 Difficulty Levels
 - 1. 1 hour or less
 - 3. 1h < 1d
 - 5. 1d < 3d
 - 8. 3d < 7d
 - 13. 7d, or more
 
 # Completeness
 Each Item gets a grade 1-5 (stars) that rerpresents how complete the item is.
 
 ## Programming
 
 - [ ] ★★★☆☆ Module, Hab, Lab, Bio
 - [ ] ★★☆☆☆ Earth Order
 - [ ] ★☆☆☆☆ Garage
 - [ ] ★★☆☆☆ Accounting System
 - [ ] ★★☆☆☆ Truss
 - [ ] ★★★☆☆ Life Support Systems
 - [ ] ☆☆☆☆☆ Travels Scene (v 1.1)
 - [ ] ☆☆☆☆☆ Mars Scene
 - [ ] ☆☆☆☆☆ Server - SKNServer?
 - [ ] ★☆☆☆☆ Player(object) + settings + playability
 
 ## Art Assets
 Each Item gets a grade 1-5 (stars) that rerpresents how complete the item is.
 
 Icons + 2D Overlays
 - [ ] ★★★★☆ Humans + Skills
 - [ ] ★★☆☆☆ Tanks, Containers, Ingredients, Peripherals
 - [ ] ★★★☆☆ Scenes Overlay (Camera, Vehicles list, etc.)
 - [ ] ☆☆☆☆☆ Action Icons - Buy, Cancel, Cheat, Tokens, etc.
 - [ ] ☆☆☆☆☆ Icons - App Icon
 
 3D Scenes
 - [ ] ★★★☆☆ Space Station
 - [ ] ★★☆☆☆ Delivery Vehicle
 - [ ] ☆☆☆☆☆ Mars Colony
 - [ ] ★☆☆☆☆ Space Vehicle
 - [ ] ☆☆☆☆☆ Sound Effects
 - [ ] ☆☆☆☆☆ Music / Soudtrack
 
 ## Total Completeness
 Example calculation of **fair share**
 
 @ File created (with these settings): October 29, 2020 at 3:00 PM
 - Star Count: 5/70 = 7.14%
 - ★ (1 Star) = 1.43%
 - Farini 5/5 = 100%
 - Difficulty Count: 64
 - Done Difficulty: 6/64 = 9.37%
 
 @ December 24, 2020
- Star Count: 26/105 = 24.76%
- ★ (1 Star) = 0.95%
- Farini 26/26 = 100%
- Difficulty Count: 152
- Done Difficulty: 52/152 = 34.21%

#  Backlog
Items being worked on

## 📝 Doing - Present

- [X] 3/3 GameMessage Object - 1/19/2021
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

- [ ] Lab Module needs to update list when research is finished (Needs testing)


- [X] LSS View 3/3 -> Each Peripheral should have its own Detail View and actions
- [X] Fix LSS View update issues
- [X] LSS View -> Improve Peripherals
- [X] Accounting should use all of the energy generated first, then from batteries

- [ ] Free Supply Drop-offs -> Pay for more
- [ ] If you simulate your vehicles, you get an extra XP for the Garage
- [ ] People generator should generate new people every hour. Pay for more. And generate Materials engineer first
- [ ] LSS View -> Make 1 tab for tanks & ingredients, and another for Peripherals
- [ ] GameLoop: Auto-Accounting
- [ ] GameLoop: Look for dates (Lab Activities, Human Activities, Vehicles)
- [ ] Accounting: Make it harder for **Person** to be happy on their own
- [ ] Person: Have action(s) to make **Person** happier

- [X] 5/21 Scene Improvements
    - [X] Cleanup Original Scene
    - [X] SCNNodes Classes (Roboarm, Antenna, Radiator, Delivery Vehicle)
    - [X] 3/3 Ship Animation (Needs better particle emitter, plus open the shell)
    - [X] Particle emitter on all engines
    - [X] Animate particle emission correctly
    - [X] Fix Model underneath lid
    - [X] Earth with Emission
    - [X] Implement 'Skin' on all Modules
    - [ ] Blender Monkey inside Helmet
    - [ ] Blender Individual Tanks
    - [ ] Improve Background HDRI image
    - [ ] Reskin Delivery Vehicle
    - [ ] Remodel Space Vehicle
    - [ ] Earth Revealage
    - [ ] Build Dock 3D Model
    - [ ] Add light and transluscent sphere to Dock
    - [ ] 5 Models of Antenna
    - [ ] Roboarm animation
    - [ ] Load more items of Scene in StationBuilder
    - [ ] Breakdown Scene in Main Components - Nodes, Modules, Lights, Camera, etc.
    - [ ] Camera positions + Sphere node
    - [ ] Unbuild Module
    - [ ] StationBuilder Object - 01/16/2021
        - [X] Make Skin Work
        - [X] Remake of Builder -> SceneBuilder to replace 'BuildItem'
        - [X] Simplify Builder
        - [X] Add Modules 7 ... 10
        - [ ] Lights (Roboarm, Garage in, Garage out, Cuppola, Airlock) + User control
        - [ ] Load Skin on all Modules
    
    - [X] Truss View creation
        - [X] Solar Panel positions
        - [X] Control where each solar panel goes
        - [ ] Control where each Radiator goes
    - [X] 1/3 Notify scene when tech is ready (not working)
        - [X] Update Scene
        - [ ] Show  News
        - [X] Scene is showing Serial builder ahead of time. Check isUnlocked vs isResearched
        - [ ] Live update of tech
        
        
- [ ] 6/13 Scene Overlay
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
    - [ ] Helmet Icon
    - [ ] Put icons inside buttons
    - [ ] Time Token Icon (Helmet)
    - [ ] Add colors / shaders
    - [ ] 1/3 Camera options + animations
        - [X] Perspective view
        - [X] Garage View - CameraBack
        - [X] Front View - CameraFront
        - [ ] Bring Regular Camera Closer to Scene
        - [ ] Adjust Scaling (Focal Length)? of Cameras
        - [ ] Adjust animation with midpoints
        
- [ ] 4/8 Garage View Improvements
    - [X] Time to create SpaceVehicle
    - [X] Circular progress View
    - [X] Transfer Building Vehicles to Built Vehicles automatically
    - [X] Vehicle Row improvements
    - [X] Better Vehicle Assembly
    - [ ] Initial Push (Fuel)
    - [ ] Trajectory (+animations ?)
    
- [ ] 7/13 Basic Views
    - [X] Ingredients and sufficiency
    - [X] Create a general Header View in SwiftUI for all SwiftUI base views
    - [X] Improve People Selection View - Add a mark so user knows when they are selected
    - [X] Improve Timer View 
    - [ ] Improve General Header View
    - [ ] Pass functions (Change skin, Rename, etc.)
    - [ ] Error messages
    - [ ] Remove Horizontal Scrollers

## 📝 To Do - Future
Grab things from this list as you go along.

- [X] 5/8 Accounting
    - [X] Basic Accounting (testable)
    - [X] Person's happiness (if cuppola, airlock, etc.)
    - [X] View Accounting Problems
    - [X] Accounting Problems
    - [X] Accounting Report object
    - [ ] Vehicle Accounting View

- [ ] 0/21 Server
    - [ ] Server test address
    - [ ] Player Object(s)
    - [ ] Free Deliveries
    - [ ] Available Humans for delivery
    - [ ] Guilds
    - [ ] Token Validation

- [ ] 8/13 Data Model
    - [X] Accounting Adjustments
    - [ ] 0/8 Mars Model
    - [ ] 5/8 TechTree improvements (Tree improved, Add Antenna upgrades, Charge ingredients, electricity, Select Humans, Fix Time)
        - [X] 22 Items
        - [ ] Antenna Updates
        - [ ] Improve and use PlayerObject
        

        
- [ ] 1/3 iOS View Presentation
    - [X] Present view on iPad
    - [X] View dismissal
    - [X] Test iPhone View sizes
    - [ ] Adjust iPhone View sizes


- [ ] 1/13 Create Mars Scene
- [ ] 0/21 Mars Views & Controllers
- [ ] 0/13 Create Server
- [ ] 0/3 Create Loading initial screen


## 📝 Done - Past
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
