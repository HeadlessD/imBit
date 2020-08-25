//
//  DFUserDefaultStorageService.h
//  coder
//
//  Created by 豆凯强 on 17/5/9.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFUserDefaultStorageService : NSObject

@property (nonatomic, strong) NSUserDefaults *ud;


-(void) sync;

@end
