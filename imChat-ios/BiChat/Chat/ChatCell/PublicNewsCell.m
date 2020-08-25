//
//  PublicNewsCell.m
//  BiChat
//
//  Created by worm_kc on 2018/4/25.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "PublicNewsCell.h"
#import "JSONKit.h"

@implementation PublicNewsCell

+ (CGFloat)getCellHeight:(NSDictionary *)message
                 peerUid:(NSString *)peerUid
                   width:(CGFloat)cellWidth
            showNickName:(BOOL)showNickName
{
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *messageInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    CGFloat imageHeight = [[messageInfo objectForKey:@"img"]length]==0?0:(cellWidth - 40)/2;
    //NSLog(@"%@", messageInfo);
    
    CGRect rect4Title = [[messageInfo objectForKey:@"title"]boundingRectWithSize:CGSizeMake(cellWidth - 60, MAXFLOAT)
                                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                                      attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                                                         context:nil];
    CGRect rect4Desc = [[messageInfo objectForKey:@"desc"]boundingRectWithSize:CGSizeMake(cellWidth - 60, MAXFLOAT)
                                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                                    attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                                                       context:nil];
    if (rect4Desc.size.height > 51)
        rect4Desc.size.height = 51;
    return imageHeight + rect4Title.size.height + rect4Desc.size.height + 40;
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
    NSDictionary *messageInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    CGFloat imageHeight = [[messageInfo objectForKey:@"img"]length]==0?0:(cellWidth - 40)/2;
    //NSLog(@"%@", messageInfo);
    
    CGRect rect4Title = [[messageInfo objectForKey:@"title"]boundingRectWithSize:CGSizeMake(cellWidth - 60, MAXFLOAT)
                                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                                      attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                                                         context:nil];
    CGRect rect4Desc = [[messageInfo objectForKey:@"desc"]boundingRectWithSize:CGSizeMake(cellWidth - 60, MAXFLOAT)
                                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                                    attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                                                       context:nil];
    if (rect4Desc.size.height > 51)
        rect4Desc.size.height = 51;
    
    UIView *view4NewsFrame = [[UIView alloc]initWithFrame:CGRectMake(20, 0, cellWidth - 40,
                                                                     imageHeight + rect4Title.size.height + rect4Desc.size.height + 30)];
    view4NewsFrame.backgroundColor = [UIColor whiteColor];
    view4NewsFrame.layer.borderWidth = .5;
    view4NewsFrame.layer.borderColor = THEME_GRAY.CGColor;
    view4NewsFrame.layer.cornerRadius = 5;
    view4NewsFrame.clipsToBounds = YES;
    [contentView addSubview:view4NewsFrame];
    
    //添加tap手势
    if ([[messageInfo objectForKey:@"link"]length] > 0)
    {
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:tapTarget action:tapAction];
        objc_setAssociatedObject(tapGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(tapGest, @"targetView", view4NewsFrame, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(tapGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
        [view4NewsFrame addGestureRecognizer:tapGest];
    }
    
    //放图片
    if ([[messageInfo objectForKey:@"img"]length] > 0)
    {
        UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, cellWidth - 40, (cellWidth - 40)/2)];
        image.contentMode = UIViewContentModeScaleAspectFill;
        image.clipsToBounds = YES;
        [image sd_setImageWithURL:[NSURL URLWithString:[messageInfo objectForKey:@"img"]]];
        [view4NewsFrame addSubview:image];
    }
    
    //标题
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(10, imageHeight + 10, rect4Title.size.width, rect4Title.size.height)];
    label4Title.text = [messageInfo objectForKey:@"title"];
    label4Title.font = [UIFont systemFontOfSize:16];
    label4Title.numberOfLines = 0;
    [view4NewsFrame addSubview:label4Title];
    
    //简介
    UILabel *label4Desc = [[UILabel alloc]initWithFrame:CGRectMake(10, imageHeight + 10 + rect4Title.size.height + 10, rect4Desc.size.width, rect4Desc.size.height)];
    label4Desc.text = [messageInfo objectForKey:@"desc"];
    label4Desc.font = [UIFont systemFontOfSize:14];
    label4Desc.numberOfLines = 0;
    label4Desc.textColor = [UIColor grayColor];
    [view4NewsFrame addSubview:label4Desc];
}

@end
