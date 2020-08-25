//
//  DFLanguageManager.m
//  BiChat Dev
//
//  Created by chat on 2018/12/12.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "DFLanguageManager.h"
#import <AFNetworking/AFHTTPSessionManager.h>

@implementation DFLanguageManager

static NSBundle *bundle = nil;

+ (NSBundle *)bundle {
    return bundle;
}

//首次加载时检测语言是否存在
+ (NSString *)getLanguageName{
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    NSString *currLanguage = [def valueForKey:DFAPPLANGUAGE];
   
    if (!currLanguage || (currLanguage && currLanguage.length != 5)) {//本地没有的话 取系统的语言
        NSArray *preferredLanguages = [NSLocale preferredLanguages];
        currLanguage = preferredLanguages[0];
        if ([currLanguage hasPrefix:@"en"]) {
            currLanguage = @"en-US";
        }else if ([currLanguage hasPrefix:@"zh-Hans"]) {
            currLanguage = @"zh-CN";
        }else if ([currLanguage hasPrefix:@"zh-HK"] || [currLanguage hasPrefix:@"zh-Hant"]) {
            currLanguage = @"zh-HK";
        }else {
            currLanguage = @"zh-CN";
        }
        
#ifdef ENV_CN
        currLanguage = @"zh-CN";
#endif

        [def setValue:currLanguage forKey:DFAPPLANGUAGE];
        [def synchronize];
    }
    return currLanguage;
}

+ (NSDictionary *)getLanguageList{

    NSData *data = [NSData dataWithContentsOfFile:[WPBaseManager fileName:@"lan-list.json" inDirectory:@"language"]];
    if (!data) {
        data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"lan-list" ofType:@"json"]];
    }
    NSDictionary * listDic = [NSDictionary dictionary];

    if (data) {
        listDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments  error:nil];
    }else{
        listDic = nil;
    }
    return listDic;
}

//设置语言
+ (void)setUserLanguage:(NSString *)language {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currLanguage = [userDefaults valueForKey:DFAPPLANGUAGE];
//    if ([currLanguage isEqualToString:language]) {
//        return;
//    }
    [userDefaults setValue:language forKey:DFAPPLANGUAGE];
    [userDefaults synchronize];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:language forKey:@"lang"];
    [NetworkModule setMyPrivacyProfile:dict completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id data) {
        if (success) {
            [[BiChatGlobal sharedManager].dict4MyPrivacyProfile setObject:language forKey:@"lang"];
        }
    }];
    
    [DFLanguageManager getNewDataWIthVersion];//获取资源文件
}

+ (void)getNewDataWIthVersion{
    NSString * userLanguage = [DFLanguageManager getLanguageName];

    if (![BiChatGlobal sharedManager].llstrData) {
        [BiChatGlobal sharedManager].llstrData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:userLanguage ofType:@"json"]];
    }else{
        
        NSData * newData = [NSData dataWithContentsOfFile:[WPBaseManager fileName:[NSString stringWithFormat:@"%@.json",userLanguage] inDirectory:@"language"]];
        NSData * oldData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:userLanguage ofType:@"json"]];
        
        if (!newData) {
            NSLog(@"没有新的");
            [BiChatGlobal sharedManager].llstrData = oldData;
        }else{
            NSDictionary * newDic  = [NSJSONSerialization JSONObjectWithData:newData options:NSJSONReadingAllowFragments  error:nil];
            NSDictionary * oldDic  = [NSJSONSerialization JSONObjectWithData:oldData options:NSJSONReadingAllowFragments  error:nil];
            
            NSString * newV = [newDic objectForKey:@"Version"];
            NSInteger newInt = [newV integerValue];
            NSString * oldV = [oldDic objectForKey:@"Version"];
            NSInteger oldInt = [oldV integerValue];
            if (newInt > oldInt) {
                NSLog(@"old-%ld  new-%ld",(long)oldInt,newInt);
                [BiChatGlobal sharedManager].llstrData = newData;
            }else if (newInt <= oldInt){
                NSLog(@"old-%ld  new-%ld",(long)oldInt,newInt);
                [BiChatGlobal sharedManager].llstrData = oldData;
            }
        }
    }
    [BiChatGlobal sharedManager].llstrDic = [NSJSONSerialization JSONObjectWithData:[BiChatGlobal sharedManager].llstrData options:NSJSONReadingAllowFragments  error:nil];
}

