import XCTest
@testable import AsyncCommand

final class AsyncCommandTests: XCTestCase {
    
    func testValidCommand() async throws {
let pycount = Command(name: "PyCount",
                      command: "/usr/local/bin/python3",
                      arguments: [
                        "-c",
                        "for i in range(1,11):print(i)"
                      ],
                      errorPhrases: ["3"],
                      verbose: false)
        let pythonCounter = Command(name: "PyCount", command: "/usr/local/bin/python3", arguments: [
            "-c",
            "for i in range(1,11):print(i)"
        ])
        try await pythonCounter.run()

        let log = await pythonCounter.log
        XCTAssertEqual(log, "1\n2\n3\n4\n5\n6\n7\n8\n9\n10")

        let status = await pythonCounter.status
        XCTAssertEqual(status, Command.Status.finished)
    }


    func testInvalidCommand() async throws {
        let which = Command(name: "which", command: "which", arguments: ["python3"], verbose: false)
        try await which.run()

        let log = await which.log
        XCTAssertEqual(log, "The file “which” doesn’t exist.")

        let status = await which.status
        XCTAssertEqual(status, Command.Status.error)
    }


    func testErrorPhrase() async throws {
        let pythonCounter = Command(name: "PyCount", command: "/usr/local/bin/python3", arguments: [
            "-c",
            "for i in range(1,11):print(i)"
        ], errorPhrases: ["3"])
        try await pythonCounter.run()

        let log = await pythonCounter.log
        XCTAssertEqual(log, "1\n2\n3\n4\n5\n6\n7\n8\n9\n10")

        let status = await pythonCounter.status
        XCTAssertEqual(status, Command.Status.error)
    }
}
