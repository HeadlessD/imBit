//
//  NSString+Categroy.h
//  BiChat
//
//  Created by 张迅 on 2018/5/4.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Categroy)
/**
 匹配整数
 
 @return 是否为整数
 */
- (BOOL)isInt;
/**
 匹配 小写字母
 
 @return 是否为小写字母
 */
- (BOOL)isLetter;

/**
 匹配浮点数
 
 @return 是否为浮点数
 */
- (BOOL)isFloat;

/**
 判断字符串是否匹配正则

 @param regex 正则
 @return 是否匹配的结果
 */
- (BOOL) judgeWithRegex:(NSString *)regex;


/**
 捕获组

 @param regex 正则
 @return 捕获到的元素
 */
- (NSDictionary *)judGroupWithRegex:(NSString *)regex;


/**
 获取url中的参数

 @return 参数字典
 */
- (NSDictionary *)getUrlParams;

/**
 MD5加密
 
 @return MD5加密后的字符串
 */
- (NSString *)md5Encode;

/**
 根据规则返回对应精度的字符串
 @param formatterString 精度设置规则（保留几位小数）
 @param autoCheck 是否将小数点后多余的0去掉
 @return 计算好精度的字符串
 */
- (NSString *)accuracyCheckWithFormatterString:(NSString *)formatterString auotCheck:(BOOL)autoCheck;

/**
 丢精问题解决

 @return 未丢失精度的字符串
 */
- (NSString *)toPrise;

/**
根据精度返回需要的格式化字符串

 @param bit 精度
 @return 格式化字符串
 */
- (NSString *)getFormatterStringWithBit:(NSString *)bit;

/**
 根据时间戳返回时间
 @param timestamp 时间戳
 @return 时间字符串
 */
- (NSString *)getTimeWithTimestamp:(NSString *)timestamp;

//转换表情
- (NSMutableAttributedString *)transEmotionWithFont:(UIFont *)font;
//获取字符串长度（emoji、中文算2个，英文算一个）
- (NSInteger)getLength;

- (NSMutableAttributedString *)YYTransEmotionWithFont:(UIFont *)font;
- (NSMutableAttributedString *)DFTransEmotionWithFont:(UIFont *)font;

//+ (instancetype)stringWithFormatWithIM:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

- (NSString *) llReplaceWithArray:(NSArray *)array;

@end
