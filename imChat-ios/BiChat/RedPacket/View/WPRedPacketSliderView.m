//
//  WPRedPacketSliderView.m
//  BiChat
//
//  Created by 张迅 on 2018/6/7.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPRedPacketSliderView.h"

@interface WPRedPacketSliderView()
{
    NSString *value;
}
@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *left;
@property (nonatomic, strong) NSArray *valueArray;
@end

@implementation WPRedPacketSliderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithSubView];
    }
    return self;
}

- (void) initWithSubView{
    
    _valueArray = @[@"10",@"20",@"30",@"40",@"50",@"60",@"70",@"80",@"90"];
    [self addSubview:self.lineView];
    [self setpUI];
    [self addSubview:self.leftView];
    
    [self addSubview:self.left];
}

- (void)setpUI{
    
    UIView *viewT = [UIView new];
    viewT.frame = CGRectMake(5, self.lineView.frame.origin.y - 5, 2, 5);
    viewT.backgroundColor = [UIColor orangeColor];
    [self addSubview:viewT];
    
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0,0 , 60, 30)];
    lable.text = @"0";
    lable.textColor = [UIColor redColor];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.font = [UIFont systemFontOfSize:12];
    lable.center = CGPointMake(viewT.center.x, viewT.center.y - 10);
    [self addSubview:lable];
    
    for (int i = 1; i <= _valueArray.count ; i ++) {
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0,0 , 60, 30)];
        lable.text = _valueArray[i -1];
        lable.textColor = [UIColor redColor];
        lable.textAlignment = NSTextAlignmentCenter;
        lable.font = [UIFont systemFontOfSize:12];
        [self addSubview:lable];
    }
}

#pragma mark - 懒加载
- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(5, self.frame.size.height - 10, self.frame.size.width -10, 2)];
        _lineView.backgroundColor  = [UIColor blueColor];
    }
    
    return _lineView;
}


- (UIView *)left{
    if (!_left) {
        _left = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _left.center = CGPointMake(self.lineView.frame.origin.x, self.lineView.frame.origin.y);
        _left.layer.cornerRadius = 5;
        _left.layer.masksToBounds = YES;
        _left.backgroundColor = [UIColor redColor];
        
        _left.alpha = 1;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(leftPanEvent:)];
        [_left addGestureRecognizer:pan];
    }
    return _left;
}
- (UIView *)leftView{
    if (!_leftView) {
        _leftView = [[UIView alloc] initWithFrame:CGRectMake(self.lineView.frame.origin.x, self.lineView.frame.origin.y, 0, 2)];
        _leftView.backgroundColor = [UIColor blackColor];
    }
    return _leftView;
}

#pragma mark - 滑动事件
- (void)leftPanEvent:(UIPanGestureRecognizer *)gesture{
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint offset = [gesture translationInView:self];
        CGFloat y = gesture.view.center.y;
        CGFloat x = gesture.view.center.x +offset.x;
        
        if (x <self.lineView.frame.origin.x) {
            x = self.lineView.frame.origin.x;
        }
        if (x > self.lineView.frame.size.width) {
            x = self.lineView.frame.size.width;
        }
        
        gesture.view.center = CGPointMake(x, y);
        [gesture setTranslation:CGPointMake(0, 0) inView:self];
        self.leftView.frame = CGRectMake(self.leftView.frame.origin.x, self.leftView.frame.origin.y, x, self.leftView.frame.size.height);
        

    }else if(gesture.state == UIGestureRecognizerStateEnded){
//        if (self.delegate && [self.delegate respondsToSelector:@selector(choicePriceViewGetMinMoney:maxMoney:)]) {
//            [self.delegate choicePriceViewGetMinMoney:minMoney maxMoney:maxMoney];
//        }
    }
}

@end
