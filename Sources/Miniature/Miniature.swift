import Combine
import Foundation

public struct Miniature<T> {
    var onLocal: (() -> T?)
    var onRemote: (() -> AnyPublisher<T, Error>)
    var refreshLocal: ((T) -> Void)

    public init(
        onLocal: @escaping () -> T?,
        onRemote: @escaping () -> AnyPublisher<T, Error>,
        updateLocal: @escaping (T) -> Void
    ) {
        self.onLocal = onLocal
        self.onRemote = onRemote
        self.refreshLocal = updateLocal
    }

    public func publish(
        _ action: @escaping (MiniatureStatus<T>) -> Void
    ) -> AnyCancellable {
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
}
