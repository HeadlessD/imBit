//
//  WPNewsGlobalInfo.m
//  BiChat
//
//  Created by 张迅 on 2018/5/22.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPNewsGlobalInfo.h"
#import "WPBaseManager.h"

static WPNewsGlobalInfo *info = nil;
@implementation WPNewsGlobalInfo

+ (instancetype)globalInfo {
    if (!info) {
        info = [[WPNewsGlobalInfo alloc]init];
        [info loadReadList];
    }
    return info;
}

- (void)loadReadList {
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePath]];
    [self.readList addObjectsFromArray:array];
}

- (void)addReadId:(NSString *)readId {
    if (!self.readList) {
        self.readList = [NSMutableArray array];
    }
    [self.readList addObject:readId];
    [self saveReadList];
}

- (void)saveReadList {
    if ([NSKeyedArchiver archiveRootObject:self.readList toFile:[self filePath]]) {
        NSLog(@"saveSucceed");
    } else {
        NSLog(@"saveFailure");
    }
}

- (NSString *)filePath {
    NSString *path = [WPBaseManager fileName:@"discoverList_read.data" inDirectory:@"discover"];
    return path;
}

@end
