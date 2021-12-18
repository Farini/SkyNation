//
//  GuildMDView.swift
//  SkyNation
//
//  Created by Carlos Farini on 12/15/21.
//

import SwiftUI

struct GuildMDView: View {
    
    @ObservedObject var controller:GuildRoomController
    
    @State var markdown:String = defaultMarkdown
    @State var myComments:String = "my comments"
    
//    var isPresident:Bool = false
    
    @State var isEditing:Bool = false
    
    // must know if president
    // must get chat
    
    var body: some View {
        VStack {
            // Spacer()
            HStack {
                Text("Documentation").font(GameFont.section.makeFont())
                Spacer()
                Text("Char \(markdown.count) of 150")
                    .foregroundColor(markdown.count > 150 ? Color.red:Color.green)
                HStack {
                    // Markdown updates
                    Button(isEditing ? "Update":"Edit") {
                        print("Update")
                        if isEditing == true {
                            controller.commitMarkdown(markdown: markdown)
                        }
                        isEditing.toggle()
                    }
                    .disabled(!controller.iAmPresident())
//                    .disabled(controller.player.id != controller.guildMap?.president ?? UUID())
                    .buttonStyle(GameButtonStyle())
                    // Markdown comments (citizens comments - the guild chat)
                    // president can clear comments (will reset count of comments)
                    if !isEditing {
                        Button("Comment") {
                            print("Comment")
                        }
                        .buttonStyle(GameButtonStyle())
                    }
                    
                }
            }
            .padding([.top, .horizontal])
            
            Divider()
            
            if isEditing {
                HStack {
                    TextEditor(text: $markdown)
                    Text(markdown)
                        .padding(.horizontal)
                }
            } else {
                HStack(spacing:12) {
                    VStack {
                        Text(markdown)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Comments
                    VStack(alignment:.leading) {
                        Text("Comments")
                        
                        ForEach(controller.guildChat) { chatMsg in
                            HStack {
                                Text(chatMsg.name).foregroundColor(.blue)
                                Text(chatMsg.message)
                            }
                        }
                        // (no comments)
                        if controller.guildChat.isEmpty {
                            Text("No one commented yet").foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
            
            if !isEditing {
                Divider()
                HStack {
                    TextEditor(text: $myComments)
                    Button("Post") {
                        controller.postMessage(text: myComments)
                    }
                    .buttonStyle(GameButtonStyle())
                }
                .frame(height:50)
                .padding(.horizontal)
                .padding(.bottom, 6)
            }
            
        }
    }
    
    static var defaultMarkdown:String = """
    Guild Markdown
    
    Give it a nice title.
    Enumerate rules of the Guild
    
    1. Be nice
    2. Work when you can
    3. Send resources
    
    Thanks.
    The Guild
    """
}

struct GuildMDView_Previews: PreviewProvider {
    static var previews: some View {
        GuildMDView(controller: GuildRoomController())
    }
}
