//
//  WPAESEncrypt.h
//  BiChat
//
//  Created by iMac on 2019/3/5.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WPAESEncrypt : NSObject

+ (NSString *)encryptStringWithString:(NSString *)string andKey:(NSString *)key;
+ (NSString *)decryptStringWithString:(NSString *)string andKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
