//
//  AddFriendViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/2/27.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanViewController.h"

@interface AddFriendViewController : UITableViewController<UITextFieldDelegate, ScanViewControllerDelegate>
{
    UITextField *input4UserMobile;
}

@end
