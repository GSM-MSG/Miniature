import Combine
import Foundation

public struct Miniature<T> {
    var onLocal: (() -> T?)
    var onRemote: (() -> AnyPublisher<T, Error>)?
    var onAsyncRemote: (() async throws -> T)?
    var refreshLocal: ((T) -> Void)

    public init(
        onLocal: @escaping () -> T?,
        onRemote: @escaping () -> AnyPublisher<T, Error>,
        refreshLocal: @escaping (T) -> Void
    ) {
        self.onLocal = onLocal
        self.onRemote = onRemote
        self.onAsyncRemote = nil
        self.refreshLocal = refreshLocal
    }

    public init(
        onLocal: @escaping () -> T?,
        onRemote: @escaping () async throws -> T,
        refreshLocal: @escaping (T) -> Void
    ) {
        self.onLocal = onLocal
        self.onRemote = nil
        self.onAsyncRemote = onRemote
        self.refreshLocal = refreshLocal
    }

    public func publish(
        _ action: @escaping (MiniatureStatus<T>) -> Void
    ) -> AnyCancellable {
        guard let onRemote else { fatalError(MiniatureError.notInitializeClosure.localizedDescription) }
        let localData = onLocal()
        action(.loading(localData))
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

    public func asyncPublish(
        _ action: @escaping (MiniatureStatus<T>) -> Void
    ) async {
        do {
            guard let onAsyncRemote else { fatalError(MiniatureError.notInitializeClosure.localizedDescription) }
            let localData = onLocal()
            action(.loading(localData))
            let remoteData = try await onAsyncRemote()
            refreshLocal(remoteData)
            action(.completed(remoteData))
        } catch {
            action(.error(error))
        }
    }
}
