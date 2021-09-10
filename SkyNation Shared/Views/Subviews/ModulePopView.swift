//
//  ModulePopView.swift
//  SkyNation
//
//  Created by Carlos Farini on 2/8/21.
//

import SwiftUI

struct ModulePopView: View {
    
    enum PopViewState {
        case menu
        case skin
        case renaming
    }
    
    @State var viewState:PopViewState = .menu
    
    @State var name:String
    
    @State var skin:ModuleSkin? {
        didSet {
            let ball:[String:Any] = ["id":self.module.id,
                                     "skin":skin!.rawValue]
            NotificationCenter.default.post(name: .changeModule, object: ball)
        }
    }
    
    @State private var isValidName:Bool = true
    @State private var isUnbuildAlert:Bool = false
    
    var module:Module
    
    var body: some View {
        switch viewState {
            case .menu:
                ScrollView {
                    VStack {
                        Text("Module Options")
                            .font(.title3)
                            .foregroundColor(.gray)
                        
                        // Rename
                        Divider()
                        HStack {
                            Text(isValidName ? "Rename":"Max 12 chars")
                                .font(.title3)
                                .padding([.leading], 6)
                            TextField("name", text: $name) { isEditing in
//                                self.isEditing = isEditing
                            } onCommit: {
                                if name.count < 12 && !name.isEmpty {
                                    print("Valid name: \(name)")
                                    self.isValidName = true
                                    let ball:[String:Any] = ["id":self.module.id,
                                                             "name":$name.wrappedValue]
                                    NotificationCenter.default.post(name: .changeModule, object: ball)
                                } else {
                                    print("Invalid name: \(name)")
                                    self.isValidName = false
                                }
                            }
                            .foregroundColor(isValidName ? .red:.blue)
                            
                            Spacer()
                        }
                        
                        // Skin
                        Divider()
                        HStack {
                            Text("Change Skin")
                                .font(.title3)
                                .padding([.leading], 6)
                            Spacer()
                        }
                        .onTapGesture {
                            changeSkin()
                        }
                        
                        // Tutorial
                        Divider()
                        HStack {
                            Text("Tutorial")
                                .font(.title3)
                                .padding([.leading], 6)
                            Spacer()
                        }
                        Divider()
                        
                        // Unbuild
                        HStack {
                            Text("Unbuild Module")
                                .font(.title3)
                                .padding([.leading], 6)
                            Spacer()
                        }
                        .onTapGesture {
                            self.isUnbuildAlert.toggle()
                        }
                        
                        
                    }
                }
                .frame(minWidth: 200, idealWidth: 250, maxWidth: 300, maxHeight: 150, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .onAppear() {
                    self.name = module.name
                }
                .alert(isPresented: $isUnbuildAlert, content: {
                    Alert(title: Text("Unbuild Module?"), message: Text("Everything that is in this module, including humans will disappear. Are you sure you want to continue?"), primaryButton: .cancel(), secondaryButton: .destructive(Text("Unbuild"), action: {
                        let ball:[String:Any] = ["id":self.module.id,
                                                 "unbuild":true]
                        NotificationCenter.default.post(name: .changeModule, object: ball)
                    }))
                })
            case .skin:
                ScrollView {
                    VStack {
                        Text("Choose Module Skin")
                        Divider()
                        ForEach(ModuleSkin.allCases, id:\.self) { mSkin in
                            HStack {
                                let isSelected = mSkin == self.skin ? true:false
                                let preText:String = isSelected ? "●":"○"
                                
                                Text("\(preText) \(mSkin.displayName)")
                                    .font(.title3)
                                    .padding([.leading], 6)
                                Spacer()
                                
                                Button("Set") {
                                    print("Set the Skin to \(mSkin)")
                                    self.skin = mSkin
                                }
                                .disabled(self.skin == mSkin)
                                .padding([.trailing], 6)
                                
                            }
                            Divider()
                        }
                    }
                }
                .frame(minWidth: 200, idealWidth: 250, maxWidth: 300, maxHeight: 150, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            case .renaming:
                VStack {
                    Spacer()
                    Text("Textfield or change")
                    Spacer()
                }
                .frame(minWidth: 200, idealWidth: 250, maxWidth: 300, maxHeight: 150, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
    }
    
    func changeSkin() {
        self.viewState = .skin
    }
}

struct ModulePopView_Previews: PreviewProvider {
    static var previews: some View {
        if let module = LocalDatabase.shared.station?.modules.first {
            ModulePopView(name: module.name, module: module)
        } else {
            let module = Module(id: UUID(), modex: .mod10)
            ModulePopView(name: module.name, module: module)
        }
        
    }
}
