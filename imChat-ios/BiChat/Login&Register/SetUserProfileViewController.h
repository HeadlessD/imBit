//
//  SetUserProfileViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/3/15.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPTextFieldView.h"

@interface SetUserProfileViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate>

@property (nonatomic) BOOL canCancel;
@property (nonatomic) BOOL canBack;
@property (nonatomic) BOOL backOnDone;
@property (nonatomic) BOOL bindWeChatOnDone;
@property (nonatomic) BOOL nickNameAlong;
@property (nonatomic, retain) NSString *nickName;
@property (nonatomic, retain) NSString *avatar;
@property (nonatomic, strong) WPTextFieldView *input4NickName;

@end
