//
//  ChatCell.m
//  BiChat
//
//  Created by worm_kc on 2018/4/24.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "ChatCell.h"

@implementation ChatCell

+ (CGFloat)getCellHeight:(NSDictionary *)message
                 peerUid:(NSString *)peerUid
                   width:(CGFloat)cellWidth
            showNickName:(BOOL)showNickName
{
    return 0;
}

+ (void)renderCellInView:(UIView *)contentView
                 peerUid:(NSString *)peerUid
                 message:(NSDictionary *)message
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
}

//绑定一个图片，让它可以相应单击事件显示用户信息
+ (void)bundleView:(UIView *)view
          WithUser:(NSString *)uid
          userName:(NSString *)userName
          nickName:(NSString *)nickName
            avatar:(NSString *)avatar
          isPublic:(BOOL)isPublic
         tapTarget:(id)tapTarget
         tapAction:(SEL)tapAction
   longPressTarget:(id)longPressTarget
   longPressAction:(SEL)longPressAction
{
    //给图片增加轻点手势
    if (tapTarget != nil && tapAction != nil)
    {
        view.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:tapTarget action:tapAction];
        objc_setAssociatedObject(tapGest, @"uid", uid, OBJC_ASSOCIATION_RETAIN);
        objc_setAssociatedObject(tapGest, @"username", userName, OBJC_ASSOCIATION_RETAIN);
        objc_setAssociatedObject(tapGest, @"nickname", nickName, OBJC_ASSOCIATION_RETAIN);
        objc_setAssociatedObject(tapGest, @"avatar", avatar, OBJC_ASSOCIATION_RETAIN);
        objc_setAssociatedObject(tapGest, @"isPublic", [NSNumber numberWithBool:isPublic], OBJC_ASSOCIATION_RETAIN);
        [view addGestureRecognizer:tapGest];
    }
    
    //给图片增加长按手势
    if (longPressTarget != nil && longPressAction != nil)
    {
        view.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
        objc_setAssociatedObject(longPressGest, @"uid", uid, OBJC_ASSOCIATION_RETAIN);
        objc_setAssociatedObject(longPressGest, @"username", userName, OBJC_ASSOCIATION_RETAIN);
        objc_setAssociatedObject(longPressGest, @"nickname", nickName, OBJC_ASSOCIATION_RETAIN);
        objc_setAssociatedObject(longPressGest, @"avatar", avatar, OBJC_ASSOCIATION_RETAIN);
        objc_setAssociatedObject(longPressGest, @"isPublic", [NSNumber numberWithBool:isPublic], OBJC_ASSOCIATION_RETAIN);
        [view addGestureRecognizer:longPressGest];
    }
}

@end
