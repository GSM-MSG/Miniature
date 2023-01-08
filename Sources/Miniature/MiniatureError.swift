import Foundation

public enum MiniatureError: Error {
    case notInitializeClosure
}

extension MiniatureError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notInitializeClosure:
            return "'publish' without initializing."
        }
    }
}
