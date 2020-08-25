//
//  WPShareSheetItem.h
//  BiChat
//
//  Created by iMac on 2018/6/11.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface WPShareSheetItem : NSObject

@property (nonatomic, copy) NSString *icon;             /**< 图标名称 */
@property (nonatomic, copy) NSString *title;            /**< 标题 */
@property (nonatomic, copy) void (^selectionHandler)(void); /**< 点击后的事件处理 */

/**
 *  快速创建方法
 */
+ (instancetype)itemWithTitle:(NSString *)title
                         icon:(NSString *)icon
                      handler:(void (^)(void))handler;

@end
