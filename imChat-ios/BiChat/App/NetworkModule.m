//
//  NetworkModule.m
//  BiChat
//
//  Created by worm_kc on 2018/3/22.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import "NetworkModule.h"
#import <TTStreamer/TTStreamerClient.h>
#import <AdSupport/AdSupport.h>
#import "JSONKit.h"
#import "pinyin.h"

#define USE_WEBAPI

@implementation SendMessagePara
@end
@implementation getGroupPropertyPara
@end

@implementation NetworkModule

//强制重新连接网络模块，用于重新登录
+ (BOOL)reconnect
{
    return [PokerStreamClient disconect];
}

//使用微信登录
+ (BOOL)loginByWeChat:(NSString *_Nonnull)code completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *appid = @"wx5c3730f74d615522";
    NSString *appVersion = [@"ios:" stringByAppendingString:[BiChatGlobal getAppVersion]];
#ifdef ENV_CN
    appid = @"wx5c3730f74d615522";
    appVersion = [@"ioscn:" stringByAppendingString:[BiChatGlobal getAppVersion]];
#endif
#ifdef ENV_ENT
    appid = @"wxdf77fcd9ec0d3501";
    appVersion = [@"iosent:" stringByAppendingString:[BiChatGlobal getAppVersion]];
#endif
#ifdef ENV_V_DEV
    appid = @"wxe408d34135439533";
    appVersion = [@"ios:" stringByAppendingString:[BiChatGlobal getAppVersion]];
#endif
    
    //使用 http portal 接口进行微信登录
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/login.do?code=%@&appVersion=%@&appid=%@",
                         [BiChatGlobal sharedManager].authWxUrl,
                         code,
                         appVersion,
                         appid];

    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];

    return YES;
}

//绑定微信账号
+ (BOOL)bindingWeChat:(NSString *_Nonnull)code completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *appid = @"wx5c3730f74d615522";
    NSString *appVersion = [@"ios:" stringByAppendingString:[BiChatGlobal getAppVersion]];
#ifdef ENV_CN
    appid = @"wx5c3730f74d615522";
    appVersion = [@"ioscn:" stringByAppendingString:[BiChatGlobal getAppVersion]];
#endif
#ifdef ENV_ENT
    appid = @"wxdf77fcd9ec0d3501";
    appVersion = [@"iosent:" stringByAppendingString:[BiChatGlobal getAppVersion]];
#endif
#ifdef ENV_V_DEV
    appid = @"wxe408d34135439533";
    appVersion = [@"ios:" stringByAppendingString:[BiChatGlobal getAppVersion]];
#endif

    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/auth.do?tokenid=%@&code=%@&appVersion=%@&appid=%@",
                         [BiChatGlobal sharedManager].authWxUrl,
                         [BiChatGlobal sharedManager].token,
                         code,
                         appVersion,
                         appid];
    
    //GO!
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

+ (BOOL)unBindWeChat:(NSString *_Nonnull)unionId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    short headerSize = 36;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 108;
    HTONS(CommandType);
    
    //准备数据
    NSData *data4UnionId = [unionId dataUsingEncoding:NSUTF8StringEncoding];
    
    //生成获取通讯录所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4UnionId];
    
    //发送获取通讯录命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
            completedBlock(YES, NO, 0, responseObject);
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, nil);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
            else
                completedBlock(NO, NO, 0, nil);
        }
    }])
    {
    }
#endif
    return YES;
}

//登出当前的用户
+ (BOOL)logout:(NetworkCompletedBlock _Nonnull)completedBlock
{
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 107;
    HTONS(CommandType);
    
    //生成获取通讯录所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    
    //发送登出命令
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                    completedBlock(YES, NO, 0, nil);
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
            else
                completedBlock(NO, NO, 0, nil);
        }
    }])
    {
        return NO;
    }

    return YES;
}

+ (BOOL)sendVerifyCode4Login:(NSString *_Nonnull)areaCode
                      mobile:(NSString *_Nonnull)mobile
              completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //准备参数
    NSInteger count = ++ [BiChatGlobal sharedManager].verifyCodeCount;
    [[BiChatGlobal sharedManager]saveGlobalInfo];
    NSDictionary *dict4AppInfo = [NSDictionary dictionary];
    dict4AppInfo = @{@"device":@"IOS", @"version":[BiChatGlobal getAppVersion]};
#ifdef ENV_CN
    dict4AppInfo = @{@"device":@"IOSCN", @"version":[BiChatGlobal getAppVersion]};
#endif
#ifdef ENV_ENT
    dict4AppInfo = @{@"device":@"IOSENT", @"version":[BiChatGlobal getAppVersion]};
#endif
#ifdef ENV_V_DEV
    dict4AppInfo = @{@"device":@"IOS", @"version":[BiChatGlobal getAppVersion], @"progId":[BiChatGlobal sharedManager].progId};
#endif
    NSString *str4AppInfo = [dict4AppInfo mj_JSONString];
    
    //使用 http portal 接口进行微信登录
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/requirePhoneCodeForLogin.do?smsType=%@&countryCode=%@&phoneNum=%@&sendCount=%ld&body=%@&progId=%@",
                         [BiChatGlobal sharedManager].authWxUrl,
                         @"sms",
                         areaCode,
                         mobile,
                         (long)count,
                         str4AppInfo,
                         [BiChatGlobal sharedManager].progId];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    str4Url = [str4Url stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    [self saveWebApiAccess:str4Url];
    //NSLog(@"%@", str4Url);
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
            completedBlock(YES, NO, 0, responseObject);
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //换一个地址重新尝试
        NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/requirePhoneCodeForLogin.do?smsType=%@&countryCode=%@&phoneNum=%@&sendCount=%ld&body=%@",
                             [BiChatGlobal sharedManager].apiUrl,
                             @"sms",
                             areaCode,
                             mobile,
                             (long)count,
                             str4AppInfo];
        
        //GO!
        str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        str4Url = [str4Url stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        //NSLog(@"%@", str4Url);
        AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
        [httmMgr POST:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if ([responseObject objectForKey:@"code"] != nil &&
                [[responseObject objectForKey:@"code"]integerValue] == 0)
                completedBlock(YES, NO, 0, responseObject);
            else
                completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            completedBlock(NO, NO, 0, nil);
        }];
    }];
    
    return YES;
}

//发送登录语音验证码
+ (BOOL)sendVoiceVerifyCode4Login:(NSString *_Nonnull)areaCode
                           mobile:(NSString *_Nonnull)mobile
                   completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //准备参数
    NSInteger count = ++ [BiChatGlobal sharedManager].verifyCodeCount;
    [[BiChatGlobal sharedManager]saveGlobalInfo];
    NSDictionary *dict4AppInfo = [NSDictionary dictionary];
    dict4AppInfo = @{@"device":@"IOS", @"version":[BiChatGlobal getAppVersion]};
#ifdef ENV_CN
    dict4AppInfo = @{@"device":@"IOSCN", @"version":[BiChatGlobal getAppVersion]};
#endif
#ifdef ENV_ENT
    dict4AppInfo = @{@"device":@"IOSENT", @"version":[BiChatGlobal getAppVersion]};
#endif
#ifdef ENV_V_DEV
    dict4AppInfo = @{@"device":@"IOS", @"version":[BiChatGlobal getAppVersion], @"progId":[BiChatGlobal sharedManager].progId};
#endif
    NSString *str4AppInfo = [dict4AppInfo mj_JSONString];
    
    //使用 http portal 接口进行微信登录
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/requirePhoneCodeForLogin.do?smsType=%@&countryCode=%@&phoneNum=%@&sendCount=%ld&body=%@",
                         [BiChatGlobal sharedManager].authWxUrl,
                         @"voice",
                         areaCode,
                         mobile,
                         count,
                         str4AppInfo];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    str4Url = [str4Url stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
            completedBlock(YES, NO, 0, responseObject);
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //换一个地址重新尝试
        NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/requirePhoneCodeForLogin.do?smsType=%@&countryCode=%@&phoneNum=%@&sendCount=%ld&body=%@",
                             [BiChatGlobal sharedManager].apiUrl,
                             @"voice",
                             areaCode,
                             mobile,
                             count,
                             str4AppInfo];
        
        //GO!
        str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        str4Url = [str4Url stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
        [httmMgr POST:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if ([responseObject objectForKey:@"code"] != nil &&
                [[responseObject objectForKey:@"code"]integerValue] == 0)
                completedBlock(YES, NO, 0, responseObject);
            else
                completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            completedBlock(NO, NO, 0, nil);
        }];
    }];
    
    return YES;
}

//发送修改支付密码验证码
+ (BOOL)sendVerifyCode4ChangePaymentPassword:(NSString *_Nonnull)areaCode
                                      mobile:(NSString *_Nonnull)mobile
                              completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //开始发送获取验证码的命令
    NSData *data4AreaCode = [areaCode dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data4Mobile = [mobile dataUsingEncoding:NSUTF8StringEncoding];
    
    short headerSize = 14 + data4Mobile.length + data4AreaCode.length;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 59;
    HTONS(CommandType);
    short AreaCodeLength = data4AreaCode.length;
    HTONS(AreaCodeLength);
    short MobileNumberLength = data4Mobile.length;
    HTONS(MobileNumberLength);
    short count = ++ [BiChatGlobal sharedManager].verifyCodeCount;
    [[BiChatGlobal sharedManager]saveGlobalInfo];
    HTONS(count);
    
    //生成登录所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&AreaCodeLength length:2]];
    [data appendData:data4AreaCode];
    [data appendData:[[NSData alloc]initWithBytes:&MobileNumberLength length:2]];
    [data appendData:data4Mobile];
    [data appendData:[[NSData alloc]initWithBytes:&count length:2]];

    //发送获取验证码命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
            completedBlock(YES, NO, 0, responseObject);
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:nil binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, nil);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
            else
                completedBlock(NO, NO, 0, nil);
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//检查验证码是否正确
+ (BOOL)checkVerifyCode:(NSString *)areaCode
                 mobile:(NSString *_Nonnull)mobile verifyCode:(NSString *_Nonnull)verifyCode completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //准备数据
    NSData *data4AreaCode = [areaCode dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data4Mobile = [mobile dataUsingEncoding:NSUTF8StringEncoding];
    
    short headerSize = 18 + data4Mobile.length + data4AreaCode.length;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 58;
    HTONS(CommandType);
    short areaCodeLength = data4AreaCode.length;
    HTONS(areaCodeLength);
    short mobileNumberLength = data4Mobile.length;
    HTONS(mobileNumberLength);

    //生成检查验证码所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&areaCodeLength length:2]];
    [data appendData:data4AreaCode];
    [data appendData:[[NSData alloc]initWithBytes:&mobileNumberLength length:2]];
    [data appendData:data4Mobile];
    [data appendData:[verifyCode dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送检查验证码命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:nil binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    [BiChatGlobal sharedManager].verifyCodeCount = 0;
                    [[BiChatGlobal sharedManager]saveGlobalInfo];
                    completedBlock(YES, NO, 0, nil);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
            else
                completedBlock(NO, NO, 0, nil);
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)loginByVerifyCode:(NSString *_Nonnull)areaCode
                   mobile:(NSString *_Nonnull)mobile
               verifyCode:(NSString *_Nonnull)verifyCode
              weChatToken:(NSString *_Nonnull)weChatToken
           completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //准备参数
    NSDictionary *dict4AppInfo = [NSDictionary dictionary];
    dict4AppInfo = @{@"device":@"IOS", @"version":[BiChatGlobal getAppVersion]};
#ifdef ENV_CN
    dict4AppInfo = @{@"device":@"IOSCN", @"version":[BiChatGlobal getAppVersion]};
#endif
#ifdef ENV_ENT
    dict4AppInfo = @{@"device":@"IOSENT", @"version":[BiChatGlobal getAppVersion]};
#endif
#ifdef ENV_V_DEV
    dict4AppInfo = @{@"device":@"IOS", @"version":[BiChatGlobal getAppVersion], @"progId":[BiChatGlobal sharedManager].progId};
#endif
    NSString *str4AppInfo = [dict4AppInfo mj_JSONString];
    
    //使用 http portal 接口进行微信登录
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/phoneLogin.do?countryCode=%@&phoneNum=%@&loginPhoneCode=%@&body=%@",
                         [BiChatGlobal sharedManager].authWxUrl,
                         areaCode,
                         mobile,
                         verifyCode,
                         str4AppInfo];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    str4Url = [str4Url stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    [self saveWebApiAccess:str4Url];
    //NSLog(@"%@", str4Url);
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //换一个地址重新尝试
        NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/phoneLogin.do?countryCode=%@&phoneNum=%@&loginPhoneCode=%@&body=%@",
                             [BiChatGlobal sharedManager].apiUrl,
                             areaCode,
                             mobile,
                             verifyCode,
                             str4AppInfo];
        
        //GO!
        str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        str4Url = [str4Url stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        //NSLog(@"%@", str4Url);
        AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
        [httmMgr POST:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if ([responseObject objectForKey:@"code"] != nil &&
                [[responseObject objectForKey:@"code"]integerValue] == 0)
            {
                JSONDecoder *dec = [JSONDecoder new];
                NSDictionary *ret = responseObject;
                responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
                completedBlock(YES, NO, 0, responseObject);
            }
            else
                completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            completedBlock(NO, NO, 0, nil);
        }];
    }];
    
    return YES;
}

