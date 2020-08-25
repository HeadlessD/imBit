//
//  TextMessageViewController.h
//  BiChat Dev
//
//  Created by imac2 on 2018/8/17.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextMessageViewController : UIViewController<UITextViewDelegate>

@property (nonatomic, retain) NSDictionary *message;
@property (nonatomic, retain) NSString *footer;

@end
