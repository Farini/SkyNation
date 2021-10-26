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
    
    // Downloaded
    case Adventure
    case Indreams
    case MainTheme
    
    var fileName:String {
        switch self {
            case .SKN_T1, .SKN_T2, .SKN_T3: return "\(self.rawValue).m4a"
            case .Adventure, .Indreams, .MainTheme: return "\(self.rawValue).mp3"
        }
    }
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
