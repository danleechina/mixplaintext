//
//  MixDecrypt.h
//
//  Created by Dan.Lee on 2017/3/10.
//

#ifndef MixDecrypt_h
#define MixDecrypt_h

#import <Foundation/Foundation.h>
#include <stdio.h>

@implementation NSData (ITTAdditions)

- (NSString *)dl_decryptTextUsingXOR {
    if (self == nil || self.length <= 0) {
        return nil;
    }
    
    Byte *dataBytes = (Byte *)[self bytes];
    NSUInteger originalBytesLength = self.length;
    
    Byte randomByte = dataBytes[originalBytesLength - 2];
    //    Byte version = dataBytes[originalBytesLength + 1];
    for (int i = 0; i < originalBytesLength - 2; i++) {
        dataBytes[i] ^= randomByte;
    }
    
    Byte *bytesBuffer = malloc(originalBytesLength - 2);
    memcpy(bytesBuffer, dataBytes, originalBytesLength - 2);
    
    NSData *decryptedData = [[NSData alloc] initWithBytes:bytesBuffer length:(originalBytesLength - 2)];
    NSString *decryptedString = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    
    free(bytesBuffer);
    bytesBuffer = NULL;
    
    return decryptedString;
}

@end

static NSString *dl_getRealText(NSString *obscureText)
{
    static dispatch_once_t onceToken;
    static NSCache *storeData;
    dispatch_once(&onceToken, ^{
        storeData = [NSCache new];
    });
    if (![storeData objectForKey:obscureText]) {
        NSString *decryptText = [[[NSData alloc] initWithBase64EncodedString:obscureText options:NSDataBase64DecodingIgnoreUnknownCharacters] dl_decryptTextUsingXOR];
        [storeData setObject:decryptText
                      forKey:obscureText];
    }
    return [storeData objectForKey:obscureText];
}

#endif /* MixDecrypt_h */
