import Combine
import Foundation

/// The `Miniature` struct is designed to handle loading data from both local and remote sources,
/// as well as caching it locally.
public struct Miniature<T> {
    /// `onLocal` is a closure that returns data from the local cache.
    var onLocal: () -> T?
    /// `onRemote` is an optional closure that returns data from a remote source as an async task
    var onRemote: () async throws -> T
    /// `refreshLocal` is a closure that updates the local cache with new data.
    var refreshLocal: (T) -> Void

    /// Initializer that accepts onAsyncRemote closure, returns an async task that throws error
    public init(
        onLocal: @escaping () -> T?,
        onRemote: @escaping () async throws -> T,
        refreshLocal: @escaping (T) -> Void
    ) {
        self.onLocal = onLocal
        self.onRemote = onRemote
        self.refreshLocal = refreshLocal
    }

    /// Method to load data from a remote source using the `onRemote` closure and calls the provided action closure
    /// with the appropriate `MiniatureStatus` enum case.
    /// This method returns an object that conforms to AnyCancellable protocol, which can be used to cancel the task.

    /// Method to load data from a remote source using the `onAsyncRemote` closure and calls the provided action closure
    /// with the appropriate `MiniatureStatus` enum case.
    public func asyncPublish(
        _ action: @escaping (MiniatureStatus<T>) -> Void
    ) async {
        do {
            let localData = onLocal()
            action(.loading(localData))
            let remoteData = try await onRemote()
            refreshLocal(remoteData)
            action(.completed(remoteData))
        } catch {
            action(.error(error))
        }
    }
}
