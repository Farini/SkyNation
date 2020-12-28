# SkyNation
Welcome to the SkyNation repository. This is a space exploration MMO type of game. I've been working on it for a few years. 
The recent technology allows the combination of SwiftUI, SceneKit, and SpriteKit to work together and make this game's production easier and faster.
The reason this repository is public for now is that I would like to find people like you. People that are browsing projects, and trying to find something cool to work on.
I intend to pull this project out of its **public** state to a **private repository** around February, 2021.
If you are a Blender artist, or can program in Swift any of the frameworks mentioned above, or Swift Vapor for this game's server, don't hesitate to contact me.
Feel free to take a look at the *ToDo* list, make suggestions, etc.

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
 - [ ] ★☆☆☆☆ Accounting System
 - [ ] ★☆☆☆☆ Truss
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
 - [ ] ★★☆☆☆ Scenes Overlay (Camera, Vehicles list, etc.)
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

- [X] 3/8 Accounting
    - [X] Basic Accounting (testable)
    - [X] Person's happiness (if cuppola, airlock, etc.)
    - [X] View Accounting Problems
    - [ ] Vehicle Accounting View
    - [ ] Accounting Previews
    - [ ] Save Accounting Problems
    - [ ] Accounting Report object
    
- [X] 2/13 Scene Improvements
    - [X] Truss View creation
        - [ ] Solar Panel positions
        - [ ] Control where each solar panel goes
    - [X] 1/3 Notify scene when tech is ready (not working)
        - [ ] Update Scene
        - [ ] Show News
        - [ ] Scene is showing Serial builder ahead of time. Check isUnlocked vs isResearched
        
- [ ] 2/8 Garage View Improvements
    - [X] Time to create SpaceVehicle
    - [X] Circular progress View
    - [X] Transfer Building Vehicles to Built Vehicles automatically
    - [ ] Initial Push (Fuel)
    - [ ] Trajectory (+animations ?)
    - [ ] Vehicle Row improvements
    
- [ ] 5/13 Scene Overlay
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
    - [ ] Put icons inside buttons
    - [ ] Time Token Icon
    - [ ] Delivery Token Icon
    - [ ] Add colors / shaders
    - [ ] 1/3 Camera options + animations
        - [ ] Orthographic / Perspective view control
        - [ ] Garage View (From behind)
        - [ ] Front View
    
    
- [ ] 1/3 iOS View Presentation
    - [X] Present view on iPad
    - [X] View dismissal
    - [ ] Test iPhone View sizes

- [ ] 7/13 Basic Views
    - [X] Ingredients and sufficiency
    - [X] Create a general Header View in SwiftUI for all SwiftUI base views
    - [X] Improve People Selection View - Add a mark so user knows when they are selected
    - [X] Improve Timer View 
    - [ ] Improve General Header View
    - [ ] Pass functions (Change skin, Rename, etc.)
    - [ ] Error messages

## 📝 To Do - Future
Grab things from this list as you go along.

- [ ] 0/21 Server
    - [ ] Server test address
    - [ ] Player Object(s)
    - [ ] Free Deliveries
    - [ ] Available Humans for delivery
    - [ ] Guilds

- [ ] 8/13 Data Model
    - [ ] 5/8 TechTree improvements (Tree improved, Add Antenna upgrades, Charge ingredients, electricity, Select Humans, Fix Time)
        - [X] 22 Items
        - [ ] Antenna Updates
        - [ ] Improve and use PlayerObject

- [ ] 3/13 Station Scene
    - [ ] Improve Background HDRI image
    - [ ] Loading
    - [ ] Lights (Roboarm, Garage in, Garage out, Cuppola, Airlock) + User control
    - [ ] Roboarm animation
    - [ ] Earth Revealage
    - [ ] Earth Light Emission
    - [ ] Implement 'Skin' on all Modules
    - [ ] 1/3 Cleanup Original Scene
    - [ ] Simplify Builder (Delete orientation, etc.) - Questionable
    - [ ] Add Modules 7 ... 10
    - [ ] 1/3 Ship Animation (Needs better particle emitter, plus open the shell)
        - [ ] Particle emitter on all engines
        - [ ] Animate particle emission correctly
        - [ ] Fix Model underneath lid

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
