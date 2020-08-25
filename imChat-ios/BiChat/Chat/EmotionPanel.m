//
//  EmotionPanel.m
//  BiChat
//
//  Created by worm_kc on 2018/7/10.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "EmotionPanel.h"

@implementation EmotionPanel

@synthesize inputTextField = _inputTextField;
@synthesize inputTextView = _inputTextView;

- (id)initWithFrame:(CGRect)frame
{
    frame.size.height = 220;
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor colorWithWhite:.98 alpha:1];
    [self initData];
    [self initGUI];
    [self fleshCurrentSelectedEmotionType];
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)initData
{
}

- (void)initGUI
{
    scroll4EmotionSelector = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 70)];
    scroll4EmotionSelector.backgroundColor = [UIColor clearColor];
    scroll4EmotionSelector.pagingEnabled = YES;
    scroll4EmotionSelector.delegate = self;
    scroll4EmotionSelector.showsHorizontalScrollIndicator = NO;
    scroll4EmotionSelector.showsVerticalScrollIndicator = NO;
    [self addSubview:scroll4EmotionSelector];
    
    page4EmotionSelector = [[UIPageControl alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 70, self.frame.size.width, 20)];
    page4EmotionSelector.currentPage = 0;
    page4EmotionSelector.numberOfPages = 5;
    page4EmotionSelector.pageIndicatorTintColor = [UIColor colorWithWhite:.9 alpha:1];
    page4EmotionSelector.currentPageIndicatorTintColor = THEME_GRAY;
    [self addSubview:page4EmotionSelector];
    
    scroll4EmotionTypeSelector = [[UIScrollView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 50, self.frame.size.width - 70, 50)];
    scroll4EmotionTypeSelector.backgroundColor = [UIColor whiteColor];
    [self addSubview:scroll4EmotionTypeSelector];
    
    button4Emotion = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    [button4Emotion setImage:[UIImage imageNamed:@"emotiontype_smile"] forState:UIControlStateNormal];
    [button4Emotion addTarget:self action:@selector(onButtonTypeEmotion:) forControlEvents:UIControlEventTouchUpInside];
    //[scroll4EmotionTypeSelector addSubview:button4Emotion];
    
    button4Send = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 70, self.frame.size.height - 50, 70, 50)];
    button4Send.backgroundColor = [UIColor whiteColor];
    button4Send.titleLabel.font = [UIFont systemFontOfSize:16];
    [button4Send setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [button4Send setTitle:LLSTR(@"101021") forState:UIControlStateNormal];
    [button4Send addTarget:self action:@selector(onButtonSend:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button4Send];
    
    //分割线
    UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 50, self.frame.size.width, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
    [self addSubview:view4Seperator];
    
    view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(self.frame.size.width - 70, self.frame.size.height - 50, 0.5, 50)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
    [self addSubview:view4Seperator];
    
    if (isIphonex)
    {
        CGRect frame = self.frame;
        frame.size.height = 250;
        self.frame = frame;
    }
}

- (void)fleshCurrentSelectedEmotionType
{
    //清理现场
    for (UIView *subView in [scroll4EmotionSelector subviews])
        [subView removeFromSuperview];
        
    //计算有几个常用表情
    array4FrequentlyUsedEmotion = [NSMutableArray array];
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *item in [BiChatGlobal sharedManager].array4UserFrequentlyUsedEmotions)
    {
        if ([[item objectForKey:@"count"]integerValue] > 0)
            [array addObject:item];
    }
    [array sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return ([[obj1 objectForKey:@"count"]integerValue] < [[obj2 objectForKey:@"count"]integerValue]);
    }];

    for (int i = 0; i < array.count; i ++)
    {
        if (i >= 9) break;
        NSString *str = [[array objectAtIndex:i]objectForKey:@"name"];
        for (NSDictionary *item in [BiChatGlobal sharedManager].array4AllDefaultEmotions)
        {
            if ([str isEqualToString:[item objectForKey:@"chinese"]] ||
                [str isEqualToString:[item objectForKey:@"english"]])
            {
                [array4FrequentlyUsedEmotion addObject:item];
            }
        }
    }
    
    //计算
    NSInteger numberOfEmotionsPerLine = (self.frame.size.width - 30) / 40;
    CGFloat buttonWidth = (self.frame.size.width - 30) / numberOfEmotionsPerLine;
    NSInteger numberOfEmotionsPerPage = numberOfEmotionsPerLine * 3;
    
    //第一种排版
    if (array4FrequentlyUsedEmotion.count == 0)
    {
        NSInteger pages = [BiChatGlobal sharedManager].array4AllDefaultEmotions.count / numberOfEmotionsPerPage + ([BiChatGlobal sharedManager].array4AllDefaultEmotions.count % numberOfEmotionsPerPage==0?0:1);
        page4EmotionSelector.numberOfPages = pages;
        scroll4EmotionSelector.contentSize = CGSizeMake(self.frame.size.width * pages, scroll4EmotionSelector.frame.size.height);

        //开始安排
        for (int i = 0; i < pages; i ++)
        {
            for (int j = 0; j < 3; j ++)
            {
                for (int k = 0; k < numberOfEmotionsPerLine; k ++)
                {
                    NSInteger index = i * numberOfEmotionsPerPage + j * numberOfEmotionsPerLine + k - i;
                    
                    if (j == 2 && k == numberOfEmotionsPerLine - 1)
                    {
                        UIButton *button4Backspace = [[UIButton alloc]initWithFrame:CGRectMake(i * self.frame.size.width + (numberOfEmotionsPerLine - 1) * buttonWidth + 15, 100, buttonWidth, 45)];
                        [button4Backspace setImage:[UIImage imageNamed:@"backspace"] forState:UIControlStateNormal];
                        [button4Backspace addTarget:self action:@selector(onButtonBackspace:) forControlEvents:UIControlEventTouchUpInside];
                        [scroll4EmotionSelector addSubview:button4Backspace];
                    }
                    else
                    {
                        if (index >= [BiChatGlobal sharedManager].array4AllDefaultEmotions.count)
                            continue;
                        //崩溃
                        UIButton *button4Emotion = [[UIButton alloc]initWithFrame:CGRectMake(i * self.frame.size.width + k * buttonWidth + 15,
                                                                                             10 + j * 45,
                                                                                             buttonWidth,
                                                                                             45)];
                        button4Emotion.tag = index;
                        [button4Emotion setImage:[UIImage imageNamed:[[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:index]objectForKey:@"name"]] forState:UIControlStateNormal];
                        [button4Emotion addTarget:self action:@selector(onButtonEmotion:) forControlEvents:UIControlEventTouchUpInside];
                        [scroll4EmotionSelector addSubview:button4Emotion];
                    }
                }
            }
        }
    }
    
    //第二种排版
    else
    {
        NSInteger frequentlyUsedEmotionColumn = array4FrequentlyUsedEmotion.count / 3 + (array4FrequentlyUsedEmotion.count % 3 == 0?0:1);
        NSInteger count = [BiChatGlobal sharedManager].array4AllDefaultEmotions.count + (frequentlyUsedEmotionColumn + 1) * 3;
        NSInteger pages = count / numberOfEmotionsPerPage + (count % numberOfEmotionsPerPage==0?0:1);
        page4EmotionSelector.numberOfPages = pages;
        scroll4EmotionSelector.contentSize = CGSizeMake(self.frame.size.width * pages, scroll4EmotionSelector.frame.size.height);
        
        //第一页，先安排常用的表情
        CGRect rect = [LLSTR(@"101034")boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
        UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15 + buttonWidth / 2 - 15, 0, rect.size.width, 15)];
        label4Title.text = LLSTR(@"101034");
        label4Title.font = [UIFont systemFontOfSize:12];
        label4Title.textColor = THEME_GRAY;
        label4Title.textAlignment = NSTextAlignmentCenter;
        [scroll4EmotionSelector addSubview:label4Title];
        
        for (int i = 0; i < 3; i ++)
        {
            for (int j = 0; j < frequentlyUsedEmotionColumn; j ++)
            {
                NSInteger index = frequentlyUsedEmotionColumn * i + j;
                if (index >= array4FrequentlyUsedEmotion.count)
                    break;
                
                //常用表情按钮
                UIButton *button4FrequentlyUsedEmotion = [[UIButton alloc]initWithFrame:CGRectMake(15 + j * buttonWidth, 10 + i * 45, buttonWidth, 45)];
                button4FrequentlyUsedEmotion.tag = index;
                [button4FrequentlyUsedEmotion setImage:[UIImage imageNamed:[[array4FrequentlyUsedEmotion objectAtIndex:index]objectForKey:@"name"]] forState:UIControlStateNormal];
                [button4FrequentlyUsedEmotion addTarget:self action:@selector(onButtonFrequentlyUsedEmotion:) forControlEvents:UIControlEventTouchUpInside];
                [scroll4EmotionSelector addSubview:button4FrequentlyUsedEmotion];
            }
        }
        
        //竖线
        UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(15 + frequentlyUsedEmotionColumn * buttonWidth + buttonWidth / 2, 25, 0.5, 100)];
        view4Seperator.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
        [scroll4EmotionSelector addSubview:view4Seperator];
        
        //再安排普通表情
        for (int i = 0; i < 3; i ++)
        {
            for (int j = 0; j < numberOfEmotionsPerLine - frequentlyUsedEmotionColumn - 1; j ++)
            {
                NSInteger index =(numberOfEmotionsPerLine - frequentlyUsedEmotionColumn - 1) * i + j;
                
                //是不是需要放置回退按钮
                if (i == 2 && j == numberOfEmotionsPerLine - frequentlyUsedEmotionColumn - 2)
                {
                    UIButton *button4Backspace = [[UIButton alloc]initWithFrame:CGRectMake((numberOfEmotionsPerLine - 1) * buttonWidth + 15, 100, buttonWidth, 45)];
                    [button4Backspace setImage:[UIImage imageNamed:@"backspace"] forState:UIControlStateNormal];
                    [button4Backspace addTarget:self action:@selector(onButtonBackspace:) forControlEvents:UIControlEventTouchUpInside];
                    [scroll4EmotionSelector addSubview:button4Backspace];
                }
                else
                {
                    if (index >= [BiChatGlobal sharedManager].array4AllDefaultEmotions.count)
                        continue;

                    CGRect cg = CGRectMake(15 + (frequentlyUsedEmotionColumn + 1 + j) *  buttonWidth ,
                                           10 + i * 45, buttonWidth, 45);

                    //表情按钮
                    UIButton *button4Emotion = [[UIButton alloc]initWithFrame:cg];
                    button4Emotion.tag = index;
                    [button4Emotion setImage:[UIImage imageNamed:[[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:index]objectForKey:@"name"]] forState:UIControlStateNormal];
                    [button4Emotion addTarget:self action:@selector(onButtonEmotion:) forControlEvents:UIControlEventTouchUpInside];
                    [scroll4EmotionSelector addSubview:button4Emotion];
                }
            }
        }
        
        //再安排后面的页
        for (int i = 1; i < pages; i ++)
        {
            for (int j = 0; j < 3; j ++)
            {
                for (int k = 0; k < numberOfEmotionsPerLine; k ++)
                {
                    NSInteger index = i * numberOfEmotionsPerPage + j * numberOfEmotionsPerLine + k - (frequentlyUsedEmotionColumn + 1) * 3 - i;
                    
                    //是不是需要放置回退按钮
                    if (j == 2 && k == numberOfEmotionsPerLine - 1)
                    {
                        UIButton *button4Backspace = [[UIButton alloc]initWithFrame:CGRectMake(i * self.frame.size.width + (numberOfEmotionsPerLine - 1) * buttonWidth + 15, 100, buttonWidth, 45)];
                        [button4Backspace setImage:[UIImage imageNamed:@"backspace"] forState:UIControlStateNormal];
                        [button4Backspace addTarget:self action:@selector(onButtonBackspace:) forControlEvents:UIControlEventTouchUpInside];
                        [scroll4EmotionSelector addSubview:button4Backspace];
                    }
                    else
                    {
                        if (index >= [BiChatGlobal sharedManager].array4AllDefaultEmotions.count)
                            continue;

                        CGRect cg = CGRectMake(i * self.frame.size.width + k * buttonWidth + 15,10 + j * 45,buttonWidth,45);
                        
                        //表情按钮
                        UIButton *button4Emotion = [[UIButton alloc]initWithFrame:cg];
                        button4Emotion.tag = index;
                        [button4Emotion setImage:[UIImage imageNamed:[[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:index]objectForKey:@"name"]] forState:UIControlStateNormal];
                        [button4Emotion addTarget:self action:@selector(onButtonEmotion:) forControlEvents:UIControlEventTouchUpInside];
                        [scroll4EmotionSelector addSubview:button4Emotion];
                    }
                }
            }
        }
    }
}

