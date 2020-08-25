//
//  SoundMessageDetailViewController.m
//  BiChat
//
//  Created by Admin on 2018/5/31.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "SoundMessageDetailViewController.h"
#import "JSONKit.h"
#import "S3SDK_.h"

@interface SoundMessageDetailViewController ()

@end

@implementation SoundMessageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"语音详情";
    self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    
    [self createGUI];
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //如果当前正在播放，需要停止
    if (avPlayer.isPlaying)
    {
        [avPlayer stop];
        [timer4Progress invalidate];
        timer4Progress = nil;
        progress4Play.progress = 0;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 私有函数

- (void)createGUI
{
    //头像
    UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[self.message objectForKey:@"sender"]
                                            nickName:[self.message objectForKey:@"senderNickName"]
                                              avatar:[self.message objectForKey:@"senderAvatar"] frame:CGRectMake(15, 15, 40, 40)];
    [self.view addSubview:view4Avatar];
    
    //昵称
    UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(65, 15, self.view.frame.size.width - 80, 20)];
    label4NickName.text = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[self.message objectForKey:@"sender"] groupProperty:nil nickName:[self.message objectForKey:@"senderNickName"]];
    label4NickName.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:label4NickName];
    
    //发送时间
    UILabel *label4Time = [[UILabel alloc]initWithFrame:CGRectMake(65, 35, self.view.frame.size.width - 80, 20)];
    label4Time.text = [BiChatGlobal adjustDateString:[self.message objectForKey:@"timeStamp"]];
    label4Time.font = [UIFont systemFontOfSize:12];
    label4Time.textColor = [UIColor grayColor];
    [self.view addSubview:label4Time];
    
    //frame
    UIView *view4Frame = [[UIView alloc]initWithFrame:CGRectMake(15, 70, self.view.frame.size.width - 30, 70)];
    view4Frame.backgroundColor = [UIColor whiteColor];
    view4Frame.layer.cornerRadius = 3;
    view4Frame.layer.borderColor = THEME_GRAY.CGColor;
    view4Frame.layer.borderWidth = 0.5;
    [self.view addSubview:view4Frame];
    
    //播放按钮
    button4PlayStop = [[UIButton alloc]initWithFrame:CGRectMake(30, 85, 40, 40)];
    [button4PlayStop setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [button4PlayStop addTarget:self action:@selector(onButtonPlayStop:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button4PlayStop];
    
    //时长
    UILabel *label4SoundLength = [[UILabel alloc]initWithFrame:CGRectMake(80, 85, 30, 40)];
    label4SoundLength.text = @"3s";
    label4SoundLength.font = [UIFont systemFontOfSize:14];
    label4SoundLength.textColor = [UIColor grayColor];
    label4SoundLength.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label4SoundLength];
    
    //progress
    progress4Play = [[UIProgressView alloc]initWithFrame:CGRectMake(120, 104, self.view.frame.size.width - 155, 3)];
    [self.view addSubview:progress4Play];
}

- (void)onButtonPlayStop:(id)sender
{
    if (avPlayer.playing)
    {
        [avPlayer stop];
        progress4Play.progress = 0;
        [button4PlayStop setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [timer4Progress invalidate];
        timer4Progress = nil;
    }
    else
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *item4SoundInfo = [dec objectWithData:[[self.message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        //开始播放指定的声音
        NSArray *pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   [[item4SoundInfo objectForKey:@"FileName"]stringByReplacingOccurrencesOfString:@"/" withString:@"_"], //caf
                                   nil];
        NSURL *soundFileUrl = [NSURL fileURLWithPathComponents:pathComponents];
        __block NSError *err;
        avPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:soundFileUrl error:&err];
        if (err)
        {
            //没能打开文件，说明文件不存在，下载
            S3SDK_ *S3SDK = [S3SDK_ new];
            [S3SDK DownloadData:[item4SoundInfo objectForKey:@"FileName"]
                          begin:^(void){}
                       progress:^(float ratio) {
                ;
            } success:^(NSDictionary * _Nullable info, id  _Nonnull responseObject) {
                
                //文件下载成功，重新开始播放
                NSLog(@"%@", [soundFileUrl relativePath]);
                BOOL ret = [responseObject writeToFile:[soundFileUrl relativePath] atomically:YES];
                NSLog(@"write to file(%lubytes) return :%d", (unsigned long)[responseObject length], ret);
                avPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:soundFileUrl error:&err];
                if (err)
                {
                    [BiChatGlobal showInfo:LLSTR(@"301805") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                    return;
                }
                avPlayer.delegate = self;
                [avPlayer play];
                timer4Progress = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
                    progress4Play.progress = avPlayer.currentTime/avPlayer.duration;
                }];
                
            } failure:^(NSError * _Nonnull error) {
                [BiChatGlobal showInfo:LLSTR(@"301801") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }];
        }
        
        NSLog(@"开始播放");
        avPlayer.delegate = self;
        [avPlayer play];
        timer4Progress = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            progress4Play.progress = avPlayer.currentTime/avPlayer.duration;
        }];
        [button4PlayStop setImage:[UIImage imageNamed:@"stop_play"] forState:UIControlStateNormal];
    }
}

//声音播放结束
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"结束");
    [button4PlayStop setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [timer4Progress invalidate];
    timer4Progress = nil;
    progress4Play.progress = 0;
}

@end
