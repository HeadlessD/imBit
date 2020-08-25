//
//  GroupApplyMiddleViewController.m
//  BiChat
//
//  Created by imac2 on 2019/4/15.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import "GroupApplyMiddleViewController.h"
#import "ChatViewController.h"

@interface GroupApplyMiddleViewController ()

@end

@implementation GroupApplyMiddleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //获取群审批列表
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getGroupApproveList:[self.groupProperty objectForKey:@"groupId"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            //找到自己的入群方式
            for (NSDictionary *item in [data objectForKey:@"data"])
            {
                if ([[item objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid])
                {
                    source = [item objectForKey:@"source"];
                    joinTime = [[item objectForKey:@"joinTime"]longLongValue];
                    [self createUI];
                }
            }
        }
        else
            [BiChatGlobal showInfo:@"" withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
    }];
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

- (void)createUI
{
    NSString *str4Avatar = [BiChatGlobal getGroupAvatar:self.groupProperty];
    UIView *view4Avatar = [BiChatGlobal getAvatarWnd:nil nickName:[self.groupProperty objectForKey:@"groupName"] avatar:str4Avatar width:60 height:60];
    view4Avatar.center = CGPointMake(self.view.frame.size.width / 2, 30);
    [self.view addSubview:view4Avatar];
    
    //群名称
    UILabel *label4GroupName = [[UILabel alloc]initWithFrame:CGRectMake(10, 70, self.view.frame.size.width - 20, 20)];
    label4GroupName.text = [self.groupProperty objectForKey:@"groupName"];
    label4GroupName.font = [UIFont systemFontOfSize:16];
    label4GroupName.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label4GroupName];
    
    //入群方式
    UILabel *label4Source = [[UILabel alloc]initWithFrame:CGRectMake(10, 100, self.view.frame.size.width - 20, 20)];
    label4Source.text = [LLSTR(@"201231") llReplaceWithArray:@[[BiChatGlobal adjustDateString:[BiChatGlobal getDateString:[NSDate dateWithTimeIntervalSince1970:joinTime/1000]]], [BiChatGlobal getSourceString:source]]];
    label4Source.textAlignment = NSTextAlignmentCenter;
    label4Source.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:label4Source];
    
    //群简介
    NSString *groupDescription = [self.groupProperty objectForKey:@"briefing"];
    CGRect rect = [groupDescription boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 20, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
    if (rect.size.height > self.view.frame.size.height - 270)
        rect.size.height = self.view.frame.size.height - 270;
    
    UITextView *label4Description = [[UITextView alloc]initWithFrame:CGRectMake(10, 130, self.view.frame.size.width - 20, rect.size.height + 20)];
    label4Description.text = groupDescription;
    label4Description.font = [UIFont systemFontOfSize:14];
    label4Description.textColor = [UIColor grayColor];
    label4Description.editable = NO;
    [self.view addSubview:label4Description];
    
    //进入审批群按钮
    NSString *title = LLSTR(@"201349");
    rect = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil];
    UIButton *button4EnterServiceGroup = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, rect.size.width + 40, 40)];
    button4EnterServiceGroup.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height - 80);
    button4EnterServiceGroup.layer.borderColor = THEME_COLOR.CGColor;
    button4EnterServiceGroup.layer.borderWidth = 0.5;
    button4EnterServiceGroup.layer.cornerRadius = 5;
    button4EnterServiceGroup.titleLabel.font = [UIFont systemFontOfSize:16];
    [button4EnterServiceGroup setTitle:title forState:UIControlStateNormal];
    [button4EnterServiceGroup setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [button4EnterServiceGroup addTarget:self action:@selector(onButtonEnterServiceGroup:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button4EnterServiceGroup];
}

- (void)onButtonEnterServiceGroup:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    //创建和管理员沟通群
    button.enabled = NO;
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule createGroupServiceGroup:[self.groupProperty objectForKey:@"groupId"] userId:[BiChatGlobal sharedManager].uid relatedGroupId:[BiChatGlobal sharedManager].uid relatedGroupType:1 completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            //NSLog(@"%@", data);
            [NetworkModule getGroupProperty:[data objectForKey:@"queryGroup"] completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                
                button.enabled = YES;
                if (success)
                {
                    //NSLog(@"%@", data);
                    ChatViewController *wnd = [ChatViewController new];
                    wnd.isGroup = YES;
                    wnd.peerUid = [data objectForKey:@"groupId"];
                    wnd.peerNickName = [data objectForKey:@"groupName"];
                    wnd.peerAvatar = [data objectForKey:@"avatar"];
                    [self.navigationController pushViewController:wnd animated:YES];
                }
                else
                    [BiChatGlobal showInfo:LLSTR(@"301715") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }];
        }
        else
        {
            button.enabled = YES;
            [BiChatGlobal showInfo:LLSTR(@"301715") withIcon:[UIImage imageNamed:@"icon_alert"]duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }
    }];
}

@end
