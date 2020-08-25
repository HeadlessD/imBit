//
//  DFMomentViewController.m
//  DFTimelineView
//
//  Created by 豆凯强 on 17/9/27.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#import "DFMomentViewController.h"
#import "DFMomentBaseCell.h"
#import "DFNotCell.h"
#import "DFImagesSendViewController.h"
#import "DFImagesSendViewController.h"
#import "DFTimeLineViewController.h"
#import "IQKeyboardManager.h"
#import "S3SDK_.h"
#import "DFMomentInputView.h"
#import "DFMomentBaseCell.h"
#import "DFRemindingViewController.h"
#import "UserDetailViewController.h"
#import "WPNewsDetailViewController.h"
#import "ChatSelectViewController.h"
#import "ChatViewController.h"
#import "WPGroupAddMiddleViewController.h"
#import "MJPhoto.h"
#import "TextRenderViewController.h"
#import <Photos/PHPhotoLibrary.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import "DFLocationViewController.h"
#import "DFLookMapViewController.h"

#define remindViewWidth 180


@interface DFMomentViewController ()<DFMomentBaseCellDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,DFImagesSendViewControllerDelegate,UITextViewDelegate,DFMomentInputViewDelegate,ChatSelectDelegate,/*MSTImagePickerControllerDelegate,*/UIGestureRecognizerDelegate,MJPhotoBrowserDelegate,LFImagePickerControllerDelegate>

@property (strong, nonatomic) DFMomentInputView * dfMomentInputView;

@property (nonatomic, strong) UIImagePickerController * pickerController;
@property (nonatomic, strong) UIImagePickerController * coverCameraPicker;
@property (nonatomic, strong) UIImagePickerController * coverLibraryPicker;

//@property (nonatomic,strong) MSTImagePickerController * textImgPickerVc;
@property (nonatomic,strong) LFImagePickerController  * textImgPickerVc;

@property (nonatomic,strong) DFImagesSendViewController *sendController;

@property (nonatomic,strong) UIView * testView;
@property (nonatomic,strong) UIView * remindingView;
@property (nonatomic,strong) UIImageView * remindingAvatar;
@property (nonatomic,strong) UILabel * remindingLabel;
@property (nonatomic,strong) UIImageView * remindingArrow;

@property (nonatomic,strong) NSMutableArray * subDataSource;
@property (nonatomic,assign) NSInteger  subIndex;

@property (nonatomic,assign) BOOL  isNotAllowBack;


@end

@implementation DFMomentViewController

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = YES;
    
    //禁止返回
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self addRemindingView];
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    //YES：允许右滑返回  NO：禁止右滑返回
    if (_isNotAllowBack) {
        return NO;
    }else{
        return YES;
    }
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [DFMomentsManager sharedInstance].isNewMomentRedPoint = NO;
    
    if (_dfMomentInputView) {
        _dfMomentInputView = nil;
    }
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _subIndex = 0;
    _subDataSource = [NSMutableArray array];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(longTapOnImage:) name:@"photo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWithIndex:) name:NOTI_MOMENT_TYPE_UPDATEMOMENT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MomentReloadData) name:NOTI_MOMENT_TYPE_RELOADDATA object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addRemindingView) name:NOTI_MOMENT_TYPE_ADD_REMINDINGVIEW object:nil];
    
    [IQKeyboardManager sharedManager].enable = NO;
    
    self.title = LLSTR(@"104001");
    [self setHeader];
    
    [self.tableView.tableHeaderView addSubview:self.remindingView];
    //    [self.tableView.mj_header beginRefreshing];
    
    [self MomentReloadData];
    [self.tableView.mj_header beginRefreshing];
    //    [self.view addSubview:self.dfMomentInputView];
    
    [self  repMomentModel];
    
    
    
    DFBaseMomentModel * test = [[DFBaseMomentModel alloc]init];
    test.videoUrlStr_copy = @"copy_111111111111111111";
    test.videoUrlStr_strong = @"strong_22222222222222222";
    
    NSMutableArray * testArr = @[test.videoUrlStr_copy,test.videoUrlStr_strong];
    NSLog(@"11111%@",testArr);
    
    test.videoUrlStr_copy = @"copy_333333333333333";
    test.videoUrlStr_strong = @"strong_44444444444444";
    NSLog(@"222222%@",testArr);

}

-(void)repMomentModel{
    
    for (DFBaseMomentModel * baseModel in _subDataSource) {
        
        if (baseModel.isNeedRepSend) {
            //    NSLog(@"这个需要重新发送");
            
            //时间重设
            NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970]*1000;
            long long theTime = [[NSNumber numberWithDouble:nowtime] longLongValue];
            baseModel.message.ctime = theTime;
            
            NSMutableArray * imageArr = [NSMutableArray array];
            if (baseModel.itsrcImages.count) {
                for (int i = 0 ; i < baseModel.itsrcImages.count; i++) {
                    
                    NSString * imgStr = baseModel.itsrcImages[i];
                    
                    if ([[imgStr substringToIndex:8] isEqualToString:@"imgcache"]) {
                        NSString *path = [WPBaseManager fileName:[imgStr substringFromIndex:8] inDirectory:@"dfImage"];
                        UIImage * imageeee = [UIImage imageWithContentsOfFile:path];
                        if (imageeee) {
                            [imageArr addObject:imageeee];
                        }
                    }
                }
            }
            NSInteger imageType = MomentSendType_Text;
            if (imageArr.count) {
                imageType = MomentSendType_Image;
            }

            [DFLogicTool updateImageAndVideo:imageArr videoUrl:nil videoImg:nil success:^(NSArray *imgArr, NSString *jsonStr) {
                
                NSDictionary * addMessageDic = @{@"id":baseModel.message.momentId,
                                                 @"tokenid":[BiChatGlobal sharedManager].token,
                                                 @"content":baseModel.message.content,
                                                 @"type":@(imageType),
                                                 @"mediasList":jsonStr,
                                                 @"location":@"",
                                                 @"seeType":@1,
                                                 @"seeUids":@"",
                                                 @"notToSeeUids":@"",
                                                 @"remindUids":@""};
                [[WPBaseManager baseManager] getInterface:@"Chat/ApiCircleOfFriends/addMessage.do" parameters:addMessageDic success:^(id response) {
                    if ([[response stringObjectForkey:@"code"] isEqualToString:@"0"]){

                        baseModel.isNeedRepSend = NO;
                        [DFMomentsManager insertMomentModel:baseModel atTopOrBottom:@"top"];
                        
                        //    NSLog(@"重发成功");
                        [self MomentReloadData];
                        
                        //获取积分
                        [NetworkModule sendMomentWithType:@{@"type":@"MOMENT"} completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        }];
                    }else{
                        //    NSLog(@"发表失败");
                    }
                } failure:^(NSError *error) {
                    //    NSLog(@"发表失败");
                }];
            } failure:^(NSError *error) {
                //    NSLog(@"发表失败");
            }];
        }else if (baseModel.isNeedRepComment){
            
            BOOL haveRepCom = NO;
            
            for (CommentModel * comModel in baseModel.commentList) {
                
                if (comModel.isNeedCommentTwo) {
                    haveRepCom = YES;
                    
                    NSDictionary * dict = @{@"id":comModel.commentId,
                                            @"tokenid":[BiChatGlobal sharedManager].token,
                                            @"msgId":baseModel.message.momentId,
                                            @"content":comModel.content,
                                            @"reply_uid":comModel.replyUser.uid?comModel.replyUser.uid:@""};
                    //评论请求
                    //    NSLog(@"_______评论请求——%@",commentItem.content);
                    [[WPBaseManager baseManager] getInterface:@"Chat/ApiCircleOfFriends/addComment.do" parameters:dict success:^(id response)
                     {
                         NSLog(@"重发评论成功");
                         comModel.isNeedCommentTwo = NO;

                         //获取积分socket To林超
                         [NetworkModule sendMomentWithType:@{@"type":@"COMMENT"} completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                         }];
                         //    NSLog(@"_______评论请求成功——%@",commentItem.content);
                     } failure:^(NSError *error) {
                         NSLog(@"重发评论失败");

//                         [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]];
                     }];
                    
                }
            }
            if (!haveRepCom) {
                baseModel.isNeedRepComment = NO;
                NSLog(@"没有需要重发的了");
            }
        }
    }
}


-(void)dealloc{
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"photo" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTI_MOMENT_TYPE_UPDATEMOMENT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTI_MOMENT_TYPE_RELOADDATA object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTI_MOMENT_TYPE_ADD_REMINDINGVIEW object:nil];
}

