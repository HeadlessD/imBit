//
//  TransferMoneyCell.m
//  BiChat
//
//  Created by worm_kc on 2018/4/25.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "TransferMoneyCell.h"
#import "JSONKit.h"

@implementation TransferMoneyCell

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
            peerNickName:(NSString *)peerNickName
{
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *TransferMoneyInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    
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
        
        UIImageView *image4RedPacketFrame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"transfermoneyframeMine"]];
        if ([[BiChatGlobal sharedManager]isTransferMoneyFinished:[TransferMoneyInfo objectForKey:@"transactionId"]])
            image4RedPacketFrame.image = [UIImage imageNamed:@"transfermoneyframeMine_light"];
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
        
        //币种图标
        UIImageView *image4CoinIcon = [[UIImageView alloc]initWithFrame:CGRectMake(cellWidth - 277, 14, 40, 40)];
        [image4CoinIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, [TransferMoneyInfo objectForKey:@"coinIconWhiteUrl"]]]];
        [contentView addSubview:image4CoinIcon];
        
        //数量
        NSString *str = [BiChatGlobal decimalNumberWithDouble:[[TransferMoneyInfo objectForKey:@"count"]doubleValue]];
        CGRect rect = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:20]}
                                        context:nil];
        UILabel *label4Count = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 227, 15, rect.size.width, 20)];
        label4Count.text = str;
        label4Count.font = [UIFont systemFontOfSize:20];
        label4Count.textColor = [UIColor whiteColor];
        [contentView addSubview:label4Count];
        
        //币种名称
        UILabel *label4CoinName = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 227 + rect.size.width + 5, 21, 100, 12)];
        label4CoinName.text = [TransferMoneyInfo objectForKey:@"coinName"];
        label4CoinName.font = [UIFont systemFontOfSize:12];
        label4CoinName.textColor = [UIColor whiteColor];
        [contentView addSubview:label4CoinName];
        
        //留言
        UILabel *label4Memo = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 227, 40, 150, 15)];
        label4Memo.text = [TransferMoneyInfo objectForKey:@"memo"];
        if (label4Memo.text.length == 0)
            label4Memo.text = LLSTR(@"101617");
        label4Memo.font = [UIFont systemFontOfSize:12];
        label4Memo.textColor = [UIColor whiteColor];
        [contentView addSubview:label4Memo];
        
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 277, 68, 200, 14)];
        label4Title.text = LLSTR(@"201017");
        if ([[BiChatGlobal sharedManager]isTransferMoneyFinished:[TransferMoneyInfo objectForKey:@"transactionId"]] == 1)
            label4Title.text = LLSTR(@"101618");
        else if ([[BiChatGlobal sharedManager]isTransferMoneyFinished:[TransferMoneyInfo objectForKey:@"transactionId"]] == 2)
            label4Title.text = LLSTR(@"101619");
        else if ([[BiChatGlobal sharedManager]isTransferMoneyFinished:[TransferMoneyInfo objectForKey:@"transactionId"]] == 3)
            label4Title.text = LLSTR(@"101620");
        label4Title.font = [UIFont systemFontOfSize:12];
        label4Title.textColor = THEME_GRAY;
        [contentView addSubview:label4Title];
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
                
                UIImageView *image4RedPacketFrame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"transfermoneyframeSomeone"]];
                if ([[BiChatGlobal sharedManager]isTransferMoneyFinished:[TransferMoneyInfo objectForKey:@"transactionId"]])
                    image4RedPacketFrame.image = [UIImage imageNamed:@"transfermoneyframeSomeone_light"];
                image4RedPacketFrame.center = CGPointMake(213, 63);
                [contentView addSubview:image4RedPacketFrame];
                
                //币种图标
                UIImageView *image4CoinIcon = [[UIImageView alloc]initWithFrame:CGRectMake(114, 34, 40, 40)];
                [image4CoinIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, [TransferMoneyInfo objectForKey:@"coinIconWhiteUrl"]]]];
                [contentView addSubview:image4CoinIcon];
                
                //数量
                NSString *str = [BiChatGlobal decimalNumberWithDouble:[[TransferMoneyInfo objectForKey:@"count"]doubleValue]];
                CGRect rect = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:20]}
                                                context:nil];
                UILabel *label4Count = [[UILabel alloc]initWithFrame:CGRectMake(165, 35, rect.size.width, 20)];
                label4Count.text = str;
                label4Count.font = [UIFont systemFontOfSize:20];
                label4Count.textColor = [UIColor whiteColor];
                [contentView addSubview:label4Count];
                
                //币种名称
                UILabel *label4CoinName = [[UILabel alloc]initWithFrame:CGRectMake(165 + rect.size.width + 5, 41, 100, 12)];
                label4CoinName.text = [TransferMoneyInfo objectForKey:@"coinName"];
                label4CoinName.font = [UIFont systemFontOfSize:12];
                label4CoinName.textColor = [UIColor whiteColor];
                [contentView addSubview:label4CoinName];
                
                //留言
                UILabel *label4Memo = [[UILabel alloc]initWithFrame:CGRectMake(165, 60, 150, 15)];
                label4Memo.text = [TransferMoneyInfo objectForKey:@"memo"];
                if (label4Memo.text.length == 0)
                    label4Memo.text = LLSTR(@"101617");
                label4Memo.font = [UIFont systemFontOfSize:12];
                label4Memo.textColor = [UIColor whiteColor];
                [contentView addSubview:label4Memo];
                
                UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(114, 88, 200, 15)];
                label4Title.text = LLSTR(@"201017");
                if ([[BiChatGlobal sharedManager]isTransferMoneyFinished:[TransferMoneyInfo objectForKey:@"transactionId"]] == 1)
                    label4Title.text = LLSTR(@"101618");
                else if ([[BiChatGlobal sharedManager]isTransferMoneyFinished:[TransferMoneyInfo objectForKey:@"transactionId"]] == 2)
                    label4Title.text = LLSTR(@"101619");
                else if ([[BiChatGlobal sharedManager]isTransferMoneyFinished:[TransferMoneyInfo objectForKey:@"transactionId"]] == 3)
                    label4Title.text = LLSTR(@"101620");
                label4Title.font = [UIFont systemFontOfSize:12];
                label4Title.textColor = THEME_GRAY;
                [contentView addSubview:label4Title];
            }
            else
            {
                UIImageView *image4RedPacketFrame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"transfermoneyframeSomeone"]];
                if ([[BiChatGlobal sharedManager]isTransferMoneyFinished:[TransferMoneyInfo objectForKey:@"transactionId"]])
                    image4RedPacketFrame.image = [UIImage imageNamed:@"transfermoneyframeSomeone_light"];
                image4RedPacketFrame.center = CGPointMake(213, 43);
                [contentView addSubview:image4RedPacketFrame];
                
                //币种图标
                UIImageView *image4CoinIcon = [[UIImageView alloc]initWithFrame:CGRectMake(114, 14, 40, 40)];
                [image4CoinIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, [TransferMoneyInfo objectForKey:@"coinIconWhiteUrl"]]]];
                [contentView addSubview:image4CoinIcon];
                
                //数量
                NSString *str = [BiChatGlobal decimalNumberWithDouble:[[TransferMoneyInfo objectForKey:@"count"]doubleValue]];
                CGRect rect = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:20]}
                                                context:nil];
                UILabel *label4Count = [[UILabel alloc]initWithFrame:CGRectMake(165, 15, rect.size.width, 20)];
                label4Count.text = str;
                label4Count.font = [UIFont systemFontOfSize:20];
                label4Count.textColor = [UIColor whiteColor];
                [contentView addSubview:label4Count];
                
                //币种名称
                UILabel *label4CoinName = [[UILabel alloc]initWithFrame:CGRectMake(165 + rect.size.width + 5, 22, 100, 12)];
                label4CoinName.text = [TransferMoneyInfo objectForKey:@"coinName"];
                label4CoinName.font = [UIFont systemFontOfSize:11];
                label4CoinName.textColor = [UIColor whiteColor];
                [contentView addSubview:label4CoinName];
                
                //留言
                UILabel *label4Memo = [[UILabel alloc]initWithFrame:CGRectMake(165, 40, 150, 15)];
                label4Memo.text = [TransferMoneyInfo objectForKey:@"memo"];
                if (label4Memo.text.length == 0)
                    label4Memo.text = LLSTR(@"101617");
                label4Memo.font = [UIFont systemFontOfSize:12];
                label4Memo.textColor = [UIColor whiteColor];
                [contentView addSubview:label4Memo];
                
                UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(114, 68, 200, 15)];
                label4Title.text = LLSTR(@"201017");
                if ([[BiChatGlobal sharedManager]isTransferMoneyFinished:[TransferMoneyInfo objectForKey:@"transactionId"]] == 1)
                    label4Title.text = LLSTR(@"101618");
                else if ([[BiChatGlobal sharedManager]isTransferMoneyFinished:[TransferMoneyInfo objectForKey:@"transactionId"]] == 2)
                    label4Title.text = LLSTR(@"101619");
                else if ([[BiChatGlobal sharedManager]isTransferMoneyFinished:[TransferMoneyInfo objectForKey:@"transactionId"]] == 3)
                    label4Title.text = LLSTR(@"101620");
                label4Title.font = [UIFont systemFontOfSize:12];
                label4Title.textColor = THEME_GRAY;
                [contentView addSubview:label4Title];
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
                
                UIImageView *image4RedPacketFrame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"transfermoneyframeSomeone"]];
                if ([[BiChatGlobal sharedManager]isTransferMoneyFinished:[TransferMoneyInfo objectForKey:@"transactionId"]])
                    image4RedPacketFrame.image = [UIImage imageNamed:@"transfermoneyframeSomeone_light"];
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
                
                //币种图标
                UIImageView *image4CoinIcon = [[UIImageView alloc]initWithFrame:CGRectMake(74, 34, 40, 40)];
                [image4CoinIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, [TransferMoneyInfo objectForKey:@"coinIconWhiteUrl"]]]];
                [contentView addSubview:image4CoinIcon];
                
                //数量
                NSString *str = [BiChatGlobal decimalNumberWithDouble:[[TransferMoneyInfo objectForKey:@"count"]doubleValue]];
                CGRect rect = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:20]}
                                                context:nil];
                UILabel *label4Count = [[UILabel alloc]initWithFrame:CGRectMake(125, 35, rect.size.width, 20)];
                label4Count.text = str;
                label4Count.font = [UIFont systemFontOfSize:20];
                label4Count.textColor = [UIColor whiteColor];
                [contentView addSubview:label4Count];
                
                //币种名称
                UILabel *label4CoinName = [[UILabel alloc]initWithFrame:CGRectMake(125 + rect.size.width + 5, 41, 100, 12)];
                label4CoinName.text = [TransferMoneyInfo objectForKey:@"coinName"];
                label4CoinName.font = [UIFont systemFontOfSize:12];
                label4CoinName.textColor = [UIColor whiteColor];
                [contentView addSubview:label4CoinName];
                
                //留言
                UILabel *label4Memo = [[UILabel alloc]initWithFrame:CGRectMake(125, 60, 150, 15)];
                label4Memo.text = [TransferMoneyInfo objectForKey:@"memo"];
                if (label4Memo.text.length == 0)
                    label4Memo.text = LLSTR(@"101617");
                label4Memo.font = [UIFont systemFontOfSize:12];
                label4Memo.textColor = [UIColor whiteColor];
                [contentView addSubview:label4Memo];
                
                UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(74, 88, 200, 15)];
                label4Title.text = LLSTR(@"201017");
                if ([[BiChatGlobal sharedManager]isTransferMoneyFinished:[TransferMoneyInfo objectForKey:@"transactionId"]] == 1)
                    label4Title.text = LLSTR(@"101618");
                else if ([[BiChatGlobal sharedManager]isTransferMoneyFinished:[TransferMoneyInfo objectForKey:@"transactionId"]] == 2)
                    label4Title.text = LLSTR(@"101619");
                else if ([[BiChatGlobal sharedManager]isTransferMoneyFinished:[TransferMoneyInfo objectForKey:@"transactionId"]] == 3)
                    label4Title.text = LLSTR(@"101620");
                label4Title.font = [UIFont systemFontOfSize:12];
                label4Title.textColor = THEME_GRAY;
                [contentView addSubview:label4Title];
            }
            else
            {
                UIImageView *image4RedPacketFrame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"transfermoneyframeSomeone"]];
                if ([[BiChatGlobal sharedManager]isTransferMoneyFinished:[TransferMoneyInfo objectForKey:@"transactionId"]])
                    image4RedPacketFrame.image = [UIImage imageNamed:@"transfermoneyframeSomeone_light"];
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
                
                //币种图标
                UIImageView *image4CoinIcon = [[UIImageView alloc]initWithFrame:CGRectMake(74, 14, 40, 40)];
                [image4CoinIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, [TransferMoneyInfo objectForKey:@"coinIconWhiteUrl"]]]];
                [contentView addSubview:image4CoinIcon];
                
                //数量
                NSString *str = [BiChatGlobal decimalNumberWithDouble:[[TransferMoneyInfo objectForKey:@"count"]doubleValue]];
                CGRect rect = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:20]}
                                                context:nil];
                UILabel *label4Count = [[UILabel alloc]initWithFrame:CGRectMake(125, 15, rect.size.width, 20)];
                label4Count.text = str;
                label4Count.font = [UIFont systemFontOfSize:20];
                label4Count.textColor = [UIColor whiteColor];
                [contentView addSubview:label4Count];
                
                //币种名称
                UILabel *label4CoinName = [[UILabel alloc]initWithFrame:CGRectMake(125 + rect.size.width + 5, 22, 100, 12)];
                label4CoinName.text = [TransferMoneyInfo objectForKey:@"coinName"];
                label4CoinName.font = [UIFont systemFontOfSize:11];
                label4CoinName.textColor = [UIColor whiteColor];
                [contentView addSubview:label4CoinName];
                
                //留言
                UILabel *label4Memo = [[UILabel alloc]initWithFrame:CGRectMake(125, 40, 150, 15)];
                label4Memo.text = [TransferMoneyInfo objectForKey:@"memo"];
                if (label4Memo.text.length == 0)
                    label4Memo.text = LLSTR(@"101617");
                label4Memo.font = [UIFont systemFontOfSize:12];
                label4Memo.textColor = [UIColor whiteColor];
                [contentView addSubview:label4Memo];
                
                UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(74, 68, 200, 15)];
                label4Title.text = LLSTR(@"201017");
                if ([[BiChatGlobal sharedManager]isTransferMoneyFinished:[TransferMoneyInfo objectForKey:@"transactionId"]] == 1)
                    label4Title.text = LLSTR(@"101618");
                else if ([[BiChatGlobal sharedManager]isTransferMoneyFinished:[TransferMoneyInfo objectForKey:@"transactionId"]] == 2)
                    label4Title.text = LLSTR(@"101619");
                else if ([[BiChatGlobal sharedManager]isTransferMoneyFinished:[TransferMoneyInfo objectForKey:@"transactionId"]] == 3)
                    label4Title.text = LLSTR(@"101620");
                label4Title.font = [UIFont systemFontOfSize:12];
                label4Title.textColor = THEME_GRAY;
                [contentView addSubview:label4Title];
            }
        }
    }
}

@end
