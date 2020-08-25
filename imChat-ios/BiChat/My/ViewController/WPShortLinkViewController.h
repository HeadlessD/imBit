//
//  WPShortLinkViewController.h
//  BiChat
//
//  Created by iMac on 2019/4/25.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import "WPBaseViewController.h"
#import "WPTextFieldView.h"

NS_ASSUME_NONNULL_BEGIN

@interface WPShortLinkViewController : WPBaseViewController
@property (nonatomic,strong)WPTextFieldView *input4MySign;

@property (nonatomic,strong)NSString *type;

@property (nonatomic,strong)NSString *groupId;

@property (nonatomic,strong)NSString *changeCount;
//当前短链接
@property (nonatomic,strong)NSString *shortLink;

@property (nonatomic,copy)void (^ChangeBlock)(void);
@end

NS_ASSUME_NONNULL_END
