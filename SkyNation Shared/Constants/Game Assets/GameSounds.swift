//
//  GameSounds.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/18/21.
//

import Foundation

// MARK: - Sounds

/// Names of the soundtrack (music) to play.
enum Soundtrack:String, CaseIterable {
    case SKN_T1
    case SKN_T2
    case SKN_T3
}

/// Sound Effects like selecting, closing, etc.
enum SoundFX:String, CaseIterable {
    case Selected
    case Close
    
    var soundName:String {
        switch self {
            case .Selected: return "SFXSelected.wav"
            case .Close: return "SFXClose.way"
        }
    }
}