-(DFMomentInputView *)dfMomentInputView{
    if (!_dfMomentInputView) {
        _dfMomentInputView = [[DFMomentInputView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _dfMomentInputView.delegate = self;
        _dfMomentInputView.hidden = YES;
        [self.view addSubview:_dfMomentInputView];
    }
    return _dfMomentInputView;
}

//添加新消息提示窗
-(void)addRemindingView{
    
//    NSLog(@"addRemindingView");
    
    if ([DFMomentsManager sharedInstance].newMomentRemindingCount) {
        self.tableView.tableHeaderView.frame  = CGRectMake(0, 0, ScreenWidth, 420);
        _remindingView.frame = CGRectMake((ScreenWidth - remindViewWidth)/2, self.tableView.tableHeaderView.frame.size.height - 50, remindViewWidth, 40);
        [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
        _remindingView.hidden = NO;
        
        if ([DFMomentsManager sharedInstance].remind_arr.count) {
            DFPushModel * pushModel = [DFMomentsManager sharedInstance].remind_arr[0];
            [_remindingAvatar setImageWithURL:[DFLogicTool getImgWithStr:pushModel.dfContent.avatar] title:pushModel.dfContent.remark size:CGSizeMake(40, 40) placeHolde:nil color:nil textColor:nil];
            NSString * remindCount = [NSString stringWithFormat:@"%ld",[DFMomentsManager sharedInstance].newMomentRemindingCount];
            
            _remindingLabel.text = [LLSTR(@"104006") llReplaceWithArray:@[remindCount]];
        }
    }else{
        self.tableView.tableHeaderView.frame  = CGRectMake(0, 0, ScreenWidth, 380);
        [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
        _remindingView.hidden = YES;
    }
}

//跳转新消息界面
-(void)pushRemindingViewController{
    DFRemindingViewController * vc = [[DFRemindingViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

//刷新一条动态
- (void)updateWithIndex:(NSNotification *)noti {
    
//    NSLog(@"updateWithIndex");
    DFBaseMomentModel * basemodel = [noti.object objectForKey:NOTI_MOMENT_TYPE_UPDATEMOMENT];
    
    //        //    NSLog(@"__最终刷新model一共%lu条",(unsigned long)basemodel.commentList.count);
    if ([[DFMomentsManager sharedInstance].moment_dict objectForKey:basemodel.message.momentId] != nil){
        //        NSUInteger index = [[DFMomentsManager sharedInstance].moment_arr indexOfObject:basemodel];
        //        NSIndexPath * indexPath_1=[NSIndexPath indexPathForRow:index inSection:0];
        //        NSArray *indexArray=[NSArray arrayWithObject:indexPath_1];
        //        [self.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];
        [self MomentReloadData];
    }
}



-(void) setHeader
{
    NSString * userCover = [[DFMomentsManager sharedInstance].userCover_dict objectForKey:[BiChatGlobal sharedManager].uid];
    NSString * userCover2 = [[DFYTKDBManager sharedInstance].store getStringById:TabKey_UserCover fromTable:OtherTab];
    
    if (userCover) {
        [self setOwnCover:[DFLogicTool getImgWithStr:userCover]];
    }else{
        [self setOwnCover:[DFLogicTool getImgWithStr:userCover2]];
    }
    
    [[WPBaseManager baseManager] getInterface:@"Chat/ApiCircleOfFriends/getCircleOfFriendsUserSetting.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token} success:^(id response) {
        if ([[response stringObjectForkey:@"code"] isEqualToString:@"0"]){
            NSDictionary * dataDic = [response objectForKey:@"data"];
            NSString * imgStr = [dataDic objectForKey:@"cover"];
            if (imgStr.length > 0) {
                [self setOwnCover:[DFLogicTool getImgWithStr:imgStr]];
                [[DFYTKDBManager sharedInstance].store putString:imgStr withId:TabKey_UserCover intoTable:OtherTab];
                [[DFMomentsManager sharedInstance].userCover_dict setObject:imgStr forKey:[BiChatGlobal sharedManager].uid];
            }
        }
    } failure:^(NSError *error) {
        [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]];
    }];
    //备注名
    //    [[BiChatGlobal sharedManager]getFriendMemoName:self.uid]
    //背景
    [self setUserAvatar:[DFLogicTool getImgWithStr:[BiChatGlobal sharedManager].avatar] withName:[BiChatGlobal sharedManager].nickName];
    [self setUserNick:[BiChatGlobal sharedManager].nickName];
    [self setUserSign:[[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"sign"]];
}

#pragma mark - 获取朋友圈
-(void)getMomentsWithTimeStamp:(NSInteger )timeStamp withAction:(NSNumber *)action
{    // 0:下拉，1：上推
    
        //    NSLog(@"timeStamp_%ld",(long)timeStamp);
    NSDictionary * addMessageDic = @{@"tokenid":[BiChatGlobal sharedManager].token,@"index":[NSNumber numberWithInteger:timeStamp],@"action":action};
    //获取朋友圈-我的
    [[WPBaseManager baseManager] getInterface:@"Chat/ApiCircleOfFriends/getCircleOfFriendsMessageList.do" parameters:addMessageDic success:^(id response) {
        if ([[response stringObjectForkey:@"code"] isEqualToString:@"0"]) {
            
            NSDictionary * dataDic = [response objectForKey:@"data"];
            
            NSArray * listArr = [dataDic objectForKey:@"list"];
            
            [self endLoadNew];
            [self endLoadMore];

            
            if (listArr.count) {
                if ([action isEqualToNumber:[NSNumber numberWithInteger:0]])listArr = [[listArr reverseObjectEnumerator] allObjects];
                
                for (NSDictionary * itDic in listArr) {
                    DFBaseMomentModel * itModel = [DFBaseMomentModel mj_objectWithKeyValues:itDic];
                    
                    //高度计算
                    [DFMomentsManager getLikeOrNotLike:itModel];
                    [DFMomentsManager addMediasFromeModel:itModel];
                    [DFMomentBaseCell getMomentBaseCellHeight:itModel isSaveH:NO];
                    [DFMomentsManager saveIndexWith:[itModel.message.index integerValue]];

                    if ([action isEqualToNumber:[NSNumber numberWithInteger:0]]) {
                        [DFMomentsManager insertMomentModel:itModel atTopOrBottom:@"top"];
                    }else{
                        [DFMomentsManager insertMomentModel:itModel atTopOrBottom:@"bottom"];
                    }
                    [DFYTKDBManager saveMomentModel:itModel];//获取
                }
                
                [[DFYTKDBManager sharedInstance].store putNumber:[NSNumber numberWithInteger:[DFMomentsManager sharedInstance].loadNewIndex] withId:@"loadNewIndex" intoTable:IndexTab];
                
                [[DFYTKDBManager sharedInstance].store putNumber:[NSNumber numberWithInteger:[DFMomentsManager sharedInstance].loadMoreIndex] withId:@"loadMoreIndex" intoTable:IndexTab];
                
                if ([action isEqualToNumber:[NSNumber numberWithInteger:0]]) {
                    [self MomentReloadData];
                }else{
                    [self MomentReloadDataMore];
                }
            }
        }else{
            [self endLoadNew];
            [self endLoadMore];
        }
    } failure:^(NSError *error) {
        [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]];
        [self endLoadNew];
        [self endLoadMore];
    }];
}

#pragma mark - 发表朋友圈
-(void)sendMomentWithText:(NSString *)text images:(NSArray *)images videoUrl:(NSString *)videoUrl videoImg:(UIImage *)videoImg location:(AMapPOI *)location
{
    static MomentSendType sendType = MomentSendType_Text;
    if (images.count) {
        sendType = MomentSendType_Image;
    }else if (videoUrl.length && videoImg){
        sendType = MomentSendType_Video;
    }

    NSString * locaJsonStr = @"";
    if (location) {
        NSMutableDictionary * locaDic = [NSMutableDictionary dictionary];
        [locaDic setObject:location.name forKey:@"name"];
        [locaDic setObject:location.address forKey:@"address"];
        [locaDic setObject:[NSNumber numberWithFloat:location.location.longitude] forKey:@"longitude"];
        [locaDic setObject:[NSNumber numberWithFloat:location.location.latitude] forKey:@"latitude"];
        locaJsonStr = [DFLogicTool JsonNSDictionaryToJsonStr:locaDic];
    }

    DFBaseMomentModel *textImageItem = [[DFBaseMomentModel alloc] init];
    textImageItem.message = [[Message alloc]init];
   
    NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970]*1000;
    long long theTime = [[NSNumber numberWithDouble:nowtime] longLongValue];
    textImageItem.message.ctime = theTime;
    textImageItem.message.momentId = [DFLogicTool createUUID];
    textImageItem.message.content = text;
    textImageItem.message.location = locaJsonStr;
    textImageItem.message.type = sendType;

    textImageItem.message.createUser = [[Createuser alloc]init];
    textImageItem.message.createUser.uid = [BiChatGlobal sharedManager].uid;
    textImageItem.message.createUser.avatar = [DFLogicTool getImgWithStr:[BiChatGlobal sharedManager].avatar];
    textImageItem.message.createUser.nickName = [BiChatGlobal sharedManager].nickName; 
    textImageItem.itsrcImages = images;
    textImageItem.itthumbImages = images;
    textImageItem.dontClick = YES;
    
    textImageItem.videoUrlStr = videoUrl;
    textImageItem.videoUrlStr = videoUrl;

    if (videoImg)textImageItem.videoImgArr = @[videoImg];
    textImageItem.videoImgWidth = videoImg.size.width;
    textImageItem.videoImgHeight = videoImg.size.height;
    
    [DFMomentsManager insertMomentModel:textImageItem atTopOrBottom:@"top"];
    
    [self MomentReloadData];
    [DFLogicTool updateImageAndVideo:images videoUrl:videoUrl videoImg:videoImg success:^(NSArray *imgArr, NSString *jsonStr) {

        NSDictionary * addMessageDic = @{@"id":textImageItem.message.momentId,
                                         @"tokenid":[BiChatGlobal sharedManager].token,
                                         @"content":text,
                                         @"type":@(sendType),
                                         @"mediasList":jsonStr,
                                         @"location":locaJsonStr,
                                         @"seeType":@1,
                                         @"seeUids":@"",
                                         @"notToSeeUids":@"",
                                         @"remindUids":@""};
        [[WPBaseManager baseManager] getInterface:@"Chat/ApiCircleOfFriends/addMessage.do" parameters:addMessageDic success:^(id response) {
            if ([[response stringObjectForkey:@"code"] isEqualToString:@"0"]){
                //获取积分
                [NetworkModule sendMomentWithType:@{@"type":@"MOMENT"} completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                }];
                
            }else{
                        NSLog(@"发表失败");
                
                NSMutableArray * sendImgArr = [NSMutableArray array];
                
                for (int i = 0; i < images.count; i ++ ) {
                    NSString * imageStr = [NSString stringWithFormat:@"%@_%d",textImageItem.message.momentId,i];
                    NSString *path = [WPBaseManager fileName:imageStr inDirectory:@"dfImage"];
                    LFResultImage * resuImg = images[i];
                    [UIImageJPEGRepresentation(resuImg.originalImage, 0.6) writeToFile:path atomically:NO];
                    [sendImgArr addObject:[NSString stringWithFormat:@"imgcache%@",imageStr]];
                }
                
                textImageItem.itsrcImages = sendImgArr;
                textImageItem.itthumbImages = sendImgArr;
                textImageItem.isNeedRepSend = YES;
                
                textImageItem.videoImgArr = nil;
                textImageItem.message.mediasList = @[jsonStr];
                [DFYTKDBManager saveMomentModel:textImageItem];//获取
            }
        } failure:^(NSError *error) {
            [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]];
            
            NSMutableArray * sendImgArr = [NSMutableArray array];
            
            for (int i = 0; i < images.count; i ++ ) {
                NSString * imageStr = [NSString stringWithFormat:@"%@_%d",textImageItem.message.momentId,i];
                NSString *path = [WPBaseManager fileName:imageStr inDirectory:@"dfImage"];
                LFResultImage * resuImg = images[i];
                [UIImageJPEGRepresentation(resuImg.originalImage, 0.6) writeToFile:path atomically:NO];
                [sendImgArr addObject:[NSString stringWithFormat:@"imgcache%@",imageStr]];
            }
            
            textImageItem.itsrcImages = sendImgArr;
            textImageItem.itthumbImages = sendImgArr;
            textImageItem.isNeedRepSend = YES;
            
            textImageItem.videoImgArr = nil;
            textImageItem.message.mediasList = @[jsonStr];
            [DFYTKDBManager saveMomentModel:textImageItem];//获取
        }];
    } failure:^(NSError *error) {

        NSMutableArray * sendImgArr = [NSMutableArray array];
        
        for (int i = 0; i < images.count; i ++ ) {
            NSString * imageStr = [NSString stringWithFormat:@"%@_%d",textImageItem.message.momentId,i];
            NSString *path = [WPBaseManager fileName:imageStr inDirectory:@"dfImage"];
            LFResultImage * resuImg = images[i];
            [UIImageJPEGRepresentation(resuImg.originalImage, 0.6) writeToFile:path atomically:NO];
            [sendImgArr addObject:[NSString stringWithFormat:@"imgcache%@",imageStr]];
        }
        
        textImageItem.itsrcImages = sendImgArr;
        textImageItem.itthumbImages = sendImgArr;
        textImageItem.isNeedRepSend = YES;
        
        textImageItem.videoImgArr = nil;
        [DFYTKDBManager saveMomentModel:textImageItem];//获取
            //    NSLog(@"发表失败");
    }];
}

//删除我发表的动态
-(void)deleteMomentWithMoment:(DFBaseMomentModel*)moment
{
    //    //检查网络
    if ([DFMomentsManager sharedInstance].networkDisconnected)
    {
        [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameroAction = [UIAlertAction actionWithTitle:LLSTR(@"104013") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self deleteMoment:moment];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:cameroAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:^{}];
}

-(void)deleteMoment:(DFBaseMomentModel*)moment{
    
    //检查网络
    if ([DFMomentsManager sharedInstance].networkDisconnected)
    {
        [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]];
        return;
    }
    
    [[DFMomentsManager sharedInstance].moment_arr enumerateObjectsUsingBlock:^(DFBaseMomentModel * obj, NSUInteger idx, BOOL *stop) {
        if ([obj.message.momentId isEqualToString:moment.message.momentId]) {
            *stop = YES;
            if (*stop == YES) {
                [[DFMomentsManager sharedInstance].moment_arr removeObject:obj];
                [[DFMomentsManager sharedInstance].moment_dict removeObjectForKey:moment.message.momentId];
                [DFYTKDBManager deleteModelWithId:moment.message.momentId fromeTab:MomentTab];
                
                [self MomentReloadData];
                [BiChatGlobal showInfo:LLSTR(@"301403") withIcon:[UIImage imageNamed:@"icon_OK"]];
            }
        }
        if (*stop) {
                //    NSLog(@"array is dataSource");
        }
    }];
    
    //删除朋友圈请求
    [[WPBaseManager baseManager] getInterface:@"Chat/ApiCircleOfFriends/delMessage.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"id":moment.message.momentId} success:^(id response) {
        if ([[response stringObjectForkey:@"code"] isEqualToString:@"0"]){
            
        }else{
                //    NSLog(@"请求失败");
        }
    } failure:^(NSError *error) {
        [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]];
    }];
}

