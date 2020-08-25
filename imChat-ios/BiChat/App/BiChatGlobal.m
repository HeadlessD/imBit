//
//  BiChatGlobal.m
//  BiChat
//
//  Created by worm_kc on 2018/2/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "BiChatDataModule.h"
#import <TTStreamer/TTStreamerClient.h>
#import "AlertView.h"
#import "JSONKit.h"
#import "pinyin.h"
#import "UIImageView+WebCache.h"
#import "SectorProgressView.h"
#import "LoginPortalViewController.h"
#import "LoginViewController.h"
#import "PersistentBackgroundLabel.h"
#import "WXApi.h"
#import <sys/utsname.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"

@implementation BiChatGlobal
#define kBadgeTag 999

static BiChatGlobal *sharedGlobalManager = nil;
+ (BiChatGlobal *)sharedManager
{
    @synchronized(self)
    {
        if  (sharedGlobalManager == nil)
        {
            sharedGlobalManager = [[BiChatGlobal alloc]init];
            
            //加载一些全局变量
            sharedGlobalManager.dict4GlobalUFileUploadCache = [NSMutableDictionary dictionary];
            [sharedGlobalManager loadAreaCode];
            [sharedGlobalManager loadCountryCode2AreaCode];
            [sharedGlobalManager loadGlobalInfo];
            [sharedGlobalManager loadAvatarNickNameInfo];
            sharedGlobalManager.array4AllDefaultEmotions = [NSMutableArray arrayWithObjects:
                                                            @{@"chinese":@"[微笑]",@"english":@"[Smile]",@"name":@"smile"},
                                                            @{@"chinese":@"[撇嘴]",@"english":@"[Grimace]",@"name":@"grimance"},
                                                            @{@"chinese":@"[色]",@"english":@"[Drool]",@"name":@"drool"},
                                                            @{@"chinese":@"[发呆]",@"english":@"[Scowl]",@"name":@"scowl"},
                                                            @{@"chinese":@"[得意]",@"english":@"[CoolGuy]",@"name":@"cool_guy"},
                                                            @{@"chinese":@"[流泪]",@"english":@"[Sob]",@"name":@"sob"},
                                                            @{@"chinese":@"[害羞]",@"english":@"[Shy]",@"name":@"shy"},
                                                            @{@"chinese":@"[闭嘴]",@"english":@"[Silent]",@"name":@"silent"},
                                                            @{@"chinese":@"[睡]",@"english":@"[Sleep]",@"name":@"sleep"},
                                                            @{@"chinese":@"[大哭]",@"english":@"[Cry]",@"name":@"cry"},
                                                            @{@"chinese":@"[尴尬]",@"english":@"[Awkward]",@"name":@"akward"},
                                                            @{@"chinese":@"[发怒]",@"english":@"[Angry]",@"name":@"angry"},
                                                            @{@"chinese":@"[调皮]",@"english":@"[Tongue]",@"name":@"tongue"},
                                                            @{@"chinese":@"[呲牙]",@"english":@"[Grin]",@"name":@"grin"},
                                                            @{@"chinese":@"[惊讶]",@"english":@"[Surprise]",@"name":@"surprise"},
                                                            @{@"chinese":@"[难过]",@"english":@"[Frown]",@"name":@"frown"},
                                                            @{@"chinese":@"[囧]",@"english":@"[Blush]",@"name":@"blush"},
                                                            @{@"chinese":@"[抓狂]",@"english":@"[Scream]",@"name":@"scream"},
                                                            @{@"chinese":@"[吐]",@"english":@"[Puke]",@"name":@"puke"},
                                                            @{@"chinese":@"[偷笑]",@"english":@"[Chuckle]",@"name":@"chuckle"},
                                                            @{@"chinese":@"[愉快]",@"english":@"[Joyful]",@"name":@"joyful"},
                                                            @{@"chinese":@"[白眼]",@"english":@"[Slight]",@"name":@"slight"},
                                                            @{@"chinese":@"[傲慢]",@"english":@"[Smug]",@"name":@"smug"},
                                                            @{@"chinese":@"[困]",@"english":@"[Drowsy]",@"name":@"drowsy"},
                                                            @{@"chinese":@"[惊恐]",@"english":@"[Panic]",@"name":@"panic"},
                                                            @{@"chinese":@"[流汗]",@"english":@"[Sweat]",@"name":@"sweat"},
                                                            @{@"chinese":@"[憨笑]",@"english":@"[Laugh]",@"name":@"laugh"},
                                                            @{@"chinese":@"[悠闲]",@"english":@"[Commando]",@"name":@"commando"},
                                                            @{@"chinese":@"[奋斗]",@"english":@"[Determined]",@"name":@"determined"},
                                                            @{@"chinese":@"[咒骂]",@"english":@"[Scold]",@"name":@"scold"},
                                                            @{@"chinese":@"[疑问]",@"english":@"[Shocked]",@"name":@"shocked"},
                                                            @{@"chinese":@"[嘘]",@"english":@"[Shhh]",@"name":@"shhh"},
                                                            @{@"chinese":@"[晕]",@"english":@"[Dizzy]",@"name":@"dizzy"},
                                                            @{@"chinese":@"[衰]",@"english":@"[Toasted]",@"name":@"toasted"},
                                                            @{@"chinese":@"[骷髅]",@"english":@"[Skull]",@"name":@"skull"},
                                                            @{@"chinese":@"[敲打]",@"english":@"[Hammer]",@"name":@"hammer"},
                                                            @{@"chinese":@"[再见]",@"english":@"[Bye]",@"name":@"wave"},
                                                            @{@"chinese":@"[擦汗]",@"english":@"[Speechless]",@"name":@"speechless"},
                                                            @{@"chinese":@"[抠鼻]",@"english":@"[NosePick]",@"name":@"nose_pick"},
                                                            @{@"chinese":@"[鼓掌]",@"english":@"[Clap]",@"name":@"clap"},
                                                            @{@"chinese":@"[坏笑]",@"english":@"[Trick]",@"name":@"trick"},
                                                            @{@"chinese":@"[左哼哼]",@"english":@"[Bah！L]",@"name":@"bah_l"},
                                                            @{@"chinese":@"[右哼哼]",@"english":@"[Bah！R]",@"name":@"bah_r"},
                                                            @{@"chinese":@"[哈欠]",@"english":@"[Yawn]",@"name":@"yawn"},
                                                            @{@"chinese":@"[鄙视]",@"english":@"[Pooh-pooh]",@"name":@"pooh_pooh"},
                                                            @{@"chinese":@"[委屈]",@"english":@"[Shrunken]",@"name":@"shrunken"},
                                                            @{@"chinese":@"[快哭了]",@"english":@"[TearingUp]",@"name":@"tearing_up"},
                                                            @{@"chinese":@"[阴险]",@"english":@"[Sly]",@"name":@"sly"},
                                                            @{@"chinese":@"[亲亲]",@"english":@"[Kiss]",@"name":@"kiss"},
                                                            @{@"chinese":@"[可怜]",@"english":@"[Whimper]",@"name":@"whimper"},
                                                            @{@"chinese":@"[菜刀]",@"english":@"[Cleaver]",@"name":@"cleaver"},
                                                            @{@"chinese":@"[西瓜]",@"english":@"[Watermelon]",@"name":@"watermelon"},
                                                            @{@"chinese":@"[啤酒]",@"english":@"[Beer]",@"name":@"beer"},
                                                            @{@"chinese":@"[咖啡]",@"english":@"[Coffee]",@"name":@"coffee"},
                                                            @{@"chinese":@"[猪头]",@"english":@"[Pig]",@"name":@"pig"},
                                                            @{@"chinese":@"[玫瑰]",@"english":@"[Rose]",@"name":@"rose"},
                                                            @{@"chinese":@"[凋谢]",@"english":@"[Wilt]",@"name":@"wilt"},
                                                            @{@"chinese":@"[嘴唇]",@"english":@"[Lips]",@"name":@"lips"},
                                                            @{@"chinese":@"[爱心]",@"english":@"[Heart]",@"name":@"heart"},
                                                            @{@"chinese":@"[心碎]",@"english":@"[BrokenHeart]",@"name":@"broken_heart"},
                                                            @{@"chinese":@"[蛋糕]",@"english":@"[Cake]",@"name":@"cake"},
                                                            @{@"chinese":@"[炸弹]",@"english":@"[Bomb]",@"name":@"bomb"},
                                                            @{@"chinese":@"[便便]",@"english":@"[Poop]",@"name":@"poop"},
                                                            @{@"chinese":@"[月亮]",@"english":@"[Moon]",@"name":@"moon"},
                                                            @{@"chinese":@"[太阳]",@"english":@"[Sun]",@"name":@"sun"},
                                                            @{@"chinese":@"[拥抱]",@"english":@"[Hug]",@"name":@"hug"},
                                                            @{@"chinese":@"[强]",@"english":@"[ThumbsUp]",@"name":@"thumbs_up"},
                                                            @{@"chinese":@"[弱]",@"english":@"[ThumbsDown]",@"name":@"thumbs_down"},
                                                            @{@"chinese":@"[握手]",@"english":@"[Shake]",@"name":@"shake"},
                                                            @{@"chinese":@"[胜利]",@"english":@"[Peace]",@"name":@"peace"},
                                                            @{@"chinese":@"[抱拳]",@"english":@"[Salute]",@"name":@"fight"},
                                                            @{@"chinese":@"[勾引]",@"english":@"[Beckon]",@"name":@"beckon"},
                                                            @{@"chinese":@"[拳头]",@"english":@"[Fist]",@"name":@"fist"},
                                                            @{@"chinese":@"[ok]",@"english":@"[OK]",@"name":@"ok"},
                                                            @{@"chinese":@"[跳跳]",@"english":@"[Waddle]",@"name":@"jump"},
                                                            @{@"chinese":@"[发抖]",@"english":@"[Tremble]",@"name":@"tremble"},
                                                            @{@"chinese":@"[怄火]",@"english":@"[Aaagh!]",@"name":@"aaagh"},
                                                            @{@"chinese":@"[转圈]",@"english":@"[Twirl]",@"name":@"twirl"},
                                                            @{@"chinese":@"😄",@"english":@"😄",@"name":@"add1"},
                                                            @{@"chinese":@"😷",@"english":@"😷",@"name":@"add2"},
                                                            @{@"chinese":@"😂",@"english":@"😂",@"name":@"add3"},
                                                            @{@"chinese":@"😝",@"english":@"😝",@"name":@"add4"},
                                                            @{@"chinese":@"😳",@"english":@"😳",@"name":@"add5"},
                                                            @{@"chinese":@"😱",@"english":@"😱",@"name":@"add6"},
                                                            @{@"chinese":@"😔",@"english":@"😔",@"name":@"add7"},
                                                            @{@"chinese":@"😒",@"english":@"😒",@"name":@"add8"},
                                                            @{@"chinese":@"[嘿哈]",@"english":@"[Hey]",@"name":@"add9"},
                                                            @{@"chinese":@"[捂脸]",@"english":@"[Facepalm]",@"name":@"add10"},
                                                            @{@"chinese":@"[奸笑]",@"english":@"[Smirk]",@"name":@"add11"},
                                                            @{@"chinese":@"[机智]",@"english":@"[Smart]",@"name":@"add12"},
                                                            @{@"chinese":@"[皱眉]",@"english":@"[Concerned]",@"name":@"add13"},
                                                            @{@"chinese":@"[耶]",@"english":@"[Yeah!]",@"name":@"add14"},
                                                            @{@"chinese":@"👻",@"english":@"👻",@"name":@"add15"},
                                                            @{@"chinese":@"🙏",@"english":@"🙏",@"name":@"add16"},
                                                            @{@"chinese":@"💪",@"english":@"💪",@"name":@"add17"},
                                                            @{@"chinese":@"🎉",@"english":@"🎉",@"name":@"add18"},
                                                            @{@"chinese":@"🎁",@"english":@"🎁",@"name":@"add19"},
                                                            @{@"chinese":@"[红包]",@"english":@"[Packet]",@"name":@"add20"},
                                                            @{@"chinese":@"[發]",@"english":@"[Rich]",@"name":@"add21"},
                                                            @{@"chinese":@"[小狗]",@"english":@"[Pup]",@"name":@"add22"},
                                                            nil];
            sharedGlobalManager.dict4AllDefaultEmotions = [NSMutableDictionary dictionary];
            sharedGlobalManager.array4GroupOperation = [NSMutableArray array];
            for (NSDictionary *item in sharedGlobalManager.array4AllDefaultEmotions)
            {
                [sharedGlobalManager.dict4AllDefaultEmotions setObject:item forKey:[item objectForKey:@"chinese"]];
                [sharedGlobalManager.dict4AllDefaultEmotions setObject:item forKey:[item objectForKey:@"english"]];
            }
        }
    }
    return sharedGlobalManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (sharedGlobalManager == nil) {
            sharedGlobalManager = [super allocWithZone:zone];
            return sharedGlobalManager;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

//打开风火轮
#define BACKGROUND_VIEW                                     9999
#define INDICATOR_VIEW                                      9998
#define FRAME_VIEW                                          9997
#define MESSAGE_VIEW                                        9996
#define SHARE_VIEW                                          9995
#define PROGRESS_VIEW                                       9994
#define PROGRESS_INFO                                       9993
#define PROGRESS_FRAME_VIEW                                 9992
#define PROGRESS_ADDITIONAL_VIEW                            9991
BOOL activityShowed;
NSTimer *timer4ControlActivityIndicator;
+ (void)ShowActivityIndicator
{
    [self ShowActivityIndicatorWithClickType:CLICK_TYPE_ALL];
}

+ (void)ShowActivityIndicatorImmediately
{
    [self ShowActivityIndicatorWithClickTypeImmediately:CLICK_TYPE_ALL];
}

+ (void)ShowActivityIndicatorWithClickType:(NSInteger)clickType
{
    //已经显示了？
    if (activityShowed)
        return;
    
    //显示风火轮的时候，必须先关闭进度
    activityShowed = YES;
    [self hideProgress];
    [timer4ControlActivityIndicator invalidate];
    timer4ControlActivityIndicator = nil;
    timer4ControlActivityIndicator = [NSTimer scheduledTimerWithTimeInterval:1 repeats:NO block:^(NSTimer * _Nonnull timer) {
        
        //计算frame坐标
        CGRect frameframe = CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 30.0f,
                                       [UIScreen mainScreen].bounds.size.height/2 - 55.0f,
                                       60.0f,
                                       60.0f);
        
        //是否已经显示frame
        UIView *frameView = (UIView *)[[UIApplication sharedApplication].keyWindow viewWithTag:FRAME_VIEW];
        if (frameView != nil)
        {
            [[UIApplication sharedApplication].keyWindow bringSubviewToFront:frameView];
            frameView.hidden = NO;
            frameView.frame = frameframe;
        }
        else
        {
            frameView = [[UIView alloc]initWithFrame:frameframe];
            frameView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
            frameView.tag = FRAME_VIEW;
            frameView.clipsToBounds = YES;
            frameView.layer.cornerRadius = 10;
            frameView.hidden = NO;
            [[UIApplication sharedApplication].keyWindow addSubview:frameView];
        }
        
        //计算activity坐标
        CGRect activityframe = CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 30.0f,
                                          [UIScreen mainScreen].bounds.size.height/2 - 55.0f,
                                          60.0f,
                                          60.0f);
        
        //风火轮
        UIActivityIndicatorView *activityView = (UIActivityIndicatorView *)[[UIApplication sharedApplication].keyWindow viewWithTag:INDICATOR_VIEW];
        if (activityView != nil)
        {
            [[UIApplication sharedApplication].keyWindow bringSubviewToFront:activityView];
            activityView.hidden = NO;
            activityView.frame = activityframe;
            [activityView startAnimating];
        }
        else
        {
            activityView = [[UIActivityIndicatorView alloc]initWithFrame:activityframe];
            activityView.tag = INDICATOR_VIEW;
            [[UIApplication sharedApplication].keyWindow addSubview:activityView];
            [activityView startAnimating];
        }
    }];
}

+ (void)ShowActivityIndicatorWithClickTypeImmediately:(NSInteger)clickType
{
    //已经显示了？
    if (activityShowed)
        return;
    
    //显示风火轮的时候，必须先关闭进度
    activityShowed = YES;
    [self hideProgress];
    [timer4ControlActivityIndicator invalidate];
    timer4ControlActivityIndicator = nil;
    //计算frame坐标
    CGRect frameframe = CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 30.0f,
                                   [UIScreen mainScreen].bounds.size.height/2 - 55.0f,
                                   60.0f,
                                   60.0f);
    
    //是否已经显示frame
    UIView *frameView = (UIView *)[[UIApplication sharedApplication].keyWindow viewWithTag:FRAME_VIEW];
    if (frameView != nil)
    {
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:frameView];
        frameView.hidden = NO;
        frameView.frame = frameframe;
    }
    else
    {
        frameView = [[UIView alloc]initWithFrame:frameframe];
        frameView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        frameView.tag = FRAME_VIEW;
        frameView.clipsToBounds = YES;
        frameView.layer.cornerRadius = 10;
        frameView.hidden = NO;
        [[UIApplication sharedApplication].keyWindow addSubview:frameView];
    }
    
    //计算activity坐标
    CGRect activityframe = CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 30.0f,
                                      [UIScreen mainScreen].bounds.size.height/2 - 55.0f,
                                      60.0f,
                                      60.0f);
    
    //风火轮
    UIActivityIndicatorView *activityView = (UIActivityIndicatorView *)[[UIApplication sharedApplication].keyWindow viewWithTag:INDICATOR_VIEW];
    if (activityView != nil)
    {
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:activityView];
        activityView.hidden = NO;
        activityView.frame = activityframe;
        [activityView startAnimating];
    }
    else
    {
        activityView = [[UIActivityIndicatorView alloc]initWithFrame:activityframe];
        activityView.tag = INDICATOR_VIEW;
        [[UIApplication sharedApplication].keyWindow addSubview:activityView];
        [activityView startAnimating];
    }
}

//关闭风火轮
+ (void)HideActivityIndicator
{
    //关闭控制时钟
    activityShowed = NO;
    [timer4ControlActivityIndicator invalidate];
    timer4ControlActivityIndicator = nil;
    
    //关闭风火轮
    UIView *frameView = (UIView *)[[UIApplication sharedApplication].keyWindow viewWithTag:FRAME_VIEW];
    if (!frameView) {
        return;
    }
    frameView.hidden = YES;
    UIActivityIndicatorView *activityView = (UIActivityIndicatorView *)[[UIApplication sharedApplication].keyWindow viewWithTag:INDICATOR_VIEW];
    [activityView stopAnimating];
    activityView.hidden = YES;
}

//显示一个进度
+ (void)showProgress:(CGFloat)progress
                info:(NSString *)info
      additionalView:(UIView *)additionalView
           clickType:(NSInteger)clickType;
{
    //显示进度的时候，必须先关闭风火轮
    [self HideActivityIndicator];
    
    //是否指定了点击类型
    UIView *backgroudView = (UIView *)[[UIApplication sharedApplication].keyWindow viewWithTag:BACKGROUND_VIEW];
    if (backgroudView == nil)
    {
        backgroudView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        backgroudView.tag = BACKGROUND_VIEW;
        [[UIApplication sharedApplication].keyWindow addSubview:backgroudView];
    }
    backgroudView.hidden = NO;
    backgroudView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    if (clickType == CLICK_TYPE_NONE)
        backgroudView.frame = [UIApplication sharedApplication].keyWindow.bounds;
    else if (clickType == CLICK_TYPE_NAVIGATOR)
    {
        CGRect frame = [UIApplication sharedApplication].keyWindow.bounds;
        if (isIphonex)
            backgroudView.frame = CGRectMake(0, 88, frame.size.width, frame.size.height - 88);
        else
            backgroudView.frame = CGRectMake(0, 64, frame.size.width, frame.size.height - 64);
    }
    else if (clickType == CLICK_TYPE_ALL)
        backgroudView.frame = CGRectMake(0, 0, 0, 0);
    
    //计算frame坐标
    CGRect frameframe = CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 50.0f,
                                   [UIScreen mainScreen].bounds.size.height/2 - 50.0f,
                                   100.0f,
                                   100.0f);
    
    //是否已经显示frame
    UIView *frameView = (UIView *)[[UIApplication sharedApplication].keyWindow viewWithTag:PROGRESS_FRAME_VIEW];
    if (frameView != nil)
    {
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:frameView];
        frameView.hidden = NO;
        frameView.frame = frameframe;
    }
    else
    {
        frameView = [[UIView alloc]initWithFrame:frameframe];
        frameView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        frameView.tag = PROGRESS_FRAME_VIEW;
        frameView.clipsToBounds = YES;
        frameView.layer.cornerRadius = 10;
        frameView.hidden = NO;
        [[UIApplication sharedApplication].keyWindow addSubview:frameView];
    }
    
    //是否已经显示了进度
    SectorProgressView *progressView = (SectorProgressView *)[[UIApplication sharedApplication].keyWindow viewWithTag:PROGRESS_VIEW];
    if (progressView != nil)
    {
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:progressView];
        progressView.hidden = NO;
    }
    else
    {
        progressView = [[SectorProgressView alloc]initWithFrame:CGRectMake(frameframe.origin.x, frameframe.origin.y, 50, 50)];
        progressView.backgroundColor = [UIColor whiteColor];
        progressView.tag = PROGRESS_VIEW;
        progressView.layer.cornerRadius = 25;
        progressView.clipsToBounds = YES;
        progressView.progressColor = [UIColor colorWithWhite:0 alpha:0.8];
        [[UIApplication sharedApplication].keyWindow addSubview:progressView];
        
        //安排位置
        if (info.length == 0)
            progressView.center = CGPointMake(frameframe.origin.x + frameframe.size.width / 2, frameframe.origin.y + frameframe.size.height / 2);
        else
            progressView.center = CGPointMake(frameframe.origin.x + frameframe.size.width / 2, frameframe.origin.y + frameframe.size.height / 2 - 10);
    }
    progressView.progress = progress;
    
    //是否已经显示了进度信息
    UILabel *progressInfo = (UILabel *)[[UIApplication sharedApplication].keyWindow viewWithTag:PROGRESS_INFO];
    if (progressInfo != nil)
    {
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:progressInfo];
        progressInfo.hidden = NO;
        progressInfo.frame = CGRectMake(frameframe.origin.x, frameframe.origin.y + frameframe.size.height - 40, frameframe.size.width, 40);
    }
    else
    {
        progressInfo = [[UILabel alloc]initWithFrame:CGRectMake(frameframe.origin.x, frameframe.origin.y + frameframe.size.height - 40, frameframe.size.width, 40)];
        progressInfo.tag = PROGRESS_INFO;
        progressInfo.textColor = [UIColor whiteColor];
        progressInfo.textAlignment = NSTextAlignmentCenter;
        progressInfo.font = [UIFont systemFontOfSize:14];
        [[UIApplication sharedApplication].keyWindow addSubview:progressInfo];
    }
    progressInfo.text = info;
    
    //是否有附加窗口
    UIView *additionalView_ = (UIView *)[[UIApplication sharedApplication].keyWindow viewWithTag:PROGRESS_ADDITIONAL_VIEW];
    [additionalView_ removeFromSuperview];
    if (additionalView != nil)
    {
        additionalView.tag = PROGRESS_ADDITIONAL_VIEW;
        additionalView.center = CGPointMake(frameframe.origin.x + frameframe.size.width / 2, frameframe.origin.y + frameframe.size.height + 10 + additionalView.frame.size.height / 2);
        [[UIApplication sharedApplication].keyWindow addSubview:additionalView];
    }
}

//关闭进度
+ (void)hideProgress
{
    UIView *backgroupView = (UIView *)[[UIApplication sharedApplication].keyWindow viewWithTag:BACKGROUND_VIEW];
    backgroupView.hidden = YES;
    UIView *frameView = (UIView *)[[UIApplication sharedApplication].keyWindow viewWithTag:PROGRESS_FRAME_VIEW];
    frameView.hidden = YES;
    UILabel *progressView = (UILabel *)[[UIApplication sharedApplication].keyWindow viewWithTag:PROGRESS_VIEW];
    progressView.hidden = YES;
    UILabel *progressInfo = (UILabel *)[[UIApplication sharedApplication].keyWindow viewWithTag:PROGRESS_INFO];
    progressInfo.hidden = YES;
    UIView *additionalViwe = (UIView *)[[UIApplication sharedApplication].keyWindow viewWithTag:PROGRESS_ADDITIONAL_VIEW];
    [additionalViwe removeFromSuperview];
}

+ (void)showToastWithError:(NSError *)error { 
    if ([error.userInfo stringObjectForkey:@"mess"].length > 0) {
        [BiChatGlobal showInfo:[error.userInfo stringObjectForkey:@"mess"] withIcon:Image(@"icon_alert")];
    } else {
        [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:Image(@"icon_alert")];
    }
}

+ (void)showSuccessWithString:(NSString *)string {
    //显示
    CGSize size = [UIScreen mainScreen].bounds.size ;
    AlertView *alert = [[AlertView alloc]initWithFrame: CGRectMake(0, 0, size.width, size.height)];
    alert.duration = 2;
    alert.enableClick = YES;
    [alert setAlertInfo:string withIcon:Image(@"icon_OK")];
    [[[UIApplication sharedApplication]keyWindow] addSubview:alert];
}

+ (void)showFailWithString:(NSString *)string {
    //显示
    CGSize size = [UIScreen mainScreen].bounds.size ;
    AlertView *alert = [[AlertView alloc]initWithFrame: CGRectMake(0, 0, size.width, size.height)];
    alert.duration = 2;
    alert.enableClick = YES;
    [alert setAlertInfo:string withIcon:Image(@"icon_alert")];
    [[[UIApplication sharedApplication]keyWindow] addSubview:alert];
}

+ (void)showFailWithResponse:(NSDictionary *)response {
    //显示
    CGSize size = [UIScreen mainScreen].bounds.size ;
    AlertView *alert = [[AlertView alloc]initWithFrame: CGRectMake(0, 0, size.width, size.height)];
    alert.duration = 2;
    alert.enableClick = YES;
    [alert setAlertInfo:[response objectForKey:@"mess"] withIcon:Image(@"icon_alert")];
    [[[UIApplication sharedApplication]keyWindow] addSubview:alert];
}

//显示一条字符信息
+(void)showInfo:(NSString *)info
       withIcon:(UIImage *)icon
{
    //没有文字和图标
    if (info.length == 0 && icon == nil)
        return;
    
    //显示
    CGSize size = [UIScreen mainScreen].bounds.size ;
    AlertView *alert = [[AlertView alloc]initWithFrame: CGRectMake(0, 0, size.width, size.height)];
    alert.duration = 2;
    alert.enableClick = YES;
    [alert setAlertInfo:info withIcon:icon];
    [[[UIApplication sharedApplication]keyWindow] addSubview:alert];
}

+ (void)showInfo:(NSString *)info withIcon:(UIImage *)icon duration:(CGFloat)duration enableClick:(BOOL)enableClick
{
    //没有文字和图标
    if (info.length == 0 && icon == nil)
        return;
    
    //显示
    CGSize size = [UIScreen mainScreen].bounds.size ;
    AlertView *alert = [[AlertView alloc]initWithFrame: CGRectMake(0, 0, size.width, size.height)];
    alert.duration = duration;
    alert.enableClick = enableClick;
    [alert setAlertInfo:info withIcon:icon];
    [[[UIApplication sharedApplication]keyWindow] addSubview:alert];
}

UIView *presentedModalView;
UIView *view4HoldModalView;
void(^dismissblock)(void);

+ (void)presentModalViewWithoutBackground:(UIView *)view4Present clickDismiss:(BOOL)clickDismiss delayDismiss:(NSTimeInterval)delayDismiss andDismissCallback:(void (^)(void))dismissCallback
{
    [view4HoldModalView removeFromSuperview];
    view4HoldModalView = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    view4HoldModalView.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication].keyWindow addSubview:view4HoldModalView];
    dismissblock = dismissCallback;
    
    if (clickDismiss)
    {
        UIButton *button4Dismiss = [[UIButton alloc]initWithFrame:view4HoldModalView.frame];
        [button4Dismiss addTarget:self action:@selector(onButtonDismiss:) forControlEvents:UIControlEventTouchUpInside];
        [view4HoldModalView addSubview:button4Dismiss];
    }
    
    view4Present.center = view4HoldModalView.center;
    [view4HoldModalView addSubview:view4Present];
    presentedModalView = view4Present;
    
    if (delayDismiss > 0)
    {
        [self performSelector:@selector(onButtonDismiss:) withObject:nil afterDelay:delayDismiss];
    }
}

+ (void)presentModalView:(UIView *)view4Present clickDismiss:(BOOL)clickDismiss delayDismiss:(NSTimeInterval)delayDismiss andDismissCallback:(void(^)(void))dismissCallback
{
    [view4HoldModalView removeFromSuperview];
    view4HoldModalView = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    view4HoldModalView.backgroundColor = [UIColor colorWithWhite:.2 alpha:.8];
    [[UIApplication sharedApplication].keyWindow addSubview:view4HoldModalView];
    dismissblock = dismissCallback;
    
    if (clickDismiss)
    {
        UIButton *button4Dismiss = [[UIButton alloc]initWithFrame:view4HoldModalView.frame];
        [button4Dismiss addTarget:self action:@selector(onButtonDismiss:) forControlEvents:UIControlEventTouchUpInside];
        [view4HoldModalView addSubview:button4Dismiss];
    }
    
    view4Present.center = view4HoldModalView.center;
    [view4HoldModalView addSubview:view4Present];
    presentedModalView = view4Present;
    
    if (delayDismiss > 0)
    {
        [self performSelector:@selector(onButtonDismiss:) withObject:nil afterDelay:delayDismiss];
    }
}

+ (UIView *)presentedModalView
{
    return presentedModalView;
}

+ (void)dismissModalView
{
    [view4HoldModalView removeFromSuperview];
    view4HoldModalView = nil;
    presentedModalView = nil;
}

+ (void)onButtonDismiss:(id)sender
{
    [self dismissModalView];
    if (dismissblock) dismissblock();
}

UIView *view4HoldModalViewFromBottom;
void(^dismissblockFromBottom)(void);

+ (void)presentModalViewFromBottom:(UIView *)view4Present clickDismiss:(BOOL)clickDismiss delayDismiss:(NSTimeInterval)delayDismiss andDismissCallback:(void(^)(void))dismissCallback
{
    [view4HoldModalViewFromBottom removeFromSuperview];
    view4HoldModalViewFromBottom = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    view4HoldModalViewFromBottom.backgroundColor = [UIColor colorWithWhite:.5 alpha:.5];
    [[UIApplication sharedApplication].keyWindow addSubview:view4HoldModalViewFromBottom];
    dismissblockFromBottom = dismissCallback;
    
    if (clickDismiss)
    {
        UIButton *button4Dismiss = [[UIButton alloc]initWithFrame:view4HoldModalViewFromBottom.frame];
        [button4Dismiss addTarget:self action:@selector(onButtonDismissFromBottom:) forControlEvents:UIControlEventTouchUpInside];
        [view4HoldModalViewFromBottom addSubview:button4Dismiss];
    }
    
    view4Present.frame = CGRectMake(0, [UIApplication sharedApplication].keyWindow.frame.size.height, [UIApplication sharedApplication].keyWindow.frame.size.width, view4Present.frame.size.height);
    [view4HoldModalViewFromBottom addSubview:view4Present];
    
    //显示动画
    [UIView beginAnimations:nil context:nil];
    view4Present.frame = CGRectMake(0, [UIApplication sharedApplication].keyWindow.frame.size.height - view4Present.frame.size.height, [UIApplication sharedApplication].keyWindow.frame.size.width, view4Present.frame.size.height);
    [UIView commitAnimations];
    
    if (delayDismiss > 0)
    {
        [self performSelector:@selector(onButtonDismiss:) withObject:nil afterDelay:delayDismiss];
    }
}

+ (void)dismissModalViewFromBottom
{
    [view4HoldModalViewFromBottom removeFromSuperview];
    view4HoldModalViewFromBottom = nil;
}

+ (void)onButtonDismissFromBottom:(id)sender
{
    [self dismissModalViewFromBottom];
    if (dismissblockFromBottom) dismissblockFromBottom();
}

//加载国家-电话区号对应表
- (void)loadCountryCode2AreaCode
{
    NSDictionary * codes = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"+972", @"IL", @"+93", @"AF", @"+355", @"AL", @"+213", @"DZ", @"+1", @"AS", @"+376", @"AD", @"+244", @"AO", @"+1", @"AI",
                            @"+1", @"AG", @"+54", @"AR", @"+374", @"AM", @"+297", @"AW", @"+61", @"AU", @"+43", @"AT", @"+994", @"AZ", @"+1", @"BS",
                            @"+973", @"BH", @"+880", @"BD", @"+1", @"BB", @"+375", @"BY", @"+32", @"BE", @"+501", @"BZ", @"+229", @"BJ", @"+1", @"BM",
                            @"+975", @"BT", @"+387", @"BA", @"+267", @"BW", @"+55", @"BR", @"+246", @"IO", @"+359", @"BG", @"+226", @"BF", @"+257", @"BI",
                            @"+855", @"KH", @"+237", @"CM", @"+1", @"CA", @"+238", @"CV", @"+345", @"KY", @"+236", @"CF", @"+235", @"TD", @"+56", @"CL",
                            @"+86", @"CN", @"+61", @"CX", @"+57", @"CO", @"+269", @"KM", @"+242", @"CG", @"+682", @"CK", @"+506", @"CR", @"+385", @"HR",
                            @"+53", @"CU", @"+537", @"CY", @"+420", @"CZ", @"+45", @"DK", @"+253", @"DJ", @"+1", @"DM", @"+1", @"DO", @"+593", @"EC",
                            @"+20", @"EG", @"+503", @"SV", @"+240", @"GQ", @"+291", @"ER", @"+372", @"EE", @"+251", @"ET", @"+298", @"FO", @"+679", @"FJ",
                            @"+358", @"FI", @"+33", @"FR", @"+594", @"GF", @"+689", @"PF", @"+241", @"GA", @"+220", @"GM", @"+995", @"GE", @"+49", @"DE",
                            @"+233", @"GH", @"+350", @"GI", @"+30", @"GR", @"+299", @"GL", @"+1", @"GD", @"+590", @"GP", @"+1", @"GU", @"+502", @"GT",
                            @"+224", @"GN", @"+245", @"GW", @"+595", @"GY", @"+509", @"HT", @"+504", @"HN", @"+36", @"HU", @"+354", @"IS", @"+91", @"IN",
                            @"+62", @"ID", @"+964", @"IQ", @"+353", @"IE", @"+972", @"IL", @"+39", @"IT", @"+1", @"JM", @"+81", @"JP", @"+962", @"JO",
                            @"+77", @"KZ", @"+254", @"KE", @"+686", @"KI", @"+965", @"KW", @"+996", @"KG", @"+371", @"LV", @"+961", @"LB", @"+266", @"LS",
                            @"+231", @"LR", @"+423", @"LI", @"+370", @"LT", @"+352", @"LU", @"+261", @"MG", @"+265", @"MW", @"+60", @"MY", @"+960", @"MV",
                            @"+223", @"ML", @"+356", @"MT", @"+692", @"MH", @"+596", @"MQ", @"+222", @"MR", @"+230", @"MU", @"+262", @"YT", @"+52", @"MX",
                            @"+377", @"MC", @"+976", @"MN", @"+382", @"ME", @"+1", @"MS", @"+212", @"MA", @"+95", @"MM", @"+264", @"NA", @"+674", @"NR",
                            @"+977", @"NP", @"+31", @"NL", @"+599", @"AN", @"+687", @"NC", @"+64", @"NZ", @"+505", @"NI", @"+227", @"NE", @"+234", @"NG",
                            @"+683", @"NU", @"+672", @"NF", @"+1", @"MP", @"+47", @"NO", @"+968", @"OM", @"+92", @"PK", @"+680", @"PW", @"+507", @"PA",
                            @"+675", @"PG", @"+595", @"PY", @"+51", @"PE", @"+63", @"PH", @"+48", @"PL", @"+351", @"PT", @"+1", @"PR", @"+974", @"QA",
                            @"+40", @"RO", @"+250", @"RW", @"+685", @"WS", @"+378", @"SM", @"+966", @"SA", @"+221", @"SN", @"+381", @"RS", @"+248", @"SC",
                            @"+232", @"SL", @"+65", @"SG", @"+421", @"SK", @"+386", @"SI", @"+677", @"SB", @"+27", @"ZA", @"+500", @"GS", @"+34", @"ES",
                            @"+94", @"LK", @"+249", @"SD", @"+597", @"SR", @"+268", @"SZ", @"+46", @"SE", @"+41", @"CH", @"+992", @"TJ", @"+66", @"TH",
                            @"+228", @"TG", @"+690", @"TK", @"+676", @"TO", @"+1", @"TT", @"+216", @"TN", @"+90", @"TR", @"+993", @"TM", @"+1", @"TC",
                            @"+688", @"TV", @"+256", @"UG", @"+380", @"UA", @"+971", @"AE", @"+44", @"GB", @"+1", @"US", @"+598", @"UY", @"+998", @"UZ",
                            @"+678", @"VU", @"+681", @"WF", @"+967", @"YE", @"+260", @"ZM", @"+263", @"ZW", @"+591", @"BO", @"+673", @"BN", @"+61", @"CC",
                            @"+243", @"CD", @"+225", @"CI", @"+500", @"FK", @"+44", @"GG", @"+379", @"VA", @"+852", @"HK", @"+98", @"IR", @"+44", @"IM",
                            @"+44", @"JE", @"+850", @"KP", @"+82", @"KR", @"+856", @"LA", @"+218", @"LY", @"+853", @"MO", @"+389", @"MK", @"+691", @"FM",
                            @"+373", @"MD", @"+258", @"MZ", @"+970", @"PS", @"+872", @"PN", @"+262", @"RE", @"+7", @"RU", @"+590", @"BL", @"+290", @"SH",
                            @"+1", @"KN", @"+1", @"LC", @"+590", @"MF", @"+508", @"PM", @"+1", @"VC", @"+239", @"ST", @"+252", @"SO", @"+47", @"SJ",
                            @"+", @"SY", @"+886", @"TW", @"+255", @"TZ", @"+670", @"TL", @"+58", @"VE", @"+84", @"VN", @"+1", @"VG", @"+1", @"VI", nil];
    _dict4CountryCode2AreaCode = codes;
}

