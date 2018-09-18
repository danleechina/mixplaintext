If you need English document for this project, [`MixPlainText ` English document](https://github.com/danleechina/MixPlainText/blob/master/README-en.md)

# 重要

目前想到一个更好的方案，就是使用 Lex （最新的实现叫做 Flex，这个工具在 macOS 上自带） （这个工具也叫做词法分析器的生成器）。后面有时间再更新。

# MixPlainText

该项目的作用是可以将 iOS 工程所有 Objective C 实现文件（后缀名为 m 的文件）中的明文进行加密混淆，如此一来，您的 app 的二进制文件中所有的明文都是经过混淆的。之前我总结了一点如何确保 iOS app 在越狱环境下的安全性，或许值得一看：[对 iOS app 进行安全加固](https://danleechina.github.io/ios-app-security-reinforce/)

# 特点

1. 简单，开发人员可以硬编码明文字符串，所有的加密会在编译开始时自动处理
2. 可自定义加密或者混淆方式，（为了不影响 app 运行效率，需要提供一个简单快速的加密或混淆方式）提高逆向难度

# 局限

1. 不能加密这样的 OC string，比如：@"a""b"，因为默认的正则表达式无法识别这种情况，确保将其改成 @"ab"，否则无法通过编译。
2. Mix 处理过程中如果遇到 "@"，这种字符串，会编译出错，需要改一下写法，使用下面的 cs 变量
```
NSString *s = @"@";
char *cs = s.UTF8String;
```
3. 不能加密含 \nnn， \xnn， \unnnn 和 \Unnnnnnnn 这样的转义字符串，确保您的转义字符串不含这些转义，否则无法通过编译。
4. 不能加密静态类型的 string。

# 使用场景

1. 使用私有 API，将加密操作交给 MixPlainText，只要不在审核期间调用，一般能够通过审核
2. 提高逆向分析难度，因为所有明文都是经过加密混淆的，逆向分析需要先解密

# 使用方式

1. 编译运行 macOS 工程 Mix/Mix.xcodeproj，将得到的 Mix 二进制文件放到您需要混淆加密的工程的根目录。
2. 打开您自己的工程，在 Build Phases 中添加 Run Script，内容为

	```
	# 默认是 Release 情况下运行，可根据需要自定义
	if [ "${CONFIGURATION}" = "Release" ]; then
	# 注意由于你的工程目录可能包含 Pods 这类第三方代码，所以你需要切换到你自己代码所在的目录比如 MixIosDemo 目录
	# cd MixIosDemo/
	# 如果你切换了工作目录，需要正确指定 Mix 程序的文件位置
	# ../Mix
	./Mix
	fi
	```
	确保该 Run Script 在 Compile Souces 之前。
3. 添加 MixIosDemo/MixOC/MixDecrypt.h 到您的工程中
4. 在您的 pch 头文件中引入 MixDecrypt.h
5. 如果遇到代码编译不过的问题，请到编译出错的地方比较原先的代码和经过 Mix 程序加密过后的区别，然后对原始代码进行一些相应修改。当然你可以给我提 issue。

您可以随时参考 MixIosDemo 这个 iOS Demo 工程来了解具体配置方式。

现在 Swift 支持脚本运行，由于 Mix 这个二进制文件是由 Swift 写成，所以您也可以在您的打包脚本中，添加 `swift xxx.swift` (确保环境中的 swift 版本是 swift 3，这里的 xxx.swift 就是 repo 中 Mix/Mix/main.swift 文件)

# 自定义加密混淆

目前默认的加密方式是异或加密（可能也算不上加密，顶多算是混淆），如果需要自定义加密混淆方式，两个步骤：

1. 修改 Mix/Mix/main.swift 中的加密方法，编译工程，替换您工程目录下的 Mix 二进制文件为编译生成的 Mix 文件
2. 修改 MixDecrypt.h 中 dl_getRealText 函数体的解密方法

注意，不要使用复杂的加解密方法，同时解密方法要和加密方法配套，否则运行时会出错。

# Warning

由于该程序会改变您原来程序代码的内容，所以您在使用的时候一定要谨慎，最好是在版本控制系统（比如 Git，SVN）下使用，同时当前工作目录没有未 commit 的内容。

# TODO

1. 支持 C 类型的字符串
2. 增加支持更多的文件类型，比如 mm 文件， h 文件，pch 文件， c 文件， cpp 文件等

# 贡献者

作者: [@粉碎音箱的音乐(weibo)](http://weibo.com/u/1172595722) 

Blog: [Blog](http://danleechina.github.io/)

# 需要 Star！

如果你觉得 `MixPlainText` 有用的话，请点个 star 呗！谢谢啦。😄

