//
//  TypographyView.swift
//  SkyNation
//
//  Created by Carlos Farini on 10/26/21.
//

import SwiftUI

struct TypographyView: View {
    var body: some View {
        
        VStack(alignment:.leading) {
            HStack(alignment: .lastTextBaseline, spacing: 12) {
                Text("Ailerons")
                    .font(Font.custom("Ailerons", size: 24))
                    .padding(.horizontal)
                    .padding(.top)
                    .foregroundColor(Color("LightBlue"))
                Text("Title: Ailerons, 24")
                Spacer()
            }
            
            
            Divider()
            
            Group() {
                
                HStack(alignment: .lastTextBaseline, spacing: 12) {
                    Text("Heading Relevant")
                        .font(Font.custom("Roboto Slab", size: 16))
                        .padding(.vertical, 6)
                    Text("Heading: Roboto Slab, 16")
                    Text("padding .vertical, 6").foregroundColor(.gray)
                }
                
                HStack(alignment: .lastTextBaseline, spacing: 12) {
                    Text("Description text")
                        .font(Font.custom("Roboto Mono", size: 14))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(3)
                        .padding(.bottom, 6)
                    Text("Paragraph: Roboto Mono, 14")
                }
                
                HStack(alignment: .lastTextBaseline, spacing: 12) {
                    Text("Detail shade text")
                        .font(Font.custom("Roboto Mono", size: 14))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(3)
                        .padding(.bottom, 6)
                        .foregroundColor(.gray)
                    Text("Paragraph: Roboto Mono, 14")
                }

                Divider()
                
                HStack {
                    VStack {
                        Text("ABCDEF 12345")
                            .font(Font.custom("Roboto Mono", size: 14))
                            .foregroundColor(.orange)
                        
                        Text("abcdef 12345")
                            .font(Font.custom("Roboto Mono", size: 14))
                        Text("FEDcba 12345")
                            .font(Font.custom("Roboto Mono", size: 14))
                            .foregroundColor(.green)
                        Text("TestMy Space")
                            .font(Font.custom("Roboto Mono", size: 14))
                            .foregroundColor(.blue)
                    }
                    VStack {
                        HStack {
                            Rectangle()
                                .foregroundColor(.orange)
                                .frame(minWidth: 20, maxWidth: 100, minHeight: 20, maxHeight: 40, alignment: .center)
                            Rectangle()
                                .foregroundColor(.green)
                                .frame(minWidth: 20, maxWidth: 100, minHeight: 20, maxHeight: 40, alignment: .center)
                            Rectangle()
                                .foregroundColor(.red)
                                .frame(minWidth: 20, maxWidth: 100, minHeight: 20, maxHeight: 40, alignment: .center)
                        }
                        HStack {
                            Rectangle()
                                .foregroundColor(Color("LightBlue"))
                                .frame(minWidth: 20, maxWidth: 150, minHeight: 20, maxHeight: 40, alignment: .center)
                            Rectangle()
                                .foregroundColor(.gray)
                                .frame(minWidth: 20, maxWidth: 150, minHeight: 20, maxHeight: 40, alignment: .center)
                        }
                        HStack {
                            Rectangle()
                                .foregroundColor(.black)
                                .frame(minWidth: 20, maxWidth: 150, minHeight: 20, maxHeight: 40, alignment: .center)
                            Rectangle()
                                .foregroundColor(Color("DarkGray"))
                                .frame(minWidth: 20, maxWidth: 150, minHeight: 20, maxHeight: 40, alignment: .center)
                        }
                        
                    }
                }
                
                
                
            }
            .padding(.horizontal)
            
            Divider()
            
            Text("Image + Selection")
                .font(Font.custom("Roboto Slab", size: 16))
                .padding(.leading)
            
            HStack {
                PeripheralObject(peripheral: .PowerGen).getImage()
                    .padding()
                    .background(Color.black)
                    .cornerRadius(8)
                
                
                PeripheralObject(peripheral: .BioSolidifier).getImage()
                    .padding()
                    .background(Color.black)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .inset(by: 0.5)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                
            }
            .padding()
            
            
            
            CautionStripeShape()
                .fill(Color.orange, style: FillStyle(eoFill: false, antialiased: true))
                .foregroundColor(Color.white)
                .frame(width: 300, height: 15, alignment: .center)
            
            Text("status message")
                .font(Font.custom("Roboto Mono", size: 14))
                .padding(.leading)
                .foregroundColor(.red)
            
            Divider()
            
            HStack {
                Spacer()
                
                Button("Action") {
                    print("Act")
                }
                .buttonStyle(GameButtonStyle())
                .padding(.bottom)
                
                
                Button("Destroy") {
                    print("Act")
                }
                .buttonStyle(GameButtonStyle(labelColor: .red))
                .padding(.bottom)
                
                Spacer()
            }
            .padding(.horizontal)
            
        }
        // .frame(width:300)
    }
}

