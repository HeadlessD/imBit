//
//  ZFFullScreenViewController.m
//  ZFPlayer_Example
//
//  Created by 紫枫 on 2018/8/29.
//  Copyright © 2018年 紫枫. All rights reserved.
//

#import "ZFFullScreenViewController.h"
#import <ZFPlayer/ZFPlayer.h>
#import <ZFPlayer/ZFAVPlayerManager.h>
#import <ZFPlayer/ZFIJKPlayerManager.h>
//#import <ZFPlayer/KSMediaPlayerManager.h>
#import <ZFPlayer/ZFPlayerControlView.h>
//#import "ZFSmallPlayViewController.h"


@interface ZFFullScreenViewController ()
@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) ZFPlayerControlView *controlView;
@property (nonatomic, strong) ZFPortraitControlView *portraitControlView;
@property (nonatomic, strong) ZFLandScapeControlView *landScapeControlView;

@end

@implementation ZFFullScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    @weakify(self)
    
    [self.controlView showTitle:nil coverImage:nil fullScreenMode:ZFFullScreenModePortrait];
    if (_videoImage) {
        [self.controlView.coverImageView setImage:_videoImage];
        [self.controlView.bgImgView setImage:_videoImage];
    }else{
        [self.controlView.coverImageView yy_setImageWithURL:[NSURL URLWithString:_videoImageStr] placeholder:nil];
        [self.controlView.bgImgView yy_setImageWithURL:[NSURL URLWithString:_videoImageStr] placeholder:[UIImage imageNamed:@"default_image"]];
    }
    
    self.controlView.backBtnClickCallback = ^{
        @strongify(self)
//        [self.player enterFullScreen:NO animated:NO];
        [self.player stop];
        [self.navigationController popViewControllerAnimated:NO];
    };
    
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
    /// 播放器相关
    //    self.player = [[ZFPlayerController alloc] initWithPlayerManager:playerManager containerView:self.controlView];
    self.player = [[ZFPlayerController alloc] initWithPlayerManager:playerManager containerView:[UIApplication sharedApplication].keyWindow];
    
    
    self.player.controlView = self.controlView;
    self.player.orientationObserver.fullScreenMode =  ZFFullScreenModePortrait;
    self.player.orientationObserver.supportInterfaceOrientation = ZFInterfaceOrientationMaskLandscape;
    [self.player enterFullScreen:YES animated:NO];
    
    self.player.allowOrentitaionRotation = NO;
    self.player.WWANAutoPlay = YES;
    /// 1.0是完全消失时候
    self.player.playerDisapperaPercent = 1.0;

    WEAKSELF;
    self.player.playerDidToEnd = ^(id  _Nonnull asset) {
        @strongify(self)
        [weakSelf.player.currentPlayerManager replay];
    };
    
    NSURL * locaPath = nil;
    NSURL * downUrl = nil;

    if (_chatVideoUrl) {
        NSString * chatStr = [NSString stringWithFormat:@"%@",_chatVideoUrl];
        locaPath =  [NSURL URLWithString:[WPBaseManager fileName:[chatStr substringWithRange:NSMakeRange(chatStr.length - 36, 36)] inDirectory:@"MVideo"]];
        downUrl = _chatVideoUrl;
    }else{
        locaPath = [NSURL fileURLWithPath:[WPBaseManager fileName:[_playVideoUrl substringWithRange:NSMakeRange(_playVideoUrl.length - 36, 36)] inDirectory:@"MVideo"]];
        downUrl =  [NSURL URLWithString:_playVideoUrl];
    }

    if ([[[NSString stringWithFormat:@"%@",locaPath] substringToIndex:4] isEqualToString:@"http"])
    {
        playerManager.assetURL = downUrl;
        //        NSString * filePath = [WPBaseManager fileName:[url substringWithRange:NSMakeRange(url.length - 36, 36)] inDirectory:@"MVideo"];
        
        
        [[DFFileManager sharedInstance] downloadVideoUrl:[NSString stringWithFormat:@"%@",downUrl] success:^(BOOL success) {
            if (success) {
                NSLog(@"下载成功");
            } else {
                NSLog(@"下载失败");
            }
        }];
    }
    else
    {
        NSString * file = [NSString stringWithFormat:@"file://%@",locaPath.absoluteString];
        NSData * locaData1 = [NSData dataWithContentsOfFile:locaPath.absoluteString];
        NSData * locaData2 = [NSData dataWithContentsOfURL:[NSURL URLWithString:file]];
        
        if (locaData2) {
            playerManager.assetURL = [NSURL URLWithString:file];
        }else{
            playerManager.assetURL = downUrl;
            //        NSString * filePath = [WPBaseManager fileName:[url substringWithRange:NSMakeRange(url.length - 36, 36)] inDirectory:@"MVideo"];
            
            [[DFFileManager sharedInstance] downloadVideoUrl:[NSString stringWithFormat:@"%@",downUrl] success:^(BOOL success) {
                if (success) {
                    NSLog(@"下载成功");
                } else {
                    NSLog(@"下载失败");
                }
            }];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.player.viewControllerDisappear = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.player.viewControllerDisappear = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.player.isFullScreen) {
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return self.player.isStatusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (BOOL)shouldAutorotate {
    return self.player.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (ZFPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [ZFPlayerControlView new];
        _controlView.fastViewAnimated = YES;
    }
    return _controlView;
}

@end
