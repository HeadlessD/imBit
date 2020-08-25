//
//  WPMenuHrizontal.m
//  BiChat
//
//  Created by 张迅 on 2018/4/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPMenuHrizontal.h"

@implementation WPMenuHrizontal

#define BUTTONITEMWIDTH   70
#define kBtnTag 123

- (id)initWithFrame:(CGRect)frame ButtonItems:(NSArray *)aItemsArray
{
    self = [super initWithFrame:frame];
    if (self) {
        itemWidth = frame.size.width;
        if (mButtonArray == nil) {
            mButtonArray = [[NSMutableArray alloc] init];
        }
        if (mScrollView == nil) {
            mScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            mScrollView.showsHorizontalScrollIndicator = NO;
        }
        if (mItemInfoArray == nil) {
            mItemInfoArray = [[NSMutableArray alloc]init];
        }
        [mItemInfoArray removeAllObjects];
        [self createMenuItems:aItemsArray];
    }
    return self;
}

- (void)fillItems:(NSArray *)array {
    [mButtonArray removeAllObjects];
    for (UIButton *button in mScrollView.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            [button removeFromSuperview];
        }
    }
    [self createMenuItems:array];
}

-(void)createMenuItems:(NSArray *)aItemsArray{
    float menuWidth = 10;
    UIFont *buttonTitleFont = Font(17);
    float totalWidth = 0;
    for (int i = 0; i< aItemsArray.count; i++ ) {
        NSString *vTitleStr = [aItemsArray objectAtIndex:i];
        CGSize titleS = [vTitleStr boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : buttonTitleFont} context:NULL].size;
        float vButtonWidth = titleS.width + 20;
        totalWidth += vButtonWidth;
    }
    if (totalWidth - 10 < itemWidth) {
        menuWidth = (itemWidth - totalWidth + 10) / 2.0;
    }
    
    for (int i = 0; i< aItemsArray.count; i++ ) {
        NSString *vTitleStr = [aItemsArray objectAtIndex:i];
        CGSize titleS = [vTitleStr boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : buttonTitleFont} context:NULL].size;
        float vButtonWidth = titleS.width + 10;
        UIButton *vButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [vButton setTitle:vTitleStr forState:UIControlStateNormal];
        vButton.titleLabel.font = buttonTitleFont;
        [vButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        if (self.normalColor) {
            [vButton setTitleColor:self.normalColor forState:UIControlStateNormal];
        }
        [vButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        if (self.hightLightColor) {
            [vButton setTitleColor:self.hightLightColor forState:UIControlStateNormal];
        }
        [vButton setTag:i + kBtnTag];
        [vButton addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [vButton setFrame:CGRectMake(menuWidth, 0, vButtonWidth, self.frame.size.height)];
        [mScrollView addSubview:vButton];
        [mButtonArray addObject:vButton];
        vButtonWidth += 10;
        menuWidth += vButtonWidth;
        [mItemInfoArray addObject:[NSNumber numberWithFloat:menuWidth]];
        if (i == 0) {
            [self menuButtonClicked:vButton];
        }
    }
    [mScrollView setContentSize:CGSizeMake(menuWidth - 10, self.frame.size.height)];
    [self addSubview:mScrollView];
    mTotalWidth = menuWidth;
}

- (void)setShowLine:(BOOL)showLine {
    if (showLine) {
        if (!lineV) {
            lineV = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)];
            lineV.backgroundColor = RGB(0x2fb6fa);
            [self addSubview:lineV];
        }
        lineV.hidden = NO;
    } else {
        lineV.hidden = YES;
    }
}

- (void)setShowSlider:(BOOL)showSlider {
    _showSlider = showSlider;
    if (showSlider) {
        if (!self.sliderView) {
            UIButton *button = [mScrollView viewWithTag:kBtnTag];
            self.sliderView = [[UIView alloc]initWithFrame:CGRectMake(button.frame.origin.x + 5, self.frame.size.height - 3, button.frame.size.width - 10, 3)];
            self.sliderView.backgroundColor = [UIColor blackColor];
            [mScrollView addSubview:self.sliderView];
            self.sliderView.hidden = NO;
        }
    } else {
        self.sliderView.hidden = YES;
    }
    
}

- (void)setNormalColor:(UIColor *)normalColor {
    for (UIButton *button in mButtonArray) {
        [button setTitleColor:normalColor forState:UIControlStateNormal];
    }
}

- (void)setHightLightColor:(UIColor *)hightLightColor {
    _hightLightColor = hightLightColor;
    for (UIButton *button in mButtonArray) {
        [button setTitleColor:hightLightColor forState:UIControlStateSelected];
    }
}