//修改支付密码
+ (BOOL)changePaymentPassword:(NSString *_Nonnull)areaCode
                       mobile:(NSString *_Nonnull)mobile
                   verifyCode:(NSString *_Nonnull)verifyCode
                     password:(NSString *)password
               completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //准备数据
    NSData *data4AreaCode = [areaCode dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data4Mobile = [mobile dataUsingEncoding:NSUTF8StringEncoding];
    
    short headerSize = 50 + data4Mobile.length + data4AreaCode.length;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 42;
    HTONS(CommandType);
    short AreaCodeLength = data4AreaCode.length;
    HTONS(AreaCodeLength);
    short MobileNumberLength = data4Mobile.length;
    HTONS(MobileNumberLength);
    
    //生成修改支付密码所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&AreaCodeLength length:2]];
    [data appendData:data4AreaCode];
    [data appendData:[[NSData alloc]initWithBytes:&MobileNumberLength length:2]];
    [data appendData:data4Mobile];
    [data appendData:[verifyCode dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[password dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送修改支付密码命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, nil);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
            else
                completedBlock(NO, NO, 0, nil);
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//是否已经设置了支付密码
+ (BOOL)isPaymentPasswordSet:(NetworkCompletedBlock _Nonnull)completedBlock
{
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 61;
    HTONS(CommandType);
    
    //生成获取通讯录所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    
    //发送获取通讯录命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, nil);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
            else
                completedBlock(NO, NO, 0, nil);
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//重新加载联系人列表
+ (BOOL)reloadContactList:(NetworkCompletedBlock _Nonnull )completedBlock
{
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 15;
    HTONS(CommandType);
    
    //生成获取通讯录所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    
    //发送获取通讯录命令
    [PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        //超时
        if (isTimeOut)
            completedBlock(NO, YES, 0, nil);
        
        //有返回
        if (data != nil)
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            
            if ([obj objectForKey:@"errorCode"] != nil &&
                [[obj objectForKey:@"errorCode"]integerValue] == 0)
            {
                //生成新的结构
                [BiChatGlobal sharedManager].array4AllFriendGroup = [NSMutableArray array];
                [BiChatGlobal sharedManager].dict4AllFriend = [NSMutableDictionary dictionary];
                
                //逐条添加所有的通讯录
                NSMutableArray *allFriends = [obj objectForKey:@"friends"];
                
                //如果我不在通讯录里面，则手动添加进入
                BOOL isIamIn = NO;
                for (NSDictionary *item in allFriends)
                {
                    if ([[item objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid])
                        isIamIn = YES;
                }
                if (!isIamIn)
                {
                    [allFriends addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           [BiChatGlobal sharedManager].nickName, @"nickName",
                                           [BiChatGlobal sharedManager].uid, @"uid",
                                           [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"avatar",
                                           [NSString stringWithFormat:@"%@ %@", [BiChatGlobal sharedManager].lastLoginAreaCode, [BiChatGlobal sharedManager].lastLoginUserName], @"userName", nil]];
                }
                
                //分类进入所在的section
                for (NSDictionary *item in allFriends)
                {
                    //检查参数
                    if ([item objectForKey:@"uid"] == nil)
                        continue;
                    
                    //处理一条记录
                    [[BiChatGlobal sharedManager].dict4AllFriend setObject:item forKey:[item objectForKey:@"uid"]];
                }
                [[BiChatGlobal sharedManager]resortAllFriend];
                                
                //加入到通讯录的群聊和黑名单
                [BiChatGlobal sharedManager].array4AllGroup = [obj objectForKey:@"groups"];
                [BiChatGlobal sharedManager].array4BlackList = [obj objectForKey:@"block"];
                [BiChatGlobal sharedManager].array4MuteList = [obj objectForKey:@"mute"];
                [BiChatGlobal sharedManager].array4StickList = [obj objectForKey:@"chatTop"];
                [BiChatGlobal sharedManager].array4FoldList = [obj objectForKey:@"fold"];
                [BiChatGlobal sharedManager].array4FollowList = [obj objectForKey:@"publicAccountGroup"];
                if ([BiChatGlobal sharedManager].array4FoldList == nil) [BiChatGlobal sharedManager].array4FoldList = [NSMutableArray array];
                if ([BiChatGlobal sharedManager].array4FollowList == nil) [BiChatGlobal sharedManager].array4FollowList = [NSMutableArray array];
                [[BiChatGlobal sharedManager]saveUserInfo];
                
                //回调
                completedBlock(YES, NO, 0, nil);
            }
            else
                completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
        }
    }];
    
    return YES;
}

//获取我的隐私设置
+ (BOOL)getMyPrivacyProfile:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //使用 http portal 接口进行获取
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/getMyAccountInfo.do?tokenid=%@",
                         [BiChatGlobal sharedManager].apiUrl,
                         [BiChatGlobal sharedManager].token];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    str4Url = [str4Url stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            NSString *str = [responseObject mj_JSONString];
            [BiChatGlobal sharedManager].dict4MyPrivacyProfile = [str mutableObjectFromJSONString];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

//设置我的隐私配置
+ (BOOL)setMyPrivacyProfile:(id _Nonnull)profile completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //准备参数
    NSString *str4Profile = [profile mj_JSONString];
    
    //使用 http portal 接口进行获取
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/setMyAccountInfo.do?tokenid=%@&body=%@",
                         [BiChatGlobal sharedManager].apiUrl,
                         [BiChatGlobal sharedManager].token,
                         str4Profile];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    str4Url = [str4Url stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    [self saveWebApiAccess:str4Url];
    //NSLog@"%@", str4Url);
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
            completedBlock(YES, NO, 0, responseObject);
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

//朋友圈相关接口
+ (BOOL)sendMomentWithType:(id _Nonnull)profile completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Profile = [profile mj_JSONString];
    NSData *data4Profile = [str4Profile dataUsingEncoding:NSUTF8StringEncoding];
    
    //send the message
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = (int)data4Profile.length;
    HTONL(bodySize);
    short CommandType = 117;
    HTONS(CommandType);
    
    //生成发送消息所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4Profile];
    
    //发送消息命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        if (isTimeOut){
            completedBlock(NO, YES, 0, nil);
        }else{
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];

            if ([obj isKindOfClass:[NSDictionary class]]){
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0){
                    NSLog(LLSTR(@"301004"));
                    completedBlock(YES, NO, 0, nil);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//获取多语言文件
+ (BOOL)getLanguageJsonWithDic:(id _Nonnull)profile completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Profile = [profile mj_JSONString];
    NSData *data4Profile = [str4Profile dataUsingEncoding:NSUTF8StringEncoding];
    
    //send the message
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = (int)data4Profile.length;
    HTONL(bodySize);
    short CommandType = 153;
    HTONS(CommandType);
    
    //生成发送消息所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4Profile];
    
    //发送消息命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        if (isTimeOut){
            completedBlock(NO, YES, 0, nil);
        }else{
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            
            if ([obj isKindOfClass:[NSDictionary class]]){
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0){
                    NSLog(@"12121212121212");
                    completedBlock(YES, NO, 0, nil);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//不看他的朋友圈
+ (BOOL)MomentJurisdictionWhitId:(NSArray *_Nonnull)userList withType:(short)commandType completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
//    Command Type    2字节    122 屏蔽对方看我的朋友圈
//    Command Type    2字节    123 解除屏蔽对方看我的朋友
//    Command Type    2字节    124 不想看对方的朋友圈
//    Command Type    2字节    125 取消不想看对方的朋友圈
    
    //send the message
    short headerSize = 42 + 32;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = commandType;
    HTONS(CommandType);
    short userCount = userList.count;
    HTONS(userCount);
    
    //生成发送消息所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&userCount length:2]];
    
    for (int i = 0; i < userList.count; i ++)
        [data appendData:[[userList objectAtIndex:i] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送消息命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            NSLog(@"MomentJurisdictionWhitId_obj_%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}


//block联系人
+ (BOOL)blockUser:(NSString *)uid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType;
    CommandType = 30;
    HTONS(CommandType);
    
    //生成登录所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[uid dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送登录命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
            [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data)
            {
                JSONDecoder *dec = [JSONDecoder new];
                NSDictionary *ret = responseObject;
                id responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
                completedBlock(YES, NO, 0, responseObject);
            }];
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        //超时
        if (isTimeOut)
            completedBlock(NO, YES, 0, nil);
        
        //有返回
        if (data != nil)
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            
            if ([obj objectForKey:@"errorCode"] != nil &&
                [[obj objectForKey:@"errorCode"]integerValue] == 0)
            {
                //重新刷新通讯录
                [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
                    completedBlock(success, isTimeOut, errorCode, nil);
                }];
            }
            else
                completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//unblock 联系人
+ (BOOL)unBlockUser:(NSString * _Nonnull)uid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType;
    CommandType = 31;
    HTONS(CommandType);
    
    //生成登录所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[uid dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送登录命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
            [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data)
            {
                JSONDecoder *dec = [JSONDecoder new];
                NSDictionary *ret = responseObject;
                id responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
                completedBlock(YES, NO, 0, responseObject);
            }];
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        //超时
        if (isTimeOut)
            completedBlock(NO, YES, 0, nil);
        
        //有返回
        if (data != nil)
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            
            if ([obj objectForKey:@"errorCode"] != nil &&
                [[obj objectForKey:@"errorCode"]integerValue] == 0)
            {
                //重新刷新通讯录
                [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
                    completedBlock(success, isTimeOut, errorCode, nil);
                }];
            }
            else
                completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//设置群组公共属性
+ (BOOL)setGroupPublicProfile:(NSString * _Nonnull)groupId profile:(id _Nonnull)profile completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSData *data4PublicProfile = [profile JSONData];
    NSData *data4GroupId = [groupId dataUsingEncoding:NSUTF8StringEncoding];
    
    //开始修改群名
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = (int)data4PublicProfile.length;
    HTONL(bodySize);
    short CommandType = 4;
    HTONS(CommandType);
    
    //生成修改群名所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4GroupId];
    [data appendData:data4PublicProfile];
    
    //发送修改群名命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                    completedBlock(YES, NO, 0, obj);
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//设置群组对本用户的私有属性
+ (BOOL)setGroupPrivateProfile:(NSString * _Nonnull)groupId profile:(id _Nonnull)profile completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSData *data4PrivateProfile = [profile JSONData];
    NSData *data4GroupId = [groupId dataUsingEncoding:NSUTF8StringEncoding];
    
    //开始修改群名
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = (int)data4PrivateProfile.length;
    HTONL(bodySize);
    short CommandType = 25;
    HTONS(CommandType);
    
    //生成修改群名所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4GroupId];
    [data appendData:data4PrivateProfile];
    
    //发送修改群名命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                    completedBlock(YES, NO, 0, obj);
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//置顶一个条目
+ (BOOL)stickItem:(NSString * _Nonnull)itemUid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //开始修改群名
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 41;
    HTONS(CommandType);
    
    //生成修改群名所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[itemUid dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送修改群名命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            [BiChatGlobal sharedManager].array4StickList = [responseObject objectForKey:@"chatTop"];
            [[BiChatGlobal sharedManager]saveUserInfo];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    [BiChatGlobal sharedManager].array4StickList = [obj objectForKey:@"chatTop"];
                    [[BiChatGlobal sharedManager]saveUserInfo];
                    completedBlock(YES, NO, 0, obj);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//取消置顶一个条目
+ (BOOL)unStickItem:(NSString * _Nonnull)itemUid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //开始修改群名
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 44;
    HTONS(CommandType);
    
    //生成修改群名所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[itemUid dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送修改群名命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            [BiChatGlobal sharedManager].array4StickList = [responseObject objectForKey:@"chatTop"];
            [[BiChatGlobal sharedManager]saveUserInfo];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    [BiChatGlobal sharedManager].array4StickList = [obj objectForKey:@"chatTop"];
                    [[BiChatGlobal sharedManager]saveUserInfo];
                    completedBlock(YES, NO, 0, obj);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//折叠一个条目
+ (BOOL)foldItem:(NSString * _Nonnull)itemUid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //开始修改群名
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 67;
    HTONS(CommandType);
    
    //生成修改群名所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[itemUid dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送修改群名命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            [BiChatGlobal sharedManager].array4FoldList = [responseObject objectForKey:@"fold"];
            [[BiChatGlobal sharedManager]saveUserInfo];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    [BiChatGlobal sharedManager].array4FoldList = [obj objectForKey:@"fold"];
                    [[BiChatGlobal sharedManager]saveUserInfo];
                    completedBlock(YES, NO, 0, nil);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//取消折叠一个条目
+ (BOOL)unFoldItem:(NSString * _Nonnull)itemUid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //开始修改群名
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 68;
    HTONS(CommandType);
    
    //生成修改群名所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[itemUid dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送修改群名命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            [BiChatGlobal sharedManager].array4FoldList = [responseObject objectForKey:@"fold"];
            [[BiChatGlobal sharedManager]saveUserInfo];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    [BiChatGlobal sharedManager].array4FoldList = [obj objectForKey:@"fold"];
                    [[BiChatGlobal sharedManager]saveUserInfo];
                    completedBlock(YES, NO, 0, nil);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//静音一个条目
+ (BOOL)muteItem:(NSString * _Nonnull)itemUid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //开始修改群名
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 40;
    HTONS(CommandType);
    
    //生成修改群名所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[itemUid dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送修改群名命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            [BiChatGlobal sharedManager].array4MuteList = [responseObject objectForKey:@"mute"];
            [[BiChatGlobal sharedManager]saveUserInfo];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    [BiChatGlobal sharedManager].array4MuteList = [obj objectForKey:@"mute"];
                    [[BiChatGlobal sharedManager]saveUserInfo];
                    completedBlock(YES, 0, 0, nil);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//取消静音一个条目
+ (BOOL)unMuteItem:(NSString * _Nonnull)itemUid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //开始修改群名
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 43;
    HTONS(CommandType);
    
    //生成修改群名所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[itemUid dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送修改群名命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            [BiChatGlobal sharedManager].array4MuteList = [responseObject objectForKey:@"mute"];
            [[BiChatGlobal sharedManager]saveUserInfo];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    JSONDecoder *dec = [JSONDecoder new];
                    NSDictionary *ret = responseObject;
                    responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
                    [BiChatGlobal sharedManager].array4MuteList = [obj objectForKey:@"mute"];
                    [[BiChatGlobal sharedManager]saveUserInfo];
                    completedBlock(YES, 0, 0, nil);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//加一个用户为我的朋友
+ (BOOL)addFriend:(NSString * _Nonnull)peerUserName source:(NSString *)source completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //准备参数
    if (source.length == 0)
        source = @"";

    //使用 http portal 接口进行获取
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/addFriend.do?tokenid=%@&username=%@&sourceBody=%@",
                         [BiChatGlobal sharedManager].apiUrl,
                         [BiChatGlobal sharedManager].token,
                         peerUserName,
                         source];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    str4Url = [str4Url stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    [self saveWebApiAccess:str4Url];
    //NSLog(@"%@", str4Url);
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            
            //添加朋友成功, 刷新通讯录界面
            [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
                completedBlock(success, isTimeOut, errorCode, responseObject);
            }];
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

//同意一个朋友邀请
+ (BOOL)agreeFriend:(NSString *_Nonnull)peerUid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //发一个命令，把对方加入到我的通讯录之中
    short headerSize = 42;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 17;
    HTONS(CommandType);
    short agree = 1;
    HTONS(agree);
    
    //生成登录所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&agree length:2]];
    [data appendData:[peerUid dataUsingEncoding:NSUTF8StringEncoding]];

    //发送添加朋友命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                completedBlock(YES, NO, 0, responseObject);
            }];
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    //需要重新拉一下通讯录
                    [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
                        completedBlock(success, isTimeOut, errorCode, nil);
                    }];
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//添加一个朋友
+ (BOOL)delFriend:(NSString * _Nonnull)peerUid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //开始添加一个朋友
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 34;
    HTONS(CommandType);
    
    //生成修改群名所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[peerUid dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送修改群名命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                completedBlock(YES, NO, 0, responseObject);
            }];
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    //需要重新拉一下通讯录
                    [self reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        completedBlock(success, isTimeOut, errorCode, data);
                    }];
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//根据phone查找一个朋友
+ (BOOL)getFriendByPhone:(NSString *_Nonnull)phone completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //使用 http portal 接口进行获取
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/findUserByPhone.do?tokenid=%@&phoneNum=%@",
                         [BiChatGlobal sharedManager].apiUrl,
                         [BiChatGlobal sharedManager].token,
                         phone];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    str4Url = [str4Url stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    [self saveWebApiAccess:str4Url];
    //NSLog(@"%@", str4Url);
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

//根据refCode查找一个朋友
+ (BOOL)getFriendByRefCode:(NSString * _Nonnull)refCode completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSData *data4RefCode = [refCode dataUsingEncoding:NSUTF8StringEncoding];
    
    short headerSize = 8;
    HTONS(headerSize);
    short CommandType = 120;
    HTONS(CommandType);
    int bodySize = (int)data4RefCode.length;
    HTONL(bodySize);
    
    //生成发送消息所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4RefCode];
    
    //发送消息命令(15821926890)
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                    completedBlock(YES, NO, 0, obj);
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//添加我的邀请人
+ (BOOL)addMyInviter:(NSString * _Nonnull)peerUid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //使用 http portal 接口进行获取
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/addMyInviter.do?tokenid=%@&inviterUid=%@",
                         [BiChatGlobal sharedManager].apiUrl,
                         [BiChatGlobal sharedManager].token,
                         peerUid];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    str4Url = [str4Url stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    [self saveWebApiAccess:str4Url];
    //NSLog(@"%@", str4Url);
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            [NetworkModule getMyPrivacyProfile:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                completedBlock(YES, NO, 0, responseObject);
            }];
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