-(void)momentViewClickLikeCommentBtn:(DFBaseMomentModel*)moment momCell:(DFMomentBaseCell *)momCell{
    
    NSArray * cellArr = self.tableView.visibleCells;
    if (cellArr.count > 0) {
        for (DFMomentBaseCell *cell in cellArr) {
            if ([cell isKindOfClass: [DFNotCell class]] || [cell.cellIndexStr isEqualToString:momCell.cellIndexStr]) {
//                NSLog(@"该Cell不要管");
            }else{
                cell.likeCommentToolbar.hidden = YES;
            }
        }
    }
    momCell.likeCommentToolbar.hidden = !momCell.likeCommentToolbar.hidden;
}

#pragma mark - 点赞响应
-(void)on3LikeFromeLineCell:(DFBaseMomentModel *)baseModel{
    //检查网络
//    if ([DFMomentsManager sharedInstance].networkDisconnected)
//    {
//        [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]];
//        return;
//    }
    
    NSString * netUrl = @"";
    if (baseModel.message.isPrais) {
        //取消点赞请求
        netUrl = @"Chat/ApiCircleOfFriends/cancelPraise.do";
    }else{
        //点赞请求
        netUrl = @"Chat/ApiCircleOfFriends/addPraise.do";
        
        //获取积分socket To林超
        [NetworkModule sendMomentWithType:@{@"type":@"LIKE"} completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        }];
    }
    
    //提前本地展示
    [DFMomentsManager addlikeTestWithModel:baseModel IsPrais:baseModel.message.isPrais];
    [self MomentReloadData];
    
    [[WPBaseManager baseManager] getInterface:netUrl parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"msgId":baseModel.message.momentId} success:^(id response) {
        
    } failure:^(NSError *error) {
//        [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]];
    }];
}

-(void)DFMomentBaseCellToPlayVideoWithMoment:(DFBaseMomentModel *)moment{
    
    ZFFullScreenViewController * zfull = [[ZFFullScreenViewController alloc]init];

    NSDictionary * resourceDic = moment.message.mediasList[0];
    
    if (resourceDic) {
        zfull.playVideoUrl = [DFLogicTool getImgWithStr:[resourceDic objectForKey:@"medias_display"]];
        zfull.videoImageStr = [DFLogicTool getImgWithStr:[resourceDic objectForKey:@"medias_thumb"]];
    }else{
        zfull.playVideoUrl = moment.videoUrlStr;
        if (moment.videoImgArr.count) {
            zfull.videoImage = moment.videoImgArr[0];
        }
    }

    [self.navigationController pushViewController:zfull animated:NO];
}

