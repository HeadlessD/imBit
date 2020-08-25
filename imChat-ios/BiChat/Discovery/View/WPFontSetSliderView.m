//
//  WPFontSetSliderView.m
//  BiChat
//
//  Created by iMac on 2018/10/30.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "WPFontSetSliderView.h"

@implementation WPFontSetSliderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self createUI];
    return self;
}

- (void)createUI {
    self.whiteView = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 150)];
    self.whiteView.backgroundColor = [UIColor whiteColor];
    self.whiteView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.whiteView.layer.shadowRadius = 2;
    self.whiteView.layer.shadowOffset = CGSizeMake(0, -3);
    self.whiteView.layer.shadowOpacity = 0.1;
    [self addSubview:self.whiteView];
    
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(50, 80, ScreenWidth - 100, 1)];
    lineV.backgroundColor = [UIColor grayColor];
    [self.whiteView addSubview:lineV];
    CGFloat unitWith = (ScreenWidth - 100) / 4;
    for (int i = 0; i < 5; i++) {
        UIView *vLineV = [[UIView alloc]initWithFrame:CGRectMake(50 + unitWith * i, 76, 1, 8)];
        vLineV.backgroundColor = [UIColor grayColor];
        [self.whiteView addSubview:vLineV];
    }
    
    UILabel *sLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 40, 50, 20)];
    [self.whiteView addSubview:sLabel];
    sLabel.text = @"A";
    sLabel.font = Font(12);
    sLabel.textAlignment = NSTextAlignmentCenter;
    
    UILabel *suitLabel = [[UILabel alloc]initWithFrame:CGRectMake(50 + unitWith / 2.0, 40, unitWith, 20)];
    [self.whiteView addSubview:suitLabel];
    suitLabel.text = LLSTR(@"102218");
    suitLabel.font = Font(14);
    suitLabel.textColor = [UIColor grayColor];
    suitLabel.textAlignment = NSTextAlignmentCenter;
    
    UILabel *bLabel = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 75, 40, 50, 20)];
    [self.whiteView addSubview:bLabel];
    bLabel.text = @"A";
    bLabel.font = Font(20);
    bLabel.textAlignment = NSTextAlignmentCenter;
    
    
    
    self.sliderView = [[UIImageView alloc] init];
    self.sliderView.frame = CGRectMake(0, 0, 25, 25);
    self.sliderView.backgroundColor = [UIColor whiteColor];
    self.sliderView.layer.cornerRadius = 12.5;
    self.sliderView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.sliderView.layer.shadowRadius = 2;
    self.sliderView.layer.shadowOffset = CGSizeMake(0, 0);
    self.sliderView.layer.shadowOpacity = 0.5;
    [self.whiteView addSubview:self.sliderView];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"webSliderValue"] integerValue]) {
        NSInteger value = [[[NSUserDefaults standardUserDefaults] objectForKey:@"webSliderValue"] integerValue];
        self.sliderView.center = CGPointMake(50 + value * unitWith, 80);
    } else {
        self.sliderView.center = CGPointMake(50 + unitWith, 80);
    }
    
    self.sliderView.userInteractionEnabled = YES;
    
    
    [self showSlider];
}
//显示滑块
- (void)showSlider {
    [UIView animateWithDuration:0.26 animations:^{
        self.whiteView.frame = CGRectMake(0, ScreenHeight - 150 - (isIphonex ? 88 : 64), ScreenWidth, 150);
    }];
}

- (void)hideSlider {
    [UIView animateWithDuration:0.26 animations:^{
        self.whiteView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, 150);
    } completion:^(BOOL finished) {
        if (self.SliderRemoveBlock) {
            self.SliderRemoveBlock();
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSArray *touchArr = [touches allObjects];
    self.isSlider = NO;
    for (int i = 0; i < touchArr.count; i++) {
        UITouch *touch = touchArr[i];
        if ([touch.view isEqual:self.sliderView] || [touch.view isEqual:self.whiteView]) {
            self.isSlider = YES;
        }
        if ([touch.view isEqual:self]) {
            [self hideSlider];
        }
    }
    if (self.isSlider) {
        UITouch *touch = [touches allObjects][0];
        [self calculateValue:[touch locationInView:self.whiteView].x];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.isSlider) {
        return;
    }
    UITouch *touch = [touches allObjects][0];
    [self calculateValue:[touch locationInView:self.whiteView].x];
    
}

- (void)calculateValue:(CGFloat)value {
    if (value < 50) {
        if (self.zoomValue == 0) {
            return;
        }
        self.zoomValue = 0;
        if (self.SliderBlock) {
            self.SliderBlock(0);
        }
        self.sliderView.center = CGPointMake(50, 80);
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%ld",self.zoomValue] forKey:@"webSliderValue"];
        return;
    }
    CGFloat unitWith = (ScreenWidth - 100) / 4;
    if (value > 50 + unitWith * 4) {
        if (self.zoomValue == 4) {
            return;
        }
        self.zoomValue = 4;
        if (self.SliderBlock) {
            self.SliderBlock(4);
        }
        self.sliderView.center = CGPointMake(50 + self.zoomValue * unitWith, 80);
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%ld",self.zoomValue] forKey:@"webSliderValue"];
        return;
    }
    int a = (value - 50) / unitWith;
    if (value - 50 - unitWith * a > unitWith / 2) {
        if (self.zoomValue != a + 1) {
            self.zoomValue = a + 1;
            if (self.SliderBlock) {
                self.SliderBlock(self.zoomValue);
            }
            self.sliderView.center = CGPointMake(50 + self.zoomValue * unitWith, 80);
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%ld",self.zoomValue] forKey:@"webSliderValue"];
        }
    } else {
        if (self.zoomValue != a) {
            self.zoomValue = a;
            if (self.SliderBlock) {
                self.SliderBlock(self.zoomValue);
            }
            self.sliderView.center = CGPointMake(50 + self.zoomValue * unitWith, 80);
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%ld",self.zoomValue] forKey:@"webSliderValue"];
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
