//
//  DFLanguageManager.h
//  BiChat Dev
//
//  Created by chat on 2018/12/12.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DFLanguageManager : NSObject

+ (NSBundle *)bundle;//获取当前资源文件

+ (void)getNewDataWIthVersion;//获取当前资源文件

+ (NSString *)getLanguageName;   //获取当前语言名称

+ (NSDictionary *)getLanguageList;//获取语言列表

+ (NSString *)getLanguageVersion;//获取当前语言版本

+ (void)setUserLanguage:(NSString *)language;//设置当前语言

+ (NSString *)getStrWithStr:(NSString *)str;//获取本地化字符串

+ (NSString *)getStrWithId:(NSInteger)languageId;//获取本地化字符串(同 getStrWithStr:)

+(void)downloadLanStrWith:(NSString *)language SuccessBlock:(void(^)(NSDictionary * respone , NSInteger updateNum))successBlock failBlock:(void(^)(NSError * error))failBlock;

+(void)downloadLanListSuccessBlock:(void(^)(NSDictionary * respone))successBlock failBlock:(void(^)(NSError * error))failBlock;

+(void)getLanguageUpdateEveryDay;

+(void)getLanguageUpdateEveryTimeSuccessBlock:(void(^)(NSDictionary * respone , NSInteger updateNum))successBlock failBlock:(void(^)(NSError * error))failBlock;

+(NSString *)getkeyForValue:(NSString *)value dic:(NSDictionary *)dic;


+(NSString *)getStrWithDic:(NSDictionary *)strDic llstr:(NSString *)llstr;


@end

NS_ASSUME_NONNULL_END
