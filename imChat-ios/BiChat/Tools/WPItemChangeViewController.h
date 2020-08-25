//
//  WPItemChangeViewController.h
//  BiChat
//
//  Created by iMac on 2018/7/9.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPBaseViewController.h"

typedef enum {
    ChangeTypeLiveCreate = 0
}ChangeType;

@interface WPItemChangeViewController : WPBaseViewController
//需传递的用户ID/群ID
@property (nonatomic, strong) NSString *useId;
//标题
@property (nonatomic, strong) NSString *titleString;
//副标题
@property (nonatomic, strong) NSString *subtitle;
//内容
@property (nonatomic, strong) NSString *content;
//占位文字
@property (nonatomic, strong) NSString *placeHolder;
//最大长度
@property (nonatomic, assign) NSInteger maxLength;
//是否允许空
@property (nonatomic, assign) BOOL allowEmpty;
//类型0
@property (nonatomic, assign) NSInteger changeType;

@property (nonatomic,strong)NSDictionary *groupProperty;

@property (nonatomic,copy)void (^FinishBlock)(BOOL result);
@end