//创建一个新群
+ (BOOL)createGroup:(NSString *_Nonnull)groupName
           userList:(NSArray *_Nonnull)userList
     relatedGroupId:(NSString *)relatedGroupId
   relatedGroupType:(NSInteger)relatedGroupType
     completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    /*
    //使用 http portal 接口进行获取
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/ApiGroup/createGroup.do?tokenid=%@&groupName=%@&userCount=%zd&userList=%@",
                         [BiChatGlobal sharedManager].apiUrl,
                         [BiChatGlobal sharedManager].token,
                         [groupName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]],
                         userList.count,
                         [userList componentsJoinedByString:@","]];
    
    //GO!
    str4Url = [str4Url stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    [self saveWebApiAccess:str4Url];
    //NSLog(@"%@", str4Url);
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
     */
    
    //开始创建新的群
    NSData *data4GrougName = [groupName dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data4Body = nil;
    if (relatedGroupId.length > 0)
    {
        NSDictionary *body = @{@"relatedGroupId": relatedGroupId, @"relatedGroupType": [NSNumber numberWithInteger:relatedGroupType]};
        data4Body = [body JSONData];
    }
    short headerSize = 12 + 32 * userList.count + data4GrougName.length;
    HTONS(headerSize);
    int bodySize = (int)data4Body.length;
    HTONL(bodySize);
    short CommandType = 3;
    HTONS(CommandType);
    short userCount = userList.count;
    HTONS(userCount);
    short groupNameLen = [data4GrougName length];
    HTONS(groupNameLen);
    
    //生成修改群名所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&userCount length:2]];
    for (int i = 0; i < userList.count; i ++)
        [data appendData:[[userList objectAtIndex:i]dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSData alloc]initWithBytes:&groupNameLen length:2]];
    [data appendData:data4GrougName];
    [data appendData:data4Body];
    
    //发送修改群名命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, nil);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif

    
    return YES;
}

//设置新的群主
+ (BOOL)setGroupOwner:(NSString *_Nonnull)groupId
                owner:(NSString *_Nonnull)uid
       completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //开始设置新的群主
    short headerSize = 72;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 38;
    HTONS(CommandType);
    
    //生成修改群名所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[uid dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送修改群名命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }

        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, nil);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)addGroupAssistant:(NSString *_Nonnull)groupId assistant:(NSArray *_Nonnull)uids completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //开始设置新的群主
    short headerSize = 40 + 2 + uids.count * 32;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 36;
    HTONS(CommandType);
    short assitantNumber = uids.count;
    HTONS(assitantNumber);
    
    //生成修改群名所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSData alloc]initWithBytes:&assitantNumber length:2]];
    for (int i = 0; i < uids.count; i ++)
        [data appendData:[[uids objectAtIndex:i] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送修改群名命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, nil);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//删除群管理员
+ (BOOL)delGroupAssistant:(NSString *_Nonnull)groupId assistant:(NSArray *_Nonnull)uids completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //开始设置新的群主
    short headerSize = 40 + 2 + uids.count * 32;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 37;
    HTONS(CommandType);
    short assitantNumber = uids.count;
    HTONS(assitantNumber);
    
    //生成修改群名所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSData alloc]initWithBytes:&assitantNumber length:2]];
    for (int i = 0; i < uids.count; i ++)
        [data appendData:[[uids objectAtIndex:i] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送修改群名命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, nil);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)addGroupVIP:(NSString *_Nonnull)groupId VIP:(NSArray *_Nonnull)uids completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //开始设置新的群主
    short headerSize = 40 + 2 + uids.count * 32;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 135;
    HTONS(CommandType);
    short assitantNumber = uids.count;
    HTONS(assitantNumber);
    
    //生成修改群名所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSData alloc]initWithBytes:&assitantNumber length:2]];
    for (int i = 0; i < uids.count; i ++)
        [data appendData:[[uids objectAtIndex:i] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送修改群名命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, nil);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//删除群管理员
+ (BOOL)delGroupVIP:(NSString *_Nonnull)groupId VIP:(NSArray *_Nonnull)uids completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //开始设置新的群主
    short headerSize = 40 + 2 + uids.count * 32;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 136;
    HTONS(CommandType);
    short assitantNumber = uids.count;
    HTONS(assitantNumber);
    
    //生成修改群名所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSData alloc]initWithBytes:&assitantNumber length:2]];
    for (int i = 0; i < uids.count; i ++)
        [data appendData:[[uids objectAtIndex:i] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送修改群名命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, nil);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)sendMessageToUser:(NSString *)peerUid message:(NSMutableDictionary *_Nonnull)message completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //处理消息
    NSMutableDictionary *newMessage = [NSMutableDictionary dictionary];
    for (NSString *key in message)
    {
        if (![[message objectForKey:key]isKindOfClass:[UIView class]])
        {
            [newMessage setObject:[message objectForKey:key] forKey:key];
        }
    }
    
    //开始发送
    [[BiChatDataModule sharedDataModule]setSendingMessage:[message objectForKey:@"msgId"]];
    SendMessagePara *para = [SendMessagePara new];
    para.count = 0;
    para.peerUid = peerUid;
    para.message = newMessage;
    para.completedBlock = completedBlock;
    [self performSelector:@selector(sendMessageToUserInternal:) withObject:para afterDelay:0];
    return YES;
}

+ (void)sendMessageToUserInternal:(SendMessagePara *)para
{
    NSDictionary *message = para.message;
    NSString *peerUid = para.peerUid;
    NetworkCompletedBlock completedBlock = para.completedBlock;
    NSString *str = [message mj_JSONString];
    
    //发送到服务器
    NSData *data4SendData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data4PeerID = [peerUid dataUsingEncoding:NSUTF8StringEncoding];
    
    //send the message
    short headerSize = 42;
    HTONS(headerSize);
    int bodySize = (int)data4SendData.length;
    HTONL(bodySize);
    short CommandType = 9;
    HTONS(CommandType);
    short messageType = [[message objectForKey:@"type"]integerValue];
    HTONS(messageType);
    
    //生成发送消息所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4PeerID];
    [data appendData:[[NSData alloc]initWithBytes:&messageType length:2]];
    [data appendData:data4SendData];
    
    //发送消息
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *ret = responseObject;
        id obj = [dec mutableObjectWithData:[ret mj_JSONData]];
        if ([obj isKindOfClass:[NSDictionary class]])
        {
            if ([obj objectForKey:@"errorCode"] != nil &&
                [[obj objectForKey:@"errorCode"]integerValue] == 0)
            {
                [[BiChatDataModule sharedDataModule]clearSendingMessage:[message objectForKey:@"msgId"]];
                [[BiChatGlobal sharedManager]imChatLog:@"Snd msg:(", [BiChatGlobal getMessageReadableString:message groupProperty:nil],@")(成功)", nil];
                completedBlock(YES, NO, 0, nil);
            }
            else
            {
                [[BiChatDataModule sharedDataModule]clearSendingMessage:[message objectForKey:@"msgId"]];
                [[BiChatDataModule sharedDataModule]setUnSentMessage:[message objectForKey:@"msgId"]];
                [[BiChatGlobal sharedManager]imChatLog:@"Snd msg:(", [BiChatGlobal getMessageReadableString:message groupProperty:nil],@")(失败1)", nil];
                completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
        else
        {
            [[BiChatDataModule sharedDataModule]clearSendingMessage:[message objectForKey:@"msgId"]];
            [[BiChatDataModule sharedDataModule]setUnSentMessage:[message objectForKey:@"msgId"]];
            [[BiChatGlobal sharedManager]imChatLog:@"Snd msg:(", [BiChatGlobal getMessageReadableString:message groupProperty:nil],@")(失败2)", nil];
            completedBlock(NO, NO, 0, nil);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //是否超时
        if (para.count > 60)
        {
            [[BiChatDataModule sharedDataModule]clearSendingMessage:[message objectForKey:@"msgId"]];
            [[BiChatDataModule sharedDataModule]setUnSentMessage:[message objectForKey:@"msgId"]];
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            //没有超时，重新发送
            para.count ++;
            [self performSelector:@selector(sendMessageToUserInternal:) withObject:para afterDelay:1];
        }
    }];
    
#else
    //发送消息命令
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            //是否超时
            if (para.count > 60)
            {
                [[BiChatDataModule sharedDataModule]clearSendingMessage:[message objectForKey:@"msgId"]];
                [[BiChatDataModule sharedDataModule]setUnSentMessage:[message objectForKey:@"msgId"]];
                [[BiChatGlobal sharedManager]imChatLog:@"Snd msg:(", [BiChatGlobal getMessageReadableString:message groupProperty:nil],@")(超时)", nil];
                completedBlock(NO, YES, 0, nil);
            }
            else
            {
                //没有超时，重新发送
                para.count ++;
                [self performSelector:@selector(sendMessageToUserInternal:) withObject:para afterDelay:1];
            }
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    [[BiChatDataModule sharedDataModule]clearSendingMessage:[message objectForKey:@"msgId"]];
                    [[BiChatGlobal sharedManager]imChatLog:@"Snd msg:(", [BiChatGlobal getMessageReadableString:message groupProperty:nil],@")(成功)", nil];
                    completedBlock(YES, NO, 0, nil);
                }
                else
                {
                    [[BiChatDataModule sharedDataModule]clearSendingMessage:[message objectForKey:@"msgId"]];
                    [[BiChatDataModule sharedDataModule]setUnSentMessage:[message objectForKey:@"msgId"]];
                    [[BiChatGlobal sharedManager]imChatLog:@"Snd msg:(", [BiChatGlobal getMessageReadableString:message groupProperty:nil],@")(失败1)", nil];
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
            else
            {
                [[BiChatDataModule sharedDataModule]clearSendingMessage:[message objectForKey:@"msgId"]];
                [[BiChatDataModule sharedDataModule]setUnSentMessage:[message objectForKey:@"msgId"]];
                [[BiChatGlobal sharedManager]imChatLog:@"Snd msg:(", [BiChatGlobal getMessageReadableString:message groupProperty:nil],@")(失败2)", nil];
                completedBlock(NO, NO, 0, nil);
            }
        }
    }])
    {
        //是否超时
        if (para.count > 60)
        {
            [[BiChatDataModule sharedDataModule]clearSendingMessage:[message objectForKey:@"msgId"]];
            [[BiChatDataModule sharedDataModule]setUnSentMessage:[message objectForKey:@"msgId"]];
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            //没有超时，重新发送
            para.count ++;
            [self performSelector:@selector(sendMessageToUserInternal:) withObject:para afterDelay:1];
        }
    }
#endif
}

+ (BOOL)sendMessageToGroup:(NSString *)groupId message:(NSMutableDictionary *_Nonnull)message completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //处理消息
    NSMutableDictionary *newMessage = [NSMutableDictionary dictionary];
    for (NSString *key in message)
    {
        if (![[message objectForKey:key]isKindOfClass:[UIView class]])
        {
            [newMessage setObject:[message objectForKey:key] forKey:key];
        }
    }
    
    //本群是否禁言
    NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:groupId];
    if ([[groupProperty objectForKey:@"mute"]boolValue] &&
        ![BiChatGlobal isMeGroupOperator:groupProperty] &&
        ![BiChatGlobal isMeGroupVIP:groupProperty])
        return NO;
    
    [[BiChatDataModule sharedDataModule]setSendingMessage:[message objectForKey:@"msgId"]];
    SendMessagePara *para = [SendMessagePara new];
    para.count = 0;
    para.peerUid = groupId;
    para.message = newMessage;
    para.completedBlock = completedBlock;
    [self performSelector:@selector(sendMessageToGroupInternal:) withObject:para afterDelay:0];
    return YES;
}

+ (void)sendMessageToGroupInternal:(SendMessagePara *)para
{
    NSDictionary *message = para.message;
    NSString *groupId = para.peerUid;
    NetworkCompletedBlock completedBlock = para.completedBlock;
    NSString *str = [message mj_JSONString];
    
    //发送到服务器
    NSData *data4SendData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data4GroupId = [groupId dataUsingEncoding:NSUTF8StringEncoding];
    
    //send the message
    short headerSize = 44;
    HTONS(headerSize);
    int bodySize = (int)data4SendData.length;
    HTONL(bodySize);
    short CommandType = 19;
    HTONS(CommandType);
    short messageType = [[message objectForKey:@"type"]integerValue];
    HTONS(messageType);
    short toUidCount = 0;
    HTONS(toUidCount);
    
    //生成发送消息所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4GroupId];
    [data appendData:[[NSData alloc]initWithBytes:&messageType length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&toUidCount length:2]];
    [data appendData:data4SendData];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *ret = responseObject;
        id obj = [dec mutableObjectWithData:[ret mj_JSONData]];
        if ([obj isKindOfClass:[NSDictionary class]])
        {
            if ([obj objectForKey:@"errorCode"] != nil &&
                [[obj objectForKey:@"errorCode"]integerValue] == 0)
            {
                [[BiChatDataModule sharedDataModule]clearSendingMessage:[message objectForKey:@"msgId"]];
                [[BiChatGlobal sharedManager]imChatLog:@"Snd msg:(", [BiChatGlobal getMessageReadableString:message groupProperty:nil],@")(成功)", nil];
                completedBlock(YES, NO, 0, nil);
            }
            else
            {
                [[BiChatDataModule sharedDataModule]clearSendingMessage:[message objectForKey:@"msgId"]];
                [[BiChatDataModule sharedDataModule]setUnSentMessage:[message objectForKey:@"msgId"]];
                [[BiChatGlobal sharedManager]imChatLog:@"Snd msg:(", [BiChatGlobal getMessageReadableString:message groupProperty:nil],@")(失败1)", nil];
                completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
        else
        {
            [[BiChatDataModule sharedDataModule]clearSendingMessage:[message objectForKey:@"msgId"]];
            [[BiChatDataModule sharedDataModule]setUnSentMessage:[message objectForKey:@"msgId"]];
            [[BiChatGlobal sharedManager]imChatLog:@"Snd msg:(", [BiChatGlobal getMessageReadableString:message groupProperty:nil],@")(失败2)", nil];
            completedBlock(NO, NO, 0, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //是否超时
        if (para.count > 60)
        {
            [[BiChatDataModule sharedDataModule]clearSendingMessage:[message objectForKey:@"msgId"]];
            [[BiChatDataModule sharedDataModule]setUnSentMessage:[message objectForKey:@"msgId"]];
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            //没有超时，重新发送
            para.count ++;
            [self performSelector:@selector(sendMessageToUserInternal:) withObject:para afterDelay:1];
        }
    }];
    
#else

    //发送消息命令
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            //是否超时
            if (para.count > 60)
            {
                [[BiChatDataModule sharedDataModule]clearSendingMessage:[message objectForKey:@"msgId"]];
                [[BiChatDataModule sharedDataModule]setUnSentMessage:[message objectForKey:@"msgId"]];
                [[BiChatGlobal sharedManager]imChatLog:@"Snd msg:(", [BiChatGlobal getMessageReadableString:message groupProperty:nil],@")(超时)", nil];
                completedBlock(NO, YES, 0, nil);
            }
            else
            {
                //没有超时，重新发送
                para.count ++;
                [self performSelector:@selector(sendMessageToGroupInternal:) withObject:para afterDelay:1];
            }
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    [[BiChatDataModule sharedDataModule]clearSendingMessage:[message objectForKey:@"msgId"]];
                    [[BiChatGlobal sharedManager]imChatLog:@"Snd msg:(", [BiChatGlobal getMessageReadableString:message groupProperty:nil],@")(成功)", nil];
                    completedBlock(YES, NO, 0, obj);
                }
                else
                {
                    [[BiChatDataModule sharedDataModule]clearSendingMessage:[message objectForKey:@"msgId"]];
                    [[BiChatDataModule sharedDataModule]setUnSentMessage:[message objectForKey:@"msgId"]];
                    [[BiChatGlobal sharedManager]imChatLog:@"Snd msg:(", [BiChatGlobal getMessageReadableString:message groupProperty:nil],@")(失败1)", nil];
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
            else
            {
                [[BiChatDataModule sharedDataModule]clearSendingMessage:[message objectForKey:@"msgId"]];
                [[BiChatDataModule sharedDataModule]setUnSentMessage:[message objectForKey:@"msgId"]];
                [[BiChatGlobal sharedManager]imChatLog:@"Snd msg:(", [BiChatGlobal getMessageReadableString:message groupProperty:nil],@")(失败2)", nil];
                completedBlock(NO, NO, 0, nil);
            }
        }
    }])
    {
        //是否超时
        if (para.count > 60)
        {
            [[BiChatDataModule sharedDataModule]clearSendingMessage:[message objectForKey:@"msgId"]];
            [[BiChatDataModule sharedDataModule]setUnSentMessage:[message objectForKey:@"msgId"]];
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            //没有超时，重新发送
            para.count ++;
            [self performSelector:@selector(sendMessageToUserInternal:) withObject:para afterDelay:1];
        }
    }