+ (NSString *)getStrWithStr:(NSString *)str{
    if (![BiChatGlobal sharedManager].llstrData) {
        [DFLanguageManager getNewDataWIthVersion];
    }
    if ([BiChatGlobal sharedManager].llstrDic) {
        NSString * languageStr = [[BiChatGlobal sharedManager].llstrDic objectForKey:str];
        if (languageStr.length > 0) {
            return languageStr;
        }else{
            return str;
        }
    }else{
        return str;
    }
}

+ (NSString *)getStrWithId:(NSInteger)languageId{
    if (![BiChatGlobal sharedManager].llstrData) {
        [DFLanguageManager getNewDataWIthVersion];
    }
    if ([BiChatGlobal sharedManager].llstrDic) {
        NSString * languageStr = [[BiChatGlobal sharedManager].llstrDic objectForKey:[NSString stringWithFormat:@"%ld",languageId]];
        if (languageStr.length > 0) {
            return languageStr;
        }else{
            return [NSString stringWithFormat:@"%ld",languageId];
        }
    }else{
        return [NSString stringWithFormat:@"%ld",languageId];
    }
}

//获取当前语言版本号
+ (NSString *)getLanguageVersion{
    if (![BiChatGlobal sharedManager].llstrData) {
        [DFLanguageManager getNewDataWIthVersion];
    }

    if ([BiChatGlobal sharedManager].llstrDic) {
        NSString * languageStr = [[BiChatGlobal sharedManager].llstrDic objectForKey:@"Version"];
        if (languageStr.length > 0) {
            return languageStr;
        }else{
            return @"0";
        }
    }else{
        return @"0";
    }
}

//下载最新全量语言包
+(void)downloadLanStrWith:(NSString *)language SuccessBlock:(void(^)(NSDictionary * respone , NSInteger updateNum))successBlock failBlock:(void(^)(NSError * error))failBlock{
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.validatesDomainName = NO;
    securityPolicy.allowInvalidCertificates = YES;
    AFHTTPSessionManager * manage = [AFHTTPSessionManager manager];
    manage.securityPolicy = securityPolicy;
    manage.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString * lanpath  = @"";
    if ([BiChatGlobal sharedManager].langPath) {
        lanpath = [BiChatGlobal sharedManager].langPath;
    }else{
        lanpath = @"http://sys.dev.iweipeng.com/language/";
    }
    NSLog(@"**********************************%@",[NSString stringWithFormat:@"%@%@_%@.json",lanpath,language,DIFAPPID]);

    [manage GET:[NSString stringWithFormat:@"%@%@_%@.json?t=%@",lanpath,language,DIFAPPID,[DFLogicTool getNowTimeTimestamp]]  parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            NSDictionary * lanDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                    NSLog(@"**********************************全量更新语言包成功");
            //下载的语言包写入文件
            NSString *path = [WPBaseManager fileName:[NSString stringWithFormat:@"%@.json",language] inDirectory:@"language"];
            [responseObject writeToFile:path atomically:YES];

            successBlock(lanDic,1);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failBlock(error);
            //    NSLog(@"%@",error);
    }];
}

//下载最新语言列表
+(void)downloadLanListSuccessBlock:(void(^)(NSDictionary * respone))successBlock failBlock:(void(^)(NSError * error))failBlock{
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.validatesDomainName = NO;
    securityPolicy.allowInvalidCertificates = YES;
    AFHTTPSessionManager * manage = [AFHTTPSessionManager manager];
    manage.securityPolicy = securityPolicy;
    manage.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString * lanpath  = @"";
    if ([BiChatGlobal sharedManager].langPath) {
        lanpath = [BiChatGlobal sharedManager].langPath;
    }else{
        lanpath = @"http://sys.dev.iweipeng.com/language/";
    }
    
    [manage GET:[NSString stringWithFormat:@"%@lan-list.json?t=%@",lanpath,[DFLogicTool getNowTimeTimestamp]] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            NSDictionary * listDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            //下载的语言列表写入文件
//            NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
//            NSString * realPath =[resourcePath stringByAppendingPathComponent:@"lan-list.json"];
//            [responseObject writeToFile:realPath atomically:YES];
            
            NSString *path = [WPBaseManager fileName:@"lan-list.json" inDirectory:@"language"];
            [responseObject writeToFile:path atomically:YES];
            
            successBlock(listDic);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failBlock(error);
    }];
}

