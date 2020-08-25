//
//  UserMemoNameViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/4/26.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPTextFieldView.h"

@interface UserMemoNameViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSString *memoName;
@property (nonatomic, strong) WPTextFieldView *input4MemoName;

@end