#endif
}

+ (BOOL)sendMessageToGroupOperator:(NSString *_Nonnull)groupId message:(NSMutableDictionary *_Nonnull)message completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //处理消息
    NSMutableDictionary *newMessage = [NSMutableDictionary dictionary];
    for (NSString *key in message)
    {
        if (![[message objectForKey:key]isKindOfClass:[UIView class]])
        {
            [newMessage setObject:[message objectForKey:key] forKey:key];
        }
    }
    
    //首先获取这个群的管理员
    NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:groupId];
    if (groupProperty == nil)
        return NO;
    NSArray *array4Operator = [groupProperty objectForKey:@"assitantUid"];
    if (array4Operator.count == 0)
        return NO;
    
    NSString *str = [newMessage mj_JSONString];
    //NSLog(@"%@", str);
    
    //发送到服务器
    NSData *data4SendData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data4GroupId = [groupId dataUsingEncoding:NSUTF8StringEncoding];
    
    //send the message
    short headerSize = 44 + 32 * array4Operator.count;
    HTONS(headerSize);
    int bodySize = (int)data4SendData.length;
    HTONL(bodySize);
    short CommandType = 19;
    HTONS(CommandType);
    short messageType = [[message objectForKey:@"type"]integerValue];
    HTONS(messageType);
    short toUidCount = array4Operator.count;
    HTONS(toUidCount);
    
    //生成发送消息所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4GroupId];
    [data appendData:[[NSData alloc]initWithBytes:&messageType length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&toUidCount length:2]];
    for (int i = 0; i < array4Operator.count; i ++)
        [data appendData:[[array4Operator objectAtIndex:i]dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:data4SendData];
    
    //发送消息命令
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            [[BiChatGlobal sharedManager]imChatLog:@"Snd msg:(", [BiChatGlobal getMessageReadableString:message groupProperty:nil],@")(超时)", nil];
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    [[BiChatGlobal sharedManager]imChatLog:@"Snd msg:(", [BiChatGlobal getMessageReadableString:message groupProperty:nil],@")(成功)", nil];
                    completedBlock(YES, NO, 0, nil);
                }
                else
                {
                    [[BiChatGlobal sharedManager]imChatLog:@"Snd msg:(", [BiChatGlobal getMessageReadableString:message groupProperty:nil],@")(失败1)", nil];
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
            else
            {
                [[BiChatGlobal sharedManager]imChatLog:@"Snd msg:(", [BiChatGlobal getMessageReadableString:message groupProperty:nil],@")(失败2)", nil];
                completedBlock(NO, NO, 0, nil);
            }
        }
    }])
    {
        return NO;
    }

    return YES;
}

+ (BOOL)getUserProfileByUid:(NSString *_Nonnull)peerUid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //开始获取朋友信息
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 29;
    HTONS(CommandType);
    
    //生成修改群名所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[peerUid dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送修改群名命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, obj);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)getUserProfileByMobile:(NSString *_Nonnull)mobile completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    return YES;
}

+ (BOOL)setUserMemoNameByUid:(NSString *)peerUid memoName:(NSString *)memoName completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:memoName, @"remark", nil];
    NSData *data4Info = [info JSONData];
    
    //开始获取朋友信息
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = (int)data4Info.length;
    HTONL(bodySize);
    short CommandType = 33;
    HTONS(CommandType);
    
    //生成修改群名所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[peerUid dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:data4Info];
    
    //发送修改群名命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, obj);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//上传本地通讯录
+ (BOOL)uploadLocalContact:(NSArray *)contact completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSData *data4ContactInfo = [contact JSONData];
    
    //开始上传数据
    short headerSize = 10;
    HTONS(headerSize);
    int bodySize = (int)data4ContactInfo.length;
    HTONL(bodySize);
    short CommandType = 35;
    HTONS(CommandType);
    
    //生成发送消息所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4ContactInfo];
    
    //发送消息命令(15821926890)
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, obj);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//获取app版本号
+ (BOOL)getAppVersion:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //开始获取App最新版本号
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 47;
    HTONS(CommandType);
    
    //生成修改群名所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    
    //发送修改群名命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:nil binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, obj);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//获取钱包信息
+ (BOOL)getWallet:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/ApiPay/getMyAsset.do?tokenid=%@", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token];

    //GO!
    //NSLog(@"%@", str4Url);
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [responseObject setObject:dict forKey:@"assetIndex"];
            NSString *str = [responseObject objectForKey:@"tradeMarketTickerAll"];
            if (str != Nil)
            {
                NSData *data = [[NSData alloc]initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];

                //NSLog(@"%@", [data description]);
                for (int i = 0; i < data.length; i += 24)
                {
                    int k;
                    [data getBytes:&k range:NSMakeRange(i, 4)];
                    NTOHL(k);
                    int j;
                    [data getBytes:&j range:NSMakeRange(i + 4, 4)];
                    NTOHL(j);
                    double d;
                    [data getBytes:&d range:NSMakeRange(i + 8, 8)];
                    unsigned long long l;
                    [data getBytes:&l range:NSMakeRange(i + 16, 8)];
                    NTOHLL(l);

                    //设置相应的币种价格
                    for (NSMutableDictionary *item in [responseObject objectForKey:@"bitcoinDetail"])
                    {
                        if ([[item objectForKey:@"code"]integerValue] == k)
                        {
                            [item setObject:[NSNumber numberWithDouble:d] forKey:@"price"];
                            [item setObject:[NSNumber numberWithLongLong:l] forKey:@"price_time"];
                            [item setObject:[NSNumber numberWithInteger:j] forKey:@"source"];

                            [dict setObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:d], @"price", nil] forKey:[item objectForKey:@"symbol"]];
                            break;
                        }
                    }
                }
            }
            [responseObject removeObjectForKey:@"tradeMarketTickerAll"];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];

    return YES;

    //开始获取钱包信息
//    short headerSize = 8;
//    HTONS(headerSize);
//    int bodySize = 0;
//    HTONL(bodySize);
//    short CommandType = 11;
//    HTONS(CommandType);
//
//    //生成获取钱包信息所需数据包
//    NSMutableData *data = [NSMutableData data];
//    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
//    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
//    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
//
//    //发送获取钱包信息命令
//    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
//
//        if (isTimeOut)
//        {
//            completedBlock(NO, YES, 0, nil);
//        }
//        else
//        {
//            JSONDecoder *dec = [JSONDecoder new];
//            id obj = [dec mutableObjectWithData:data1];
//            //NSLog(@"%@", obj);
//            if ([obj isKindOfClass:[NSDictionary class]])
//            {
//                if ([obj objectForKey:@"errorCode"] != nil &&
//                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
//                {
//                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//                    [obj setObject:dict forKey:@"assetIndex"];
//                    NSString *str = [obj objectForKey:@"tradeMarketTickerAll"];
//                    if (str != Nil)
//                    {
//                        NSData *data = [[NSData alloc]initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
//
//                        //NSLog(@"%@", [data description]);
//                        for (int i = 0; i < data.length; i += 24)
//                        {
//                            int k;
//                            [data getBytes:&k range:NSMakeRange(i, 4)];
//                            NTOHL(k);
//                            int j;
//                            [data getBytes:&j range:NSMakeRange(i + 4, 4)];
//                            NTOHL(j);
//                            double d;
//                            [data getBytes:&d range:NSMakeRange(i + 8, 8)];
//                            unsigned long long l;
//                            [data getBytes:&l range:NSMakeRange(i + 16, 8)];
//                            NTOHLL(l);
//
//                            //设置相应的币种价格
//                            for (NSMutableDictionary *item in [obj objectForKey:@"bitcoinDetail"])
//                            {
//                                if ([[item objectForKey:@"code"]integerValue] == k)
//                                {
//                                    [item setObject:[NSNumber numberWithDouble:d] forKey:@"price"];
//                                    [item setObject:[NSNumber numberWithLongLong:l] forKey:@"price_time"];
//                                    [item setObject:[NSNumber numberWithInteger:j] forKey:@"source"];
//
//                                    [dict setObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:d], @"price", nil] forKey:[item objectForKey:@"symbol"]];
//                                    break;
//                                }
//                            }
//                        }
//                    }
//                    [obj removeObjectForKey:@"tradeMarketTickerAll"];
//                    completedBlock(YES, NO, 0, obj);
//                }
//                else
//                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
//            }
//        }
//    }])
//    {
//        return NO;
//    }
//
//    return YES;
}

//获取流水
+ (BOOL)getWalletAccount:(NSString * _Nonnull)coinSymbol currPage:(NSInteger)currPage completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/ApiPay/getBalanceHistoryList.do?tokenid=%@&accuType=CASH&coinType=%@&currPage=%ld", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token, coinSymbol, (long)currPage];
    
    //GO!
    //NSLog(@"%@", str4Url);
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

//设置当前我的数字资产
+ (BOOL)setMyWalletAsset:(NSArray *)coinSymbols completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys:coinSymbols, @"myCoinList", nil];
    [NetworkModule setMyPrivacyProfile:item completedBlock:completedBlock];
    return YES;
}

//朋友转账
+ (BOOL)transferCoin:(NSString *_Nonnull)coinSymbol
                 to:(NSString *_Nonnull)peerUid
              count:(CGFloat)count
    paymentPassword:(NSString *_Nonnull)paymentPassword
     completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys:
                          coinSymbol, @"coinType",
                          peerUid, @"uid",
                          [BiChatGlobal decimalNumberWithDouble:count], @"value",
                          paymentPassword, @"paymentPassword",
                          nil];
    NSData *body = [item JSONData];
    
    //开始获取钱包信息
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = (int)body.length;
    HTONL(bodySize);
    short CommandType = 51;
    HTONS(CommandType);
    
    //生成获取钱包信息所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:body];
    
    //发送获取钱包信息命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, obj);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//确认转账
+ (BOOL)confirmTransferCoin:(NSString *)transactionId completedBlock:(NetworkCompletedBlock)completedBlock
{
    //开始确认转账
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 56;
    HTONS(CommandType);
    
    //生成确认转账所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[transactionId dataUsingEncoding:NSUTF8StringEncoding]];

    //发送确认转账命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, obj);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//获取转账信息
+ (BOOL)getTransferCoinInfo:(NSString *_Nonnull)transactionId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //开始获取转账信息
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 63;
    HTONS(CommandType);
    
    //生成获取转账信息所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[transactionId dataUsingEncoding:NSUTF8StringEncoding]];

    //发送获取转账信息命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, [responseObject objectForKey:@"transfer"]);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, [obj objectForKey:@"transfer"]);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//撤回转账
+ (BOOL)recallTransferCoin:(NSString *_Nonnull)transactionId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //开始撤回转账
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 57;
    HTONS(CommandType);
    
    //生成撤回转账所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[transactionId dataUsingEncoding:NSUTF8StringEncoding]];

    //发送撤回转账命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, obj);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//交换
+ (BOOL)exchangeCoin:(NSString *_Nonnull)coinSymbol
               count:(CGFloat)count
     paymentPassword:(NSString *_Nonnull)paymentPassword
  exchangeCoinSymbol:(NSString *_Nonnull)exchangeCoinSymbol
       exchangeCount:(CGFloat)exchangeCount
              expire:(CGFloat)expire
                memo:(NSString *_Nullable)memo
      completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/ApiPay/saveOTCDetail.do?tokenid=%@&password=%@&fromCoinType=%@&fromAmount=%@&toCoinType=%@&toAmount=%@&type=0&expired=%@&remark=%@",
                         [BiChatGlobal sharedManager].apiUrl,
                         [BiChatGlobal sharedManager].token,
                         paymentPassword,
                         coinSymbol, [NSNumber numberWithDouble:count],
                         exchangeCoinSymbol, [NSNumber numberWithDouble:exchangeCount],
                         [NSString stringWithFormat:@"%d", (int)(expire / 60)],
                         [memo stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    
    //GO!
    //NSLog(@"%@", str4Url);
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

//确认交换
+ (BOOL)confirmExchangeCoin:(NSString *_Nonnull)transactionId password:(NSString *_Nonnull)password completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/ApiPay/confirmOTC.do?tokenid=%@&txId=%@&password=%@",
                         [BiChatGlobal sharedManager].apiUrl,
                         [BiChatGlobal sharedManager].token,
                         transactionId,
                         password];
    
    //GO!
    //NSLog(@"%@", str4Url);
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
            completedBlock(YES, NO, 0, responseObject);
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

+ (BOOL)getExchangeCoinInfo:(NSString *_Nonnull)transactionId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/ApiPay/getOTCDetail.do?tokenid=%@&txId=%@",
                         [BiChatGlobal sharedManager].apiUrl,
                         [BiChatGlobal sharedManager].token,
                         transactionId];
    
    //GO!
    //NSLog(@"%@", str4Url);
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

+ (BOOL)recallExchangeCoin:(NSString *_Nonnull)transactionId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/ApiPay/cancelOTC.do?tokenid=%@&txId=%@",
                         [BiChatGlobal sharedManager].apiUrl,
                         [BiChatGlobal sharedManager].token,
                         transactionId];
    
    //GO!
    //NSLog(@"%@", str4Url);
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

