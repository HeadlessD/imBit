//
//  WPBaseManager.m
//  BiChat
//
//  Created by 张迅 on 2018/4/9.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPBaseManager.h"

static WPBaseManager *manager;

@implementation WPBaseManager

+ (NSString *) baseURL {
    return [BiChatGlobal sharedManager].apiUrl;
}

+ (WPBaseManager *)baseManager {
    if (!manager) {
        manager = [[WPBaseManager alloc]initWithBaseURL:[NSURL URLWithString:[WPBaseManager baseURL]]];
//        manager.requestSerializer = [AFJSONRequestSerializer serializer];
//        manager.responseSerializer = [AFJSONResponseSerializer serializer];
//        manager.requestSerializer.timeoutInterval = 30;
    }
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@",[BiChatGlobal sharedManager].token] forHTTPHeaderField:@"tokenid"];
    return manager;
}

- (id)init {
    self = [super initWithBaseURL:[NSURL URLWithString:[WPBaseManager baseURL]]];
    if (!self) {
        return nil;
    }
//    self.requestSerializer = [AFJSONRequestSerializer serializer];
//    self.responseSerializer = [AFJSONResponseSerializer serializer];
//    self.requestSerializer.timeoutInterval = 30;
    return self;
}

- (void)getInterface:(NSString *)interface
          parameters:(id)parameters
             success:(void (^)(id))success
             failure:(void (^)(NSError *))failure {
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.validatesDomainName = NO;
    securityPolicy.allowInvalidCertificates = YES;
    self.securityPolicy = securityPolicy;
    
    [self POST:[NSString stringWithFormat:@"%@%@",[WPBaseManager baseURL],interface] parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            success(responseObject);
        }else {
            failure(nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
//
//    [self GET:[NSString stringWithFormat:@"%@%@",[WPBaseManager baseURL],interface] parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//        if (success) {
//            success(responseObject);
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        if (failure) {
//            failure(error);
//        }
//    }];
}

- (void)dfGetInterface:(NSString *)interface parameters:(id)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.validatesDomainName = NO;
    securityPolicy.allowInvalidCertificates = YES;
    
    AFHTTPSessionManager * manage = [AFHTTPSessionManager manager];
    manage.securityPolicy = securityPolicy;
    manage.responseSerializer = [AFHTTPResponseSerializer serializer];

//    self.securityPolicy = securityPolicy;
    
    [manage GET:interface parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            success(responseObject);
        }else {
            failure(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

- (void)postInterface:(NSString *)interface
           parameters:(id)parameters
              success:(void (^)(id))success
              failure:(void (^)(NSError *))failure {
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.validatesDomainName = NO;
    securityPolicy.allowInvalidCertificates = YES;
    self.securityPolicy = securityPolicy;
    
    [self POST:[NSString stringWithFormat:@"%@%@",[WPBaseManager baseURL],interface] parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}
//缓存
+ (NSString *)fileName:(NSString*)fileName inDirectory:(NSString *)directory {
    NSString *documentPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:directory];
    NSString *libaryDirectoryPath = [documentPath stringByAppendingPathComponent:fileName];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:documentPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:documentPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    return libaryDirectoryPath;
}

@end