-(void)DFMomentBaseCellToClickShareNewsWithMoment:(DFBaseMomentModel *)moment{
    
    WPNewsDetailViewController *detailVC = [WPNewsDetailViewController new];
    
    NSDictionary * resourceDic = [NSDictionary dictionary];
    resourceDic = [DFLogicTool JsonStringToDictionary:moment.message.resourceContent];
    
    //是一个纯的url
    if ([[resourceDic objectForKey:@"pubid"]length] == 0 && [[resourceDic objectForKey:@"newsid"]length] == 0)
    {
        detailVC.url = [resourceDic objectForKey:@"url"];
        if (detailVC.url.length == 0) detailVC.url = [resourceDic objectForKey:@"link"];
    }
    else
    {
        WPDiscoverModel *modal = [WPDiscoverModel new];
        modal.newsid = [resourceDic objectForKey:@"newsid"];
        modal.ctime = [resourceDic objectForKey:@"ctime"];
        modal.title = [resourceDic objectForKey:@"title"];
        modal.desc = [resourceDic objectForKey:@"desc"];
        modal.url = [resourceDic objectForKey:@"url"];
        modal.pubid = [resourceDic objectForKey:@"pubid"];
        modal.pubname = [resourceDic objectForKey:@"pubname"];
        modal.pubnickname = [resourceDic objectForKey:@"pubnickname"];
        modal.author = @"";
        if ([resourceDic objectForKey:@"image"])
            modal.imgs = [NSArray arrayWithObject:[resourceDic objectForKey:@"image"]];
        detailVC.model = modal;
    }
    
    detailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(void)DFMomentBaseCellToClickLocation:(DFBaseMomentModel*)moment{
    
    DFLookMapViewController * selLocation = [[DFLookMapViewController alloc]init];
    
    NSDictionary * locaDic = [DFLogicTool JsonStringToDictionary:moment.message.location];
    if (locaDic) {
        selLocation.locationDic = locaDic;
    }
//    selLocation.delegage = self;
    [self.navigationController pushViewController:selLocation animated:YES];
    
}

#pragma mark - 点击头像或者名称跳转
-(void)onClickAvatarOnCellLeftBtn:(NSString *)userId{
    UserDetailViewController * userVC = [[UserDetailViewController alloc]init];
    userVC.uid = userId;
    [self.navigationController pushViewController:userVC animated:YES];
}

-(void)onClickAvatarOnHeadView
{
        //    NSLog(@"点击自己头像2");
    DFTimeLineViewController *controller = [[DFTimeLineViewController alloc] init];
    controller.timeLineId = [BiChatGlobal sharedManager].uid;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - 评论流程
//点击评论btn
-(void)clickCommentButtonTwo:(DFBaseMomentModel *)momentModel{
    // 滚动到指定位置
    
    //    NSUInteger index = [[DFMomentsManager sharedInstance].moment_arr indexOfObject:momentModel];
    NSUInteger index = [_subDataSource indexOfObject:momentModel];
    NSIndexPath * indexPath_1=[NSIndexPath indexPathForRow:index inSection:0];
    
//    [self.tableView scrollToRowAtIndexPath:indexPath_1 atScrollPosition:UITableViewScrollPositionTop animated:NO];
//    if (self.tableView.contentOffset.y > 200) {
//        self.tableView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y - 100);
//    }
    
    [self adjustWithIndexPath:indexPath_1];
    
    self.dfMomentInputView.hidden = NO;
    self.dfMomentInputView.replyUser = nil;
    self.dfMomentInputView.momentModel = momentModel;
    self.dfMomentInputView.momentId = momentModel.message.momentId;
    [self.dfMomentInputView momentInputViewShow];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [super scrollViewDidScroll:scrollView];
}

-(void)adjustWithIndexPath:(NSIndexPath *)indexPath{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    CGRect rect = [cell.superview convertRect:cell.frame toView:window];
    [self adjustWithRect:rect];
}

-(void)adjustWithRect:(CGRect)rect{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    CGFloat delta = CGRectGetMaxY(rect) - (window.bounds.size.height - 335);
    CGPoint offset = self.tableView.contentOffset;
    offset.y += delta;
    if (offset.y < 0) {
        offset.y = 0;
    }
    [self.tableView setContentOffset:offset animated:YES];
}

//点击发送评论
-(void) sendCommentWithReReplyIdOne:(Commentuser *)replyUser momentModel:(DFBaseMomentModel *)momentModel text:(NSString *)text
{
    //检查网络
//    if ([DFMomentsManager sharedInstance].networkDisconnected)
//    {
//        [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]];
//        return;
//    }
    //本地创建评论
    CommentModel *commentItem = [[CommentModel alloc] init];
    NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970]*1000;
    long long theTime = [[NSNumber numberWithDouble:nowtime] longLongValue];
    commentItem.ctime = theTime;
    commentItem.commentId = [DFLogicTool createUUID];
    commentItem.commentUser = [[Commentuser alloc]init];
    commentItem.commentUser.uid = [BiChatGlobal sharedManager].uid;
    commentItem.commentUser.nickName = [BiChatGlobal sharedManager].nickName;
    commentItem.commentUser.avatar = [BiChatGlobal sharedManager].avatar;
    commentItem.content = text;
    
    if (replyUser.uid > 0) {
        commentItem.replyUser = [[ReplyUser alloc]init];
        commentItem.replyUser.uid = replyUser.uid;
        commentItem.replyUser.nickName = replyUser.nickName;
    }
    momentModel.cellHeightChange = YES;

    [momentModel.commentList addObject:commentItem];
        //    NSLog(@"_______加入评论——%@",commentItem.content);
    
    [DFMomentsManager insertMomentModel:momentModel atTopOrBottom:@""];
    
    
        //    NSLog(@"_______刷新评论——%@",commentItem.content);
    [self MomentReloadData];
    
    for (int i = 0; i < momentModel.commentList.count; i++) {
        
        CommentModel *comment = momentModel.commentList[i];
            //    NSLog(@"遍历第%d条——%@",i,comment.content);
    }
    
        //    NSLog(@"_______共%lu条",(unsigned long)momentModel.commentList.count);
    
    NSDictionary * dict = @{@"id":commentItem.commentId,
                            @"tokenid":[BiChatGlobal sharedManager].token,
                            @"msgId":momentModel.message.momentId,
                            @"content":text,
                            @"reply_uid":replyUser.uid?replyUser.uid:@""};
    //评论请求
        //    NSLog(@"_______评论请求——%@",commentItem.content);
    [[WPBaseManager baseManager] getInterface:@"Chat/ApiCircleOfFriends/addComment.do" parameters:dict success:^(id response)
     {
         //获取积分socket To林超
         [NetworkModule sendMomentWithType:@{@"type":@"COMMENT"} completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
         }];
             //    NSLog(@"_______评论请求成功——%@",commentItem.content);
         momentModel.isNeedRepComment = YES;
         commentItem.isNeedCommentTwo = YES;

     } failure:^(NSError *error) {
         momentModel.isNeedRepComment = YES;
         commentItem.isNeedCommentTwo = YES;

//         [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]];
     }];
}

//点击评论View 删除评论
-(void) clickCommentViewTwo:(CommentModel *)commentModel momentId:(NSString *)momentId{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameroAction = [[UIAlertAction alloc]init];
    if ([commentModel.commentUser.uid isEqualToString:[BiChatGlobal sharedManager].uid]) {
        
        cameroAction = [UIAlertAction actionWithTitle:LLSTR(@"101018") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self deleteCommentWithCommetnModel:commentModel momentId:momentId];
        }];
    }else{
        cameroAction = [UIAlertAction actionWithTitle:LLSTR(@"104014") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //点击的这条评论的ID 就是要发表的评论中被回复人的ID
            self.dfMomentInputView.hidden = NO;
            self.dfMomentInputView.replyUser = commentModel.commentUser;
            self.dfMomentInputView.momentId = momentId;
            self.dfMomentInputView.momentModel = [DFMomentsManager getMomentModelWithMomentId:momentId];
            [self.dfMomentInputView momentInputViewShow];
            [self.dfMomentInputView setPlaceHolder:[LLSTR(@"104015") llReplaceWithArray:@[commentModel.commentUser.remark]]];
        }];
    }
    
    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:LLSTR(@"101019") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIPasteboard *board = [UIPasteboard generalPasteboard];
        if (commentModel.content.length > 0) {
            board.string = commentModel.content;
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:cameroAction];
    [alertController addAction:copyAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:^{}];
}


-(void)deleteCommentWithCommetnModel:(CommentModel *)commentModel momentId:(NSString *)momentId
{
    
    //检查网络
    if ([DFMomentsManager sharedInstance].networkDisconnected)
    {
        [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]];
        return;
    }
    
    DFBaseMomentModel * model = [DFMomentsManager getMomentModelWithMomentId:momentId];
    
    [model.commentList enumerateObjectsUsingBlock:^(CommentModel * obj, NSUInteger idx, BOOL *stop) {
        if ([obj.commentId isEqualToString:commentModel.commentId]) {
            *stop = YES;
            if (*stop == YES) {
                [model.commentList removeObject:obj];
                model.cellHeightChange = YES;
                
                [self MomentReloadData];
                
                [DFYTKDBManager saveMomentModel:model];//删除评论
            }
        }
        if (*stop) {
                //    NSLog(@"array is arr");
        }
    }];
    
    [[WPBaseManager baseManager] getInterface:@"Chat/ApiCircleOfFriends/delComment.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"id":commentModel.commentId,@"msgId":momentId} success:^(id response) {
        
        if ([[response stringObjectForkey:@"code"] isEqualToString:@"0"]){
            [BiChatGlobal showInfo:LLSTR(@"301401") withIcon:[UIImage imageNamed:@"icon_OK"]];
        }else{
            [BiChatGlobal showInfo:LLSTR(@"301402") withIcon:[UIImage imageNamed:@"icon_alert"]];
        }
    } failure:^(NSError *error) {
        [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]];
    }];
}

-(void)pushWithUrlFromeDFMomentBaseCell:(NSString *)url{
        //    NSLog(@"push%@",url);
    WPNewsDetailViewController *wnd = [WPNewsDetailViewController new];
    wnd.url = url;
    wnd.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:wnd animated:YES];
}

-(void) clickImgOnDFMomentBaseCellWithThumbImgArr:(NSArray *)thumbImgArr displayImgArr:(NSArray *)displayImgArr withTag:(NSInteger)tag withBaseModel:(DFBaseMomentModel *)baseModel
{
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.delegate = self;
    browser.baseModel = baseModel;
    NSMutableArray *photos = [NSMutableArray array];
    
    for (int i=0; i<displayImgArr.count; i++) {
        MJPhoto *photo = [[MJPhoto alloc] init];
        
        id img = [displayImgArr objectAtIndex:i];
        if ([img isKindOfClass:[UIImage class]]) {
            photo.image = img;
            
        }else if ([img isKindOfClass:[NSData class]]){
            
            photo.image = [YYImage yy_imageWithSmallGIFData:img scale:2.0f];
//            UIImage *image = [UIImage imageWithData:img];
//            photo.image = image;
            
        }else if ([img isKindOfClass:[NSString class]]){
            
            NSString * imgStr = [displayImgArr objectAtIndex:i];
            if ([[imgStr substringToIndex:8] isEqualToString:@"imgcache"]) {
                NSString *path = [WPBaseManager fileName:[imgStr substringFromIndex:8] inDirectory:@"dfImage"];
                UIImage * imageeee = [UIImage imageWithContentsOfFile:path];
                photo.image = imageeee;
            }else{
                photo.url = [NSURL URLWithString:imgStr];
                    //    NSLog(@"displayImgArr_%d_%@",i,imgStr);
            }
        }else if ([img isKindOfClass:[LFResultImage class]]){
            LFResultImage * resuImg = img;
            [photo setImage:resuImg.originalImage];
        }
        
        
        photo.placeholderUrl = thumbImgArr[i];
            //    NSLog(@"thumbImgArr_%d_%@",i,thumbImgArr[i]);
        
        [photos addObject:photo];
    }
    
    browser.photos = photos;
    browser.currentPhotoIndex = tag;
    [browser showOnView:self.navigationController.view];
    _isNotAllowBack = YES;
}

-(void)onClickHiddenImage{
    _isNotAllowBack = NO;
}

