//
//  PublicMessageCell.m
//  BiChat
//
//  Created by worm_kc on 2018/4/25.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "PublicMessageCell.h"
#import "JSONKit.h"

@implementation PublicMessageCell

+ (CGFloat)getCellHeight:(NSDictionary *)message
                 peerUid:(NSString *)peerUid
                   width:(CGFloat)cellWidth
            showNickName:(BOOL)showNickName
{
    if ([[message objectForKey:@"content"]length] == 0)
        return 0;
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *messageInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    //NSLog(@"%@", messageInfo);
    
    //是否有多语言处理
    if ([message objectForKey:@"langs"] != nil)
    {
        NSDictionary *langs = [dec objectWithData:[[message objectForKey:@"langs"]dataUsingEncoding:NSUTF8StringEncoding]];
        if ([langs objectForKey:[DFLanguageManager getLanguageName]] != nil)
            messageInfo = [langs objectForKey:[DFLanguageManager getLanguageName]];
    }
    
    if ([[messageInfo objectForKey:@"type"]integerValue] == 1)
    {
        //具体内容
        CGFloat offset = 150;
        for (NSDictionary *item in [messageInfo objectForKey:@"keysWords"])
        {
            NSString * str = [NSString stringWithFormat:@"%@", [item objectForKey:@"value"]];
            CGRect rect = [str boundingRectWithSize:CGSizeMake(cellWidth - 172, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                            context:nil];
            offset += (rect.size.height + 5);
        }
        return offset + 20;
    }
    else
    {
        //具体内容
        CGFloat offset = 60;
        for (NSDictionary *item in [messageInfo objectForKey:@"keysWords"])
        {
            NSString * str = [NSString stringWithFormat:@"%@", [item objectForKey:@"value"]];
            CGRect rect = [str boundingRectWithSize:CGSizeMake(cellWidth - 172, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                            context:nil];
            offset += (rect.size.height + 5);
        }
        return offset + 20;
    }
}

+ (void)renderCellInView:(UIView *)contentView
                 peerUid:(NSString *)peerUid
                 message:(NSMutableDictionary *)message1
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
    if ([[message1 objectForKey:@"content"]length] == 0)
        return;
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *messageInfo = [dec objectWithData:[[message1 objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    
    //是否有多语言处理
    if ([message1 objectForKey:@"langs"] != nil)
    {
        NSDictionary *langs = [dec objectWithData:[[message1 objectForKey:@"langs"]dataUsingEncoding:NSUTF8StringEncoding]];
        if ([langs objectForKey:[DFLanguageManager getLanguageName]] != nil)
            messageInfo = [langs objectForKey:[DFLanguageManager getLanguageName]];
    }
    
    //计算keywords里面的name的最长
    CGFloat width = 0;
    for (NSDictionary *item in [messageInfo objectForKey:@"keysWords"])
    {
        NSString *name = [item objectForKey:@"name"];
        CGRect rect = [name boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
        if (rect.size.width > width)
            width = rect.size.width;
    }
    
    //NSLog(@"%@", messageInfo);
    if ([[messageInfo objectForKey:@"type"]integerValue] == 1)
    {
        UIView *view4NewsFrame = [[UIView alloc]initWithFrame:CGRectMake(20, 0, cellWidth - 40, 400)];
        view4NewsFrame.backgroundColor = [UIColor whiteColor];
        view4NewsFrame.layer.borderWidth = .5;
        view4NewsFrame.layer.borderColor = THEME_GRAY.CGColor;
        view4NewsFrame.layer.cornerRadius = 5;
        view4NewsFrame.clipsToBounds = YES;
        [contentView addSubview:view4NewsFrame];
        
        //logo
        if ([messageInfo objectForKey:@"logo"] != nil)
        {
            UIImageView *image4Logo = [[UIImageView alloc]initWithFrame:CGRectMake(8, 8, 24, 24)];
            [image4Logo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, [messageInfo objectForKey:@"logo"]]]];
            [view4NewsFrame addSubview:image4Logo];
        }
        
        //标题
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake([messageInfo objectForKey:@"logo"]==nil?12:32, 10, view4NewsFrame.frame.size.width - 20, 20)];
        label4Title.text = [messageInfo objectForKey:@"title"];
        label4Title.font = [UIFont systemFontOfSize:16];
        [view4NewsFrame addSubview:label4Title];
        
        //是否有链接
        if ([[messageInfo objectForKey:@"link"]length] > 0)
        {
            UIView *view4Title = [[UIView alloc]initWithFrame:CGRectMake(10, 10, view4NewsFrame.frame.size.width - 20, 40)];
            UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:tapTarget action:tapAction];
            objc_setAssociatedObject(tapGest, @"targetData", message1, OBJC_ASSOCIATION_ASSIGN);
            [view4Title addGestureRecognizer:tapGest];
            [view4NewsFrame addSubview:view4Title];

            UIButton *button4Link = [[UIButton alloc]initWithFrame:CGRectMake(view4NewsFrame.frame.size.width - 30, 0, 30, 40)];
            objc_setAssociatedObject(button4Link, @"targetData", message1, OBJC_ASSOCIATION_RETAIN);
            [button4Link setImage:[UIImage imageNamed:@"arrow_right"] forState:UIControlStateNormal];
            [button4Link addTarget:tapTarget action:tapAction forControlEvents:UIControlEventTouchUpInside];
            [view4NewsFrame addSubview:button4Link];
        }
        
        UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(8, 40, view4NewsFrame.frame.size.width - 16, 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
        [view4NewsFrame addSubview:view4Seperator];
        
        //内容第一行
        UILabel *label4ContentLine1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 70, view4NewsFrame.frame.size.width - 20, 40)];
        if ([[messageInfo objectForKey:@"first1"]isKindOfClass:[NSNumber class]])
            label4ContentLine1.text = [BiChatGlobal decimalNumberWithDouble:[[messageInfo objectForKey:@"first1"]doubleValue]];
        else
            label4ContentLine1.text = [NSString stringWithFormat:@"%@", [messageInfo objectForKey:@"first1"]];
        label4ContentLine1.font = [UIFont systemFontOfSize:35];
        label4ContentLine1.textAlignment = NSTextAlignmentCenter;
        [view4NewsFrame addSubview:label4ContentLine1];
        
        //内容第二行
        UILabel *label4ContentLine2 = [[UILabel alloc]initWithFrame:CGRectMake(10, 110, view4NewsFrame.frame.size.width - 20, 15)];
        label4ContentLine2.text = [NSString stringWithFormat:@"%@", [messageInfo objectForKey:@"first2"]];
        label4ContentLine2.font = [UIFont systemFontOfSize:12];
        label4ContentLine2.textColor = [UIColor grayColor];
        label4ContentLine2.textAlignment = NSTextAlignmentCenter;
        [view4NewsFrame addSubview:label4ContentLine2];
        
        //具体内容
        CGFloat offset = 150;
        for (NSDictionary *item in [messageInfo objectForKey:@"keysWords"])
        {
            NSString * str = [NSString stringWithFormat:@"%@", [item objectForKey:@"value"]];
            
            if ([[[item objectForKey:@"type"]lowercaseString]isEqualToString:@"time"])
            {
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[item objectForKey:@"value"]doubleValue] / 1000];
                NSDateFormatter *fmt = [NSDateFormatter new];
                fmt.dateFormat = @"yyyy-MM-dd HH:mm";
                str = [fmt stringFromDate:date];
            }
            
            CGRect rect = [str boundingRectWithSize:CGSizeMake(cellWidth - width - 100, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                            context:nil];
            UILabel *label4Name = [[UILabel alloc]initWithFrame:CGRectMake(20, offset, width, 16)];
            label4Name.text = [item objectForKey:@"name"];
            label4Name.textColor = [UIColor grayColor];
            label4Name.font = [UIFont systemFontOfSize:14];
            label4Name.adjustsFontSizeToFitWidth = YES;
            [view4NewsFrame addSubview:label4Name];
            
            UILabel *label4Value = [[UILabel alloc]initWithFrame:CGRectMake(width + 40, offset, rect.size.width, rect.size.height)];
            label4Value.text = str;
            label4Value.font = [UIFont systemFontOfSize:14];
            label4Value.numberOfLines = 0;
            [view4NewsFrame addSubview:label4Value];
            
            offset += (rect.size.height + 5);
        }
        view4NewsFrame.frame = CGRectMake(20, 0, cellWidth - 40, offset + 10);
    }
    else
    {
        UIView *view4NewsFrame = [[UIView alloc]initWithFrame:CGRectMake(20, 0, cellWidth - 40, 400)];
        view4NewsFrame.backgroundColor = [UIColor whiteColor];
        view4NewsFrame.layer.borderWidth = .5;
        view4NewsFrame.layer.borderColor = THEME_GRAY.CGColor;
        view4NewsFrame.layer.cornerRadius = 5;
        view4NewsFrame.clipsToBounds = YES;
        [contentView addSubview:view4NewsFrame];
        
        //logo
        if ([messageInfo objectForKey:@"logo"] != nil)
        {
            UIImageView *image4Logo = [[UIImageView alloc]initWithFrame:CGRectMake(8, 8, 24, 24)];
            [image4Logo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].StaticUrl, [messageInfo objectForKey:@"logo"]]]];
            [view4NewsFrame addSubview:image4Logo];
        }
        
        //标题
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake([messageInfo objectForKey:@"logo"]==nil?12:32, 10, view4NewsFrame.frame.size.width - 20, 20)];
        label4Title.text = [messageInfo objectForKey:@"title"];
        label4Title.font = [UIFont systemFontOfSize:16];
        [view4NewsFrame addSubview:label4Title];
        
        //是否有链接
        if ([[messageInfo objectForKey:@"link"]length] > 0)
        {
            UIView *view4Title = [[UIView alloc]initWithFrame:CGRectMake(10, 10, view4NewsFrame.frame.size.width - 20, 40)];
            UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:tapTarget action:tapAction];
            objc_setAssociatedObject(tapGest, @"targetData", message1, OBJC_ASSOCIATION_ASSIGN);
            [view4Title addGestureRecognizer:tapGest];
            [view4NewsFrame addSubview:view4Title];
            
            UIButton *button4Link = [[UIButton alloc]initWithFrame:CGRectMake(view4NewsFrame.frame.size.width - 30, 0, 30, 40)];
            objc_setAssociatedObject(button4Link, @"targetData", message1, OBJC_ASSOCIATION_RETAIN);
            [button4Link setImage:[UIImage imageNamed:@"arrow_right"] forState:UIControlStateNormal];
            [button4Link addTarget:tapTarget action:tapAction forControlEvents:UIControlEventTouchUpInside];
            [view4NewsFrame addSubview:button4Link];
        }
        
        UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(8, 40, view4NewsFrame.frame.size.width - 16, 0.5)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
        [view4NewsFrame addSubview:view4Seperator];
        
        //具体内容
        CGFloat offset = 60;
        for (NSDictionary *item in [messageInfo objectForKey:@"keysWords"])
        {
            NSString * str = [NSString stringWithFormat:@"%@", [item objectForKey:@"value"]];
            
            if ([[[item objectForKey:@"type"]lowercaseString]isEqualToString:@"time"])
            {
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[item objectForKey:@"value"]doubleValue] / 1000];
                NSDateFormatter *fmt = [NSDateFormatter new];
                fmt.dateFormat = @"yyyy-MM-dd HH:mm";
                str = [fmt stringFromDate:date];
            }
            
            CGRect rect = [str boundingRectWithSize:CGSizeMake(cellWidth - width - 100, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                            context:nil];
            UILabel *label4Name = [[UILabel alloc]initWithFrame:CGRectMake(20, offset, width, 16)];
            label4Name.text = [item objectForKey:@"name"];
            label4Name.textColor = [UIColor grayColor];
            label4Name.font = [UIFont systemFontOfSize:14];
            label4Name.adjustsFontSizeToFitWidth = YES;
            [view4NewsFrame addSubview:label4Name];
            
            UILabel *label4Value = [[UILabel alloc]initWithFrame:CGRectMake(width + 40, offset, rect.size.width, rect.size.height)];
            label4Value.text = str;
            label4Value.font = [UIFont systemFontOfSize:14];
            label4Value.numberOfLines = 0;
            [view4NewsFrame addSubview:label4Value];
            
            offset += (rect.size.height + 5);
        }
        view4NewsFrame.frame = CGRectMake(20, 0, cellWidth - 40, offset + 10);
    }
}

@end