+(void)getLanguageUpdateEveryDay{
    
    NSDate *now = [NSDate date];
    NSDate *agoDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"nowDate"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *ageDateString = [dateFormatter stringFromDate:agoDate];
    NSString *nowDateString = [dateFormatter stringFromDate:now];

    if ([ageDateString isEqualToString:nowDateString]) {
            //    NSLog(@"今天已经更新过语言包");
    }else{
        [DFLanguageManager getLanguageUpdateEveryTimeSuccessBlock:^(NSDictionary * _Nonnull respone, NSInteger updateNum) {
            
        } failBlock:^(NSError * _Nonnull error) {
            
        }];
        //记录弹窗时间
        NSDate *nowDate = [NSDate date];
        NSUserDefaults *dataUser = [NSUserDefaults standardUserDefaults];
        [dataUser setObject:nowDate forKey:@"nowDate"];
        [dataUser synchronize];
    }
}

//查询语言包是否要升级
+(void)getLanguageUpdateEveryTimeSuccessBlock:(void(^)(NSDictionary * respone , NSInteger updateNum))successBlock failBlock:(void(^)(NSError * error))failBlock{
    [NetworkModule getLanguageJsonWithDic:@{
                                            @"lang":[DFLanguageManager getLanguageName],
                                            @"progId":DIFAPPID,
                                            @"versionNum":[DFLanguageManager getLanguageVersion]
                                            } completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        //updateType 0最新 1全量 3增量
        if (success) {
            if (data) {
                switch ([[data objectForKey:@"updateType"] intValue]) {
                    case 0:{
                                NSLog(@"语言包最新的不用更新");
                        [DFLanguageManager downloadLanStrWith:[DFLanguageManager getLanguageName] SuccessBlock:^(NSDictionary * _Nonnull respone, NSInteger updateNum) {
                            successBlock(respone,updateNum);
                        } failBlock:^(NSError * _Nonnull error) {
                            successBlock(nil,0);
                        }];
                    }
                        break;
                    case 1:{
                                NSLog(@"语言包全量更新");
                        [DFLanguageManager downloadLanStrWith:[DFLanguageManager getLanguageName] SuccessBlock:^(NSDictionary * _Nonnull respone, NSInteger updateNum) {
                            successBlock(respone,updateNum);
                        } failBlock:^(NSError * _Nonnull error) {
                            successBlock(nil,0);
                        }];
                    }
                        break;
                    case 2:{
                            //    NSLog(@"语言包增量更新");
                        successBlock(nil,0);
                    }
                        break;
                    default:
                        break;
                }
            }else{
                successBlock(nil,0);
            }
        }else{
                //    NSLog(@"no");
            successBlock(nil,0);
        }
    }];
}


+(NSString *)getkeyForValue:(NSString *)value dic:(NSDictionary *)dic{
    NSArray * keyArr = dic.allKeys;
    NSArray * valArr = dic.allValues;

    if (keyArr.count && valArr.count) {
        NSInteger index = [valArr indexOfObject:value];
        NSString * str = [keyArr objectAtIndex:index];
        return str;
    }else{
        return nil;
    }
}

//字段返回
//promptText="102223"  //返回为多语言代码
//authItemText=["102223"] //返回为多语言代码
//langs="{"{_mobile_}":{"type":1,value:"damon"}}"

//用于多语言的替换键值对,type=1 文本，type=2 多语言包

+(NSString *)getStrWithDic:(NSDictionary *)strDic llstr:(NSString *)llstr{
    
    NSString * oldStr = LLSTR(llstr);
    
    if (strDic) {
        NSArray * keyArr = strDic.allKeys;
        NSArray * valArr = strDic.allValues;
        
        for (int i = 0; i < valArr.count; i++) {

            NSDictionary * valDic = valArr[i];

            if ([[valDic objectForKey:@"type"] integerValue] == 1) {
                oldStr = [oldStr stringByReplacingOccurrencesOfString:keyArr[i] withString:[valDic objectForKey:@"value"]];
                
            }else if ([[valDic objectForKey:@"type"] integerValue] == 2){
                NSDictionary * lanListDic =  [DFLogicTool JsonStringToDictionary:[valDic objectForKey:@"value"]];

                NSString * keyStr =  [lanListDic objectForKey:[DFLanguageManager getLanguageName]];
                if (!keyStr) {
                    keyStr = [lanListDic objectForKey:@"Default"];
                }
                oldStr = [oldStr stringByReplacingOccurrencesOfString:keyArr[i] withString:keyStr];
            }
        }
    }
    return oldStr;
}

@end