//加载国家地区电话号码编号
- (void)loadAreaCode
{
    NSString *str4CountryInfo_CN = @"["
    "{\"country\":\"中国\", \"flag\":\"🇨🇳\", \"code\": \"+86\", \"sticky\": \"1\"},"
    "{\"country\":\"香港\", \"flag\":\"🇭🇰\", \"code\": \"+852\", \"sticky\": \"1\"},"
    "{\"country\":\"澳门\", \"flag\":\"🇲🇴\", \"code\": \"+853\", \"sticky\": \"1\"},"
    "{\"country\":\"台湾\", \"flag\":\"🇨🇳\", \"code\": \"+886\", \"sticky\": \"1\"},"
    "{\"country\":\"新加坡\", \"flag\":\"🇸🇬\", \"code\": \"+65\", \"sticky\": \"1\"},"
    "{\"country\":\"日本\", \"flag\":\"🇯🇵\", \"code\": \"+81\", \"sticky\": \"1\"},"
    "{\"country\":\"韩国\", \"flag\":\"🇰🇷\", \"code\": \"+82\", \"sticky\": \"1\"},"
    "{\"country\":\"美国\", \"flag\":\"🇺🇸\", \"code\": \"+1\", \"sticky\": \"1\"},"
    "{\"country\":\"加拿大\", \"flag\":\"🇨🇦\", \"code\": \"+1\", \"sticky\": \"1\"},"
    "{\"country\":\"英国\", \"flag\":\"🇬🇧\", \"code\": \"+44\", \"sticky\": \"1\"},"
    "{\"country\":\"澳大利亚\", \"flag\":\"🇦🇺\", \"code\": \"+61\", \"sticky\": \"1\"},"
    "{\"country\":\"新西兰\", \"flag\":\"🇳🇿\", \"code\": \"+64\", \"sticky\": \"1\"},"
    "{\"country\":\"阿森松岛\", \"flag\":\"🇦🇨\", \"code\": \"+247\", \"sticky\": \"0\"},"
    "{\"country\":\"安道尔\", \"flag\":\"🇦🇩\", \"code\": \"+376\", \"sticky\": \"0\"},"
    "{\"country\":\"阿拉伯联合酋长国\", \"flag\":\"🇦🇪\", \"code\": \"+971\", \"sticky\": \"0\"},"
    "{\"country\":\"阿富汗\", \"flag\":\"🇦🇫\", \"code\": \"+93\", \"sticky\": \"0\"},"
    "{\"country\":\"安提瓜和巴布达\", \"flag\":\"🇦🇬\", \"code\": \"+1268\", \"sticky\": \"0\"},"
    "{\"country\":\"安圭拉\", \"flag\":\"🇦🇮\", \"code\": \"+1264\", \"sticky\": \"0\"},"
    "{\"country\":\"阿尔巴尼亚\", \"flag\":\"🇦🇱\", \"code\": \"+355\", \"sticky\": \"0\"},"
    "{\"country\":\"亚美尼亚\", \"flag\":\"🇦🇲\", \"code\": \"+374\", \"sticky\": \"0\"},"
    "{\"country\":\"安哥拉\", \"flag\":\"🇦🇴\", \"code\": \"+244\", \"sticky\": \"0\"},"
    "{\"country\":\"阿根廷\", \"flag\":\"🇦🇷\", \"code\": \"+54\", \"sticky\": \"0\"},"
    "{\"country\":\"美属萨摩亚群岛\", \"flag\":\"🇦🇸\", \"code\": \"+1684\", \"sticky\": \"0\"},"
    "{\"country\":\"奥地利\", \"flag\":\"🇦🇹\", \"code\": \"+43\", \"sticky\": \"0\"},"
    "{\"country\":\"阿鲁巴\", \"flag\":\"🇦🇼\", \"code\": \"+297\", \"sticky\": \"0\"},"
    "{\"country\":\"阿塞拜疆\", \"flag\":\"🇦🇿\", \"code\": \"+994\", \"sticky\": \"0\"},"
    "{\"country\":\"巴巴多斯\", \"flag\":\"🇧🇧\", \"code\": \"+1246\", \"sticky\": \"0\"},"
    "{\"country\":\"孟加拉国\", \"flag\":\"🇧🇩\", \"code\": \"+880\", \"sticky\": \"0\"},"
    "{\"country\":\"比利时\", \"flag\":\"🇧🇪\", \"code\": \"+32\", \"sticky\": \"0\"},"
    "{\"country\":\"布基纳法索\", \"flag\":\"🇧🇫\", \"code\": \"+226\", \"sticky\": \"0\"},"
    "{\"country\":\"保加利亚\", \"flag\":\"🇧🇬\", \"code\": \"+359\", \"sticky\": \"0\"},"
    "{\"country\":\"巴林\", \"flag\":\"🇧🇭\", \"code\": \"+973\", \"sticky\": \"0\"},"
    "{\"country\":\"布隆迪\", \"flag\":\"🇧🇮\", \"code\": \"+257\", \"sticky\": \"0\"},"
    "{\"country\":\"贝宁\", \"flag\":\"🇧🇯\", \"code\": \"+229\", \"sticky\": \"0\"},"
    "{\"country\":\"百慕大\", \"flag\":\"🇧🇲\", \"code\": \"+1441\", \"sticky\": \"0\"},"
    "{\"country\":\"文莱\", \"flag\":\"🇧🇳\", \"code\": \"+673\", \"sticky\": \"0\"},"
    "{\"country\":\"玻利维亚\", \"flag\":\"🇧🇴\", \"code\": \"+591\", \"sticky\": \"0\"},"
    "{\"country\":\"博内尔岛，圣尤斯特歇斯和\", \"flag\":\"🇧🇶\", \"code\": \"+599\", \"sticky\": \"0\"},"
    "{\"country\":\"巴西\", \"flag\":\"🇧🇷\", \"code\": \"+55\", \"sticky\": \"0\"},"
    "{\"country\":\"巴哈马\", \"flag\":\"🇧🇸\", \"code\": \"+1242\", \"sticky\": \"0\"},"
    "{\"country\":\"不丹\", \"flag\":\"🇧🇹\", \"code\": \"+975\", \"sticky\": \"0\"},"
    "{\"country\":\"博茨瓦纳\", \"flag\":\"🇧🇼\", \"code\": \"+267\", \"sticky\": \"0\"},"
    "{\"country\":\"白俄罗斯\", \"flag\":\"🇧🇾\", \"code\": \"+375\", \"sticky\": \"0\"},"
    "{\"country\":\"伯利兹\", \"flag\":\"🇧🇿\", \"code\": \"+501\", \"sticky\": \"0\"},"
    "{\"country\":\"刚果(金)\", \"flag\":\"🇨🇩\", \"code\": \"+242\", \"sticky\": \"0\"},"
    "{\"country\":\"中非共和国\", \"flag\":\"🇨🇫\", \"code\": \"+236\", \"sticky\": \"0\"},"
    "{\"country\":\"刚果(布)\", \"flag\":\"🇨🇬\", \"code\": \"+243\", \"sticky\": \"0\"},"
    "{\"country\":\"瑞士\", \"flag\":\"🇨🇭\", \"code\": \"+41\", \"sticky\": \"0\"},"
    "{\"country\":\"科特迪瓦\", \"flag\":\"🇨🇮\", \"code\": \"+225\", \"sticky\": \"0\"},"
    "{\"country\":\"库克群岛\", \"flag\":\"🇨🇰\", \"code\": \"+682\", \"sticky\": \"0\"},"
    "{\"country\":\"智利\", \"flag\":\"🇨🇱\", \"code\": \"+56\", \"sticky\": \"0\"},"
    "{\"country\":\"喀麦隆\", \"flag\":\"🇨🇲\", \"code\": \"+237\", \"sticky\": \"0\"},"
    "{\"country\":\"哥伦比亚\", \"flag\":\"🇨🇴\", \"code\": \"+57\", \"sticky\": \"0\"},"
    "{\"country\":\"哥斯达黎加\", \"flag\":\"🇨🇷\", \"code\": \"+506\", \"sticky\": \"0\"},"
    "{\"country\":\"古巴\", \"flag\":\"🇨🇺\", \"code\": \"+53\", \"sticky\": \"0\"},"
    "{\"country\":\"佛得角\", \"flag\":\"🇨🇻\", \"code\": \"+238\", \"sticky\": \"0\"},"
    "{\"country\":\"库拉索\", \"flag\":\"🇨🇼\", \"code\": \"+599\", \"sticky\": \"0\"},"
    "{\"country\":\"塞浦路斯\", \"flag\":\"🇨🇾\", \"code\": \"+357\", \"sticky\": \"0\"},"
    "{\"country\":\"捷克共和国\", \"flag\":\"🇨🇿\", \"code\": \"+420\", \"sticky\": \"0\"},"
    "{\"country\":\"德国\", \"flag\":\"🇩🇪\", \"code\": \"+49\", \"sticky\": \"0\"},"
    "{\"country\":\"吉布提\", \"flag\":\"🇩🇯\", \"code\": \"+253\", \"sticky\": \"0\"},"
    "{\"country\":\"丹麦\", \"flag\":\"🇩🇰\", \"code\": \"+45\", \"sticky\": \"0\"},"
    "{\"country\":\"多明尼加共和国\", \"flag\":\"🇩🇴\", \"code\": \"+1809\", \"sticky\": \"0\"},"
    "{\"country\":\"阿尔及利亚\", \"flag\":\"🇩🇿\", \"code\": \"+213\", \"sticky\": \"0\"},"
    "{\"country\":\"厄瓜多尔\", \"flag\":\"🇪🇨\", \"code\": \"+593\", \"sticky\": \"0\"},"
    "{\"country\":\"爱沙尼亚\", \"flag\":\"🇪🇪\", \"code\": \"+371\", \"sticky\": \"0\"},"
    "{\"country\":\"埃及\", \"flag\":\"🇪🇬\", \"code\": \"+20\", \"sticky\": \"0\"},"
    "{\"country\":\"西班牙\", \"flag\":\"🇪🇸\", \"code\": \"+34\", \"sticky\": \"0\"},"
    "{\"country\":\"埃塞俄比亚\", \"flag\":\"🇪🇹\", \"code\": \"+251\", \"sticky\": \"0\"},"
    "{\"country\":\"芬兰\", \"flag\":\"🇫🇮\", \"code\": \"+358\", \"sticky\": \"0\"},"
    "{\"country\":\"斐济\", \"flag\":\"🇫🇯\", \"code\": \"+679\", \"sticky\": \"0\"},"
    "{\"country\":\"法罗群岛\", \"flag\":\"🇫🇴\", \"code\": \"+298\", \"sticky\": \"0\"},"
    "{\"country\":\"法国\", \"flag\":\"🇫🇷\", \"code\": \"+33\", \"sticky\": \"0\"},"
    "{\"country\":\"加蓬\", \"flag\":\"🇬🇦\", \"code\": \"+241\", \"sticky\": \"0\"},"
    "{\"country\":\"格林纳达\", \"flag\":\"🇬🇩\", \"code\": \"+1809\", \"sticky\": \"0\"},"
    "{\"country\":\"格鲁吉亚\", \"flag\":\"🇬🇪\", \"code\": \"+995\", \"sticky\": \"0\"},"
    "{\"country\":\"法属圭亚那\", \"flag\":\"🇬🇫\", \"code\": \"+594\", \"sticky\": \"0\"},"
    "{\"country\":\"加纳\", \"flag\":\"🇬🇭\", \"code\": \"+233\", \"sticky\": \"0\"},"
    "{\"country\":\"直布罗陀\", \"flag\":\"🇬🇮\", \"code\": \"+350\", \"sticky\": \"0\"},"
    "{\"country\":\"格陵兰\", \"flag\":\"🇬🇱\", \"code\": \"+299\", \"sticky\": \"0\"},"
    "{\"country\":\"冈比亚\", \"flag\":\"🇬🇲\", \"code\": \"+220\", \"sticky\": \"0\"},"
    "{\"country\":\"几内亚\", \"flag\":\"🇬🇳\", \"code\": \"+224\", \"sticky\": \"0\"},"
    "{\"country\":\"瓜德罗普岛\", \"flag\":\"🇬🇵\", \"code\": \"+590\", \"sticky\": \"0\"},"
    "{\"country\":\"赤道几内亚\", \"flag\":\"🇬🇶\", \"code\": \"+240\", \"sticky\": \"0\"},"
    "{\"country\":\"希腊\", \"flag\":\"🇬🇷\", \"code\": \"+30\", \"sticky\": \"0\"},"
    "{\"country\":\"危地马拉\", \"flag\":\"🇬🇹\", \"code\": \"+502\", \"sticky\": \"0\"},"
    "{\"country\":\"关岛\", \"flag\":\"🇬🇺\", \"code\": \"+1671\", \"sticky\": \"0\"},"
    "{\"country\":\"几内亚比绍\", \"flag\":\"🇬🇼\", \"code\": \"+245\", \"sticky\": \"0\"},"
    "{\"country\":\"圭亚那\", \"flag\":\"🇬🇾\", \"code\": \"+592\", \"sticky\": \"0\"},"
    "{\"country\":\"洪都拉斯\", \"flag\":\"🇭🇳\", \"code\": \"+504\", \"sticky\": \"0\"},"
    "{\"country\":\"克罗地亚\", \"flag\":\"🇭🇷\", \"code\": \"+385\", \"sticky\": \"0\"},"
    "{\"country\":\"海地\", \"flag\":\"🇭🇹\", \"code\": \"+509\", \"sticky\": \"0\"},"
    "{\"country\":\"匈牙利\", \"flag\":\"🇭🇺\", \"code\": \"+36\", \"sticky\": \"0\"},"
    "{\"country\":\"印度尼西亚\", \"flag\":\"🇮🇩\", \"code\": \"+62\", \"sticky\": \"0\"},"
    "{\"country\":\"爱尔兰\", \"flag\":\"🇮🇪\", \"code\": \"+353\", \"sticky\": \"0\"},"
    "{\"country\":\"以色列\", \"flag\":\"🇮🇱\", \"code\": \"+972\", \"sticky\": \"0\"},"
    "{\"country\":\"印度\", \"flag\":\"🇮🇳\", \"code\": \"+91\", \"sticky\": \"0\"},"
    "{\"country\":\"伊拉克\", \"flag\":\"🇮🇶\", \"code\": \"+964\", \"sticky\": \"0\"},"
    "{\"country\":\"伊朗\", \"flag\":\"🇮🇷\", \"code\": \"+98\", \"sticky\": \"0\"},"
    "{\"country\":\"冰岛\", \"flag\":\"🇮🇸\", \"code\": \"+354\", \"sticky\": \"0\"},"
    "{\"country\":\"意大利\", \"flag\":\"🇮🇹\", \"code\": \"+39\", \"sticky\": \"0\"},"
    "{\"country\":\"牙买加\", \"flag\":\"🇯🇲\", \"code\": \"+1876\", \"sticky\": \"0\"},"
    "{\"country\":\"约旦\", \"flag\":\"🇯🇴\", \"code\": \"+962\", \"sticky\": \"0\"},"
    "{\"country\":\"肯尼亚\", \"flag\":\"🇰🇪\", \"code\": \"+254\", \"sticky\": \"0\"},"
    "{\"country\":\"吉尔吉斯斯坦\", \"flag\":\"🇰🇬\", \"code\": \"+996\", \"sticky\": \"0\"},"
    "{\"country\":\"柬埔寨\", \"flag\":\"🇰🇭\", \"code\": \"+855\", \"sticky\": \"0\"},"
    "{\"country\":\"基里巴斯\", \"flag\":\"🇰🇮\", \"code\": \"+686\", \"sticky\": \"0\"},"
    "{\"country\":\"科摩罗\", \"flag\":\"🇰🇲\", \"code\": \"+269\", \"sticky\": \"0\"},"
    "{\"country\":\"圣基茨和尼维斯\", \"flag\":\"🇰🇳\", \"code\": \"+1869\", \"sticky\": \"0\"},"
    "{\"country\":\"科威特\", \"flag\":\"🇰🇼\", \"code\": \"+965\", \"sticky\": \"0\"},"
    "{\"country\":\"开曼群岛\", \"flag\":\"🇰🇾\", \"code\": \"+1345\", \"sticky\": \"0\"},"
    "{\"country\":\"老挝\", \"flag\":\"🇱🇦\", \"code\": \"+856\", \"sticky\": \"0\"},"
    "{\"country\":\"黎巴嫩\", \"flag\":\"🇱🇧\", \"code\": \"+961\", \"sticky\": \"0\"},"
    "{\"country\":\"圣卢西亚\", \"flag\":\"🇱🇨\", \"code\": \"+1758\", \"sticky\": \"0\"},"
    "{\"country\":\"列支敦士登\", \"flag\":\"🇱🇮\", \"code\": \"+423\", \"sticky\": \"0\"},"
    "{\"country\":\"斯里兰卡\", \"flag\":\"🇱🇰\", \"code\": \"+94\", \"sticky\": \"0\"},"
    "{\"country\":\"利比里亚\", \"flag\":\"🇱🇷\", \"code\": \"+231\", \"sticky\": \"0\"},"
    "{\"country\":\"莱索托\", \"flag\":\"🇱🇸\", \"code\": \"+266\", \"sticky\": \"0\"},"
    "{\"country\":\"立陶宛\", \"flag\":\"🇱🇹\", \"code\": \"+370\", \"sticky\": \"0\"},"
    "{\"country\":\"卢森堡\", \"flag\":\"🇱🇺\", \"code\": \"+352\", \"sticky\": \"0\"},"
    "{\"country\":\"拉脱维亚\", \"flag\":\"🇱🇻\", \"code\": \"+371\", \"sticky\": \"0\"},"
    "{\"country\":\"利比亚\", \"flag\":\"🇱🇾\", \"code\": \"+218\", \"sticky\": \"0\"},"
    "{\"country\":\"摩洛哥\", \"flag\":\"🇲🇦\", \"code\": \"+212\", \"sticky\": \"0\"},"
    "{\"country\":\"摩纳哥\", \"flag\":\"🇲🇨\", \"code\": \"+377\", \"sticky\": \"0\"},"
    "{\"country\":\"摩尔多瓦\", \"flag\":\"🇲🇩\", \"code\": \"+373\", \"sticky\": \"0\"},"
    "{\"country\":\"黑山\", \"flag\":\"🇲🇪\", \"code\": \"+382\", \"sticky\": \"0\"},"
    "{\"country\":\"马达加斯加\", \"flag\":\"🇲🇬\", \"code\": \"+261\", \"sticky\": \"0\"},"
    "{\"country\":\"马其顿\", \"flag\":\"🇲🇰\", \"code\": \"+389\", \"sticky\": \"0\"},"
    "{\"country\":\"马里\", \"flag\":\"🇲🇱\", \"code\": \"+223\", \"sticky\": \"0\"},"
    "{\"country\":\"缅甸\", \"flag\":\"🇲🇲\", \"code\": \"+95\", \"sticky\": \"0\"},"
    "{\"country\":\"蒙古\", \"flag\":\"🇲🇳\", \"code\": \"+976\", \"sticky\": \"0\"},"
    "{\"country\":\"马提尼克岛\", \"flag\":\"🇲🇶\", \"code\": \"+596\", \"sticky\": \"0\"},"
    "{\"country\":\"毛里塔尼亚\", \"flag\":\"🇲🇷\", \"code\": \"+222\", \"sticky\": \"0\"},"
    "{\"country\":\"蒙特塞拉特\", \"flag\":\"🇲🇸\", \"code\": \"+1664\", \"sticky\": \"0\"},"
    "{\"country\":\"马耳他\", \"flag\":\"🇲🇹\", \"code\": \"+356\", \"sticky\": \"0\"},"
    "{\"country\":\"毛里求斯\", \"flag\":\"🇲🇺\", \"code\": \"+230\", \"sticky\": \"0\"},"
    "{\"country\":\"马尔代夫\", \"flag\":\"🇲🇻\", \"code\": \"+960\", \"sticky\": \"0\"},"
    "{\"country\":\"马拉维\", \"flag\":\"🇲🇼\", \"code\": \"+265\", \"sticky\": \"0\"},"
    "{\"country\":\"墨西哥\", \"flag\":\"🇲🇽\", \"code\": \"+52\", \"sticky\": \"0\"},"
    "{\"country\":\"马来西亚\", \"flag\":\"🇲🇾\", \"code\": \"+60\", \"sticky\": \"0\"},"
    "{\"country\":\"莫桑比克\", \"flag\":\"🇲🇿\", \"code\": \"+258\", \"sticky\": \"0\"},"
    "{\"country\":\"纳米比亚\", \"flag\":\"🇳🇦\", \"code\": \"+264\", \"sticky\": \"0\"},"
    "{\"country\":\"新喀里多尼亚\", \"flag\":\"🇳🇨\", \"code\": \"+687\", \"sticky\": \"0\"},"
    "{\"country\":\"尼日尔\", \"flag\":\"🇳🇪\", \"code\": \"+227\", \"sticky\": \"0\"},"
    "{\"country\":\"尼日利亚\", \"flag\":\"🇳🇬\", \"code\": \"+234\", \"sticky\": \"0\"},"
    "{\"country\":\"尼加拉瓜\", \"flag\":\"🇳🇮\", \"code\": \"+505\", \"sticky\": \"0\"},"
    "{\"country\":\"荷兰\", \"flag\":\"🇳🇱\", \"code\": \"+31\", \"sticky\": \"0\"},"
    "{\"country\":\"挪威\", \"flag\":\"🇳🇴\", \"code\": \"+47\", \"sticky\": \"0\"},"
    "{\"country\":\"尼泊尔\", \"flag\":\"🇳🇵\", \"code\": \"+977\", \"sticky\": \"0\"},"
    "{\"country\":\"阿曼\", \"flag\":\"🇴🇲\", \"code\": \"+968\", \"sticky\": \"0\"},"
    "{\"country\":\"巴拿马\", \"flag\":\"🇵🇦\", \"code\": \"+507\", \"sticky\": \"0\"},"
    "{\"country\":\"秘鲁\", \"flag\":\"🇵🇪\", \"code\": \"+51\", \"sticky\": \"0\"},"
    "{\"country\":\"法属波利尼西亚\", \"flag\":\"🇵🇫\", \"code\": \"+689\", \"sticky\": \"0\"},"
    "{\"country\":\"巴布亚新几内亚\", \"flag\":\"🇵🇬\", \"code\": \"+675\", \"sticky\": \"0\"},"
    "{\"country\":\"菲律宾\", \"flag\":\"🇵🇭\", \"code\": \"+63\", \"sticky\": \"0\"},"
    "{\"country\":\"巴基斯坦\", \"flag\":\"🇵🇰\", \"code\": \"+92\", \"sticky\": \"0\"},"
    "{\"country\":\"波兰\", \"flag\":\"🇵🇱\", \"code\": \"+48\", \"sticky\": \"0\"},"
    "{\"country\":\"圣皮埃尔和密克隆群岛\", \"flag\":\"🇵🇲\", \"code\": \"+508\", \"sticky\": \"0\"},"
    "{\"country\":\"波多黎各\", \"flag\":\"🇵🇷\", \"code\": \"+1787\", \"sticky\": \"0\"},"
    "{\"country\":\"巴勒斯坦\", \"flag\":\"🇵🇸\", \"code\": \"+970\", \"sticky\": \"0\"},"
    "{\"country\":\"葡萄牙\", \"flag\":\"🇵🇹\", \"code\": \"+351\", \"sticky\": \"0\"},"
    "{\"country\":\"帕劳\", \"flag\":\"🇵🇼\", \"code\": \"+680\", \"sticky\": \"0\"},"
    "{\"country\":\"巴拉圭\", \"flag\":\"🇵🇾\", \"code\": \"+595\", \"sticky\": \"0\"},"
    "{\"country\":\"卡塔尔\", \"flag\":\"🇶🇦\", \"code\": \"+974\", \"sticky\": \"0\"},"
    "{\"country\":\"罗马尼亚\", \"flag\":\"🇷🇴\", \"code\": \"+40\", \"sticky\": \"0\"},"
    "{\"country\":\"塞尔维亚\", \"flag\":\"🇷🇸\", \"code\": \"+381\", \"sticky\": \"0\"},"
    "{\"country\":\"俄罗斯\", \"flag\":\"🇷🇺\", \"code\": \"+7\", \"sticky\": \"0\"},"
    "{\"country\":\"卢旺达\", \"flag\":\"🇷🇼\", \"code\": \"+250\", \"sticky\": \"0\"},"
    "{\"country\":\"沙特阿拉伯\", \"flag\":\"🇸🇦\", \"code\": \"+966\", \"sticky\": \"0\"},"
    "{\"country\":\"所罗门群岛\", \"flag\":\"🇸🇧\", \"code\": \"+677\", \"sticky\": \"0\"},"
    "{\"country\":\"塞舌尔\", \"flag\":\"🇸🇨\", \"code\": \"+248\", \"sticky\": \"0\"},"
    "{\"country\":\"苏丹\", \"flag\":\"🇸🇩\", \"code\": \"+249\", \"sticky\": \"0\"},"
    "{\"country\":\"瑞典\", \"flag\":\"🇸🇪\", \"code\": \"+46\", \"sticky\": \"0\"},"
    "{\"country\":\"斯洛文尼亚\", \"flag\":\"🇸🇮\", \"code\": \"+386\", \"sticky\": \"0\"},"
    "{\"country\":\"斯洛伐克\", \"flag\":\"🇸🇰\", \"code\": \"+421\", \"sticky\": \"0\"},"
    "{\"country\":\"塞拉利昂\", \"flag\":\"🇸🇱\", \"code\": \"+232\", \"sticky\": \"0\"},"
    "{\"country\":\"圣马力诺\", \"flag\":\"🇸🇲\", \"code\": \"+223\", \"sticky\": \"0\"},"
    "{\"country\":\"塞内加尔\", \"flag\":\"🇸🇳\", \"code\": \"+221\", \"sticky\": \"0\"},"
    "{\"country\":\"索马里\", \"flag\":\"🇸🇴\", \"code\": \"+252\", \"sticky\": \"0\"},"
    "{\"country\":\"苏里南\", \"flag\":\"🇸🇷\", \"code\": \"+597\", \"sticky\": \"0\"},"
    "{\"country\":\"南苏丹\", \"flag\":\"🇸🇸\", \"code\": \"+211\", \"sticky\": \"0\"},"
    "{\"country\":\"圣多美和普林西比\", \"flag\":\"🇸🇹\", \"code\": \"+239\", \"sticky\": \"0\"},"
    "{\"country\":\"萨尔瓦多\", \"flag\":\"🇸🇻\", \"code\": \"+503\", \"sticky\": \"0\"},"
    "{\"country\":\"圣马丁岛\", \"flag\":\"🇸🇽\", \"code\": \"+590\", \"sticky\": \"0\"},"
    "{\"country\":\"叙利亚\", \"flag\":\"🇸🇾\", \"code\": \"+963\", \"sticky\": \"0\"},"
    "{\"country\":\"斯威士兰\", \"flag\":\"🇸🇿\", \"code\": \"+268\", \"sticky\": \"0\"},"
    "{\"country\":\"特克斯和凯科斯群岛\", \"flag\":\"🇹🇨\", \"code\": \"+1649\", \"sticky\": \"0\"},"
    "{\"country\":\"乍得\", \"flag\":\"🇹🇩\", \"code\": \"+235\", \"sticky\": \"0\"},"
    "{\"country\":\"多哥\", \"flag\":\"🇹🇬\", \"code\": \"+228\", \"sticky\": \"0\"},"
    "{\"country\":\"泰国\", \"flag\":\"🇹🇭\", \"code\": \"+66\", \"sticky\": \"0\"},"
    "{\"country\":\"东帝汶\", \"flag\":\"🇹🇱\", \"code\": \"+670\", \"sticky\": \"0\"},"
    "{\"country\":\"土库曼斯坦\", \"flag\":\"🇹🇲\", \"code\": \"+993\", \"sticky\": \"0\"},"
    "{\"country\":\"突尼斯\", \"flag\":\"🇹🇳\", \"code\": \"+216\", \"sticky\": \"0\"},"
    "{\"country\":\"汤加\", \"flag\":\"🇹🇴\", \"code\": \"+676\", \"sticky\": \"0\"},"
    "{\"country\":\"土耳其\", \"flag\":\"🇹🇷\", \"code\": \"+90\", \"sticky\": \"0\"},"
    "{\"country\":\"特立尼达和多巴哥\", \"flag\":\"🇹🇹\", \"code\": \"+1809\", \"sticky\": \"0\"},"
    "{\"country\":\"坦桑尼亚\", \"flag\":\"🇹🇿\", \"code\": \"+255\", \"sticky\": \"0\"},"
    "{\"country\":\"乌克兰\", \"flag\":\"🇺🇦\", \"code\": \"+380\", \"sticky\": \"0\"},"
    "{\"country\":\"乌干达\", \"flag\":\"🇺🇬\", \"code\": \"+256\", \"sticky\": \"0\"},"
    "{\"country\":\"乌拉圭\", \"flag\":\"🇺🇾\", \"code\": \"+598\", \"sticky\": \"0\"},"
    "{\"country\":\"乌兹别克斯坦\", \"flag\":\"🇺🇿\", \"code\": \"+233\", \"sticky\": \"0\"},"
    "{\"country\":\"圣文森特和格林纳丁斯\", \"flag\":\"🇻🇨\", \"code\": \"+1784\", \"sticky\": \"0\"},"
    "{\"country\":\"委内瑞拉\", \"flag\":\"🇻🇪\", \"code\": \"+58\", \"sticky\": \"0\"},"
    "{\"country\":\"英属维京群岛\", \"flag\":\"🇻🇬\", \"code\": \"+1284\", \"sticky\": \"0\"},"
    "{\"country\":\"美属维京群岛\", \"flag\":\"🇻🇮\", \"code\": \"+1340\", \"sticky\": \"0\"},"
    "{\"country\":\"越南\", \"flag\":\"🇻🇳\", \"code\": \"+84\", \"sticky\": \"0\"},"
    "{\"country\":\"瓦努阿图共和国\", \"flag\":\"🇻🇺\", \"code\": \"+678\", \"sticky\": \"0\"},"
    "{\"country\":\"萨摩亚\", \"flag\":\"🇼🇸\", \"code\": \"+685\", \"sticky\": \"0\"},"
    "{\"country\":\"也门\", \"flag\":\"🇾🇪\", \"code\": \"+967\", \"sticky\": \"0\"},"
    "{\"country\":\"马约特\", \"flag\":\"🇾🇹\", \"code\": \"+262\", \"sticky\": \"0\"},"
    "{\"country\":\"南非\", \"flag\":\"🇿🇦\", \"code\": \"+27\", \"sticky\": \"0\"},"
    "{\"country\":\"赞比亚\", \"flag\":\"🇿🇲\", \"code\": \"+260\", \"sticky\": \"0\"},"
    "{\"country\":\"津巴布韦\", \"flag\":\"🇿🇼\", \"code\": \"+263\"}"
    "]";
    
    
    NSString *str4CountryInfo_En = @"["
    "{\"country\":\"China\", \"flag\":\"🇨🇳\", \"code\": \"+86\", \"sticky\": \"1\"},"
    "{\"country\":\"Hong Kong\", \"flag\":\"🇭🇰\", \"code\": \"+852\", \"sticky\": \"1\"},"
    "{\"country\":\"Macao\", \"flag\":\"🇲🇴\", \"code\": \"+853\", \"sticky\": \"1\"},"
    "{\"country\":\"Taiwan\", \"flag\":\"🇨🇳\", \"code\": \"+886\", \"sticky\": \"1\"},"
    "{\"country\":\"Singapore\", \"flag\":\"🇸🇬\", \"code\": \"+65\", \"sticky\": \"1\"},"
    "{\"country\":\"Japan\", \"flag\":\"🇯🇵\", \"code\": \"+81\", \"sticky\": \"1\"},"
    "{\"country\":\"Korea, Republic of\", \"flag\":\"🇰🇷\", \"code\": \"+82\", \"sticky\": \"1\"},"
    "{\"country\":\"United States\", \"flag\":\"🇺🇸\", \"code\": \"+1\", \"sticky\": \"1\"},"
    "{\"country\":\"Canada\", \"flag\":\"🇨🇦\", \"code\": \"+1\", \"sticky\": \"1\"},"
    "{\"country\":\"Australia\", \"flag\":\"🇦🇺\", \"code\": \"+61\", \"sticky\": \"1\"},"
    "{\"country\":\"New Zealand\", \"flag\":\"🇳🇿\", \"code\": \"+64\", \"sticky\": \"1\"},"
    "{\"country\":\"Ascension island\", \"flag\":\"🇦🇨\", \"code\": \"+247\", \"sticky\": \"0\"},"
    "{\"country\":\"Andorra\", \"flag\":\"🇦🇩\", \"code\": \"+376\", \"sticky\": \"0\"},"
    "{\"country\":\"United Arab Emirates\", \"flag\":\"🇦🇪\", \"code\": \"+971\", \"sticky\": \"0\"},"
    "{\"country\":\"Afghanistan\", \"flag\":\"🇦🇫\", \"code\": \"+93\", \"sticky\": \"0\"},"
    "{\"country\":\"Antigua and Barbuda\", \"flag\":\"🇦🇬\", \"code\": \"+1268\", \"sticky\": \"0\"},"
    "{\"country\":\"Anguilla\", \"flag\":\"🇦🇮\", \"code\": \"+1264\", \"sticky\": \"0\"},"
    "{\"country\":\"Albania\", \"flag\":\"🇦🇱\", \"code\": \"+355\", \"sticky\": \"0\"},"
    "{\"country\":\"Armenia\", \"flag\":\"🇦🇲\", \"code\": \"+374\", \"sticky\": \"0\"},"
    "{\"country\":\"Angola\", \"flag\":\"🇦🇴\", \"code\": \"+244\", \"sticky\": \"0\"},"
    "{\"country\":\"Argentina\", \"flag\":\"🇦🇷\", \"code\": \"+54\", \"sticky\": \"0\"},"
    "{\"country\":\"American Samoa\", \"flag\":\"🇦🇸\", \"code\": \"+1684\", \"sticky\": \"0\"},"
    "{\"country\":\"Austria\", \"flag\":\"🇦🇹\", \"code\": \"+43\", \"sticky\": \"0\"},"
    "{\"country\":\"Aruba\", \"flag\":\"🇦🇼\", \"code\": \"+297\", \"sticky\": \"0\"},"
    "{\"country\":\"Azerbaijan\", \"flag\":\"🇦🇿\", \"code\": \"+994\", \"sticky\": \"0\"},"
    "{\"country\":\"Barbados\", \"flag\":\"🇧🇧\", \"code\": \"+1246\", \"sticky\": \"0\"},"
    "{\"country\":\"Bangladesh\", \"flag\":\"🇧🇩\", \"code\": \"+880\", \"sticky\": \"0\"},"
    "{\"country\":\"Belgium\", \"flag\":\"🇧🇪\", \"code\": \"+32\", \"sticky\": \"0\"},"
    "{\"country\":\"Burkina Faso\", \"flag\":\"🇧🇫\", \"code\": \"+226\", \"sticky\": \"0\"},"
    "{\"country\":\"Bulgaria\", \"flag\":\"🇧🇬\", \"code\": \"+359\", \"sticky\": \"0\"},"
    "{\"country\":\"Bahrain\", \"flag\":\"🇧🇭\", \"code\": \"+973\", \"sticky\": \"0\"},"
    "{\"country\":\"Burundi\", \"flag\":\"🇧🇮\", \"code\": \"+257\", \"sticky\": \"0\"},"
    "{\"country\":\"Benin\", \"flag\":\"🇧🇯\", \"code\": \"+229\", \"sticky\": \"0\"},"
    "{\"country\":\"Bermuda\", \"flag\":\"🇧🇲\", \"code\": \"+1441\", \"sticky\": \"0\"},"
    "{\"country\":\"Brunei Darussalam\", \"flag\":\"🇧🇳\", \"code\": \"+673\", \"sticky\": \"0\"},"
    "{\"country\":\"Bolivia, Plurinational\", \"flag\":\"🇧🇴\", \"code\": \"+591\", \"sticky\": \"0\"},"
    "{\"country\":\"Bonaire Sint Eustat\", \"flag\":\"🇧🇶\", \"code\": \"+599\", \"sticky\": \"0\"},"
    "{\"country\":\"Brazil\", \"flag\":\"🇧🇷\", \"code\": \"+55\", \"sticky\": \"0\"},"
    "{\"country\":\"Bahamas\", \"flag\":\"🇧🇸\", \"code\": \"+1242\", \"sticky\": \"0\"},"
    "{\"country\":\"Bhutan\", \"flag\":\"🇧🇹\", \"code\": \"+975\", \"sticky\": \"0\"},"
    "{\"country\":\"Botswana\", \"flag\":\"🇧🇼\", \"code\": \"+267\", \"sticky\": \"0\"},"
    "{\"country\":\"Belarus\", \"flag\":\"🇧🇾\", \"code\": \"+375\", \"sticky\": \"0\"},"
    "{\"country\":\"Belize\", \"flag\":\"🇧🇿\", \"code\": \"+501\", \"sticky\": \"0\"},"
    "{\"country\":\"Congo\", \"flag\":\"🇨🇩\", \"code\": \"+242\", \"sticky\": \"0\"},"
    "{\"country\":\"Central African Republic\", \"flag\":\"🇨🇫\", \"code\": \"+236\", \"sticky\": \"0\"},"
    "{\"country\":\"The Republic of Congo\", \"flag\":\"🇨🇬\", \"code\": \"+243\", \"sticky\": \"0\"},"
    "{\"country\":\"Switzerland\", \"flag\":\"🇨🇭\", \"code\": \"+41\", \"sticky\": \"0\"},"
    "{\"country\":\"Côte d'Ivoire\", \"flag\":\"🇨🇮\", \"code\": \"+225\", \"sticky\": \"0\"},"
    "{\"country\":\"Cook Islands\", \"flag\":\"🇨🇰\", \"code\": \"+682\", \"sticky\": \"0\"},"
    "{\"country\":\"Chile\", \"flag\":\"🇨🇱\", \"code\": \"+56\", \"sticky\": \"0\"},"
    "{\"country\":\"Cameroon\", \"flag\":\"🇨🇲\", \"code\": \"+237\", \"sticky\": \"0\"},"
    "{\"country\":\"Colombia\", \"flag\":\"🇨🇴\", \"code\": \"+57\", \"sticky\": \"0\"},"
    "{\"country\":\"Costa Rica\", \"flag\":\"🇨🇷\", \"code\": \"+506\", \"sticky\": \"0\"},"
    "{\"country\":\"Cuba\", \"flag\":\"🇨🇺\", \"code\": \"+53\", \"sticky\": \"0\"},"
    "{\"country\":\"Cape Verde\", \"flag\":\"🇨🇻\", \"code\": \"+238\", \"sticky\": \"0\"},"
    "{\"country\":\"Curacao\", \"flag\":\"🇨🇼\", \"code\": \"+599\", \"sticky\": \"0\"},"
    "{\"country\":\"Cyprus\", \"flag\":\"🇨🇾\", \"code\": \"+357\", \"sticky\": \"0\"},"
    "{\"country\":\"Czech Republic\", \"flag\":\"🇨🇿\", \"code\": \"+420\", \"sticky\": \"0\"},"
    "{\"country\":\"Germany\", \"flag\":\"🇩🇪\", \"code\": \"+49\", \"sticky\": \"0\"},"
    "{\"country\":\"Djibouti\", \"flag\":\"🇩🇯\", \"code\": \"+253\", \"sticky\": \"0\"},"
    "{\"country\":\"Denmark\", \"flag\":\"🇩🇰\", \"code\": \"+45\", \"sticky\": \"0\"},"
    "{\"country\":\"Dominican Republic\", \"flag\":\"🇩🇴\", \"code\": \"+1809\", \"sticky\": \"0\"},"
    "{\"country\":\"Algeria\", \"flag\":\"🇩🇿\", \"code\": \"+213\", \"sticky\": \"0\"},"
    "{\"country\":\"Ecuador\", \"flag\":\"🇪🇨\", \"code\": \"+593\", \"sticky\": \"0\"},"
    "{\"country\":\"Estonia\", \"flag\":\"🇪🇪\", \"code\": \"+371\", \"sticky\": \"0\"},"
    "{\"country\":\"Egypt\", \"flag\":\"🇪🇬\", \"code\": \"+20\", \"sticky\": \"0\"},"
    "{\"country\":\"Spain\", \"flag\":\"🇪🇸\", \"code\": \"+34\", \"sticky\": \"0\"},"
    "{\"country\":\"Ethiopia\", \"flag\":\"🇪🇹\", \"code\": \"+251\", \"sticky\": \"0\"},"
    "{\"country\":\"Finland\", \"flag\":\"🇫🇮\", \"code\": \"+358\", \"sticky\": \"0\"},"
    "{\"country\":\"Fiji\", \"flag\":\"🇫🇯\", \"code\": \"+679\", \"sticky\": \"0\"},"
    "{\"country\":\"Faroe Islands\", \"flag\":\"🇫🇴\", \"code\": \"+298\", \"sticky\": \"0\"},"
    "{\"country\":\"France\", \"flag\":\"🇫🇷\", \"code\": \"+33\", \"sticky\": \"0\"},"
    "{\"country\":\"Gabon\", \"flag\":\"🇬🇦\", \"code\": \"+241\", \"sticky\": \"0\"},"
    "{\"country\":\"United Kingdom\", \"flag\":\"🇬🇧\", \"code\": \"+44\", \"sticky\": \"0\"},"
    "{\"country\":\"Grenada\", \"flag\":\"🇬🇩\", \"code\": \"+1809\", \"sticky\": \"0\"},"
    "{\"country\":\"Georgia\", \"flag\":\"🇬🇪\", \"code\": \"+995\", \"sticky\": \"0\"},"
    "{\"country\":\"French Guiana\", \"flag\":\"🇬🇫\", \"code\": \"+594\", \"sticky\": \"0\"},"
    "{\"country\":\"Ghana\", \"flag\":\"🇬🇭\", \"code\": \"+233\", \"sticky\": \"0\"},"
    "{\"country\":\"Gibraltar\", \"flag\":\"🇬🇮\", \"code\": \"+350\", \"sticky\": \"0\"},"
    "{\"country\":\"Greenland\", \"flag\":\"🇬🇱\", \"code\": \"+299\", \"sticky\": \"0\"},"
    "{\"country\":\"Gambia\", \"flag\":\"🇬🇲\", \"code\": \"+220\", \"sticky\": \"0\"},"
    "{\"country\":\"Guinea\", \"flag\":\"🇬🇳\", \"code\": \"+224\", \"sticky\": \"0\"},"
    "{\"country\":\"Guadeloupe\", \"flag\":\"🇬🇵\", \"code\": \"+590\", \"sticky\": \"0\"},"
    "{\"country\":\"Equatorial Guinea\", \"flag\":\"🇬🇶\", \"code\": \"+240\", \"sticky\": \"0\"},"
    "{\"country\":\"Greece\", \"flag\":\"🇬🇷\", \"code\": \"+30\", \"sticky\": \"0\"},"
    "{\"country\":\"Guatemala\", \"flag\":\"🇬🇹\", \"code\": \"+502\", \"sticky\": \"0\"},"
    "{\"country\":\"Guam\", \"flag\":\"🇬🇺\", \"code\": \"+1671\", \"sticky\": \"0\"},"
    "{\"country\":\"Guinea\", \"flag\":\"🇬🇼\", \"code\": \"+245\", \"sticky\": \"0\"},"
    "{\"country\":\"Guyana\", \"flag\":\"🇬🇾\", \"code\": \"+592\", \"sticky\": \"0\"},"
    "{\"country\":\"Honduras\", \"flag\":\"🇭🇳\", \"code\": \"+504\", \"sticky\": \"0\"},"
    "{\"country\":\"Croatia\", \"flag\":\"🇭🇷\", \"code\": \"+385\", \"sticky\": \"0\"},"
    "{\"country\":\"Haiti\", \"flag\":\"🇭🇹\", \"code\": \"+509\", \"sticky\": \"0\"},"
    "{\"country\":\"Hungary\", \"flag\":\"🇭🇺\", \"code\": \"+36\", \"sticky\": \"0\"},"
    "{\"country\":\"Indonesia\", \"flag\":\"🇮🇩\", \"code\": \"+62\", \"sticky\": \"0\"},"
    "{\"country\":\"Ireland\", \"flag\":\"🇮🇪\", \"code\": \"+353\", \"sticky\": \"0\"},"
    "{\"country\":\"Israel\", \"flag\":\"🇮🇱\", \"code\": \"+972\", \"sticky\": \"0\"},"
    "{\"country\":\"India\", \"flag\":\"🇮🇳\", \"code\": \"+91\", \"sticky\": \"0\"},"
    "{\"country\":\"Iraq\", \"flag\":\"🇮🇶\", \"code\": \"+964\", \"sticky\": \"0\"},"
    "{\"country\":\"Iran, Islamic Republic of\", \"flag\":\"🇮🇷\", \"code\": \"+98\", \"sticky\": \"0\"},"
    "{\"country\":\"Iceland\", \"flag\":\"🇮🇸\", \"code\": \"+354\", \"sticky\": \"0\"},"
    "{\"country\":\"Italy\", \"flag\":\"🇮🇹\", \"code\": \"+39\", \"sticky\": \"0\"},"
    "{\"country\":\"Jamaica\", \"flag\":\"🇯🇲\", \"code\": \"+1876\", \"sticky\": \"0\"},"
    "{\"country\":\"Jordan\", \"flag\":\"🇯🇴\", \"code\": \"+962\", \"sticky\": \"0\"},"
    "{\"country\":\"Kenya\", \"flag\":\"🇰🇪\", \"code\": \"+254\", \"sticky\": \"0\"},"
    "{\"country\":\"Kyrgyzstan\", \"flag\":\"🇰🇬\", \"code\": \"+996\", \"sticky\": \"0\"},"
    "{\"country\":\"Cambodia\", \"flag\":\"🇰🇭\", \"code\": \"+855\", \"sticky\": \"0\"},"
    "{\"country\":\"Kiribati\", \"flag\":\"🇰🇮\", \"code\": \"+686\", \"sticky\": \"0\"},"
    "{\"country\":\"Comoros\", \"flag\":\"🇰🇲\", \"code\": \"+269\", \"sticky\": \"0\"},"
    "{\"country\":\"Saint Kitts and Nevis\", \"flag\":\"🇰🇳\", \"code\": \"+1869\", \"sticky\": \"0\"},"
    "{\"country\":\"Kuwait\", \"flag\":\"🇰🇼\", \"code\": \"+965\", \"sticky\": \"0\"},"
    "{\"country\":\"Cayman Islands\", \"flag\":\"🇰🇾\", \"code\": \"+1345\", \"sticky\": \"0\"},"
    "{\"country\":\"Lao People's Democratic Republic\", \"flag\":\"🇱🇦\", \"code\": \"+856\", \"sticky\": \"0\"},"
    "{\"country\":\"Lebanon\", \"flag\":\"🇱🇧\", \"code\": \"+961\", \"sticky\": \"0\"},"
    "{\"country\":\"Saint Lucia\", \"flag\":\"🇱🇨\", \"code\": \"+1758\", \"sticky\": \"0\"},"
    "{\"country\":\"Liechtenstein\", \"flag\":\"🇱🇮\", \"code\": \"+423\", \"sticky\": \"0\"},"
    "{\"country\":\"Sri Lanka\", \"flag\":\"🇱🇰\", \"code\": \"+94\", \"sticky\": \"0\"},"
    "{\"country\":\"Liberia\", \"flag\":\"🇱🇷\", \"code\": \"+231\", \"sticky\": \"0\"},"
    "{\"country\":\"Lesotho\", \"flag\":\"🇱🇸\", \"code\": \"+266\", \"sticky\": \"0\"},"
    "{\"country\":\"Lithuania\", \"flag\":\"🇱🇹\", \"code\": \"+370\", \"sticky\": \"0\"},"
    "{\"country\":\"Luxembourg\", \"flag\":\"🇱🇺\", \"code\": \"+352\", \"sticky\": \"0\"},"
    "{\"country\":\"Latvia\", \"flag\":\"🇱🇻\", \"code\": \"+371\", \"sticky\": \"0\"},"
    "{\"country\":\"Libya\", \"flag\":\"🇱🇾\", \"code\": \"+218\", \"sticky\": \"0\"},"
    "{\"country\":\"Morocco\", \"flag\":\"🇲🇦\", \"code\": \"+212\", \"sticky\": \"0\"},"
    "{\"country\":\"Monaco\", \"flag\":\"🇲🇨\", \"code\": \"+377\", \"sticky\": \"0\"},"
    "{\"country\":\"Moldova, Republic of\", \"flag\":\"🇲🇩\", \"code\": \"+373\", \"sticky\": \"0\"},"
    "{\"country\":\"Montenegro\", \"flag\":\"🇲🇪\", \"code\": \"+382\", \"sticky\": \"0\"},"
    "{\"country\":\"Madagascar\", \"flag\":\"🇲🇬\", \"code\": \"+261\", \"sticky\": \"0\"},"
    "{\"country\":\"Macedonia, the former Yugoslav Republic of\", \"flag\":\"🇲🇰\", \"code\": \"+389\", \"sticky\": \"0\"},"
    "{\"country\":\"Mali\", \"flag\":\"🇲🇱\", \"code\": \"+223\", \"sticky\": \"0\"},"
    "{\"country\":\"Myanmar\", \"flag\":\"🇲🇲\", \"code\": \"+95\", \"sticky\": \"0\"},"
    "{\"country\":\"Mongolia\", \"flag\":\"🇲🇳\", \"code\": \"+976\", \"sticky\": \"0\"},"
    "{\"country\":\"Martinique\", \"flag\":\"🇲🇶\", \"code\": \"+596\", \"sticky\": \"0\"},"
    "{\"country\":\"Mauritania\", \"flag\":\"🇲🇷\", \"code\": \"+222\", \"sticky\": \"0\"},"
    "{\"country\":\"Montserrat\", \"flag\":\"🇲🇸\", \"code\": \"+1664\", \"sticky\": \"0\"},"
    "{\"country\":\"Malta\", \"flag\":\"🇲🇹\", \"code\": \"+356\", \"sticky\": \"0\"},"
    "{\"country\":\"Mauritius\", \"flag\":\"🇲🇺\", \"code\": \"+230\", \"sticky\": \"0\"},"
    "{\"country\":\"Maldives\", \"flag\":\"🇲🇻\", \"code\": \"+960\", \"sticky\": \"0\"},"
    "{\"country\":\"Malawi\", \"flag\":\"🇲🇼\", \"code\": \"+265\", \"sticky\": \"0\"},"
    "{\"country\":\"Mexico\", \"flag\":\"🇲🇽\", \"code\": \"+52\", \"sticky\": \"0\"},"
    "{\"country\":\"Malaysia\", \"flag\":\"🇲🇾\", \"code\": \"+60\", \"sticky\": \"0\"},"
    "{\"country\":\"Mozambique\", \"flag\":\"🇲🇿\", \"code\": \"+258\", \"sticky\": \"0\"},"
    "{\"country\":\"Namibia\", \"flag\":\"🇳🇦\", \"code\": \"+264\", \"sticky\": \"0\"},"
    "{\"country\":\"New Caledonia\", \"flag\":\"🇳🇨\", \"code\": \"+687\", \"sticky\": \"0\"},"
    "{\"country\":\"Niger\", \"flag\":\"🇳🇪\", \"code\": \"+227\", \"sticky\": \"0\"},"
    "{\"country\":\"Nigeria\", \"flag\":\"🇳🇬\", \"code\": \"+234\", \"sticky\": \"0\"},"
    "{\"country\":\"Nicaragua\", \"flag\":\"🇳🇮\", \"code\": \"+505\", \"sticky\": \"0\"},"
    "{\"country\":\"Netherlands\", \"flag\":\"🇳🇱\", \"code\": \"+31\", \"sticky\": \"0\"},"
    "{\"country\":\"Norway\", \"flag\":\"🇳🇴\", \"code\": \"+47\", \"sticky\": \"0\"},"
    "{\"country\":\"Nepal\", \"flag\":\"🇳🇵\", \"code\": \"+977\", \"sticky\": \"0\"},"
    "{\"country\":\"Oman\", \"flag\":\"🇴🇲\", \"code\": \"+968\", \"sticky\": \"0\"},"
    "{\"country\":\"Panama\", \"flag\":\"🇵🇦\", \"code\": \"+507\", \"sticky\": \"0\"},"
    "{\"country\":\"Peru\", \"flag\":\"🇵🇪\", \"code\": \"+51\", \"sticky\": \"0\"},"
    "{\"country\":\"French Polynesia\", \"flag\":\"🇵🇫\", \"code\": \"+689\", \"sticky\": \"0\"},"
    "{\"country\":\"Papua New Guinea\", \"flag\":\"🇵🇬\", \"code\": \"+675\", \"sticky\": \"0\"},"
    "{\"country\":\"Philippines\", \"flag\":\"🇵🇭\", \"code\": \"+63\", \"sticky\": \"0\"},"
    "{\"country\":\"Pakistan\", \"flag\":\"🇵🇰\", \"code\": \"+92\", \"sticky\": \"0\"},"
    "{\"country\":\"Poland\", \"flag\":\"🇵🇱\", \"code\": \"+48\", \"sticky\": \"0\"},"
    "{\"country\":\"Saint Pierre and Miquelon\", \"flag\":\"🇵🇲\", \"code\": \"+508\", \"sticky\": \"0\"},"
    "{\"country\":\"Puerto Rico\", \"flag\":\"🇵🇷\", \"code\": \"+1787\", \"sticky\": \"0\"},"
    "{\"country\":\"Palestine, State of\", \"flag\":\"🇵🇸\", \"code\": \"+970\", \"sticky\": \"0\"},"
    "{\"country\":\"Portugal\", \"flag\":\"🇵🇹\", \"code\": \"+351\", \"sticky\": \"0\"},"
    "{\"country\":\"Palau\", \"flag\":\"🇵🇼\", \"code\": \"+680\", \"sticky\": \"0\"},"
    "{\"country\":\"Paraguay\", \"flag\":\"🇵🇾\", \"code\": \"+595\", \"sticky\": \"0\"},"
    "{\"country\":\"Qatar\", \"flag\":\"🇶🇦\", \"code\": \"+974\", \"sticky\": \"0\"},"
    "{\"country\":\"Romania\", \"flag\":\"🇷🇴\", \"code\": \"+40\", \"sticky\": \"0\"},"
    "{\"country\":\"Serbia\", \"flag\":\"🇷🇸\", \"code\": \"+381\", \"sticky\": \"0\"},"
    "{\"country\":\"Russian\", \"flag\":\"🇷🇺\", \"code\": \"+7\", \"sticky\": \"0\"},"
    "{\"country\":\"Rwanda\", \"flag\":\"🇷🇼\", \"code\": \"+250\", \"sticky\": \"0\"},"
    "{\"country\":\"Saudi Arabia\", \"flag\":\"🇸🇦\", \"code\": \"+966\", \"sticky\": \"0\"},"
    "{\"country\":\"Solomon Islands\", \"flag\":\"🇸🇧\", \"code\": \"+677\", \"sticky\": \"0\"},"
    "{\"country\":\"Seychelles\", \"flag\":\"🇸🇨\", \"code\": \"+248\", \"sticky\": \"0\"},"
    "{\"country\":\"Sudan\", \"flag\":\"🇸🇩\", \"code\": \"+249\", \"sticky\": \"0\"},"
    "{\"country\":\"Sweden\", \"flag\":\"🇸🇪\", \"code\": \"+46\", \"sticky\": \"0\"},"
    "{\"country\":\"Slovenia\", \"flag\":\"🇸🇮\", \"code\": \"+386\", \"sticky\": \"0\"},"
    "{\"country\":\"Slovakia\", \"flag\":\"🇸🇰\", \"code\": \"+421\", \"sticky\": \"0\"},"
    "{\"country\":\"Sierra Leone\", \"flag\":\"🇸🇱\", \"code\": \"+232\", \"sticky\": \"0\"},"
    "{\"country\":\"San Marino\", \"flag\":\"🇸🇲\", \"code\": \"+223\", \"sticky\": \"0\"},"
    "{\"country\":\"Senegal\", \"flag\":\"🇸🇳\", \"code\": \"+221\", \"sticky\": \"0\"},"
    "{\"country\":\"Somalia\", \"flag\":\"🇸🇴\", \"code\": \"+252\", \"sticky\": \"0\"},"
    "{\"country\":\"Suriname\", \"flag\":\"🇸🇷\", \"code\": \"+597\", \"sticky\": \"0\"},"
    "{\"country\":\"South Sudan\", \"flag\":\"🇸🇸\", \"code\": \"+211\", \"sticky\": \"0\"},"
    "{\"country\":\"Sao Tome and Principe\", \"flag\":\"🇸🇹\", \"code\": \"+239\", \"sticky\": \"0\"},"
    "{\"country\":\"El Salvador\", \"flag\":\"🇸🇻\", \"code\": \"+503\", \"sticky\": \"0\"},"
    "{\"country\":\"Sint Maarten(Dutch)\", \"flag\":\"🇸🇽\", \"code\": \"+590\", \"sticky\": \"0\"},"
    "{\"country\":\"Syrian Arab Republic\", \"flag\":\"🇸🇾\", \"code\": \"+963\", \"sticky\": \"0\"},"
    "{\"country\":\"Swaziland\", \"flag\":\"🇸🇿\", \"code\": \"+268\", \"sticky\": \"0\"},"
    "{\"country\":\"Turks and Caicos Islands\", \"flag\":\"🇹🇨\", \"code\": \"+1649\", \"sticky\": \"0\"},"
    "{\"country\":\"Chad\", \"flag\":\"🇹🇩\", \"code\": \"+235\", \"sticky\": \"0\"},"
    "{\"country\":\"Togo\", \"flag\":\"🇹🇬\", \"code\": \"+228\", \"sticky\": \"0\"},"
    "{\"country\":\"Thailand\", \"flag\":\"🇹🇭\", \"code\": \"+66\", \"sticky\": \"0\"},"
    "{\"country\":\"Timor \", \"flag\":\"🇹🇱\", \"code\": \"+670\", \"sticky\": \"0\"},"
    "{\"country\":\"Turkmenistan\", \"flag\":\"🇹🇲\", \"code\": \"+993\", \"sticky\": \"0\"},"
    "{\"country\":\"Tunisia\", \"flag\":\"🇹🇳\", \"code\": \"+216\", \"sticky\": \"0\"},"
    "{\"country\":\"Tonga\", \"flag\":\"🇹🇴\", \"code\": \"+676\", \"sticky\": \"0\"},"
    "{\"country\":\"Turkey\", \"flag\":\"🇹🇷\", \"code\": \"+90\", \"sticky\": \"0\"},"
    "{\"country\":\"Trinidad and Tobago\", \"flag\":\"🇹🇹\", \"code\": \"+1809\", \"sticky\": \"0\"},"
    "{\"country\":\"Tanzania, United Republic of\", \"flag\":\"🇹🇿\", \"code\": \"+255\", \"sticky\": \"0\"},"
    "{\"country\":\"Ukraine\", \"flag\":\"🇺🇦\", \"code\": \"+380\", \"sticky\": \"0\"},"
    "{\"country\":\"Uganda\", \"flag\":\"🇺🇬\", \"code\": \"+256\", \"sticky\": \"0\"},"
    "{\"country\":\"Uruguay\", \"flag\":\"🇺🇾\", \"code\": \"+598\", \"sticky\": \"0\"},"
    "{\"country\":\"Uzbekistan\", \"flag\":\"🇺🇿\", \"code\": \"+233\", \"sticky\": \"0\"},"
    "{\"country\":\"Saint Vincent and the Grenadines\", \"flag\":\"🇻🇨\", \"code\": \"+1784\", \"sticky\": \"0\"},"
    "{\"country\":\"Venezuela, Bolivarian Republic of\", \"flag\":\"🇻🇪\", \"code\": \"+58\", \"sticky\": \"0\"},"
    "{\"country\":\"Virgin Islands, U.S.\", \"flag\":\"🇻🇬\", \"code\": \"+1284\", \"sticky\": \"0\"},"
    "{\"country\":\"United States Virgin Islands\", \"flag\":\"🇻🇮\", \"code\": \"+1340\", \"sticky\": \"0\"},"
    "{\"country\":\"Vietnam\", \"flag\":\"🇻🇳\", \"code\": \"+84\", \"sticky\": \"0\"},"
    "{\"country\":\"Vanuatu\", \"flag\":\"🇻🇺\", \"code\": \"+678\", \"sticky\": \"0\"},"
    "{\"country\":\"Samoa\", \"flag\":\"🇼🇸\", \"code\": \"+685\", \"sticky\": \"0\"},"
    "{\"country\":\"Yemen\", \"flag\":\"🇾🇪\", \"code\": \"+967\", \"sticky\": \"0\"},"
    "{\"country\":\"Mayotte\", \"flag\":\"🇾🇹\", \"code\": \"+262\", \"sticky\": \"0\"},"
    "{\"country\":\"South Africa\", \"flag\":\"🇿🇦\", \"code\": \"+27\", \"sticky\": \"0\"},"
    "{\"country\":\"Zambia\", \"flag\":\"🇿🇲\", \"code\": \"+260\", \"sticky\": \"0\"},"
    "{\"country\":\"Republic of Zimbabwe\", \"flag\":\"🇿🇼\", \"code\": \"+263\"}"
    "]";
    
    NSString *str = str4CountryInfo_CN;
    if (![[NSLocale currentLocale].countryCode isEqualToString:@"CN"])
        str = str4CountryInfo_En;

    JSONDecoder *dec = [JSONDecoder new];
    self.array4CountryInfo = [dec objectWithData:[str dataUsingEncoding:NSUTF8StringEncoding]];
}

