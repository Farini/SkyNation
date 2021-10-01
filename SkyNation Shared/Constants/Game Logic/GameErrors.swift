//
//  GameErrors.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/18/21.
//

import Foundation

// MARK: - Server Errors

// See 'ServerData' file
enum ServerDataError:Error {
    
    /// Also useful for when an OutpostData doesn't exist on server.
    case noOutpostFile // Server response, that is
    
    /// LocalDatabase doesn't have a server data file
    case noServerDataFile
    
    /// Returned when performing player authorized login
    case failedAuthorization
}

/// An Error occurred when Contributing to Outpost (supply)
enum OPContribError:Error {
    
    case missingOutpostID
    case badSupplyData
    case outdated
    case serverDecodingData // Server could not decode its own data
    case serverWritingData  // Server could not write new data to file
    
}

/*
 (Not sure we need to use it)
 enum MGuildState:Error {
 case loaded
 case serverDown
 case badRequest
 case locally
 case notJoined
 case nonExistant
 case other(error:Error)
 }
 */

/*
 /// Ways in which a login can fail
 enum LogFail:Error {
 case noID
 case noPass
 }
 */

/// The default `error` response from server, when not requested object.
struct GameError:Codable {
    var error:Bool
    var reason:String
    
    func isNotFound() -> Bool {
        return reason == "Not Found"
    }
    
    /// Returns true is server can't decode an Object
    func isDecodingProblem() -> Bool {
        return reason.contains("Decoding") || reason.contains("decoding")
    }
}

enum AddingTrussItemProblem:Error {
    case NoAvailableComponent
    case ItemAlreadyAssigned
    case Invalidated
}

extension AddingTrussItemProblem: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .NoAvailableComponent:
                return NSLocalizedString("No available Truss component", comment: "")
            case .ItemAlreadyAssigned:
                return NSLocalizedString("This item has already been assigned", comment: "")
            case .Invalidated:
                return NSLocalizedString("Unknown error", comment: "")
        }
    }
}
