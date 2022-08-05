# AsyncCommand

A structured concurrency wrapper for running external processes.


## Usage

```swift 
let homeURL = FileManager.default.homeDirectoryForCurrentUser
let path = homeURL.path + "/Desktop"

let ffmpeg = Command(name: "ffmpeg",
                     command: "/usr/local/bin/ffmpeg",
                     arguments: [
                        "-y",
                        "-i", "\(path)/big_buck_bunny_720.mov",
                        "-c:v", "hevc_videotoolbox",
                        "\(path)/big_buck_bunny_h265.mp4"
                     ],
                    verbose: true)
                    
try await ffmpeg.run()
```


## Error Phrases

Sometimes a script or tool might not actually exit with non-zero in
the case of an error. The `errorPhrases` parameter takes a list of 
strings which are used to indicate that the command has failed.  
The output of the command is searched for these phrases, setting the
`status` to `.error` if there's a match, regardless of what the 
command returns.

 