-(void)clickOpenContentWithMoment:(DFMomentBaseCell *)baseCell
{
    NSIndexPath * indexPath = [self.tableView indexPathForCell:baseCell];
    
    //    DFBaseMomentModel * model = [[DFMomentsManager sharedInstance].moment_arr objectAtIndex:indexPath.row];
    DFBaseMomentModel * model = [_subDataSource objectAtIndex:indexPath.row];
    
    NSString * opStr = @"";
    if (model.isOpen) {
        opStr = LLSTR(@"104019");
        if (model.openHeight) {
            self.tableView.contentOffset = CGPointMake(0, model.openHeight);
        }
    }else{
        opStr = LLSTR(@"104020");
        model.openHeight = self.tableView.contentOffset.y;
    }
    
    model.isOpen = !model.isOpen;
    model.cellHeightChange = YES;
    
    // 滚动到指定位置
    //    if (!model.isOpen) {
    //        NSUInteger index = [[DFMomentsManager sharedInstance].moment_arr indexOfObject:model];
    //        NSIndexPath * indexPath_1=[NSIndexPath indexPathForRow:index inSection:0];
    //
    //        [self.tableView scrollToRowAtIndexPath:indexPath_1 atScrollPosition:UITableViewScrollPositionTop animated:NO];
    //        if (self.tableView.contentOffset.y > 200) {
    //            self.tableView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y - 100);
    //        }
    //    }
    
    [UIView animateWithDuration:0.2 animations:^{
        [self MomentReloadData];
        //        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
}

#pragma mark - BarButtonItem
//基类rightbutton方法
-(void)onLongPressCamera:(UIGestureRecognizer *) gesture
{
    _sendController = [[DFImagesSendViewController alloc]init];
    _sendController.delegate = self;//崩溃
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:_sendController];
    
    //    UIViewController *top = [self topMostController];
    UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    //防止重复弹
    if ([top.presentedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigation = (id)top.presentedViewController;
        if ([navigation.topViewController isKindOfClass:[DFImagesSendViewController class]]) {
            return;
        }
    }
    
    if (top.presentedViewController) {
        //要先dismiss结束后才能重新present否则会出现Warning: Attempt to present <UINavigationController: 0x7fdd22262800> on <UITabBarController: 0x7fdd21c33a60> whose view is not in the window hierarchy!就会present不出来登录页面
        [top.presentedViewController dismissViewControllerAnimated:false completion:^{
            [top presentViewController:navController animated:true completion:nil];
        }];
    }else {
        [top presentViewController:navController animated:true completion:nil];
    }
}

//基类rightbutton手势
-(void)onClickCamera:(id) sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LLSTR(@"101006") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameroAction = [UIAlertAction actionWithTitle:LLSTR(@"101007") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getPicFromeCameraTo:SendMoment_Camera];
    }];
    UIAlertAction *galleryAction = [UIAlertAction actionWithTitle:LLSTR(@"101008") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getpicFromePhotoTo:SendMoment_library withCount:9];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    
    [alertController addAction:cameroAction];
    [alertController addAction:galleryAction];
    [alertController addAction:cancelAction];
    
    if ( [alertController respondsToSelector:@selector(popoverPresentationController)] ) {
        alertController.popoverPresentationController.sourceView = sender;
        alertController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    }
    //崩溃
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)changeCoverImg
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LLSTR(@"101006") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameroAction = [UIAlertAction actionWithTitle:LLSTR(@"101007") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getPicFromeCameraTo:Cover_camero];
    }];
    UIAlertAction *galleryAction = [UIAlertAction actionWithTitle:LLSTR(@"101008") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getPicFromeCameraTo:Cover_library];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:cameroAction];
    [alertController addAction:galleryAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:^{}];
}

-(void)getPicFromeCameraTo:(MomentChoosePic)choosePicType{
    WEAKSELF;

    //是否有权限访问相机
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus == AVAuthorizationStatusDenied)
//        AVAuthorizationStatusRestricted
//    {
//        [[[UIAlertView alloc] initWithTitle:LLSTR(@"106201") message:LLSTR(@"106202") delegate:nil cancelButtonTitle:LLSTR(@"101023") otherButtonTitles:nil] show];
//        return;
//    }
    {

        UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:LLSTR(@"106201") message:LLSTR(@"106202") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * doneAct = [UIAlertAction actionWithTitle:LLSTR(@"101001") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (@available(iOS 8.0, *)){
                if (@available(iOS 10.0, *)){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
                [alertVC dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        
        UIAlertAction * cancelAct = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertVC dismissViewControllerAnimated:YES completion:nil];
            
        }];
        
        [alertVC addAction:doneAct];
        [alertVC addAction:cancelAct];
        [weakSelf presentViewController:alertVC animated:YES completion:nil];
    }
    
    if (choosePicType == Cover_camero) {
        _coverCameraPicker = [[UIImagePickerController alloc] init];
        _coverCameraPicker.delegate = self;
        _coverCameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:_coverCameraPicker animated:YES completion:nil];
    } else if (choosePicType ==  SendMoment_Camera) {

        
        XFCameraController *cameraController = [XFCameraController defaultCameraController];
        //不能拍摄
        cameraController.justPhoto = NO;
        
        __weak XFCameraController *weakCameraController = cameraController;
        
        cameraController.takePhotosCompletionBlock = ^(UIImage *image, NSError *error) {
            NSLog(@"takePhotosCompletionBlock");
            [weakCameraController dismissViewControllerAnimated:YES completion:nil];
            
            _sendController = [[DFImagesSendViewController alloc]init];
            _sendController.sendImagesArr = @[image];
            _sendController.delegate = self;//崩溃
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:_sendController];
            
            //    UIViewController *top = [self topMostController];
            UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
            //防止重复弹
            if ([top.presentedViewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navigation = (id)top.presentedViewController;
                if ([navigation.topViewController isKindOfClass:[DFImagesSendViewController class]]) {
                    return;
                }
            }
            [top presentViewController:navController animated:true completion:nil];
            
        };
        
        cameraController.shootCompletionBlock = ^(NSURL *videoUrl, CGFloat videoTimeLength, UIImage *thumbnailImage, NSError *error) {
            NSLog(@"shootCompletionBlock");
            [weakCameraController dismissViewControllerAnimated:YES completion:nil];

            _sendController = [[DFImagesSendViewController alloc]init];
//            _sendController.sendImagesArr = @[image];

            _sendController.sendVideoUrl = [NSString stringWithFormat:@"%@",videoUrl];
            _sendController.sendVideoImg = thumbnailImage;

            _sendController.delegate = self;//崩溃
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:_sendController];
            
            //    UIViewController *top = [self topMostController];
            UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
            //防止重复弹
            if ([top.presentedViewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navigation = (id)top.presentedViewController;
                if ([navigation.topViewController isKindOfClass:[DFImagesSendViewController class]]) {
                    return;
                }
            }
            [top presentViewController:navController animated:true completion:nil];
        };
        
        [self presentViewController:cameraController animated:YES completion:nil];
        
//        _pickerController = [[UIImagePickerController alloc] init];
//        _pickerController.delegate = self;
//        _pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
//        [self presentViewController:_pickerController animated:YES completion:nil];
    }else if (choosePicType == Cover_library){
        _coverLibraryPicker = [[UIImagePickerController alloc] init];
        _coverLibraryPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _coverLibraryPicker.delegate = self;
        _coverLibraryPicker.allowsEditing = YES;
        [self presentViewController:_coverLibraryPicker animated:YES completion:nil];
    }
}
#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)editingInfo{
//-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary<UIImagePickerController *,id> *)editingInfo{
    if (picker == _coverCameraPicker) {//照相机更换背景
        //        UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
        [self setCoverWithImage:image];
        [_coverCameraPicker dismissViewControllerAnimated:YES completion:nil];
        
        [DFLogicTool updateOneImageWithImageData:UIImageJPEGRepresentation(image, 0.5) success:^(NSArray *imgArr, NSString *jsonStr) {

            [[WPBaseManager baseManager] getInterface:@"Chat/ApiCircleOfFriends/setCircleOfFriendsUserSetting.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"cover":jsonStr} success:^(id response) {
                if ([[response stringObjectForkey:@"code"] isEqualToString:@"0"] && jsonStr.length > 0){
                    [[DFMomentsManager sharedInstance].userCover_dict setObject:jsonStr forKey:[BiChatGlobal sharedManager].uid];
                }
            } failure:^(NSError *error) {
                [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]];
            }];
        } failure:^(NSError *error) {
                //    NSLog(@"发表失败");
        }];
        
    }else if (picker == _pickerController){//照相机发表动态
        [_pickerController dismissViewControllerAnimated:YES completion:nil];
        //        UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
        
        _sendController = [[DFImagesSendViewController alloc]init];
        _sendController.sendImagesArr = @[image];
        _sendController.delegate = self;//崩溃
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:_sendController];
        
        //    UIViewController *top = [self topMostController];
        UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
        //防止重复弹
        if ([top.presentedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigation = (id)top.presentedViewController;
            if ([navigation.topViewController isKindOfClass:[DFImagesSendViewController class]]) {
                return;
            }
        }
        
        //        if (top.presentedViewController) {
        //            //要先dismiss结束后才能重新present否则会出现Warning: Attempt to present <UINavigationController: 0x7fdd22262800> on <UITabBarController: 0x7fdd21c33a60> whose view is not in the window hierarchy!就会present不出来登录页面
        //            [top.presentedViewController dismissViewControllerAnimated:false completion:^{
        //                [top presentViewController:navController animated:true completion:nil];
        //            }];
        //        }else {
        [top presentViewController:navController animated:true completion:nil];
        //        }
    }else if (picker == _coverLibraryPicker){
        //相册更换背景
        //        UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
        [self setCoverWithImage:image];
        [_coverLibraryPicker dismissViewControllerAnimated:YES completion:nil];
        
        [DFLogicTool updateOneImageWithImageData:UIImageJPEGRepresentation(image, 0.5) success:^(NSArray *imgArr, NSString *jsonStr) {
            
            [[WPBaseManager baseManager] getInterface:@"Chat/ApiCircleOfFriends/setCircleOfFriendsUserSetting.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"cover":jsonStr} success:^(id response) {
                if ([[response stringObjectForkey:@"code"] isEqualToString:@"0"] && jsonStr.length > 0){
                    [[DFMomentsManager sharedInstance].userCover_dict setObject:jsonStr forKey:[BiChatGlobal sharedManager].uid];
                }
            } failure:^(NSError *error) {
                [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]];
            }];
        }failure:^(NSError *error) {
                //    NSLog(@"发表失败");
        }];
    }
}

