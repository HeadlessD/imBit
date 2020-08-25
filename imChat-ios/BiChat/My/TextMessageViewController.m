//
//  TextMessageViewController.m
//  BiChat Dev
//
//  Created by imac2 on 2018/8/17.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "TextMessageViewController.h"
#import "ChatViewController.h"
#import "WPNewsDetailViewController.h"
#import "WPGroupAddMiddleViewController.h"

@interface TextMessageViewController ()

@end

@implementation TextMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"104012");
    self.view.backgroundColor = [UIColor whiteColor];
    [self initGUI];
    // Do any additional setup after loading the view.
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

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    //是我们系统内部链接
    if ([URL.absoluteString.lowercaseString rangeOfString:IMCHAT_GROUPLINK_MARK].length > 0)
    {
        NSInteger pt = [URL.absoluteString.lowercaseString rangeOfString:IMCHAT_GROUPLINK_MARK].location;
        NSString *groupId = [URL.absoluteString.lowercaseString substringFromIndex:(pt + IMCHAT_GROUPLINK_MARK.length)];
        NSRange range = [groupId rangeOfString:@"&"];
        if (range.length > 0)
            groupId = [groupId substringToIndex:range.location];
        [self enterGroup:groupId];
        return NO;
    }
    
    else if ([URL.scheme.lowercaseString isEqualToString:@"http"] ||
             [URL.scheme.lowercaseString isEqualToString:@"https"])
    {
        WPNewsDetailViewController *wnd = [WPNewsDetailViewController new];
        wnd.url = URL.absoluteString;
        [self.navigationController pushViewController:wnd animated:YES];
        return NO;
    }
    
    //交给系统去打理
    return YES;
}

- (void)enterGroup:(NSString *)groupId
{
    //获取群聊信息
    [BiChatGlobal ShowActivityIndicator];
    [NetworkModule getGroupProperty:groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        [BiChatGlobal HideActivityIndicator];
        if (success)
        {
            if ([BiChatGlobal isUserInGroup:data uid:[BiChatGlobal sharedManager].uid])
            {
                //进入群聊
                //清除这个聊天的新消息条数
                [[BiChatDataModule sharedDataModule]clearNewMessageCountWith:groupId];
                
                //进入聊天界面
                ChatViewController *wnd = [ChatViewController new];
                wnd.hidesBottomBarWhenPushed = YES;
                wnd.peerUid = groupId;
                wnd.peerUserName = @"";
                wnd.peerNickName = [data objectForKey:@"groupName"];
                wnd.peerAvatar = [data objectForKey:@"avatar"];
                wnd.isGroup = YES;
                wnd.isPublic = NO;
                [self.navigationController pushViewController:wnd animated:YES];
                
                //添加一个系统消息
                //                NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:[BiChatGlobal getUuidString], @"msgId",
                //                                                [NSNumber numberWithInteger:MESSAGE_CONTENT_TYPE_SYSTEM], @"type",
                //                                                [BiChatGlobal getUuidString], @"contentId",
                //                                                @"欢迎回到群聊", @"content",
                //                                                [BiChatGlobal getCurrentDateString], @"timeStamp",
                //                                                nil];
                //                [wnd appendMessageFromNetwork:message];
            }
            else
            {
                WPGroupAddMiddleViewController *middleVC = [[WPGroupAddMiddleViewController alloc]init];
                middleVC.groupId = groupId;
                middleVC.source = [@{@"source": @"LINK"} mj_JSONString];
                middleVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:middleVC animated:YES];
            }
        }
        else
            [BiChatGlobal showInfo:LLSTR(@"301701") withIcon:[UIImage imageNamed:@"icon_alert"]];
    }];
}


#pragma mark - 私有函数

- (void)initGUI
{
    UIScrollView *scroll4Content = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64)];
    [self.view addSubview:scroll4Content];
    
    //头像
    UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[self.message objectForKey:@"sender"] nickName:[self.message objectForKey:@"senderNickName"] avatar:[self.message objectForKey:@"senderAvatar"] frame:CGRectMake(15, 15, 40, 40)];
    [scroll4Content addSubview:view4Avatar];
    
    //发言者
    UILabel *label4Speaker = [[UILabel alloc]initWithFrame:CGRectMake(70, 15, self.view.frame.size.width - 90, 40)];
    label4Speaker.text = [self.message objectForKey:@"senderNickName"];
    label4Speaker.font = [UIFont systemFontOfSize:16];
    [scroll4Content addSubview:label4Speaker];
    
    //分割线
    UIView *view4Seperator = [[UIView alloc]initWithFrame:CGRectMake(15, 70, self.view.frame.size.width - 30, 0.5)];
    view4Seperator.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];
    [scroll4Content addSubview:view4Seperator];
    
    //文字
    NSString *content = [self.message objectForKey:@"content"];
    NSMutableAttributedString *str = [content transEmotionWithFont:[UIFont systemFontOfSize:CHATTEXT_FONTSIZE]];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:1];
    [str addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:CHATTEXT_FONTSIZE] range:NSMakeRange(0, str.length)];
    CGRect rect4Content = [str boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                            context:nil];
    scroll4Content.contentSize = CGSizeMake(self.view.frame.size.width, rect4Content.size.height + 150);
    
    //内容
    UITextView *text4Message = [[UITextView alloc]initWithFrame:CGRectMake(15, 85, rect4Content.size.width, rect4Content.size.height)];
    text4Message.dataDetectorTypes = UIDataDetectorTypePhoneNumber | UIDataDetectorTypeLink;
    text4Message.linkTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                       THEME_COLOR, NSForegroundColorAttributeName,
                                       /*[NSNumber numberWithInt:1], NSUnderlineStyleAttributeName,*/
                                       nil];
    text4Message.attributedText = str;
    text4Message.font = [UIFont systemFontOfSize:CHATTEXT_FONTSIZE];
    text4Message.editable = NO;
    text4Message.selectable = YES;
    text4Message.textContainerInset = UIEdgeInsetsMake(0, -5, 0, -5);
    text4Message.layoutManager.allowsNonContiguousLayout=NO;
    text4Message.delegate = self;
    text4Message.scrollEnabled = NO;
    text4Message.clipsToBounds = NO;
    [scroll4Content addSubview:text4Message];

    //UILabel *label4Text = [[UILabel alloc]initWithFrame:CGRectMake(15, 85, rect4Content.size.width, rect4Content.size.height)];
    //label4Text.attributedText = str;
    //label4Text.font = [UIFont systemFontOfSize:CHATTEXT_FONTSIZE];
    //label4Text.numberOfLines = 0;
    //[scroll4Content addSubview:label4Text];
    
    //footer
    UILabel *label4Footer = [[UILabel alloc]initWithFrame:CGRectMake(15, rect4Content.size.height + 110, self.view.frame.size.width - 30, 20)];
    label4Footer.text = self.footer;
    label4Footer.textColor = THEME_GRAY;
    label4Footer.font = [UIFont systemFontOfSize:14];
    [scroll4Content addSubview:label4Footer];
}

@end
