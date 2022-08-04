# AsyncCommand

A structured concurrency wrapper for running external processes.


## Usage

```swift 
let pycount = Command(name: "PyCount",
                      command: "/usr/local/bin/python3",
                      arguments: [
                        "-c",
                        "for i in range(1,11):print(i)"
                      ],
                      errorPhrases: [
                        "3"
                      ],
                      verbose: false)
                      
try await pycount.run()
```


## Error Phrases

Sometimes a script or tool might not actually exit with non-zero in
the case of an error. The `errorPhrases` parameter takes a list of 
strings which are used to indicate that the command has failed.  
The output of the command is searched for these phrases, setting the
`status` to `.error` if there's a match, regardless of what the 
command returns.

 
