//
//  WPTextFieldView.h
//  BiChat
//
//  Created by iMac on 2018/6/28.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WPTextFieldView : UIView <UITextFieldDelegate>

@property (nonatomic,strong)UITextField *tf;
@property (nonatomic,strong)UIView *lineV;
@property (nonatomic,strong)UILabel *countlabel;

@property (nonatomic,assign)NSInteger limitCount;

@property (nonatomic,strong)UIFont *font;

@property (nonatomic,copy)void (^EditBlock)(UITextField *tf);

- (void)textFieldDidChange:(UITextField *)textField;

- (void)setText:(NSString *)text;

@end
