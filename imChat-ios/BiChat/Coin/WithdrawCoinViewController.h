//
//  WithdrawCoinViewController.h
//  BiChat
//
//  Created by imac2 on 2018/8/29.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanViewController.h"

@interface WithdrawCoinViewController : UITableViewController<ScanViewControllerDelegate, UITextViewDelegate>
{
    UITextView *input4Address;
    UITextField *input4WithdrawCount;
    UILabel *label4Charge;
}

@property (nonatomic, retain) NSDictionary *coinInfo;
@property (nonatomic) CGFloat coinCount;

@end