- (void)onButtonSend:(id)sender
{
    if (self.inputTextView)
    {
        [self.inputTextView.delegate textView:self.inputTextView shouldChangeTextInRange:self.inputTextView.selectedRange replacementText:@"\n"];
    }
}

- (void)onButtonTypeEmotion:(id)sender
{
}

- (void)onButtonFrequentlyUsedEmotion:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger index = button.tag;

    if (index >= array4FrequentlyUsedEmotion.count)
        return;
    
    //开始通知
    NSString *str = [[array4FrequentlyUsedEmotion objectAtIndex:index]objectForKey:@"chinese"];
    if (![[DFLanguageManager getLanguageName]isEqualToString:@"zh-CN"])
        str = [[array4FrequentlyUsedEmotion objectAtIndex:index]objectForKey:@"english"];
    
    if (self.inputTextView)
    {
        //NSMutableString *faceString = [[NSMutableString alloc]initWithString:self.inputTextView.text];
        //[faceString appendString:[_faceMap objectForKey:[NSString stringWithFormat:@"%03d", i]]];
        //
        //EmotionTextAttachment *emotionTextAttachment = [EmotionTextAttachment new];
        //emotionTextAttachment.emotionStr = [_faceMap objectForKey:[NSString stringWithFormat:@"%03d", i]];
        //emotionTextAttachment.image = [UIImage imageNamed:[NSString stringWithFormat:@"%03d", i]];
        ////存储光标位置
        //location = (int)self.inputTextView.selectedRange.location;
        ////插入表情
        //[self.inputTextView.textStorage insertAttributedString:[NSAttributedString attributedStringWithAttachment:emotionTextAttachment] atIndex:self.inputTextView.selectedRange.location];
        ////光标位置移动1个单位
        //self.inputTextView.selectedRange = NSMakeRange(location+1, 0);
        
        if ([self.inputTextView.delegate textView:self.inputTextView shouldChangeTextInRange:self.inputTextView.selectedRange replacementText:str])
        {
            self.inputTextView.text = [self.inputTextView.text stringByReplacingCharactersInRange:self.inputTextView.selectedRange withString:str];
            [self.inputTextView.delegate textViewDidChange:self.inputTextView];
            
            //记录一下这次使用
            [[BiChatGlobal sharedManager]useEmotion:str];
        }
    }
}

