//
//  DFUserDefaultStorageService.m
//  coder
//
//  Created by 豆凯强 on 17/5/9.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#import "DFUserDefaultStorageService.h"

@implementation DFUserDefaultStorageService

- (instancetype)init
{
    self = [super init];
    if (self) {
        _ud = [NSUserDefaults standardUserDefaults];
    }
    return self;
}


-(void)sync
{
    [_ud synchronize];
}
@end
