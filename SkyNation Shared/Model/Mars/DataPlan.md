#  Database Plan

## Using Server

1. The data is small enough to be saved in a public CloudKit database without using too much space (per player)

- Guild
- City
- Outpost

- Person
- Peripherals
- Recipes
- Ingredients
- Tanks
- Energy
- Air

### Outpost Contribution
Use this function to check if there are upgrades

```Swift
 func runUpgrade() -> OutpostUpgradeResult
 
 enum OutpostUpgradeResult {
    case needsDateUpgrade
    case dateUpgradeShouldBeNil
 
    case noChanges
    case nextState(_ state:OutpostState)
    case applyForLevelUp(currentLevel:Int)
 }
 ```
 
 Generally `nextState` means the Server should be upgraded.
 
 