//获取微信绑定列表
+ (BOOL)getWeChatBindingList:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //开始获取微信绑定列表
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 62;
    HTONS(CommandType);
    
    //生成获取钱包信息所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    
    //发送微信绑定列表信息命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        //NSLog(@"getWeChatBindingList callback");
        if (isTimeOut)
        {
            //NSLog(@"timeout");
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"1-%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, obj);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)getCoinHistory:(NSString *)coinFlag completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSData *data4CoinFlag = [coinFlag dataUsingEncoding:NSUTF8StringEncoding];
    
    //开始获取钱包信息
    short headerSize = 8 + data4CoinFlag.length;
    HTONS(headerSize);
    int bodySize = (int)data4CoinFlag.length;
    HTONL(bodySize);
    short CommandType = 64;
    HTONS(CommandType);
    
    //生成获取钱包信息所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4CoinFlag];
    
    //发送获取钱包信息命令
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    if ([obj objectForKey:@"data"] == nil ||
                        [[obj objectForKey:@"data"]length] == 0)
                    {
                        completedBlock(NO, NO, 0, nil);
                        return;
                    }
                    
                    NSData *data = [[NSData alloc]initWithBase64EncodedString:[obj objectForKey:@"data"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    
                    //如果是8个字节，需要特殊处理
                    if (data.length == 8)
                    {
                        double a;
                        [data getBytes:&a range:NSMakeRange(0, 8)];
                        completedBlock(YES, NO, 0, [NSArray arrayWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"timeStamp",
                                                                             [NSNumber numberWithDouble:a], @"min",
                                                                             [NSNumber numberWithDouble:a], @"max",
                                                                             [NSNumber numberWithDouble:a], @"begin",
                                                                             [NSNumber numberWithDouble:a], @"end",
                                                                             [NSNumber numberWithDouble:a], @"count",
                                                                             nil]]);
                        return;
                    }
                    
                    //正常数据
                    //数据块太小
                    if (data.length < 12)
                    {
                        completedBlock(NO, NO, 0, nil);
                        return;
                    }
                    
                    //开始解析
                    int code;
                    [data getBytes:&code range:NSMakeRange(0, 4)];
                    NTOHL(code);
                    int source;
                    [data getBytes:&source range:NSMakeRange(4, 4)];
                    NTOHL(source);
                    int granularity;
                    [data getBytes:&granularity range:NSMakeRange(8, 4)];
                    NTOHL(granularity);
                    
                    //NSLog(@"%d, %d, %d", code, source, granularity);
                    
                    //接下来是具体的数据
                    NSMutableArray *array4QuotationData = [NSMutableArray array];
                    for (int i = 12; i < data.length; i += 48)
                    {
                        unsigned long long time;
                        [data getBytes:&time range:NSMakeRange(i, 8)];
                        NTOHLL(time);
                        double a;
                        [data getBytes:&a range:NSMakeRange(i + 8, 8)];
                        double b;
                        [data getBytes:&b range:NSMakeRange(i + 8, 8)];
                        double c;
                        [data getBytes:&c range:NSMakeRange(i + 8, 8)];
                        double d;
                        [data getBytes:&d range:NSMakeRange(i + 8, 8)];
                        double e;
                        [data getBytes:&e range:NSMakeRange(i + 8, 8)];
                        
                        //NSLog(@"%lld, %f, %f, %f, %f, %f", time, a, b, c, d, e);
                        
                        [array4QuotationData addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSDate dateWithTimeIntervalSince1970:time], @"timeStamp",
                                                        [NSNumber numberWithDouble:a], @"min",
                                                        [NSNumber numberWithDouble:b], @"max",
                                                        [NSNumber numberWithDouble:c], @"begin",
                                                        [NSNumber numberWithDouble:d], @"end",
                                                        [NSNumber numberWithDouble:e], @"count",
                                                        nil]];
                    }
                    completedBlock(YES, NO, 0, array4QuotationData);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
    
    return YES;
}

+ (BOOL)pauseNetwork:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //开始获取钱包信息
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 65;
    HTONS(CommandType);
    
    //生成获取钱包信息所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    
    //发送暂停网络信息命令
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, obj);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
    return YES;
}

+ (BOOL)resumeNetwork:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //开始获取钱包信息
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 66;
    HTONS(CommandType);
    
    //生成获取钱包信息所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    
    //发送重启网络命令
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, obj);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
    return YES;
}

//申请加入一个群(本人申请加入)
+ (BOOL)apply4Group:(NSString *_Nonnull)groupId
             source:(NSString *_Nonnull)source
     completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    if (source.length == 0)
        source = @"";
    NSData *data4GroupId = [groupId dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data4MyUid = [[BiChatGlobal sharedManager].uid dataUsingEncoding:NSUTF8StringEncoding];
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *dict = [dec objectWithData:[source dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *data4Body = [dict mj_JSONData];
    
    //开始添加
    short headerSize = 74;
    HTONS(headerSize);
    int bodySize = (int)data4Body.length;
    HTONL(bodySize);
    short CommandType = 6;
    HTONS(CommandType);
    short userCount = 1;
    HTONS(userCount);
    
    //生成申请加入一个群所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4GroupId];
    [data appendData:[[NSData alloc]initWithBytes:&userCount length:2]];
    [data appendData:data4MyUid];
    [data appendData:data4Body];
    
    //发送获取钱包信息命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data1, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data1];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, obj);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)getPublicProperty:(NSString *_Nonnull)publicId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //获取群聊信息
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 91;
    HTONS(CommandType);
    
    //生成获取群聊信息所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    
    //添加群id
    [data appendData:[publicId dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送获取群聊信息命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, obj);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)getGroupProperty:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //判断参数
    if (groupId.length == 0)
        return NO;
    
    //使用 http portal
    [[WPBaseManager baseManager] getInterface:@"Chat/ApiGroup/getGroupUserList.do" parameters:@{@"groupId":groupId,@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token} success:^(id responseObject) {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *ret = responseObject;
        responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
        [responseObject setObject:groupId forKey:@"groupId"];
        if ([[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            //是不是虚拟群
            if ([[responseObject objectForKey:@"virtualGroupId"]length] > 0)
            {
                //虚拟群要同时获取一下子群的列表
                [NetworkModule getVirtualGroupList:[responseObject objectForKey:@"virtualGroupId"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    
                    if (success && [[data objectForKey:@"data"]count] > 0)
                    {
                        [responseObject setObject:[data objectForKey:@"data"] forKey:@"virtualGroupSubList"];
                    }
                    [[BiChatDataModule sharedDataModule]setGroupProperty:groupId property:responseObject];
                    
                    //回调
                    completedBlock(YES, NO, 0, responseObject);
                }];
            }
            else
            {
                [[BiChatDataModule sharedDataModule]setGroupProperty:groupId property:responseObject];
                completedBlock(YES, NO, 0, responseObject);
            }
        }
        else
        {
            //回调
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
        }
    } failure:^(NSError *error) {
        //回调
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

+ (BOOL)getGroupPropertyLite:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //当前本地是否已经有缓存
    if ([[BiChatDataModule sharedDataModule]getGroupProperty:groupId] == nil)
        return [self getGroupProperty:groupId completedBlock:completedBlock];
    
    //放消息入精选
    short headerSize = 40;
    HTONS(headerSize);
    short bodySize = 0;
    HTONL(bodySize);
    short CommandType = 141;
    HTONS(CommandType);
    
    //生成加入精选所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送加入精选命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            
            //获取原来的属性,以补全群成员列表
            NSMutableDictionary *groupPropertyTmp = [[BiChatDataModule sharedDataModule]getGroupProperty:groupId];
            if ([groupPropertyTmp objectForKey:@"groupUserList"] != nil)
                [responseObject setObject:[groupPropertyTmp objectForKey:@"groupUserList"] forKey:@"groupUserList"];
            
            //是不是虚拟群
            if ([[responseObject objectForKey:@"virtualGroupId"]length] > 0)
            {
                //虚拟群要同时获取一下子群的列表
                [NetworkModule getVirtualGroupList:[responseObject objectForKey:@"virtualGroupId"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                    
                    if (success && [[data objectForKey:@"data"]count] > 0)
                    {
                        [responseObject setObject:[data objectForKey:@"data"] forKey:@"virtualGroupSubList"];
                    }
                    [[BiChatDataModule sharedDataModule]setGroupProperty:groupId property:responseObject];
                    completedBlock(YES, NO, 0, responseObject);
                }];
            }
            else
            {
                [[BiChatDataModule sharedDataModule]setGroupProperty:groupId property:responseObject];
                completedBlock(YES, NO, 0, responseObject);
            }
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
#endif
    return YES;
}

+ (BOOL)pinMessage:(NSDictionary *_Nonnull)message inGroup:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //准备数据
    NSData *data4Message = [[message JSONString]dataUsingEncoding:NSUTF8StringEncoding];

    //放消息入精选
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = (int)data4Message.length;
    HTONL(bodySize);
    short CommandType = 48;
    HTONS(CommandType);
    
    //生成加入精选所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    
    //添加pin的消息
    [data appendData:data4Message];
    
    //添加钉的信息
    NSMutableDictionary *pinInfo = [NSMutableDictionary dictionary];
    [pinInfo setObject:groupId forKey:@"groupId"];
    [pinInfo setObject:@"MESSAGE" forKey:@"type"];
    [pinInfo setObject:[[message objectForKey:@"contentId"]stringByReplacingOccurrencesOfString:@"-" withString:@""] forKey:@"uuid"];
    NSData *data4PinInfo = [[pinInfo JSONString]dataUsingEncoding:NSUTF8StringEncoding];
    short groupInfoLength = (int)data4PinInfo.length;
    HTONS(groupInfoLength);
    [data appendData:[[NSData alloc]initWithBytes:&groupInfoLength length:2]];
    [data appendData:data4PinInfo];
    
    //发送加入精选命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, obj);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)unPinMessage:(NSString *_Nonnull)pinId inGroup:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSMutableDictionary *pinInfo = [NSMutableDictionary dictionary];
    [pinInfo setObject:groupId forKey:@"groupId"];
    [pinInfo setObject:@"MESSAGE" forKey:@"findType"];
    NSData *data4PinInfo = [[pinInfo JSONString]dataUsingEncoding:NSUTF8StringEncoding];

    //拔钉
    short headerSize = 72;
    HTONS(headerSize);
    int bodySize = (int)data4PinInfo.length;
    HTONL(bodySize);
    short CommandType = 49;
    HTONS(CommandType);
    
    //生成拔钉所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    
    //添加群id和messageid
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[pinId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:data4PinInfo];
    
    //发送拔钉命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, obj);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)getPinMessageList:(NSString *_Nonnull)groupId key:(NSString *_Nullable)key completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //生成获取精选的命令
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/getGroupDingLst.do?tokenid=%@&groupId=%@&type=MESSAGE", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token, groupId];
    
    //是不是有key
    if (key.length > 0)
        str4Url = [str4Url stringByAppendingFormat:@"&keyWord=%@", key];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //NSLog(@"%@", responseObject);
        if ([responseObject objectForKey:@"code"]!=nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
            completedBlock(YES, NO, 0, [NSMutableArray arrayWithArray:[responseObject objectForKey:@"list"]]);
        else
            completedBlock(NO, NO, 0, nil);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];

    return YES;
}

//设置一个加入精选的属性
+ (BOOL)flagPinMessage:(NSString *_Nonnull)groupId uuid:(NSString *_Nonnull)uuid flag:(NSDictionary *_Nonnull)flag completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //检查参数
    if (groupId.length != 32 ||
        uuid.length != 32)
        return NO;
    
    //生成数据
    NSMutableDictionary *pinInfo = [NSMutableDictionary dictionaryWithDictionary:flag];
    [pinInfo setObject:@"MESSAGE" forKey:@"findType"];
    NSData *body = [pinInfo JSONData];
    
    short headerSize = 72;
    HTONS(headerSize);
    int bodySize = (int)body.length;
    HTONL(bodySize);
    short CommandType = 101;
    HTONS(CommandType);
    
    //生成登录所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    
    //添加群id
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    //添加uuid
    [data appendData:[uuid dataUsingEncoding:NSUTF8StringEncoding]];
    //添加body
    [data appendData:body];
    
    //发送命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, obj);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)boardMessage:(NSDictionary *_Nonnull)message inGroup:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //准备数据
    NSData *data4Message = [[message JSONString]dataUsingEncoding:NSUTF8StringEncoding];
    
    //放消息入公告板
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = (int)data4Message.length;
    HTONL(bodySize);
    short CommandType = 48;
    HTONS(CommandType);
    
    //生成公告消息所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    
    //添加公告的消息
    [data appendData:data4Message];
    
    //添加公告的信息
    NSMutableDictionary *groupInfo = [NSMutableDictionary dictionary];
    [groupInfo setObject:groupId forKey:@"groupId"];
    [groupInfo setObject:@"BOARD" forKey:@"type"];
    [groupInfo setObject:[[message objectForKey:@"contentId"]stringByReplacingOccurrencesOfString:@"-" withString:@""] forKey:@"uuid"];
    NSData *data4GroupInfo = [[groupInfo JSONString]dataUsingEncoding:NSUTF8StringEncoding];
    short groupInfoLength = (int)data4GroupInfo.length;
    HTONS(groupInfoLength);
    [data appendData:[[NSData alloc]initWithBytes:&groupInfoLength length:2]];
    [data appendData:data4GroupInfo];
    
    //发送公告消息命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, obj);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)unBoardMessage:(NSString *_Nonnull)boardId inGroup:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSMutableDictionary *boardInfo = [NSMutableDictionary dictionary];
    [boardInfo setObject:groupId forKey:@"groupId"];
    [boardInfo setObject:@"BOARD" forKey:@"findType"];
    NSData *data4BoardInfo = [[boardInfo JSONString]dataUsingEncoding:NSUTF8StringEncoding];
    
    //拔钉
    short headerSize = 72;
    HTONS(headerSize);
    int bodySize = (int)data4BoardInfo.length;
    HTONL(bodySize);
    short CommandType = 49;
    HTONS(CommandType);
    
    //生成拔钉所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    
    //添加群id和messageid
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[boardId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:data4BoardInfo];
    
    //发送拔钉命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, obj);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)getBoardMessageList:(NSString *_Nonnull)groupId key:(NSString *_Nullable)key completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //生成获取公告板信息的命令
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/getGroupDingLst.do?tokenid=%@&groupId=%@&type=BOARD", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token, groupId];
    
    //是不是有key
    if (key.length > 0)
        str4Url = [str4Url stringByAppendingFormat:@"&keyWord=%@", key];

    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //NSLog(@"%@", responseObject);
        if ([responseObject objectForKey:@"code"]!=nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
            completedBlock(YES, NO, 0, [NSMutableArray arrayWithArray:[responseObject objectForKey:@"list"]]);
        else
            completedBlock(NO, NO, 0, nil);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];

    return YES;
}

+ (BOOL)favoriteMessage:(NSDictionary *_Nonnull)message msgId:(NSString *_Nonnull)msgId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //准备数据
    msgId = [msgId stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSData *data4Message = [[message JSONString]dataUsingEncoding:NSUTF8StringEncoding];
    
    //收藏消息
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = (int)data4Message.length;
    HTONL(bodySize);
    short CommandType = 52;
    HTONS(CommandType);
    
    //生成收藏消息所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    
    //添加收藏的消息
    [data appendData:data4Message];
    
    //添加收藏的信息
    NSMutableDictionary *favoriteInfo = [NSMutableDictionary dictionary];
    [favoriteInfo setObject:@"1" forKey:@"tag"];
    if (msgId != nil)
        [favoriteInfo setObject:msgId forKey:@"uuid"];
    NSData *data4FavoriteInfo = [[favoriteInfo JSONString]dataUsingEncoding:NSUTF8StringEncoding];
    short favoriteInfoLength = (int)data4FavoriteInfo.length;
    HTONS(favoriteInfoLength);
    [data appendData:[[NSData alloc]initWithBytes:&favoriteInfoLength length:2]];
    [data appendData:data4FavoriteInfo];
    
    //发送收藏消息命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, obj);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)unFavoriteMessage:(NSString *_Nonnull)msgId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    msgId = [msgId stringByReplacingOccurrencesOfString:@"-" withString:@""];

    //取消收藏
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 54;
    HTONS(CommandType);
    
    //生成取消收藏所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    
    //添加群id和messageid
    [data appendData:[msgId dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送拔钉命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, obj);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)getFavoriteMessageList:(NSString *_Nonnull)key
                      currPage:(NSInteger)currPage
                completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //使用 http portal 接口进行微信登录
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/searchUserFavoriteList.do?tokenid=%@", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token];
    
    //是不是有key
    if (key.length > 0)
        str4Url = [str4Url stringByAppendingFormat:@"&keyWord=%@", key];
    
    //是不是有分页
    if (currPage >= 0)
        str4Url = [str4Url stringByAppendingFormat:@"&currPage=%ld", currPage];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //NSLog(@"%@", responseObject);
        if ([responseObject objectForKey:@"code"]!=nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
            completedBlock(YES, NO, 0, [NSMutableArray arrayWithArray:[responseObject objectForKey:@"list"]]);
        else
            completedBlock(NO, NO, 0, nil);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];

    return YES;
}

+ (BOOL)followPublicAccount:(NSString *_Nonnull)accountId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //关注公号
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 71;
    HTONS(CommandType);
    
    //生成关注公号所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    
    //添加公号id
    [data appendData:[accountId dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送关注公号命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                completedBlock(YES, NO, 0, responseObject);
            }];
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        //NSLog(@"%@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    //重新获取一下通讯录
                    [self reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        completedBlock(YES, NO, 0, obj);
                    }];
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], obj);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)unfollowPublicAccount:(NSString *_Nonnull)accountId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //取消关注
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 72;
    HTONS(CommandType);
    
    //生成取消关注所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    
    //添加公号id
    [data appendData:[accountId dataUsingEncoding:NSUTF8StringEncoding]];
    
    //发送取消公号命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            [NetworkModule reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                completedBlock(YES, NO, 0, responseObject);
            }];
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    //重新获取一下通讯录
                    [self reloadContactList:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        completedBlock(YES, NO, 0, obj);
                    }];
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)searchPublicAccountByName:(NSString *_Nonnull)accountName completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSData *data4SearchKey = [accountName dataUsingEncoding:NSUTF8StringEncoding];
    //搜索公号
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = (int)data4SearchKey.length;
    HTONL(bodySize);
    short CommandType = 73;
    HTONS(CommandType);
    
    //生成搜索公号所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    
    //添加公号名称
    [data appendData:data4SearchKey];
    
    //发送搜索公号命令
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        if (isTimeOut)
        {
            completedBlock(NO, YES, 0, nil);
        }
        else
        {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0)
                {
                    completedBlock(YES, NO, 0, obj);
                }
                else
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//获取公开可抢的红包
+ (BOOL)getRedAvailableInfo:(NSString *)name completedBlock:(NetworkCompletedBlock)completedBlock
{
    NSData *nameKey = [name dataUsingEncoding:NSUTF8StringEncoding];
    short headerSize = 8 + nameKey.length;
    HTONS(headerSize);
    int bodySize = (int)name.length;
    HTONL(bodySize);
    short CommandType = 77;
    HTONS(CommandType);
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:nameKey];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//获取已经领过的红包
+ (BOOL)getReceivedRedList:(NSString *_Nonnull)uid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock {
    NSData *nameKey = [uid dataUsingEncoding:NSUTF8StringEncoding];
    short headerSize = 8 + nameKey.length;
    HTONS(headerSize);
    int bodySize = (int)uid.length;
    HTONL(bodySize);
    short CommandType = 76;
    HTONS(CommandType);
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:nameKey];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//群主/管理员移除用户出群
+ (BOOL)removeUsersFromGroup:(NSString *_Nonnull) groupId userList:(NSArray *_Nonnull)userList completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //检查参数
    if (userList.count == 0)
        return NO;
    
    //使用 http portal 接口进行获取
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/ApiGroup/removeUserFromGroup.do?tokenid=%@&groupId=%@&userCount=%zd&groupUserList=%@",
                         [BiChatGlobal sharedManager].apiUrl,
                         [BiChatGlobal sharedManager].token,
                         groupId,
                         userList.count,
                         [userList componentsJoinedByString:@","]];
    
    //GO!
    //NSLog(@"%@", str4Url);
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

