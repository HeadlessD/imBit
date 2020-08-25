//
//  WPEncryptionObject.m
//  BiChat
//
//  Created by iMac on 2019/2/15.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import "WPEncryptionObject.h"
//#import <openssl/rsa.h>
//#import <openssl/pem.h>

//#define kRSA_KEY_SIZE 1024

@implementation WPEncryptionObject


+ (NSString *)geAEStEncodId:(int)len {
    
    char ch[len];
    for (int index = 0; index < len; index++) {
        int num = arc4random_uniform(75)+48;
        if (num > 57 && num < 65) {
            num = num % 57 + 48;
        }
        else if (num > 90 && num < 97) {
            num = num % 90 + 65;
        }
        ch[index] = num;
    }
    return [[NSString alloc] initWithBytes:ch length:len encoding:NSUTF8StringEncoding];
}


+ (WPEncryptModel *)getEncryptModelByNo:(NSString *)No {
    YTKKeyValueStore *store = [[YTKKeyValueStore alloc] initDBWithName:@"bidding.db"];
    [store createTableWithName:[NSString stringWithFormat:@"a%@",[BiChatGlobal sharedManager].uid]];
    NSDictionary *dict = [store getObjectById:No fromTable:[NSString stringWithFormat:@"a%@",[BiChatGlobal sharedManager].uid]];
    WPEncryptModel *model = [WPEncryptModel mj_objectWithKeyValues:dict];
    return model;
}

+ (void)saveModel:(WPEncryptModel *)model {
    YTKKeyValueStore *store = [[YTKKeyValueStore alloc] initDBWithName:@"bidding.db"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:model.batchNo forKey:@"batchNo"];
    [dict setObject:model.encryptId forKey:@"encryptId"];
    [dict setObject:model.aesKey forKey:@"aesKey"];
    [dict setObject:model.rsaPublicKey forKey:@"rsaPublicKey"];
    [dict setObject:model.rsaPrivateKey forKey:@"rsaPrivateKey"];
    [store putObject:dict withId:model.batchNo intoTable:[NSString stringWithFormat:@"a%@",[BiChatGlobal sharedManager].uid]];
}

@end
