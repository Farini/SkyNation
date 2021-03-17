//
//  GuildView.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/28/21.
//

import SwiftUI

struct GuildView: View {
    
    
    var guild:GuildSummary = Guild.example.makeSummary()
    
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
    
    var closeAction: () -> Void = {}
    var flipAction: () -> Void = {}
    
    var body: some View {
        
        ZStack {
            
            backScene
            
            VStack {
                Text("\(guild.name)")
                    .font(.title2)
                    .foregroundColor(.yellow)
                
                if displayingAsCard {
                    Divider()
                    
                    Text("Citizens: \(guild.citizens.count)")
                        .foregroundColor(style == .largeDescriptive ? Color.white:Color.yellow)
                        .font(style == .largeSummary ? .title3:.body)
                    
                    if style == .largeSummary {
                        ForEach(guild.citizens, id:\.self) { citid in
                            Text(citid.uuidString).foregroundColor(.gray)
                        }
                    }
                    
                    Text("Cities: \(guild.cities.count)")
                        .foregroundColor(style == .largeDescriptive ? Color.yellow:Color.white)
                        .font(style == .largeDescriptive ? .title3:.body)
                    if style == .largeDescriptive {
                        Text("City A").foregroundColor(.gray)
                        Text("City B").foregroundColor(.gray)
                        Text("City C").foregroundColor(.gray)
                    }
                    
                    HStack {
                        if guild.citizens.count <= 20 {
                            Button("Join") {
                                //                    controller.requestJoinGuild(guild: guild)
                            }
                            .buttonStyle(NeumorphicButtonStyle(bgColor: .green))
                            Divider()
                        }
                        Button("Flip") {
                            //                    controller.requestJoinGuild(guild: guild)
                        }
                        .buttonStyle(NeumorphicButtonStyle(bgColor: .green))
                    }
                    
                    
                    
                } else {
                    Text("👤 \(guild.citizens.count)")
                    Text("🌆 \(guild.cities.count)")
                    Text("⚙️ \(guild.outposts.count)")
//                    Text("📆 \(GameFormatters.dateFormatter.string(from: guild.election))")
                }
            }
            .background(GameColors.transBlack)
            
            
            
        }
        .frame(width: displayingAsCard ? 300:150, height: displayingAsCard ? 300:100, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) // .frame(minWidth: 130, maxWidth: 400, maxHeight: 500)
        .clipShape(shape)
        .overlay(
            shape
                .inset(by: 0.5)
                .stroke(Color.white.opacity(0.5), lineWidth: 2)
        )
        .contentShape(shape)
        .accessibilityElement(children: .contain)
        // .background(Color.black)
        // .cornerRadius(12)
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
    
    func generateBarcode(from uuid: UUID) -> Image? {
        let data = uuid.uuidString.prefix(8).data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            
            if let output:CIImage = filter.outputImage {
                
                if let inverter = CIFilter(name:"CIColorInvert") {
                    
                    inverter.setValue(output, forKey:"inputImage")
                    
                    if let invertedOutput = inverter.outputImage {
                        let rep = NSCIImageRep(ciImage: invertedOutput)
                        let nsImage = NSImage(size: rep.size)
                        nsImage.addRepresentation(rep)
                        return Image(nsImage:nsImage)
                    }
                    
                } else {
                    let rep = NSCIImageRep(ciImage: output)
                    let nsImage = NSImage(size: rep.size)
                    nsImage.addRepresentation(rep)
                    
                    return Image(nsImage:nsImage)
                }
                
                
            }
            
            
            //            return NSImage(ciImage: filter.outputImage)
            //            let transform = CGAffineTransform(scaleX: 3, y: 3)
            //            let out = filter.outputImage?.transformed(by:transform)
            //
            //            if let output = filter.outputImage?.transformed(by: transform) {
            //                let image = NSImage(ciImage:output)
            //                return image
            //            }
        }
        
        return nil
    }
}

struct GuildView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GuildView(style: .thumbnail)
                .frame(width: 180, height: 180)
                .previewDisplayName("Thumbnail")
            GuildView(style: .largeDescriptive)
                .aspectRatio(0.75, contentMode: .fit)
                .frame(width: 500, height: 400)
                .previewDisplayName("Large Descriptive")
            GuildView(style: .largeSummary)
                .aspectRatio(0.75, contentMode: .fit)
                .frame(width: 500, height: 400)
                .previewDisplayName("Large Summary")
        }
        .previewLayout(.sizeThatFits)
    }
}
