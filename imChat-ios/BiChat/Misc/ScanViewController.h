//
//  ScanViewController.h
//  HJYScanCode
//
//  Created by 黄家永 on 16/6/23.
//  Copyright © 2016年 黄家永. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScanViewControllerDelegate <NSObject>

- (void)license:(NSString *)license;

@end

#define SCANMODE_CAPTURE                        0
#define SCANMODE_PICTURE                        1

@interface ScanViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    NSInteger scanMode;
}

@property (nonatomic, weak) id<ScanViewControllerDelegate> delegate;

@end