//群主/管理员批准入群申请
+ (BOOL)approveGroupApplication:(NSString *_Nonnull)groupId userList:(NSArray *_Nonnull)userList completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //检查参数
    if (userList.count == 0)
        return YES;
    
    short headerSize = 42 + 32 * userList.count;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 45;
    HTONS(CommandType);
    short userCount = userList.count;
    HTONS(userCount);
    
    //生成批准入群所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSData alloc]initWithBytes:&userCount length:2]];
    for (int i = 0; i < userList.count; i ++)
        [data appendData:[[userList objectAtIndex:i]dataUsingEncoding:NSUTF8StringEncoding]];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//群主/管理员拒绝入群申请
+ (BOOL)rejectGroupApplication:(NSString *_Nonnull)groupId userList:(NSArray *_Nonnull)userList completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //检查参数
    if (userList.count == 0)
        return YES;
    
    short headerSize = 42 + 32 * userList.count;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 81;
    HTONS(CommandType);
    short userCount = userList.count;
    HTONS(userCount);
    
    //生成批准入群所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSData alloc]initWithBytes:&userCount length:2]];
    for (int i = 0; i < userList.count; i ++)
        [data appendData:[[userList objectAtIndex:i]dataUsingEncoding:NSUTF8StringEncoding]];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//申请人取消入群申请
+ (BOOL)cancelGroupApplication:(NSString *_Nonnull)groupId
                      userList:(NSArray *_Nonnull)userList
                completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //检查参数
    if (userList.count == 0)
        return YES;

    short headerSize = 42 + 32 * userList.count;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 46;
    HTONS(CommandType);
    short userCount = userList.count;
    HTONS(userCount);

    //生成批准入群所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSData alloc]initWithBytes:&userCount length:2]];
    for (int i = 0; i < userList.count; i ++)
        [data appendData:[[userList objectAtIndex:i]dataUsingEncoding:NSUTF8StringEncoding]];

#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//获取一个群的有效的入群审批列表
+ (BOOL)getGroupApproveList:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 83;
    HTONS(CommandType);
    
    //生成批准入群所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//获取一个用户在某群中的状态
+ (BOOL)getUserStatusInGroup:(NSString *_Nonnull)groupId userId:(NSString *_Nonnull)userId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    short headerSize = 72;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 79;
    HTONS(CommandType);
    
    //生成批准入群所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[userId dataUsingEncoding:NSUTF8StringEncoding]];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//创建一个客服交流群，用于客户和群管理员交流
+ (BOOL)createGroupServiceGroup:(NSString *_Nonnull)groupId
                         userId:(NSString *_Nonnull)userId
                 relatedGroupId:(NSString *_Nonnull)relatedGroupId
               relatedGroupType:(NSInteger)relatedGroupType
                 completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSData *data4Body = nil;
    if (relatedGroupId.length > 0)
    {
        NSDictionary *body = @{@"relatedGroupId": relatedGroupId, @"relatedGroupType": [NSNumber numberWithInteger:relatedGroupType]};
        data4Body = [body JSONData];
    }
    short headerSize = 72;
    HTONS(headerSize);
    int bodySize = (int)data4Body.length;
    HTONL(bodySize);
    short CommandType = 161;
    HTONS(CommandType);
    
    //生成批准入群所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[userId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:data4Body];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//扫码登录
+ (BOOL)scanLoginWithstring:(NSString *_Nonnull)string completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock {
    
    NSData *data4String = [string dataUsingEncoding:NSUTF8StringEncoding];
    short headerSize = 8 + data4String.length;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 88;
    HTONS(CommandType);
    
    //生成批准入群所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4String];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)scanPublicManaemengLogingWithstring:(NSString *_Nonnull)string completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock {
    
    NSData *data4String = [string dataUsingEncoding:NSUTF8StringEncoding];
    short headerSize = 8 + data4String.length;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 102;
    HTONS(CommandType);
    
    //生成批准入群所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4String];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//创建一个虚拟群
+ (BOOL)createVirtualGroup:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 84;
    HTONS(CommandType);
    
    //生成批准入群所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//创建一个虚拟群广播子群
+ (BOOL)createVirtualGroupBroadCastGroup:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 151;
    HTONS(CommandType);
    
    //生成批准入群所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            NSLog(@"%@", ret);
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//获取一个虚拟群有几个子群
+ (BOOL)getVirtualGroupList:(NSString *_Nonnull)virtualGroupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 85;
    HTONS(CommandType);
    
    //生成批准入群所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[virtualGroupId dataUsingEncoding:NSUTF8StringEncoding]];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//获取一个虚拟群的主群id
+ (BOOL)getMainGroupIdByVirtualGroup:(NSString *)virtualGroupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 86;
    HTONS(CommandType);
    
    //生成批准入群所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[virtualGroupId dataUsingEncoding:NSUTF8StringEncoding]];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//创建一个虚拟群子群
+ (BOOL)createVirtualSubGroup:(NSString *_Nonnull)virtualGroupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 93;
    HTONS(CommandType);
    
    //生成批准入群所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[virtualGroupId dataUsingEncoding:NSUTF8StringEncoding]];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//根据昵称搜索一个虚拟群里面的用户
+ (BOOL)searchVirtualGroupByNickName:(NSString *_Nonnull)nickName groupId:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    if (nickName.length == 0)
        return NO;
    NSData *data4SearchKey = [nickName dataUsingEncoding:NSUTF8StringEncoding];
    
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = (int)data4SearchKey.length;
    HTONL(bodySize);
    short CommandType = 89;
    HTONS(CommandType);
    
    //生成批准入群所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:data4SearchKey];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//拉人进入群
+ (BOOL)addGroupMember:(NSArray *_Nonnull)contacts
               groupId:(NSString *_Nonnull)groupId
                source:(NSDictionary * _Nonnull)source
        completedBlock:(NetworkCompletedBlock  _Nonnull)completedBlock
{
    //检查参数
    if (contacts.count == 0)
        return NO;
    
    //使用 http portal 接口进行获取
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/ApiGroup/joinGroup.do?tokenid=%@&groupId=%@&userCount=%zd&groupUserList=%@&source=%@&inviterId=%@",
                         [BiChatGlobal sharedManager].apiUrl,
                         [BiChatGlobal sharedManager].token,
                         groupId,
                         contacts.count,
                         [contacts componentsJoinedByString:@","],
                         [source objectForKey:@"source"],
                         [source objectForKey:@"inviterId"]
                         ];
    
    //GO!
    //NSLog(@"%@", str4Url);
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

//拉人进入虚拟群
+ (BOOL)addVirtualGroupMember:(NSArray *_Nonnull)contacts virtualGroupId:(NSString *_Nonnull)virtualGroupId groupId:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //检查参数
    if (contacts.count == 0)
        return NO;
    
    short headerSize = 74 + contacts.count * 32;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 94;
    HTONS(CommandType);
    short count = contacts.count;
    HTONS(count);
    
    //生成批准入群所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[virtualGroupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSData alloc]initWithBytes:&count length:2]];
    
    //添加所有的uid
    for (int i = 0; i < contacts.count; i ++)
        [data appendData:[[contacts objectAtIndex:i]dataUsingEncoding:NSUTF8StringEncoding]];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//获取不能自动入群的人员列表
+ (BOOL)getAutoRejectApplyList:(NSString *)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    if (groupId.length == 0)
        return NO;
    
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 100;
    HTONS(CommandType);
    
    //生成批准入群所需数据包
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//红包入群
+ (BOOL)joinGroupWithGroupId:(NSString *_Nonnull)groupId jsonData:(NSDictionary *)jsonData completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock {
    if (groupId.length == 0)
        return NO;
    NSData *data4Body = [NSJSONSerialization dataWithJSONObject:jsonData options:NSJSONWritingPrettyPrinted error:nil];
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = (int)data4Body.length;
    HTONL(bodySize);
    short CommandType = 103;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:data4Body];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], obj);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//升级普通群为大大群
+ (BOOL)upgradeToBigGroup:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    if (groupId.length == 0)
        return NO;
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 96;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//订阅大大群的消息
+ (BOOL)subscribeBigGroup:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //NSLog(@"subscribeBigGroup:%@", groupId);
    if (groupId.length == 0)
        return NO;
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 97;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
    return YES;
}

//取消订阅大大群的消息
+ (BOOL)unSubscribeBigGroup:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //NSLog(@"unsubscribeBigGroup:%@", groupId);
    if (groupId.length == 0)
        return NO;
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 98;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }

    return YES;
}

//获取大大群特定返回的消息
+ (BOOL)getBigGroupMessage:(NSString *_Nonnull)groupId from:(NSInteger)fromIndex to:(NSInteger)toIndex completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    if (groupId.length == 0)
        return NO;
    
    //生成body体
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:fromIndex], @"start", [NSNumber numberWithInteger:toIndex], @"end", nil];
    NSData *data4Body = [dict JSONData];
    //NSLog(@"%@", dict);
    
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = (int)data4Body.length;
    HTONL(bodySize);
    short CommandType = 99;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:data4Body];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//搜索大大群的群用户
+ (BOOL)searchBigGroupMember:(NSString *_Nonnull)groupId keyWord:(NSString *_Nonnull)keyWord completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //使用 http portal 接口进行微信登录 
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/searchGroupUserList.do?tokenid=%@&groupId=%@&keyWord=%@", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token, groupId, keyWord];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

+ (BOOL)blockGroupMembers:(NSString *_Nonnull)groupId userIds:(NSArray *_Nonnull)userIds completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //检查参数
    if (groupId.length == 0 || userIds.count == 0)
        return NO;
    
    short headerSize = 42 + 32 * userIds.count;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 104;
    HTONS(CommandType);
    short userCount = userIds.count;
    HTONS(userCount);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSData alloc]initWithBytes:&userCount length:2]];
    for (int i = 0; i < userIds.count; i ++)
        [data appendData:[[userIds objectAtIndex:i] dataUsingEncoding:NSUTF8StringEncoding]];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)blockGroupMember:(NSString *_Nonnull)groupId userId:(NSString *_Nonnull)userId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //检查参数
    if (groupId.length == 0 || userId.length == 0)
        return NO;
    
    short headerSize = 74;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 104;
    HTONS(CommandType);
    short userCount = 1;
    HTONS(userCount);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSData alloc]initWithBytes:&userCount length:2]];
    [data appendData:[userId dataUsingEncoding:NSUTF8StringEncoding]];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//将一个人移出黑名单
+ (BOOL)unBlockGroupMember:(NSString *_Nonnull)groupId userId:(NSString *_Nonnull)userId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //检查参数
    if (groupId.length == 0 || userId.length == 0)
        return NO;
    
    short headerSize = 74;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 70;
    HTONS(CommandType);
    short userCount = 1;
    HTONS(userCount);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSData alloc]initWithBytes:&userCount length:2]];
    [data appendData:[userId dataUsingEncoding:NSUTF8StringEncoding]];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//禁言
