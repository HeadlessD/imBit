//
//  NewsCell.m
//  BiChat
//
//  Created by worm_kc on 2018/4/25.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "NewsCell.h"
#import "JSONKit.h"

@implementation NewsCell

+ (CGFloat)getCellHeight:(NSDictionary *)message
                 peerUid:(NSString *)peerUid
                   width:(CGFloat)cellWidth
            showNickName:(BOOL)showNickName
{
    //解析链接内容
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *newsInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];

    //标题高度
    CGRect rect = [[newsInfo objectForKey:@"title"]boundingRectWithSize:CGSizeMake(205, 40)
                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                             attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                                                context:nil];
    
    if (![[message objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid] && showNickName)
        return 125 + rect.size.height;
    else
        return 105 + rect.size.height;
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
    //解析链接内容
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *newsInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    
    //标题高度
    CGRect rect4Title = [[newsInfo objectForKey:@"title"]boundingRectWithSize:CGSizeMake(205, 40)
                                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                                   attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                                                      context:nil];
    
    //是否自己发言
    NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:peerUid];
    if ([[message objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
    {
        //头像
        UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[BiChatGlobal sharedManager].uid nickName:[BiChatGlobal sharedManager].nickName avatar:[BiChatGlobal sharedManager].avatar frame:CGRectMake(cellWidth - 50, 0, 40, 40)];
        [self bundleView:view4Avatar
                WithUser:[message objectForKey:@"sender"]
                userName:[message objectForKey:@"senderUserName"]
                nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]
                  avatar:[message objectForKey:@"senderAvatar"]
                isPublic:[[message objectForKey:@"isPublic"]boolValue]
               tapTarget:tapUserAvatarTarget tapAction:tapUserAvatarAction
         longPressTarget:longPressUserAvatarTarget longPressAction:longPressUserAvatarAction];
        [contentView addSubview:view4Avatar];
        
        //内容框
        UIImageView *image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(cellWidth - 235 - 55,
                                                                                       0,
                                                                                       235,
                                                                                       87 + rect4Title.size.height + 8)];
        image4ContentFrame.image = [UIImage imageNamed:@"bubbleMine_light"];
        [contentView addSubview:image4ContentFrame];
        
        if (!inMultiSelectMode)
        {
            //给图片增加长按手势
            image4ContentFrame.userInteractionEnabled = YES;
            UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
            objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(longPressGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
            [image4ContentFrame addGestureRecognizer:longPressGest];
            
            //给图片增加轻点手势
            UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:tapTarget action:tapAction];
            objc_setAssociatedObject(tapGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(tapGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(tapGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
            [image4ContentFrame addGestureRecognizer:tapGest];
        }
        
        //内容
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 278, 11, rect4Title.size.width, rect4Title.size.height)];
        label4Title.text = [newsInfo objectForKey:@"title"];
        label4Title.font = [UIFont systemFontOfSize:16];
        label4Title.numberOfLines = 0;
        [contentView addSubview:label4Title];

        //图片
        UIImageView *view4CardAvatar = [[UIImageView alloc]initWithFrame:CGRectMake(cellWidth - 278, 12 + rect4Title.size.height + 8, 46, 46)];
        if ([[newsInfo objectForKey:@"newsid"]length] == 0 && [[newsInfo objectForKey:@"pubid"]length] == 0)
        {
            view4CardAvatar.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
            [view4CardAvatar sd_setImageWithURL:[NSURL URLWithString:[newsInfo objectForKey:@"image"]]placeholderImage:[UIImage imageNamed:@"share_link_gray"]];
        }
        else
            [view4CardAvatar sd_setImageWithURL:[NSURL URLWithString:[newsInfo objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"share_link_gray"]];
        view4CardAvatar.contentMode = UIViewContentModeScaleAspectFill;
        view4CardAvatar.clipsToBounds = YES;
        [contentView addSubview:view4CardAvatar];
        
        //副标题
        if ([[newsInfo objectForKey:@"desc"]length] != 0)
        {
            CGRect rect = [[newsInfo objectForKey:@"desc"]boundingRectWithSize:CGSizeMake(155, 50)
                                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                                     attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}
                                                                        context:nil];
            UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 223, 12 + rect4Title.size.height + 8, rect.size.width, rect.size.height)];
            label4Title.text = [newsInfo objectForKey:@"desc"];
            label4Title.textColor = [UIColor grayColor];
            label4Title.font = [UIFont systemFontOfSize:13];
            label4Title.numberOfLines = 0;
            [contentView addSubview:label4Title];
        }

        //seperator
        UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(cellWidth - 225 - 55, 65 + rect4Title.size.height + 10, 210, 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
        [contentView addSubview:view4Seperator];
        
        //链接标志
        UILabel *label4Card = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 278, 67 + rect4Title.size.height + 10, 190, 15)];
        label4Card.text = LLSTR(@"201021");
        label4Card.font = [UIFont systemFontOfSize:12];
        label4Card.textColor = THEME_GRAY;
        [contentView addSubview:label4Card];
    }
    else
    {
        if (inMultiSelectMode)  //是多重选择模式
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
                label4NickName.text = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]];
                label4NickName.font = [UIFont systemFontOfSize:12];
                label4NickName.textColor = [UIColor grayColor];
                [contentView addSubview:label4NickName];
                
                //内容框
                UIImageView *image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(95,
                                                                                               20,
                                                                                               235,
                                                                                               85 + rect4Title.size.height + 10)];
                image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                [contentView addSubview:image4ContentFrame];
                
                //内容
                UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(112, 31, rect4Title.size.width, rect4Title.size.height)];
                label4Title.text = [newsInfo objectForKey:@"title"];
                label4Title.font = [UIFont systemFontOfSize:16];
                label4Title.numberOfLines = 0;
                [contentView addSubview:label4Title];

                //图片
                UIImageView *view4CardAvatar = [[UIImageView alloc]initWithFrame:CGRectMake(112, 31 + rect4Title.size.height + 8, 46, 46)];
                if ([[newsInfo objectForKey:@"newsid"]length] == 0 && [[newsInfo objectForKey:@"pubid"]length] == 0)
                {
                    view4CardAvatar.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                    [view4CardAvatar sd_setImageWithURL:[NSURL URLWithString:[newsInfo objectForKey:@"image"]]placeholderImage:[UIImage imageNamed:@"share_link_gray"]];
                }
                else
                    [view4CardAvatar sd_setImageWithURL:[NSURL URLWithString:[newsInfo objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"share_link_gray"]];
                view4CardAvatar.contentMode = UIViewContentModeScaleAspectFill;
                view4CardAvatar.clipsToBounds = YES;
                [contentView addSubview:view4CardAvatar];
                
                //标题
                if ([[newsInfo objectForKey:@"desc"]length] != 0)
                {
                    CGRect rect = [[newsInfo objectForKey:@"desc"]boundingRectWithSize:CGSizeMake(155, 50)
                                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                                             attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}
                                                                                context:nil];
                    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(163, 31 + rect4Title.size.height + 8, rect.size.width, rect.size.height)];
                    label4Title.text = [newsInfo objectForKey:@"desc"];
                    label4Title.font = [UIFont systemFontOfSize:13];
                    label4Title.numberOfLines = 0;
                    label4Title.textColor = [UIColor grayColor];
                    [contentView addSubview:label4Title];
                }

                //seperator
                UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(110, 85 + rect4Title.size.height + 10, 210, 0.5)];
                view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                [contentView addSubview:view4Seperator];
                
                //链接标志
                UILabel *label4Card = [[UILabel alloc]initWithFrame:CGRectMake(112, 87 + rect4Title.size.height + 10, 190, 15)];
                label4Card.text = LLSTR(@"201021");
                label4Card.font = [UIFont systemFontOfSize:12];
                label4Card.textColor = THEME_GRAY;
                [contentView addSubview:label4Card];
            }
            else
            {
                //内容框
                UIImageView *image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(95,
                                                                                               0,
                                                                                               235,
                                                                                               84 + rect4Title.size.height + 10)];
                image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                [contentView addSubview:image4ContentFrame];
                
                //内容
                UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(112, 11, rect4Title.size.width, rect4Title.size.height)];
                label4Title.text = [newsInfo objectForKey:@"title"];
                label4Title.font = [UIFont systemFontOfSize:16];
                label4Title.numberOfLines = 0;
                [contentView addSubview:label4Title];
                
                //图片
                UIImageView *view4CardAvatar = [[UIImageView alloc]initWithFrame:CGRectMake(112, 12 + rect4Title.size.height + 8, 44, 44)];
                if ([[newsInfo objectForKey:@"newsid"]length] == 0 && [[newsInfo objectForKey:@"pubid"]length] == 0)
                {
                    view4CardAvatar.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                    [view4CardAvatar sd_setImageWithURL:[NSURL URLWithString:[newsInfo objectForKey:@"image"]]placeholderImage:[UIImage imageNamed:@"share_link_gray"]];
                }
                else
                    [view4CardAvatar sd_setImageWithURL:[NSURL URLWithString:[newsInfo objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"share_link_gray"]];
                view4CardAvatar.contentMode = UIViewContentModeScaleAspectFill;
                view4CardAvatar.clipsToBounds = YES;
                [contentView addSubview:view4CardAvatar];
                
                //标题
                if ([[newsInfo objectForKey:@"desc"]length] != 0)
                {
                    CGRect rect = [[newsInfo objectForKey:@"desc"]boundingRectWithSize:CGSizeMake(155, 50)
                                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                                             attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}
                                                                                context:nil];
                    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(164, 11 + rect4Title.size.height + 8, rect.size.width, rect.size.height)];
                    label4Title.text = [newsInfo objectForKey:@"desc"];
                    label4Title.font = [UIFont systemFontOfSize:13];
                    label4Title.numberOfLines = 0;
                    label4Title.textColor = [UIColor grayColor];
                    [contentView addSubview:label4Title];
                }

                //seperator
                UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(110, 65 + rect4Title.size.height + 10, 210, 0.5)];
                view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                [contentView addSubview:view4Seperator];
                
                //链接标志
                UILabel *label4Card = [[UILabel alloc]initWithFrame:CGRectMake(112, 67 + rect4Title.size.height + 10, 190, 15)];
                label4Card.text = LLSTR(@"201021");
                label4Card.font = [UIFont systemFontOfSize:12];
                label4Card.textColor = THEME_GRAY;
                [contentView addSubview:label4Card];
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
                label4NickName.text = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]];
                label4NickName.font = [UIFont systemFontOfSize:12];
                label4NickName.textColor = [UIColor grayColor];
                [contentView addSubview:label4NickName];
                
                //内容框
                UIImageView *image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(55,
                                                                                               20,
                                                                                               235,
                                                                                               85 + rect4Title.size.height + 10)];
                image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                [contentView addSubview:image4ContentFrame];
                
                //给图片增加长按手势
                image4ContentFrame.userInteractionEnabled = YES;
                UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
                objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(longPressGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [image4ContentFrame addGestureRecognizer:longPressGest];
                
                //给图片增加轻点手势
                UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:tapTarget action:tapAction];
                objc_setAssociatedObject(tapGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(tapGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(tapGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [image4ContentFrame addGestureRecognizer:tapGest];
                
                //内容
                UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(72, 31, rect4Title.size.width, rect4Title.size.height)];
                label4Title.text = [newsInfo objectForKey:@"title"];
                label4Title.font = [UIFont systemFontOfSize:16];
                label4Title.numberOfLines = 0;
                [contentView addSubview:label4Title];

                //图片
                UIImageView *view4CardAvatar = [[UIImageView alloc]initWithFrame:CGRectMake(72, 31 + rect4Title.size.height + 8, 46, 46)];
                if ([[newsInfo objectForKey:@"newsid"]length] == 0 && [[newsInfo objectForKey:@"pubid"]length] == 0)
                {
                    view4CardAvatar.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                    [view4CardAvatar sd_setImageWithURL:[NSURL URLWithString:[newsInfo objectForKey:@"image"]]placeholderImage:[UIImage imageNamed:@"share_link_gray"]];
                }
                else
                    [view4CardAvatar sd_setImageWithURL:[NSURL URLWithString:[newsInfo objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"share_link_gray"]];
                view4CardAvatar.contentMode = UIViewContentModeScaleAspectFill;
                view4CardAvatar.clipsToBounds = YES;
                [contentView addSubview:view4CardAvatar];
                
                //标题
                if ([[newsInfo objectForKey:@"desc"]length] != 0)
                {
                    CGRect rect = [[newsInfo objectForKey:@"desc"]boundingRectWithSize:CGSizeMake(155, 50)
                                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                                             attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}
                                                                                context:nil];
                    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(126, 31 + rect4Title.size.height + 8, rect.size.width, rect.size.height)];
                    label4Title.text = [newsInfo objectForKey:@"desc"];
                    label4Title.font = [UIFont systemFontOfSize:13];
                    label4Title.numberOfLines = 0;
                    label4Title.textColor = [UIColor grayColor];
                    [contentView addSubview:label4Title];
                }

                //seperator
                UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(70, 85 + rect4Title.size.height + 10, 210, 0.5)];
                view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                [contentView addSubview:view4Seperator];
                
                //链接标志
                UILabel *label4Card = [[UILabel alloc]initWithFrame:CGRectMake(72, 87 + rect4Title.size.height + 10, 190, 15)];
                label4Card.text = LLSTR(@"201021");
                label4Card.font = [UIFont systemFontOfSize:12];
                label4Card.textColor = THEME_GRAY;
                [contentView addSubview:label4Card];
            }
            else
            {
                //内容框
                UIImageView *image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(55,
                                                                                               0,
                                                                                               235,
                                                                                               95 + rect4Title.size.height)];
                image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                [contentView addSubview:image4ContentFrame];
                
                //给图片增加长按手势
                image4ContentFrame.userInteractionEnabled = YES;
                UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
                objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(longPressGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [image4ContentFrame addGestureRecognizer:longPressGest];
                
                //给图片增加轻点手势
                UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:tapTarget action:tapAction];
                objc_setAssociatedObject(tapGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(tapGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(tapGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [image4ContentFrame addGestureRecognizer:tapGest];
                
                //内容
                UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(72, 11, rect4Title.size.width, rect4Title.size.height)];
                label4Title.text = [newsInfo objectForKey:@"title"];
                label4Title.font = [UIFont systemFontOfSize:16];
                label4Title.numberOfLines = 0;
                [contentView addSubview:label4Title];

                //图片
                UIImageView *view4CardAvatar = [[UIImageView alloc]initWithFrame:CGRectMake(72, 11 + rect4Title.size.height + 8, 46, 46)];
                if ([[newsInfo objectForKey:@"newsid"]length] == 0 && [[newsInfo objectForKey:@"pubid"]length] == 0)
                {
                    view4CardAvatar.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                    [view4CardAvatar sd_setImageWithURL:[NSURL URLWithString:[newsInfo objectForKey:@"image"]]placeholderImage:[UIImage imageNamed:@"share_link_gray"]];
                }
                else
                    [view4CardAvatar sd_setImageWithURL:[NSURL URLWithString:[newsInfo objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"share_link_gray"]];
                view4CardAvatar.contentMode = UIViewContentModeScaleAspectFill;
                view4CardAvatar.clipsToBounds = YES;
                [contentView addSubview:view4CardAvatar];
                
                //标题
                if ([[newsInfo objectForKey:@"desc"]length] != 0)
                {
                    CGRect rect = [[newsInfo objectForKey:@"desc"]boundingRectWithSize:CGSizeMake(155, 50)
                                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                                             attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}
                                                                                context:nil];
                    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(127, 11 + rect4Title.size.height + 8, rect.size.width, rect.size.height)];
                    label4Title.text = [newsInfo objectForKey:@"desc"];
                    label4Title.font = [UIFont systemFontOfSize:13];
                    label4Title.numberOfLines = 0;
                    label4Title.textColor = [UIColor grayColor];
                    [contentView addSubview:label4Title];
                }

                //seperator
                UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(70, 67 + rect4Title.size.height + 8, 210, 0.5)];
                view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
                [contentView addSubview:view4Seperator];
                
                //链接标志
                UILabel *label4Card = [[UILabel alloc]initWithFrame:CGRectMake(72, 69 + rect4Title.size.height + 8, 190, 15)];
                label4Card.text = LLSTR(@"201021");
                label4Card.font = [UIFont systemFontOfSize:12];
                label4Card.textColor = THEME_GRAY;
                [contentView addSubview:label4Card];
            }
        }
    }
}

@end
