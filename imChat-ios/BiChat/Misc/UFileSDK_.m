//
//  UFileSDK_.m
//  BiChat
//
//  Created by worm_kc on 2018/3/9.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "UFileSDK_.h"
#import "JSONKit.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

//ttfile.cn-bj.ufileos.com

@implementation UFileSDK_

- (void)UploadData:(NSData *)data
          withName:(NSString *)name
       contentType:(NSString *)contentType
          progress:(UFileProgressCallback _Nullable)uploadProgress
           success:(UFileUploadDoneCallback _Nonnull)success
           failure:(UFileOpFailCallback _Nonnull)failure;
{
    //先记录一下block信息
    progressCallback = uploadProgress;
    upSuccessCallback = success;
    failureCallback = failure;
    
    //先生成url
    //NSString *urlString = [NSString stringWithFormat:@"https://ttfile.cn-bj.ufileos.com/%@", name];
    NSString *urlString = [NSString stringWithFormat:@"https://imchat.up.ufileos.com/%@", name];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"imchat.up.ufileos.com" forHTTPHeaderField:@"Host"];
    [request setValue:[NSString stringWithFormat:@"%zd", data.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    
    //生成签名字段
    NSString *string2Sign = [NSString stringWithFormat:@"PUT\n\n%@\n\n/imchat/%@", contentType, name];
    
    //NSLog(@"%@", string2Sign);
    [request setValue:[self calcAuthorization:string2Sign] forHTTPHeaderField:@"Authorization"];
    //NSLog(@"%@", [request allHTTPHeaderFields]);
    //NSLog(@"%@", request);
    NSURLConnection *con = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    self.thisConnection = con;
    [self.thisConnection start];
    //NSLog(@"start network connection");
}

- (NSString *)calcAuthorization:(NSString *)string2Sign
{
    //使用SHA1签名
    NSString *sha1 = [self hmacsha1:string2Sign key:@"2789bfbeae8be76b6e9a9c972bf83ac999afa6f7"];
    return [NSString stringWithFormat:@"UCloud %@:%@", @"cDqOTQ9xfM48TyP1vHMko98y0OaIfxn+zvWpmr5KZRVPstJb", sha1];
}

- (NSString *)hmacsha1:(NSString *)text key:(NSString *)secret {
    const char *cKey  = [secret cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [text cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    //将加密结果进行一次BASE64编码。
    NSString *hash = [HMAC base64EncodedStringWithOptions:0];
    return hash;
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    //NSHTTPURLResponse *newResponse=(NSHTTPURLResponse*)response;
    NSMutableData *data = [[NSMutableData alloc] init];
    [data setLength:0];
    self.resultData = data;
}

//下载progress
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    //所每次下载的数据保存到缓冲区中
    [self.resultData appendData:data];
}

//上传progress
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    NSLog(@"1, %zd, %zd, %zd", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    if (progressCallback)
    {
        float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
        progressCallback(progress);
    }
}

//数据下载完成
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    JSONDecoder* decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
    id result = [decoder mutableObjectWithData:self.resultData];
    
    //log一下
    NSLog(@"UCloud return:[%@]", [[NSString alloc]initWithData:self.resultData encoding:NSUTF8StringEncoding]);

    //回调block
    if (upSuccessCallback)
    {
        @try {
            upSuccessCallback(result);
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
    }
    
    //回调delegate
    else
    {
        @try {
            self.resultData = nil;
            self.thisConnection = nil;
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    if ([error code] == kCFURLErrorNotConnectedToInternet)
    {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"No Connection Error"
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                         code:kCFURLErrorNotConnectedToInternet
                                                     userInfo:userInfo];
        [self handleError:noConnectionError];
    }
    else
    {
        // otherwise handle the error generically
        [self handleError:error];
    }
}

- (void)handleError:(NSError *)error
{
    self.resultData = nil;
    self.thisConnection = nil;
    
    //回调block
    if (failureCallback)
    {
        @try {
            failureCallback(nil);
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
    }
    else
    {
    }
    //NSLog(@"%@",[error localizedDescription]);
}


@end
