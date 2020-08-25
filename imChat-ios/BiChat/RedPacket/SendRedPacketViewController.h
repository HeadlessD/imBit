//
//  SendRedPacketViewController.h
//  BiChat
//
//  Created by Admin on 2018/3/26.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendRedPacketViewController : UITableViewController
{
    NSString *selectedCoinName;
    NSString *selectedCoinIcon;
    CGFloat balance;
    BOOL allowForward;
    
    //界面相关
    UITextField *input4SelectCoinSum;
    UITextField *input4RedPacketCount;
    UITextView *input4BestWisth;
}

@property (nonatomic, retain) NSDictionary *groupProperty;

@end
