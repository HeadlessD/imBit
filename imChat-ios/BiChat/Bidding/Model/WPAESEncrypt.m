//
//  WPAESEncrypt.m
//  BiChat
//
//  Created by iMac on 2019/3/5.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import "WPAESEncrypt.h"
#import <CommonCrypto/CommonCryptor.h>
#import "WPBase64.h"
@implementation WPAESEncrypt


+ (NSString *)encryptStringWithString:(NSString *)string andKey:(NSString *)key {
    
    const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:string.length];
    //对数据进行加密
    NSData *result = [WPAESEncrypt encryptDataWithData:data Key:key];
    //转换为2进制字符串
    if (result && result.length > 0) {
//        Byte *datas = (Byte *)[result bytes];
//        NSMutableString *outPut = [NSMutableString stringWithCapacity:result.length];
//        for(int i = 0 ; i < result.length ; i++) {
//            [outPut appendFormat:@"%02x",datas[i]];
//        }
        
        return [result base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    return nil;
    
}

+ (NSString *)decryptStringWithString:(NSString *)string andKey:(NSString *)key {
//    NSString *baString = [string base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    if (!string || !key) {
        return nil;
    }
    NSData *dataa = [[NSData alloc] initWithBase64EncodedString:string options:0];
    NSMutableData *data = [[NSMutableData alloc] initWithData:dataa];
//    unsigned char whole_bytes;
//    char byte_chars[3] = {'\0','\0','\0'};
//    int i;
//    for(i = 0 ; i < [string length]/2 ; i++) {
//        byte_chars[0] = [string characterAtIndex:i * 2];
//        byte_chars[1] = [string characterAtIndex:i * 2 + 1];
//        whole_bytes = strtol(byte_chars, NULL, 16);
//        [data appendBytes:&whole_bytes length:1];
//    }
    NSData *result = [WPAESEncrypt decryptDataWithData:data andKey:key];
    if(result && result.length > 0) {
        return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    }
    return nil;
}

+ (NSData *)encryptDataWithData:(NSData *)data Key:(NSString *)key {
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr,
                                          kCCKeySizeAES128,
                                          NULL ,
                                          data.bytes,
                                          dataLength, /* input */
                                          buffer,
                                          bufferSize, /* output */
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return nil;
}

+ (NSData *)decryptDataWithData:(NSData *)data andKey:(NSString *)key {
    NSData* keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    
    //IV init
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          [keyData bytes],
                                          kCCKeySizeAES128,
                                          NULL,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}

+ (NSData *)dataWithBase64EncodedString:(NSString *)string
{
    const char lookup[] =
    {
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 62, 99, 99, 99, 63,
        52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 99, 99, 99, 99, 99, 99,
        99,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
        15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 99, 99, 99, 99, 99,
        99, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
        41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 99, 99, 99, 99, 99
    };
    
    NSData *inputData = [string dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    long long inputLength = [inputData length];
    const unsigned char *inputBytes = [inputData bytes];
    
    long long maxOutputLength = (inputLength / 4 + 1) * 3;
    NSMutableData *outputData = [NSMutableData dataWithLength:maxOutputLength];
    unsigned char *outputBytes = (unsigned char *)[outputData mutableBytes];
    
    int accumulator = 0;
    long long outputLength = 0;
    unsigned char accumulated[] = {0, 0, 0, 0};
    for (long long i = 0; i < inputLength; i++)
    {
        unsigned char decoded = lookup[inputBytes[i] & 0x7F];
        if (decoded != 99)
        {
            accumulated[accumulator] = decoded;
            if (accumulator == 3)
            {
                outputBytes[outputLength++] = (accumulated[0] << 2) | (accumulated[1] >> 4);
                outputBytes[outputLength++] = (accumulated[1] << 4) | (accumulated[2] >> 2);
                outputBytes[outputLength++] = (accumulated[2] << 6) | accumulated[3];
            }
            accumulator = (accumulator + 1) % 4;
        }
    }
    
    //handle left-over data
    if (accumulator > 0) outputBytes[outputLength] = (accumulated[0] << 2) | (accumulated[1] >> 4);
    if (accumulator > 1) outputBytes[++outputLength] = (accumulated[1] << 4) | (accumulated[2] >> 2);
    if (accumulator > 2) outputLength++;
    
    //truncate data to match actual output length
    outputData.length = outputLength;
    return outputLength? outputData: nil;
}

@end
