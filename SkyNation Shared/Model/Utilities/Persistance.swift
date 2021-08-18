//
//  Persistance.swift
//  SkyTestSceneKit
//
//  Created by Farini on 8/24/20.
//  Copyright © 2020 Farini. All rights reserved.
//

import Foundation

//extension Bundle {
//
//    func decode<T: Decodable>(_ type: T.Type, from file: String) -> T {
//
//        guard let url = self.url(forResource: file, withExtension: nil) else {
//            fatalError("Failed to locate \(file) in bundle.")
//        }
//
//        guard let data = try? Data(contentsOf: url) else {
//            fatalError("Failed to load \(file) from bundle.")
//        }
//
//        print("Decoding file \(file) data:\(data.description)")
//
//        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .secondsSince1970
//        decoder.dataDecodingStrategy = .deferredToData
//
//        guard let loaded = try? decoder.decode(T.self, from: data) else {
//            print("\nDecode ===\n    Decoder:\(decoder.userInfo)")
//            fatalError("Failed to decode \(file) from bundle.")
//        }
//
//        return loaded
//    }
//}
