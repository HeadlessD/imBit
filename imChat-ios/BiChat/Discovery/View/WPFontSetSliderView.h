//
//  WPFontSetSliderView.h
//  BiChat
//
//  Created by iMac on 2018/10/30.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WPFontSetSliderView : UIView

@property (nonatomic,strong)UIView *whiteView;
@property (nonatomic,strong)UIImageView *sliderView;

@property (nonatomic,assign)BOOL isSlider;

@property (nonatomic,assign)NSUInteger zoomValue;

@property (nonatomic,copy)void (^SliderBlock)(NSUInteger value);
@property (nonatomic,copy)void (^SliderRemoveBlock)(void);

@end