- (void)onButtonEmotion:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger index = button.tag;
    
    if (index >= [BiChatGlobal sharedManager].array4AllDefaultEmotions.count)
        return;
    
    //开始通知
    NSString *str = [[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:index]objectForKey:@"chinese"];
    if (![[DFLanguageManager getLanguageName]isEqualToString:@"zh-CN"])
        str = [[[BiChatGlobal sharedManager].array4AllDefaultEmotions objectAtIndex:index]objectForKey:@"english"];

    if (self.inputTextView)
    {
        //NSMutableString *faceString = [[NSMutableString alloc]initWithString:self.inputTextView.text];
        //[faceString appendString:[_faceMap objectForKey:[NSString stringWithFormat:@"%03d", i]]];
        //
        //EmotionTextAttachment *emotionTextAttachment = [EmotionTextAttachment new];
        //emotionTextAttachment.emotionStr = [_faceMap objectForKey:[NSString stringWithFormat:@"%03d", i]];
        //emotionTextAttachment.image = [UIImage imageNamed:[NSString stringWithFormat:@"%03d", i]];
        ////存储光标位置
        //location = (int)self.inputTextView.selectedRange.location;
        ////插入表情
        //[self.inputTextView.textStorage insertAttributedString:[NSAttributedString attributedStringWithAttachment:emotionTextAttachment] atIndex:self.inputTextView.selectedRange.location];
        ////光标位置移动1个单位
        //self.inputTextView.selectedRange = NSMakeRange(location+1, 0);
        
        if ([self.inputTextView.delegate textView:self.inputTextView shouldChangeTextInRange:self.inputTextView.selectedRange replacementText:str])
        {
            self.inputTextView.text = [self.inputTextView.text stringByReplacingCharactersInRange:self.inputTextView.selectedRange withString:str];
            [self.inputTextView.delegate textViewDidChange:self.inputTextView];
            
            //记录一下这次使用
            [[BiChatGlobal sharedManager]useEmotion:str];
        }
    }
}