-(void)getpicFromePhotoTo:(MomentChoosePic)choosePicType withCount:(NSInteger)picCount{
    WEAKSELF;
    
    if (choosePicType == Cover_library) {
        
    } else if (choosePicType == SendMoment_library) {
        
        //        _textImgPickerVc = [[MSTImagePickerController alloc] initWithAccessType:MSTImagePickerAccessTypePhotosWithAlbums identifiers:[NSArray array]];
        //        _textImgPickerVc.MSTDelegate = self;
        //        _textImgPickerVc.maxSelectCount = 9;
        //        _textImgPickerVc.numsInRow = 4;
        //        _textImgPickerVc.mutiSelected = YES;
        //        _textImgPickerVc.masking = YES;
        //        _textImgPickerVc.maxImageWidth = 600;
        //        _textImgPickerVc.selectedAnimation = NO;
        //        _textImgPickerVc.themeStyle = 0;
        //        _textImgPickerVc.photoMomentGroupType = 0;
        //        _textImgPickerVc.photosDesc = NO;
        //        _textImgPickerVc.showAlbumThumbnail = YES;
        //        _textImgPickerVc.showAlbumNumber = YES;
        //        _textImgPickerVc.showEmptyAlbum = NO;
        //        _textImgPickerVc.onlyShowImages = YES;
        //        _textImgPickerVc.showLivePhotoIcon = NO;
        //        _textImgPickerVc.firstCamera = NO;
        //        _textImgPickerVc.makingVideo = NO;
        //        _textImgPickerVc.videoAutoSave = NO;
        //        _textImgPickerVc.videoMaximumDuration = 0;
        //        _textImgPickerVc.isHideFullButtonAndImg = YES;
        //        [self presentViewController:_textImgPickerVc animated:YES completion:nil];
        
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        
        if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied)
        {
            
            UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:LLSTR(@"106203") message:LLSTR(@"106204") preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction * doneAct = [UIAlertAction actionWithTitle:LLSTR(@"101001") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (@available(iOS 8.0, *)){
                    if (@available(iOS 10.0, *)){
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                    } else {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }
                    [alertVC dismissViewControllerAnimated:YES completion:nil];
                }
            }];
            
            UIAlertAction * cancelAct = [UIAlertAction actionWithTitle:LLSTR(@"101002") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alertVC dismissViewControllerAnimated:YES completion:nil];
                
            }];
            
            [alertVC addAction:doneAct];
            [alertVC addAction:cancelAct];
            [weakSelf presentViewController:alertVC animated:YES completion:nil];

        }else{
            
            
        _textImgPickerVc = [[LFImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
        //根据需求设置
        _textImgPickerVc.allowTakePicture = NO; //不显示拍照按钮
        _textImgPickerVc.doneBtnTitleStr = LLSTR(@"101001"); //最终确定按钮名称
        _textImgPickerVc.allowPickingGif = YES;
        _textImgPickerVc.allowTakePicture = NO;
        _textImgPickerVc.allowPickingOriginalPhoto = NO;
        _textImgPickerVc.allowPickingVideo = NO;
        _textImgPickerVc.maxVideosCount = 1; /** 解除混合选择- 要么1个视频，要么9个图片 */
        
        _textImgPickerVc.imageCompressSize = 300;
        _textImgPickerVc.thumbnailCompressSize = 0.f;  /**不需要缩略图*/
        
        _textImgPickerVc.oKButtonTitleColorNormal = DFBlue;// 下选中button背景(包括多选边框)
        _textImgPickerVc.oKButtonTitleColorDisabled = [UIColor clearColor];//下未选中button背景
        
        //    _textImgPickerVc.toolbarTitleColorNormal = DFBlue;//下选中button字色
        //    _textImgPickerVc.toolbarTitleColorDisabled = DFBlue;//下未选中的button字色
        _textImgPickerVc.toolbarTitleColorDisabled = [UIColor whiteColor];//下未选中的button字色
        //    _textImgPickerVc.toolbarTitleColorDisabled = THEME_DARKBLUE;//下未选中的button字色
        
        //    _textImgPickerVc.naviBgColor = [UIColor colorWithWhite:0.9 alpha:0.9];//上背景颜色
        //    _textImgPickerVc.naviTitleColor = [UIColor blackColor];//上背景字色
        //    _textImgPickerVc.barItemTextColor  = DFBlue;//上button item字色
        
        //    _textImgPickerVc.toolbarBgColor = [UIColor colorWithWhite:0.9 alpha:0.9];//选择和浏览公用下背景颜色
        //    _textImgPickerVc.previewNaviBgColor  = [UIColor colorWithWhite:0.9 alpha:0.9];//浏览页面上背景颜色
        
        _textImgPickerVc.naviTitleFont = [UIFont systemFontOfSize:18];
        //    _textImgPickerVc.naviTipsFont = [UIFont systemFontOfSize:18];
        _textImgPickerVc.barItemTextFont = [UIFont systemFontOfSize:18];
        _textImgPickerVc.toolbarTitleFont = [UIFont systemFontOfSize:18];
        
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f) {
            _textImgPickerVc.syncAlbum = YES; /** 实时同步相册 */
        }
        [self presentViewController:_textImgPickerVc animated:YES completion:nil];
    }
    }
}
- (void)lf_imagePickerController:(LFImagePickerController *)picker didFinishPickingResult:(NSArray<LFResultObject *> *)results{
    
    NSMutableArray *images = [NSMutableArray array];
    
    for (NSInteger i = 0; i < results.count; i++) {
        LFResultObject *result = results[i];
        if ([result isKindOfClass:[LFResultImage class]]) {
            LFResultImage *resultImage = (LFResultImage *)result;
            
//            if (resultImage.subMediaType == LFImagePickerSubMediaTypeGIF) {
//
//                UIImage * gifImage = [YYImage yy_imageWithSmallGIFData:resultImage.originalData scale:2.0f];
//
//                NSData * littData2 = [gifImage lf_fastestCompressAnimatedImageDataWithScaleRatio:0.8f];
//
////                NSLog(@"%f-%f__",gifImage.size.width,gifImage.size.height);
////                NSLog(@"%lu_%lu",(unsigned long)resultImage.originalData.length,(unsigned long)littData2.length);
//
//                [images addObject:littData2];
//            }else{
//                [images addObject:resultImage.originalImage];
//            }
            
            [images addObject:resultImage];

        }
    }
    
    if (picker == _textImgPickerVc) {//相册发表动态
        
        _sendController = [[DFImagesSendViewController alloc]init];
        _sendController.sendImagesArr = images;
        _sendController.delegate = self;//崩溃
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:_sendController];
        
        //    UIViewController *top = [self topMostController];
        UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
        //防止重复弹
        if ([top.presentedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigation = (id)top.presentedViewController;
            if ([navigation.topViewController isKindOfClass:[DFImagesSendViewController class]]) {
                return;
            }
        }
        
        //        if (top.presentedViewController) {
        //            //要先dismiss结束后才能重新present否则会出现Warning: Attempt to present <UINavigationController: 0x7fdd22262800> on <UITabBarController: 0x7fdd21c33a60> whose view is not in the window hierarchy!就会present不出来登录页面
        //            [top.presentedViewController dismissViewControllerAnimated:false completion:^{
        //                [top presentViewController:navController animated:true completion:nil];
        //            }];
        //        }else {
        [top presentViewController:navController animated:true completion:nil];
        //        }
        
    }
}

