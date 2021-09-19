//
//  GameSettingsTabView.swift
//  SkyNation
//
//  Created by Carlos Farini on 9/19/21.
//

import SwiftUI

// MARK: - Tab4: Settings
struct GameSettingsTabView: View {
    
    var settings:GameSettings
    
    @State var showTutorial:Bool = GameSettings.shared.showTutorial
    @State var useCloudData:Bool = GameSettings.shared.useCloud
    @State var showLights:Bool = GameSettings.shared.showLights
    @State var clearTanks:Bool = GameSettings.shared.clearEmptyTanks
    @State var mergeTanks:Bool = GameSettings.shared.autoMergeTanks
    @State var startingScene:GameSceneType = GameSettings.shared.startingScene
    
    
    @State var musicOn:Bool = GameSettings.shared.musicOn
    @State var soundFXOn:Bool = GameSettings.shared.soundFXOn
    
    init() {
        self.settings = GameSettings.shared
    }
    
    var body:some View {
        ScrollView {
            VStack(alignment:.leading) {
                
                Text("Graphics").font(.title)
                Toggle("Show Lights", isOn:$showLights)
                
                Divider()
                
                HStack(alignment:.top) {
                    VStack(alignment: .leading) {
                        Text("Gameplay").font(.title)
                        Picker(selection: $startingScene, label: Text("Main Scene")) {
                            ForEach(GameSceneType.allCases, id:\.self) { sceneCase in
                                Text(sceneCase.rawValue)
                                    .onTapGesture {
                                        print("Set another scene")
                                    }
                            }
                        }
                        .frame(maxWidth: 200)
                        Toggle("Clear empty tanks", isOn:$clearTanks)
                        Toggle("Auto merge Tanks", isOn:$mergeTanks)
                        Toggle("Show Tutorial", isOn:$showTutorial)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Sounds").font(.title)
                        Toggle("Music", isOn:$musicOn)
                        Toggle("Sound FX", isOn:$soundFXOn)
                        Toggle("Dialogue", isOn:$soundFXOn)
                    }
                    Spacer()
                }
                
                Divider()
                Group {
                    Text("Data").font(.title)
                    Toggle("Use iCloud", isOn:$useCloudData)
                }
                
                Divider()
                
                Button("Save") {
                    print("Save Settings")
                    
                    // Data
                    settings.useCloud = self.useCloudData
                    
                    // Graphics
                    settings.showLights = self.showLights
                    
                    // Logic preferences
                    settings.clearEmptyTanks = self.clearTanks
                    settings.showTutorial = self.showTutorial
                    
                    // Sounds
                    settings.musicOn = self.musicOn
                    settings.soundFXOn = self.soundFXOn
                    settings.dialogueOn = self.soundFXOn
                    
                    settings.save()
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor:.blue))
            }
            .padding(.horizontal)
        }
        
    }
    
}
