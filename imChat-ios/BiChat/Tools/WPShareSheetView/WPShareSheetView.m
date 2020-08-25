//
//  WPShareSheetView.m
//  BiChat
//
//  Created by iMac on 2018/6/11.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#define kHeight 155
#define kBtnHeight 50
#define kMargin 15
#define kBtnTag 123

#import "WPShareSheetView.h"
#import <SDWebImage/UIView+WebCache.h>

@implementation WPShareSheetView

- (instancetype)initWithItemsArray:(NSArray *)array {
    self = [super init];
    self.contentArray = array;
    self.perPageCount = 5;
    return self;
}

- (void)show {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo([UIApplication sharedApplication].keyWindow);
    }];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doHide)];
    [self addGestureRecognizer:tapGes];
    [self createUI];
}

- (void)createUI {
    self.sheetView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, ScreenWidth, isIphonex ? kHeight + 20 : kHeight + 15 * self.contentArray.count)];
    self.sheetView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [self addSubview:self.sheetView];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(emptyMethod)];
    [self.sheetView addGestureRecognizer:tapGes];
    
    CGFloat width = (ScreenWidth - (kMargin * 6.0)) * 0.2;
    UIScrollView *lastSV = nil;
    for (int i = 0; i < self.contentArray.count; i++) {
        NSArray *array = [self.contentArray objectAtIndex:i];
        CGFloat contentWidth = (width + kMargin) * array.count + kMargin;
        UIScrollView *sv = [[UIScrollView alloc]init];
        [self.sheetView addSubview:sv];
        [sv mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastSV) {
                make.top.equalTo(lastSV.mas_bottom);
            } else {
                make.top.equalTo(self.sheetView);
            }
            make.height.equalTo(@(width + 35 + 15));
            make.left.right.equalTo (self.sheetView);
        }];
        sv.contentSize = CGSizeMake(contentWidth, width + 35 + 15);
        sv.showsHorizontalScrollIndicator = NO;
        lastSV = sv;
        CGFloat leftMargin = (ScreenWidth - (array.count > self.perPageCount ? self.perPageCount : array.count) * width) / ((array.count > self.perPageCount ? self.perPageCount : array.count) + 1);
        //一行是否少于5个
        BOOL lessLine = NO;
        for (NSArray *lineArray in self.contentArray) {
            if (lineArray.count < 5) {
                lessLine = YES;
            }
        }
        
        BOOL differentCount = NO;
        if (lessLine) {
            NSArray *singleArray = self.contentArray[0];
            if (self.contentArray.count > 1) {
                for (int i = 0; i < self.contentArray.count; i++) {
                    NSArray *countArr = self.contentArray[i];
                    if (singleArray.count != countArr.count) {
                        differentCount = YES;
                    }
                }
            }
        }
        
        if (differentCount) {
            leftMargin = kMargin;
        }
        
        for (int j = 0; j < array.count; j++) {
            WPShareSheetItem *item = array[j];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [sv addSubview:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(sv).offset(leftMargin + (width +leftMargin) * j);
                make.top.equalTo(sv).offset(15);
                make.width.equalTo(@(width));
                make.height.equalTo(@(width));
            }];
            if (self.isOnline) {
                [button sd_internalSetImageWithURL:[NSURL URLWithString:item.icon] placeholderImage:nil options:SDWebImageRetryFailed context:nil setImageBlock:nil progress:nil completed:nil];
                
//                 sd_internalSetImageWithURL:[NSURL URLWithString:item.icon] placeholderImage:nil options:SDWebImageRetryFailed operationKey:nil setImageBlock:nil progress:nil completed:nil];

            } else {
                [button setImage:Image(item.icon) forState:UIControlStateNormal];
            }
            button.tag = kBtnTag + j;
            button.layer.cornerRadius = 5;
            button.layer.masksToBounds = YES;
            button.backgroundColor = [UIColor whiteColor];
            [button addTarget:self action:@selector(btnTap:) forControlEvents:UIControlEventTouchUpInside];
            objc_setAssociatedObject(button, "firstObject", [NSString stringWithFormat:@"%d",i], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            UILabel *label = [[UILabel alloc]init];
            [sv addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(button);
                make.top.equalTo(button.mas_bottom).offset(5);
                make.height.equalTo(@30);
            }];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = item.title;
            label.numberOfLines = 2;
            label.textColor = [UIColor darkGrayColor];
            label.font = Font(11);
        }
    }
    if (!self.disableCancel) {
        UIView *whiteView = [[UIView alloc]init];
        [self.sheetView addSubview:whiteView];
        [whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.sheetView);
            make.height.equalTo(@25);
        }];
        whiteView.backgroundColor = [UIColor whiteColor];
    }
    
    
    if (!self.disableCancel) {
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.sheetView addSubview:cancelButton];
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.sheetView);
            if (isIphonex) {
                make.bottom.equalTo(self.sheetView).offset(-20);
            } else {
                make.bottom.equalTo(self.sheetView);
            }
            make.height.equalTo(@kBtnHeight);
        }];
        [cancelButton addTarget:self action:@selector(doHide) forControlEvents:UIControlEventTouchUpInside];
        cancelButton.backgroundColor = [UIColor whiteColor];
        [cancelButton setTitle:LLSTR(@"101002") forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    [self setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.3 animations:^{
        self.sheetView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - (isIphonex ? 20 : 0) - (width + 40) * self.contentArray.count - 10 - (self.disableCancel ? 0 : 40) - self.contentArray.count * 15, ScreenWidth, (isIphonex ?  20 : 0) + (width + 40) * self.contentArray.count + 10 + (self.disableCancel ? 0 : 40) + self.contentArray.count * 15);
        self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)emptyMethod {
    
}

- (void)btnTap:(UIButton *)button {
    id first = objc_getAssociatedObject(button, "firstObject");
    NSArray *contentArray = [self.contentArray objectAtIndex:[first intValue]];
    WPShareSheetItem *item = contentArray[button.tag - kBtnTag];
    if (item.selectionHandler) {
        item.selectionHandler();
    }
    [self doHide];
}

- (void)doHide {
    [self.sheetView setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.3 animations:^{
        self.sheetView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, ScreenWidth, isIphonex ? kHeight + 20 : kHeight);
        self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
