//
//  WPShareView.h
//  BiChat
//
//  Created by 张迅 on 2018/5/2.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WPShareView : UIView <UITextViewDelegate>

@property (nonatomic,strong)UIView *backView;
@property (nonatomic,strong)UIImageView *headIV;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UILabel *contentLabel;
@property (nonatomic,strong)UITextView *messageTV;
@property (nonatomic,strong)UILabel *sendLabel;
@property (nonatomic,assign)BOOL hasChange;

@property (nonatomic,strong)NSString *sendString;
@property (nonatomic,strong)NSString *avatar;
@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSString *content;


@property (nonatomic)void (^ChooseItemBlock)(NSInteger chooseStatus,NSString *content);

@end
