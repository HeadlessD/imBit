//
//  ExchangeMoneyCell.m
//  BiChat
//
//  Created by worm_kc on 2018/4/25.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "ExchangeMoneyCell.h"
#import "JSONKit.h"

@implementation ExchangeMoneyCell

+ (CGFloat)getCellHeight:(NSDictionary *)message
                 peerUid:(NSString *)peerUid
                   width:(CGFloat)cellWidth
            showNickName:(BOOL)showNickName
{
    NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:peerUid];
    if ((groupProperty == nil && ([[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"enabledFeaturesIOS"]integerValue] & 4) == 0) ||
        (groupProperty != nil && ([[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"enabledFeaturesIOS"]integerValue] & 16) == 0))
    {
        NSString *strMessage = LLSTR(@"101672");
        CGRect rect = [strMessage boundingRectWithSize:CGSizeMake(cellWidth - 40, MAXFLOAT)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}
                                               context:nil];
        return rect.size.height + 17;
    }

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
    NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:peerUid];
    if ((groupProperty == nil && ([[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"enabledFeaturesIOS"]integerValue] & 4) == 0) ||
        (groupProperty != nil && ([[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"enabledFeaturesIOS"]integerValue] & 16) == 0))
    {
        NSString *strMessage = LLSTR(@"101672");
        CGRect rect = [strMessage boundingRectWithSize:CGSizeMake(cellWidth - 40, MAXFLOAT)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}
                                               context:nil];
        
        UILabel *label4Hint = [[UILabel alloc]initWithFrame:CGRectMake((cellWidth - rect.size.width - 20) / 2, 0, (int)rect.size.width + 20, (int)rect.size.height + 7)];
        label4Hint.text = strMessage;
        label4Hint.font = [UIFont systemFontOfSize:12];
        label4Hint.textColor = [UIColor grayColor];
        label4Hint.backgroundColor = [UIColor clearColor];
        label4Hint.textAlignment = NSTextAlignmentCenter;
        label4Hint.layer.cornerRadius = 5;
        label4Hint.layer.borderWidth = 0;
        label4Hint.layer.borderColor = [UIColor colorWithWhite:.78 alpha:1].CGColor;
        label4Hint.clipsToBounds = YES;
        label4Hint.numberOfLines = 0;
        [contentView addSubview:label4Hint];

        return;
    }
    
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *ExchangeMoneyInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    
    //是我自己发的？
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
        
        UIImageView *image4RedPacketFrame = [[UIImageView alloc]initWithFrame:CGRectMake(cellWidth - 173 - 117, 0, 234.5, 84)];
        image4RedPacketFrame.image = [UIImage imageNamed:@"exchangemoneyframeMine"];
        if ([[BiChatGlobal sharedManager]isExchangeMoneyFinished:[ExchangeMoneyInfo objectForKey:@"transactionId"]])
            image4RedPacketFrame.image = [UIImage imageNamed:@"exchangemoneyframeMine_light"];
        image4RedPacketFrame.center = CGPointMake(cellWidth - 173, 43);
        [contentView addSubview:image4RedPacketFrame];
        
        UIImageView *image4ExchangeFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"exchange_flag"]];
        image4ExchangeFlag.center = CGPointMake(110, 34);
        [image4RedPacketFrame addSubview:image4ExchangeFlag];
        
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
        [image4CoinIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, [ExchangeMoneyInfo objectForKey:@"coinIconWhiteUrl"]]]];
        [contentView addSubview:image4CoinIcon];
        
        //付出币种信息
        UILabel *label4CoinInfo = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 227, 11, 98, 20)];
        label4CoinInfo.text = [NSString stringWithFormat:@"%@ %@", [BiChatGlobal decimalNumberWithDouble:[[ExchangeMoneyInfo objectForKey:@"count"]doubleValue]], [ExchangeMoneyInfo objectForKey:@"coinName"]];
        label4CoinInfo.adjustsFontSizeToFitWidth = YES;
        label4CoinInfo.textAlignment = NSTextAlignmentCenter;
        label4CoinInfo.textColor = [UIColor whiteColor];
        [contentView addSubview:label4CoinInfo];
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:label4CoinInfo.text];
        [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, str.length)];
        [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(str.length - [[ExchangeMoneyInfo objectForKey:@"coinName"]length], [[ExchangeMoneyInfo objectForKey:@"coinName"]length])];
        label4CoinInfo.attributedText = str;
        
        //换入币种信息
        UILabel *label4ExchangeCoinInfo = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 227, 37, 98, 20)];
        label4ExchangeCoinInfo.text = [NSString stringWithFormat:@"%@ %@", [BiChatGlobal decimalNumberWithDouble:[[ExchangeMoneyInfo objectForKey:@"exchangeCount"]doubleValue]], [ExchangeMoneyInfo objectForKey:@"exchangeCoinName"]];
        label4ExchangeCoinInfo.adjustsFontSizeToFitWidth = YES;
        label4ExchangeCoinInfo.textAlignment = NSTextAlignmentCenter;
        label4ExchangeCoinInfo.textColor = [UIColor whiteColor];
        [contentView addSubview:label4ExchangeCoinInfo];
        
        str = [[NSMutableAttributedString alloc]initWithString:label4ExchangeCoinInfo.text];
        [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, str.length)];
        [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(str.length - [[ExchangeMoneyInfo objectForKey:@"exchangeCoinName"]length], [[ExchangeMoneyInfo objectForKey:@"exchangeCoinName"]length])];
        label4ExchangeCoinInfo.attributedText = str;
        
        //交换币种图标
        UIImageView *image4ExchangeCoinIcon = [[UIImageView alloc]initWithFrame:CGRectMake(cellWidth - 117, 14, 40, 40)];
        [image4ExchangeCoinIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, [ExchangeMoneyInfo objectForKey:@"exchangeCoinIconWhiteUrl"]]]];
        [contentView addSubview:image4ExchangeCoinIcon];

        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 277, 68, 200, 14)];
        label4Title.text = LLSTR(@"101669");
        if ([[BiChatGlobal sharedManager]isExchangeMoneyFinished:[ExchangeMoneyInfo objectForKey:@"transactionId"]] == 1)
            label4Title.text = LLSTR(@"101660");
        else if ([[BiChatGlobal sharedManager]isExchangeMoneyFinished:[ExchangeMoneyInfo objectForKey:@"transactionId"]] == 2)
            label4Title.text = LLSTR(@"101661");
        else if ([[BiChatGlobal sharedManager]isExchangeMoneyFinished:[ExchangeMoneyInfo objectForKey:@"transactionId"]] == 3)
            label4Title.text = LLSTR(@"101662");
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
                
                UIImageView *image4RedPacketFrame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"exchangemoneyframeSomeone"]];
                if ([[BiChatGlobal sharedManager]isExchangeMoneyFinished:[ExchangeMoneyInfo objectForKey:@"transactionId"]])
                    image4RedPacketFrame.image = [UIImage imageNamed:@"exchangemoneyframeSomeone_light"];
                image4RedPacketFrame.center = CGPointMake(213, 63);
                [contentView addSubview:image4RedPacketFrame];
                
                UIImageView *image4ExchangeFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"exchange_flag"]];
                image4ExchangeFlag.center = CGPointMake(114, 33);
                [image4RedPacketFrame addSubview:image4ExchangeFlag];
                
                //币种图标
                UIImageView *image4CoinIcon = [[UIImageView alloc]initWithFrame:CGRectMake(114, 34, 40, 40)];
                [image4CoinIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, [ExchangeMoneyInfo objectForKey:@"coinIconWhiteUrl"]]]];
                [contentView addSubview:image4CoinIcon];
                
                //付出币种信息
                UILabel *label4CoinInfo = [[UILabel alloc]initWithFrame:CGRectMake(165, 30, 98, 20)];
                label4CoinInfo.text = [NSString stringWithFormat:@"%@ %@", [BiChatGlobal decimalNumberWithDouble:[[ExchangeMoneyInfo objectForKey:@"count"]doubleValue]], [ExchangeMoneyInfo objectForKey:@"coinName"]];
                label4CoinInfo.adjustsFontSizeToFitWidth = YES;
                label4CoinInfo.textAlignment = NSTextAlignmentCenter;
                label4CoinInfo.textColor = [UIColor whiteColor];
                [contentView addSubview:label4CoinInfo];
                
                NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:label4CoinInfo.text];
                [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, str.length)];
                [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(str.length - [[ExchangeMoneyInfo objectForKey:@"coinName"]length], [[ExchangeMoneyInfo objectForKey:@"coinName"]length])];
                label4CoinInfo.attributedText = str;
                
                //换入币种信息
                UILabel *label4ExchangeCoinInfo = [[UILabel alloc]initWithFrame:CGRectMake(165, 57, 98, 20)];
                label4ExchangeCoinInfo.text = [NSString stringWithFormat:@"%@ %@", [BiChatGlobal decimalNumberWithDouble:[[ExchangeMoneyInfo objectForKey:@"exchangeCount"]doubleValue]], [ExchangeMoneyInfo objectForKey:@"exchangeCoinName"]];
                label4ExchangeCoinInfo.adjustsFontSizeToFitWidth = YES;
                label4ExchangeCoinInfo.textAlignment = NSTextAlignmentCenter;
                label4ExchangeCoinInfo.textColor = [UIColor whiteColor];
                [contentView addSubview:label4ExchangeCoinInfo];
                
                str = [[NSMutableAttributedString alloc]initWithString:label4ExchangeCoinInfo.text];
                [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, str.length)];
                [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(str.length - [[ExchangeMoneyInfo objectForKey:@"exchangeCoinName"]length], [[ExchangeMoneyInfo objectForKey:@"exchangeCoinName"]length])];
                label4ExchangeCoinInfo.attributedText = str;
                
                //交换币种图标
                UIImageView *image4ExchangeCoinIcon = [[UIImageView alloc]initWithFrame:CGRectMake(274, 34, 40, 40)];
                [image4ExchangeCoinIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, [ExchangeMoneyInfo objectForKey:@"exchangeCoinIconWhiteUrl"]]]];
                [contentView addSubview:image4ExchangeCoinIcon];

                UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(114, 88, 200, 15)];
                label4Title.text = LLSTR(@"101669");
                if ([[BiChatGlobal sharedManager]isExchangeMoneyFinished:[ExchangeMoneyInfo objectForKey:@"transactionId"]] == 1)
                    label4Title.text = LLSTR(@"101660");
                else if ([[BiChatGlobal sharedManager]isExchangeMoneyFinished:[ExchangeMoneyInfo objectForKey:@"transactionId"]] == 2)
                    label4Title.text = LLSTR(@"101661");
                else if ([[BiChatGlobal sharedManager]isExchangeMoneyFinished:[ExchangeMoneyInfo objectForKey:@"transactionId"]] == 3)
                    label4Title.text = LLSTR(@"101662");
                label4Title.font = [UIFont systemFontOfSize:12];
                label4Title.textColor = THEME_GRAY;
                [contentView addSubview:label4Title];
            }
            else
            {
                UIImageView *image4RedPacketFrame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"exchangemoneyframeSomeone"]];
                if ([[BiChatGlobal sharedManager]isExchangeMoneyFinished:[ExchangeMoneyInfo objectForKey:@"transactionId"]])
                    image4RedPacketFrame.image = [UIImage imageNamed:@"exchangemoneyframeSomeone_light"];
                image4RedPacketFrame.center = CGPointMake(213, 43);
                [contentView addSubview:image4RedPacketFrame];
                
                UIImageView *image4ExchangeFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"exchange_flag"]];
                image4ExchangeFlag.center = CGPointMake(114, 33);
                [image4RedPacketFrame addSubview:image4ExchangeFlag];

                //币种图标
                UIImageView *image4CoinIcon = [[UIImageView alloc]initWithFrame:CGRectMake(114, 14, 40, 40)];
                [image4CoinIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, [ExchangeMoneyInfo objectForKey:@"coinIconWhiteUrl"]]]];
                [contentView addSubview:image4CoinIcon];
                
                //付出币种信息
                UILabel *label4CoinInfo = [[UILabel alloc]initWithFrame:CGRectMake(165, 11, 98, 20)];
                label4CoinInfo.text = [NSString stringWithFormat:@"%@ %@", [BiChatGlobal decimalNumberWithDouble:[[ExchangeMoneyInfo objectForKey:@"count"]doubleValue]], [ExchangeMoneyInfo objectForKey:@"coinName"]];
                label4CoinInfo.adjustsFontSizeToFitWidth = YES;
                label4CoinInfo.textAlignment = NSTextAlignmentCenter;
                label4CoinInfo.textColor = [UIColor whiteColor];
                [contentView addSubview:label4CoinInfo];
                
                NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:label4CoinInfo.text];
                [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, str.length)];
                [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(str.length - [[ExchangeMoneyInfo objectForKey:@"coinName"]length], [[ExchangeMoneyInfo objectForKey:@"coinName"]length])];
                label4CoinInfo.attributedText = str;
                
                //换入币种信息
                UILabel *label4ExchangeCoinInfo = [[UILabel alloc]initWithFrame:CGRectMake(165, 37, 98, 20)];
                label4ExchangeCoinInfo.text = [NSString stringWithFormat:@"%@ %@", [BiChatGlobal decimalNumberWithDouble:[[ExchangeMoneyInfo objectForKey:@"exchangeCount"]doubleValue]], [ExchangeMoneyInfo objectForKey:@"exchangeCoinName"]];
                label4ExchangeCoinInfo.adjustsFontSizeToFitWidth = YES;
                label4ExchangeCoinInfo.textAlignment = NSTextAlignmentCenter;
                label4ExchangeCoinInfo.textColor = [UIColor whiteColor];
                [contentView addSubview:label4ExchangeCoinInfo];
                
                str = [[NSMutableAttributedString alloc]initWithString:label4ExchangeCoinInfo.text];
                [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, str.length)];
                [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(str.length - [[ExchangeMoneyInfo objectForKey:@"exchangeCoinName"]length], [[ExchangeMoneyInfo objectForKey:@"exchangeCoinName"]length])];
                label4ExchangeCoinInfo.attributedText = str;

                //交换币种图标
                UIImageView *image4ExchangeCoinIcon = [[UIImageView alloc]initWithFrame:CGRectMake(274, 14, 40, 40)];
                [image4ExchangeCoinIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, [ExchangeMoneyInfo objectForKey:@"exchangeCoinIconWhiteUrl"]]]];
                [contentView addSubview:image4ExchangeCoinIcon];

                UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(114, 68, 200, 15)];
                label4Title.text = LLSTR(@"101669");
                if ([[BiChatGlobal sharedManager]isExchangeMoneyFinished:[ExchangeMoneyInfo objectForKey:@"transactionId"]] == 1)
                    label4Title.text = LLSTR(@"101660");
                else if ([[BiChatGlobal sharedManager]isExchangeMoneyFinished:[ExchangeMoneyInfo objectForKey:@"transactionId"]] == 2)
                    label4Title.text = LLSTR(@"101661");
                else if ([[BiChatGlobal sharedManager]isExchangeMoneyFinished:[ExchangeMoneyInfo objectForKey:@"transactionId"]] == 3)
                    label4Title.text = LLSTR(@"101662");
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
                
                UIImageView *image4RedPacketFrame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"exchangemoneyframeSomeone"]];
                if ([[BiChatGlobal sharedManager]isExchangeMoneyFinished:[ExchangeMoneyInfo objectForKey:@"transactionId"]])
                    image4RedPacketFrame.image = [UIImage imageNamed:@"exchangemoneyframeSomeone_light"];
                image4RedPacketFrame.center = CGPointMake(173, 63);
                [contentView addSubview:image4RedPacketFrame];
                
                UIImageView *image4ExchangeFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"exchange_flag"]];
                image4ExchangeFlag.center = CGPointMake(114, 33);
                [image4RedPacketFrame addSubview:image4ExchangeFlag];

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
                [image4CoinIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, [ExchangeMoneyInfo objectForKey:@"coinIconWhiteUrl"]]]];
                [contentView addSubview:image4CoinIcon];
                
                //付出币种信息
                UILabel *label4CoinInfo = [[UILabel alloc]initWithFrame:CGRectMake(125, 30, 98, 20)];
                label4CoinInfo.text = [NSString stringWithFormat:@"%@ %@", [BiChatGlobal decimalNumberWithDouble:[[ExchangeMoneyInfo objectForKey:@"count"]doubleValue]], [ExchangeMoneyInfo objectForKey:@"coinName"]];
                label4CoinInfo.adjustsFontSizeToFitWidth = YES;
                label4CoinInfo.textAlignment = NSTextAlignmentCenter;
                label4CoinInfo.textColor = [UIColor whiteColor];
                [contentView addSubview:label4CoinInfo];
                
                NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:label4CoinInfo.text];
                [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, str.length)];
                [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(str.length - [[ExchangeMoneyInfo objectForKey:@"coinName"]length], [[ExchangeMoneyInfo objectForKey:@"coinName"]length])];
                label4CoinInfo.attributedText = str;
                
                //换入币种信息
                UILabel *label4ExchangeCoinInfo = [[UILabel alloc]initWithFrame:CGRectMake(125, 57, 98, 20)];
                label4ExchangeCoinInfo.text = [NSString stringWithFormat:@"%@ %@", [BiChatGlobal decimalNumberWithDouble:[[ExchangeMoneyInfo objectForKey:@"exchangeCount"]doubleValue]], [ExchangeMoneyInfo objectForKey:@"exchangeCoinName"]];
                label4ExchangeCoinInfo.adjustsFontSizeToFitWidth = YES;
                label4ExchangeCoinInfo.textAlignment = NSTextAlignmentCenter;
                label4ExchangeCoinInfo.textColor = [UIColor whiteColor];
                [contentView addSubview:label4ExchangeCoinInfo];
                
                str = [[NSMutableAttributedString alloc]initWithString:label4ExchangeCoinInfo.text];
                [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, str.length)];
                [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(str.length - [[ExchangeMoneyInfo objectForKey:@"exchangeCoinName"]length], [[ExchangeMoneyInfo objectForKey:@"exchangeCoinName"]length])];
                label4ExchangeCoinInfo.attributedText = str;
                
                //交换币种图标
                UIImageView *image4ExchangeCoinIcon = [[UIImageView alloc]initWithFrame:CGRectMake(234, 34, 40, 40)];
                [image4ExchangeCoinIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, [ExchangeMoneyInfo objectForKey:@"exchangeCoinIconWhiteUrl"]]]];
                [contentView addSubview:image4ExchangeCoinIcon];

                UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(74, 88, 200, 15)];
                label4Title.text = LLSTR(@"101669");
                if ([[BiChatGlobal sharedManager]isExchangeMoneyFinished:[ExchangeMoneyInfo objectForKey:@"transactionId"]] == 1)
                    label4Title.text = LLSTR(@"101660");
                else if ([[BiChatGlobal sharedManager]isExchangeMoneyFinished:[ExchangeMoneyInfo objectForKey:@"transactionId"]] == 2)
                    label4Title.text = LLSTR(@"101661");
                else if ([[BiChatGlobal sharedManager]isExchangeMoneyFinished:[ExchangeMoneyInfo objectForKey:@"transactionId"]] == 3)
                    label4Title.text = LLSTR(@"101662");
                label4Title.font = [UIFont systemFontOfSize:12];
                label4Title.textColor = THEME_GRAY;
                [contentView addSubview:label4Title];
            }
            else
            {
                UIImageView *image4RedPacketFrame = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"exchangemoneyframeSomeone"]];
                if ([[BiChatGlobal sharedManager]isExchangeMoneyFinished:[ExchangeMoneyInfo objectForKey:@"transactionId"]])
                    image4RedPacketFrame.image = [UIImage imageNamed:@"exchangemoneyframeSomeone_light"];
                image4RedPacketFrame.center = CGPointMake(173, 43);
                [contentView addSubview:image4RedPacketFrame];
                
                UIImageView *image4ExchangeFlag = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"exchange_flag"]];
                image4ExchangeFlag.center = CGPointMake(114, 33);
                [image4RedPacketFrame addSubview:image4ExchangeFlag];
                
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
                [image4CoinIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, [ExchangeMoneyInfo objectForKey:@"coinIconWhiteUrl"]]]];
                [contentView addSubview:image4CoinIcon];
                
                //付出币种信息
                UILabel *label4CoinInfo = [[UILabel alloc]initWithFrame:CGRectMake(125, 11, 98, 20)];
                label4CoinInfo.text = [NSString stringWithFormat:@"%@ %@", [BiChatGlobal decimalNumberWithDouble:[[ExchangeMoneyInfo objectForKey:@"count"]doubleValue]], [ExchangeMoneyInfo objectForKey:@"coinName"]];
                label4CoinInfo.adjustsFontSizeToFitWidth = YES;
                label4CoinInfo.textAlignment = NSTextAlignmentCenter;
                label4CoinInfo.textColor = [UIColor whiteColor];
                [contentView addSubview:label4CoinInfo];
                
                NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:label4CoinInfo.text];
                [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, str.length)];
                [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(str.length - [[ExchangeMoneyInfo objectForKey:@"coinName"]length], [[ExchangeMoneyInfo objectForKey:@"coinName"]length])];
                label4CoinInfo.attributedText = str;
                
                //换入币种信息
                UILabel *label4ExchangeCoinInfo = [[UILabel alloc]initWithFrame:CGRectMake(125, 37, 98, 20)];
                label4ExchangeCoinInfo.text = [NSString stringWithFormat:@"%@ %@", [BiChatGlobal decimalNumberWithDouble:[[ExchangeMoneyInfo objectForKey:@"exchangeCount"]doubleValue]], [ExchangeMoneyInfo objectForKey:@"exchangeCoinName"]];
                label4ExchangeCoinInfo.adjustsFontSizeToFitWidth = YES;
                label4ExchangeCoinInfo.textAlignment = NSTextAlignmentCenter;
                label4ExchangeCoinInfo.textColor = [UIColor whiteColor];
                [contentView addSubview:label4ExchangeCoinInfo];
                
                str = [[NSMutableAttributedString alloc]initWithString:label4ExchangeCoinInfo.text];
                [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, str.length)];
                [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(str.length - [[ExchangeMoneyInfo objectForKey:@"exchangeCoinName"]length], [[ExchangeMoneyInfo objectForKey:@"exchangeCoinName"]length])];
                label4ExchangeCoinInfo.attributedText = str;
                
                //数量
