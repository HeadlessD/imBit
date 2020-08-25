//
//  WPMenuHrizontal.h
//  BiChat
//
//  Created by 张迅 on 2018/4/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NOMALKEY   @"normalKey"
#define HEIGHTKEY  @"helightKey"
#define TITLEKEY   @"titleKey"
#define TITLEWIDTH @"titleWidth"
#define TOTALWIDTH @"totalWidth"

@interface WPMenuHrizontal : UIView {
    NSMutableArray        *mButtonArray;
    NSMutableArray        *mItemInfoArray;
    UIScrollView          *mScrollView;
    float                 mTotalWidth;
    UIView                *lineV;
    float                 itemWidth;
}

@property (nonatomic,copy)void (^SelectBlock)(NSInteger selectId);
@property (nonatomic,assign)BOOL showLine;
@property (nonatomic,assign)BOOL showSlider;
@property (nonatomic,assign)BOOL showAnimated;
@property (nonatomic,strong)UIView *sliderView;

@property (nonatomic,strong)UIColor *normalColor;
@property (nonatomic,strong)UIColor *hightLightColor;

#pragma mark 初始化菜单
- (id)initWithFrame:(CGRect)frame ButtonItems:(NSArray *)aItemsArray;

#pragma mark 选中某个button
-(void)clickButtonAtIndex:(NSInteger)aIndex needBlock:(BOOL)needBlock;

#pragma mark 改变第几个button为选中状态，不发送delegate
-(void)changeButtonStateAtIndex:(NSInteger)aIndex;

- (void)fillItems:(NSArray *)array;
-(void)menuButtonClicked:(UIButton *)aButton;
-(void)menuButtonWithoutBlockClicked:(UIButton *)aButton;

//显示红点
- (void)showRedPointAtIndex:(NSInteger)index;
//隐藏红点
- (void)removeRedPointAtIndex:(NSInteger)index button:(UIButton *)button;
@end