#pragma mark - /*MSTImagePickerControllerDelegate*/
//- (void)MSTImagePickerController:(nonnull MSTImagePickerController *)picker didFinishPickingMediaWithArray:(nonnull NSArray <MSTPickingModel *>*)array{
//    NSMutableArray *photos = [NSMutableArray array];
//    for (int i = 0; i < array.count; i ++)
//    {
//        UIImage *image = [array objectAtIndex:i].image;
//        [photos addObject:image];
//        
//        //        UIImage *orignalImage = [array objectAtIndex:i].orignalImage;
//        //        if (orignalImage)
//        //            [arrayTmp addObject:@{@"image":image, @"orignalImage":orignalImage}];
//        //        else
//        //            [arrayTmp addObject:@{@"image":image}];
//    }
//    
//    //        //    NSLog(@"photos%@", photos);
//    if (picker == _textImgPickerVc) {//相册发表动态
//        
//        _sendController = [[DFImagesSendViewController alloc]init];
//        _sendController.sendImagesArr = photos;
//        _sendController.delegate = self;//崩溃
//        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:_sendController];
//        
//        //    UIViewController *top = [self topMostController];
//        UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
//        //防止重复弹
//        if ([top.presentedViewController isKindOfClass:[UINavigationController class]]) {
//            UINavigationController *navigation = (id)top.presentedViewController;
//            if ([navigation.topViewController isKindOfClass:[DFImagesSendViewController class]]) {
//                return;
//            }
//        }
//        
//        //        if (top.presentedViewController) {
//        //            //要先dismiss结束后才能重新present否则会出现Warning: Attempt to present <UINavigationController: 0x7fdd22262800> on <UITabBarController: 0x7fdd21c33a60> whose view is not in the window hierarchy!就会present不出来登录页面
//        //            [top.presentedViewController dismissViewControllerAnimated:false completion:^{
//        //                [top presentViewController:navController animated:true completion:nil];
//        //            }];
//        //        }else {
//        [top presentViewController:navController animated:true completion:nil];
//        //        }
//        
//    }
//}

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //    if ([DFMomentsManager sharedInstance].moment_arr.count == 0) {
    //        return 1;
    //    }else{
    //        return [DFMomentsManager sharedInstance].moment_arr.count;
    //    }
    
    if (_subDataSource.count == 0) {
        return 1;
    }else{
        return _subDataSource.count;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_subDataSource.count == 0) {
        return 100;
    }else{
        DFBaseMomentModel * baseItem = [_subDataSource objectAtIndex:indexPath.row];
        if (baseItem.message.type == MomentSendType_Video) {
            baseItem.cellHeightChange = YES;
        }
        return [DFMomentBaseCell getMomentBaseCellHeight:baseItem isSaveH:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    //    if ([DFMomentsManager sharedInstance].moment_arr.count == 0) {
    if (_subDataSource.count == 0) {
        
        DFNotCell *cell = [tableView dequeueReusableCellWithIdentifier: @"DFNotCell"];
        
        if (cell == nil ) {
            cell = [[DFNotCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DFNotCell"];
        }else{
            
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return cell;
    }else{
        
        DFBaseMomentModel * baseItem = [_subDataSource objectAtIndex:indexPath.row];

        DFMomentBaseCell *cell = [tableView dequeueReusableCellWithIdentifier: @"DFMomentBaseCell"];
        
        if (cell == nil ) {
            cell = [[DFMomentBaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DFMomentBaseCell"];
        }else{
            //            //    NSLog(@"重用Cell: %@", reuseIdentifier);
        }
        cell.delegate = self;
        cell.likeCommentToolbar.hidden = YES;
        cell.separatorInset = UIEdgeInsetsZero;
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            cell.layoutMargins = UIEdgeInsetsZero;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        cell.cellIndexStr = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
        [cell updateWithItem:baseItem];
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //    if ([DFMomentsManager sharedInstance].moment_arr.count != 0) {
    if (_subDataSource.count != 0) {
        
        //点击所有cell空白地方 隐藏toolbar
        NSInteger rows =  [tableView numberOfRowsInSection:0];
        for (int row = 0; row < rows; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            DFMomentBaseCell *cell  = (DFMomentBaseCell *)[tableView cellForRowAtIndexPath:indexPath];
            
            [cell hideLikeCommentToolbar];
        }
    }
}



-(void)moment_arrPaixu{
    //这里类似KVO的读取属性的方法，直接从字符串读取对象属性，注意不要写错
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sorteTime" ascending:NO];
    //这个数组保存的是排序好的对象
    NSArray *tempArray = [[DFMomentsManager sharedInstance].moment_arr sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [DFMomentsManager sharedInstance].moment_arr = [NSMutableArray arrayWithArray:tempArray];
}

-(void)MomentReloadData{
    
//    NSLog(@"MomentReloadData");
    
    [self moment_arrPaixu];
    
    if (!_subIndex) {
        if ([DFMomentsManager sharedInstance].moment_arr.count < 20) {
            _subIndex = [DFMomentsManager sharedInstance].moment_arr.count;
        }else{
            _subIndex = 20;
        }
    }else{
        if (_subIndex > [DFMomentsManager sharedInstance].moment_arr.count) {
            _subIndex = [DFMomentsManager sharedInstance].moment_arr.count;
        }
    }
    
    _subDataSource = [NSMutableArray arrayWithArray:[[DFMomentsManager sharedInstance].moment_arr subarrayWithRange:NSMakeRange(0, _subIndex)]];
    //    _subIndex = _subDataSource.count;
    
    [self.tableView reloadData];
}

-(void)MomentReloadDataMore{
    [self moment_arrPaixu];
    if (_subIndex > [DFMomentsManager sharedInstance].moment_arr.count){
        //超出本地的数据了
        _subIndex = [DFMomentsManager sharedInstance].moment_arr.count;
    }
    _subDataSource = [NSMutableArray arrayWithArray:[[DFMomentsManager sharedInstance].moment_arr subarrayWithRange:NSMakeRange(0, _subIndex)]];
    [self.tableView reloadData];
}

//刷新
-(void)loadNewData
{
    [self getMomentsWithTimeStamp:[DFMomentsManager sharedInstance].loadNewIndex withAction:[NSNumber numberWithInteger:0]];
}

-(void)loadMoreData
{
    [self moment_arrPaixu];
    _subIndex += 20;
    
    if (_subIndex > [DFMomentsManager sharedInstance].moment_arr.count){
        [self getMomentsWithTimeStamp:[DFMomentsManager sharedInstance].loadMoreIndex withAction:[NSNumber numberWithInteger:1]];
    }else{
            //    NSLog(@"还没超出本地数据");
        [self endLoadNew];
        [self endLoadMore];
        
        _subDataSource = [NSMutableArray arrayWithArray:[[DFMomentsManager sharedInstance].moment_arr subarrayWithRange:NSMakeRange(0, _subIndex)]];
        [self.tableView reloadData];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [_coverCameraPicker dismissViewControllerAnimated:YES completion:nil];
    [_pickerController  dismissViewControllerAnimated:YES completion:nil];
    [_coverLibraryPicker  dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - DFVideoCaptureControllerDelegate
-(void)onCaptureVideo:(NSString *)filePath screenShot:(UIImage *)screenShot
{
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [self onSendVideo:@"" videoPath:filePath screenShot:screenShot];
    //    });
}
-(UIView *)remindingView{
    if (!_remindingView) {
        _remindingView = [[UIView alloc]initWithFrame:CGRectMake((ScreenWidth - remindViewWidth)/2, self.tableView.tableHeaderView.frame.size.height - 40, remindViewWidth, 40)];
        _remindingView.backgroundColor = [UIColor colorWithHex:0x000000 alpha:0.75];
        _remindingView.layer.cornerRadius = 5;
        _remindingView.layer.masksToBounds = YES;
        [_remindingView addSubview:self.remindingAvatar];
        [_remindingView addSubview:self.remindingLabel];
        [_remindingView addSubview:self.remindingArrow];
        
        UITapGestureRecognizer * messageTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushRemindingViewController)];
        [_remindingView addGestureRecognizer: messageTap];
    }
    return _remindingView;
}

-(UIImageView *)remindingAvatar{
    if (!_remindingAvatar) {
        _remindingAvatar = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 30, 30)];
        _remindingAvatar.backgroundColor = [UIColor whiteColor];
        [_remindingAvatar sd_setImageWithURL:[NSURL URLWithString:[DFLogicTool getImgWithStr:[BiChatGlobal sharedManager].avatar]]];;
        _remindingAvatar.layer.cornerRadius = 30/2;
        _remindingAvatar.layer.masksToBounds = YES;
    }
    return _remindingAvatar;
}

-(UILabel *)remindingLabel{
    if (!_remindingLabel) {
        _remindingLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 0, remindViewWidth - 40 - 30, 40)];
        _remindingLabel.backgroundColor = [UIColor clearColor];
        _remindingLabel.textAlignment = NSTextAlignmentCenter;
        _remindingLabel.textColor = [UIColor whiteColor];
        _remindingLabel.font = DFFont_Comment_14;
        
        _remindingLabel.text = [LLSTR(@"104006") llReplaceWithArray:@[@"99"]];
    }
    return  _remindingLabel;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//        //    NSLog(@"开始滑动");
    NSArray * cellArr = self.tableView.visibleCells;
    if (cellArr.count > 0) {
        for (DFMomentBaseCell *cell in cellArr) {
            if ([cell isKindOfClass: [DFNotCell class]]) {
                    //    NSLog(@"buguan");
            }else{
                cell.likeCommentToolbar.hidden = YES;
            }
        }
    }
}

-(UIImageView *)remindingArrow{
    if (!_remindingArrow) {
        _remindingArrow = [[UIImageView alloc]initWithFrame:CGRectMake(remindViewWidth-20, (40-15)/2 , 10 , 15)];
        _remindingArrow.backgroundColor = [UIColor clearColor];
        [_remindingArrow setImage:[UIImage imageNamed:@"arrow_right"]];
    }
    return _remindingArrow;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)license:(NSString *)license {
    //扫码登录
    if ([license hasPrefix:@"imChatScanLogin://"]) {
        NSString *loginString = [license substringFromIndex:18];
        [NetworkModule scanLoginWithstring:loginString completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (!success) {
                [BiChatGlobal showInfo:LLSTR(@"301502") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301501") withIcon:[UIImage imageNamed:@"icon_OK"]];
        }];
        return;
    }
    
    //扫码登录公号管理平台
    if ([license hasPrefix:@"imChatManageScanLogin://"]) {
        NSString *loginString = [license substringFromIndex:24];
        [NetworkModule scanPublicManaemengLogingWithstring:loginString completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            if (!success) {
                [BiChatGlobal showInfo:LLSTR(@"301504") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301503") withIcon:[UIImage imageNamed:@"icon_OK"]];
        }];
        return;
    }
    
    //是加入群组
    else if ([license rangeOfString:IMCHAT_GROUPLINK_MARK].length > 0 &&
             [license rangeOfString:IMCHAT_USERLINK_MARK].length > 0)
    {
        NSInteger pt = [license rangeOfString:IMCHAT_GROUPLINK_MARK].location;
        NSString *groupId = [license substringFromIndex:(pt + IMCHAT_GROUPLINK_MARK.length)];
        NSRange range = [groupId rangeOfString:@"&"];
        if (range.length > 0)
            groupId = [groupId substringToIndex:range.location];
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule getGroupProperty:groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            [BiChatGlobal HideActivityIndicator];
            if (success) {
                BOOL inner = NO;
                for (NSDictionary *dict in [data objectForKey:@"groupUserList"]) {
                    if ([[dict objectForKey:@"uid"] isEqualToString:[BiChatGlobal sharedManager].uid]) {
                        inner = YES;
                    }
                }
                if (inner) {
                    for (NSDictionary *item in [[BiChatDataModule sharedDataModule]getChatListInfo]){
                        if ([[item objectForKey:@"isGroup"]boolValue] && [[item objectForKey:@"peerUid"]isEqualToString:groupId]) {
                            //进入聊天界面
                            ChatViewController *wnd = [ChatViewController new];
                            wnd.isGroup = YES;
                            wnd.peerUid = groupId;
                            wnd.peerNickName = [item objectForKey:@"peerNickName"];
                            wnd.hidesBottomBarWhenPushed = YES;
                            [self.navigationController pushViewController:wnd animated:YES];
                            return;
                        }
                    }
                    //没有发现条目，新增一条
                    [NetworkModule getGroupProperty:groupId completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
                        if (success){
                            //添加
                            [[BiChatDataModule sharedDataModule]addChatItem:groupId peerNickName:[data objectForKey:@"groupName"] peerAvatar:[data objectForKey:@"avatar"] isGroup:YES];
                            //进入
                            ChatViewController *wnd = [ChatViewController new];
                            wnd.isGroup = YES;
                            wnd.peerUid = groupId;
                            wnd.peerNickName = [data objectForKey:@"groupName"];
                            wnd.hidesBottomBarWhenPushed = YES;
                            [self.navigationController pushViewController:wnd animated:YES];
                            //添加一条进入群的消息(本地)
                            NSDictionary *myInfo = [NSDictionary dictionaryWithObjectsAndKeys:[BiChatGlobal sharedManager].uid, @"uid", [BiChatGlobal sharedManager].nickName, @"nickName", nil];
                            NSString *msgId = [BiChatGlobal getUuidString];
                            NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", MESSAGE_CONTENT_TYPE_JOINGROUP], @"type",
                                                             [myInfo mj_JSONString], @"content",
                                                             groupId, @"receiver",
                                                             [data objectForKey:@"groupName"], @"receiverNickName",
                                                             [data objectForKey:@"avatar"]==nil?@"":[data objectForKey:@"avatar"], @"receiverAvatar",
                                                             [BiChatGlobal sharedManager].uid, @"sender",
                                                             [BiChatGlobal sharedManager].nickName, @"senderNickName",
                                                             [BiChatGlobal sharedManager].avatar==nil?@"":[BiChatGlobal sharedManager].avatar, @"senderAvatar",
                                                             [[BiChatGlobal sharedManager]getCurrentLoginMobile], @"senderUserName",
                                                             [BiChatGlobal getCurrentDateString], @"time",
                                                             @"1", @"isGroup",
                                                             msgId, @"msgId",
                                                             nil];
                            [wnd appendMessage:sendData];
                            //记录
                            [[BiChatDataModule sharedDataModule]setLastMessage:groupId
                                                                  peerUserName:@""
                                                                  peerNickName:[data objectForKey:@"groupName"]
                                                                    peerAvatar:[data objectForKey:@"avatar"]
                                                                       message:[BiChatGlobal getMessageReadableString:sendData groupProperty:nil]
                                                                   messageTime:[BiChatGlobal getCurrentDateString]
                                                                         isNew:NO isGroup:YES isPublic:NO createNew:NO];
                        } else {
                            [BiChatGlobal showInfo:LLSTR(@"301701") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
                        }
                    }];
                } else {
                    WPGroupAddMiddleViewController *middleVC = [[WPGroupAddMiddleViewController alloc]init];
                    middleVC.groupId = groupId;
                    middleVC.source = [@{@"source": @"APP_CODE"} mj_JSONString];
                    middleVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:middleVC animated:YES];
                }
            }
        }];
    }
    
    //是加朋友？
    else if ([license rangeOfString:IMCHAT_USERLINK_MARK].length > 0)
    {
        NSInteger pt = [license rangeOfString:IMCHAT_USERLINK_MARK].location;
        NSString *userRefCode = [license substringFromIndex:(pt + IMCHAT_USERLINK_MARK.length)];
        NSRange range = [userRefCode rangeOfString:@"&"];
        if (range.length > 0)
            userRefCode = [userRefCode substringToIndex:range.location];
        
        [BiChatGlobal ShowActivityIndicator];
        [NetworkModule getFriendByRefCode:userRefCode completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
            [BiChatGlobal HideActivityIndicator];
            if (success)
            {
                if (![[BiChatGlobal sharedManager]isFriendInContact:[data objectForKey:@"uid"]] &&
                    [[BiChatDataModule sharedDataModule]isChatExist:[data objectForKey:@"uid"]])
                {
                    ChatViewController *wnd = [ChatViewController new];
                    wnd.peerUid = [data objectForKey:@"uid"];
                    wnd.peerNickName = [data objectForKey:@"nickName"];
                    wnd.peerUserName = [data objectForKey:@"userName"];
                    wnd.peerAvatar = [data objectForKey:@"avatar"];
                    wnd.isGroup = NO;
                    wnd.isPublic = NO;
                    wnd.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:wnd animated:YES];
                }
                else
                {
                    UserDetailViewController *wnd = [[UserDetailViewController alloc]init];
                    wnd.uid = [data objectForKey:@"uid"];
                    wnd.userName = [data objectForKey:@"userName"];
                    wnd.nickName = [data objectForKey:@"nickName"];
                    wnd.avatar = [data objectForKey:@"avatar"];
                    wnd.source = @"CODE";
                    wnd.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:wnd animated:YES];
                }
            }
            else
                [BiChatGlobal showInfo:LLSTR(@"301019") withIcon:[UIImage imageNamed:@"icon_alert"] duration:ALERT_MESSAGE_DURATION enableClick:YES];
        }];
    }
    else if ([[license lowercaseString]hasPrefix:@"http://"] ||
             [[license lowercaseString]hasPrefix:@"https://"])
    {
        WPNewsDetailViewController *wnd = [WPNewsDetailViewController new];
        wnd.url = license;
        wnd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wnd animated:YES];
    }
    else {
        TextRenderViewController *wnd = [TextRenderViewController new];
        wnd.navigationItem.title = LLSTR(@"101032");
        wnd.hidesBottomBarWhenPushed = YES;
        wnd.text = license;
        [self.navigationController pushViewController:wnd animated:YES];
    }
}

