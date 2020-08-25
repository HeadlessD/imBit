//
//  TimeCell.m
//  BiChat
//
//  Created by worm_kc on 2018/4/24.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "TimeCell.h"

@implementation TimeCell

+ (CGFloat)getCellHeight:(NSDictionary *)message
                 peerUid:(NSString *)peerUid
                   width:(CGFloat)cellWidth
            showNickName:(BOOL)showNickName
{
    return 30;
}

+ (void)renderCellInView:(UIView *)contentView
                 peerUid:(NSString *)peerUid
                 message:(NSMutableDictionary *)message
                   width:(CGFloat)cellWidth
            showNickName:(BOOL)showNickName
       inMultiSelectMode:(BOOL)inMultiSelectMode
               indexPath:(NSIndexPath *)indexPath
         longPressTarget:(id)longPressTarget
         longPressAction:(SEL)longPressAction
               tapTarget:(id)tapTarget
               tapAction:(SEL)tapAction
     tapUserAvatarTarget:(id)tapUserAvatarTarget
     tapUserAvatarAction:(SEL)tapUserAvatarAction
longPressUserAvatarTarget:(id)longPressUserAvatarTarget
longPressUserAvatarAction:(SEL)longPressUserAvatarAction
            remarkTarget:(id)remarkTarget
            remarkAction:(SEL)remarkAction
            resendTarget:(id)resendTarget
            resendAction:(SEL)resendAction
{
    NSString *str4Time = [BiChatGlobal adjustDateString:[message objectForKey:@"timeStamp"]];
    CGRect rect = [str4Time boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}
                                         context:nil];
    
    UILabel *label4Time = [[UILabel alloc]initWithFrame:CGRectMake((cellWidth - rect.size.width - 20) / 2, 0, rect.size.width + 20, 20)];
    label4Time.text = str4Time;
    label4Time.font = [UIFont systemFontOfSize:12];
    label4Time.textColor = [UIColor whiteColor];
    label4Time.backgroundColor = [UIColor colorWithWhite:.78 alpha:1];
    label4Time.textAlignment = NSTextAlignmentCenter;
    label4Time.layer.cornerRadius = 5;
    label4Time.clipsToBounds = YES;
    [contentView addSubview:label4Time];
}

@end