- (void)onButtonBackspace:(id)sender
{
    if (self.inputTextView)
    {
        //光标在最前方
        if (self.inputTextView.selectedRange.length == 0 &&
            self.inputTextView.selectedRange.location == 0)
            return;
        
        //开始删除,有选择
        if (self.inputTextView.selectedRange.length > 0)
        {
            if ([self.inputTextView.delegate textView:self.inputTextView shouldChangeTextInRange:self.inputTextView.selectedRange replacementText:@""])
                self.inputTextView.text = [self.inputTextView.text stringByReplacingCharactersInRange:self.inputTextView.selectedRange withString:@""];
            return;
        }
        
        //无选择
        NSRange range = NSMakeRange(self.inputTextView.selectedRange.location - 1, 1);
        
        //判断是不是emoji，一个emoji字符的长度是2
        if (range.location > 0)
        {
            unichar c = [self.inputTextView.text characterAtIndex:range.location - 1];
            if (c >= 0xd800 && c <= 0xdbff)
            {
                range.location = range.location - 1;
                range.length = 2;
            }
        }
        
        if ([self.inputTextView.delegate textView:self.inputTextView shouldChangeTextInRange:range replacementText:@""])
        {
            self.inputTextView.text = [self.inputTextView.text stringByReplacingCharactersInRange:range withString:@""];
            self.inputTextView.selectedRange = NSMakeRange(range.location, 0);
            [self.inputTextView.delegate textViewDidChange:self.inputTextView];
        }
    }
}

#pragma mark - UIScrollViewDelegate functions

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == scroll4EmotionSelector)
    {
        page4EmotionSelector.currentPage = (scroll4EmotionSelector.contentOffset.x + self.frame.size.width / 2) / self.frame.size.width;
    }
}

@end
