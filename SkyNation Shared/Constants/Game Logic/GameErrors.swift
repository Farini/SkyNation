//
//  GameErrors.swift
//  SkyNation
//
//  Created by Carlos Farini on 8/18/21.
//

import Foundation

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

/*
 /// Ways in which a login can fail
 enum LogFail:Error {
 case noID
 case noPass
 }
 */

/*
    Common Errors:
    1. Not Connected? Check Connection
    2. Not Authenticated
    3. Server Decoding
    4. Local Decoding
    5. Saving Locally
 */

// MARK: - Server Errors

// See 'ServerData' file
enum ServerDataError:Error, CustomStringConvertible, LocalizedError  {
    
    /// Also useful for when an OutpostData doesn't exist on server.
    case noOutpostFile // Server response, that is
    
    /// LocalDatabase doesn't have a server data file
    case noServerDataFile
    
    /// Returned when performing player authorized login
    case failedAuthorization
    
    // MARK: - Descriptions
    
    var description: String {
        switch self {
            case .noOutpostFile: return "No Outpost File found."
            case .noServerDataFile: return "Could not find server data."
            case .failedAuthorization: return "Failed server authorization."
        }
    }
    
    var errorDescription: String? {
        return NSLocalizedString(description, comment: "Error")
    }
}

/// An Error occurred when Contributing to Outpost (supply)
enum OPContribError:Error, CustomStringConvertible, LocalizedError {
    
    case missingOutpostID
    case badSupplyData
    case outdated
    case serverDecodingData // Server could not decode its own data
    case serverWritingData  // Server could not write new data to file
    
    var description: String {
        switch self {
            case .missingOutpostID: return "Missing Outpost ID."
            case .badSupplyData: return "Bad Supply Data."
            case .outdated: return "Data is outdated. Needs refresh."
            case .serverDecodingData: return "Server could not decode the data sent."
            case .serverWritingData: return "Server was unable to write Decoding Data to file."
        }
    }
    
    var errorDescription: String? {
        return NSLocalizedString(description, comment: "Error")
    }
    
}

// MARK: - UI Errors

/// Error that shows when adding a Truss component to the Station.
enum AddingTrussItemProblem:Error, CustomStringConvertible, LocalizedError {
    
    case NoAvailableComponent
    case ItemAlreadyAssigned
    case Invalidated
    
    var description: String {
        switch self {
            case .NoAvailableComponent: return "No such component for Truss."
            case .ItemAlreadyAssigned: return "This item is already placed."
            case .Invalidated: return "This item has been invalidated, or removed from Truss."
        }
    }
    
    var errorDescription: String? {
        return NSLocalizedString(description, comment: "Error")
    }
}

enum CustomError: Error, CustomStringConvertible, LocalizedError, CaseIterable {
    static var allCases: [CustomError] { return [invalidPassword, .notFound] }
    
    // Throw when an invalid password is entered
    case invalidPassword
    
    // Throw when an expected resource is not found
    case notFound
    
    // Throw in all other cases
    case unexpected(code: Int)
    
    // For each error type return the appropriate description
    public var description: String {
        switch self {
            case .invalidPassword:
                return "The provided password is not valid."
            case .notFound:
                return "The specified item could not be found."
            case .unexpected(_):
                return "An unexpected error occurred."
        }
    }
    
    // For each error type return the appropriate localized description
    public var errorDescription: String? {
        switch self {
            case .invalidPassword:
                return NSLocalizedString(
                    "The provided password is not valid.",
                    comment: "Invalid Password"
                )
            case .notFound:
                return NSLocalizedString(
                    "The specified item could not be found.",
                    comment: "Resource Not Found"
                )
            case .unexpected(_):
                return NSLocalizedString(
                    "An unexpected error occurred.",
                    comment: "Unexpected Error"
                )
        }
    }
}

// When Picking Staff for Activity
enum ActivityStaffViewError: Error, CustomStringConvertible, LocalizedError {
    case missing(skills:[Skills:Int])
    case busyPerson(_ name:String)
    case unknown
    
    var description: String {
        switch self {
            case .missing(let skills): return "Missing \(skills.map({ $0.key.rawValue }).joined(separator: ", "))"
            case .busyPerson(let name): return "\(name) is busy"
            case .unknown: return "An unknown error occurred."
        }
    }
    
    var errorDescription: String? {
        return NSLocalizedString(description, comment: "Error")
    }
}
