import Foundation

/// The `MiniatureStatus` Enum defines the possible states of data loading: loading, completed, and error.
public enum MiniatureStatus<T> {
    case loading(T?)
    case error(Error)
    case completed(T)

    /// Helper function to handle the enum case
    public func action<V>(
        onLoading: (T?) -> V,
        onCompleted: (T) -> V,
        onError: (Error) -> V
    ) -> V {
        switch self {
        case let .loading(load):
            return onLoading(load)

        case let .completed(value):
            return onCompleted(value)

        case let .error(error):
            return onError(error)
        }
    }
}
