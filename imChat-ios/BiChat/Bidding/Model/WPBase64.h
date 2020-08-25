//
//  WPBase64.h
//  BiChat
//
//  Created by iMac on 2019/3/5.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WPBase64 : NSObject
//Base64
+ (NSString *)base64StringFromText:(NSString *)text;
+ (NSString *)textFromBase64String:(NSString *)base64;
+ (NSString *)base64EncodedStringFrom:(NSData *)data;
@end

NS_ASSUME_NONNULL_END
