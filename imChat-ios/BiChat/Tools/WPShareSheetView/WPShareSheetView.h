//
//  WPShareSheetView.h
//  BiChat
//
//  Created by iMac on 2018/6/11.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPShareSheetItem.h"

@interface WPShareSheetView : UIView

@property (nonatomic, strong)UIView *sheetView;
@property (nonatomic, strong)NSArray *contentArray;
//是否加载云端图片
@property (nonatomic, assign)BOOL isOnline;
//是否显示取消按钮
@property (nonatomic, assign)BOOL disableCancel;
//每屏单行显示个数
@property (nonatomic, assign)NSInteger perPageCount;

- (instancetype)initWithItemsArray:(NSArray *)array;
- (void)show;

@end
