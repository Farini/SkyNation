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
    @State var serveBiobox:Bool = GameSettings.shared.serveBioBox
    @State var startingScene:GameSceneType = GameSettings.shared.startingScene
    @State var autoStart:Bool = GameSettings.shared.autoStartScene ?? false
    
    @State var musicOn:Bool = GameSettings.shared.musicOn
    @State var soundFXOn:Bool = GameSettings.shared.soundFXOn
    
    init() {
        self.settings = GameSettings.shared
    }
    
    var body:some View {
        ScrollView {
            VStack(alignment:.leading) {
                
                Group {
                    Text("📺 Graphics")
                        .font(GameFont.title.makeFont())
                        .padding(.top)
                    
                    Toggle("Lighting boost", isOn:$showLights)
                        .onChange(of: showLights) { _ in self.saveSettings() }
                    
                    Text("* Renders complex shadows and more textures.")
                        .foregroundColor(.gray)
                        .font(.footnote)
//                        .frame(maxWidth:250)
                }
                
                
                // Enhanced Shadows
                // Enhanced Emitters
                // Complex Lighting (scenes with more lighting details)
                
                Divider()
                
                HStack(alignment:.top, spacing:12) {
                    VStack(alignment: .leading) {
                        Text("🎮 Gameplay")//.font(.title)
                            .font(GameFont.title.makeFont())
                        
                        Toggle("Clear empty tanks", isOn:$clearTanks)
                        // Explanation
                        Text("* When a tank is empty, it is thrown away whether it is reusable or not.")
                            .foregroundColor(.gray)
                            .font(.footnote)
                            .frame(maxWidth:250)
                            .onChange(of: clearTanks) { _ in self.saveSettings() }
                        
                        Toggle("Auto merge Tanks", isOn:$mergeTanks)
                        Text("* Marries tanks of the same type that are half-full, so you can get empty tanks faster.")
                            .foregroundColor(.gray)
                            .font(.footnote)
                            .frame(maxWidth:250)
                            .onChange(of: mergeTanks) { _ in self.saveSettings() }
                        
                        Toggle("Serve Biobox", isOn: $serveBiobox)
                        Text("* In the Station, you may serve the food from the Biobox, or save it to transport.")
                            .foregroundColor(.gray)
                            .font(.footnote)
                            .frame(maxWidth:250)
                            .onChange(of: serveBiobox) { _ in self.saveSettings() }
                        
                        
//                        Toggle("Show Tutorial", isOn:$showTutorial)
//                            .onChange(of: showTutorial) { _ in self.saveSettings() }
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("🔉 Sounds")//.font(.title)
                            .font(GameFont.title.makeFont())
                        
                        Toggle("Sound Track (music)", isOn:$musicOn)
                            .onChange(of: musicOn) { _ in self.saveSettings() }
                        Text("* Plays music during the game.")
                            .foregroundColor(.gray)
                            .font(.footnote)
                            .frame(maxWidth:250)
                        
                        Toggle("Sound FX", isOn:$soundFXOn)
                            .onChange(of: soundFXOn) { _ in self.saveSettings() }
                        Text("* Plays Game Sound FX.")
                            .foregroundColor(.gray)
                            .font(.footnote)
                            .frame(maxWidth:250)
                    }
                    Spacer()
                }
                
                Divider()
                Group {
                    Text("💾 Data")//.font(.title)
                        .font(GameFont.title.makeFont())
                    
                    Toggle("Auto Start", isOn:$autoStart)
                }
                
                Divider()
                
                if isSaving {
                    Image(systemName: "square.and.arrow.down")
                        .font(.title)
                        .transition(.slide.combined(with:AnyTransition.opacity))
                        .animation(.spring(response: 0.5, dampingFraction: 0.75))
                }
            }
            .padding(.horizontal)
        }
    }
    
    @State private var isSaving:Bool = false
    
    func saveSettings() {
        self.isSaving = true
        
        // Data
        settings.autoStartScene = self.autoStart
        
        // Graphics
        settings.showLights = self.showLights
        
        // Logic preferences
        settings.clearEmptyTanks = self.clearTanks
        settings.showTutorial = self.showTutorial
        settings.serveBioBox = self.serveBiobox
        
        // Sounds
        settings.musicOn = self.musicOn
        settings.soundFXOn = self.soundFXOn
        settings.dialogueOn = self.soundFXOn
        
        settings.save()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            self.isSaving = false
        }
    }
    
}


struct SettingsPlayerPreview: PreviewProvider {
    static var previews:some View {
        TabView {
            let controller = GameSettingsController()
            
            // Settings
            GameSettingsTabView()
                .tabItem {
                    Label("Settings", systemImage:"gamecontroller")
                }
            // Game
            GameLoadingTab(controller:controller)
                .tabItem {
                    Label("Game", systemImage:"gamecontroller")
                }
            // Server
            GuildBrowser(controller: controller)
//            SettingsServerTab(controller:controller)
//                .tabItem {
//                    Label("Server", systemImage:"gamecontroller")
//                }
            
            // Player
            PlayerEditorView(controller:controller)
                .tabItem {
                    Label("Player", systemImage:"gamecontroller")
                }
        }
        .preferredColorScheme(.dark)
    }
}