//登录门户
- (void)loginPortal
{
    //[BiChatGlobal sharedManager].loginOrder = @"mw";

    //检查登录顺序
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < [BiChatGlobal sharedManager].loginOrder.length; i ++)
    {
        unichar c = [[BiChatGlobal sharedManager].loginOrder characterAtIndex:i];
        if (c == 'w' || c == 'W')
        {
            //微信是否被安装
            if ([WXApi isWXAppInstalled])
            {
                [array addObject:@"w"];
            }
        }
        else if (c == 'm' || c == 'M')
        {
            [array addObject:@"m"];
        }
    }
    if ([array count] == 0)
    {
        //微信是否被安装
        if ([WXApi isWXAppInstalled])
        {
            [array addObject:@"w"];
        }
        [array addObject:@"m"];
    }
    
    if ([[array firstObject]isEqualToString:@"w"])
    {
        //调起登录门户
        LoginPortalViewController *wnd = [LoginPortalViewController new];
        wnd.loginOrder = array;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
        nav.navigationBar.translucent = NO;
        nav.navigationBar.tintColor = THEME_COLOR;
        [[BiChatGlobal sharedManager].mainGUI presentViewController:nav animated:YES completion:nil];
    }
    else if ([[array firstObject]isEqualToString:@"m"])
    {
        //调起手机登录界面
        LoginViewController *wnd = [LoginViewController new];
        wnd.loginOrder = array;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wnd];
        nav.navigationBar.translucent = NO;
        nav.navigationBar.tintColor = THEME_COLOR;
        [[BiChatGlobal sharedManager].mainGUI presentViewController:nav animated:YES completion:nil];
    }
}

//加载全局信息
- (void)loadGlobalInfo
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *loginInfoFile = [documentsDirectory stringByAppendingPathComponent:@"globalInfo.dat"];
    
    //读文件并解析数据
    NSDictionary *info = [[NSDictionary alloc]initWithContentsOfFile:loginInfoFile];
    if (info == nil)
    {
        self.bLogin = NO;
        self.loginMode = 0;
        self.lastLoginAreaCode = @"";
        self.lastLoginUserName = @"";
        self.lastLoginPasswordMD5 = @"";
        self.lastLoginAppVersion = @"";
        self.token = nil;
        self.nickName = @"";
        self.avatar = @"";
        self.uid = @"";
        self.verifyCodeCount = 0;
        self.createdTime = [NSDate dateWithTimeIntervalSince1970:0];
        self.S3URL = @"";
        self.S3Bucket = @"";
        self.StaticUrl = @"";
        self.filePubUid = @"";
        self.authWxUrl = @"";
        self.apiUrl = @"";
        self.inviteMessage = @"";
        self.loginOrder = @"wm";
        self.allowedVersion = @"";
        self.lastestVersion = @"";
        self.feedback = @"";
        self.imChatEmail = @"imchathk@gmail.com";
        self.exchangeExpireMinite = 24 * 60;
        self.rewardExpireMinite = 24 * 60;
        self.transferExpireMinite = 24 * 60;
        self.download = @"";
        self.forceMenu = [NSMutableArray array];
        self.unlockMinPoint = 100;
        self.soundPlayRoute = 0;
        self.systemConfigVersionNumber = @"0";
        self.exchangeAllowed = YES;
        self.business = @"";
    }
    else
    {
        self.bLogin = [[info objectForKey:@"bLogin"]boolValue];
        self.loginMode = [[info objectForKey:@"loginMode"]integerValue];
        self.lastLoginAreaCode = [info objectForKey:@"lastLoginAreaCode"];
        self.lastLoginUserName = [info objectForKey:@"lastLoginUserName"];
        self.lastLoginPasswordMD5 = [info objectForKey:@"lastLoginPasswordMD5"];
        self.lastLoginAppVersion = [info objectForKey:@"lastLoginAppVersion"];
        self.token = [info objectForKey:@"token"];
        self.nickName = [info objectForKey:@"nickName"];
        self.avatar = [info objectForKey:@"avatar"];
        self.uid = [info objectForKey:@"uid"];
        self.verifyCodeCount = [[info objectForKey:@"vierifyCodeCount"]integerValue];
        self.createdTime = [info objectForKey:@"createdTime"];
        self.S3URL = [info objectForKey:@"S3URL"];
        self.S3Bucket = [info objectForKey:@"S3Bucket"];
        self.StaticUrl = [info objectForKey:@"StaticURL"];
        self.filePubUid = [info objectForKey:@"filePubUid"];
        self.authWxUrl = [info objectForKey:@"authWxURL"];
        self.apiUrl = [info objectForKey:@"apiURL"];
        self.inviteMessage = [info objectForKey:@"inviteMessage"];
        self.defaultInviteeMaxNum = [[info objectForKey:@"defaultInviteeMaxNum"]integerValue];
        self.loginOrder = [info objectForKey:@"loginOrder"];
        self.allowedVersion = [info objectForKey:@"allowedVersion"];
        self.lastestVersion = [info objectForKey:@"lastestVersion"];
        self.feedback = [info objectForKey:@"feedback"];
        self.imChatEmail = [info objectForKey:@"imChatEmail"];
        self.exchangeExpireMinite = [[info objectForKey:@"exchangeExpireMinite"]integerValue];
        self.rewardExpireMinite = [[info objectForKey:@"rewardExpireMinite"]integerValue];
        self.transferExpireMinite = [[info objectForKey:@"transferExpireMinite"]integerValue];
        self.download = [info objectForKey:@"download"];
        self.forceMenu = [info objectForKey:@"forceMenu"];
        self.unlockMinPoint = [[info objectForKey:@"unlockMinPoint"]integerValue];
        self.soundPlayRoute = [[info objectForKey:@"soundPlayRoute"]integerValue];
        self.dict4MyTokenInfo = [info objectForKey:@"myTokenInfo"];
        self.systemConfigVersionNumber = [info objectForKey:@"systemConfigVersionNumber"];
        self.exchangeAllowed = [[info objectForKey:@"exchangeAllowed"]boolValue];
        self.business = [info objectForKey:@"business"];
        self.scanCodeRule = [info objectForKey:@"scanCodeRule"];
        self.systemConfig = [info objectForKey:@"systemConfig"];
        self.langPath = [info objectForKey:@"langPath"];
        self.shortLinkTempl = [[info objectForKey:@"systemConfig"] objectForKey:@"shortLinkTempl"];
        self.shortLinkPattern = [[info objectForKey:@"systemConfig"] objectForKey:@"shortLinkPattern"];
        
        if (self.loginOrder.length == 0)
            self.loginOrder = @"wm";
        if (self.systemConfigVersionNumber.length == 0)
            self.systemConfigVersionNumber = @"0";
        if (self.exchangeExpireMinite == 0)
            self.exchangeExpireMinite = 24 * 60;
        if (self.rewardExpireMinite == 0)
            self.rewardExpireMinite = 24 * 60;
        if (self.transferExpireMinite == 0)
            self.transferExpireMinite = 24 * 60;
        if (self.business.length == 0)
            self.business = @"7777";
    }
    
    //做一下数据保护
    if (self.apiUrl.length == 0)
    {
#ifdef ENV_DEV
        self.apiUrl = @"http://cgi.dev.iweipeng.com/";
#endif
#ifdef ENV_TEST
        self.apiUrl = @"http://cgi.t.iweipeng.com/";
#endif
#ifdef ENV_LIVE
        self.apiUrl = @"http://cgi.imchat.com/";
#endif
#ifdef ENV_CN
        self.apiUrl = @"http://cgi.imchat.com/";
#endif
#ifdef ENV_ENT
        self.apiUrl = @"http://cgi.imchat.com/";
#endif
#ifdef ENV_V_DEV
        self.apiUrl = @"http://cgi.dev.iweipeng.com/";
#endif
    }
    if (self.authWxUrl.length == 0)
    {
#ifdef ENV_DEV
        self.authWxUrl = @"http://auth.wx.imchatred.com/";
#endif
#ifdef ENV_TEST
        self.authWxUrl = @"http://auth.wx.imchatred.com/";
#endif
#ifdef ENV_LIVE
        self.authWxUrl = @"http://auth.wx.imchatred.com/";
#endif
#ifdef ENV_CN
        self.authWxUrl = @"http://auth.wx.imchatred.com/";
#endif
#ifdef ENV_ENT
        self.authWxUrl = @"http://auth.wx.imchatred.com/";
#endif
#ifdef ENV_V_DEV
        self.authWxUrl = @"http://auth.wx.imchatred.com/";
#endif
    }
}

