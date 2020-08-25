//
//  WPRSAEncrypt.h
//  BiChat
//
//  Created by iMac on 2019/3/5.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <openssl/rsa.h>

NS_ASSUME_NONNULL_BEGIN

@interface WPRSAEncrypt : NSObject

+ (void)keyWith:(void(^)(NSString *pubKey, NSString *priKey))block;

/**
 *  加密方法
 *
 *  @param str    需要加密的字符串
 *  @param pubKey 公钥字符串
 */
+ (NSString *)encryptString:(NSString *)str publicKey:(NSString *)pubKey;

+ (SecKeyRef)addPublicKey:(NSString *)key;

/**
 验签

 @param content 原始文本
 @param signature 签名后的文本
 @param publicKey 公钥
 @return 结果
 */
+ (BOOL)verify:(NSString *)content signature:(NSString *)signature withPublivKey:(NSString *)publicKey;

/**
 *  解密方法
 *
 *  @param str     需要解密的字符串
 *  @param privKey 私钥字符串
 */
+ (NSString *)decryptString:(NSString *)str privateKey:(NSString *)privKey;

+ (SecKeyRef)addPrivateKey:(NSString *)key;

/**
 签名

 @param content 需要签名的字符串
 @param priKey 私钥字符串
 @return 签名后的字符串
 */
+ (NSString *)sign:(NSString *)content withPriKey:(NSString *)priKey;

RSA* createRSA(unsigned char* key);

EVP_PKEY*createEVP(unsigned char* key);

unsigned char* public_encrypt(unsigned char* data, int data_len, unsigned char* key, unsigned char* encrypted);

int private_decrypt(unsigned char* enc_data, int data_len, unsigned char* key, unsigned char* decrypted);

@end

NS_ASSUME_NONNULL_END
