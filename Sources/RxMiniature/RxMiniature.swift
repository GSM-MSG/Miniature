import RxSwift
import Miniature

public struct RxMiniature<T> {
    var onLocal: () -> T?
    var onRemote: () -> Observable<T>
    var refreshLocal: ((T) -> Void)

    public init(
        onLocal: @escaping () -> T?,
        onRemote: @escaping () -> Observable<T>,
        refreshLocal: @escaping (T) -> Void
    ) {
        self.onLocal = onLocal
        self.onRemote = onRemote
        self.refreshLocal = refreshLocal
    }

    public func subscribe(
        _ action: @escaping (MiniatureStatus<T>) -> Void
    ) -> any Disposable {
        let local = onLocal()
        action(.loading(local))
        let disposable = onRemote()
            .subscribe { event in
                switch event {
                case let .next(remoteData):
                    refreshLocal(remoteData)
                    action(.completed(remoteData))

                case let .error(error):
                    action(.error(error))

                default:
                    break
                }
            }
        return disposable
    }
}