//保存全局信息
- (void)saveGlobalInfo
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *loginInfoFile = [documentsDirectory stringByAppendingPathComponent:@"globalInfo.dat"];
    
    //组装数据
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:self.bLogin], @"bLogin",
                          [NSNumber numberWithInteger:self.loginMode], @"loginMode",
                          self.lastLoginAreaCode==nil?@"":self.lastLoginAreaCode, @"lastLoginAreaCode",
                          self.lastLoginUserName==nil?@"":self.lastLoginUserName, @"lastLoginUserName",
                          self.lastLoginPasswordMD5==nil?@"":self.lastLoginPasswordMD5, @"lastLoginPasswordMD5",
                          self.lastLoginAppVersion==nil?@"":self.lastLoginAppVersion, @"lastLoginAppVersion",
                          self.token==nil?@"":self.token, @"token",
                          self.nickName==nil?@"":self.nickName, @"nickName",
                          self.avatar==nil?@"":self.avatar, @"avatar",
                          self.uid==nil?@"":self.uid, @"uid",
                          [NSNumber numberWithInteger:self.verifyCodeCount], @"verifyCodeCount",
                          self.createdTime==nil?[NSDate dateWithTimeIntervalSince1970:0]:self.createdTime, @"createdTime",
                          self.S3URL==nil?@"":self.S3URL, @"S3URL",
                          self.S3Bucket==nil?@"":self.S3Bucket, @"S3Bucket",
                          self.StaticUrl==nil?@"":self.StaticUrl, @"StaticURL",
                          self.filePubUid==nil?@"":self.filePubUid, @"filePubUid",
                          self.authWxUrl==nil?@"":self.authWxUrl, @"authWxURL",
                          self.apiUrl==nil?@"":self.apiUrl, @"apiURL",
                          self.inviteMessage==nil?@"":self.inviteMessage, @"inviteMessage",
                          [NSNumber numberWithInteger:self.defaultInviteeMaxNum], @"defaultInviteeMaxNum",
                          self.loginOrder==nil?@"":self.loginOrder, @"loginOrder",
                          self.allowedVersion==nil?@"":self.allowedVersion, @"allowedVersion",
                          self.lastestVersion==nil?@"":self.lastestVersion, @"lastestVersion",
                          self.feedback==nil?@"":self.feedback, @"feedback",
                          self.imChatEmail==nil?@"":self.imChatEmail, @"imChatEmail",
                          [NSNumber numberWithInteger:self.exchangeExpireMinite], @"exchangeExpireMinite",
                          [NSNumber numberWithInteger:self.rewardExpireMinite], @"rewardExpireMinite",
                          [NSNumber numberWithInteger:self.transferExpireMinite], @"transferExpireMinite",
                          self.download==nil?@"":self.download, @"download",
                          self.forceMenu==nil?[NSMutableArray array]:self.forceMenu, @"forceMenu",
                          [NSNumber numberWithInteger:self.soundPlayRoute], @"soundPlayRoute",
                          self.dict4MyTokenInfo==nil?[NSMutableDictionary dictionary]:self.dict4MyTokenInfo, @"myTokenInfo",
                          [NSNumber numberWithInteger:self.unlockMinPoint], @"unlockMinPoint",
                          self.systemConfigVersionNumber==nil?@"":self.systemConfigVersionNumber, @"systemConfigVersionNumber",
                          [NSNumber numberWithBool:self.exchangeAllowed], @"exchangeAllowed",
                          self.business==nil?@"":self.business, @"business",
                          self.scanCodeRule==nil?@"":self.scanCodeRule, @"scanCodeRule",
                          self.langPath==nil?@"":self.langPath, @"langPath",
                          self.systemConfig==nil?[NSDictionary dictionary]:self.systemConfig, @"systemConfig",
                          self.shortLinkPattern==nil?@"":self.shortLinkPattern,
                          self.shortLinkTempl==nil?@"":self.shortLinkTempl,
                          nil];
    
    //写文件
    NSLog(@"write 1");
    [info writeToFile:loginInfoFile atomically:YES];
    NSLog(@"write 1 end");
}

- (void)loadAvatarNickNameInfo
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *avatarInfoFile = [documentsDirectory stringByAppendingPathComponent:@"avatarInfo.dat"];
    
    self.dict4AvatarCache = [[NSMutableDictionary alloc]initWithContentsOfFile:avatarInfoFile];
    if (self.dict4AvatarCache == nil)
        self.dict4AvatarCache = [NSMutableDictionary dictionary];
    
    NSString *nickNameInfoFile = [documentsDirectory stringByAppendingPathComponent:@"nickNameInfo.dat"];
    
    self.dict4NickNameCache = [[NSMutableDictionary alloc]initWithContentsOfFile:nickNameInfoFile];
    if (self.dict4NickNameCache == nil)
        self.dict4NickNameCache = [NSMutableDictionary dictionary];
}

- (void)saveAvatarNickNameInfo
{
    [self performSelectorOnMainThread:@selector(saveAvatarNickNameInfoInternal) withObject:nil waitUntilDone:NO];
}

- (void)saveAvatarNickNameInfoInternal
{
    [timer4SaveAvatarNickNameInfo invalidate];
    timer4SaveAvatarNickNameInfo = [NSTimer scheduledTimerWithTimeInterval:1 repeats:NO block:^(NSTimer * _Nonnull timer) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *avatarInfoFile = [documentsDirectory stringByAppendingPathComponent:@"avatarInfo.dat"];
        
        if (self.dict4AvatarCache == nil)
            self.dict4AvatarCache = [NSMutableDictionary dictionary];
        NSLog(@"write 2");
        [self.dict4AvatarCache writeToFile:avatarInfoFile atomically:YES];
        NSLog(@"write 2 end");
        
        NSString *nickNameInfoFile = [documentsDirectory stringByAppendingPathComponent:@"nickNameInfo.dat"];
        
        if (self.dict4NickNameCache == nil)
            self.dict4NickNameCache = [NSMutableDictionary dictionary];
        NSLog(@"write 3");
        [self.dict4NickNameCache writeToFile:nickNameInfoFile atomically:YES];
        NSLog(@"write 3 end");
    }];
}

//加载当前登录的用户的信息
- (void)loadUserInfo
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *userInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"userInfo_%@.dat", self.uid]];

    //加载数据
    NSDictionary *info = [[NSDictionary alloc]initWithContentsOfFile:userInfoFile];
    self.array4AllFriendGroup = [info objectForKey:@"allFriendGroup"];
    self.dict4AllFriend = [info objectForKey:@"allFriend"];
    self.array4AllGroup = [info objectForKey:@"allGroup"];
    self.array4BlackList = [info objectForKey:@"blackList"];
    self.array4Invite = [info objectForKey:@"invite"];
    self.array4StickList = [info objectForKey:@"stick"];
    self.array4MuteList = [info objectForKey:@"mute"];
    self.array4FoldList = [info objectForKey:@"fold"];
    self.array4FollowList = [info objectForKey:@"follow"];
    self.RefCode = [info objectForKey:@"RefCode"];
    self.paymentPasswordSet = [[info objectForKey:@"paymentPasswordSet"]boolValue];
    self.hideFillInviterHint = [[info objectForKey:@"hideFillInviterHint"]boolValue];
    self.hideNewVersionHintVersion = [info objectForKey:@"hideNewVersionHintVersion"];
    self.hideMoreForceHintDate = [info objectForKey:@"hideMoreForceHintDate"];
    self.dict4WalletInfo = [info objectForKey:@"walletInfo"];

    //整理一些数据
    if (self.array4FoldList == nil) self.array4FoldList = [NSMutableArray array];
    if (self.array4FollowList == nil) self.array4FollowList = [NSMutableArray array];
    
    //附加创建
    //self.array4UnSendRequest = [NSMutableArray array];
    //[self.timer4ProcessUnSendRequest invalidate];
    //self.timer4ProcessUnSendRequest = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
    //    NSLog(@"unsend request : %@", self.array4UnSendRequest);
    //}];
}

//保存当前登录用户的信息
- (void)saveUserInfo
{
    //检查参数
    if ([[BiChatGlobal sharedManager].uid length] == 0)
        return;

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *userInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"userInfo_%@.dat", self.uid]];
    
    //组合数据
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.array4AllFriendGroup==nil?[NSMutableArray array]:self.array4AllFriendGroup, @"allFriendGroup",
                          self.dict4AllFriend==nil?[NSMutableDictionary dictionary]:self.dict4AllFriend, @"allFriend",
                          self.array4AllGroup==nil?[NSMutableArray array]:self.array4AllGroup, @"allGroup",
                          self.array4BlackList==nil?[NSMutableArray array]:self.array4BlackList, @"blackList",
                          self.array4Invite==nil?[NSMutableArray array]:self.array4Invite, @"invite",
                          self.array4StickList==nil?[NSMutableArray array]:self.array4StickList, @"stick",
                          self.array4MuteList==nil?[NSMutableArray array]:self.array4MuteList, @"mute",
                          self.array4FoldList==nil?[NSMutableArray array]:self.array4FoldList, @"fold",
                          self.array4FollowList==nil?[NSMutableArray array]:self.array4FollowList, @"follow",
                          [NSNumber numberWithBool:self.paymentPasswordSet], @"paymentPasswordSet",
                          [NSNumber numberWithBool:self.hideFillInviterHint], @"hideFillInviterHint",
                          self.hideNewVersionHintVersion==nil?@"":self.hideNewVersionHintVersion, @"hideNewVersionHintVersion",
                          self.hideMoreForceHintDate==nil?@"":self.hideMoreForceHintDate, @"hideMoreForceHintDate",
                          self.RefCode.length > 0 ? self.RefCode : @"",@"RefCode",
                          self.dict4WalletInfo==nil?[NSMutableDictionary dictionary]:self.dict4WalletInfo, @"walletInfo",
                          nil];
    [info writeToFile:userInfoFile atomically:YES];
}

//加载附加的用户信息
- (void)loadUserAdditionInfo
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *userInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"userAdditionInfo_%@.dat", self.uid]];
    
    //加载数据
    NSDictionary *info = [[NSDictionary alloc]initWithContentsOfFile:userInfoFile];
    self.dict4ApplyList = [info objectForKey:@"apply"];
    self.array4ApproveList = [info objectForKey:@"approve"];
    self.dict4DownloadingSound = [info objectForKey:@"downloadingSound"];
    self.array4Log = [info objectForKey:@"log"];
    
    //整理一些数据
    self.dict4ApplyList = [NSMutableDictionary dictionaryWithDictionary:self.dict4ApplyList];
    if (self.array4ApproveList == nil) self.array4ApproveList = [NSMutableArray array];
    else self.array4ApproveList = [NSMutableArray arrayWithArray:self.array4ApproveList];
    self.dict4DownloadingSound = [NSMutableDictionary dictionaryWithDictionary:self.dict4DownloadingSound];
    if (self.array4Log == nil) self.array4Log = [NSMutableArray array];
    else self.array4Log = [NSMutableArray arrayWithArray:self.array4Log];
}

//保存当前登录用户的附加信息
- (void)saveUserAdditionInfo
{
    //检查参数
    if ([[BiChatGlobal sharedManager].uid length] == 0)
        return;
    
    [self performSelectorOnMainThread:@selector(saveUserAdditionInfoInternal) withObject:nil waitUntilDone:NO];
}

- (void)saveUserAdditionInfoInternal
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *userInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"userAdditionInfo_%@.dat", self.uid]];
    
    //组合数据
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.array4ApproveList==nil?[NSMutableArray array]:self.array4ApproveList, @"approve",
                          self.dict4ApplyList==nil?[NSMutableDictionary dictionary]:self.dict4ApplyList, @"apply",
                          self.dict4DownloadingSound==nil?[NSMutableDictionary dictionary]:self.dict4DownloadingSound, @"downloadingSound",
                          self.array4Log==nil?[NSMutableArray array]:self.array4Log, @"log",
                          nil];
    [info writeToFile:userInfoFile atomically:YES];
}

//加载本用户关于表情相关的信息
- (void)loadUserEmotionInfo
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *userEmotionInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"userEmotionInfo_%@.dat", self.uid]];

    //加载数据
    NSDictionary *info = [[NSDictionary alloc]initWithContentsOfFile:userEmotionInfoFile];
    self.array4UserFrequentlyUsedEmotions = [info objectForKey:@"currentUserFrequentlyUsedEmotions"];
    
    //调整里面所有的重复数据
    [self clearDuplicatedFrequentlyUsedEmotion];
    
    //调整数据
    if (self.array4UserFrequentlyUsedEmotions == nil) self.array4UserFrequentlyUsedEmotions = [NSMutableArray array];
}

//保存本用户关于表情相关的信息
- (void)saveUserEmotionInfo
{
    //检查参数
    if ([[BiChatGlobal sharedManager].uid length] == 0)
        return;
    
    //调整里面所有的重复数据
    [self clearDuplicatedFrequentlyUsedEmotion];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *userEmotionInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"userEmotionInfo_%@.dat", self.uid]];

    //组合数据
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.array4UserFrequentlyUsedEmotions==nil?[NSMutableArray array]:self.array4UserFrequentlyUsedEmotions, @"currentUserFrequentlyUsedEmotions", nil];
    [info writeToFile:userEmotionInfoFile atomically:YES];
}

//清除重复使用的当前表情
- (void)clearDuplicatedFrequentlyUsedEmotion
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSMutableDictionary *item in self.array4UserFrequentlyUsedEmotions)
    {
        //先找一下这个表情是否还存在
        NSDictionary *emotion = nil;
        for (NSMutableDictionary *item2 in self.array4AllDefaultEmotions)
        {
            if ([[item objectForKey:@"name"]isEqualToString:[item2 objectForKey:@"chinese"]] ||
                [[item objectForKey:@"name"]isEqualToString:[item2 objectForKey:@"english"]])
            {
                emotion = item2;
                break;
            }
        }
        
        //找到了
        if (emotion)
        {
            //找找这个表情是否已经处理过了
            BOOL found = NO;
            for (NSMutableDictionary *item2 in array)
            {
                if ([[item2 objectForKey:@"name"]isEqualToString:[emotion objectForKey:@"chinese"]] ||
                    [[item2 objectForKey:@"name"]isEqualToString:[emotion objectForKey:@"english"]])
                {
                    [item2 setObject:[NSNumber numberWithInteger:[[item2 objectForKey:@"count"]integerValue] + [[item objectForKey:@"count"]integerValue]] forKey:@"count"];
                    found = YES;
                    break;
                }
            }
            
            if (!found)
                [array addObject:item];
        }
    }
    
    self.array4UserFrequentlyUsedEmotions = array;
}

//用户使用了一个表情
- (void)useEmotion:(NSString *)emotion
{
    if (self.array4UserFrequentlyUsedEmotions == nil)
        self.array4UserFrequentlyUsedEmotions = [NSMutableArray array];
    
    //寻找这个表情是否已经使用过
    for (NSMutableDictionary *item in self.array4UserFrequentlyUsedEmotions)
    {
        if ([[item objectForKey:@"name"]isEqualToString:emotion])
        {
            [item setObject:[NSNumber numberWithInteger:[[item objectForKey:@"count"]integerValue] + 1] forKey:@"count"];
            [self saveUserEmotionInfo];
            return;
        }
    }
    
    //没有找到
    NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:emotion, @"name", [NSNumber numberWithInteger:1], @"count", nil];
    [self.array4UserFrequentlyUsedEmotions addObject:item];
    [self saveUserEmotionInfo];
}

- (NSString *)getCurrentLoginMobile
{
    return [NSString stringWithFormat:@"%@ %@", self.lastLoginAreaCode, self.lastLoginUserName];
}

//imChat日志
- (void)imChatLog:(NSString*)logStr, ...
{
    [self.array4Log removeAllObjects];
    return;
    
    /*
    //获取参数
    NSMutableString* parmaStr = [NSMutableString string];
    // 声明一个参数指针
    va_list paramList;
    // 获取参数地址，将paramList指向logStr
    va_start(paramList, logStr);
    id arg = logStr;
    
    @try {
        // 遍历参数列表
        while (arg) {
            [parmaStr appendString:arg];
            // 指向下一个参数，后面是参数类似
            arg = va_arg(paramList, NSString*);
        }
    } @catch (NSException *exception) {
        [parmaStr appendString:@"【记录日志异常】"];
    } @finally {
        
        // 将参数列表指针置空
        va_end(paramList);
    }
    
    NSDateFormatter *fmt = [NSDateFormatter new];
    fmt.dateFormat = @"yyyy/MM/dd HH:mm:ss";
    
    //生成写入的字符串
    NSString* writeStr = [NSString stringWithFormat:@"[%@]-%@\n", [fmt stringFromDate:[NSDate date]], parmaStr];
    [self.array4Log addObject:writeStr];
    if (self.array4Log.count > 1000)
        [self.array4Log removeObjectAtIndex:0];
    
    [timer4SaveImLog invalidate];
    timer4SaveImLog = [NSTimer scheduledTimerWithTimeInterval:1 repeats:NO
                                                        block:^(NSTimer * _Nonnull timer) {
                                                            //写入日志
                                                            NSLog(@"save log file");
                                                            [self saveUserAdditionInfo];
                                                            NSLog(@"save log file end");
                                                        }];
     */
}

//下载一条声音
- (void)downloadSound:(NSString *)soundFileName msgId:(NSString *)msgId
{
    [self.dict4DownloadingSound setObject:@"downloading" forKey:soundFileName];
    [self saveUserAdditionInfo];
    [self performSelectorInBackground:@selector(downloadSoundInternal:) withObject:@{@"fileName":soundFileName,@"msgId":msgId}];
}

- (void)downloadSoundInternal:(NSDictionary *)soundFileInfo
{
    NSString *soundFileName = [soundFileInfo objectForKey:@"fileName"];
    NSString *msgId = [soundFileInfo objectForKey:@"msgId"];
    
    //记录这条消息正在被下载
    [[BiChatDataModule sharedDataModule]setReceivingMessage:msgId];
    
    //重复5次进行下载，如果5次都下载不成，就不尝试了
    for (int i = 0; i < 5; i ++)
    {
        NSString *str4Url = [NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, soundFileName];
        NSData *data = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:str4Url]];
        if (data != nil)
        {
            //下载成功，保存
            NSString *soundFileNameTmp = [soundFileName stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *SoundPath = [documentsDirectory stringByAppendingPathComponent:soundFileNameTmp];
            NSLog(@"write 7");
            [data writeToFile:SoundPath atomically:YES];
            NSLog(@"write 7 end");
            [self.dict4DownloadingSound removeObjectForKey:soundFileName];
            [self saveUserAdditionInfo];
            [[BiChatDataModule sharedDataModule]clearReceivingMessage:msgId];
            return;
        }
    }
    
    //下载失败，记录一下
    [[BiChatDataModule sharedDataModule]clearReceivingMessage:msgId];
    [self.dict4DownloadingSound setObject:@"failure" forKey:soundFileName];
    [self saveUserAdditionInfo];
}

- (void)downloadAllPendingSound
{
    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:self.dict4DownloadingSound];
    for (NSString *key in dict)
    {
        if (![[dict objectForKey:key]isEqualToString:@"failure"])
            [self downloadSound:key msgId:[dict objectForKey:key]];
    }
}

