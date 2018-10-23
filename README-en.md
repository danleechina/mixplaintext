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

1. Open your project which needs to be obscured. In the Build Phases session of target, add a new Run Script, make sure this is before Compile Souces. The content of script is like below:
 
 	```
     # 默认是 Debug 情况下运行，可根据需要自定义，比如 Release
     if [ "${CONFIGURATION}" = "Debug" ]; then
     # 注意由于你的工程目录可能包含 Pods 这类第三方代码，所以你需要切换到你自己代码所在的目录比如 MixIosDemo 目录
     cd MixIosDemo
     chmod +x ../mix.swift
     ../mix.swift
     fi
	```
	
3. add MixIosDemo/MixOC/MixDecrypt.h in your project
4. import MixDecrypt.h in your project's pch header

You can watch MixIosDemo for detail setting

# Custom encrypt or obscure

The default encrypt method is xor(maybe it just obscrue the plain text). Two steps to custom encrypt or obscure.

1. Modify encrypt method in mix.swift
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
