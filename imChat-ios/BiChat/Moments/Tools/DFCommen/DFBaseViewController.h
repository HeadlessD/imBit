//
//  HCBaseViewController.h
//  Heacha
//
//  Created by 豆凯强 on 17/1/11.
//  Copyright (c) 2017年 Datafans Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBarButtonItem+Lite.h"

@interface DFBaseViewController : UIViewController


//普通文本
-(void) hudShowText:(NSString *)text;
-(void) hudShowText:(NSString *)text second:(NSInteger)second;

//加载状态
//-(MBProgressHUD *) hudShowLoading;
//-(MBProgressHUD *) hudShowLoading:(NSString *)text;

//成功或失败提示
-(void) hudShowOk:(NSString *) text;
-(void) hudShowFail:(NSString *) text;

-(void) hudShowIcon:(NSString *) icon text:(NSString *) text;


-(UIBarButtonItem *) rightBarButtonItem;
-(UIBarButtonItem *) leftBarButtonItem;
-(UIBarButtonItem *) defaultReturnBarButtonItem;


-(BOOL) enableAutoLoadStateView;

-(void) showLoadingView;
-(void) hideLoadingView;


-(void) showLoadFailView;
-(void) hideLoadFailView;


-(void) onClickLoadFailView;



@end