struct GameColorsView: View {
    var body: some View {
        VStack {
            HStack(alignment: .lastTextBaseline, spacing: 12) {
                Text("Game Colors")
                    .font(Font.custom("Ailerons", size: 24))
                    .padding(.horizontal)
                    .padding(.top)
                    .foregroundColor(Color("LightBlue"))
                Spacer()
            }
            Divider()
            
            HStack {
                Text("Text Colors - Tabulated Data")
                    .font(Font.custom("Roboto Slab", size: 16))
                    .padding(.vertical, 6)
                Spacer()
            }
            .padding(.horizontal)
            
            VStack {
                HStack {
                    Text("ABCDEF 12345")
                        .font(Font.custom("Roboto Mono", size: 14))
                        .foregroundColor(.orange)
                    Spacer()
                    Text("DISABLED")
                        .font(Font.custom("Roboto Mono", size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                HStack {
                    Text("abcdef 12345")
                        .font(Font.custom("Roboto Mono", size: 14))
                    Spacer()
                    Text("White Color text")
                        .font(Font.custom("Roboto Mono", size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                HStack {
                    Text("FEDcba 12345")
                        .font(Font.custom("Roboto Mono", size: 14))
                        .foregroundColor(.green)
                    Spacer()
                    Text("Horizontal padding (10 px)")
                        .font(Font.custom("Roboto Mono", size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                HStack {
                    Text("Equal Widths")
                        .font(Font.custom("Roboto Mono", size: 14))
                        .foregroundColor(.blue)
                    Spacer()
                    Text("Horizontal padding (10 px)")
                        .font(Font.custom("Roboto Mono", size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                HStack {
                    Text("Test redtext")
                        .font(Font.custom("Roboto Mono", size: 14))
                        .foregroundColor(.red)
                    Spacer()
                    Text("Horizontal padding (10 px)")
                        .font(Font.custom("Roboto Mono", size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                
            }
            
            Divider()
            
            HStack {
                VStack(alignment:.leading) {
                    Text("Box Colors & Containers")
                        .font(Font.custom("Roboto Slab", size: 16))
                        .padding(.vertical, 6)
                    Text("Boxes should have a corner radius - 8px is preferred")
                        .foregroundColor(.gray)
                    Text("They should also be selectable in blue.")
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            
            
            HStack {
                Rectangle()
                    .foregroundColor(Color.clear)
                    .frame(minWidth: 20, maxWidth: 150, minHeight: 40, maxHeight: 50, alignment: .center)
                    .cornerRadius(8)
                
                Rectangle()
                    .foregroundColor(Color.clear)
                    .frame(minWidth: 20, maxWidth: 150, minHeight: 40, maxHeight: 50, alignment: .center)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .inset(by: 0.5)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(minWidth: 20, maxWidth: 150, minHeight: 40, maxHeight: 50, alignment: .center)
                    .cornerRadius(8)
                    
                
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(minWidth: 20, maxWidth: 150, minHeight: 40, maxHeight: 50, alignment: .center)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .inset(by: 0.5)
                            .stroke(Color.blue, lineWidth: 2)
                    )
            }
            .padding()
            
            HStack {
                Rectangle()
                    .foregroundColor(.black.opacity(0.5))
                    .frame(minWidth: 20, maxWidth: 150, minHeight: 40, maxHeight: 50, alignment: .center)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .inset(by: 0.5)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                
                Rectangle()
                    .foregroundColor(.black.opacity(0.5))
                    .frame(minWidth: 20, maxWidth: 150, minHeight: 40, maxHeight: 50, alignment: .center)
                    .cornerRadius(8)
                    
                Rectangle()
                    .foregroundColor(Color("DarkGray"))
                    .frame(minWidth: 20, maxWidth: 150, minHeight: 40, maxHeight: 50, alignment: .center)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .inset(by: 0.5)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                Rectangle()
                    .foregroundColor(Color("DarkGray"))
                    .frame(minWidth: 20, maxWidth: 150, minHeight: 40, maxHeight: 50, alignment: .center)
                    .cornerRadius(8)
                    
            }
            .padding()
        }
    }
}

struct TypographicView_Previews: PreviewProvider {
    static var previews: some View {
        TypographyView()
        GameColorsView()
            .frame(minHeight:500)
    }
}
