//
//  DFVideoCaptureController.h
//  iconTest
//
//  Created by 豆凯强 on 16/2/14.
//  Copyright © 2016年 Datafans. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DFVideoCaptureControllerDelegate <NSObject>

@optional

-(void) onCaptureVideo:(NSString *) filePath screenShot:(UIImage *) screenShot;

@end

@interface DFVideoCaptureController : UIViewController

@property (nonatomic, weak) id<DFVideoCaptureControllerDelegate> delegate;

-(void) onCaptureVideo:(NSString *) filePath screenShot:(UIImage *) screenShot;

@end
