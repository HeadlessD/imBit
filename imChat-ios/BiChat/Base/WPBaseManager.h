//
//  WPBaseManager.h
//  BiChat
//
//  Created by 张迅 on 2018/4/9.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface WPBaseManager : AFHTTPSessionManager

+ (WPBaseManager *)baseManager;

- (void)getInterface:(NSString *)interface
          parameters:(id)parameters
             success:(void (^)(id response))success
             failure:(void (^)(NSError *error))failure;

- (void)postInterface:(NSString *)interface
           parameters:(id)parameters
              success:(void (^)(id response))success
              failure:(void (^)(NSError *error))failure;

+ (NSString *)fileName:(NSString*)fileName inDirectory:(NSString *)directory;




- (void)dfGetInterface:(NSString *)interface parameters:(id)parameters success:(void (^)(id response))success failure:(void (^)(NSError *))failure;

@end
