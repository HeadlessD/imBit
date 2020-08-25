//
//  WPPublicAccountMessageView.h
//  BiChat
//
//  Created by iMac on 2018/7/20.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPPublicAccountMessageModel.h"
@interface WPPublicAccountMessageView : UIView


@property (nonatomic,strong)UIView *lineV;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UILabel *timeLabel;
@property (nonatomic,strong)UIImageView *headIV;
@property (nonatomic,strong)NSString *url;
@property (nonatomic,strong)WPPublicAccountMessageModel *model;

- (void)addTarget:(id)target action:(SEL)selector;

@end
