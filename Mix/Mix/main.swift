//
//  main.swift
//  Mix
//
//  Created by Dan.Lee on 2017/3/17.
//  Copyright © 2017年 Dan Lee. All rights reserved.
//

import Foundation

// @"[\s\S]*?(?<!(\\))(\\\\)*"
let defaultRegex = "@\"[\\s\\S]*?(?<!(\\\\))(\\\\\\\\)*\""
let defaultWorkspace = FileManager.default.currentDirectoryPath
let escapeSymbol = ["'": "'" as Character,
                    "\"": "\"" as Character,
                    "?": "?" as Character,
                    "\\": "\\" as Character,
                    "a": "a" as Character,
                    "b": "b" as Character,
                    "f": "f" as Character,
                    "n": "n" as Character,
                    "r": "r" as Character,
                    "t": "t" as Character,
                    "v": "v" as Character,]
let backSlash:Character = "\\"
let changeLine:Character = "\n"

/*
 make sure you don't use these Objective C string:
 1. objective-c string like @"a""b" is not supported by regex @"[\s\S]*?(?<!(\\))(\\\\)*"
 2. objective-c escape sequences has \nnn \xnn \unnnn \Unnnnnnnn is not supportted
 
 see http://en.cppreference.com/w/cpp/language/escape for detail
 \'	single quote	byte 0x27 in ASCII encoding
 \"	double quote	byte 0x22 in ASCII encoding
 \?	question mark	byte 0x3f in ASCII encoding
 \\	backslash	byte 0x5c in ASCII encoding
 \a	audible bell	byte 0x07 in ASCII encoding
 \b	backspace	byte 0x08 in ASCII encoding
 \f	form feed - new page	byte 0x0c in ASCII encoding
 \n	line feed - new line	byte 0x0a in ASCII encoding
 \r	carriage return	byte 0x0d in ASCII encoding
 \t	horizontal tab	byte 0x09 in ASCII encoding
 \v	vertical tab	byte 0x0b in ASCII encoding
 \nnn	arbitrary octal value	byte nnn
 \xnn	arbitrary hexadecimal value	byte nn
 \unnnn	universal character name (arbitrary Unicode value); may result in several characters	code point U+nnnn
 \Unnnnnnnn	universal character name (arbitrary Unicode value); may result in several characters	code point U+nnnnnnnn
 */
func convert(escapeSequences: String) -> String {
    var printfableString = ""
    let characters = escapeSequences.characters
    var index = 0
    let length = characters.count
    while index < length {
        let singleChar = char(for: characters, at: index)
        if singleChar == backSlash {
            index += 1
            let nextChar = char(for: characters, at: index)
            if nextChar == escapeSymbol["'"] {
                printfableString.append("'")
            } else if nextChar == escapeSymbol["\""] {
                printfableString.append("\"")
            } else if nextChar == escapeSymbol["?"] {
                printfableString.append("?")
            } else if nextChar == escapeSymbol["\\"] {
                printfableString.append("\\")
            } else if nextChar == escapeSymbol["a"] {
            } else if nextChar == escapeSymbol["b"] {
            } else if nextChar == escapeSymbol["f"] {
                printfableString.append("\n") // no f in swift
            } else if nextChar == escapeSymbol["n"] {
                printfableString.append("\n")
            } else if nextChar == escapeSymbol["r"] {
                printfableString.append("\r")
            } else if nextChar == escapeSymbol["t"] {
                printfableString.append("\t")
            } else if nextChar == escapeSymbol["v"] {
                printfableString.append("\n") // no v in swift
            } else if nextChar == changeLine {
            } else {
                
            }
        } else {
            printfableString.append(singleChar)
        }
        index += 1
    }
    return printfableString
}

func printf(_ string: String) -> Void {
//    print(string)
}

func matches(for regex: String, in text: String) -> [String] {
    do {
        let regex = try NSRegularExpression(pattern: regex)
        let nsString = text as NSString
        let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
        return results.map { nsString.substring(with: $0.range)}
    } catch let error {
        printf("invalid regex: \(error.localizedDescription)")
        return []
    }
}

func encrypt(input: String, staticKey: UInt8, version: UInt8) -> String? {
    if input.characters.count == 0 {
        printf("empty content")
        return nil
    }
    guard let originalData = input.data(using: String.Encoding.utf8) else {
        printf("invalid data format")
        return nil
    }
    var data = originalData.enumerated().map { (_, element) -> UInt8 in
        return element ^ staticKey
    }
    data.append(contentsOf: [staticKey, version])
    
    return Data.init(bytes: data).base64EncodedString()
}

func char(for characters: String.CharacterView, at index: Int) -> Character {
    return characters[characters.index(characters.startIndex, offsetBy: index)]
}

func does(OCString: String, defineSubStringAsStaticString subString:String) -> Bool {
    if let rangeForSubString = OCString.range(of: subString) {
        let rangeForTheLine = OCString.lineRange(for: rangeForSubString)
        let lineString = OCString.substring(with: rangeForTheLine)
        if !(matches(for: "static\\s*NSString\\s*", in: lineString).count > 0) {
            return matches(for: "NSString[\\s\\S]*const", in: lineString).count > 0
        } else {
            return true
        }
    }
    return false
}

func deal(file filepath: String) -> Void {
    printf("-----------------")
    guard let contentsData = FileManager.default.contents(atPath: filepath),
        var contentsString = String(data: contentsData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) else {
            printf("\(filepath) read fail")
            exit(0)
    }
    var itemIndex = 0
    matches(for: defaultRegex, in: contentsString).forEach({ (item) in
        if !does(OCString: contentsString, defineSubStringAsStaticString: item) {
            printf("\(itemIndex+1) \(item)")
            var printfableString = convert(escapeSequences: item)
            if printfableString.characters.count > 3 {
                let startIndex = printfableString.index(printfableString.startIndex, offsetBy: 2)
                let endIndex = printfableString.index(printfableString.endIndex, offsetBy: -1)
                printfableString = printfableString.substring(with: startIndex..<endIndex )
                printf("\(itemIndex+1) \(printfableString)")
            } else {
                printfableString = ""
            }
            if var replaceStr = encrypt(input: printfableString, staticKey: 0xff, version: 0x01) {
                replaceStr = "dl_getRealText(@\"\(replaceStr)\")"
                contentsString = contentsString.replacingOccurrences(of: item, with: replaceStr)
            }
            itemIndex += 1
        } else {
            printf("static string \(item)")
        }
    })

    guard let resultData = contentsString.data(using: String.Encoding.utf8) else {
        printf("\(filepath) write fail")
        exit(0)
    }
    FileManager.default.createFile(atPath: filepath, contents: resultData, attributes: nil)
    printf("-----------------")
}

func main() {
    let fileManager = FileManager.default
    let resourceKeys : [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
    let workspaceURL = URL.init(fileURLWithPath: defaultWorkspace)
    let enumerator = fileManager.enumerator(at: workspaceURL, includingPropertiesForKeys: resourceKeys, options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
        printf("directoryEnumerator error at \(url): \n\(error)")
        return true
    })!
    
    var fileNO = 0
    for case let fileURL as URL in enumerator {
        if fileURL.pathExtension == "m" {
            fileNO += 1
            printf(fileURL.lastPathComponent)
            deal(file: fileURL.path)
            printf("finish file \(fileNO) \(fileURL.absoluteString)")
        }
    }
    printf("\(fileNO)")
}

main()
