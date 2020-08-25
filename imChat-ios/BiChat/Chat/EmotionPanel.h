//
//  EmotionPanel.h
//  BiChat
//
//  Created by worm_kc on 2018/7/10.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmotionPanel : UIView<UIScrollViewDelegate>
{
    UIScrollView *scroll4EmotionSelector;
    UIPageControl *page4EmotionSelector;
    UIScrollView *scroll4EmotionTypeSelector;
    UIButton *button4Emotion;
    UIButton *button4Send;
    
    //当前选择
    NSInteger currentSelectedEmotionType;               //0为缺省内建笑脸系列
    NSMutableArray *array4FrequentlyUsedEmotion;
}

@property (nonatomic, retain) UITextField *inputTextField;
@property (nonatomic, retain) UITextView *inputTextView;

@end
