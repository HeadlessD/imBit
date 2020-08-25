//
//  WPShareSheetItem.m
//  BiChat
//
//  Created by iMac on 2018/6/11.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPShareSheetItem.h"

@implementation WPShareSheetItem


+ (instancetype)itemWithTitle:(NSString *)title
                         icon:(NSString *)icon
                      handler:(void (^)(void))handler {
    WPShareSheetItem *item = [[WPShareSheetItem alloc] init];
    item.title = title;
    item.icon = icon;
    item.selectionHandler = handler;
    return item;
}
@end