#pragma mark - ChatSelectDelegate
- (void)chatSelected:(NSArray *)chats withCookie:(NSInteger)cookie andTarget:(id)target {
    if (chats.count == 0){
        return;
    }
    //需要发送的内容
    NSString *str4Content;
    if (cookie == 1)
        str4Content = [NSString stringWithFormat:@"%@：%@",
                       [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[target objectForKey:@"sender"] groupProperty:nil nickName:[target objectForKey:@"senderNickName"]],
                       [BiChatGlobal getMessageReadableString:target groupProperty:nil]];
    
    //计算内容需要的空间
    CGRect rect = [str4Content boundingRectWithSize:CGSizeMake(270, 300)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: DFFont_Comment_14}
                                            context:nil];
    
    //限制高度
    if (rect.size.height > 110)
        rect.size.height = 110;
    
    //显示转发提示界面
    UIView *view4ForwardPrompt = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 225 + rect.size.height)];
    view4ForwardPrompt.backgroundColor = [UIColor whiteColor];
    view4ForwardPrompt.layer.cornerRadius = 5;
    view4ForwardPrompt.clipsToBounds = YES;
    
    //title
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, 200, 20)];
    label4Title.font = DFFont_NameFont_16;
    [view4ForwardPrompt addSubview:label4Title];
    
    //对方是一个公号
    if ([[BiChatGlobal sharedManager]isFriendInFollowList:[[chats firstObject]objectForKey:@"peerUid"]] ||
        [[[chats firstObject]objectForKey:@"isPublic"]boolValue])
        label4Title.text = LLSTR(@"102425");
    else if ([[[chats firstObject]objectForKey:@"isGroup"]boolValue])
        label4Title.text = LLSTR(@"102424");
    else
        label4Title.text = LLSTR(@"102423");
    
    //对方avatar
    UIView *view4PeerAvatar = [BiChatGlobal getAvatarWnd:[[chats firstObject]objectForKey:@"peerUid"]
                                                nickName:[[chats firstObject]objectForKey:@"peerNickName"]
                                                  avatar:[[chats firstObject]objectForKey:@"peerAvatar"]
                                                   width:40 height:40];
    view4PeerAvatar.center = CGPointMake(35, 65);
    [view4ForwardPrompt addSubview:view4PeerAvatar];
    
    //对方nickname
    UILabel *label4PeerNickName = [[UILabel alloc]initWithFrame:CGRectMake(65, 45, 220, 40)];
    label4PeerNickName.text = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[[chats firstObject]objectForKey:@"peerUid"]
                                                                          groupProperty:nil
                                                                               nickName:[[chats firstObject]objectForKey:@"peerNickName"]];
    //是否是客服群
    if ([[[chats firstObject]objectForKey:@"applyUser"]length] > 0)
        label4PeerNickName.text = [NSString stringWithFormat:@"%@_%@", label4PeerNickName.text, [[chats firstObject]objectForKey:@"applyUserNickName"]];
}

@end
