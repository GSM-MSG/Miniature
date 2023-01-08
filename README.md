# Miniature

Repository pattern support library

[Document](https://gsm-msg.github.io/Miniature/documentation/miniature/)

<br>

## Contents
- [Miniature](#miniature)
  - [Contents](#contents)
  - [Requirements](#requirements)
  - [Communication](#communication)
  - [Installation](#installation)
    - [Manually](#manually)
  - [Usage](#usage)

<br>

## Requirements
- iOS 13.0+ / tvOS 13.0+ / watchOS 6.0+ / macOS 10.15+
- Swift 5+

<br>

## Communication
- If you found a bug, open an issue.
- If you have a feature request, open an issue.
- If you want to contribute, submit a pull request.

<br>

## Installation
[Swift Package Manager](https://www.swift.org/package-manager/) is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

To integrate `Miniature` into your Xcode project using Swift Package Manager, add it to the dependencies value of your Package.swift:

```swift
dependencies: [
    .package(url: "https://github.com/GSM-MSG/Miniature.git", .upToNextMajor(from: "1.1.0"))
]
```

### Manually
If you prefer not to use either of the aforementioned dependency managers, you can integrate Miniature into your project manually.

<br>

## Usage
```swift
struct Test {
    var int = 0
    
    func localData() -> Int {
        return int
    }

    func remoteData() -> AnyPublisher<Int, Error> {
        Just(2).delay(for: 2, scheduler: RunLoop.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    mutating func updateLocal(int: Int) {
        self.int = int
    }
}

final class ViewController: UIViewController {
    var bag = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        var test = Test()
        
        Miniature {
            test.localData()
        } onRemote: {
            test.remoteData()
        } refreshLocal: { value in
            test.updateLocal(int: value)
        }
        .publish { status in
            status.action { load in
                print("LOAD", load)
            } onCompleted: { complete in
                print("COMPLETE", complete)
            } onError: { err in
                print(err)
            }
        }
        .store(in: &bag)
    }
}
```
