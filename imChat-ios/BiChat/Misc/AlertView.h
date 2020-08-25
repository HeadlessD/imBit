//
//  AlertView.h
//  福利社
//
//  Created by lugang on 8/16/13.
//  Copyright (c) 2013 lugang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertView : UIView

@property (retain, nonatomic) UIImageView *alertIcon;
@property (retain, nonatomic) UILabel *alertLabel;
@property (retain, nonatomic) UIImageView *alertBk;
@property (nonatomic) CGFloat duration;
@property (nonatomic) BOOL enableClick;

-(void)setAlertInfo:(NSString *)info withIcon:(UIImage *)icon;


@end