+ (NSString *)getDateString:(NSDate *)date
{
    NSDateFormatter *fmt = [NSDateFormatter new];
    [fmt setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    fmt.dateFormat = @"yyyy/MM/dd HH:mm";
    return [fmt stringFromDate:date];
}

+ (NSString *)getCurrentDateString
{
    double interval = [[NSDate date]timeIntervalSince1970];
    interval -= [BiChatGlobal sharedManager].serverTimeOffset;
    return [NSString stringWithFormat:@"%lld", (long long)(interval * 1000)];
}

+ (NSDate *)getCurrentDate
{
    double interval = [[NSDate date]timeIntervalSince1970];
    interval -= [BiChatGlobal sharedManager].serverTimeOffset;
    return [[NSDate alloc]initWithTimeIntervalSince1970:interval];
}

+ (NSDate *)parseDateString:(NSString *)biChatDateString
{
    NSString *str = [NSString stringWithFormat:@"%@", biChatDateString];
    NSDateFormatter *fmt = [NSDateFormatter new];
    fmt.dateFormat = @"yyyy/MM/dd HH:mm";
    [fmt setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [fmt dateFromString:str];
    if (date == nil)
        date = [NSDate dateWithTimeIntervalSince1970:[str doubleValue]/1000];
    return date;
}

+ (NSString *)adjustDateString:(NSString *)BiChatDateString
{
    BiChatDateString = [NSString stringWithFormat:@"%@", BiChatDateString];
    NSCalendar *cal = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitWeekday|kCFCalendarUnitWeekdayOrdinal;

    NSDateFormatter *fmt = [NSDateFormatter new];
    fmt.dateFormat = @"yyyy/MM/dd HH:mm";
    [fmt setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [fmt dateFromString:BiChatDateString];
    if (date == nil)
    {
        //另一种格式
        fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        date = [fmt dateFromString:BiChatDateString];
        
        //是不是时间戳
        date = [NSDate dateWithTimeIntervalSince1970:[BiChatDateString doubleValue]/1000];
    }
    NSDateComponents *comp4Date = [cal components:unitFlags fromDate:date];
    
    //当前的日期的年月日
    NSDate *now = [NSDate date];
    NSDateComponents *comp4Now = [cal components:unitFlags fromDate:now];
    NSDateComponents *comp4Interval = [cal components:NSCalendarUnitDay | kCFCalendarUnitHour | kCFCalendarUnitMinute  fromDate:date toDate:now options:0];
        
    //是不是今天
    if ([comp4Date year] == [comp4Now year] &&
        [comp4Date month] == [comp4Now month] &&
        [comp4Date day] == [comp4Now day])
    {
        NSDateFormatter *fmt = [NSDateFormatter new];
        if ([comp4Date hour] >= 0 && [comp4Date hour] < 6)          //凌晨
            fmt.dateFormat = @"HH:mm";
        else if ([comp4Date hour] >=6 && [comp4Date hour] < 12)     //上午
            fmt.dateFormat = @"HH:mm";
        else if ([comp4Date hour] >= 12 && [comp4Date hour] < 18)   //下午
            fmt.dateFormat = @"HH:mm";
        else                                                        //晚上
            fmt.dateFormat = @"HH:mm";
        return [fmt stringFromDate:date];
    }
    
    //是不是昨天
//    else if (comp4Interval.day <= 1 && comp4Interval.day >= 0)
//    {
//        NSDateFormatter *fmt = [NSDateFormatter new];
//        if ([comp4Date hour] >= 0 && [comp4Date hour] < 6)          //凌晨
//            fmt.dateFormat = @"HH:mm";
//        else if ([comp4Date hour] >=6 && [comp4Date hour] < 12)     //上午
//            fmt.dateFormat = @"HH:mm";
//        else if ([comp4Date hour] >= 12 && [comp4Date hour] < 18)   //下午
//            fmt.dateFormat = @"HH:mm";
//        else                                                        //晚上
//            fmt.dateFormat = @"HH:mm";
//        return [NSString stringWithFormat:@"%@ %@",LLSTR(@"101098"),[fmt stringFromDate:date]];
//    }
    
    //是不是一个星期之内
    else if ([comp4Interval day] <= 7 && comp4Interval.day >= 0)
    {
        NSDateFormatter *fmt = [NSDateFormatter new];
        if ([comp4Date hour] >= 0 && [comp4Date hour] < 6)          //凌晨
            fmt.dateFormat = @"HH:mm";
        else if ([comp4Date hour] >=6 && [comp4Date hour] < 12)     //上午
            fmt.dateFormat = @"HH:mm";
        else if ([comp4Date hour] >= 12 && [comp4Date hour] < 18)   //下午
            fmt.dateFormat = @"HH:mm";
        else                                                        //晚上
            fmt.dateFormat = @"HH:mm";
        return [NSString stringWithFormat:@"%@ %@",[BiChatGlobal getWeekDayString:[comp4Date weekday]] ,[fmt stringFromDate:date]];
    }
    
    //是不是今年
    else if ([comp4Date year] == [comp4Now year])
    {
        NSDateFormatter *fmt = [NSDateFormatter new];
        fmt.dateFormat = @"MM/dd HH:mm";
        return [fmt stringFromDate:date];
    }
    
    //其他
    else
    {
        NSDateFormatter *fmt = [NSDateFormatter new];
        fmt.dateFormat = @"yyyy/MM/dd HH:mm";
        return [fmt stringFromDate:date];
    }
}

+ (NSString *)adjustDateString2:(NSString *)BiChatDateString
{    
    BiChatDateString = [NSString stringWithFormat:@"%@", BiChatDateString];
    NSDateFormatter *fmt = [NSDateFormatter new];
    fmt.dateFormat = @"yyyy/MM/dd HH:mm";
    [fmt setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [fmt dateFromString:BiChatDateString];
    if (date == nil)
    {
        //另一种格式
        fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        date = [fmt dateFromString:BiChatDateString];
        
        //是不是时间戳
        date = [NSDate dateWithTimeIntervalSince1970:[BiChatDateString doubleValue]/1000];
    }
    
    fmt = [NSDateFormatter new];
    fmt.dateFormat = @"yyyy/MM/dd HH:mm";
    return [fmt stringFromDate:date];
}

+ (NSString *)getWeekDayString:(NSInteger)weekday
{
    if (weekday == 1) return LLSTR(@"101097");
    else if (weekday == 2) return LLSTR(@"101091");
    else if (weekday == 3) return LLSTR(@"101092");
    else if (weekday == 4) return LLSTR(@"101093");
    else if (weekday == 5) return LLSTR(@"101094");
    else if (weekday == 6) return LLSTR(@"101095");
    else return LLSTR(@"101096");
}

+ (CGSize)calcDisplaySize:(CGFloat)width height:(CGFloat)height
{
    if (width == 0 || height == 0) return CGSizeMake(0, 0);
    if (width > height)
    {
        if (height > 600)
        {
            CGFloat displayHeight = 600;
            CGFloat displayWidth = 600 * width / height;
            if (displayWidth > 1000)
            {
                displayWidth = 1000;
                displayHeight = 1000 * height / width;
            }
            return CGSizeMake(displayWidth, displayHeight);
        }
        else
            return CGSizeMake(width, height);
    }
    else
    {
        if (width > 600)
        {
            CGFloat displayWidth = 600;
            CGFloat displayHeight = 600 * height / width;
            if (displayHeight > 1000)
            {
                displayHeight = 1000;
                displayWidth = 1000 * width / height;
            }
            return CGSizeMake(displayWidth, displayHeight);
        }
        else
            return CGSizeMake(width, height);
    }
}

+ (CGSize)calcThumbSize:(CGFloat)width height:(CGFloat)height
{
    if (width == 0 || height == 0) return CGSizeMake(0, 0);
    if (width > height)
    {
        CGFloat thumbHeight = 100;
        CGFloat thumbWidth = 100 * width / height;
        if (thumbWidth > 200) thumbWidth = 200;
        return CGSizeMake(thumbWidth, thumbHeight);
    }
    else
    {
        CGFloat thumbWidth = 100;
        CGFloat thumbHeight = 100 * height / width;
        if (thumbHeight > 200) thumbHeight = 200;
        return CGSizeMake(thumbWidth, thumbHeight);
    }
}

+ (UIImage *)createThumbImageFor:(UIImage *)image size:(CGSize)size
{
    CGSize originImageSize = image.size;
    CGRect newRect =CGRectMake(0,0,size.width,size.height);
    
    //根据当前屏幕scaling factor创建一个透明的位图图形上下文(此处不能直接从UIGraphicsGetCurrentContext获取,原因是UIGraphicsGetCurrentContext获取的是上下文栈的顶,在drawRect:方法里栈顶才有数据,其他地方只能获取一个nil.详情看文档)
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
    
    //保持宽高比例,确定缩放倍数
    //(原图的宽高做分母,导致大的结果比例更小,做MAX后,ratio*原图长宽得到的值最小是40,最大则比40大,这样的好处是可以让原图在画进40*40的缩略矩形画布时,origin可以取=(缩略矩形长宽减原图长宽*ratio)/2 ,这样可以得到一个可能包含负数的origin,结合缩放的原图长宽size之后,最终原图缩小后的缩略图中央刚好可以对准缩略矩形画布中央)
    float ratio = MAX(newRect.size.width / originImageSize.width, newRect.size.height / originImageSize.height);
    
    //让image在缩略图范围内居中()
    CGRect projectRect;
    projectRect.size.width = originImageSize.width * ratio;
    projectRect.size.height = originImageSize.height * ratio;
    projectRect.origin.x = (newRect.size.width- projectRect.size.width) / 2;
    projectRect.origin.y = (newRect.size.height- projectRect.size.height) / 2;
    
    //在上下文中画图
    [image drawInRect:projectRect];
    
    //从图形上下文获取到UIImage对象,赋值给thumbnai属性
    UIImage *smallImg = UIGraphicsGetImageFromCurrentImageContext();
    
    //清理图形上下文(用了UIGraphicsBeginImageContext需要清理)
    UIGraphicsEndImageContext();
    return smallImg;
}

//查找一个朋友是否在通讯录
- (BOOL)isFriendInContact:(NSString *)peerUid
{
    for(NSString *item in [BiChatGlobal sharedManager].dict4AllFriend)
    {
        if ([peerUid isEqualToString:item])
        {
            NSDictionary *friendInfo = [[BiChatGlobal sharedManager].dict4AllFriend objectForKey:item];
            if ([[friendInfo objectForKey:@"friendType"]integerValue] == -1)
                return NO;
            return YES;
        }
    }
    return NO;
}

//查找一个手机号码是否在通讯录
- (BOOL)isMobileInContact:(NSString *)mobile
{
    for (NSArray *array in _array4AllFriendGroup)
    {
        for (NSDictionary *item in array)
        {
            if ([mobile isEqualToString:[item objectForKey:@"userName"]])
            {
                return YES;
            }
        }
    }
    return NO;
}

//查找一个用户是否在黑名单
- (BOOL)isFriendInBlackList:(NSString *)peerUid
{
    for (NSDictionary *item in _array4BlackList)
    {
        
        if ([peerUid isEqualToString:[item objectForKey:@"uid"]])
            return YES;
    }
    return NO;
}

//查找一个用户是否在邀请列表里面
- (BOOL)isFriendInInviteList:(NSString *)peerUid
{
    for (NSString *str in _array4Invite)
    {
        if ([str isEqualToString:peerUid])
            return YES;
    }
    return NO;
}

//添加一个人到邀请列表里面
- (void)addFriendInInviteList:(NSString *)peerUid
{
    if ([self isFriendInInviteList:peerUid])
        return;
    if (_array4Invite == nil) _array4Invite = [NSMutableArray array];
    if (![_array4Invite isKindOfClass:[NSMutableArray class]])
        _array4Invite = [[NSMutableArray alloc]initWithArray:_array4Invite];
    [_array4Invite addObject:peerUid];
    [self saveUserInfo];
}

//从邀请列表里面删除一条记录
- (void)delFriendInInviteList:(NSString *)peerUid
{
    for (int i = 0; i < _array4Invite.count; i ++)
    {
        if ([[_array4Invite objectAtIndex:i]isEqualToString:peerUid])
        {
            [_array4Invite removeObjectAtIndex:i];
            [self saveUserInfo];
            return;
        }
    }
}

//查找一个人是否在静音列表里面
- (BOOL)isFriendInMuteList:(NSString *)peerUid
{
    for (NSString *str in self.array4MuteList)
    {
        if ([peerUid isEqualToString:str])
            return YES;
    }
    return NO;
}

//从静音列表中删除一个人
- (void)delFriendInMuteList:(NSString *)peerUid
{
    for (NSString *str in self.array4MuteList)
    {
        if ([peerUid isEqualToString:str])
        {
            [self.array4MuteList removeObject:str];
            return;
        }
    }
}

//查找一个人是否在折叠列表里面
- (BOOL)isFriendInFoldList:(NSString *)peerUid
{
    for (NSString *str in self.array4FoldList)
    {
        if ([peerUid isEqualToString:str])
            return YES;
    }
    return NO;
}

//从折叠列表中删除一个人
- (void)delFriendInFoldList:(NSString *)peerUid
{
    for (NSString *str in self.array4FoldList)
    {
        if ([peerUid isEqualToString:str])
        {
            [self.array4FoldList removeObject:str];
            return;
        }
    }
}

//查找一个人是否在置顶列表里面
- (BOOL)isFriendInStickList:(NSString *)peerUid
{
    for (NSString *str in self.array4StickList)
    {
        if ([peerUid isEqualToString:str])
            return YES;
    }
    return NO;
}

//从折叠列表中删除一个人
- (void)delFriendInStickList:(NSString *)peerUid
{
    for (NSString *str in self.array4StickList)
    {
        if ([peerUid isEqualToString:str])
        {
            [self.array4StickList removeObject:str];
            return;
        }
    }
}

//查找一个人是否在关注列表里面
- (BOOL)isFriendInFollowList:(NSString *)peerUid
{
    for (NSDictionary *item in self.array4FollowList)
    {
        if ([peerUid isEqualToString:[item objectForKey:@"ownerUid"]])
            return YES;
    }
    return NO;
}

//在本地通讯录中根据uid查找用户
- (NSDictionary *)getFriendInfoInContactByUid:(NSString *)peerUid
{
    for (NSArray *array in _array4AllFriendGroup)
    {
        for (NSDictionary *item in array)
        {
            if ([peerUid isEqualToString:[item objectForKey:@"uid"]])
                return item;
        }
    }
    return nil;
}

//在本地通讯录中根据手机号码查找用户
- (NSDictionary *)getFriendInfoInContactByMobile:(NSString *)mobile
{
    for (NSArray *array in _array4AllFriendGroup)
    {
        for (NSDictionary *item in array)
        {
            if ([mobile isEqualToString:[item objectForKey:@"userName"]])
                return item;
        }
    }
    return nil;
}

//查找一个朋友的昵称
- (NSString *)getFriendNickName:(NSString *)peerUid
{
    for (NSArray *array in _array4AllFriendGroup)
    {
        for (NSDictionary *item in array)
        {
            if ([peerUid isEqualToString:[item objectForKey:@"uid"]])
                return [item objectForKey:@"nickName"];
        }
    }
    return @"";
}

//查找一个朋友的avatar
- (NSString *)getFriendAvatar:(NSString *)peerUid
{
    for (NSArray *array in _array4AllFriendGroup)
    {
        for (NSDictionary *item in array)
        {
            if ([peerUid isEqualToString:[item objectForKey:@"uid"]])
                return [item objectForKey:@"avatar"];
        }
    }
    return @"";
}

//查找一个朋友的username
- (NSString *)getFriendUserName:(NSString *)peerUid
{
    for (NSArray *array in _array4AllFriendGroup)
    {
        for (NSDictionary *item in array)
        {
            if ([peerUid isEqualToString:[item objectForKey:@"uid"]])
                return [item objectForKey:@"userName"];
        }
    }
    return @"";
}

- (NSString *)adjustFriendNickName4Display:(NSString *)peerUid groupProperty:(NSDictionary *)groupProperty nickName:(NSString *)nickName
{
    //先看这个朋友，有没有备注名
    NSString *memoName = [[BiChatGlobal sharedManager]getFriendMemoName:peerUid];
    if (memoName.length > 0)
        return memoName;
    
    //然后看看这个朋友在群里面的昵称
    for (NSDictionary *item in [groupProperty objectForKey:@"groupUserList"])
    {
        //优先显示群昵称
        if ([[item objectForKey:@"uid"]isEqualToString:peerUid] &&
            [[item objectForKey:@"groupNickName"]length] > 0)
            return [item objectForKey:@"groupNickName"];
        
        //昵称
        if ([[item objectForKey:@"uid"]isEqualToString:peerUid] &&
            [[item objectForKey:@"nickName"]length] > 0)
            return [item objectForKey:@"nickName"];
    }
    
    //然后看看这个用户的昵称是不是在cache里面
    NSString *cacheName = [[BiChatGlobal sharedManager].dict4NickNameCache objectForKey:peerUid];
    if (cacheName.length > 0)
        return cacheName;
    
    //最后什么都没有找到，返回原始的昵称
    return nickName == nil?@"":nickName;
}

- (NSString *)adjustFriendNickName4Display2:(NSString *)peerUid groupProperty:(NSDictionary *)groupProperty nickName:(NSString *)nickName
{
    //先看这个人是不是自己
    if ([peerUid isEqualToString:[BiChatGlobal sharedManager].uid])
        return LLSTR(@"101015");
    
    //先看这个朋友，有没有备注名
    NSString *memoName = [[BiChatGlobal sharedManager]getFriendMemoName:peerUid];
    if (memoName.length > 0)
        return memoName;
    
    //然后看看这个朋友在群里面的昵称
    for (NSDictionary *item in [groupProperty objectForKey:@"groupUserList"])
    {
        //优先显示群昵称
        if ([[item objectForKey:@"uid"]isEqualToString:peerUid] &&
            [[item objectForKey:@"groupNickName"]length] > 0)
            return [item objectForKey:@"groupNickName"];
        
        //昵称
        if ([[item objectForKey:@"uid"]isEqualToString:peerUid] &&
            [[item objectForKey:@"nickName"]length] > 0)
            return [item objectForKey:@"nickName"];
    }
    
    //然后看看这个用户的昵称是不是在cache里面
    NSString *cacheName = [[BiChatGlobal sharedManager].dict4NickNameCache objectForKey:peerUid];
    if (cacheName.length > 0)
        return cacheName;
    
    //最后什么都没有找到，返回原始的昵称
    return nickName == nil?@"":nickName;
}

- (NSString *)adjustGroupNickName4Display:(NSString *)groupId nickName:(NSString *)nickName
{
    NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:groupId];
    if (groupProperty == nil)
        return nickName;
    
    //是否虚拟群
    if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0)
    {
        for (NSDictionary *item in [groupProperty objectForKey:@"virtualGroupSubList"])
        {
            if ([groupId isEqualToString:[item objectForKey:@"groupId"]])
            {
                if ([[item objectForKey:@"virtualGroupNum"]integerValue] == 0)
                    return [NSString stringWithFormat:@"%@ %@", [groupProperty objectForKey:@"groupName"], LLSTR(@"201503")];
                else if ([[item objectForKey:@"isBroadCastGroup"]boolValue])
                    return [NSString stringWithFormat:@"%@ %@", [groupProperty objectForKey:@"groupName"], LLSTR(@"201504")];
                else if ([[item objectForKey:@"groupNickName"]length] > 0)
                    return [NSString stringWithFormat:@"%@ #%@", [groupProperty objectForKey:@"groupName"], [item objectForKey:@"groupNickName"]];
                else
                    return [NSString stringWithFormat:@"%@ #%@", [groupProperty objectForKey:@"groupName"], [item objectForKey:@"virtualGroupNum"]];
                break;
            }
        }
        return nickName;
    }
    else if (nickName.length == 0 && [[groupProperty objectForKey:@"groupName"]length] > 0)
        return [groupProperty objectForKey:@"groupName"];
    else
        return nickName;
}

//查找一个用户的来源
- (NSString *)getFriendSource:(NSString *)peerUid
{
    for (NSArray *array in _array4AllFriendGroup)
    {
        for (NSDictionary *item in array)
        {
            if ([peerUid isEqualToString:[item objectForKey:@"uid"]])
                return [item objectForKey:@"resource"];
        }
    }
    return nil;
}

//设置一个人的用户昵称和头像，修改到通讯录
- (void)setFriendInfo:(NSString *)peerUid nickName:(NSString *)nickName avatar:(NSString *)avatar
{
    NSMutableDictionary *item = [_dict4AllFriend objectForKey:peerUid];
    if (nickName.length > 0)
        [item setObject:nickName forKey:@"nickName"];
    else
        [item setObject:@"" forKey:@"nickName"];
    if (avatar.length > 0)
        [item setObject:avatar forKey:@"avatar"];
    else
        [item setObject:@"" forKey:@"avatar"];
    [self resortAllFriend];
}

//设置一个人的备注名，修改到通讯录
- (void)setFriendMemoName:(NSString *)peerUid memoName:(NSString *)memoName
{
    NSMutableDictionary *item = [_dict4AllFriend objectForKey:peerUid];
    [item setObject:memoName forKey:@"remark"];
    [self resortAllFriend];
}

- (void)resortAllFriend
{
    [BiChatGlobal sharedManager].array4AllFriendGroup = [NSMutableArray array];
    for (int i = 0; i <= 37; i ++)
        [[BiChatGlobal sharedManager].array4AllFriendGroup addObject:[NSMutableArray array]];
    
    for (id key in [BiChatGlobal sharedManager].dict4AllFriend)
    {
        NSMutableDictionary *item = [[BiChatGlobal sharedManager].dict4AllFriend objectForKey:key];
        
        //还不是双向好友
        if (![[item objectForKey:@"makeFriend"]boolValue] &&
            ![[item objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid])
        {
            NSLog(@"find a single direction friend - %@", [item objectForKey:@"nickName"]);
            continue;
        }
        
        //处理一条记录
        if ([[item objectForKey:@"nickName"]length] > 0)
        {
            NSString *nickName = [item objectForKey:@"nickName"];
            if ([[item objectForKey:@"remark"]length] > 0)
                nickName = [item objectForKey:@"remark"];
            
            char c = pinyinFirstLetter([[nickName lowercaseString]characterAtIndex:0]);
            if (c >= '0' && c <= '9')
                [[[BiChatGlobal sharedManager].array4AllFriendGroup objectAtIndex:(c - '0')]addObject:item];
            else if (c >= 'a' && c <= 'z')
                [[[BiChatGlobal sharedManager].array4AllFriendGroup objectAtIndex:(c - 'a' + 10)]addObject:item];
            else
                [[[BiChatGlobal sharedManager].array4AllFriendGroup objectAtIndex:36]addObject:item];
        }
        else
            [[[BiChatGlobal sharedManager].array4AllFriendGroup objectAtIndex:36]addObject:item];
    }
}

//从本地通讯录中获取一个朋友的备注名称
- (NSString *)getFriendMemoName:(NSString *)peerUid
{
    for (NSString *item in _dict4AllFriend)
    {
        if ([item isEqualToString:peerUid])
        {
            NSDictionary *friendInfo = [_dict4AllFriend objectForKey:item];
            return [friendInfo objectForKey:@"remark"];
        }
    }
    return @"";
}

//从通讯录中读取公号的信息
- (NSDictionary *)getPublicAccountInfoInContactByUid:(NSString *)peerUid
{
    for (NSDictionary *item in _array4FollowList)
    {
        if ([peerUid isEqualToString:[item objectForKey:@"ownerUid"]])
            return item;
    }
    return nil;
}

//返回一个群的一些附加标志
- (NSArray *)getGroupFlag:(NSString *)groupId
{
    //获取这个群在本地的暂存状态
    NSMutableArray *array = [NSMutableArray array];
    NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:groupId];
    if (groupProperty == nil)
        return array;
    
    //是否可以搜索到
    //if (![[groupProperty objectForKey:@"privateGroup"]boolValue])
    //    [array addObject:@"searchable_group"];
    
    //是否是收费群
    if ([[groupProperty objectForKey:@"payGroup"]boolValue])
        [array addObject:@"charge_group"];

    return array;
}

+ (NSString *)getUuidString
{
    return [[NSUUID UUID].UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

//生成一个头像窗口
+ (UIView *)getAvatarWnd:(NSString *)uid nickName:(NSString *)nickName avatar:(NSString *)avatar width:(CGFloat)width height:(CGFloat)height
{
    //先看看cache里面有没有头像
    if (uid != nil && [[[BiChatGlobal sharedManager].dict4AvatarCache objectForKey:uid]length] > 0)
    {        
        NSString *str4AvatarUrl = [NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, [[BiChatGlobal sharedManager].dict4AvatarCache objectForKey:uid]];
        UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
        image4Avatar.layer.cornerRadius = width / 2;
        image4Avatar.clipsToBounds = YES;
        image4Avatar.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
        image4Avatar.layer.cornerRadius = width / 2;
        image4Avatar.layer.borderColor = [UIColor colorWithWhite:.9 alpha:1].CGColor;
        image4Avatar.layer.borderWidth = 0.5;
        [image4Avatar sd_setImageWithURL:[NSURL URLWithString:str4AvatarUrl]placeholderImage:[UIImage imageNamed:@"defaultavatar"]];
        return image4Avatar;
    }
    else if (avatar.length > 0)
    {
        NSString *str4AvatarUrl = [NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, avatar];
        UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
        image4Avatar.layer.cornerRadius = width / 2;
        image4Avatar.clipsToBounds = YES;
        image4Avatar.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
        image4Avatar.layer.cornerRadius = width / 2;
        image4Avatar.layer.borderColor = [UIColor colorWithWhite:.9 alpha:1].CGColor;
        image4Avatar.layer.borderWidth = 0.5;
        [image4Avatar sd_setImageWithURL:[NSURL URLWithString:str4AvatarUrl]placeholderImage:[UIImage imageNamed:@"defaultavatar"]];
        return image4Avatar;
    }
    else
    {
        NSString *str = nil;
        if (nickName.length > 0)
        {
            unichar c = [nickName characterAtIndex:0];
            if (c >= 0xd800 && c <= 0xdbff)
                str = [nickName substringToIndex:2];
            else
                str = [nickName substringToIndex:1];
        }
        
        PersistentBackgroundLabel *label4Avatar = [[PersistentBackgroundLabel alloc]initWithFrame:CGRectMake(0, 0, width, height)];
        label4Avatar.layer.cornerRadius = width / 2;
        label4Avatar.clipsToBounds = YES;
        label4Avatar.text = str;
        label4Avatar.textAlignment = NSTextAlignmentCenter;
        label4Avatar.font = [UIFont systemFontOfSize:width / 2];
        label4Avatar.textColor = [UIColor whiteColor];
        label4Avatar.persistentBackgroundColor = [UIColor colorWithWhite:0.80 alpha:1];
        return label4Avatar;
    }
}

+ (UIView *)getAvatarWnd:(NSString *)uid nickName:(NSString *)nickName avatar:(NSString *)avatar frame:(CGRect)frame
{
    if (uid != nil && [[[BiChatGlobal sharedManager].dict4AvatarCache objectForKey:uid]length] > 0)
    {
        NSString *str4AvatarUrl = [NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, [[BiChatGlobal sharedManager].dict4AvatarCache objectForKey:uid]];
        UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:frame];
        image4Avatar.layer.cornerRadius = frame.size.height / 2;
        image4Avatar.clipsToBounds = YES;
        image4Avatar.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
        [image4Avatar sd_setImageWithURL:[NSURL URLWithString:str4AvatarUrl]placeholderImage:[UIImage imageNamed:@"defaultavatar"]];
        return image4Avatar;
    }
    else if (avatar != [NSNull null] && avatar.length > 0)
    {
        NSString *str4AvatarUrl = [NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, avatar];
        UIImageView *image4Avatar = [[UIImageView alloc]initWithFrame:frame];
        image4Avatar.layer.cornerRadius = frame.size.height / 2;
        image4Avatar.clipsToBounds = YES;
        image4Avatar.backgroundColor = [UIColor colorWithWhite:.85 alpha:1];
        [image4Avatar sd_setImageWithURL:[NSURL URLWithString:str4AvatarUrl]placeholderImage:[UIImage imageNamed:@"defaultavatar"]];
        return image4Avatar;
    }
    else
    {
        NSString *str = nil;
        if (nickName.length > 0)
        {
            unichar c = [nickName characterAtIndex:0];
            if (c >= 0xd800 && c <= 0xdbff)
                str = [nickName substringToIndex:2];
            else
                str = [nickName substringToIndex:1];
        }

        PersistentBackgroundLabel *label4Avatar = [[PersistentBackgroundLabel alloc]initWithFrame:frame];
        label4Avatar.layer.cornerRadius = frame.size.height / 2;
        label4Avatar.clipsToBounds = YES;
        label4Avatar.text = str;
        label4Avatar.textAlignment = NSTextAlignmentCenter;
        label4Avatar.font = [UIFont systemFontOfSize:frame.size.height / 2];
        label4Avatar.textColor = [UIColor whiteColor];
        label4Avatar.persistentBackgroundColor = [UIColor colorWithWhite:0.80 alpha:1];
        return label4Avatar;
    }
}

//生成一个文件类型图标
+ (UIView *)getFileAvatarWnd:(NSString *)type width:(CGFloat)width height:(CGFloat)height
{
    type = [type lowercaseString];
    UIImageView *image4FileAvatar = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    if ([type isEqualToString:@"pdf"])
    {
        image4FileAvatar.image = [UIImage imageNamed:@"file_icon_pdf"];
        return image4FileAvatar;
    }
    else if ([type isEqualToString:@"doc"] ||
             [type isEqualToString:@"docx"])
    {
        image4FileAvatar.image = [UIImage imageNamed:@"file_icon_word"];
        return image4FileAvatar;
    }
    else if ([type isEqualToString:@"ppt"] ||
             [type isEqualToString:@"pptx"])
    {
        image4FileAvatar.image = [UIImage imageNamed:@"file_icon_ppt"];
        return image4FileAvatar;
    }
    else if ([type isEqualToString:@"xls"] ||
             [type isEqualToString:@"xlsx"])
    {
        image4FileAvatar.image = [UIImage imageNamed:@"file_icon_excel"];
        return image4FileAvatar;
    }
    else if ([type isEqualToString:@"txt"])
    {
        image4FileAvatar.image = [UIImage imageNamed:@"file_icon_txt"];
        return image4FileAvatar;
    }
    else if ([type isEqualToString:@"jpg"] ||
             [type isEqualToString:@"jpeg"] ||
             [type isEqualToString:@"gif"] ||
             [type isEqualToString:@"png"] ||
             [type isEqualToString:@"bmp"])
    {
        image4FileAvatar.image = [UIImage imageNamed:@"file_icon_img"];
        return image4FileAvatar;
    }
    else
    {
        image4FileAvatar.image = [UIImage imageNamed:@"file_icon_other"];
        return image4FileAvatar;
    }
}

+ (UIView *)getFileAvatarWnd:(NSString *)type frame:(CGRect)frame
{
    type = [type lowercaseString];
    UIImageView *image4FileAvatar = [[UIImageView alloc]initWithFrame:frame];
    if ([type isEqualToString:@"pdf"])
    {
        image4FileAvatar.image = [UIImage imageNamed:@"file_icon_pdf"];
        return image4FileAvatar;
    }
    else if ([type isEqualToString:@"doc"] ||
             [type isEqualToString:@"docx"])
    {
        image4FileAvatar.image = [UIImage imageNamed:@"file_icon_word"];
        return image4FileAvatar;
    }
    else if ([type isEqualToString:@"ppt"] ||
             [type isEqualToString:@"pptx"])
    {
        image4FileAvatar.image = [UIImage imageNamed:@"file_icon_ppt"];
        return image4FileAvatar;
    }
    else if ([type isEqualToString:@"xls"] ||
             [type isEqualToString:@"xlsx"])
    {
        image4FileAvatar.image = [UIImage imageNamed:@"file_icon_excel"];
        return image4FileAvatar;
    }
    else if ([type isEqualToString:@"txt"])
    {
        image4FileAvatar.image = [UIImage imageNamed:@"file_icon_txt"];
        return image4FileAvatar;
    }
    else if ([type isEqualToString:@"jpg"] ||
             [type isEqualToString:@"jpeg"] ||
             [type isEqualToString:@"gif"] ||
             [type isEqualToString:@"png"] ||
             [type isEqualToString:@"bmp"])
    {
        image4FileAvatar.image = [UIImage imageNamed:@"file_icon_img"];
        return image4FileAvatar;
    }
    else
    {
        image4FileAvatar.image = [UIImage imageNamed:@"file_icon_other"];
        return image4FileAvatar;
    }
}

//生成一个虚拟子群的群头像
+ (UIView *)getVirtualGroupAvatarWnd:(NSString *)uid nickName:(NSString *)nickName groupUserCount:(NSInteger)groupUserCount width:(CGFloat)width height:(CGFloat)height
{
    UIImageView *image4VirtualGroupAvatar = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    if (groupUserCount > 400)
        image4VirtualGroupAvatar.image = [UIImage imageNamed:@"vgroup_500"];
    else if (groupUserCount > 300)
        image4VirtualGroupAvatar.image = [UIImage imageNamed:@"vgroup_400"];
    else if (groupUserCount > 200)
        image4VirtualGroupAvatar.image = [UIImage imageNamed:@"vgroup_300"];
    else if (groupUserCount > 100)
        image4VirtualGroupAvatar.image = [UIImage imageNamed:@"vgroup_200"];
    else
        image4VirtualGroupAvatar.image = [UIImage imageNamed:@"vgroup_100"];
    
    NSString *str = nil;
    if (nickName.length > 0)
    {
        unichar c = [nickName characterAtIndex:0];
        if (c >= 0xd800 && c <= 0xdbff)
            str = [nickName substringToIndex:2];
        else
            str = [nickName substringToIndex:1];
    }

    PersistentBackgroundLabel *label4Avatar = [[PersistentBackgroundLabel alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    label4Avatar.layer.cornerRadius = width / 2;
    label4Avatar.clipsToBounds = YES;
    label4Avatar.text = str;
    label4Avatar.textAlignment = NSTextAlignmentCenter;
    label4Avatar.font = [UIFont systemFontOfSize:width / 2];
    label4Avatar.textColor = [UIColor whiteColor];
    label4Avatar.persistentBackgroundColor = [UIColor clearColor];
    [image4VirtualGroupAvatar addSubview:label4Avatar];
    
    return image4VirtualGroupAvatar;
}

//生成一个虚拟子群的群头像
+ (UIView *)getVirtualGroupAvatarWnd:(NSString *)uid nickName:(NSString *)nickName groupUserCount:(NSInteger)groupUserCount frame:(CGRect)frame
{
    UIImageView *image4VirtualGroupAvatar = [[UIImageView alloc]initWithFrame:frame];
    if (groupUserCount > 400)
        image4VirtualGroupAvatar.image = [UIImage imageNamed:@"vgroup_500"];
    else if (groupUserCount > 300)
        image4VirtualGroupAvatar.image = [UIImage imageNamed:@"vgroup_400"];
    else if (groupUserCount > 200)
        image4VirtualGroupAvatar.image = [UIImage imageNamed:@"vgroup_300"];
    else if (groupUserCount > 100)
        image4VirtualGroupAvatar.image = [UIImage imageNamed:@"vgroup_200"];
    else
        image4VirtualGroupAvatar.image = [UIImage imageNamed:@"vgroup_100"];
    
    NSString *str = nil;
    if (nickName.length > 0)
    {
        unichar c = [nickName characterAtIndex:0];
        if (c >= 0xd800 && c <= 0xdbff)
            str = [nickName substringToIndex:2];
        else
            str = [nickName substringToIndex:1];
    }
    
    PersistentBackgroundLabel *label4Avatar = [[PersistentBackgroundLabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    label4Avatar.layer.cornerRadius = frame.size.width / 2;
    label4Avatar.clipsToBounds = YES;
    label4Avatar.text = str;
    label4Avatar.textAlignment = NSTextAlignmentCenter;
    label4Avatar.font = [UIFont systemFontOfSize:frame.size.width / 2];
    label4Avatar.textColor = [UIColor whiteColor];
    label4Avatar.persistentBackgroundColor = [UIColor clearColor];
    [image4VirtualGroupAvatar addSubview:label4Avatar];

    return image4VirtualGroupAvatar;
}

//将电话号码正规化，去掉所有的空格，括号
+ (NSString *)normalizeMobileNumber:(NSString *)mobile
{
    //提前处理
    mobile = [mobile stringByReplacingOccurrencesOfString:@"?" withString:@""];
    mobile = [mobile stringByReplacingOccurrencesOfString:@" " withString:@""];        //特殊空格字符
    mobile = [mobile stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobile = [mobile stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobile = [mobile stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobile = [mobile stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //是"00"开头
    if ([mobile hasPrefix:@"00"] && mobile.length > 2)
        mobile = [NSString stringWithFormat:@"+%@", [mobile substringFromIndex:2]];

    //含有地区号？
    if ([mobile hasPrefix:@"+"])
    {
        //其他国家的区号,需要查表
        for (NSDictionary *item in [BiChatGlobal sharedManager].array4CountryInfo)
        {
            if ([mobile hasPrefix:[item objectForKey:@"code"]])
            {
                return [NSString stringWithFormat:@"%@ %@", [item objectForKey:@"code"], [mobile substringFromIndex:[[item objectForKey:@"code"]length]]];
            }
        }
        
        //没找到，直接返回
        return mobile;
    }
    else
    {
        //是不是中国的手机号码
        if ([mobile hasPrefix:@"1"] &&
            mobile.length == 11)
            return [NSString stringWithFormat:@"+86 %@", mobile];
        
        //没有地区号，添加当地的地区号
        //NSLocale *locale = [NSLocale currentLocale];
        return [NSString stringWithFormat:@"%@ %@", [BiChatGlobal sharedManager].lastLoginAreaCode, mobile];
    }
}

+ (NSString *)humanlizeMobileNumber:(NSString *)mobile
{
    mobile = [BiChatGlobal normalizeName:mobile];
    if ([mobile hasPrefix:@"+"])
    {
        NSArray *array = [mobile componentsSeparatedByString:@" "];
        if (array.count > 1)
        {
            NSString *areaCode = [array firstObject];
            NSMutableArray *array4Opt = [[NSMutableArray alloc]initWithArray:array];
            [array4Opt removeObjectAtIndex:0];
            NSString *mobileNumber = [array4Opt componentsJoinedByString:@""];
            return [BiChatGlobal humanlizeMobileNumber:areaCode mobile:mobileNumber];
        }
        else
            return mobile;
    }
    else
        return mobile;
}

+ (NSString *)humanlizeMobileNumber:(NSString *)areaCode mobile:(NSString *)mobile
{
    if (mobile.length == 11)
        return [NSString stringWithFormat:@"%@ %@ %@ %@",
                areaCode,
                [mobile substringWithRange:NSMakeRange(0, 3)],
                [mobile substringWithRange:NSMakeRange(3, 4)],
                [mobile substringWithRange:NSMakeRange(7, 4)]];
    else if (mobile.length == 9)
        return [NSString stringWithFormat:@"%@ %@ %@ %@",
                areaCode,
                [mobile substringWithRange:NSMakeRange(0, 3)],
                [mobile substringWithRange:NSMakeRange(3, 3)],
                [mobile substringWithRange:NSMakeRange(6, 3)]];
    else if (mobile.length == 10)
        return [NSString stringWithFormat:@"%@ %@ %@ %@",
                areaCode,
                [mobile substringWithRange:NSMakeRange(0, 3)],
                [mobile substringWithRange:NSMakeRange(3, 3)],
                [mobile substringWithRange:NSMakeRange(6, 4)]];
    else if (mobile.length == 8)
        return [NSString stringWithFormat:@"%@ %@ %@",
                areaCode,
                [mobile substringWithRange:NSMakeRange(0, 4)],
                [mobile substringWithRange:NSMakeRange(4, 4)]];
    else
        return [NSString stringWithFormat:@"%@ %@", areaCode, mobile];
}

+ (NSString *)normalizeName:(NSString *)name
{
    return [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

+ (NSString *)getAreaCodeByCountryCode:(NSString *)countryCode
{
    return [[BiChatGlobal sharedManager].dict4CountryCode2AreaCode objectForKey:countryCode];
}

+ (NSString *)getCountryNameByAreaCode:(NSString *)areaCode
{
    for (NSDictionary *item in [BiChatGlobal sharedManager].array4CountryInfo)
    {
        if ([areaCode isEqualToString:[item objectForKey:@"code"]])
            return [item objectForKey:@"country"];
    }
    return @"";
}

+ (NSString *)getCountryFlagByAreaCode:(NSString *)areaCode
{
    for (NSDictionary *item in [BiChatGlobal sharedManager].array4CountryInfo)
    {
        if ([areaCode isEqualToString:[item objectForKey:@"code"]])
            return [item objectForKey:@"flag"];
    }
    return @"";
}

//从一个群的属性中找到这个群的昵称
+ (NSString *)getGroupNickName:(NSMutableDictionary *)groupProperty defaultNickName:(NSString *)defaultNickName
{
    if (groupProperty == nil)
        return defaultNickName;
    NSString *groupNickName = [groupProperty objectForKey:@"groupName"]==nil?@"":[groupProperty objectForKey:@"groupName"];
    
    //是否虚拟群
    if ([[groupProperty objectForKey:@"virtualGroupId"]length] > 0)
    {
        for (NSDictionary *item in [groupProperty objectForKey:@"virtualGroupSubList"])
        {
            if ([[groupProperty objectForKey:@"groupId"]isEqualToString:[item objectForKey:@"groupId"]])
            {
                if ([[item objectForKey:@"virtualGroupNum"]integerValue] == 0)
                    return [NSString stringWithFormat:@"%@ #%@", groupNickName,LLSTR(@"201503")];
                else if ([[item objectForKey:@"isBroadCastGroup"]boolValue])
                    return [NSString stringWithFormat:@"%@ #%@", groupNickName,LLSTR(@"201504")];
                else if ([[item objectForKey:@"groupNickName"]length] > 0)
                    return [NSString stringWithFormat:@"%@ #%@", groupNickName, [item objectForKey:@"groupNickName"]];
                else
                    return [NSString stringWithFormat:@"%@ #%ld", groupNickName, [[item objectForKey:@"virtualGroupNum"]integerValue]];
            }
        }
        
        return groupNickName;
    }
    
    //普通群
    return groupNickName;
}

//从一个群的属性中找到这个群的头像
+ (NSString *)getGroupAvatar:(NSMutableDictionary *)groupProperty
{
    //是否已经指定了avatar
    if ([groupProperty objectForKey:@"avatar"] != nil)
        return [groupProperty objectForKey:@"avatar"];
    
    //没有指定，那么就使用群主的avatar
    for (NSDictionary *item in [groupProperty objectForKey:@"groupUserList"])
    {
        if ([[item objectForKey:@"uid"]isEqualToString:[groupProperty objectForKey:@"ownerUid"]])
        {
            return [item objectForKey:@"avatar"]==nil?@"":[item objectForKey:@"avatar"];
        }
    }
    
    //没有找到
    return @"";
}

//我是否一个群的操作员（群主或者管理员）
+ (BOOL)isMeGroupOperator:(NSDictionary *)groupProperty
{
    //是否群主
    if ([[BiChatGlobal sharedManager].uid isEqualToString:[groupProperty objectForKey:@"ownerUid"]])
        return YES;
    
    //是否群管理员
    if ([[groupProperty objectForKey:@"assitantUid"]containsObject:[BiChatGlobal sharedManager].uid])
        return YES;
    
    return NO;
}

//一个用户是否一个群的操作员（群主或者管理员）
+ (BOOL)isUserGroupOperator:(NSDictionary *)groupProperty uid:(NSString *)uid
{
    //是否群主
    if ([uid isEqualToString:[groupProperty objectForKey:@"ownerUid"]])
        return YES;
    
    //是否群管理员
    if ([[groupProperty objectForKey:@"assitantUid"]containsObject:uid])
        return YES;
    
    return NO;
}

//我是否一个群的群主
+ (BOOL)isMeGroupOwner:(NSDictionary *)groupProperty
{
    //是否群主
    if ([[BiChatGlobal sharedManager].uid isEqualToString:[groupProperty objectForKey:@"ownerUid"]])
        return YES;
    
    return NO;
}

//一个用户是否一个群的群主
+ (BOOL)isUserGroupOwner:(NSDictionary *)groupProperty uid:(NSString *)uid
{
    //是否群主
    if ([uid isEqualToString:[groupProperty objectForKey:@"ownerUid"]])
        return YES;
    
    return NO;
}

//我是否一个群的嘉宾
+ (BOOL)isMeGroupVIP:(NSDictionary *)groupProperty
{
    if([[groupProperty objectForKey:@"vip"]containsObject:[BiChatGlobal sharedManager].uid])
        return YES;

    return NO;
}

//我是否在禁言列表里面
+ (BOOL)isMeInMuteList:(NSDictionary *)groupProperty
{
    //我在群的禁言列表中
    if ([[groupProperty objectForKey:@"muteUsers"]containsObject:[BiChatGlobal sharedManager].uid])
        return YES;

    return NO;
}

//一个用户是否在禁言列表里面
+ (BOOL)isUserInMuteList:(NSDictionary *)groupProperty uid:(NSString *)uid
{
    if ([[groupProperty objectForKey:@"muteUsers"]containsObject:uid])
        return YES;
    
    return NO;
}

//我是否在试用列表地里面
+ (BOOL)isMeInTrailList:(NSDictionary *)groupProperty
{
    //我是否为付费群使用用户
    if ([[groupProperty objectForKey:@"payGroup"]boolValue] &&
        [[groupProperty objectForKey:@"groupTrailUids"]containsObject:[BiChatGlobal sharedManager].uid])
        return YES;
    
    return NO;
}

//一个用户是否在试用列表里面
+ (BOOL)isUserInTrailList:(NSDictionary *)groupProperty uid:(NSString *)uid
{
    //我是否为付费群使用用户
    if ([[groupProperty objectForKey:@"payGroup"]boolValue] &&
        [[groupProperty objectForKey:@"groupTrailUids"]containsObject:uid])
        return YES;
    
    return NO;
}

//我是否在支付列表里面
+ (BOOL)isMeInPayList:(NSDictionary *)groupProperty
{
    //我是否在支付列表里面
    if (![[groupProperty objectForKey:@"payGroup"]boolValue])
        return NO;
    
    for (NSDictionary *item in [groupProperty objectForKey:@"waitingPayList"])
    {
        if ([[item objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid])
            return YES;
    }
    return NO;
}

//一个用户是否在支付列表里面
+ (BOOL)isUserInPayList:(NSDictionary *)groupProperty uid:(NSString *)uid
{
    //我是否在支付列表里面
    if (![[groupProperty objectForKey:@"payGroup"]boolValue])
        return NO;
    
    for (NSDictionary *item in [groupProperty objectForKey:@"waitingPayList"])
    {
        if ([[item objectForKey:@"uid"]isEqualToString:uid])
            return YES;
    }
    return NO;
}

//一个用户是否在群里(不包括超大群)
+ (BOOL)isUserInGroup:(NSDictionary *)groupProperty uid:(NSString *)uid
{
    for (NSDictionary *item in [groupProperty objectForKey:@"groupUserList"])
    {
        if ([uid isEqualToString:[item objectForKey:@"uid"]])
            return YES;
    }
    return NO;
}

//是否在群黑名单
+ (BOOL)isUserInGroupBlockList:(NSDictionary *)groupProperty uid:(NSString *)uid
{
    for (NSDictionary *item in [groupProperty objectForKey:@"groupBlockUserLevelTwo"])
    {
        if ([uid isEqualToString:[item objectForKey:@"uid"]])
            return YES;
    }
    
    return NO;
}

//一个子群是否虚拟群的广播群
+ (BOOL)isBroadcastGroup:(NSDictionary *)groupProperty groupId:(NSString *)groupId
{
    for (NSDictionary *item in [groupProperty objectForKey:@"virtualGroupSubList"])
    {
        if ([[item objectForKey:@"groupId"]isEqualToString:groupId] &&
            [[item objectForKey:@"isBroadCastGroup"]boolValue])
            return YES;
    }
    return NO;
}

//我是否在待批准列表里面
+ (BOOL)isMeInApproveList:(NSString *)groupId
{
    for (NSDictionary *item in [BiChatGlobal sharedManager].array4ApproveList)
    {
        if ([[BiChatGlobal sharedManager].uid isEqualToString:[item objectForKey:@"uid"]] &&
            [groupId isEqualToString:[item objectForKey:@"groupId"]])
            return YES;
    }
    return NO;
}

+ (BOOL)isQueryGroup:(NSString *)groupId
{
    NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:groupId];
    return [[groupProperty objectForKey:@"groupType"]isEqualToString:@"QUERY"];
}

//判断一个群是否客服群
+ (BOOL)isCustomerServiceGroup:(NSString *)groupId
{
    NSDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:groupId];
    return ([[groupProperty objectForKey:@"groupType"]isEqualToString:@"QUERY"] &&
            [BiChatGlobal isMeGroupOwner:groupProperty]);
}

+ (NSMutableDictionary *)mutableDictionaryWithDictory:(NSDictionary *)dictionary
{
    NSData *data = [dictionary mj_JSONData];
    return [data mutableObjectFromJSONData];
}

//返回一条消息的可阅读形式
+ (NSString *)getMessageReadableString:(NSDictionary *)message groupProperty:(NSDictionary *)groupProperty
{
    NSInteger messageType = [[message objectForKey:@"type"]integerValue];
    if (messageType == MESSAGE_CONTENT_TYPE_NONE) return @"";
    else if (messageType == MESSAGE_CONTENT_TYPE_TEXT)
    {
        NSString *content = [NSString stringWithFormat:@"%@", [message objectForKey:@"content"]];
        
        //是否有多语言处理
        if ([message objectForKey:@"langs"] != nil)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *langs = [dec objectWithData:[[message objectForKey:@"langs"]dataUsingEncoding:NSUTF8StringEncoding]];
            if ([langs objectForKey:[DFLanguageManager getLanguageName]] != nil)
                content = [langs objectForKey:[DFLanguageManager getLanguageName]];
        }

        return content;
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_TIME) return [NSString stringWithFormat:@"%@", [message objectForKey:@"content"]];
    else if (messageType == MESSAGE_CONTENT_TYPE_HELLO) return [NSString stringWithFormat:@"%@", [message objectForKey:@"content"]];
    else if (messageType == MESSAGE_CONTENT_TYPE_IMAGE) return LLSTR(@"101183");
    else if (messageType == MESSAGE_CONTENT_TYPE_SOUND) return LLSTR(@"101182");
    else if (messageType == MESSAGE_CONTENT_TYPE_NEWS) return LLSTR(@"101194");
    else if (messageType == MESSAGE_CONTENT_TYPE_VIDEO) return LLSTR(@"101180");
    else if (messageType == MESSAGE_CONTENT_TYPE_ANIMATION) return @"[动画表情]";
    else if (messageType == MESSAGE_CONTENT_TYPE_RECALL)
    {
        //撤回了自己的消息
        if ([[message objectForKey:@"sender"]isEqualToString:[message objectForKey:@"orignalSender"]])
        {
            if ([[message objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
            {
                if ([[message objectForKey:@"content"]length] > 0)
                {
                    JSONDecoder *dec = [JSONDecoder new];
                    NSDictionary *dict = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
                    if (dict == nil)
                        return LLSTR(@"203101");
                    else
                        return LLSTR(@"203101");
                }
                else
                    return LLSTR(@"203101");
            }
            else
                return [LLSTR(@"202003") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
        }
        else
        {
            if ([[message objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
                return [LLSTR(@"202004") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"orignalSender"] groupProperty:groupProperty nickName:[message objectForKey:@"orignalSenderNickName"]]]];
            else
                return [LLSTR(@"202005") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]], [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"orignalSender"] groupProperty:groupProperty nickName:[message objectForKey:@"orignalSenderNickName"]]]];
        }
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_CONTACTCHANGED)
        return @"通讯录变化";
    else if (messageType == MESSAGE_CONTENT_TYPE_QUITGROUP)
        return [LLSTR(@"202007") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    else if (messageType == MESSAGE_CONTENT_TYPE_ADDTOGROUP)
    {
        //生成被邀请人列表
        JSONDecoder *dec = [JSONDecoder new];
        NSArray *array = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSMutableArray *array4NickName = [NSMutableArray array];
        if (array.count > 0)
        {
            for (int i = 0; i < array.count; i ++)
            {
                NSString *nickName = [[array objectAtIndex:i]objectForKey:@"nickName"]==nil?@"":[[array objectAtIndex:i]objectForKey:@"nickName"];
                NSString *uid = [[array objectAtIndex:i]objectForKey:@"uid"];
                [array4NickName addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:uid groupProperty:groupProperty nickName:nickName]];
            }
            return [LLSTR(@"202008") llReplaceWithArray:@[
                    [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"]groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]],
                    [array4NickName componentsJoinedByString:@", "]]];
        }
        else
            return @"--";
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_ADDTOGROUPTRAIL)
    {
        //生成被邀请人列表
        JSONDecoder *dec = [JSONDecoder new];
        NSArray *array = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSMutableArray *array4NickName = [NSMutableArray array];
        if (array.count > 0)
        {
            for (int i = 0; i < array.count; i ++)
            {
                NSString *nickName = [[array objectAtIndex:i]objectForKey:@"nickName"]==nil?@"":[[array objectAtIndex:i]objectForKey:@"nickName"];
                NSString *uid = [[array objectAtIndex:i]objectForKey:@"uid"];
                [array4NickName addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:uid groupProperty:groupProperty nickName:nickName]];
            }
            return [LLSTR(@"204209") llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"]groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]],
                                                          [array4NickName componentsJoinedByString:@", "]]];
        }
        else
            return @"--";
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_ALREDYINGROUPWAITINGPAY)
    {
        //生成被邀请人列表
        JSONDecoder *dec = [JSONDecoder new];
        NSArray *array = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSMutableArray *array4NickName = [NSMutableArray array];
        if (array.count > 0)
        {
            for (int i = 0; i < array.count; i ++)
            {
                NSString *nickName = [[array objectAtIndex:i]objectForKey:@"nickName"]==nil?@"":[[array objectAtIndex:i]objectForKey:@"nickName"];
                NSString *uid = [[array objectAtIndex:i]objectForKey:@"uid"];
                [array4NickName addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:uid groupProperty:groupProperty nickName:nickName]];
            }
            return [LLSTR(@"204210") llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"]groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]], [array4NickName componentsJoinedByString:@", "]]];
        }
        else
            return @"--";
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_JOINGROUPTRAIL)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        if ([[targetInfo objectForKey:@"source"]length] > 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *sourceInfo = [dec objectWithData:[[targetInfo objectForKey:@"source"]dataUsingEncoding:NSUTF8StringEncoding]];
            if ([[sourceInfo objectForKey:@"source"]length] > 0)
                return [LLSTR(@"204211") llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]],
                                                              [BiChatGlobal getSourceString:[sourceInfo objectForKey:@"source"]]]];
            else
                return [LLSTR(@"204211") llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]], [BiChatGlobal getSourceString:[targetInfo objectForKey:@"source"]]]];
        }
        else
            return [LLSTR(@"204211") llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]], @""]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_JOINGROUPWAITINGPAY)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        if ([[targetInfo objectForKey:@"source"]length] > 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *sourceInfo = [dec objectWithData:[[targetInfo objectForKey:@"source"]dataUsingEncoding:NSUTF8StringEncoding]];
            if ([[sourceInfo objectForKey:@"source"]length] > 0)
                return [LLSTR(@"204212") llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]],
                                                              [BiChatGlobal getSourceString:[sourceInfo objectForKey:@"source"]]]];
            else
                return [LLSTR(@"204212") llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]], [BiChatGlobal getSourceString:[targetInfo objectForKey:@"source"]]]];
        }
        else
            return [LLSTR(@"204212") llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]], @""]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL)
    {
        //生成被邀请人列表
        JSONDecoder *dec = [JSONDecoder new];
        NSArray *array = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSMutableArray *array4NickName = [NSMutableArray array];
        if (array.count > 0)
        {
            for (int i = 0; i < array.count; i ++)
            {
                NSString *nickName = [[array objectAtIndex:i]objectForKey:@"nickName"]==nil?@"":[[array objectAtIndex:i]objectForKey:@"nickName"];
                NSString *uid = [[array objectAtIndex:i]objectForKey:@"uid"];
                [array4NickName addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:uid groupProperty:groupProperty nickName:nickName]];
            }
            return [LLSTR(@"202009") llReplaceWithArray:@[ [array4NickName componentsJoinedByString:@", "]]];
        }
        else
            return @"--";
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_ADDTOGROUPALREADYINGROUP)
    {
        //生成被邀请人列表
        JSONDecoder *dec = [JSONDecoder new];
        NSArray *array = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        if (![array isKindOfClass:[NSArray class]])
            return @"--";
        NSMutableArray *array4NickName = [NSMutableArray array];
        if (array.count > 0)
        {
            for (int i = 0; i < array.count; i ++)
            {
                NSString *nickName = [[array objectAtIndex:i]objectForKey:@"nickName"]==nil?@"":[[array objectAtIndex:i]objectForKey:@"nickName"];
                NSString *uid = [[array objectAtIndex:i]objectForKey:@"uid"];
                [array4NickName addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:uid groupProperty:groupProperty nickName:nickName]];
            }
            return [LLSTR(@"202010") llReplaceWithArray:@[ [array4NickName componentsJoinedByString:@", "]]];
        }
        else
            return @"--";
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL_FULL)
    {
        //生成被邀请人列表
        JSONDecoder *dec = [JSONDecoder new];
        NSArray *array = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSMutableArray *array4NickName = [NSMutableArray array];
        if (array.count > 0)
        {
            for (int i = 0; i < array.count; i ++)
            {
                NSString *nickName = [[array objectAtIndex:i]objectForKey:@"nickName"]==nil?@"":[[array objectAtIndex:i]objectForKey:@"nickName"];
                NSString *uid = [[array objectAtIndex:i]objectForKey:@"uid"];
                [array4NickName addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:uid groupProperty:groupProperty nickName:nickName]];
            }
            return [LLSTR(@"202011") llReplaceWithArray:@[ [array4NickName componentsJoinedByString:@", "]]];
        }
        else
            return @"--";
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL_BLOCKED)
    {
        //生成被邀请人列表
        JSONDecoder *dec = [JSONDecoder new];
        NSArray *array = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSMutableArray *array4NickName = [NSMutableArray array];
        if (array.count > 0)
        {
            for (int i = 0; i < array.count; i ++)
            {
                NSString *nickName = [[array objectAtIndex:i]objectForKey:@"nickName"]==nil?@"":[[array objectAtIndex:i]objectForKey:@"nickName"];
                NSString *uid = [[array objectAtIndex:i]objectForKey:@"uid"];
                [array4NickName addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:uid groupProperty:groupProperty nickName:nickName]];
            }
            return [LLSTR(@"202012") llReplaceWithArray:@[ [array4NickName componentsJoinedByString:@", "]]];
        }
        else
            return @"--";
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL_NOTINPENDINGLIST)
    {
        //生成被邀请人列表
        JSONDecoder *dec = [JSONDecoder new];
        NSArray *array = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSMutableArray *array4NickName = [NSMutableArray array];
        if (array.count > 0)
        {
            for (int i = 0; i < array.count; i ++)
            {
                NSString *nickName = [[array objectAtIndex:i]objectForKey:@"nickName"]==nil?@"":[[array objectAtIndex:i]objectForKey:@"nickName"];
                NSString *uid = [[array objectAtIndex:i]objectForKey:@"uid"];
                [array4NickName addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:uid groupProperty:groupProperty nickName:nickName]];
            }
            return [LLSTR(@"202013") llReplaceWithArray:@[ [array4NickName componentsJoinedByString:@", "]]];
        }
        else
            return @"--";
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_AGREEAPPLYFAIL_FULL)
    {
        //生成被邀请人列表
        JSONDecoder *dec = [JSONDecoder new];
        NSArray *array = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSMutableArray *array4NickName = [NSMutableArray array];
        if (array.count > 0)
        {
            for (int i = 0; i < array.count; i ++)
            {
                NSString *nickName = [[array objectAtIndex:i]objectForKey:@"nickName"]==nil?@"":[[array objectAtIndex:i]objectForKey:@"nickName"];
                NSString *uid = [[array objectAtIndex:i]objectForKey:@"uid"];
                [array4NickName addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:uid groupProperty:groupProperty nickName:nickName]];
            }
            return [LLSTR(@"202011") llReplaceWithArray:@[ [array4NickName componentsJoinedByString:@", "]]];
        }
        else
            return @"--";
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_AGREEADDTOGROUPTRAIL)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSArray *array = [targetInfo objectForKey:@"userList"];
        NSMutableArray *array4NickName = [NSMutableArray array];
        if (array.count > 0)
        {
            for (int i = 0; i < array.count; i ++)
            {
                NSString *nickName = [[array objectAtIndex:i]objectForKey:@"nickName"]==nil?@"":[[array objectAtIndex:i]objectForKey:@"nickName"];
                NSString *uid = [[array objectAtIndex:i]objectForKey:@"uid"];
                [array4NickName addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:uid groupProperty:groupProperty nickName:nickName]];
            }
        }

        return [LLSTR(@"204361") llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"inviter"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"inviterNickName"]],
                                                      [array4NickName componentsJoinedByString:@", "],
                                                      [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_AGREEADDTOGROUPALREADYINWAITINGPAY)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSArray *array = [targetInfo objectForKey:@"userList"];
        NSMutableArray *array4NickName = [NSMutableArray array];
        if (array.count > 0)
        {
            for (int i = 0; i < array.count; i ++)
            {
                NSString *nickName = [[array objectAtIndex:i]objectForKey:@"nickName"]==nil?@"":[[array objectAtIndex:i]objectForKey:@"nickName"];
                NSString *uid = [[array objectAtIndex:i]objectForKey:@"uid"];
                [array4NickName addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:uid groupProperty:groupProperty nickName:nickName]];
            }
        }
        
        return [LLSTR(@"204362") llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"inviter"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"inviterNickName"]],
                                                      [array4NickName componentsJoinedByString:@", "],
                                                      [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_AGREEJOINGROUPTRAIL)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSArray *array = [targetInfo objectForKey:@"userList"];
        NSMutableArray *array4NickName = [NSMutableArray array];
        if (array.count > 0)
        {
            for (int i = 0; i < array.count; i ++)
            {
                NSString *nickName = [[array objectAtIndex:i]objectForKey:@"nickName"]==nil?@"":[[array objectAtIndex:i]objectForKey:@"nickName"];
                NSString *uid = [[array objectAtIndex:i]objectForKey:@"uid"];
                [array4NickName addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:uid groupProperty:groupProperty nickName:nickName]];
            }
        }
        
        return [LLSTR(@"204363") llReplaceWithArray:@[[array4NickName componentsJoinedByString:@", "],
                                                      [BiChatGlobal getSourceString:[targetInfo objectForKey:@"source"]],
                                                      [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_AGREEJOINGROUPALREADYINWAITINGPAY)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSArray *array = [targetInfo objectForKey:@"userList"];
        NSMutableArray *array4NickName = [NSMutableArray array];
        if (array.count > 0)
        {
            for (int i = 0; i < array.count; i ++)
            {
                NSString *nickName = [[array objectAtIndex:i]objectForKey:@"nickName"]==nil?@"":[[array objectAtIndex:i]objectForKey:@"nickName"];
                NSString *uid = [[array objectAtIndex:i]objectForKey:@"uid"];
                [array4NickName addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:uid groupProperty:groupProperty nickName:nickName]];
            }
        }
        
        return [LLSTR(@"204364") llReplaceWithArray:@[[array4NickName componentsJoinedByString:@", "],
                                                      [BiChatGlobal getSourceString:[targetInfo objectForKey:@"source"]],
                                                      [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_APPROVEADDGROUP)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSArray *array = [targetInfo objectForKey:@"userList"];
        NSMutableArray *array4NickName = [NSMutableArray array];
        if (array.count > 0)
        {
            for (int i = 0; i < array.count; i ++)
            {
                NSString *nickName = [[array objectAtIndex:i]objectForKey:@"nickName"]==nil?@"":[[array objectAtIndex:i]objectForKey:@"nickName"];
                NSString *uid = [[array objectAtIndex:i]objectForKey:@"uid"];
                [array4NickName addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:uid groupProperty:groupProperty nickName:nickName]];
            }
        }
        
        return [LLSTR(@"202137") llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"inviter"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"inviterNickName"]],
                                                      [array4NickName componentsJoinedByString:@", "],
                                                      [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_APPROVEJOINGROUP)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSArray *array = [targetInfo objectForKey:@"userList"];
        NSMutableArray *array4NickName = [NSMutableArray array];
        if (array.count > 0)
        {
            for (int i = 0; i < array.count; i ++)
            {
                NSString *nickName = [[array objectAtIndex:i]objectForKey:@"nickName"]==nil?@"":[[array objectAtIndex:i]objectForKey:@"nickName"];
                NSString *uid = [[array objectAtIndex:i]objectForKey:@"uid"];
                [array4NickName addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:uid groupProperty:groupProperty nickName:nickName]];
            }
        }
        
        return [LLSTR(@"202138") llReplaceWithArray:@[[array4NickName componentsJoinedByString:@", "],
                                                      [BiChatGlobal getSourceString:[targetInfo objectForKey:@"source"]],
                                                      [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUPAUTOSWITCH_MUTE)
        return LLSTR(@"202016");
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUPDISMISS)
    {
        if ([[groupProperty objectForKey:@"ownerUid"]isEqualToString:[BiChatGlobal sharedManager].uid])
            return LLSTR(@"202017");
        else
            return [LLSTR(@"202018") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"]groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUPRESTART)
        return LLSTR(@"202019");
    else if (messageType == MESSAGE_CONTENT_TYPE_CHANGEGROUPNAME)
        return [LLSTR(@"202020") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"]groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]], [message objectForKey:@"content"]]];
    else if (messageType == MESSAGE_CONTENT_TYPE_CHANGENICKNAME)
        return @"修改群昵称消息";      //本消息用于日志，不需要支持多语言
    else if (messageType == MESSAGE_CONTENT_TYPE_CHANGESUBGROUPNICKNAME)
        return [LLSTR(@"202022") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"]groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]], [message objectForKey:@"content"]]];
    else if (messageType == MESSAGE_CONTENT_TYPE_CHANGESUBGROUPNICKNAME2)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        return [LLSTR(@"202023") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"]groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]], [NSString stringWithFormat:@"%@",[targetInfo objectForKey:@"virtualGroupNum"]], [targetInfo objectForKey:@"newNickName"]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_CHANGEGROUPAVATAR)
        return [LLSTR(@"202024") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    else if (messageType == MESSAGE_CONTENT_TYPE_KICKOUTGROUP)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSArray *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSMutableArray *array4NickName = [NSMutableArray array];
        for (NSDictionary *item in targetInfo)
        {
            NSString *nickName = [item objectForKey:@"nickName"];
            NSString *uid = [item objectForKey:@"uid"];
            [array4NickName addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:uid groupProperty:groupProperty nickName:nickName]];
        }
        
        return [LLSTR(@"202025") llReplaceWithArray:@[
                [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"]groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]],
                [array4NickName componentsJoinedByString:@"、"]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_SYSTEM) return [message objectForKey:@"content"];
    else if (messageType == MESSAGE_CONTENT_TYPE_CHANGEGROUPOWNER)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        return [LLSTR(@"202026") llReplaceWithArray:@[
                [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"]groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]],
                [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"] groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUPBLOCK)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSArray *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSMutableArray *array4NickName = [NSMutableArray array];
        for (NSDictionary *item in targetInfo)
        {
            NSString *nickName = [item objectForKey:@"nickName"];
            NSString *uid = [item objectForKey:@"uid"];
            [array4NickName addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:uid groupProperty:groupProperty nickName:nickName]];
        }
        
        return [LLSTR(@"202027") llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"]groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]], [array4NickName componentsJoinedByString:@"、"]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUPUNBLOCK)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSArray *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSMutableArray *array4NickName = [NSMutableArray array];
        for (NSDictionary *item in targetInfo)
        {
            NSString *nickName = [item objectForKey:@"nickName"];
            NSString *uid = [item objectForKey:@"uid"];
            [array4NickName addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:uid groupProperty:groupProperty nickName:nickName]];
        }
        
        return [LLSTR(@"202028") llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"]groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]], [array4NickName componentsJoinedByString:@"、"]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_ADDASSISTANT)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSArray *array4NewAssistant = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSMutableArray *array4NewAssistantNickName = [NSMutableArray array];
        for (NSDictionary *item in array4NewAssistant)
            [array4NewAssistantNickName addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[item objectForKey:@"uid"] groupProperty:groupProperty nickName:[item objectForKey:@"nickName"]]];
        NSString *str = [array4NewAssistantNickName componentsJoinedByString:@"、"];
        return [LLSTR(@"202029") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"]groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]], str]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_DELASSISTANT)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSArray *array4NewAssistant = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSMutableArray *array4NewAssistantNickName = [NSMutableArray array];
        for (NSDictionary *item in array4NewAssistant)
            [array4NewAssistantNickName addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[item objectForKey:@"uid"] groupProperty:groupProperty nickName:[item objectForKey:@"nickName"]]];
        NSString *str = [array4NewAssistantNickName componentsJoinedByString:@"、"];
        return [LLSTR(@"202030") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"]groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]], str]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_ADDVIP)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSArray *array4NewAssistant = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSMutableArray *array4NewAssistantNickName = [NSMutableArray array];
        for (NSDictionary *item in array4NewAssistant)
            [array4NewAssistantNickName addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[item objectForKey:@"uid"] groupProperty:groupProperty nickName:[item objectForKey:@"nickName"]]];
        NSString *str = [array4NewAssistantNickName componentsJoinedByString:@"、"];
        return [LLSTR(@"202031") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"]groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]], str]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_DELVIP)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSArray *array4NewAssistant = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSMutableArray *array4NewAssistantNickName = [NSMutableArray array];
        for (NSDictionary *item in array4NewAssistant)
            [array4NewAssistantNickName addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[item objectForKey:@"uid"] groupProperty:groupProperty nickName:[item objectForKey:@"nickName"]]];
        NSString *str = [array4NewAssistantNickName componentsJoinedByString:@"、"];
        return [LLSTR(@"202032") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"]groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]], str]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUPBOARDITEM)
        return [LLSTR(@"202033") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"]groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    else if (messageType == MESSAGE_CONTENT_TYPE_BIDIRECTIONAL_FRIEND)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        return [LLSTR(@"202034") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"] groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_PEER_MAKEFRIEND)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        return [LLSTR(@"202035") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"] groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_MAKEFRIEND)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        return [LLSTR(@"202036") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"] groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_BLOCK)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        return [LLSTR(@"202037") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"] groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_UNBLOCK)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        return [LLSTR(@"202038") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"] groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUP_AD)
        return LLSTR(@"203103");
    else if (messageType == MESSAGE_CONTENT_TYPE_REDPACKET)
        return LLSTR(@"101185");
    else if (messageType == MESSAGE_CONTENT_TYPE_REDPACKET_RECEIVE)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        //是我本人领自己的红包
        if ([[message objectForKey:@"sender"]isEqualToString:[targetInfo objectForKey:@"sender"]] &&
            [[message objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
            return [LLSTR(@"202040") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]getCoinDSymbolBySymbol:[targetInfo objectForKey:@"coinType"]]]];
        
        //是我本人发的红包
        else if ([[targetInfo objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
            return [LLSTR(@"202041") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"]groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]], [[BiChatGlobal sharedManager]getCoinDSymbolBySymbol:[targetInfo objectForKey:@"coinType"]]]];
        
        //是我本人领的红包
        else if ([[message objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
            return [LLSTR(@"202042") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"sender"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"senderNickName"]], [[BiChatGlobal sharedManager]getCoinDSymbolBySymbol:[targetInfo objectForKey:@"coinType"]]]];
        
        //别人领了别人的红包
        else
        {
            return [LLSTR(@"202043") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"]groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]], [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[targetInfo objectForKey:@"sender"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"senderNickName"]], [[BiChatGlobal sharedManager]getCoinDSymbolBySymbol:[targetInfo objectForKey:@"coinType"]]]];
        }
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_REDPACKET_EXHAUST)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        //是我本人发的红包
        if ([[BiChatGlobal sharedManager].uid isEqualToString:[targetInfo objectForKey:@"sender"]])
            return [LLSTR(@"202044") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]getCoinDSymbolBySymbol:[targetInfo objectForKey:@"coinType"]]]];
        else
            return [LLSTR(@"202045") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"sender"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"senderNickName"]], [[BiChatGlobal sharedManager]getCoinDSymbolBySymbol:[targetInfo objectForKey:@"coinType"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_REDPAKCET_JOINGROUP)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *redPacketInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        return [LLSTR(@"202046") llReplaceWithArray:@[
                [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"]groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]],
                [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[redPacketInfo objectForKey:@"sender"] groupProperty:groupProperty nickName:[redPacketInfo objectForKey:@"senderNickName"]],
                [[BiChatGlobal sharedManager]getCoinDSymbolBySymbol:[redPacketInfo objectForKey:@"coinType"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_MYINVITEDGROUP_CREATED)
    {
        return LLSTR(@"203105");
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_FILLMONEY)
    {
        JSONDecoder *dec = [JSONDecoder new];
        if (![[message objectForKey:@"content"]isKindOfClass:[NSString class]])
            return @"--";
        NSDictionary *fillMoneyInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSDictionary *CoinInfo = [[BiChatGlobal sharedManager]getCoinInfoBySymbol:[fillMoneyInfo objectForKey:@"symbol"]];
        if ([CoinInfo objectForKey:@"bit"] == nil)
        {
            return [LLSTR(@"203109") llReplaceWithArray:@[[NSString stringWithFormat:@"%@",[fillMoneyInfo objectForKey:@"value"]], [[BiChatGlobal sharedManager]getCoinDSymbolBySymbol:[fillMoneyInfo objectForKey:@"symbol"]]]];
        }
        else
        {
            NSString *format = [NSString stringWithFormat:@"%%.0%ldf", (long)[[CoinInfo objectForKey:@"bit"]integerValue]];
            return [LLSTR(@"203109") llReplaceWithArray:@[ [NSString stringWithFormat:format, [[fillMoneyInfo objectForKey:@"value"]doubleValue]], [[BiChatGlobal sharedManager]getCoinDSymbolBySymbol:[fillMoneyInfo objectForKey:@"symbol"]]]];
        }
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_GR_APPLYADDGROUPMEMBER)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSArray *friends = [targetInfo objectForKey:@"friends"];
        if (friends.count == 0)
            return @"-";
        
        //某人通过领红包进入本群,用于审批群
        return [LLSTR(@"202050") llReplaceWithArray:@[ [[friends firstObject]objectForKey:@"nickName"]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_GA_APPLYGROUP)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSArray *friends = [targetInfo objectForKey:@"friends"];
        if (friends.count == 0)
            return @"-";
        
        if ([[targetInfo objectForKey:@"source"]isEqualToString:@"CODE"])
            return [LLSTR(@"202051") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[[friends firstObject]objectForKey:@"uid"] groupProperty:groupProperty nickName:[[friends firstObject]objectForKey:@"nickName"]]]];
        else if ([[targetInfo objectForKey:@"source"]isEqualToString:@"LINK"])
            return [LLSTR(@"202052") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[[friends firstObject]objectForKey:@"uid"] groupProperty:groupProperty nickName:[[friends firstObject]objectForKey:@"nickName"]]]];
        else if ([[targetInfo objectForKey:@"source"]isEqualToString:@"WECHAT"])
            return [LLSTR(@"202053") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[[friends firstObject]objectForKey:@"uid"] groupProperty:groupProperty nickName:[[friends firstObject]objectForKey:@"nickName"]]]];
        else if ([[targetInfo objectForKey:@"source"]isEqualToString:@"REFCODE"])
            return [LLSTR(@"202054") llReplaceWithArray:@[
                    [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]],
                    [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"refUid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"refNickName"]]]];
        else if ([[targetInfo objectForKey:@"source"]length] > 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *sourceInfo = [dec objectWithData:[[targetInfo objectForKey:@"source"]dataUsingEncoding:NSUTF8StringEncoding]];
            if ([[sourceInfo objectForKey:@"source"]length] > 0)
                return [LLSTR(@"202055") llReplaceWithArray:@[
                        [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[[friends firstObject]objectForKey:@"uid"] groupProperty:groupProperty nickName:[[friends firstObject]objectForKey:@"nickName"]],
                        [BiChatGlobal getSourceString:[targetInfo objectForKey:@"source"]]]];
            else
                return [LLSTR(@"202055") llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[[friends firstObject]objectForKey:@"uid"] groupProperty:groupProperty nickName:[[friends firstObject]objectForKey:@"nickName"]], [BiChatGlobal getSourceString:[targetInfo objectForKey:@"source"]]]];
        }
        else
            return [LLSTR(@"202056") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[[friends firstObject]objectForKey:@"uid"] groupProperty:groupProperty nickName:[[friends firstObject]objectForKey:@"nickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_TRANSFERMONEY)
        return LLSTR(@"101184");
    else if (messageType == MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECEIVE)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        //是我本人发的转账
        if ([[targetInfo objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
            return [LLSTR(@"202057") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"receiver"] groupProperty:groupProperty nickName:[targetInfo objectForKey:@"receiverNickName"]]]];
        
        //是我本人领的转账
        else
            return [LLSTR(@"202058") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"sender"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"senderNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECALL)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        //是我本人发的转账
        if ([[targetInfo objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
            return [LLSTR(@"101604") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"receiver"] groupProperty:groupProperty nickName:[targetInfo objectForKey:@"receiverNickName"]]]];
        
        //是我本人领的转账
        else
            return [LLSTR(@"202129") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"sender"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"senderNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY)
        return LLSTR(@"101190");
    else if (messageType == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECEIVE)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        //是我本人发的交换
        if ([[targetInfo objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
            return [LLSTR(@"202059") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"receiver"] groupProperty:groupProperty nickName:[targetInfo objectForKey:@"receiverNickName"]]]];
        
        //是我本人领的交换
        else if ([[targetInfo objectForKey:@"receiver"]isEqualToString:[BiChatGlobal sharedManager].uid])
            return [LLSTR(@"202060") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"sender"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"senderNickName"]]]];
        
        //其他人看到这个消息
        else
            return [LLSTR(@"202127")llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"sender"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"senderNickName"]], [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"receiver"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"receiverNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECALL)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        //是我本人发的交换
        if ([[targetInfo objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
            return [LLSTR(@"202061") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"receiver"] groupProperty:groupProperty nickName:[targetInfo objectForKey:@"receiverNickName"]]]];
        
        //是我本人领的交换
        else
            return [LLSTR(@"202062") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"sender"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"senderNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_CARD)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        if ([[targetInfo objectForKey:@"cardType"]isEqualToString:@"publicAccountCard"])
            return [LLSTR(@"101188") llReplaceWithArray:@[ [targetInfo objectForKey:@"nickName"]]];
        else if ([[targetInfo objectForKey:@"cardType"]isEqualToString:@"groupCard"])
            return [LLSTR(@"101189") llReplaceWithArray:@[ [targetInfo objectForKey:@"nickName"]]];
        else
            return  [LLSTR(@"101187") llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_LOCATION)
        return LLSTR(@"101199");
    else if (messageType == MESSAGE_CONTENT_TYPE_NEWS_PUBLIC)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        return [LLSTR(@"101191") llReplaceWithArray:@[ [targetInfo objectForKey:@"title"]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_MESSAGECONBINE)
        return LLSTR(@"101193");
    else if (messageType == MESSAGE_CONTENT_TYPE_ASSIGNTOGROUP)
    {
        //生成被邀请人列表
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *dict = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSArray *array = [dict objectForKey:@"assignedMember"];
        NSMutableArray *array4NickName = [NSMutableArray array];
        if (array.count > 0)
        {
            for (int i = 0; i < array.count; i ++)
            {
                NSString *nickName = [[array objectAtIndex:i]objectForKey:@"nickName"];
                NSString *uid = [[array objectAtIndex:i]objectForKey:@"uid"];
                [array4NickName addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:uid groupProperty:groupProperty nickName:nickName]];
            }
            if ([[dict objectForKey:@"groupId"]isEqualToString:[message objectForKey:@"receiver"]])
                return [LLSTR(@"202065") llReplaceWithArray:@[ [array4NickName componentsJoinedByString:@", "]]];
            else
                return [LLSTR(@"202066") llReplaceWithArray:@[ [array4NickName componentsJoinedByString:@"，"], [dict objectForKey:@"groupNickName"]]];
        }
        else
            return @"--";
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_APPLYGROUP)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        //是我本人的消息
        if ([[targetInfo objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid])
        {
            if ([[targetInfo objectForKey:@"source"]isEqualToString:@"CODE"])
                return LLSTR(@"202067");
            else if ([[targetInfo objectForKey:@"source"]isEqualToString:@"LINK"])
                return LLSTR(@"202068");
            else if ([[targetInfo objectForKey:@"source"]isEqualToString:@"WECHAT"])
                return LLSTR(@"202069");
            else if ([[targetInfo objectForKey:@"source"]isEqualToString:@"REFCODE"])
                return [LLSTR(@"202070") llReplaceWithArray:@[
                        [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"refUid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"refNickName"]]]];
            else if ([[targetInfo objectForKey:@"source"]length] > 0)
            {
                JSONDecoder *dec = [JSONDecoder new];
                NSDictionary *sourceInfo = [dec objectWithData:[[targetInfo objectForKey:@"source"]dataUsingEncoding:NSUTF8StringEncoding]];
                if ([[sourceInfo objectForKey:@"source"]length] > 0)
                    return [LLSTR(@"202071") llReplaceWithArray:@[
                            [BiChatGlobal getSourceString:[sourceInfo objectForKey:@"source"]]]];
                else
                    return [LLSTR(@"202072") llReplaceWithArray:@[
                            [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]],
                            [BiChatGlobal getSourceString:[targetInfo objectForKey:@"source"]]]];
            }
            else
                return LLSTR(@"202073");
        }
        else
        {
            if ([[targetInfo objectForKey:@"source"]isEqualToString:@"CODE"])
                return [LLSTR(@"202074") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
            else if ([[targetInfo objectForKey:@"source"]isEqualToString:@"LINK"])
                return [LLSTR(@"202075") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
            else if ([[targetInfo objectForKey:@"source"]isEqualToString:@"WECHAT"])
                return [LLSTR(@"202076") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
            else if ([[targetInfo objectForKey:@"source"]isEqualToString:@"REFCODE"])
                return [LLSTR(@"202077") llReplaceWithArray:@[
                        [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]],
                        [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"refUid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"refNickName"]]]];
            else if ([[targetInfo objectForKey:@"source"]length] > 0)
            {
                JSONDecoder *dec = [JSONDecoder new];
                NSDictionary *sourceInfo = [dec objectWithData:[[targetInfo objectForKey:@"source"]dataUsingEncoding:NSUTF8StringEncoding]];
                if ([[sourceInfo objectForKey:@"source"]length] > 0)
                    return [LLSTR(@"202078") llReplaceWithArray:@[
                            [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]],
                            [BiChatGlobal getSourceString:[sourceInfo objectForKey:@"source"]]]];
                else
                    return [LLSTR(@"202056") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
            }
            else
                return [LLSTR(@"202056") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
        }
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_JOINGROUP)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        if ([[targetInfo objectForKey:@"source"]isEqualToString:@"CODE"])
            return [LLSTR(@"202074") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
        else if ([[targetInfo objectForKey:@"source"]isEqualToString:@"LINK"])
            return [LLSTR(@"202075") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
        else if ([[targetInfo objectForKey:@"source"]isEqualToString:@"WECHAT"])
            return [LLSTR(@"202076") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
        else if ([[targetInfo objectForKey:@"source"]isEqualToString:@"REFCODE"])
            return [LLSTR(@"202077") llReplaceWithArray:@[
                    [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]],
                    [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"refUid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"refNickName"]]]];
        else if ([[targetInfo objectForKey:@"source"]length] > 0)
        {
            JSONDecoder *dec = [JSONDecoder new];
            NSDictionary *sourceInfo = [dec objectWithData:[[targetInfo objectForKey:@"source"]dataUsingEncoding:NSUTF8StringEncoding]];
            if ([[sourceInfo objectForKey:@"source"]length] > 0)
                return [LLSTR(@"202078") llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]],
                        [BiChatGlobal getSourceString:[sourceInfo objectForKey:@"source"]]]];
            else if ([[targetInfo objectForKey:@"source"]isKindOfClass:[NSString class]])
                return [LLSTR(@"202078") llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]],
                                                              [BiChatGlobal getSourceString:[targetInfo objectForKey:@"source"]]]];
            else
                return [LLSTR(@"202079") llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
        }
        else
            return [LLSTR(@"202079") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"]groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_SETADMINCHANGENAMEONLY)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        return [LLSTR(@"202080") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"] groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_CLEARADMINCHANGENAMEONLY)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        return [LLSTR(@"202081") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"] groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_SETADMINADDUSERONLY)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        return [LLSTR(@"202082") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"] groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_CLEARADMINADDUSERONLY)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        return [LLSTR(@"202083") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"] groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_SETADMINPINONLY)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        return [LLSTR(@"202084") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"] groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_CLEARADMINPINONLY)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        return [LLSTR(@"202085") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"] groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_SETADMINADDFRIENDONLY)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        return [LLSTR(@"202132") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"] groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_CLEARADMINADDFRIENDONLY)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        return [LLSTR(@"202133") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"] groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_APPLYADDGROUPMEMBER)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSMutableArray *array4NickNames = [NSMutableArray array];
        for (NSDictionary *item in [targetInfo objectForKey:@"friends"])
        {
            [array4NickNames addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[item objectForKey:@"uid"]groupProperty:groupProperty nickName:[item objectForKey:@"nickName"]]];
        }

        //是我本人发的消息？
        if ([[message objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
            return [LLSTR(@"202088") llReplaceWithArray:@[ [array4NickNames componentsJoinedByString:@", "]]];
        else
        {
            NSString *str4Ret = [LLSTR(@"202089") llReplaceWithArray:@[
                                 [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"]groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]],[NSString stringWithFormat:@"%lu",
                                 (long)[[targetInfo objectForKey:@"friends"]count]]]];
            return str4Ret;
        }
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_APPROVEAPPLYADDGROUPMEMBER)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        if (![targetInfo isKindOfClass:[NSDictionary class]])
            return LLSTR(@"202090");
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < [[targetInfo objectForKey:@"friends"]count]; i ++)
        {
            NSString *nickName = [[[targetInfo objectForKey:@"friends"]objectAtIndex:i]objectForKey:@"nickName"];
            NSString *uid = [[[targetInfo objectForKey:@"friends"]objectAtIndex:i]objectForKey:@"uid"];
            [array addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:uid groupProperty:groupProperty nickName:nickName]];
        }
        NSString *str = [array componentsJoinedByString:@"，"];
        return [LLSTR(@"202091") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]], str]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_REJECTAPPLYADDGROUPMEMBER)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        if (![targetInfo isKindOfClass:[NSDictionary class]])
            return LLSTR(@"202090");
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < [[targetInfo objectForKey:@"friends"]count]; i ++)
        {
            NSString *nickName = [[[targetInfo objectForKey:@"friends"]objectAtIndex:i]objectForKey:@"nickName"];
            NSString *uid = [[[targetInfo objectForKey:@"friends"]objectAtIndex:i]objectForKey:@"uid"];
            [array addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:uid groupProperty:groupProperty nickName:nickName]];
        }
        NSString *str = [array componentsJoinedByString:@"，"];
        return [LLSTR(@"202092") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]], str]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_CANCELADDTOGROUP)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        if (![targetInfo isKindOfClass:[NSDictionary class]])
            return LLSTR(@"202090");
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < [[targetInfo objectForKey:@"friends"]count]; i ++)
        {
            NSString *nickName = [[[targetInfo objectForKey:@"friends"]objectAtIndex:i]objectForKey:@"nickName"];
            NSString *uid = [[[targetInfo objectForKey:@"friends"]objectAtIndex:i]objectForKey:@"uid"];
            [array addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:uid groupProperty:groupProperty nickName:nickName]];
        }
        NSString *str = [array componentsJoinedByString:@"，"];
        return [LLSTR(@"202093") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]], str]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_APPLYADDGROUPNEEDAPPROVE)
    {
        return [LLSTR(@"202094") llReplaceWithArray:@[
                [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    }
//    else if ([[message objectForKey:@"type"]integerValue] == MESSAGE_CONTENT_TYPE_APPLYADDVIRTUALGROUPMEMBER)
//    {
//        JSONDecoder *dec = [JSONDecoder new];
//        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
//        NSMutableArray *array4NickNames = [NSMutableArray array];
//        for (NSDictionary *item in [targetInfo objectForKey:@"friends"])
//            [array4NickNames addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"] groupProperty:groupProperty nickName:[item objectForKey:@"nickName"]]];
//
//        //是我本人发的消息？
//        if ([[message objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
//            return [LLSTR(@"202088") llReplaceWithArray:@[ [array4NickNames componentsJoinedByString:@", "]]];
//        else
//        {
//            NSString *str4Ret = [LLSTR(@"202095") llReplaceWithArray:@[
//                                 [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"]groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]],[NSString stringWithFormat:@"%lu",
//                                 (long)[[targetInfo objectForKey:@"friends"]count]]]];
//            return str4Ret;
//        }
//    }
    else if (messageType == MESSAGE_CONTENT_TYPE_GA_APPLYADDGROUPMEMBEREXPIRE)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSMutableArray *array4NickNames = [NSMutableArray array];
        for (NSDictionary *item in [targetInfo objectForKey:@"friends"])
            [array4NickNames addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"] groupProperty:groupProperty nickName:[item objectForKey:@"nickName"]]];
        
        return [LLSTR(@"202096") llReplaceWithArray:@[ [array4NickNames componentsJoinedByString:@", "]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_CREATEVIRTUALGROUP)
    {
        return [LLSTR(@"202097") llReplaceWithArray:@[
                [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_ADDVIRTUALGROUP)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        return [LLSTR(@"202098") llReplaceWithArray:@[
                [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]],
                [targetInfo objectForKey:@"subGroupNickName"]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_SERVERADDSUBGROUP)
    {
        return LLSTR(@"202099");
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_UPGRADETOBIGGROUP)
    {
        return [LLSTR(@"202100") llReplaceWithArray:@[
                [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_SERVERNOTIFY_NEWMESSAGECOUNT)
        return @"超大群消息发生变化";    //本字符串用于日志，不需要支持多语言变化
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUPMUTE_ON)
    {
        return [LLSTR(@"202102") llReplaceWithArray:@[
                [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUPMUTE_OFF)
    {
        return [LLSTR(@"202103") llReplaceWithArray:@[
                [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUPFORBIDTEXTWITHLINK_ON)
    {
        return [LLSTR(@"202104") llReplaceWithArray:@[
                [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUPFORBIDTEXTWITHLINK_OFF)
    {
        return [LLSTR(@"202105") llReplaceWithArray:@[
                [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUPFORBIDIMAGEWITHVRCODE_ON)
    {
        return [LLSTR(@"202106") llReplaceWithArray:@[
                [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUPFORBIDIMAGEWITHVRCODE_OFF)
    {
        return [LLSTR(@"202107") llReplaceWithArray:@[
                [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUPFORBIDREDPACKETFROMOTHERGROUP_ON)
    {
        return [LLSTR(@"202108") llReplaceWithArray:@[
                [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUPFORBIDREDPACKETFROMOTHERGROUP_OFF)
    {
        return [LLSTR(@"202109") llReplaceWithArray:@[
                [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUPBROADCASE_ON)
    {
        return [LLSTR(@"202110") llReplaceWithArray:@[
                [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUPBROADCASE_OFF)
    {
        return [LLSTR(@"202111") llReplaceWithArray:@[
                [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUPEXCHANGE_ON)
    {
        return [LLSTR(@"202112") llReplaceWithArray:@[
                [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUPEXCHANGE_OFF)
    {
        return [LLSTR(@"202113") llReplaceWithArray:@[
                [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUPAUTOSWITCH_FORBID)
        return LLSTR(@"202114");
    else if (messageType == MESSAGE_CONTENT_TYPE_BACKTOGROUP_AD)
        return LLSTR(@"202131");
    else if (messageType == MESSAGE_CONTENT_TYPE_UPGRADE2CHARGEGROUP)
        return [LLSTR(@"204201") llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    else if (messageType == MESSAGE_CONTENT_TYPE_MODIFYCHARGEGROUP)
        return [LLSTR(@"204202") llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    else if (messageType == MESSAGE_CONTENT_TYPE_NOTIFYCHARGEGROUPEXPIRE)
        return LLSTR(@"204204");
    else if (messageType == MESSAGE_CONTENT_TYPE_BANNED4TRAIL)
        return LLSTR(@"204301");
    else if (messageType == MESSAGE_CONTENT_TYPE_BANNED4MUTE)
        return LLSTR(@"201605");
    else if (messageType == MESSAGE_CONTENT_TYPE_BANNED4MUTELIST)
        return LLSTR(@"201606");
    else if (messageType == MESSAGE_CONTENT_TYPE_BANNED4LINKTEXT)
        return LLSTR(@"201407");
    else if (messageType == MESSAGE_CONTENT_TYPE_BANNED4VRCODE)
        return LLSTR(@"201408");
    else if (messageType == MESSAGE_CONTENT_TYPE_BANNED4PAY)
        return LLSTR(@"204311");
    else if (messageType == MESSAGE_CONTENT_TYPE_BANNED4APPROVE)
        return LLSTR(@"204341");
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUPADDMUTEUSERS)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSMutableArray *array4NickNames = [NSMutableArray array];
        for (NSDictionary *item in [targetInfo objectForKey:@"friends"])
            [array4NickNames addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[item objectForKey:@"uid"] groupProperty:groupProperty nickName:[item objectForKey:@"nickName"]]];

        return [LLSTR(@"202115") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]], [array4NickNames componentsJoinedByString:@", "]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUPDELMUTEUSERS)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        NSMutableArray *array4NickNames = [NSMutableArray array];
        for (NSDictionary *item in [targetInfo objectForKey:@"friends"])
            [array4NickNames addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[item objectForKey:@"uid"] groupProperty:groupProperty nickName:[item objectForKey:@"nickName"]]];
        
        return [LLSTR(@"202116") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]], [array4NickNames componentsJoinedByString:@", "]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUPMOVEMEMBERIN)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSArray *friends = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];

        //本人是否在被移动者之间
        BOOL iWasMoved = NO;
        for (NSDictionary *item in friends)
        {
            if ([item isKindOfClass:[NSDictionary class]] &&
                [[item objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid])
            {
                iWasMoved = YES;
                break;
            }
        }
        
        if (iWasMoved)
        {
            //被移动者超过1个
            if ([friends count] > 1)
            {
                return [LLSTR(@"202117") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]],[NSString stringWithFormat:@"%ld",(long)[friends count] - 1]]];
            }
            else
            {
                return [LLSTR(@"202118") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
            }
        }
        else
        {
            NSMutableArray *array4NickNames = [NSMutableArray array];
            for (NSDictionary *item in friends)
            {
                if (![item isKindOfClass:[NSDictionary class]])
                    return @"--";
                [array4NickNames addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[item objectForKey:@"uid"] groupProperty:groupProperty nickName:[item objectForKey:@"nickName"]]];
                if (array4NickNames.count >= 3)
                    break;
            }

            //被移动者超过3个
            if ([friends count] > 3)
            {
                return [LLSTR(@"202119") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]], [array4NickNames componentsJoinedByString:@", "],[NSString stringWithFormat:@"%ld",(long)[friends count]]]];
            }
            else
            {
                return [LLSTR(@"202120") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]], [array4NickNames componentsJoinedByString:@", "]]];            }
        }
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUPMOVEMEMBEROUT)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSArray *friends = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        
        //本人是否在被移动者之间
        BOOL iWasMoved = NO;
        for (NSDictionary *item in friends)
        {
            if (![item isKindOfClass:[NSDictionary class]])
                return @"--";
            if ([[item objectForKey:@"uid"]isEqualToString:[BiChatGlobal sharedManager].uid])
            {
                iWasMoved = YES;
                break;
            }
        }
        
        if (iWasMoved)
        {
            //被移动者超过1个
            if ([friends count] > 1)
            {
                return [LLSTR(@"202121") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]],[NSString stringWithFormat:@"%ld",(long)[friends count] - 1]]];
            }
            else
            {
                return [LLSTR(@"202122") llReplaceWithArray:@[ [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
            }
        }
        else
        {
            NSMutableArray *array4NickNames = [NSMutableArray array];
            for (NSDictionary *item in friends)
            {
                [array4NickNames addObject:[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[item objectForKey:@"uid"] groupProperty:groupProperty nickName:[item objectForKey:@"nickName"]]];
                if (array4NickNames.count >= 3)
                    break;
            }
            
            //被移动者超过3个
            if ([friends count] > 3)
            {
                return [LLSTR(@"202123") llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]], [array4NickNames componentsJoinedByString:@", "], [NSString stringWithFormat:@"%ld",(long)[friends count] - 3]]];
            }
            else
            {
                return [LLSTR(@"202124") llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]], [array4NickNames componentsJoinedByString:@", "]]];            }
        }
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_FILE)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        return [LLSTR(@"101192") llReplaceWithArray:@[ [targetInfo objectForKey:@"fileName"]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_DELETEFILE)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        return [LLSTR(@"202125") llReplaceWithArray:@[ [targetInfo objectForKey:@"fileName"]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_NEWS_PUBLIC)
        return LLSTR(@"101194");
    else if (messageType == MESSAGE_CONTENT_TYPE_MESSAGE_PUBLIC)
    {
        if ([[message objectForKey:@"content"]length] == 0)
            return LLSTR(@"101196");
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        if ([[targetInfo objectForKey:@"title"]length] == 0)
            return LLSTR(@"101196");
        else
            return [targetInfo objectForKey:@"title"];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_GROUPHOME)
    {
        if ([[message objectForKey:@"content"]length] == 0)
            return LLSTR(@"201022");
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        if ([[targetInfo objectForKey:@"title"]length] == 0)
            return LLSTR(@"201022");
        else
            return [LLSTR(@"101198") llReplaceWithArray:@[ [targetInfo objectForKey:@"title"]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_IMCHATBUSINESS_AD)
        return LLSTR(@"203107");
    else if (messageType == MESSAGE_CONTENT_TYPE_SERVERNOTIFY_MOMENT)
        return @"圈子消息";           //多语言忽略本字符串
    else if (messageType == MESSAGE_CONTENT_TYPE_SERVERNOTIFY_HIGHLIGHTGROUPHOME)
        return @"群主页点亮消息";      //多语言忽略本字符串
    else if (messageType == MESSAGE_CONTENT_TYPE_SERVERNOTIFY_FRESHGROUPHOME)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        return [NSString stringWithFormat:@"%@", [targetInfo objectForKey:@"title"]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_SERVERNOTIFY_NOTICEGROUPHOME)
        return @"群主页通知消息";      //多语言忽略本字符串
    else if (messageType == MESSAGE_CONTENT_TYPE_CHARGEGROUPPAY)
    {
        return [LLSTR(@"204206")llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_CHARGEGROUPFREE)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        return [LLSTR(@"204207")llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"] groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]],
                                                     [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]],
                                                     [BiChatGlobal adjustDateString:[BiChatGlobal getDateString:[NSDate dateWithTimeIntervalSince1970:[[targetInfo objectForKey:@"expireTime"]longLongValue]/1000]]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_CHARGEGROUPMEMBER)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        return [LLSTR(@"204208")llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"] groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]],
                                                     [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]],
                                                     [BiChatGlobal adjustDateString:[BiChatGlobal getDateString:[NSDate dateWithTimeIntervalSince1970:[[targetInfo objectForKey:@"expireTime"]longLongValue]/1000]]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_ROLEAUTHORIZE)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        return [LLSTR(@"202134")llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"] groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]], [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_CANCELROLEAUTHORIZE)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        return [LLSTR(@"202136")llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]], [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"] groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
    }
    else if (messageType == MESSAGE_CONTENT_TYPE_QUITROLEAUTHOZIZE)
    {
        JSONDecoder *dec = [JSONDecoder new];
        NSDictionary *targetInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
        return [LLSTR(@"202135")llReplaceWithArray:@[[[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]], [[BiChatGlobal sharedManager]adjustFriendNickName4Display2:[targetInfo objectForKey:@"uid"] groupProperty:groupProperty nickName:[targetInfo objectForKey:@"nickName"]]]];
    }
    
    return [LLSTR(@"203111") llReplaceWithArray:@[[NSString stringWithFormat:@"%@",[message objectForKey:@"type"]]]];
}

//获取一条消息发送的时间
+ (NSDate *)getMessageTime:(NSDictionary *)message
{
    return [BiChatGlobal parseDateString:[message objectForKey:@"timeStamp"]];
}

//转化用户来源的字符串
+ (NSString *)getFriendSourceReadableString:(NSString *)source
{
    if ([source isEqualToString:@"CONTACT"])
        return LLSTR(@"106119");
    if ([source isEqualToString:@"PHONE"])
        return LLSTR(@"106103");
    else if ([source isEqualToString:@"CODE"])
        return LLSTR(@"106105");
    else if ([source isEqualToString:@"GROUP"])
        return LLSTR(@"106104");
    else if ([source isEqualToString:@"USER_NAME"])
        return LLSTR(@"106120");
    else if ([source isEqualToString:@"CARD"])
        return LLSTR(@"106106");
    else if ([source hasPrefix:@"GROUP_"])
//        return [source stringByReplacingOccurrencesOfString:@"GROUP_" withString:@"群："];
        return @"";
    else if ([source isEqualToString:@"REFCODE"])
        return LLSTR(@"106121");
    else if ([source isEqualToString:@"URL"])
        return LLSTR(@"201077");
    else if ([source isEqualToString:@"URL_LINK"])
        return LLSTR(@"201078");
    return @"";
}

//判断一条消息是否系统消息
+ (BOOL)isSystemMessage:(NSDictionary *)message
{
    NSInteger type = [[message objectForKey:@"type"]integerValue];
    if (type == MESSAGE_CONTENT_TYPE_TIME ||
        type == MESSAGE_CONTENT_TYPE_QUITGROUP ||
        type == MESSAGE_CONTENT_TYPE_ADDTOGROUP ||
        type == MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL ||
        type == MESSAGE_CONTENT_TYPE_CHANGEGROUPNAME ||
        type == MESSAGE_CONTENT_TYPE_CHANGENICKNAME ||
        type == MESSAGE_CONTENT_TYPE_CHANGESUBGROUPNICKNAME ||
        type == MESSAGE_CONTENT_TYPE_CHANGESUBGROUPNICKNAME2 ||
        type == MESSAGE_CONTENT_TYPE_KICKOUTGROUP ||
        type == MESSAGE_CONTENT_TYPE_SYSTEM ||
        type == MESSAGE_CONTENT_TYPE_RECALL ||
        type == MESSAGE_CONTENT_TYPE_GROUPBLOCK ||
        type == MESSAGE_CONTENT_TYPE_GROUPUNBLOCK ||
        type == MESSAGE_CONTENT_TYPE_CHANGEGROUPOWNER ||
        type == MESSAGE_CONTENT_TYPE_ADDASSISTANT ||
        type == MESSAGE_CONTENT_TYPE_DELASSISTANT ||
        type == MESSAGE_CONTENT_TYPE_GROUPBOARDITEM ||
        type == MESSAGE_CONTENT_TYPE_BIDIRECTIONAL_FRIEND ||
        type == MESSAGE_CONTENT_TYPE_PEER_MAKEFRIEND ||
        type == MESSAGE_CONTENT_TYPE_MAKEFRIEND ||
        type == MESSAGE_CONTENT_TYPE_BLOCK ||
        type == MESSAGE_CONTENT_TYPE_UNBLOCK ||
        type == MESSAGE_CONTENT_TYPE_GROUP_AD ||
        type == MESSAGE_CONTENT_TYPE_REDPACKET_RECEIVE ||
        type == MESSAGE_CONTENT_TYPE_REDPACKET_EXHAUST ||
        type == MESSAGE_CONTENT_TYPE_REDPAKCET_JOINGROUP ||
        type == MESSAGE_CONTENT_TYPE_MYINVITEDGROUP_CREATED ||
        type == MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECEIVE ||
        type == MESSAGE_CONTENT_TYPE_TRANSFERMONEY_RECALL ||
        type == MESSAGE_CONTENT_TYPE_TRANSFERMONEY_EXPIRE ||
        type == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECEIVE ||
        type == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECALL ||
        type == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_EXPIRE ||
        type == MESSAGE_CONTENT_TYPE_ASSIGNTOGROUP ||
        type == MESSAGE_CONTENT_TYPE_JOINGROUP ||
        type == MESSAGE_CONTENT_TYPE_SETADMINCHANGENAMEONLY ||
        type == MESSAGE_CONTENT_TYPE_CLEARADMINCHANGENAMEONLY ||
        type == MESSAGE_CONTENT_TYPE_SETADMINADDUSERONLY ||
        type == MESSAGE_CONTENT_TYPE_CLEARADMINADDUSERONLY ||
        type == MESSAGE_CONTENT_TYPE_SETADMINPINONLY ||
        type == MESSAGE_CONTENT_TYPE_CLEARADMINPINONLY ||
        type == MESSAGE_CONTENT_TYPE_SETADMINADDFRIENDONLY ||
        type == MESSAGE_CONTENT_TYPE_CLEARADMINADDFRIENDONLY ||
        type == MESSAGE_CONTENT_TYPE_APPLYADDGROUPMEMBER ||
        type == MESSAGE_CONTENT_TYPE_CHANGEGROUPINFO ||
        type == MESSAGE_CONTENT_TYPE_APPROVEAPPLYADDGROUPMEMBER ||
        type == MESSAGE_CONTENT_TYPE_REJECTAPPLYADDGROUPMEMBER ||
        type == MESSAGE_CONTENT_TYPE_APPLYADDGROUPNEEDAPPROVE ||
        type == MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL ||
        type == MESSAGE_CONTENT_TYPE_CREATEVIRTUALGROUP ||
        type == MESSAGE_CONTENT_TYPE_ADDVIRTUALGROUP ||
        type == MESSAGE_CONTENT_TYPE_GA_APPLYADDGROUPMEMBEREXPIRE ||
        type == MESSAGE_CONTENT_TYPE_GN_CREATESUBGROUP ||
        type == MESSAGE_CONTENT_TYPE_SERVERADDSUBGROUP ||
        type == MESSAGE_CONTENT_TYPE_UPGRADETOBIGGROUP ||
        type == MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL_FULL ||
        type == MESSAGE_CONTENT_TYPE_AGREEAPPLYFAIL_FULL ||
        type == MESSAGE_CONTENT_TYPE_GROUPAUTOSWITCH_MUTE ||
        type == MESSAGE_CONTENT_TYPE_UPGRADETOBIGGROUP ||
        type == MESSAGE_CONTENT_TYPE_GROUPMUTE_ON ||
        type == MESSAGE_CONTENT_TYPE_GROUPMUTE_OFF ||
        type == MESSAGE_CONTENT_TYPE_GROUPFORBIDTEXTWITHLINK_ON ||
        type == MESSAGE_CONTENT_TYPE_GROUPFORBIDTEXTWITHLINK_OFF ||
        type == MESSAGE_CONTENT_TYPE_GROUPFORBIDIMAGEWITHVRCODE_ON ||
        type == MESSAGE_CONTENT_TYPE_GROUPFORBIDIMAGEWITHVRCODE_OFF ||
        type == MESSAGE_CONTENT_TYPE_GROUPFORBIDREDPACKETFROMOTHERGROUP_ON ||
        type == MESSAGE_CONTENT_TYPE_GROUPFORBIDREDPACKETFROMOTHERGROUP_OFF ||
        type == MESSAGE_CONTENT_TYPE_GROUPADDMUTEUSERS ||
        type == MESSAGE_CONTENT_TYPE_GROUPDELMUTEUSERS ||
        type == MESSAGE_CONTENT_TYPE_GROUPDISMISS ||
        type == MESSAGE_CONTENT_TYPE_GROUPRESTART ||
        type == MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL_BLOCKED ||
        type == MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL_FULL ||
        type == MESSAGE_CONTENT_TYPE_ADDTOGROUPFAIL_NOTINPENDINGLIST ||
        type == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECEIVE ||
        type == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_EXPIRE ||
        type == MESSAGE_CONTENT_TYPE_EXCHANGEMONEY_RECALL ||
        type == MESSAGE_CONTENT_TYPE_IMCHATBUSINESS_AD ||
        type == MESSAGE_CONTENT_TYPE_GROUPMOVEMEMBEROUT ||
        type == MESSAGE_CONTENT_TYPE_GROUPMOVEMEMBERIN ||
        type == MESSAGE_CONTENT_TYPE_GROUPBROADCASE_ON ||
        type == MESSAGE_CONTENT_TYPE_GROUPBROADCASE_OFF ||
        type == MESSAGE_CONTENT_TYPE_GROUPAUTOSWITCH_FORBID ||
        type == MESSAGE_CONTENT_TYPE_BACKTOGROUP_AD ||
        type == MESSAGE_CONTENT_TYPE_SERVERNOTIFY_FRESHGROUPHOME ||
        type == MESSAGE_CONTENT_TYPE_UPGRADE2CHARGEGROUP ||
        type == MESSAGE_CONTENT_TYPE_MODIFYCHARGEGROUP ||
        type == MESSAGE_CONTENT_TYPE_CHARGEGROUPPAY ||
        type == MESSAGE_CONTENT_TYPE_CHARGEGROUPFREE ||
        type == MESSAGE_CONTENT_TYPE_CHARGEGROUPMEMBER ||
        type == MESSAGE_CONTENT_TYPE_ADDTOGROUPTRAIL ||
        type == MESSAGE_CONTENT_TYPE_ALREDYINGROUPWAITINGPAY ||
        type == MESSAGE_CONTENT_TYPE_JOINGROUPTRAIL ||
        type == MESSAGE_CONTENT_TYPE_JOINGROUPWAITINGPAY ||
        type == MESSAGE_CONTENT_TYPE_ROLEAUTHORIZE ||
        type == MESSAGE_CONTENT_TYPE_CANCELROLEAUTHORIZE ||
        type == MESSAGE_CONTENT_TYPE_QUITROLEAUTHOZIZE ||
        type == MESSAGE_CONTENT_TYPE_AGREEADDTOGROUPTRAIL ||
        type == MESSAGE_CONTENT_TYPE_AGREEADDTOGROUPALREADYINWAITINGPAY ||
        type == MESSAGE_CONTENT_TYPE_AGREEJOINGROUPTRAIL ||
        type == MESSAGE_CONTENT_TYPE_AGREEJOINGROUPALREADYINWAITINGPAY ||
        type == MESSAGE_CONTENT_TYPE_APPROVEADDGROUP ||
        type == MESSAGE_CONTENT_TYPE_APPROVEJOINGROUP)
        return YES;
    else
        return NO;
}

//判断一个电话号码是否有效（区号 手机号码）
+ (BOOL)isMobileNumberLegel:(NSString *)mobile
{
    NSArray *array = [mobile componentsSeparatedByString:@" "];
    if (array.count != 2)
        return NO;
    
    return [BiChatGlobal isMobileNumberLegel:[array firstObject] mobile:[array lastObject]];
}

+ (BOOL)isMobileNumberLegel:(NSString *)areaCode mobile:(NSString *)mobileNumber
{
    if ([areaCode isEqualToString:@"+86"])
    {
        if (mobileNumber.length != 11)
            return NO;
        NSArray *array4MobileDefine = [NSArray arrayWithObjects:
                                       @"13", @"14", @"15", @"16", @"17", @"18", @"19", nil];
        
        if (mobileNumber.length > 2)
            mobileNumber = [mobileNumber substringToIndex:2];
        for (NSString *item in array4MobileDefine)
        {
            if ([item hasPrefix:mobileNumber])
                return YES;
        }
        return NO;
    }
    else if ([areaCode isEqualToString:@"+852"])
    {
        if (mobileNumber.length != 8)
            return NO;
        NSArray *array4MobileDefine = [NSArray arrayWithObjects:@"4", @"5", @"6", @"7", @"8", @"9",  nil];
        
        if (mobileNumber.length > 1)
            mobileNumber = [mobileNumber substringToIndex:1];
        for (NSString *item in array4MobileDefine)
        {
            if ([item hasPrefix:mobileNumber])
                return YES;
        }
        return NO;
    }
    else if ([areaCode isEqualToString:@"+853"])
    {
        if (mobileNumber.length != 8)
            return NO;
        NSArray *array4MobileDefine = [NSArray arrayWithObjects:@"62", @"63", @"64", @"66", @"68", nil];
        
        if (mobileNumber.length > 1)
            mobileNumber = [mobileNumber substringToIndex:1];
        for (NSString *item in array4MobileDefine)
        {
            if ([item hasPrefix:mobileNumber])
                return YES;
        }
        return NO;
    }
    else if ([areaCode isEqualToString:@"+886"])
    {
        if (mobileNumber.length != 9)
            return NO;
        NSArray *array4MobileDefine = [NSArray arrayWithObjects:@"9", nil];
        
        if (mobileNumber.length > 1)
            mobileNumber = [mobileNumber substringToIndex:1];
        for (NSString *item in array4MobileDefine)
        {
            if ([item hasPrefix:mobileNumber])
                return YES;
        }
        return NO;
    }
    else if ([areaCode isEqualToString:@"+65"])
    {
        if (mobileNumber.length != 8)
            return NO;
        NSArray *array4MobileDefine = [NSArray arrayWithObjects:@"8", @"9", nil];
        
        if (mobileNumber.length > 1)
            mobileNumber = [mobileNumber substringToIndex:1];
        for (NSString *item in array4MobileDefine)
        {
            if ([item hasPrefix:mobileNumber])
                return YES;
        }
        return NO;
    }
    else if ([areaCode isEqualToString:@"+81"])
    {
        if (mobileNumber.length != 10)
            return NO;
        NSArray *array4MobileDefine = [NSArray arrayWithObjects: @"7", @"8", @"9", nil];
        
        if (mobileNumber.length > 1)
            mobileNumber = [mobileNumber substringToIndex:1];
        for (NSString *item in array4MobileDefine)
        {
            if ([item hasPrefix:mobileNumber])
                return YES;
        }
        return NO;
    }
    else if ([areaCode isEqualToString:@"+82"])
    {
        if (mobileNumber.length != 10)
            return NO;
        NSArray *array4MobileDefine = [NSArray arrayWithObjects:@"1", nil];
        
        if (mobileNumber.length > 1)
            mobileNumber = [mobileNumber substringToIndex:1];
        for (NSString *item in array4MobileDefine)
        {
            if ([item hasPrefix:mobileNumber])
                return YES;
        }
        return NO;
    }
    else if ([areaCode isEqualToString:@"+1"])
    {
        if (mobileNumber.length != 10)
            return NO;
    }
    else if ([areaCode isEqualToString:@"+61"])
    {
        if (mobileNumber.length != 9)
            return NO;
    }
    else if ([areaCode isEqualToString:@"64"])
    {
        if (mobileNumber.length < 8 ||
            mobileNumber.length > 10)
            return NO;
        NSArray *array4MobileDefine = [NSArray arrayWithObjects:@"2", nil];
        
        if (mobileNumber.length > 1)
            mobileNumber = [mobileNumber substringToIndex:1];
        for (NSString *item in array4MobileDefine)
        {
            if ([item hasPrefix:mobileNumber])
                return YES;
        }
        return NO;
    }
    
    return YES;
}

//设置一个红包是否已经被领取，或者已经被领光
- (void)setRedPacketFinished:(NSString *)redPacketId status:(NSInteger)status;
{
    [[BiChatDataModule sharedDataModule]setRedPacketFinished:redPacketId status:status];

    /*
    if (redPacketId == nil)
        return;
        
    //准备路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *redPacketInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"redpacket_%@.dat", self.uid]];

    //是否需要加载数据
    if (self.dict4FinishedReadPacket == nil)
    {
        //加载数据
        self.dict4FinishedReadPacket = [[NSMutableDictionary alloc]initWithContentsOfFile:redPacketInfoFile];
        if (self.dict4FinishedReadPacket == nil)
            self.dict4FinishedReadPacket = [NSMutableDictionary dictionary];
    }
    [self.dict4FinishedReadPacket setObject:[NSNumber numberWithInteger:status] forKey:redPacketId];
    
    //如果数据太多，去掉一部分
    if (self.dict4FinishedReadPacket.count > 3000)
    {
        NSInteger count = 0;
        for (NSString *key in self.dict4FinishedReadPacket)
        {
            [self.dict4FinishedReadPacket removeObjectForKey:key];
            count ++;
            if (count >= 500)
                break;
        }
    }
    
    //重新保存数据
    [self.dict4FinishedReadPacket writeToFile:redPacketInfoFile atomically:YES];
     */
}

//返回一个红包的状态
- (NSInteger)isRedPacketFinished:(NSString *)redPacketId
{
    return [[BiChatDataModule sharedDataModule]isRedPacketFinished:redPacketId];
    
    /*
    if (redPacketId == nil)
        return 0;
    
    //准备路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *redPacketInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"redpacket_%@.dat", self.uid]];
    
    //是否需要加载数据
    if (self.dict4FinishedReadPacket == nil)
    {
        //加载数据
        self.dict4FinishedReadPacket = [[NSMutableDictionary alloc]initWithContentsOfFile:redPacketInfoFile];
        if (self.dict4FinishedReadPacket == nil)
            self.dict4FinishedReadPacket = [NSMutableDictionary dictionary];
    }

    return [[self.dict4FinishedReadPacket objectForKey:redPacketId]integerValue];
     */
}

//设置一笔转账是否已经完成
- (void)setTransferMoneyFinished:(NSString *)transactionId status:(NSInteger)status
{
    [[BiChatDataModule sharedDataModule]setTransferMoneyFinished:transactionId status:status];
    
    /*
    if (transactionId == nil)
        return;
    
    //准备路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *transferMoneyInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"transfermoney_%@.dat", self.uid]];
    
    //是否需要加载数据
    if (self.dict4FinishedTransferMoney == nil)
    {
        //加载数据
        self.dict4FinishedTransferMoney = [[NSMutableDictionary alloc]initWithContentsOfFile:transferMoneyInfoFile];
        if (self.dict4FinishedTransferMoney == nil)
            self.dict4FinishedTransferMoney = [NSMutableDictionary dictionary];
    }
    [self.dict4FinishedTransferMoney setObject:[NSNumber numberWithInteger:status] forKey:transactionId];
    
    //重新保存数据
    [self.dict4FinishedTransferMoney writeToFile:transferMoneyInfoFile atomically:YES];
     */
}

//返回一笔转账是否已经完成
- (NSInteger)isTransferMoneyFinished:(NSString *)transactionId
{
    return [[BiChatDataModule sharedDataModule]isTransferMoneyFinished:transactionId];
    
    /*
    if (transactionId == nil)
        return 0;
    
    //准备路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *transferMoneyInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"transfermoney_%@.dat", self.uid]];
    
    //是否需要加载数据
    if (self.dict4FinishedTransferMoney == nil)
    {
        //加载数据
        self.dict4FinishedTransferMoney = [[NSMutableDictionary alloc]initWithContentsOfFile:transferMoneyInfoFile];
        if (self.dict4FinishedTransferMoney == nil)
            self.dict4FinishedTransferMoney = [NSMutableDictionary dictionary];
    }

    return [[self.dict4FinishedTransferMoney objectForKey:transactionId]integerValue];
     */
}

//设置一笔交换是否已经完成
- (void)setExchangeMoneyFinished:(NSString *)transactionId status:(NSInteger)status
{
    [[BiChatDataModule sharedDataModule]setExchangeMoneyFinished:transactionId status:status];
    
    /*
    if (transactionId == nil)
        return;
    
    //准备路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *exchangeMoneyInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"exchangemoney_%@.dat", self.uid]];
    
    //是否需要加载数据
    if (self.dict4FinishedExchangeMoney == nil)
    {
        //加载数据
        self.dict4FinishedExchangeMoney = [[NSMutableDictionary alloc]initWithContentsOfFile:exchangeMoneyInfoFile];
        if (self.dict4FinishedExchangeMoney == nil)
            self.dict4FinishedExchangeMoney = [NSMutableDictionary dictionary];
    }
    [self.dict4FinishedExchangeMoney setObject:[NSNumber numberWithInteger:status] forKey:transactionId];
    
    //重新保存数据
    NSLog(@"write 10");
    [self.dict4FinishedExchangeMoney writeToFile:exchangeMoneyInfoFile atomically:YES];
    NSLog(@"write 10 end");
     */
}

//返回一笔转账是否已经完成
- (NSInteger)isExchangeMoneyFinished:(NSString *)transactionId
{
    return [[BiChatDataModule sharedDataModule]isExchangeMoneyFinished:transactionId];
    
    /*
    if (transactionId == nil)
        return 0;
    
    //准备路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *exchangeMoneyInfoFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"exchangemoney_%@.dat", self.uid]];
    
    //是否需要加载数据
    if (self.dict4FinishedExchangeMoney == nil)
    {
        //加载数据
        self.dict4FinishedExchangeMoney = [[NSMutableDictionary alloc]initWithContentsOfFile:exchangeMoneyInfoFile];
        if (self.dict4FinishedExchangeMoney == nil)
            self.dict4FinishedExchangeMoney = [NSMutableDictionary dictionary];
    }
    
    return [[self.dict4FinishedExchangeMoney objectForKey:transactionId]integerValue];
     */
}

- (NSString *)getCoinDSymbolBySymbol:(NSString *)symbol
{
    if (symbol.length == 0)
        return @"";
    
    for (NSDictionary *item in [[BiChatGlobal sharedManager].dict4WalletInfo objectForKey:@"bitcoinDetail"])
    {
        if ([[item objectForKey:@"symbol"]isEqualToString:symbol])
            return [item objectForKey:@"dSymbol"];
    }
    return symbol;
}

- (NSDictionary *)getCoinInfoBySymbol:(NSString *)symbol
{
    if (symbol.length == 0)
        return @{};
    
    for (NSDictionary *item in [[BiChatGlobal sharedManager].dict4WalletInfo objectForKey:@"bitcoinDetail"])
    {
        if ([[item objectForKey:@"symbol"]isEqualToString:symbol])
            return item;
    }
    return @{};
}

// 直接传入精度丢失有问题的Double类型
+ (NSString *)decimalNumberWithDouble:(double) conversionValue
{
    NSString *doubleString        = [NSString stringWithFormat:@"%.10lf", conversionValue];
    NSDecimalNumber *decNumber    = [NSDecimalNumber decimalNumberWithString:doubleString];
    return [decNumber stringValue];
}

//转换文件长度
+ (NSString *)transFileLength:(long long)fileLength
{
    if (fileLength > 1024 * 1024)
        return [NSString stringWithFormat:@"%.1fM", (float)fileLength / 1024 / 1024];
    else if (fileLength > 1024)
        return [NSString stringWithFormat:@"%.1fK", (float)fileLength / 1024];
    else
        return [NSString stringWithFormat:@"%d bytes", (int)fileLength];
}
//显示分享窗口
+ (WPShareView *)showShareWindowWithTitle:(NSString *)title avatar:(NSString *)avatar content:(NSString *)content type:(NSInteger)type {
    WPShareView *shareV = [[WPShareView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    [[UIApplication sharedApplication].keyWindow addSubview:shareV];
    shareV.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    shareV.title = title;
    shareV.avatar = avatar;
    shareV.content = content;
    shareV.tag = SHARE_VIEW;
    return shareV;
}
//关闭分享窗口
+ (void)closeShareWindow {
    UIView *view = [[UIApplication sharedApplication].keyWindow viewWithTag:SHARE_VIEW];
    [view removeFromSuperview];
    view = nil;
}
//添加分隔符
+ (NSString *)getFormatterStringWithValue:(NSString *)value {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.minimumFractionDigits = 0;
    formatter.maximumFractionDigits = 2;
    formatter.usesGroupingSeparator = YES;
    formatter.groupingSize = 3;
    formatter.groupingSeparator = @",";
    
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:value];
    return [formatter stringFromNumber:number];
}

//显示我的badge
- (void)showMyBadge:(BOOL)bShow
{
    if (!bShow)
        [BiChatGlobal sharedManager].view4MyBadge.hidden = YES;
    else
    {
        //判断是否有新版本
        NSString *str4Version = [BiChatGlobal getAppVersion];
        if ([[BiChatGlobal sharedManager].lastestVersion compare:str4Version options:NSNumericSearch] == NSOrderedDescending)
            [BiChatGlobal sharedManager].view4MyBadge.hidden = NO;
        else
            [BiChatGlobal sharedManager].view4MyBadge.hidden = YES;
    }
}

//系统配置消息处理
- (void)processSystemConfigMessage:(NSDictionary *)item
{
    NSLog(@"system config - %@", item);
    if ([item objectForKey:@"S3URL"] != nil) [BiChatGlobal sharedManager].S3URL = [item objectForKey:@"S3URL"];
    if ([item objectForKey:@"S3Bucket"] != nil) [BiChatGlobal sharedManager].S3Bucket = [item objectForKey:@"S3Bucket"];
    if ([item objectForKey:@"staticURL"] != nil) [BiChatGlobal sharedManager].StaticUrl = [item objectForKey:@"staticURL"];
    if ([item objectForKey:@"imchatfile"] != nil) [BiChatGlobal sharedManager].filePubUid = [item objectForKey:@"imchatfile"];
    if ([item objectForKey:@"authWxURL"] != nil) [BiChatGlobal sharedManager].authWxUrl = [item objectForKey:@"authWxURL"];
    if ([item objectForKey:@"apiURL"] != nil) [BiChatGlobal sharedManager].apiUrl = [item objectForKey:@"apiURL"];
    if ([item objectForKey:@"inviteMessage"] != nil) [BiChatGlobal sharedManager].inviteMessage = [item objectForKey:@"inviteMessage"];
    if ([item objectForKey:@"inviteeMaxNumDefault"] != nil) [BiChatGlobal sharedManager].defaultInviteeMaxNum = [[item objectForKey:@"inviteeMaxNumDefault"]integerValue];
    if ([item objectForKey:@"rpSquareMaxDisabled"] != nil) {
        [BiChatGlobal sharedManager].rpSquareMaxDisabled = [item objectForKey:@"rpSquareMaxDisabled"];
    }
    if ([item objectForKey:@"login"] != nil)
    {
        if ([[item objectForKey:@"login"]integerValue] == 1)
            [BiChatGlobal sharedManager].loginOrder = @"wm";
        else
            [BiChatGlobal sharedManager].loginOrder = @"mw";
    }
    
    if ([item objectForKey:@"ios"] != nil) [BiChatGlobal sharedManager].allowedVersion = [[item objectForKey:@"ios"]objectForKey:@"allowedVersion"];
    if ([item objectForKey:@"ios"] != nil) [BiChatGlobal sharedManager].lastestVersion = [[item objectForKey:@"ios"]objectForKey:@"latestVersion"];
#ifdef ENV_CN
    if ([item objectForKey:@"ioscn"] != nil) [BiChatGlobal sharedManager].allowedVersion = [[item objectForKey:@"ioscn"]objectForKey:@"allowedVersion"];
    if ([item objectForKey:@"ioscn"] != nil) [BiChatGlobal sharedManager].lastestVersion = [[item objectForKey:@"ioscn"]objectForKey:@"latestVersion"];
#endif
#ifdef ENV_ENT
    if ([item objectForKey:@"iosent"] != nil) [BiChatGlobal sharedManager].allowedVersion = [[item objectForKey:@"iosent"]objectForKey:@"allowedVersion"];
    if ([item objectForKey:@"iosent"] != nil) [BiChatGlobal sharedManager].lastestVersion = [[item objectForKey:@"iosent"]objectForKey:@"latestVersion"];
#endif
    if ([item objectForKey:@"feedback"] != nil) [BiChatGlobal sharedManager].feedback = [item objectForKey:@"feedback"];
    if ([item objectForKey:@"email"] != nil) [BiChatGlobal sharedManager].imChatEmail = [item objectForKey:@"email"];
    if ([item objectForKey:@"OTCExpired"] != nil) [BiChatGlobal sharedManager].exchangeExpireMinite = [[item objectForKey:@"OTCExpired"]integerValue];
    if ([item objectForKey:@"RewardExpired"] != nil) [BiChatGlobal sharedManager].rewardExpireMinite = [[item objectForKey:@"RewardExpired"]integerValue];
    if ([item objectForKey:@"TransferExpired"] != nil) [BiChatGlobal sharedManager].transferExpireMinite = [[item objectForKey:@"TransferExpired"]integerValue];
    if ([item objectForKey:@"download"] != nil) [BiChatGlobal sharedManager].download = [item objectForKey:@"download"];
    if ([item objectForKey:@"forceMenus"] != nil) [BiChatGlobal sharedManager].forceMenu = [item objectForKey:@"forceMenus"];
    if ([item objectForKey:@"unlockMinPoint"] != nil) [BiChatGlobal sharedManager].unlockMinPoint = [[item objectForKey:@"unlockMinPoint"]integerValue];
    if ([item objectForKey:@"versionNum"] != nil) [BiChatGlobal sharedManager].systemConfigVersionNumber = [NSString stringWithFormat:@"%@", [item objectForKey:@"versionNum"]];
    if ([item objectForKey:@"exchangeAllowed"] != nil) [BiChatGlobal sharedManager].exchangeAllowed = [[item objectForKey:@"exchangeAllowed"]boolValue];
    if ([item objectForKey:@"business"] != nil) [BiChatGlobal sharedManager].business = [item objectForKey:@"business"];
    if ([item objectForKey:@"scanCodeRule"] != nil) [BiChatGlobal sharedManager].scanCodeRule = [item objectForKey:@"scanCodeRule"];
    //多语言
    if ([item objectForKey:@"langPath"] != nil) [BiChatGlobal sharedManager].langPath = [item objectForKey:@"langPath"];
    //短链接
    if ([item objectForKey:@"langPath"] != nil) [BiChatGlobal sharedManager].shortLinkTempl = [item objectForKey:@"shortLinkTempl"];
    if ([item objectForKey:@"langPath"] != nil) [BiChatGlobal sharedManager].shortLinkPattern = [item objectForKey:@"shortLinkPattern"];

    //整个记录一下
    if (item != nil && [[item objectForKey:@"cfgNo"]integerValue] == 1)
        [BiChatGlobal sharedManager].systemConfig = item;
    
    //鲁棒性操作
    if ([BiChatGlobal sharedManager].exchangeExpireMinite == 0)
        [BiChatGlobal sharedManager].exchangeExpireMinite = 60 * 24;
    if ([BiChatGlobal sharedManager].rewardExpireMinite == 0)
        [BiChatGlobal sharedManager].rewardExpireMinite = 60 * 24;
    if ([BiChatGlobal sharedManager].transferExpireMinite == 0)
        [BiChatGlobal sharedManager].transferExpireMinite = 60 * 24;
    if ([BiChatGlobal sharedManager].business.length == 0)
        [BiChatGlobal sharedManager].business = @"7777";
    [[BiChatGlobal sharedManager]saveGlobalInfo];
    
    //发一个通知
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_SYSCONFIG object:nil];
    
    //是否需要强制更新
    [[BiChatGlobal sharedManager]checkUpdate];
}

- (void)checkUpdate
{
    NSString *str4Version = [BiChatGlobal getAppVersion];
    if ([[BiChatGlobal sharedManager].allowedVersion compare:str4Version options:NSNumericSearch] == NSOrderedDescending)
        [[BiChatGlobal sharedManager]forceUpgrade];
}

- (void)selectIndexTwoDelay:(NSTimeInterval)delay {
    [self performSelector:@selector(setSelectIndexTow) withObject:nil afterDelay:delay];
}

- (void)setSelectIndexTow {
    self.mainGUI.selectedIndex = 2;
}

//返回入群类型字符串
+ (NSString *)getSourceString:(NSString *)source
{
    if (source.length == 0) return @"";
    if ([source isEqualToString:@"CONTACT"]) return LLSTR(@"106119");
    if ([source isEqualToString:@"PHONE"]) return LLSTR(@"106103");
    if ([source isEqualToString:@"GROUP"]) return LLSTR(@"106104");
    if ([source isEqualToString:@"USER_NAME"]) return LLSTR(@"106120");
    if ([source isEqualToString:@"CARD"]) return LLSTR(@"106106");
    if ([source isEqualToString:@"REFCODE"]) return LLSTR(@"106121");
    if ([source isEqualToString:@"WECHAT_CODE"]) return LLSTR(@"201054");
    if ([source isEqualToString:@"APP_CODE"]) return LLSTR(@"201055");
    if ([source isEqualToString:@"WECHAT_REWARD"]) return LLSTR(@"201056");
    if ([source isEqualToString:@"APP_REWARD"]) return LLSTR(@"201057");
    if ([source isEqualToString:@"INVITE"]) return LLSTR(@"201058");
    if ([source isEqualToString:@"MOVE"]) return LLSTR(@"201059");
    if ([source isEqualToString:@"DISCOVER"]) return LLSTR(@"201060");
    if ([source isEqualToString:@"ACTIVITY"]) return LLSTR(@"201062");
    if ([source isEqualToString:@"INVITEE"]) return LLSTR(@"201063");
    if ([source isEqualToString:@"GROUP_APP"]) return LLSTR(@"201075");
    if ([source isEqualToString:@"WEBAUTH"]) return LLSTR(@"201076");
    if ([source isEqualToString:@"LINK"]) return LLSTR(@"201064");
    if ([source isEqualToString:@"CODE"]) return LLSTR(@"201055");
    if ([source isEqualToString:@"REDPACKET"]) return LLSTR(@"201057");
    if ([source isEqualToString:@"URL"]) return LLSTR(@"201077");
    if ([source isEqualToString:@"URL_LINK"]) return LLSTR(@"201078");
    return source;
}

//返回本手机类型
+ (NSString *)getIphoneType
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *phoneType = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if ([phoneType isEqualToString:@"iPhone1,1"])  return @"iPhone 2G";
    if ([phoneType isEqualToString:@"iPhone1,2"])  return @"iPhone 3G";
    if ([phoneType isEqualToString:@"iPhone2,1"])  return @"iPhone 3GS";
    if ([phoneType isEqualToString:@"iPhone3,1"])  return @"iPhone 4";
    if ([phoneType isEqualToString:@"iPhone3,2"])  return @"iPhone 4";
    if ([phoneType isEqualToString:@"iPhone3,3"])  return @"iPhone 4";
    if ([phoneType isEqualToString:@"iPhone4,1"])  return @"iPhone 4S";
    if ([phoneType isEqualToString:@"iPhone5,1"])  return @"iPhone 5";
    if ([phoneType isEqualToString:@"iPhone5,2"])  return @"iPhone 5";
    if ([phoneType isEqualToString:@"iPhone5,3"])  return @"iPhone 5c";
    if ([phoneType isEqualToString:@"iPhone5,4"])  return @"iPhone 5c";
    if ([phoneType isEqualToString:@"iPhone6,1"])  return @"iPhone 5s";
    if ([phoneType isEqualToString:@"iPhone6,2"])  return @"iPhone 5s";
    if ([phoneType isEqualToString:@"iPhone7,1"])  return @"iPhone 6 Plus";
    if ([phoneType isEqualToString:@"iPhone7,2"])  return @"iPhone 6";
    if ([phoneType isEqualToString:@"iPhone8,1"])  return @"iPhone 6s";
    if ([phoneType isEqualToString:@"iPhone8,2"])  return @"iPhone 6s Plus";
    if ([phoneType isEqualToString:@"iPhone8,4"])  return @"iPhone SE";
    if ([phoneType isEqualToString:@"iPhone9,1"])  return @"iPhone 7";
    if ([phoneType isEqualToString:@"iPhone9,2"])  return @"iPhone 7 Plus";
    if ([phoneType isEqualToString:@"iPhone10,1"]) return @"iPhone 8";
    if ([phoneType isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
    if ([phoneType isEqualToString:@"iPhone10,2"]) return @"iPhone 8 Plus";
    if ([phoneType isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
    if ([phoneType isEqualToString:@"iPhone10,3"]) return @"iPhone X";
    if ([phoneType isEqualToString:@"iPhone10,6"]) return @"iPhone X";
    if ([phoneType isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
    if ([phoneType isEqualToString:@"iPhone11,4"]) return @"iPhone XS Max";      //美版
    if ([phoneType isEqualToString:@"iPhone11,6"]) return @"iPhone XS Max";
    if ([phoneType isEqualToString:@"iPhone11,8"]) return @"iPhone XR";
    
    //其他类型
    return phoneType;
}

//返回本地ip地址
+ (NSString *)getLocalIpAddress
{
    NSString *ipAddress = nil;
    struct ifaddrs *ifa_list = NULL;
    struct ifaddrs *tmp = NULL;
    int result;
    
    result = getifaddrs(&ifa_list);
    
    if(result == 0)
    {
        tmp = ifa_list;
        ipAddress = @"";
        
        while(tmp){
            if(tmp->ifa_addr->sa_family == AF_INET){
                if([[NSString stringWithUTF8String:tmp->ifa_name] isEqualToString:@"en0"])
                {
                    ipAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)tmp->ifa_addr)->sin_addr)];
                    break;
                }
            }
            tmp = tmp->ifa_next;
        }
    }
    
    freeifaddrs(ifa_list);
    return ipAddress;
}

//返回本app的版本号
+ (NSString *)getAppVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
#ifdef ENV_DEV
    NSString *str4Version = [NSString stringWithFormat:@"%@.%@", [infoDictionary objectForKey:@"CFBundleShortVersionString"], [infoDictionary objectForKey:@"CFBundleVersion"]];
#endif
#ifdef ENV_TEST
    NSString *str4Version = [NSString stringWithFormat:@"%@.%@", [infoDictionary objectForKey:@"CFBundleShortVersionString"], [infoDictionary objectForKey:@"CFBundleVersion"]];
#endif
#ifdef ENV_LIVE
    NSString *str4Version = [NSString stringWithFormat:@"%@", [infoDictionary objectForKey:@"CFBundleShortVersionString"]];
#endif
#ifdef ENV_CN
    NSString *str4Version = [NSString stringWithFormat:@"%@", [infoDictionary objectForKey:@"CFBundleShortVersionString"]];
#endif
#ifdef ENV_ENT
    NSString *str4Version = [NSString stringWithFormat:@"%@", [infoDictionary objectForKey:@"CFBundleShortVersionString"]];
#endif
#ifdef ENV_V_DEV
    NSString *str4Version = [NSString stringWithFormat:@"%@.%@", [infoDictionary objectForKey:@"CFBundleShortVersionString"], [infoDictionary objectForKey:@"CFBundleVersion"]];
#endif
    return str4Version;
}

- (void)forceUpgrade
{
    NSString *versionInfo;
    if ([BiChatGlobal sharedManager].lastestVersion.length == 0)
        versionInfo = LLSTR(@"107101");
    else
        versionInfo = [LLSTR(@"107102") llReplaceWithArray:@[[BiChatGlobal sharedManager].lastestVersion]];
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:LLSTR(@"107103")
                                                                    message:versionInfo
                                                             preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:LLSTR(@"107104") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:APPOPENURL] options:@{} completionHandler:nil];
        
    }];
    [action1 setValue:LightBlue forKey:@"_titleTextColor"];
    [alertC addAction:action1];
    [self.mainGUI presentViewController:alertC animated:YES completion:nil];
}

+ (BOOL)isTextContainLink:(NSString *)text
{
    NSString *target = [text lowercaseString];
    if ([target containsString:@"http://"] ||
        [target containsString:@"https://"] ||
        [target containsString:@"ftp://"] ||
        [target containsString:@"mailto://"] ||
        [target containsString:@"www."] ||
        [target containsString:@".top"] ||
        [target containsString:@".com"] ||
        [target containsString:@".xyz"] ||
        [target containsString:@".xin"] ||
        [target containsString:@".vip"] ||
        [target containsString:@".win"] ||
        [target containsString:@".red"] ||
        [target containsString:@".net"] ||
        [target containsString:@".org"] ||
        [target containsString:@".wang"] ||
        [target containsString:@".gov"] ||
        [target containsString:@".edu"] ||
        [target containsString:@".mil"] ||
        [target containsString:@".co"] ||
        [target containsString:@".biz"] ||
        [target containsString:@".name"] ||
        [target containsString:@".info"] ||
        [target containsString:@".mobi"] ||
        [target containsString:@".pro"] ||
        [target containsString:@".travel"] ||
        [target containsString:@".club"] ||
        [target containsString:@".museum"] ||
        [target containsString:@".int"] ||
        [target containsString:@".aero"] ||
        [target containsString:@".post"] ||
        [target containsString:@".rec"] ||
        [target containsString:@".asia"] ||
        [target containsString:@".art"] ||
        [target containsString:@".firm"] ||
        [target containsString:@".nom"] ||
        [target containsString:@".rec"] ||
        [target containsString:@".store"] ||
        [target containsString:@".web"] ||
        [target containsString:@".cn"] ||
        [target containsString:@".au"] ||
        [target containsString:@".ad"] ||
        [target containsString:@".ae"] ||
        [target containsString:@".af"] ||
        [target containsString:@".ag"] ||
        [target containsString:@".ai"] ||
        [target containsString:@".al"] ||
        [target containsString:@".am"] ||
        [target containsString:@".an"] ||
        [target containsString:@".ao"] ||
        [target containsString:@".aa"] ||
        [target containsString:@".ar"] ||
        [target containsString:@".as"] ||
        [target containsString:@".at"] ||
        [target containsString:@".au"] ||
        [target containsString:@".aw"] ||
        [target containsString:@".az"] ||
        [target containsString:@".ba"] ||
        [target containsString:@".bb"] ||
        [target containsString:@".bd"] ||
        [target containsString:@".be"] ||
        [target containsString:@".bf"] ||
        [target containsString:@".bg"] ||
        [target containsString:@".bh"] ||
        [target containsString:@".bi"] ||
        [target containsString:@".bj"] ||
        [target containsString:@".bm"] ||
        [target containsString:@".bn"] ||
        [target containsString:@".bo"] ||
        [target containsString:@".br"] ||
        [target containsString:@".bs"] ||
        [target containsString:@".bt"] ||
        [target containsString:@".bv"] ||
        [target containsString:@".bw"] ||
        [target containsString:@".by"] ||
        [target containsString:@".bz"] ||
        [target containsString:@".ca"] ||
        [target containsString:@".cc"] ||
        [target containsString:@".cf"] ||
        [target containsString:@".cd"] ||
        [target containsString:@".ch"] ||
        [target containsString:@".ci"] ||
        [target containsString:@".ck"] ||
        [target containsString:@".cl"] ||
        [target containsString:@".cm"] ||
        [target containsString:@".cn"] ||
        [target containsString:@".co"] ||
        [target containsString:@".cq"] ||
        [target containsString:@".cr"] ||
        [target containsString:@".cu"] ||
        [target containsString:@".cv"] ||
        [target containsString:@".cx"] ||
        [target containsString:@".cy"] ||
        [target containsString:@".cy"] ||
        [target containsString:@".cz"] ||
        [target containsString:@".de"] ||
        [target containsString:@".dj"] ||
        [target containsString:@".dk"] ||
        [target containsString:@".dm"] ||
        [target containsString:@".do"] ||
        [target containsString:@".dz"] ||
        [target containsString:@".ec"] ||
        [target containsString:@".ee"] ||
        [target containsString:@".eg"] ||
        [target containsString:@".eh"] ||
        [target containsString:@".er"] ||
        [target containsString:@".es"] ||
        [target containsString:@".et"] ||
        [target containsString:@".ev"] ||
        [target containsString:@".fi"] ||
        [target containsString:@".fj"] ||
        [target containsString:@".fk"] ||
        [target containsString:@".fm"] ||
        [target containsString:@".fo"] ||
        [target containsString:@".fr"] ||
        [target containsString:@".ga"] ||
        [target containsString:@".gd"] ||
        [target containsString:@".ge"] ||
        [target containsString:@".gf"] ||
        [target containsString:@".gg"] ||
        [target containsString:@".gh"] ||
        [target containsString:@".gi"] ||
        [target containsString:@".gl"] ||
        [target containsString:@".gm"] ||
        [target containsString:@".gn"] ||
        [target containsString:@".gp"] ||
        [target containsString:@".gr"] ||
        [target containsString:@".gs"] ||
        [target containsString:@".gt"] ||
        [target containsString:@".gu"] ||
        [target containsString:@".gw"] ||
        [target containsString:@".gy"] ||
        [target containsString:@".hk"] ||
        [target containsString:@".hm"] ||
        [target containsString:@".hn"] ||
        [target containsString:@".hr"] ||
        [target containsString:@".ht"] ||
        [target containsString:@".hu"] ||
        [target containsString:@".id"] ||
        [target containsString:@".ie"] ||
        [target containsString:@".il"] ||
        [target containsString:@".im"] ||
        [target containsString:@".in"] ||
        [target containsString:@".io"] ||
        [target containsString:@".iq"] ||
        [target containsString:@".ir"] ||
        [target containsString:@".is"] ||
        [target containsString:@".it"] ||
        [target containsString:@".jm"] ||
        [target containsString:@".jo"] ||
        [target containsString:@".jp"] ||
        [target containsString:@".je"] ||
        [target containsString:@".ke"] ||
        [target containsString:@".kg"] ||
        [target containsString:@".kh"] ||
        [target containsString:@".ki"] ||
        [target containsString:@".km"] ||
        [target containsString:@".kn"] ||
        [target containsString:@".kp"] ||
        [target containsString:@".kr"] ||
        [target containsString:@".kw"] ||
        [target containsString:@".ky"] ||
        [target containsString:@".kz"] ||
        [target containsString:@".la"] ||
        [target containsString:@".lb"] ||
        [target containsString:@".lc"] ||
        [target containsString:@".li"] ||
        [target containsString:@".lk"] ||
        [target containsString:@".lr"] ||
        [target containsString:@".ls"] ||
        [target containsString:@".lt"] ||
        [target containsString:@".lu"] ||
        [target containsString:@".lv"] ||
        [target containsString:@".ly"] ||
        [target containsString:@".ma"] ||
        [target containsString:@".mc"] ||
        [target containsString:@".md"] ||
        [target containsString:@".me"] ||
        [target containsString:@".mg"] ||
        [target containsString:@".mh"] ||
        [target containsString:@".mk"] ||
        [target containsString:@".ml"] ||
        [target containsString:@".mm"] ||
        [target containsString:@".mn"] ||
        [target containsString:@".mo"] ||
        [target containsString:@".mp"] ||
        [target containsString:@".mq"] ||
        [target containsString:@".mr"] ||
        [target containsString:@".ms"] ||
        [target containsString:@".mt"] ||
        [target containsString:@".mu"] ||
        [target containsString:@".mv"] ||
        [target containsString:@".mw"] ||
        [target containsString:@".mx"] ||
        [target containsString:@".my"] ||
        [target containsString:@".mz"] ||
        [target containsString:@".na"] ||
        [target containsString:@".nc"] ||
        [target containsString:@".ne"] ||
        [target containsString:@".nf"] ||
        [target containsString:@".ng"] ||
        [target containsString:@".ni"] ||
        [target containsString:@".nl"] ||
        [target containsString:@".no"] ||
        [target containsString:@".np"] ||
        [target containsString:@".nr"] ||
        [target containsString:@".nt"] ||
        [target containsString:@".nu"] ||
        [target containsString:@".nz"] ||
        [target containsString:@".om"] ||
        [target containsString:@".qa"] ||
        [target containsString:@".pa"] ||
        [target containsString:@".pe"] ||
        [target containsString:@".pf"] ||
        [target containsString:@".pg"] ||
        [target containsString:@".ph"] ||
        [target containsString:@".pk"] ||
        [target containsString:@".pl"] ||
        [target containsString:@".pm"] ||
        [target containsString:@".pn"] ||
        [target containsString:@".pr"] ||
        [target containsString:@".pt"] ||
        [target containsString:@".pw"] ||
        [target containsString:@".py"] ||
        [target containsString:@".re"] ||
        [target containsString:@".rs"] ||
        [target containsString:@".ro"] ||
        [target containsString:@".ru"] ||
        [target containsString:@".rw"] ||
        [target containsString:@".sa"] ||
        [target containsString:@".sb"] ||
        [target containsString:@".sc"] ||
        [target containsString:@".sd"] ||
        [target containsString:@".se"] ||
        [target containsString:@".sg"] ||
        [target containsString:@".sh"] ||
        [target containsString:@".si"] ||
        [target containsString:@".sj"] ||
        [target containsString:@".sk"] ||
        [target containsString:@".sl"] ||
        [target containsString:@".sm"] ||
        [target containsString:@".sn"] ||
        [target containsString:@".so"] ||
        [target containsString:@".sr"] ||
        [target containsString:@".st"] ||
        [target containsString:@".sv"] ||
        [target containsString:@".su"] ||
        [target containsString:@".sy"] ||
        [target containsString:@".sz"] ||
        [target containsString:@".sx"] ||
        [target containsString:@".tc"] ||
        [target containsString:@".td"] ||
        [target containsString:@".tf"] ||
        [target containsString:@".tg"] ||
        [target containsString:@".th"] ||
        [target containsString:@".tj"] ||
        [target containsString:@".tk"] ||
        [target containsString:@".tl"] ||
        [target containsString:@".tm"] ||
        [target containsString:@".tn"] ||
        [target containsString:@".to"] ||
        [target containsString:@".tr"] ||
        [target containsString:@".tt"] ||
        [target containsString:@".tv"] ||
        [target containsString:@".tw"] ||
        [target containsString:@".tz"] ||
        [target containsString:@".ua"] ||
        [target containsString:@".ug"] ||
        [target containsString:@".uk"] ||
        [target containsString:@".um"] ||
        [target containsString:@".us"] ||
        [target containsString:@".uy"] ||
        [target containsString:@".uz"] ||
        [target containsString:@".va"] ||
        [target containsString:@".vc"] ||
        [target containsString:@".ve"] ||
        [target containsString:@".vg"] ||
        [target containsString:@".vi"] ||
        [target containsString:@".vn"] ||
        [target containsString:@".vu"] ||
        [target containsString:@".wf"] ||
        [target containsString:@".ws"] ||
        [target containsString:@".ye"] ||
        [target containsString:@".yt"] ||
        [target containsString:@".za"] ||
        [target containsString:@".zm"] ||
        [target containsString:@".zw"]
        )
        return YES;
    
    return NO;
}

+ (void)createWizardBkForView:(UIView *)view highlightRect:(CGRect)highlightRect
{
    UIImageView *view4Top = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, highlightRect.origin.y)];
    view4Top.image = [UIImage imageNamed:@"wizard_bk"];
    [view addSubview:view4Top];
    
    UIImageView *view4Left = [[UIImageView alloc]initWithFrame:CGRectMake(0, highlightRect.origin.y, highlightRect.origin.x, highlightRect.size.height)];
    view4Left.image = [UIImage imageNamed:@"wizard_bk"];
    [view addSubview:view4Left];
    
    UIImageView *view4Right = [[UIImageView alloc]initWithFrame:CGRectMake(highlightRect.origin.x + highlightRect.size.width, highlightRect.origin.y, view.frame.size.width - highlightRect.origin.x - highlightRect.size.width, highlightRect.size.height)];
    view4Right.image = [UIImage imageNamed:@"wizard_bk"];
    [view addSubview:view4Right];
    
    UIImageView *view4Bottom = [[UIImageView alloc]initWithFrame:CGRectMake(0, highlightRect.origin.y + highlightRect.size.height, view.frame.size.width, view.frame.size.height - highlightRect.origin.y - highlightRect.size.height)];
    view4Bottom.image = [UIImage imageNamed:@"wizard_bk"];
    [view addSubview:view4Bottom];
    
    //是否是正方形
    if (fabs(highlightRect.size.width - highlightRect.size.height) < 0.000001)
    {
        UIImageView *view4Hollow = [[UIImageView alloc]initWithFrame:highlightRect];
        view4Hollow.image = [UIImage imageNamed:@"circle_hollow"];
        [view addSubview:view4Hollow];
    }
}

//显示红点
- (void)showRedAtIndex:(NSInteger)index value:(BOOL)value {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *imageV = [self.mainGUI.tabBar viewWithTag:kBadgeTag + index];
        if (imageV) {
            [imageV removeFromSuperview];
        }
        if (value) {
            NSInteger count = [BiChatGlobal sharedManager].mainGUI.viewControllers.count;
            if (count == 0) {
                count = 5;
            }
            UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenWidth / count) * (index + 1) - (ScreenWidth / count) * 0.35, 5, 10, 10)];
            imageV.backgroundColor = [UIColor redColor];
            imageV.tag = index + kBadgeTag;
            imageV.layer.cornerRadius = 5;
            imageV.layer.masksToBounds = YES;
            [self.mainGUI.tabBar addSubview:imageV];
        }
    });
}

+ (NSString *)getAlphabet:(NSString *)nickName
{
    if (nickName.length == 0)
        return @"";
    
    //开始计算
    NSString *str4Return = @"";
    for (int i = 0; i < nickName.length; i ++)
    {
        char c = pinyinFirstLetter([nickName characterAtIndex:i]);
        str4Return = [str4Return stringByAppendingFormat:@"%c", c];
    }
    return [str4Return lowercaseString];
}

- (void)reportGroupOperation
{
    if (_array4GroupOperation.count == 0)
        return;
    
    //开始报告
    [NetworkModule reportMyGroupAccess:_array4GroupOperation completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        if (success)
        {
            [_array4GroupOperation removeAllObjects];
        }
    }];
}

- (void)saveWeb:(NSDictionary *)data {
    
    for (NSDictionary *dict in self.webArray) {
        if ([dict objectForKey:[data allKeys][0]]) {
            return;
        }
    }
    
    
    if (!self.webArray) {
        self.webArray = [NSMutableArray array];
    }
    [self.webArray insertObject:data atIndex:0];
    if (self.webArray.count > 5) {
        [self.webArray removeLastObject];
    }
}

- (WPNewsDetailViewController *)getWeb:(NSString *)url
{
    for (NSDictionary *item in self.webArray)
    {
        if ([item objectForKey:url] != nil)
            return [item objectForKey:url];
    }
    return nil;
}

@end
