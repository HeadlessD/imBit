//
//  WPInviteView.h
//  BiChat Dev
//
//  Created by iMac on 2018/9/6.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WPInviteView : UIView

- (void)fillData:(NSDictionary *)dic;

@property (nonatomic,strong)UIImageView *headIV;
@property (nonatomic,strong)UIImageView *headTypeIV;
@property (nonatomic,strong)UILabel *nameLabel;
@property (nonatomic,strong)UILabel *inveteLabel;

@end