+ (BOOL)forbidGroupMember:(NSString *_Nonnull)groupId userIds:(NSArray *_Nonnull)userIds completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //检查参数
    if (groupId.length == 0 || userIds.count == 0)
        return NO;
    
    NSDictionary *para = @{@"expireMinutes":[NSNumber numberWithInteger:60 * 24]};
    NSData *data4Para = [para mj_JSONData];
    
    short headerSize = 42 + userIds.count * 32;
    HTONS(headerSize);
    int bodySize = (int)data4Para.length;
    HTONL(bodySize);
    short CommandType = 137;
    HTONS(CommandType);
    short userCount = userIds.count;
    HTONS(userCount);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSData alloc]initWithBytes:&userCount length:2]];
    for (int i = 0; i < userIds.count; i ++)
        [data appendData:[[userIds objectAtIndex:i] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:data4Para];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)unForbidGroupMember:(NSString *_Nonnull)groupId userIds:(NSArray *_Nonnull)userIds completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //检查参数
    if (groupId.length == 0 || userIds.count == 0)
        return NO;

    short headerSize = 42 + userIds.count * 32;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 138;
    HTONS(CommandType);
    short userCount = 1;
    HTONS(userCount);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSData alloc]initWithBytes:&userCount length:2]];
    for (int i = 0; i < userIds.count; i ++)
        [data appendData:[[userIds objectAtIndex:i] dataUsingEncoding:NSUTF8StringEncoding]];

#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//报告我的ios client environmeng
+ (BOOL)reportMyEnvironment:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Version = [BiChatGlobal getAppVersion];

    //用户还没有登录，则不发送
    if ([BiChatGlobal sharedManager].uid.length == 0)
        return YES;

    //生成本地环境信息
    NSDictionary *envInfo = @{@"eventType":@"APP_INFO",
                              @"client":@"iOS",
                              @"appVersion":str4Version,
                              @"osVersion":[UIDevice currentDevice].systemVersion,
                              @"phoneModel":[BiChatGlobal getIphoneType],
                              @"ipAddress":[BiChatGlobal getLocalIpAddress],
                              @"opUid":[BiChatGlobal sharedManager].uid,
                              @"adID":[[[ASIdentifierManager sharedManager]advertisingIdentifier]UUIDString]
                              };
    NSLog(@"%@", envInfo);
    NSData *data4Env = [envInfo JSONData];
    
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = (int)data4Env.length;
    HTONL(bodySize);
    short CommandType = 111;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4Env];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)reportMyGroupAccess:(NSArray *_Nonnull)groupList completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //用户还没有登录，则不发送
    if ([BiChatGlobal sharedManager].uid.length == 0)
        return YES;
    
    //生成本地环境信息
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *item in groupList)
    {
        [array addObject:@{@"groupId":item, @"uid":[BiChatGlobal sharedManager].uid}];
    }
    
    NSDictionary *accessInfo = @{@"groupAccess":array};
    NSData *data4access = [accessInfo JSONData];
    
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = (int)data4access.length;
    HTONL(bodySize);
    short CommandType = 111;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4access];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//报告我的ios notification device id
+ (BOOL)reportMyNotificationId:(NSString *_Nonnull)notificationId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //检查参数
    if (notificationId.length == 0 ||
        ![BiChatGlobal sharedManager].bLogin ||
        [BiChatGlobal sharedManager].token.length == 0)
        return NO;
    
    //生成数据
    NSData *data4NotificationId = [notificationId dataUsingEncoding:NSUTF8StringEncoding];
    
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = (int)data4NotificationId.length;
    HTONL(bodySize);
    short CommandType = 105;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4NotificationId];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"--report token return: %@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//报告我的当前未读消息个数
+ (BOOL)reportMyUnreadMessageCount:(NSInteger)count completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 106;
    HTONS(CommandType);
    short unreadMessageCount = count;
    HTONS(unreadMessageCount);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&unreadMessageCount length:2]];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//创建直播群
+ (BOOL)liveGroupCreate:(NSString *)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    if (groupId.length == 0)
        return NO;
    NSData *data4NotificationId = [groupId dataUsingEncoding:NSUTF8StringEncoding];
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = (int)data4NotificationId.length;
    HTONL(bodySize);
    short CommandType = 110;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4NotificationId];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)getTokenInfo:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //使用 http portal 接口进行微信登录
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/ApiPay/getAccountBalance.do?tokenid=%@", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    return YES;
}

//获取充币地址
+ (BOOL)getRechargeAddress:(NSString *_Nonnull)coinType completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //使用 http portal 接口进行微信登录
    NSString *str4Url = [NSString stringWithFormat:@"%@/Chat/ApiPay/getRechargeAddress.do?tokenid=%@&coinType=%@", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token, coinType];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    return YES;
}

//生成充币地址
+ (BOOL)createRechargeAddress:(NSString *_Nonnull)coinType completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //使用 http portal 接口进行微信登录
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/ApiPay/createRechargeAddress.do?tokenid=%@&coinType=%@", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token, coinType];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    return YES;
}

//提币
+ (BOOL)withdrawCoin:(NSString *_Nonnull)coinType address:(NSString *_Nonnull)address password:(NSString *_Nonnull)password amount:(NSString *_Nonnull)amount  completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/ApiPay/withdraw.do?tokenid=%@&coinType=%@&address=%@&password=%@&amount=%@", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token, coinType, address, password, amount];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    return YES;
}

//获取我的原力奖励情况
+ (BOOL)getMyForceReward:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/getAllUserPoints.do?tokenid=%@", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    return YES;
}

//赚积分
+ (BOOL)reportPoint:(NSString *)type completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //准备参数
    if (type == nil)
        return NO;
    NSDictionary *body = @{@"type":type};
    NSData *data4Body = [body JSONData];
    
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = (int)data4Body.length;
    HTONL(bodySize);
    short CommandType = 117;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4Body];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//获取appconfig
+ (BOOL)getAppConfig:(NSString *_Nonnull)versionNum completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //准备参数
    if (versionNum == nil)
        return NO;
    NSDictionary *body = @{@"versionNum":@"1"};
    NSData *data4Body = [body JSONData];
    
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = (int)data4Body.length;
    HTONL(bodySize);
    short CommandType = 119;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4Body];
    
    if ([BiChatGlobal sharedManager].token.length == 0)
    {
        if (![PokerStreamClient sendRequest:nil binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
            if (isTimeOut) {
                completedBlock(NO, YES, 0, nil);
            } else {
                JSONDecoder *dec = [JSONDecoder new];
                id obj = [dec mutableObjectWithData:data];
                //NSLog(@"%@", obj);
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    if ([obj objectForKey:@"errorCode"] != nil &&
                        [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                        completedBlock(YES, NO, 0, obj);
                    } else {
                        completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                    }
                }
            }
        }])
        {
            return NO;
        }
    }
    else
    {
        if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
            if (isTimeOut) {
                completedBlock(NO, YES, 0, nil);
            } else {
                JSONDecoder *dec = [JSONDecoder new];
                id obj = [dec mutableObjectWithData:data];
                //NSLog(@"%@", obj);
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    if ([obj objectForKey:@"errorCode"] != nil &&
                        [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                        completedBlock(YES, NO, 0, obj);
                    } else {
                        completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                    }
                }
            }
        }])
        {
            return NO;
        }
    }
    
    return YES;
}

//收割气泡
+ (BOOL)getBubble:(NSString *_Nonnull)type uuid:(NSString *_Nonnull)uuid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/receiveBubble.do?tokenid=%@&type=%@&uuid=%@", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token, type, uuid];
    
    //GO!
    //NSLog(@"%@", str4Url);
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];

    return YES;
}

//获取我的双向好友列表
+ (BOOL)getMyFriendList:(NSInteger)currPage completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/getUserFriendRankList?tokenid=%@&currPage=%zd", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token, currPage];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

//获取我推荐的用户列表
+ (BOOL)getMyInvitedUserList:(NSInteger)currPage completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/getUserInviterList.do?tokenid=%@&currPage=%zd", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token, currPage];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

//点赞我推荐的用户
+ (BOOL)likeMyInvitedUser:(NSString *_Nonnull)uid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/saveBeInvitedLike.do?tokenid=%@&inviterUid=%@", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token, uid];
    
    //GO!
    //NSLog(@"%@", str4Url);
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

//获取我的解锁日历
+ (BOOL)getMyUnlockHistory:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/getUserUnlockHistoryList.do?tokenid=%@", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token];
    
    //GO!
    //NSLog(@"%@", str4Url);
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

//获取按日期和按用户排列的推荐奖励的详情页
+ (BOOL)getUserInviteeListByDate:(NSInteger)currPage completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/getUserInviteeListByDate.do?tokenid=%@&currPage=%ld", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token, (long)currPage];
    
    //GO!
    //NSLog(@"%@", str4Url);
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

+ (BOOL)getUserInviteeListByUser:(NSInteger)currPage completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/getUserInviteeListByUser.do?tokenid=%@&currPage=%ld", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token, (long)currPage];
    
    //GO!
    //NSLog(@"%@", str4Url);
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

//获取奖池流水
+ (BOOL)getPoolAccount:(NSInteger)currPage completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/getFundSummaryByDate.do?tokenid=%@&currPage=%ld", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token, (long)currPage];
    
    //GO!
    //NSLog(@"%@", str4Url);
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

//获取奖池流水（新）
+ (BOOL)getPoolHistory:(NSInteger)currPage completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/ApiPay/getFundBalanceHistoryList.do?tokenid=%@&currPage=%ld&coinType=TOKEN", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token, (long)currPage];
    
    //GO!
    NSLog(@"%@", str4Url);
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

//报告ack消息
+ (BOOL)reportActMessage:(NSString *)msgId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    short count = 1;
    HTONS(count);
    NSData *data4Body = [msgId dataUsingEncoding:NSUTF8StringEncoding];
    
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = (int)data4Body.length + 2;
    HTONL(bodySize);
    short CommandType = 127;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&count length:2]];
    [data appendData:data4Body];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//报告文件删除
+ (BOOL)reportFileDelete:(NSString *_Nonnull)msgId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/delFile.do?tokenid=%@&idList=%@", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token, msgId];

    //GO!
    //NSLog(@"%@", str4Url);
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

//报告文件上传
+ (BOOL)reportFileSave:(NSString *_Nonnull)fileName uploadName:(NSString *_Nonnull)uploadName length:(long)length uuid:(NSString *_Nonnull)uuid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/saveFile.do?tokenid=%@&fileName=%@&uploadName=%@&length=%ld&uuid=%@", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token, fileName, uploadName, length, uuid];
    
    //GO!
    //NSLog(@"%@", str4Url);
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

//设置大V的第二邀请码
+ (BOOL)updateVipRefCode:(NSString *_Nonnull)refCode completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/updateVipRefCode.do?tokenid=%@&refCode=%@", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token, refCode];
    
    //GO!
    //NSLog(@"%@", str4Url);
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}
+ (BOOL)getNearbyListWithLatitude:(double)latitude longitude:(double)longitude gender:(NSString *)gender completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //准备数据
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
    [dic setObject:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
    if (gender && ![gender isEqualToString:@"0"]) {
        [dic setObject:gender forKey:@"gender"];
    }
    NSData *data4Message = [[dic JSONString]dataUsingEncoding:NSUTF8StringEncoding];

    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = (int)data4Message.length;
    HTONL(bodySize);
    short CommandType = 133;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4Message];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];

    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    //发送加入精选命令
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        }
        else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                }
                else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }]) {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)clearNearbyInfoCompletedBlock:(NetworkCompletedBlock _Nonnull)completedBlock {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSData *data4Message = [[dic JSONString]dataUsingEncoding:NSUTF8StringEncoding];
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = (int)data4Message.length;
    HTONL(bodySize);
    short CommandType = 133;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4Message];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    //发送加入精选命令
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        }
        else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                }
                else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
            else
                completedBlock(NO, NO, 0, nil);
        }
    }]) {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)getSameGroupList:(NSString *)uid completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock {
    if (uid.length == 0)
        return NO;
    NSData *data4NotificationId = [uid dataUsingEncoding:NSUTF8StringEncoding];
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = (int)data4NotificationId.length;
    HTONL(bodySize);
    short CommandType = 146;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4NotificationId];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
            else
                completedBlock(NO, NO, 0, nil);
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)dismissGroup:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 145;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *ret = responseObject;
        responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
            completedBlock(YES, NO, 0, responseObject);
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
            else
                completedBlock(NO, NO, 0, nil);
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

//copy群成员到另外一个群
+ (BOOL)copyGroupMemberFrom:(NSString *)fromGroupId To:(NSString *_Nonnull)toGroupId members:(NSArray *)members completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    short headerSize = 74 + members.count * 32;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 148;
    HTONS(CommandType);
    short userCount = members.count;
    HTONS(userCount);
    
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[fromGroupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[toGroupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSData alloc]initWithBytes:&userCount length:2]];
    for (int i = 0; i < members.count; i ++)
        [data appendData:[[[members objectAtIndex:i]objectForKey:@"uid"]dataUsingEncoding:NSUTF8StringEncoding]];
//    NSDictionary *dict = @{@"source":@"MOVE",@"inviterId":[BiChatGlobal sharedManager].uid};
//    [data appendData:[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil]];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
            else
                completedBlock(NO, NO, 0, nil);
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)scanGroupManagement:(NSString *_Nonnull)string completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock {
    
    NSData *data4String = [string dataUsingEncoding:NSUTF8StringEncoding];
    short headerSize = 8 + data4String.length;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 147;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4String];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        } else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            //NSLog(@"%@", obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                } else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }])
    {
        return NO;
    }
#endif
    return YES;
}

+ (BOOL)getMyGroupListCompletedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 150;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
   AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    //发送加入精选命令
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        }
        else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                }
                else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }]) {
        return NO;
    }
#endif
    return YES;
}

//领取token
+ (BOOL)unLockToken:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/receiveUnTokenReward.do?tokenid=%@&coinType=TOKEN", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token];
    
    //GO!
    //NSLog(@"%@", str4Url);
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //NSLog(@"%@", responseObject);
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

//领取point
+ (BOOL)receivePoint:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/receiveUnTokenReward.do?tokenid=%@&coinType=POINT", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token];
    
    //GO!
    //NSLog(@"%@", str4Url);
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

//获取任务列表
+ (BOOL)getTaskList:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/getActiveTaskList.do?tokenid=%@&language=%@", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token, [DFLanguageManager getLanguageName]];
    
    //GO!
    //NSLog(@"%@", str4Url);
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

//领取任务红包
+ (BOOL)receiveTaskReward:(NSString *)taskId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/receiveTaskReward.do?tokenid=%@&taskId=%@", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token, taskId];
    
    //GO!
    //NSLog(@"%@", str4Url);
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

