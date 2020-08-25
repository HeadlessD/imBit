//
//  WPEncryptionObject.h
//  BiChat
//
//  Created by iMac on 2019/2/15.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <RNCryptor.h>
//#import <RNEncryptor.h>
//#import <RNDecryptor.h>
#import "WPAESEncrypt.h"
#import "WPRSAEncrypt.h"
#import "WPBase64.h"
#import "WPEncryptModel.h"




NS_ASSUME_NONNULL_BEGIN

@interface WPEncryptionObject : NSObject

+ (NSString *)geAEStEncodId:(int)len;

+ (WPEncryptModel *)getEncryptModelByNo:(NSString *)No;

+ (void)saveModel:(WPEncryptModel *)model;


@end

NS_ASSUME_NONNULL_END