#pragma mark - 其他辅助功能
#pragma mark 取消所有button点击状态
-(void)changeButtonsToNormalState{
    for (UIButton *vButton in mButtonArray) {
        vButton.selected = NO;
    }
}

#pragma mark 模拟选中第几个button
-(void)clickButtonAtIndex:(NSInteger)aIndex needBlock:(BOOL)needBlock{
    UIButton *vButton = [mButtonArray objectAtIndex:aIndex];
    [self removeRedPointAtIndex:aIndex button:nil];
    if (needBlock) {
        self.sliderView.frame = CGRectMake(vButton.frame.origin.x + 5, self.frame.size.height - 3, vButton.frame.size.width - 10, 3);
        [self changeButtonStateAtIndex:vButton.tag - kBtnTag];
        if (self.SelectBlock) {
            self.SelectBlock(vButton.tag - kBtnTag);
        }
    } else {
        [self menuButtonWithoutBlockClicked:vButton];
    }
}
#pragma mark 改变第几个button为选中状态，不发送delegate
-(void)changeButtonStateAtIndex:(NSInteger)aIndex{
    UIButton *vButton = [mButtonArray objectAtIndex:aIndex];
    [self changeButtonsToNormalState];
    vButton.selected = YES;
    [self moveScrolViewWithIndex:aIndex];
}
#pragma mark 移动button到可视的区域
-(void)moveScrolViewWithIndex:(NSInteger)aIndex{
    if (mItemInfoArray.count < aIndex) {
        return;
    }
    if (mTotalWidth <= itemWidth) {
        return;
    }
    float vButtonOrigin =  [[mItemInfoArray objectAtIndex:aIndex]floatValue];
    if (vButtonOrigin >= itemWidth / 2.0) {
        if ((vButtonOrigin + itemWidth / 2.0) >= mScrollView.contentSize.width) { //
            [mScrollView setContentOffset:CGPointMake(mScrollView.contentSize.width - itemWidth  , mScrollView.contentOffset.y) animated:YES];
            return;
        }
        float vMoveToContentOffset = vButtonOrigin - itemWidth / 2.0 ;
        if (vMoveToContentOffset > 0) {
            [mScrollView setContentOffset:CGPointMake(vMoveToContentOffset, mScrollView.contentOffset.y) animated:YES];
        }
    }else{
        [mScrollView setContentOffset:CGPointMake(0, mScrollView.contentOffset.y) animated:YES];
        return;
    }
}
#pragma mark - 点击事件
-(void)menuButtonClicked:(UIButton *)aButton {
    if (self.showSlider) {
        WEAKSELF;
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.sliderView.frame = CGRectMake(aButton.frame.origin.x + 5, self.frame.size.height - 3, aButton.frame.size.width - 10, 3);
        }];
    }
    [self changeButtonStateAtIndex:aButton.tag - kBtnTag];
    if (self.SelectBlock) {
        self.SelectBlock(aButton.tag - kBtnTag);
    }
    [self removeRedPointAtIndex:0 button:aButton];
}
-(void)menuButtonWithoutBlockClicked:(UIButton *)aButton {
    if (self.showSlider) {
        WEAKSELF;
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.sliderView.frame = CGRectMake(aButton.frame.origin.x + 5, self.frame.size.height - 3, aButton.frame.size.width - 10, 3);
        }];
    }
    [self changeButtonStateAtIndex:aButton.tag - kBtnTag];
    [self removeRedPointAtIndex:0 button:aButton];
}



-(void)dealloc{
    [mButtonArray removeAllObjects];
    mButtonArray = nil;
}

- (void)showRedPointAtIndex:(NSInteger)index {
    UIButton *button = [mScrollView viewWithTag:kBtnTag + index];
    UIView *view = [button viewWithTag:button.tag + kBtnTag];
    if (view) {
        return;
    }
    UIView *redV = [[UIView alloc] init];
    redV.layer.cornerRadius = 5;
    [button addSubview:redV];
    redV.backgroundColor = [UIColor redColor];
    redV.tag = button.tag + kBtnTag;
    [redV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(button).offset(7);
        make.right.equalTo(button).offset(3);
        make.width.height.equalTo(@10);
    }];
}

- (void)removeRedPointAtIndex:(NSInteger)index button:(UIButton *)button{
    if (button) {
        UIView *view = [button viewWithTag:button.tag + kBtnTag];
        [view removeFromSuperview];
        view = nil;
    } else {
        UIButton *btn = [mScrollView viewWithTag:kBtnTag + index];
        UIView *view = [btn viewWithTag:btn.tag + kBtnTag];
        [view removeFromSuperview];
        view = nil;
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
