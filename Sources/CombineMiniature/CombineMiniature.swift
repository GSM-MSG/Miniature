import Combine
import Miniature

public struct CombineMiniature<T> {
    /// `onLocal` is a closure that returns data from the local cache.
    var onLocal: () -> T?
    /// `onRemote` is an optional closure that returns data from a remote source as a publisher
    var onRemote: () -> AnyPublisher<T, Error>
    /// `refreshLocal` is a closure that updates the local cache with new data.
    var refreshLocal: (T) -> Void

    public init(
        onLocal: @escaping () -> T?,
        onRemote: @escaping () -> AnyPublisher<T, Error>,
        refreshLocal: @escaping (T) -> Void
    ) {
        self.onLocal = onLocal
        self.onRemote = onRemote
        self.refreshLocal = refreshLocal
    }

    /// Method to load data from a remote source using the `onRemote` closure and calls the provided action closure
    /// with the appropriate `MiniatureStatus` enum case.
    /// This method returns an object that conforms to AnyCancellable protocol, which can be used to cancel the task.
    public func publish(
        _ action: @escaping (MiniatureStatus<T>) -> Void
    ) -> AnyCancellable {
        let local = onLocal()
        action(.loading(local))
        let cancellable = onRemote()
            .sink { completion in
                if case let .failure(error) = completion {
                    action(.error(error))
                }
            } receiveValue: { result in
                refreshLocal(result)
                action(.completed(result))
            }
        return cancellable

    }

    public func toAnyPublisher() -> AnyPublisher<MiniatureStatus<T>, Never> {
        let local = onLocal()
        let loadingPublisher = Just(local)
            .map(MiniatureStatus.loading)

        let remotePublisher = onRemote()
            .map(MiniatureStatus.completed)
            .catch { error in
                Just(MiniatureStatus.error(error))
                    .eraseToAnyPublisher()
            }
        
        return loadingPublisher
            .merge(with: remotePublisher)
            .eraseToAnyPublisher()
    }

}
