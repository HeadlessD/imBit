//
//  NSDictionary+Category.h
//  Vegetable365
//
//  Created by 张迅 on 15/11/24.
//  Copyright © 2015年 zhangxun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Category)

- (NSString *)stringObjectForkey:(NSString *)key;
- (NSArray *)arrayObjectForKey:(NSString *)key;
- (NSDictionary *)dictionaryObjectForkey:(NSString *)key;
- (NSString *)floatValueForKey:(NSString *)key;

@end
