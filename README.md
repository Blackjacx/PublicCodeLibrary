PublicCodeLibrary
=================

An Xcode 4 project to build a static library of my iOS library. You need to build for Simulator as well as for your favourite architecture and link all together to get a universal library.
The library simplifies daily development by providing useful and well documented code (e.g categories, wrapper classes, ...).

Next Steps / History
--------------------

- make it a CocoaPods project to support this really nice package manager
- realize Base64 coding in its own class with the group crypto to better abstract this  and be able to have some crypto classes in future
- include documentation building script
- enhance documentation
- ~~include Cocoa Limberjack Logging Framework - if not GPL~~
- give category methods "pcl_" prefix to easily find them with code completion in main project √
