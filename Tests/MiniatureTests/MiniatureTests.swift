import XCTest
import Combine
import Miniature

final class MiniatureTests: XCTestCase {

    var combineMiniature: Miniature<String>!
    var asyncMiniature: Miniature<String>!
    var localData: String?
    var remoteData: String?
    var status: MiniatureStatus<String>!
    var cancellable: AnyCancellable!

    override func setUp() {
        super.setUp()
        localData = "Local Data"
        remoteData = "Remote Data"
        combineMiniature = Miniature(onLocal: {
            return self.localData
        }, onRemote: {
            return Just(self.remoteData!).delay(for: 3, scheduler: RunLoop.main)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }, refreshLocal: { value in
            self.localData = value
        })
        asyncMiniature = Miniature(onLocal: {
            return self.localData
        }, onRemote: {
            await Task {
                self.remoteData!
            }.value
        }, refreshLocal: { value in
            self.localData = value
        })
    }

    override func tearDown() {
        cancellable?.cancel()
        super.tearDown()
    }

    func testPublish() {
        let expectation = self.expectation(description: "Data should be fetched")

        cancellable = combineMiniature.publish { (status) in
            self.status = status
            if case .loading(let value) = status {
                XCTAssertEqual(value, self.localData)
            }
            if case .completed(let value) = status {
                XCTAssertEqual(value, self.remoteData)
                XCTAssertEqual(self.remoteData, self.localData)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testAsyncPublish() async {
        let expectation = self.expectation(description: "Data should be fetched")

        await asyncMiniature.asyncPublish { (status) in
            self.status = status
            if case .loading(let value) = status {
                XCTAssertEqual(value, self.localData)
            }
            if case .completed(let value) = status {
                XCTAssertEqual(value, self.remoteData)
                XCTAssertEqual(self.remoteData, self.localData)
                expectation.fulfill()
            }
        }
        await waitForExpectations(timeout: 5, handler: nil)
    }
}
