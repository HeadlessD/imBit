//
//  WPTextViewView.h
//  BiChat
//
//  Created by worm_kc on 2019/1/7.
//  Copyright © 2019年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"

NS_ASSUME_NONNULL_BEGIN

@interface WPTextViewView : UIView<UITextViewDelegate>

@property (nonatomic,strong)UIPlaceHolderTextView *tf;
@property (nonatomic,strong)UIView *lineV;
@property (nonatomic,strong)UILabel *countlabel;
@property (nonatomic,assign)NSInteger limitCount;
@property (nonatomic,strong)UIFont *font;
@property (nonatomic,copy)void (^EditBlock)(UITextView *tf);
- (void)setText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
