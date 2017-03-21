# MixPlainText

This project aims to encypt or obscure plain text for all the Objective C implement files(extension name 'm') in iOS project. So no plain text in your app's binary file.

# Features

1. Simple. Developer can hard code plain text in iOS project, all the operation like encrypting or obscuring will automatically run before compiling.
2. Customable of encrypting or obscuring(because decrypting happens in app's running, the way of encrypting should be fast and easy) which improves difficulty of reverse engineering

# Limitation

1. Can't encrypt objective-c string like @"a""b" because of the default regex. Make sure change it to @"ab", or the project will not compile successfully
2. Can't encrypt escape sequences contains \nnn,\xnn, \unnnn and \Unnnnnnnn. Make sure your objective-c string doesn't contain these.
3. Can't encrypt static type string

# Usage scenario

1. Using private API, let MixPlainText handle the obscring, make sure don't invoke private API when in the Apple approval process
2. Improving the difficulty of reverse analysis

# Usage

1. Compile macOS project Mix/Mix.xcodeproj, put the product "Mix" binary into your project's root directory.
2. Open your project which needs to be obscured. In the Build Phases session of target, add a new Run Script, make sure this is before Compile Souces. The content of script is like below:
 
 	```
 	# default runs in Release, custom it in your need
	if [ "${CONFIGURATION}" = "Release" ]; then
	./Mix
	fi
	```
	
3. add MixIosDemo/MixOC/MixDecrypt.h in your project
4. import MixDecrypt.h in your project's pch header

You can watch MixIosDemo for detail setting

At present, Swift file can be run like script. Because the Mix binary was written by Swift, you can also add `swift xxx.swift` to your packaging shell (Be sure your Swift version is 3.0 or above, and the xxx.swift is just Mix/Mix/main.swift in the repo)

# Custom encrypt or obscure

The default encrypt method is xor(maybe it just obscrue the plain text). Two steps to custom encrypt or obscure.

1. Modify encrypt method in Mix/Mix/main.swift, compile project, replace your project's Mix binary file with the new Mix file.
2. Modify decrypt method in dl_getRealText function in MixDecrypt.h

Attention, don't use complex encyrpt/decyrpt method, and make sure encyrpt/decyprt right, or the running will fail.

# TODO

1. Support C type string
2. Support file type, like mm, h, pch, c, cpp type of file.

# Contributors

Author: [@粉碎音箱的音乐(weibo)](http://weibo.com/u/1172595722) 

Blog: [Blog](http://danleechina.github.io/)

# Starring is caring

Please star if you think it is helpful to you. Thank you. 😄