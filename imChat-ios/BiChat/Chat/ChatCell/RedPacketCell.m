//
//  RedPacketCell.m
//  BiChat
//
//  Created by worm_kc on 2018/4/25.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "RedPacketCell.h"
#import "JSONKit.h"

@implementation RedPacketCell

+ (CGFloat)getCellHeight:(NSDictionary *)message
                 peerUid:(NSString *)peerUid
                   width:(CGFloat)cellWidth
            showNickName:(BOOL)showNickName
{
    if (![[message objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid] && showNickName)
        return 116;
    else
        return 96;
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
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *redPacketInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    //NSLog(@"%@", redPacketInfo);
    //NSLog(@"status = %ld", [[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]]);
        
    //是我自己发的？
    NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:peerUid];
    if ([[message objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
    {
        //头像
        UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[BiChatGlobal sharedManager].uid
                                                nickName:[BiChatGlobal sharedManager].nickName
                                                  avatar:[BiChatGlobal sharedManager].avatar
                                                   frame:CGRectMake(cellWidth - 50, 0, 40, 40)];
        [self bundleView:view4Avatar
                WithUser:[message objectForKey:@"sender"]
                userName:[message objectForKey:@"senderUserName"]
                nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]
                  avatar:[message objectForKey:@"senderAvatar"]
                isPublic:[[message objectForKey:@"isPublic"]boolValue]
               tapTarget:tapUserAvatarTarget tapAction:tapUserAvatarAction
         longPressTarget:longPressUserAvatarTarget longPressAction:longPressUserAvatarAction];
        [contentView addSubview:view4Avatar];
        
        UIImageView *image4RedPacketFrame;
        image4RedPacketFrame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"redpacketframeMine"]];
        if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 1 ||
            [[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 2 ||
            [[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 3 ||
            [[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 5 ||
            [[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 6)
            image4RedPacketFrame.image = [UIImage imageNamed:@"redpacketframeMine_light"];
        image4RedPacketFrame.center = CGPointMake(cellWidth - 173, 43);
        [contentView addSubview:image4RedPacketFrame];
        
        if (!inMultiSelectMode)
        {
            //给图片增加长按手势
            image4RedPacketFrame.userInteractionEnabled = YES;
            UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
            objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(longPressGest, @"targetView", image4RedPacketFrame, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
            [image4RedPacketFrame addGestureRecognizer:longPressGest];
        }
        
        //给图片增加轻点手势
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:tapTarget action:tapAction];
        objc_setAssociatedObject(tapGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(tapGest, @"targetView", image4RedPacketFrame, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(tapGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
        [image4RedPacketFrame addGestureRecognizer:tapGest];
        
        //是否发送成功
        if ([[BiChatDataModule sharedDataModule]isMessageUnSent:[message objectForKey:@"msgId"]])
        {
            UIButton *button4Resend = [[UIButton alloc]initWithFrame:CGRectMake(cellWidth - 335, 23, 40, 40)];
            [button4Resend setImage:[UIImage imageNamed:@"failure"] forState:UIControlStateNormal];
            [button4Resend addTarget:resendTarget action:resendAction forControlEvents:UIControlEventTouchUpInside];
            objc_setAssociatedObject(button4Resend, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(button4Resend, @"targetView", contentView, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(button4Resend, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
            [contentView addSubview:button4Resend];
        }
        
        //币图标
        UIImageView *image4RedPacketIcon = [[UIImageView alloc]initWithFrame:CGRectMake(cellWidth - 277, 14, 30, 30)];
        [image4RedPacketIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, [redPacketInfo objectForKey:@"coinImageUrl"]]]];
        [contentView addSubview:image4RedPacketIcon];
        
        UILabel *label4CoinName = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 277, 44, 30, 15)];
        label4CoinName.text = [[BiChatGlobal sharedManager]getCoinDSymbolBySymbol:[redPacketInfo objectForKey:@"coinSymbol"]];
        label4CoinName.textAlignment = NSTextAlignmentCenter;
        label4CoinName.font = [UIFont systemFontOfSize:9];
        label4CoinName.textColor = [UIColor whiteColor];
        label4CoinName.adjustsFontSizeToFitWidth = YES;
        [contentView addSubview:label4CoinName];
        
        UILabel *label4BestWish = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 237, 14, 160, 19)];
        label4BestWish.text = [redPacketInfo objectForKey:@"greeting"];
        if (label4BestWish.text.length == 0) label4BestWish.text = LLSTR(@"101454");
        label4BestWish.font = [UIFont systemFontOfSize:16];
        label4BestWish.textColor = [UIColor whiteColor];
        [contentView addSubview:label4BestWish];
        
        UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 237, 40, 160, 12)];
        label4Hint.text = [self getRedPacketHint:redPacketInfo peerUid:peerUid];
        label4Hint.font = [UIFont systemFontOfSize:12];
        label4Hint.textColor = [UIColor whiteColor];
        [contentView addSubview:label4Hint];
        
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 280, 68, 200, 15)];
        label4Title.textColor = THEME_GRAY;
        label4Title.text = [self getRedPacketTitle:redPacketInfo peerUid:peerUid];
        label4Title.font = [UIFont systemFontOfSize:12];
        [contentView addSubview:label4Title];
        
        UIImageView *image4Flag = [self getRedPacketFlag:redPacketInfo];
        image4Flag.frame = CGRectMake(cellWidth - 79.5, 65, 20, 20);
        [contentView addSubview:image4Flag];
    }
    else
    {
        if (inMultiSelectMode)
        {
            //头像
            UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[message objectForKey:@"sender"]
                                                    nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]
                                                      avatar:[message objectForKey:@"senderAvatar"]
                                                       width:40 height:40];
            view4Avatar.center = CGPointMake(70, 20);
            [self bundleView:view4Avatar
                    WithUser:[message objectForKey:@"sender"]
                    userName:[message objectForKey:@"senderUserName"]
                    nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]
                      avatar:[message objectForKey:@"senderAvatar"]
                    isPublic:[[message objectForKey:@"isPublic"]boolValue]
                   tapTarget:tapUserAvatarTarget tapAction:tapUserAvatarAction
             longPressTarget:longPressUserAvatarTarget longPressAction:longPressUserAvatarAction];
            [contentView addSubview:view4Avatar];
            
            if (showNickName)
            {
                UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(100, 0, cellWidth - 150, 20)];
                label4NickName.text =  [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]];
                label4NickName.font = [UIFont systemFontOfSize:12];
                label4NickName.textColor = [UIColor grayColor];
                [contentView addSubview:label4NickName];
                
                UIImageView *image4RedPacketFrame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"redpacketframeSomeone"]];
                if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 1 ||
                    [[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 2 ||
                    [[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 3 ||
                    [[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 5 ||
                    [[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 6)
                    image4RedPacketFrame.image = [UIImage imageNamed:@"redpacketframeSomeone_light"];
                image4RedPacketFrame.center = CGPointMake(213, 63);
                [contentView addSubview:image4RedPacketFrame];
                
                //币图标
                UIImageView *image4RedPacketIcon = [[UIImageView alloc]initWithFrame:CGRectMake(114, 34, 30, 30)];
                [image4RedPacketIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, [redPacketInfo objectForKey:@"coinImageUrl"]]]];
                [contentView addSubview:image4RedPacketIcon];
                
                UILabel *label4CoinName = [[UILabel alloc]initWithFrame:CGRectMake(114, 64, 30, 15)];
                label4CoinName.text = [[BiChatGlobal sharedManager]getCoinDSymbolBySymbol:[redPacketInfo objectForKey:@"coinSymbol"]];
                label4CoinName.textAlignment = NSTextAlignmentCenter;
                label4CoinName.font = [UIFont systemFontOfSize:9];
                label4CoinName.textColor = [UIColor whiteColor];
                label4CoinName.adjustsFontSizeToFitWidth = YES;
                [contentView addSubview:label4CoinName];
                
                UILabel *label4BestWish = [[UILabel alloc]initWithFrame:CGRectMake(155, 34, 160, 19)];
                label4BestWish.text = [redPacketInfo objectForKey:@"greeting"];
                if (label4BestWish.text.length == 0) label4BestWish.text = LLSTR(@"101454");
                label4BestWish.font = [UIFont systemFontOfSize:16];
                label4BestWish.textColor = [UIColor whiteColor];
                [contentView addSubview:label4BestWish];
                
                UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(155, 60, 160, 12)];
                label4Hint.text = [self getRedPacketHint:redPacketInfo peerUid:peerUid];
                label4Hint.font = [UIFont systemFontOfSize:12];
                label4Hint.textColor = [UIColor whiteColor];
                [contentView addSubview:label4Hint];
                
                UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(109, 88, 200, 15)];
                label4Title.text = [self getRedPacketTitle:redPacketInfo peerUid:peerUid];
                label4Title.textColor = THEME_GRAY;
                label4Title.font = [UIFont systemFontOfSize:12];
                [contentView addSubview:label4Title];
                
                UIImageView *image4Flag = [self getRedPacketFlag:redPacketInfo];
                image4Flag.frame = CGRectMake(310, 85, 20, 20);
                [contentView addSubview:image4Flag];
            }
            else
            {
                UIImageView *image4RedPacketFrame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"redpacketframeSomeone"]];
                if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]])
                    image4RedPacketFrame.image = [UIImage imageNamed:@"redpacketframeSomeone_light"];
                image4RedPacketFrame.center = CGPointMake(213, 43);
                [contentView addSubview:image4RedPacketFrame];
                
                //币图标
                UIImageView *image4RedPacketIcon = [[UIImageView alloc]initWithFrame:CGRectMake(114, 14, 30, 30)];
                [image4RedPacketIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, [redPacketInfo objectForKey:@"coinImageUrl"]]]];
                [contentView addSubview:image4RedPacketIcon];
                
                UILabel *label4CoinName = [[UILabel alloc]initWithFrame:CGRectMake(114, 44, 30, 15)];
                label4CoinName.text = [[BiChatGlobal sharedManager]getCoinDSymbolBySymbol:[redPacketInfo objectForKey:@"coinSymbol"]];
                label4CoinName.textAlignment = NSTextAlignmentCenter;
                label4CoinName.font = [UIFont systemFontOfSize:9];
                label4CoinName.textColor = [UIColor whiteColor];
                label4CoinName.adjustsFontSizeToFitWidth = YES;
                [contentView addSubview:label4CoinName];
                
                UILabel *label4BestWish = [[UILabel alloc]initWithFrame:CGRectMake(155, 14, 160, 19)];
                label4BestWish.text = [redPacketInfo objectForKey:@"greeting"];
                if (label4BestWish.text.length == 0) label4BestWish.text = LLSTR(@"101454");
                label4BestWish.font = [UIFont systemFontOfSize:16];
                label4BestWish.textColor = [UIColor whiteColor];
                [contentView addSubview:label4BestWish];
                
                UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(155, 40, 160, 12)];
                label4Hint.text = [self getRedPacketHint:redPacketInfo peerUid:peerUid];
                label4Hint.font = [UIFont systemFontOfSize:12];
                label4Hint.textColor = [UIColor whiteColor];
                [contentView addSubview:label4Hint];
                
                UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(109, 68, 200, 15)];
                label4Title.text = [self getRedPacketTitle:redPacketInfo peerUid:peerUid];
                label4Title.textColor = [UIColor grayColor];
                label4Title.font = [UIFont systemFontOfSize:12];
                [contentView addSubview:label4Title];
            
                UIImageView *image4Flag = [self getRedPacketFlag:redPacketInfo];
                image4Flag.frame = CGRectMake(310, 65, 20, 20);
                [contentView addSubview:image4Flag];
            }
        }
        else
        {
            //头像
            UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[message objectForKey:@"sender"]
                                                    nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]
                                                      avatar:[message objectForKey:@"senderAvatar"]
                                                       width:40 height:40];
            view4Avatar.center = CGPointMake(30, 20);
            [self bundleView:view4Avatar
                    WithUser:[message objectForKey:@"sender"]
                    userName:[message objectForKey:@"senderUserName"]
                    nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]
                      avatar:[message objectForKey:@"senderAvatar"]
                    isPublic:[[message objectForKey:@"isPublic"]boolValue]
                   tapTarget:tapUserAvatarTarget tapAction:tapUserAvatarAction
             longPressTarget:longPressUserAvatarTarget longPressAction:longPressUserAvatarAction];
            [contentView addSubview:view4Avatar];
            
            if (showNickName)
            {
                UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, cellWidth - 150, 20)];
                label4NickName.text =  [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]];
                label4NickName.font = [UIFont systemFontOfSize:12];
                label4NickName.textColor = [UIColor grayColor];
                [contentView addSubview:label4NickName];
                
                UIImageView *image4RedPacketFrame;
                image4RedPacketFrame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"redpacketframeSomeone"]];
                if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 1 ||
                    [[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 2 ||
                    [[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 3 ||
                    [[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 5 ||
                    [[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 6)
                    image4RedPacketFrame.image = [UIImage imageNamed:@"redpacketframeSomeone_light"];
                image4RedPacketFrame.center = CGPointMake(173, 63);
                [contentView addSubview:image4RedPacketFrame];
                
                //给图片增加长按手势
                image4RedPacketFrame.userInteractionEnabled = YES;
                UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
                objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(longPressGest, @"targetView", image4RedPacketFrame, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [image4RedPacketFrame addGestureRecognizer:longPressGest];
                
                //给图片增加轻点手势
                UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:tapTarget action:tapAction];
                objc_setAssociatedObject(tapGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(tapGest, @"targetView", image4RedPacketFrame, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(tapGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [image4RedPacketFrame addGestureRecognizer:tapGest];
                
                //币图标
                UIImageView *image4RedPacketIcon = [[UIImageView alloc]initWithFrame:CGRectMake(74, 34, 30, 30)];
                [image4RedPacketIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, [redPacketInfo objectForKey:@"coinImageUrl"]]]];
                [contentView addSubview:image4RedPacketIcon];
                
                UILabel *label4CoinName = [[UILabel alloc]initWithFrame:CGRectMake(74, 64, 30, 15)];
                label4CoinName.text = [[BiChatGlobal sharedManager]getCoinDSymbolBySymbol:[redPacketInfo objectForKey:@"coinSymbol"]];
                label4CoinName.textAlignment = NSTextAlignmentCenter;
                label4CoinName.font = [UIFont systemFontOfSize:9];
                label4CoinName.textColor = [UIColor whiteColor];
                label4CoinName.adjustsFontSizeToFitWidth = YES;
                [contentView addSubview:label4CoinName];
                
                UILabel *label4BestWish = [[UILabel alloc]initWithFrame:CGRectMake(115, 34, 160, 19)];
                label4BestWish.text = [redPacketInfo objectForKey:@"greeting"];
                if (label4BestWish.text.length == 0) label4BestWish.text = LLSTR(@"101454");
                label4BestWish.font = [UIFont systemFontOfSize:16];
                label4BestWish.textColor = [UIColor whiteColor];
                [contentView addSubview:label4BestWish];
                
                UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(115, 60, 160, 12)];
                label4Hint.text = [self getRedPacketHint:redPacketInfo peerUid:peerUid];
                label4Hint.font = [UIFont systemFontOfSize:12];
                label4Hint.textColor = [UIColor whiteColor];
                [contentView addSubview:label4Hint];
                
                UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(69, 88, 200, 15)];
                label4Title.text = [self getRedPacketTitle:redPacketInfo peerUid:peerUid];
                label4Title.textColor = THEME_GRAY;
                label4Title.font = [UIFont systemFontOfSize:12];
                [contentView addSubview:label4Title];
                
                UIImageView *image4Flag = [self getRedPacketFlag:redPacketInfo];
                image4Flag.frame = CGRectMake(270, 85, 20, 20);
                [contentView addSubview:image4Flag];
            }
            else
            {
                UIImageView *image4RedPacketFrame;
                image4RedPacketFrame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"redpacketframeSomeone"]];
                if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 1 ||
                    [[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 2 ||
                    [[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 3 ||
                    [[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 5 ||
                    [[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 6)
                    image4RedPacketFrame.image = [UIImage imageNamed:@"redpacketframeSomeone_light"];
                image4RedPacketFrame.center = CGPointMake(173, 43);
                [contentView addSubview:image4RedPacketFrame];

                //给图片增加长按手势
                image4RedPacketFrame.userInteractionEnabled = YES;
                UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
                objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(longPressGest, @"targetView", image4RedPacketFrame, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [image4RedPacketFrame addGestureRecognizer:longPressGest];
                
                //给图片增加轻点手势
                UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:tapTarget action:tapAction];
                objc_setAssociatedObject(tapGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(tapGest, @"targetView", image4RedPacketFrame, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(tapGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [image4RedPacketFrame addGestureRecognizer:tapGest];
                
                //币图标
                UIImageView *image4RedPacketIcon = [[UIImageView alloc]initWithFrame:CGRectMake(74, 14, 30, 30)];
                [image4RedPacketIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, [redPacketInfo objectForKey:@"coinImageUrl"]]]];
                [contentView addSubview:image4RedPacketIcon];
                
                UILabel *label4CoinName = [[UILabel alloc]initWithFrame:CGRectMake(74, 44, 30, 15)];
                label4CoinName.text = [[BiChatGlobal sharedManager]getCoinDSymbolBySymbol:[redPacketInfo objectForKey:@"coinSymbol"]];
                label4CoinName.textAlignment = NSTextAlignmentCenter;
                label4CoinName.font = [UIFont systemFontOfSize:9];
                label4CoinName.textColor = [UIColor whiteColor];
                label4CoinName.adjustsFontSizeToFitWidth = YES;
                [contentView addSubview:label4CoinName];
                
                UILabel *label4BestWish = [[UILabel alloc]initWithFrame:CGRectMake(115, 14, 160, 19)];
                label4BestWish.text = [redPacketInfo objectForKey:@"greeting"];
                if (label4BestWish.text.length == 0) label4BestWish.text = LLSTR(@"101454");
                label4BestWish.font = [UIFont systemFontOfSize:16];
                label4BestWish.textColor = [UIColor whiteColor];
                [contentView addSubview:label4BestWish];
                
                UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake(115, 40, 160, 12)];
                label4Hint.text = [self getRedPacketHint:redPacketInfo peerUid:peerUid];
                label4Hint.font = [UIFont systemFontOfSize:12];
                label4Hint.textColor = [UIColor whiteColor];
                [contentView addSubview:label4Hint];
                
                UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(69, 68, 200, 15)];
                label4Title.text = [self getRedPacketTitle:redPacketInfo peerUid:peerUid];
                label4Title.textColor = THEME_GRAY;
                label4Title.font = [UIFont systemFontOfSize:12];
                [contentView addSubview:label4Title];
                
                UIImageView *image4Flag = [self getRedPacketFlag:redPacketInfo];
                image4Flag.frame = CGRectMake(270, 65, 20, 20);
                [contentView addSubview:image4Flag];
            }
        }
    }
}

+ (NSString *)getRedPacketTitle:(NSDictionary *)redPacketInfo peerUid:(NSString *)peerUid
{
    //是否专属红包
    if ([[redPacketInfo objectForKey:@"at"]length] > 0)
        return [LLSTR(@"101457") llReplaceWithArray:@[[redPacketInfo objectForKey:@"atName"]]];
    
    //其他类型红包
    if ([[redPacketInfo objectForKey:@"groupId"]isEqualToString:peerUid])
    {
        if ([[redPacketInfo objectForKey:@"rewardType"]integerValue] == 103 && [[redPacketInfo objectForKey:@"subType"]integerValue] == 0)
            return LLSTR(@"201013");
        else if ([[redPacketInfo objectForKey:@"rewardType"]integerValue] == 103 && [[redPacketInfo objectForKey:@"subType"]integerValue] == 1)
            return LLSTR(@"201013");
        else if ([[redPacketInfo objectForKey:@"rewardType"]integerValue] == 103 && [[redPacketInfo objectForKey:@"subType"]integerValue] == 2)
            return LLSTR(@"201013");
        else
            return LLSTR(@"201013");
    }
    else if ([[redPacketInfo objectForKey:@"sender"]isEqualToString:peerUid] &&
             ([[redPacketInfo objectForKey:@"rewardType"]integerValue] == 104 ||
              [[redPacketInfo objectForKey:@"rewardType"]integerValue] == 105 ||
              [[redPacketInfo objectForKey:@"rewardType"]integerValue] == 106))
    {
        if ([[redPacketInfo objectForKey:@"rewardType"]integerValue] == 106 && [[redPacketInfo objectForKey:@"subType"]integerValue] == 0)
            return LLSTR(@"201013");
        else if ([[redPacketInfo objectForKey:@"rewardType"]integerValue] == 106 && [[redPacketInfo objectForKey:@"subType"]integerValue] == 1)
            return LLSTR(@"201013");
        else if ([[redPacketInfo objectForKey:@"rewardType"]integerValue] == 106 && [[redPacketInfo objectForKey:@"subType"]integerValue] == 2)
            return LLSTR(@"201013");
        else
            return LLSTR(@"201013");
    }
    else if (![[redPacketInfo objectForKey:@"sender"]isEqualToString:peerUid] &&
             ([[redPacketInfo objectForKey:@"rewardType"]integerValue] == 104 ||
              [[redPacketInfo objectForKey:@"rewardType"]integerValue] == 105 ||
              [[redPacketInfo objectForKey:@"rewardType"]integerValue] == 106))
    {
        return [NSString stringWithFormat:@"「%@」", [redPacketInfo objectForKey:@"groupName"]];
    }
    else
    {
        if ([[redPacketInfo objectForKey:@"rewardType"]integerValue] == 103 )
            return [NSString stringWithFormat:@"「%@」", [redPacketInfo objectForKey:@"groupName"]];
        else
            return LLSTR(@"201013");
    }
}

+ (NSString *)getRedPacketHint:(NSDictionary *)redPacketInfo peerUid:(NSString *)peerUid
{
    NSString *coinDSymbol = [[BiChatGlobal sharedManager]getCoinDSymbolBySymbol:[redPacketInfo objectForKey:@"coinSymbol"]];
    
    //是点对点红包
    if ([[redPacketInfo objectForKey:@"rewardType"]integerValue] == 101)
    {
        if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 1)
        {
            if ([[redPacketInfo objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
                return [LLSTR(@"101428") llReplaceWithArray:@[coinDSymbol]];
            else
                return [LLSTR(@"101428") llReplaceWithArray:@[coinDSymbol]];
        }
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 2)
        {
            if ([[redPacketInfo objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
                return [LLSTR(@"101428") llReplaceWithArray:@[coinDSymbol]];
            else
                return [LLSTR(@"101428") llReplaceWithArray:@[coinDSymbol]];
        }
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 3)
            return [LLSTR(@"101429") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 5)
            return [LLSTR(@"101433") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 6)
            return [LLSTR(@"101437") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager].uid isEqualToString:[redPacketInfo objectForKey:@"sender"]])
            return [LLSTR(@"101439") llReplaceWithArray:@[coinDSymbol]];
        else
            return [LLSTR(@"101430") llReplaceWithArray:@[coinDSymbol]];
    }
    else if ([[redPacketInfo objectForKey:@"rewardType"]integerValue] == 103 && [[redPacketInfo objectForKey:@"subType"]integerValue] == 0)
    {
        if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 1)
            return [LLSTR(@"101428") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 2)
            return [LLSTR(@"101431") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 3)
            return [LLSTR(@"101429") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 4)
            return [LLSTR(@"101432") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 5)
            return [LLSTR(@"101433") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 6)
            return [LLSTR(@"101437") llReplaceWithArray:@[coinDSymbol]];
        else if ([[redPacketInfo objectForKey:@"groupId"]isEqualToString:peerUid] || [[redPacketInfo objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
            return [LLSTR(@"101434") llReplaceWithArray:@[coinDSymbol]];
        else
            return [LLSTR(@"101427") llReplaceWithArray:@[coinDSymbol]];
    }
    else if ([[redPacketInfo objectForKey:@"rewardType"]integerValue] == 103 && [[redPacketInfo objectForKey:@"subType"]integerValue] == 1)
    {
        if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 1)
            return [LLSTR(@"101428") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 2)
            return [LLSTR(@"101431") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 3)
            return [LLSTR(@"101429") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 4)
            return [LLSTR(@"101432") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 5)
            return [LLSTR(@"101433") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 6)
            return [LLSTR(@"101437") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 7)
            return [LLSTR(@"101436") llReplaceWithArray:@[coinDSymbol]];
        else if ([[redPacketInfo objectForKey:@"groupId"]isEqualToString:peerUid]||
                 [[redPacketInfo objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
            return [LLSTR(@"101436") llReplaceWithArray:@[coinDSymbol]];
        else
            return [LLSTR(@"101427") llReplaceWithArray:@[coinDSymbol]];
    }
    else if ([[redPacketInfo objectForKey:@"rewardType"]integerValue] == 103 && [[redPacketInfo objectForKey:@"subType"]integerValue] == 2)
    {
        if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 1)
            return [LLSTR(@"101428") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 2)
            return [LLSTR(@"101431") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 3)
            return [LLSTR(@"101429") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 4)
            return [LLSTR(@"101432") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 5)
            return [LLSTR(@"101433") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 6)
            return [LLSTR(@"101437") llReplaceWithArray:@[coinDSymbol]];
        else if ([[redPacketInfo objectForKey:@"groupId"]isEqualToString:peerUid])
            return [LLSTR(@"101439") llReplaceWithArray:@[coinDSymbol]];
        else
            return [LLSTR(@"101427") llReplaceWithArray:@[coinDSymbol]];
    }
    else if ([[redPacketInfo objectForKey:@"rewardType"]integerValue] == 105)
    {
        if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 1)
            return [LLSTR(@"101428") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 2)
            return [LLSTR(@"101431") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 3)
            return [LLSTR(@"101429") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 5)
            return [LLSTR(@"101433") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 6)
            return [LLSTR(@"101437") llReplaceWithArray:@[coinDSymbol]];
        else if ([[redPacketInfo objectForKey:@"sender"]isEqualToString:peerUid])
            return [LLSTR(@"101430") llReplaceWithArray:@[coinDSymbol]];
        else
            return [LLSTR(@"101427") llReplaceWithArray:@[coinDSymbol]];
    }
    else if ([[redPacketInfo objectForKey:@"rewardType"]integerValue] == 106 && [[redPacketInfo objectForKey:@"subType"]integerValue] == 0)
    {
        if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 1)
            return [LLSTR(@"101428") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 2)
            return [LLSTR(@"101431") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 3)
            return [LLSTR(@"101429") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 4)
            return [LLSTR(@"101432") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 5)
            return [LLSTR(@"101433") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 6)
            return [LLSTR(@"101437") llReplaceWithArray:@[coinDSymbol]];
        else if ([[redPacketInfo objectForKey:@"sender"]isEqualToString:peerUid])
            return [LLSTR(@"101434") llReplaceWithArray:@[coinDSymbol]];
        else
            return [LLSTR(@"101427") llReplaceWithArray:@[coinDSymbol]];
    }
    else if ([[redPacketInfo objectForKey:@"rewardType"]integerValue] == 106 && [[redPacketInfo objectForKey:@"subType"]integerValue] == 1)
    {
        if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 1)
            return [LLSTR(@"101428") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 2)
            return [LLSTR(@"101431") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 3)
            return [LLSTR(@"101429") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 4)
            return [LLSTR(@"101432") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 5)
            return [LLSTR(@"101433") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 6)
            return [LLSTR(@"101437") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 7)
            return [LLSTR(@"101436") llReplaceWithArray:@[coinDSymbol]];
        else if ([[redPacketInfo objectForKey:@"groupId"]isEqualToString:peerUid]||
                 [[redPacketInfo objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid]||
                 [[redPacketInfo objectForKey:@"sender"]isEqualToString:peerUid])
                    return [LLSTR(@"101436") llReplaceWithArray:@[coinDSymbol]];
        else
            return [LLSTR(@"101427") llReplaceWithArray:@[coinDSymbol]];
    }
    else if ([[redPacketInfo objectForKey:@"rewardType"]integerValue] == 106 && [[redPacketInfo objectForKey:@"subType"]integerValue] == 2)
    {
        if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 1)
            return [LLSTR(@"101428") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 2)
            return [LLSTR(@"101431") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 3)
            return [LLSTR(@"101429") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 4)
            return [LLSTR(@"101432") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 5)
            return [LLSTR(@"101433") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 6)
            return [LLSTR(@"101437") llReplaceWithArray:@[coinDSymbol]];
        else if ([[redPacketInfo objectForKey:@"sender"]isEqualToString:peerUid])
            return [LLSTR(@"101439") llReplaceWithArray:@[coinDSymbol]];
        else
            return [LLSTR(@"101427") llReplaceWithArray:@[coinDSymbol]];
    }
    else if ([[redPacketInfo objectForKey:@"rewardType"]integerValue] == 104)
    {
        if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 1)
            return [LLSTR(@"101428") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 2)
            return [LLSTR(@"101431") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 3)
            return [LLSTR(@"101429") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 5)
            return [LLSTR(@"101433") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 6)
            return [LLSTR(@"101437") llReplaceWithArray:@[coinDSymbol]];
        else if ([[redPacketInfo objectForKey:@"sender"]isEqualToString:peerUid])
            return [LLSTR(@"101430") llReplaceWithArray:@[coinDSymbol]];
        else
            return [LLSTR(@"101427") llReplaceWithArray:@[coinDSymbol]];
    }
    else
    {
        if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 1)
            return [LLSTR(@"101428") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 2)
            return [LLSTR(@"101431") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 3)
            return [LLSTR(@"101429") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 4)
            return [LLSTR(@"101432") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 5)
            return [LLSTR(@"101433") llReplaceWithArray:@[coinDSymbol]];
        else if ([[BiChatGlobal sharedManager]isRedPacketFinished:[redPacketInfo objectForKey:@"redPacketId"]] == 6)
            return [LLSTR(@"101437") llReplaceWithArray:@[coinDSymbol]];
        else
            return [LLSTR(@"101427") llReplaceWithArray:@[coinDSymbol]];
    }
}

+ (UIImageView *)getRedPacketFlag:(NSDictionary *)redPacketInfo
{
    return nil;
    
//    if (([[redPacketInfo objectForKey:@"rewardType"]integerValue] == 103 && [[redPacketInfo objectForKey:@"subType"]integerValue] == 1))
//    {
//        UIImageView *image4Ret = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
//        image4Ret.tintColor = THEME_COLOR;
//        image4Ret.image = [[UIImage imageNamed:@"flag_triangle"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//        return image4Ret;
//    }
//    else if (([[redPacketInfo objectForKey:@"rewardType"]integerValue] == 103 && [[redPacketInfo objectForKey:@"subType"]integerValue] == 0))
//    {
//        UIImageView *image4Ret = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
//        image4Ret.tintColor = THEME_GRAY;
//        image4Ret.image = [[UIImage imageNamed:@"flag_triangle"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//        return image4Ret;
//    }
//    if (([[redPacketInfo objectForKey:@"rewardType"]integerValue] == 106 && [[redPacketInfo objectForKey:@"subType"]integerValue] == 1))
//    {
//        UIImageView *image4Ret = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
//        image4Ret.tintColor = THEME_COLOR;
//        image4Ret.image = [[UIImage imageNamed:@"flag_triangle"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//        return image4Ret;
//    }
//    else if (([[redPacketInfo objectForKey:@"rewardType"]integerValue] == 106 && [[redPacketInfo objectForKey:@"subType"]integerValue] == 0))
//    {
//        UIImageView *image4Ret = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
//        image4Ret.tintColor = THEME_GRAY;
//        image4Ret.image = [[UIImage imageNamed:@"flag_triangle"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//        return image4Ret;
//    }
//    else
//        return nil;
}

@end
