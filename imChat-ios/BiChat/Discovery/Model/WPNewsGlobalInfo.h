//
//  WPNewsGlobalInfo.h
//  BiChat
//
//  Created by 张迅 on 2018/5/22.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WPNewsGlobalInfo : NSObject

+ (instancetype)globalInfo;

- (void)addReadId:(NSString *)readId;

@property (nonatomic,strong)NSMutableArray *readList;

@end
