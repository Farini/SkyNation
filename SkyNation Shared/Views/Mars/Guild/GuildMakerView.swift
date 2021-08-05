//
//  GuildMakerView.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/3/21.
//

import SwiftUI



struct GuildMakerView: View {
    
    @State var selectedIcon:GuildIcon = GuildIcon.allCases.randomElement()!
    @State var selectedColor:GuildColor = GuildColor.allCases.randomElement()!
    @State var name:String = "Untitled"
    @State private var tab:Tabs = .Name
    @State private var isPublic:Bool = true
    
    enum Tabs:String, CaseIterable {
        case Name, Icon, Color
    }
    
    var body: some View {
        VStack {
            Text("Guild Maker")
                .font(.title2)
                .padding(.top)
            Divider()
            
            HStack() {
                VStack {
                    Image(systemName:selectedIcon.imageName)
                        .font(.largeTitle)
                        .padding(8)
                        .background(Color.black.opacity(0.75))
                        .foregroundColor(selectedColor.color)
                        .cornerRadius(8)
                    Text(name)
                }
                .padding(32)
                
                VStack {
                    
                    Picker("", selection: $tab) { // Picker("", selection: $airOption) {
                        ForEach(Tabs.allCases, id:\.self) { tab in
                            Text(tab.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding([.leading, .trailing, .bottom])
                    
                    switch tab {
                        case .Icon:
                            LazyVGrid(columns: [GridItem(.flexible(minimum: 32, maximum: 36)), GridItem(.flexible(minimum: 32, maximum: 36)), GridItem(.flexible(minimum: 32, maximum: 36))], alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 12, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/, content: {
                                ForEach(GuildIcon.allCases, id:\.self) { icon in
                                    Image(systemName: icon.imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: .infinity, height: 32, alignment: .center)
                                        .padding(4)
                                        .background(selectedIcon == icon ? Color.black.opacity(0.75):Color.black.opacity(0.25))
                                        .border(selectedIcon == icon ? Color.white.opacity(0.5):Color.clear, width: 0.5)
                                        .cornerRadius(8)
                                        .onTapGesture {
                                            self.selectedIcon = icon
                                        }
                                }
                            })
                            .frame(minHeight:145)
                        case .Color:
                            Text("Color")
                            LazyVGrid(columns: [GridItem(.flexible(minimum: 32, maximum: 36)), GridItem(.flexible(minimum: 32, maximum: 36)), GridItem(.flexible(minimum: 32, maximum: 36))], alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 8, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/, content: {
                                ForEach(GuildColor.allCases, id:\.self) { color in
                                    
                                    ZStack {
                                        Circle()
                                            .frame(width: 34, height: 34, alignment: .center)
                                            .foregroundColor(selectedColor == color ? Color.white:Color.clear)
                                        Circle()
                                            .frame(width: 32, height: 32, alignment: .center)
                                            .foregroundColor(color.color)
                                        
                                    }
                                    
                                    .onTapGesture {
                                        self.selectedColor = color
                                    }
                                    
                                }
                            })
                            .frame(minHeight:145)
                        case .Name:
                            VStack(alignment:.leading) {
                                Spacer()
                                Text("Guild Name")
                                TextField("Guild name", text: $name)
                                    .frame(maxWidth:100)
                                Toggle("Public", isOn: $isPublic)
                                
                                Spacer()
                            }
                            .frame(minHeight:145)
                            
                            
                    }
                }
            }
            
            Divider()
            
            // Buttons
            HStack {
                Button("Cancel") {
                    
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                
                Button("Create (10 Tokens)") {
                    
                }
                .buttonStyle(NeumorphicButtonStyle(bgColor: .gray))
                .disabled(LocalDatabase.shared.player?.shopped.getSpendableTokens().count ?? 0 < 10) //timeTokens.count ?? 0 < 10)
            }
            .padding(.bottom, 6)
        }
    }
}

struct GuildMakerView_Previews: PreviewProvider {
    static var previews: some View {
        GuildMakerView()
    }
}
