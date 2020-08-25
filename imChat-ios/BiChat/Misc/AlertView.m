//
//  AlertView.m
//  福利社
//
//  Created by lugang on 8/16/13.
//  Copyright (c) 2013 lugang. All rights reserved.
//

#import "AlertView.h"
#import "BiChatGlobal.h"

@implementation AlertView
@synthesize alertIcon;
@synthesize alertLabel;
@synthesize alertBk;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = self.enableClick;
        [self showAlert];
    }
    return self;
}

-(void)showAlert{
    
    self.window.windowLevel = 1999;
    self.backgroundColor = [UIColor clearColor];
    
    alertBk = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    alertBk.image = [UIImage imageNamed:@"alert.png"];
    [self addSubview:alertBk];
    
    alertLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    alertLabel.textAlignment = NSTextAlignmentCenter;
    alertLabel.numberOfLines = 0;
    alertLabel.textColor = [UIColor whiteColor];
    alertLabel.backgroundColor = [UIColor colorWithRed:76/255.0 green:76/255.0 blue:76/255.0 alpha:0.9];
    alertLabel.backgroundColor = [UIColor clearColor];
    alertLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:alertLabel];
    
    alertIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    [self addSubview:alertIcon];
}

-(void)setAlertInfo:(NSString *)info
           withIcon:(UIImage *)icon{
        
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:3];
    
    //安排位置
    CGRect rect = [info boundingRectWithSize:CGSizeMake(240, MAXFLOAT)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14], NSParagraphStyleAttributeName:paragraphStyle}
                                     context:nil];
    if (icon == nil)
    {
        self.alertLabel.frame = rect;
        self.alertLabel.center = self.center;
        self.alertLabel.text = info;
        self.alertBk.frame = CGRectInset(rect, -20, -15);
        self.alertBk.center = self.center;
        self.alertIcon.hidden = YES;
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:self.alertLabel.text];
        [str addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.alertLabel.text.length)];
        self.alertLabel.attributedText = str;
        self.alertLabel.textAlignment = NSTextAlignmentCenter;
    }
    else
    {
        if (rect.size.width < 90)
            rect.size.width = 90;
        self.alertLabel.text = info;
        self.alertBk.frame = CGRectMake(0, 0, rect.size.width + 20, rect.size.height + 30 + icon.size.height);
        if (self.alertBk.frame.size.width < icon.size.width + 20)
            self.alertBk.frame = CGRectMake(0, 0, icon.size.width + 20, self.alertBk.frame.size.height);
        self.alertBk.center = self.center;
        self.alertIcon.hidden = NO;
        self.alertIcon.frame = CGRectMake(0, 0, icon.size.width, icon.size.height);
        self.alertIcon.image = icon;
        self.alertIcon.center = CGPointMake(self.frame.size.width / 2, self.alertBk.frame.origin.y + 10 + icon.size.height / 2);
        self.alertLabel.frame = rect;
        self.alertLabel.center = CGPointMake(self.frame.size.width / 2, self.alertBk.frame.origin.y + 10 + icon.size.height + 10 + rect.size.height / 2);
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:self.alertLabel.text];
        [str addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.alertLabel.text.length)];
        self.alertLabel.attributedText = str;
        self.alertLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    [self performSelector:@selector(releseAlert) withObject:nil afterDelay:self.duration-0.5];
}

-(void)releseAlert{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    self.alpha = 0;
    [UIView commitAnimations];
    
    [self performSelector:@selector(removeAlert) withObject:nil afterDelay:0.5];
}

-(void)removeAlert{
    
    [self removeFromSuperview ];
}

@end
