# FSEventStream command line app
 
Slightly linked to this other project: https://github.com/charlierobin/xojo-FSEventStream

That one’s a dylib, which is something I was never really terribly happy about.

This one is a command line app, which I originally did way back when, and I’m much happier about this one.

There’s a Xojo test app, just to demonstrate how it might be used within Xojo. But it should work with anything that’s got shell/subprocess/whatever it’s called capabilities. (And of course, you can run it straight from the Terminal just to check it out that way.)

Usage is: FSEvents <path> [path ...]

There’s no way of adding/removing paths once it is running. It’s designed to just run, until terminated.

Info about the really useful stuff — modified files etc — comes out in JSON.

Rather than mess around with Apple’s flags (all integers and bitmasks: [FSEventStreamEventFlags](https://developer.apple.com/documentation/coreservices/1455361-fseventstreameventflags?language=objc)) for event types, there’s a "flags" object in the JSON, with the following (possible) range of string keys (set to true):

MustScanSubDirs
UserDropped
KernelDropped
EventIdsWrapped
HistoryDone
RootChanged
Mount
Unmount
ItemCreated
ItemRemoved
ItemInodeMetaMod
ItemRenamed
ItemModified
ItemFinderInfoMod
ItemChangeOwner
ItemXattrMod
ItemIsFile
ItemIsDir
ItemIsSymlink
OwnEvent
ItemIsHardlink
ItemIsLastHardlink
ItemCloned

There’s also a "path" value, and an "id" value. "id" is in the JSON as a string, even though it comes out of FSEventStream as an integer. I was having some difficulty with that, although I think I know why that was, now. But at the time, I just changed the "id" to a string and was done with it. (I’ve never used the event id in anything anyway. It’s really only in there for a vague sense of completeness.)

There’s not a whole bunch of error checking happening in the app: it assumes that the strings you’re passing in are correct accessible paths.

There’s perhaps a bit more that could be added to the app — handling of subdirectories and other configuration (ie: [FSEventStreamCreateFlags](https://developer.apple.com/documentation/coreservices/1455376-fseventstreamcreateflags?language=objc)), some basic filtering might be nice, debouncing of multiple events all on the same file path would be good I guess — but this basic version always seemed to work well enough, and I never got around to looking at any of that extra stuff.

The Xojo test app is just to demonstrate running the app in [Shell](https://documentation.xojo.com/api/os/shell.html), handling the return data and directing the results into a [DesktopListBox](https://documentation.xojo.com/api/user_interface/desktop/desktoplistbox.html).

https://developer.apple.com/documentation/coreservices/file_system_events?language=objc

https://developer.apple.com/library/archive/documentation/Darwin/Conceptual/FSEvents_ProgGuide/Introduction/Introduction.html?language=objc#//apple_ref/doc/uid/TP40005289