//                NSString *str = [BiChatGlobal decimalNumberWithDouble:[[ExchangeMoneyInfo objectForKey:@"count"]doubleValue]];
//                CGRect rect = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
//                                                options:NSStringDrawingUsesLineFragmentOrigin
//                                             attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
//                                                context:nil];
//                UILabel *label4Count = [[UILabel alloc]initWithFrame:CGRectMake(125, 13, rect.size.width, 20)];
//                label4Count.text = str;
//                label4Count.font = [UIFont systemFontOfSize:14];
//                label4Count.textColor = [UIColor whiteColor];
//                [contentView addSubview:label4Count];
//
//                //币种名称
//                UILabel *label4CoinName = [[UILabel alloc]initWithFrame:CGRectMake(125 + rect.size.width + 3, 19, 100 - rect.size.width, 11)];
//                label4CoinName.text = [ExchangeMoneyInfo objectForKey:@"coinName"];
//                label4CoinName.font = [UIFont systemFontOfSize:11];
//                label4CoinName.textColor = [UIColor whiteColor];
//                label4CoinName.adjustsFontSizeToFitWidth = YES;
//                [contentView addSubview:label4CoinName];
//
//                //交换币种名称
//                str = [ExchangeMoneyInfo objectForKey:@"exchangeCoinName"];
//                rect = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
//                                         options:NSStringDrawingUsesLineFragmentOrigin
//                                      attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:11]}
//                                         context:nil];
//                UILabel *label4ExchangeCoinName = [[UILabel alloc]initWithFrame:CGRectMake(234 - rect.size.width - 10, 42, rect.size.width, 11)];
//                label4ExchangeCoinName.text = str;
//                label4ExchangeCoinName.font = [UIFont systemFontOfSize:11];
//                label4ExchangeCoinName.textColor = [UIColor whiteColor];
//                [contentView addSubview:label4ExchangeCoinName];
//
//                //交换数量
//                UILabel *label4ExchangeCount = [[UILabel alloc]initWithFrame:CGRectMake(120 , 36, 100 - rect.size.width, 20)];
//                label4ExchangeCount.text = [BiChatGlobal decimalNumberWithDouble:[[ExchangeMoneyInfo objectForKey:@"exchangeCount"]doubleValue]];
//                label4ExchangeCount.font = [UIFont systemFontOfSize:14];
//                label4ExchangeCount.textColor = [UIColor whiteColor];
//                label4ExchangeCount.adjustsFontSizeToFitWidth = YES;
//                label4ExchangeCount.textAlignment = NSTextAlignmentRight;
//                [contentView addSubview:label4ExchangeCount];

                //交换币种图标
                UIImageView *image4ExchangeCoinIcon = [[UIImageView alloc]initWithFrame:CGRectMake(234, 14, 40, 40)];
                [image4ExchangeCoinIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, [ExchangeMoneyInfo objectForKey:@"exchangeCoinIconWhiteUrl"]]]];
                [contentView addSubview:image4ExchangeCoinIcon];

                UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(74, 68, 200, 15)];
                label4Title.text = LLSTR(@"101669");
                if ([[BiChatGlobal sharedManager]isExchangeMoneyFinished:[ExchangeMoneyInfo objectForKey:@"transactionId"]] == 1)
                    label4Title.text = LLSTR(@"101660");
                else if ([[BiChatGlobal sharedManager]isExchangeMoneyFinished:[ExchangeMoneyInfo objectForKey:@"transactionId"]] == 2)
                    label4Title.text = LLSTR(@"101661");
                else if ([[BiChatGlobal sharedManager]isExchangeMoneyFinished:[ExchangeMoneyInfo objectForKey:@"transactionId"]] == 3)
                    label4Title.text = LLSTR(@"101662");
                label4Title.font = [UIFont systemFontOfSize:12];
                label4Title.textColor = THEME_GRAY;
                [contentView addSubview:label4Title];
            }
        }
    }
}

@end