//批量获取收件箱消息
+ (BOOL)batchGetMessage:(NSInteger)messageCount ackBatchId:(NSString *)ackBatchId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/batchMsg.do?tokenid=%@&messageSize=%ld&batchId=%@", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token, (long)messageCount, ackBatchId];
    
    //GO!
    //NSLog(@"%@", str4Url);
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    httmMgr.requestSerializer = [AFHTTPRequestSerializer serializer];
    httmMgr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    httmMgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        NSDictionary *allHeaders = response.allHeaderFields;
        //NSLog(@"%@", allHeaders);
        
        if (responseObject != nil && [responseObject isKindOfClass:[NSData class]])
        {
            NSMutableArray *array4Message = [NSMutableArray array];
            NSInteger offset = 0;
            while (offset < ((NSData *)responseObject).length)
            {
                long length;
                [responseObject getBytes:&length range:NSMakeRange(offset, 4)];
                offset += 4;
                NTOHL(length);
                if (offset + length <= ((NSData *)responseObject).length)
                {
                    NSData *data = [responseObject subdataWithRange:NSMakeRange(offset, length)];
                    JSONDecoder *dec = [JSONDecoder new];
                    NSMutableDictionary *message = [dec mutableObjectWithData:data];
                    [array4Message addObject:message];
                }
                offset += length;
            }
            //NSLog(@"%@", array4Message);
            
            responseObject = [NSMutableDictionary dictionary];
            [responseObject setObject:array4Message forKey:@"messages"];
            if ([allHeaders objectForKey:@"batchId"] != nil)
                [responseObject setObject:[allHeaders objectForKey:@"batchId"] forKey:@"batchId"];
            if ([allHeaders objectForKey:@"leftMessages"] != nil)
                [responseObject setObject:[allHeaders objectForKey:@"leftMessages"] forKey:@"leftMessages"];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(YES, NO, 0, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

//网络测试
+ (BOOL)networkTest:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [[BiChatGlobal sharedManager].systemConfig objectForKey:@"connectivityTestURL"];
    if (str4Url == nil)
    {
        [BiChatGlobal sharedManager].systemConfigVersionNumber = @"1";
        [[BiChatGlobal sharedManager]saveGlobalInfo];
        return NO;
    }
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    httmMgr.requestSerializer = [AFHTTPRequestSerializer serializer];
    httmMgr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    httmMgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completedBlock(YES, NO, 0, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}

+ (void)saveWebApiAccess:(NSString *)url
{
    //去掉参数
    if ([url rangeOfString:@"?"].length > 0)
        url = [url substringToIndex:[url rangeOfString:@"?"].location];
    
    //保存
    if ([BiChatGlobal sharedManager].array4WebApiAccess == nil)
        [BiChatGlobal sharedManager].array4WebApiAccess = [NSMutableArray array];
    [[BiChatGlobal sharedManager].array4WebApiAccess addObject:url];
    if ([BiChatGlobal sharedManager].array4WebApiAccess.count > 5)
        [[BiChatGlobal sharedManager].array4WebApiAccess removeObjectAtIndex:0];
}

//发送邮件
- (void)sendEmailToServiceCenter:(NSString *)title content:(NSString *)content completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    sendReportEmailCompletedBlock = completedBlock;
    SKPSMTPMessage *myMessage = [[SKPSMTPMessage alloc] init];
    //此处发件箱已163为例：
    myMessage.fromEmail = [[BiChatGlobal sharedManager].systemConfig objectForKey:@"sendFrom"];//发送者邮箱
    myMessage.toEmail = [[BiChatGlobal sharedManager].systemConfig objectForKey:@"sendTo"];//收件邮箱
    //myMessage.bccEmail = @"******@qq.com";//抄送
    
    //myMessage.relayHost = @"smtp.exmail.qq.com";//发送地址host 腾讯企业邮箱:smtp.exmail.qq.com
    NSArray *array = [[[BiChatGlobal sharedManager].systemConfig objectForKey:@"sendFromHost"]componentsSeparatedByString:@":"];
    if (array.count > 0)
        myMessage.relayHost = [array objectAtIndex:0];
    if (array.count > 1)
        myMessage.relayPorts = @[[NSNumber numberWithShort:[[array objectAtIndex:1]integerValue]]];
    myMessage.requiresAuth = YES;
    if (myMessage.requiresAuth) {
        myMessage.login = [[BiChatGlobal sharedManager].systemConfig objectForKey:@"sendFromUser"];//发送者邮箱的用户名
        myMessage.pass = [[BiChatGlobal sharedManager].systemConfig objectForKey:@"sendFromPass"];//发送者邮箱的密码
    }
    myMessage.wantsSecure = YES;//为gmail邮箱设置 smtp.gmail.com
    myMessage.subject = title;//邮件主题
    myMessage.delegate = self;
    
    /* >>>>>>>>>>>>>>>>>>>> *   设置邮件内容   * <<<<<<<<<<<<<<<<<<<< */
    //1.文字信息
    NSDictionary *plainPart = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"text/plain; charset=UTF-8", kSKPSMTPPartContentTypeKey,
                               content, kSKPSMTPPartMessageKey,
                               @"8bit", kSKPSMTPPartContentTransferEncodingKey,nil];
    
    /* >>>>>>>>>>>>>>>>>>>> *   添加附件   * <<<<<<<<<<<<<<<<<<<< */
    /*
     //2.联系人信息附件
     NSDictionary *vcfPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/directory;\r\n\tx-unix-mode=0644;\r\n\tname=\"test.vcf\"",kSKPSMTPPartContentTypeKey,
     @"attachment;\r\n\tfilename=\"test.vcf\"",kSKPSMTPPartContentDispositionKey,[vcfData encodeBase64ForData],kSKPSMTPPartMessageKey,@"base64",kSKPSMTPPartContentTransferEncodingKey,nil];
     */
    
    //3.图片和视频附件
    /*
     //3.1视频附件
     NSDictionary *videoPart = [NSDictionary dictionaryWithObjectsAndKeys:@"video/quicktime;\r\n\tx-unix-mode=0644;\r\n\tname=\"video.mov\"",kSKPSMTPPartContentTypeKey,
     @"attachment;\r\n\tfilename=\"video.mov\"",kSKPSMTPPartContentDispositionKey,[videoData encodeBase64ForData],kSKPSMTPPartMessageKey,@"base64",kSKPSMTPPartContentTransferEncodingKey,nil];
     */
    
    //获取当前屏幕截图
    /*
     UIGraphicsBeginImageContextWithOptions(CGSizeMake(kIPHONE_WIDTH, kIPHONE_HEIGHT), NO, [[UIScreen mainScreen] scale]);
     [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:NO];
     UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     NSData *imageData = UIImageJPEGRepresentation(snapshot, 1.0);
     
     //3.2图片附件
     NSDictionary *imagePart = [NSDictionary dictionaryWithObjectsAndKeys:@"image/jpg;\r\n\tx-unix-mode=0644;\r\n\tname=\"snapshot.jpg\"",kSKPSMTPPartContentTypeKey,
     @"attachment;\r\n\tfilename=\"snapshot.jpg\"",kSKPSMTPPartContentDispositionKey,[imageData encodeBase64ForData],kSKPSMTPPartMessageKey,@"base64",kSKPSMTPPartContentTransferEncodingKey,nil];
     */
    
    myMessage.parts = [NSArray arrayWithObjects:plainPart,nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [myMessage send];
    });
}

-(void)messageSent:(SKPSMTPMessage *)message
{
    if (sendReportEmailCompletedBlock)
        sendReportEmailCompletedBlock(YES, NO, 0, nil);
}

-(void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error
{
    if (sendReportEmailCompletedBlock)
        sendReportEmailCompletedBlock(NO, NO, error.code, nil);
}
          

//升级一个群为收费群
+ (BOOL)upgradeToChargeGroup:(NSString *_Nonnull)groupId newGroupName:(NSString *)newGroupName coinType:(NSString *_Nonnull)coinType payValue:(NSString *_Nonnull)payValue trailTime:(NSInteger)trailTime oldGroupUserTrail:(BOOL)oldGroupUserTrail oldGroupUserExpiredTime:(NSInteger)oldGroupUserExpiredTime onePayUserExpiredTime:(NSInteger)onePayUserExpiredTime completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;
{
    //准备数据
    long long oldGroupUserExpiredTimestamp = oldGroupUserExpiredTime * 1000;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:groupId forKey:@"groupId"];
    [dic setObject:newGroupName forKey:@"newGroupName"];
    [dic setObject:coinType forKey:@"coinType"];
    [dic setObject:payValue forKey:@"payValue"];
    [dic setObject:[NSNumber numberWithLongLong:trailTime * 1000] forKey:@"trailTime"];
    [dic setObject:[NSNumber numberWithBool:!oldGroupUserTrail] forKey:@"oldGroupUserTrail"];
    [dic setObject:[NSNumber numberWithLongLong:oldGroupUserExpiredTimestamp] forKey:@"oldGroupUserExpiredTimestamp"];
    [dic setObject:[NSNumber numberWithLongLong:onePayUserExpiredTime * 1000] forKey:@"onePayUserExpiredTime"];
    NSData *data4Message = [[dic JSONString]dataUsingEncoding:NSUTF8StringEncoding];    
    
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = (int)data4Message.length;
    HTONL(bodySize);
    short CommandType = 78;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4Message];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    //发送加入精选命令
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        }
        else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                }
                else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }]) {
        return NO;
    }
#endif
    return YES;
}

//收费群创建支付订单
+ (BOOL)createChargeGroupOrder:(NSString *_Nonnull)groupId remark:(NSString *_Nonnull)remark completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //准备数据
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:remark forKey:@"remark"];
    NSData *data4Message = [[dic JSONString]dataUsingEncoding:NSUTF8StringEncoding];
    
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = (int)data4Message.length;
    HTONL(bodySize);
    short CommandType = 156;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:data4Message];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    //发送加入精选命令
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        }
        else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                }
                else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }]) {
        return NO;
    }
#endif
    return YES;
}

//删除收费群已经存在的订单
+ (BOOL)deleteChargeGroupOrder:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 157;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    //发送加入精选命令
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        }
        else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                }
                else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }]) {
        return NO;
    }
#endif
    return YES;
}

//支付入群
+ (BOOL)payChargeGroupOrder:(NSString *_Nonnull)groupId paymentPassword:(NSString *_Nonnull)paymentPassword completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    short headerSize = 40;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short CommandType = 80;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[paymentPassword dataUsingEncoding:NSUTF8StringEncoding]];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    //发送加入精选命令
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        }
        else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                }
                else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }]) {
        return NO;
    }
#endif
    return YES;
}

//延展收费群Trail用户的过期时间
+ (BOOL)extentChargeGroupTrailTimeStamp:(NSString *_Nonnull)groupId uids:(NSArray *_Nonnull)uids extendTimeStamp:(NSInteger)extendTimeStamp completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    //准备数据
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:groupId forKey:@"groupId"];
    [dic setObject:uids forKey:@"uids"];
    [dic setObject:[NSNumber numberWithInteger:extendTimeStamp] forKey:@"extendTimeStamp"];
    NSData *data4Message = [[dic JSONString]dataUsingEncoding:NSUTF8StringEncoding];
    
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = (int)data4Message.length;
    HTONL(bodySize);
    short CommandType = 159;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4Message];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    //发送加入精选命令
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        }
        else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                }
                else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }]) {
        return NO;
    }
#endif
    return YES;
}

//计算一下解散群需要的花费
+ (BOOL)getDismissChargeGroupFee:(NSString *_Nonnull)groupId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    short headerSize = 42 + 32;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short userCount = 1;
    HTONS(userCount);
    short CommandType = 160;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSData alloc]initWithBytes:&userCount length:2]];
    [data appendData:[ALLMEMBER_UID dataUsingEncoding:NSUTF8StringEncoding]];
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *ret = responseObject;
        responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
            completedBlock(YES, NO, 0, responseObject);
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    //发送加入精选命令
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        }
        else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                }
                else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }]) {
        return NO;
    }
#endif
    return YES;
}

//计算一下踢人需要的花费
+ (BOOL)getKickFromChargeGroupFee:(NSString *_Nonnull)groupId uids:(NSArray *_Nonnull)uids completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock
{
    short headerSize = 42 + 32 * uids.count;
    HTONS(headerSize);
    int bodySize = 0;
    HTONL(bodySize);
    short userCount = 1;
    HTONS(userCount);
    short CommandType = 160;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSData alloc]initWithBytes:&userCount length:2]];
    for (int i = 0; i < uids.count; i ++)
        [data appendData:[[uids objectAtIndex:i] dataUsingEncoding:NSUTF8StringEncoding]];

#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
            completedBlock(YES, NO, 0, responseObject);
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    //发送加入精选命令
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        }
        else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                }
                else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }]) {
        return NO;
    }
#endif
    return YES;
}

//获取我当前的竞价提示
+ (BOOL)getBidActiveTips:(NetworkCompletedBlock _Nonnull)completedBlock
{
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/getBidActiveTips?tokenid=%@", [BiChatGlobal sharedManager].apiUrl, [BiChatGlobal sharedManager].token];
    
    //GO!
    //NSLog(@"%@", str4Url);
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr GET:str4Url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"code"] != nil &&
            [[responseObject objectForKey:@"code"]integerValue] == 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *ret = responseObject;
            responseObject = [dec mutableObjectWithData:[ret mj_JSONData]];
            completedBlock(YES, NO, 0, responseObject);
        }
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
    
    return YES;
}
//设置短链接
+ (BOOL)setShortUrlWithType:(NSString *)type customId:(NSString *)customId chatId:(NSString *)chatId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock {
    //准备数据
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:type forKey:@"type"];
    [dic setObject:customId forKey:@"id"];
    [dic setObject:[chatId lowercaseString] forKey:@"chatId"];
    NSData *data4Message = [[dic mj_JSONString]dataUsingEncoding:NSUTF8StringEncoding];
    
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = (int)data4Message.length;
    HTONL(bodySize);
    short CommandType = 162;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4Message];
    
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
            completedBlock(YES, NO, 0, responseObject);
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"errorCode"]integerValue], responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        }
        else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                }
                else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }]) {
        return NO;
    }
#endif
    return YES;
}
+ (BOOL)getShortUrlWithType:(NSString *_Nonnull)type chatId:(NSString *_Nonnull)chatId completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock {
    //准备数据
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:type forKey:@"type"];
    [dic setObject:chatId forKey:@"chatId"];
    NSData *data4Message = [[dic mj_JSONString]dataUsingEncoding:NSUTF8StringEncoding];
    
    short headerSize = 8;
    HTONS(headerSize);
    int bodySize = (int)data4Message.length;
    HTONL(bodySize);
    short CommandType = 163;
    HTONS(CommandType);
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[[NSData alloc]initWithBytes:&headerSize length:2]];
    [data appendData:[[NSData alloc]initWithBytes:&bodySize length:4]];
    [data appendData:[[NSData alloc]initWithBytes:&CommandType length:2]];
    [data appendData:data4Message];
    
    
#ifdef USE_WEBAPI
    NSString *str4Url = [NSString stringWithFormat:@"%@Chat/Api/callWebAPI.do", [BiChatGlobal sharedManager].apiUrl];
    
    //GO!
    str4Url = [str4Url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self saveWebApiAccess:str4Url];
    AFHTTPSessionManager *httmMgr = [AFHTTPSessionManager new];
    [httmMgr POST:str4Url parameters:@{@"tokenid":[BiChatGlobal sharedManager].token==nil?@"":[BiChatGlobal sharedManager].token, @"body":[data base64EncodedStringWithOptions:0]} progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject objectForKey:@"errorCode"] != nil &&
            [[responseObject objectForKey:@"errorCode"]integerValue] == 0)
            completedBlock(YES, NO, 0, responseObject);
        else
            completedBlock(NO, NO, [[responseObject objectForKey:@"code"]integerValue], responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completedBlock(NO, NO, 0, nil);
    }];
#else
    if (![PokerStreamClient sendRequest:[BiChatGlobal sharedManager].token binary:data completed:^(NSData * _Nullable data, Boolean isTimeOut) {
        if (isTimeOut) {
            completedBlock(NO, YES, 0, nil);
        }
        else {
            JSONDecoder *dec = [JSONDecoder new];
            id obj = [dec mutableObjectWithData:data];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                if ([obj objectForKey:@"errorCode"] != nil &&
                    [[obj objectForKey:@"errorCode"]integerValue] == 0) {
                    completedBlock(YES, NO, 0, obj);
                }
                else {
                    completedBlock(NO, NO, [[obj objectForKey:@"errorCode"]integerValue], nil);
                }
            }
        }
    }]) {
        return NO;
    }
#endif
    return YES;
}



@end
