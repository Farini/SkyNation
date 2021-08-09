//
//  GuildView.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/28/21.
//

import SwiftUI

struct GuildView: View {
    
    @ObservedObject var controller:GuildController
    
    var guild:GuildSummary
    
    /// Presentation Style
    var style: Style
    enum Style {
        case thumbnail
        case largeSummary
        case largeDescriptive
    }
    var displayingAsCard: Bool {
        style == .largeSummary || style == .largeDescriptive
    }
    var shape = RoundedRectangle(cornerRadius: 16, style: .continuous)
    
    
    private enum FaceSide {
        case citizens, cities, outposts, preferences
    }
    @State private var face:FaceSide = .citizens
    
    var closeAction: () -> Void = {}
    var flipAction: () -> Void = {}
    
    init(controller:GuildController, guild:GuildSummary, style:GuildView.Style) {
        self.controller = controller
        self.guild = guild
        self.style = style
    }
    
    var body: some View {
        
        VStack {
            
            VStack {
                Image(systemName: GuildIcon(rawValue: guild.icon)!.imageName)
                    .font(.largeTitle)
                    .foregroundColor(GuildColor(rawValue: guild.color)!.color)
                    .padding(.bottom, 4)
                
                Text("\(guild.name)")
                    .font(.title2)
                    .foregroundColor(.yellow)
                
                Divider()
            }
            .frame(minWidth: 100, maxWidth: 120, minHeight: 72, maxHeight: 82, alignment: .center)
            .padding(.top, 8)
            
            
            VStack {
                
                
                if displayingAsCard {
                    
                    switch face {
                        case .citizens:
                            Text("Citizens: \(guild.citizens.count)")
                                .foregroundColor(style == .largeDescriptive ? Color.white:Color.yellow)
                                .font(style == .largeSummary ? .title3:.body)
                            
                            ForEach(guild.citizens, id:\.self) { citizenID in
                                Text(citizenID.uuidString.prefix(6))
                                    .padding(2)
                            }
                            
                        case .cities:
                            Text("Cities: \(guild.cities.count)")

                            ForEach(guild.cities, id:\.self) { city in
                                
                                Text("City: \(String(city.uuidString.prefix(6)))")
                                
                            }
                            if guild.cities.isEmpty == true {
                                Text("No Cities were started").foregroundColor(.gray)
                            }
                            
                        case .outposts:
                            Text("Outposts go here")
                        case .preferences:
                            Text("Preferences")
                            Text("Openness: \(guild.isOpen ? "Yes":"No")")
                    }
                    
                    Spacer()
                    
                    Divider()
                    
                    HStack {
                        if guild.citizens.count <= 9 {
                            Button("Join") {
                                controller.requestJoinGuild(guild: guild)
                            }
                            .buttonStyle(NeumorphicButtonStyle(bgColor: .green))
                            .disabled(LocalDatabase.shared.player?.guildID == guild.id)
                            Divider()
                        }
                        Button("Flip") {
                            self.flipToNext()
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor: .green))
                    }
                    .frame(height:32)
                    .padding(.bottom, 8)
                    
                    
                    
                } else {
                    Text("👤 \(guild.citizens.count)").padding(2)
                    Text("🌆 \(guild.cities.count)").padding(2)
                    Text("⚙️ \(guild.outposts.count)").padding(2)
                    //                    Text("📆 \(GameFormatters.dateFormatter.string(from: guild.election))")
                }
            }
            
            .frame(width: displayingAsCard ? 220:150, height: displayingAsCard ? 300:100, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .clipShape(shape)
            
            .accessibilityElement(children: .contain)
        }
        .background(GameColors.transBlack)
        .cornerRadius(16)
        .overlay(
            shape
                
                .inset(by: 0.5)
                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                
                
        )
        .contentShape(shape)
        
        
    }
    
    var backScene: some View {
        GeometryReader { geo in
            generateBarcode(from: guild.id)!
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geo.size.width, height: geo.size.height)
                .scaleEffect(displayingAsCard ? 1.0 : 0.5)
//                .offset(x: displayingAsCard ? 1.0 : 0.5)
                .frame(width: geo.size.width, height: geo.size.height)
                .scaleEffect(x: style == .largeDescriptive ? -1 : 1)
        }
        .accessibility(hidden: true)
    }
    
    func flipToNext() {
        switch face {
            case .citizens:
                self.face = .cities
            case .cities:
                self.face = .outposts
            case .outposts:
                self.face = .preferences
            case .preferences:
                self.face = .citizens
        }
    }
    
    func generateBarcode(from uuid: UUID) -> Image? {
        let data = uuid.uuidString.prefix(8).data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            
            if let output:CIImage = filter.outputImage {
                
                if let inverter = CIFilter(name:"CIColorInvert") {
                    
                    inverter.setValue(output, forKey:"inputImage")
                    
                    if let invertedOutput = inverter.outputImage {
                        #if os(macOS)
                        let rep = NSCIImageRep(ciImage: invertedOutput)
                        let nsImage = NSImage(size: rep.size)
                        nsImage.addRepresentation(rep)
                        return Image(nsImage:nsImage)
                        #else
                        let uiImage = UIImage(ciImage: invertedOutput)
                        return Image(uiImage: uiImage)
                        #endif
                    }
                    
                } else {
                    #if os(macOS)
                    let rep = NSCIImageRep(ciImage: output)
                    let nsImage = NSImage(size: rep.size)
                    nsImage.addRepresentation(rep)
                    return Image(nsImage:nsImage)
                    #else
                    let uiimage = UIImage(ciImage: output)
                    return Image(uiImage: uiimage)
                    #endif
                }
            }
        }
        
        return nil
    }
}

struct GuildView_Previews: PreviewProvider {
    
    static let rGuild = Guild.example.makeSummary()
    
    static var previews: some View {
        Group {
            let controller = GuildController(autologin: false)
            
            GuildView(controller: controller, guild: rGuild, style: .thumbnail)
                .frame(width: 250, height: 180)
                .previewDisplayName("Thumbnail")
            GuildView(controller: controller, guild: rGuild, style: .largeDescriptive)
                .aspectRatio(0.75, contentMode: .fit)
                .frame(width: 500, height: 400)
                .previewDisplayName("Large Descriptive")
//            GuildView(guild: rGuild, style: .largeSummary)
//                .aspectRatio(0.75, contentMode: .fit)
//                .frame(width: 500, height: 400)
//                .previewDisplayName("Large Summary")
        }
        .previewLayout(.sizeThatFits)
    }
}
