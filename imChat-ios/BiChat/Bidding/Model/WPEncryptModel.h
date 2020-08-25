//
//  WPEncryptModel.h
//  BiChat
//
//  Created by iMac on 2019/3/5.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WPEncryptModel : NSObject
//活动号
@property (nonatomic,strong)NSString *batchNo;
//本次加密ID,供下次提交密钥时需使用
@property (nonatomic,strong)NSString *encryptId;
////对参数：encryptData,volume,batchNo,encryptId,password按字段名字排序拼接后,用RSA 私钥进行签名
//@property (nonatomic,strong)NSString *sign;
//aes密钥
@property (nonatomic,strong)NSString *aesKey;
//rsa公钥
@property (nonatomic,strong)NSString *rsaPublicKey;
//rsa私钥
@property (nonatomic,strong)NSString *rsaPrivateKey;

@end

NS_ASSUME_NONNULL_END
