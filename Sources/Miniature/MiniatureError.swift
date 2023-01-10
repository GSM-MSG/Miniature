import Foundation

/// The `MiniatureError` Enum defines an error that can occur when the `publish` method is called
/// without initializing the onRemote or onAsyncRemote closure.
public enum MiniatureError: Error {
    case notInitializeClosure
}

/// Extension to add localized description to the error.
extension MiniatureError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notInitializeClosure:
            return "'publish' without initializing."
        }
    }
}
