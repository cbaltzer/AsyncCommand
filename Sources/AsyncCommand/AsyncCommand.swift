//
//  AsyncCommand.swift
//
//
//  Created by Chris Baltzer on 2022-08-04.
//

import Foundation

/**
 Wraps an external command in structured concurrency
 */
public actor Command {

    public enum Status: String {
        case ready
        case running
        case finished
        case error
    }

    public let name: String
    public let verbose: Bool
    public private(set) var status: Status = .ready

    let process: Process
    let stdOut = Pipe()
    let stdErr = Pipe()
    private var outputLog: String = ""
    private var errorLog: String = ""


    let errorPhrases: [String]

    /// The full log of the command output. (The contents of stdout and stderr, concatonated)
    public var log: String {
        var fullLog = ""
        var separator = ""
        if outputLog != "" {
            fullLog.append(outputLog)
            separator = "\n"
        }
        if errorLog != "" {
            fullLog.append("\(separator)\(errorLog)")
        }
        return fullLog.trimmingCharacters(in: .whitespacesAndNewlines)
    }


    /**
     Creates a new command.
     - parameters:
        - name: A human readable name for the command
        - command: The absolute path to the target executable
        - arguments: An array of arguments to pass to the target command
        - workingDirectory: A URL indicating which directory to run from 
        - errorPhrases: A list of phrases to search for in the output log. Any matches cause the final command status to be set to `.error`
        - verbose: Toggles printing the execution status
     */
    public init(name: String,
                command: String,
                arguments: [String]?,
                workingDirectory: URL? = nil,
                errorPhrases: [String] = [],
                verbose: Bool = false) {
        self.name = name
        self.verbose = verbose
        self.errorPhrases = errorPhrases

        process = Process()
        process.executableURL = URL(fileURLWithPath: command)
        process.arguments = arguments

        if let dir = workingDirectory, dir.isFileURL {
            process.currentDirectoryURL = workingDirectory
        }

        process.standardOutput = stdOut
        process.standardError = stdErr
    }


    /// Runs the command
    public func run() async throws {
        // Log our start/end
        if verbose { print("[\(name.uppercased())][START]") }
        defer {
            if verbose { print("[\(name.uppercased())][\(status.rawValue.uppercased())]") }
        }


        // Create the thread lock
        let semaphore = DispatchSemaphore(value: 0)


        // Unlock the thread when the process ends
        process.terminationHandler = { proc in
            self.status = .finished
            semaphore.signal()
        }


        // Our own catch here to handle unknown commands (file not found)
        do {
            try process.run()
            status = .running
        } catch {
            errorLog = error.localizedDescription
            status = .error
            return
        }


        // Caputure stdout
        stdOut.fileHandleForReading.readabilityHandler = { pipe in
            if let line = String(data: pipe.availableData, encoding: .utf8), line != "" {
                self.outputLog += line
                if self.verbose {
                    print("[\(self.name.uppercased())][STDOUT] \(line)")
                }
            }
        }

        // Capture stderr
        stdErr.fileHandleForReading.readabilityHandler = { pipe in
            if let line = String(data: pipe.availableData, encoding: .utf8), line != "" {
                self.errorLog += line
                if self.verbose {
                    print("[\(self.name.uppercased())][STDERR] \(line)")
                }
            }
        }


        // Lock the thread until the termination handler gets called (above)
        _ = semaphore.wait(wallTimeout: .distantFuture)
        try stdOut.fileHandleForReading.close()
        try stdErr.fileHandleForReading.close()
        status = .finished


        // Final error checks
        if process.terminationStatus != 0 || checkPhrases(log: log, phrases: errorPhrases) {
            status = .error
        }
    }



    private func checkPhrases(log: String, phrases: [String]) -> Bool {
        for phrase in phrases {
            if log.contains(phrase) {
                return true
            }
        }
        return false
    }
}
