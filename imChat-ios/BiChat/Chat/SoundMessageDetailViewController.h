//
//  SoundMessageDetailViewController.h
//  BiChat
//
//  Created by Admin on 2018/5/31.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface SoundMessageDetailViewController : UIViewController<AVAudioPlayerDelegate>
{
    //界面相关
    UIButton *button4PlayStop;
    UIProgressView *progress4Play;
    
    //声音播放
    AVAudioPlayer *avPlayer;
    NSTimer *timer4Progress;
}

@property (nonatomic, retain) NSDictionary *message;

@end
