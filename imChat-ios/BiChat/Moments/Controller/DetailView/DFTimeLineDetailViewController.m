//
//  DFTimeLineDetailViewController.m
//  BiChat Dev
//
//  Created by chat on 2018/9/3.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "DFTimeLineDetailViewController.h"

#import "DFMomentBaseCell.h"
#import "DFMomentInputView.h"
#import "DFDetailMomentCell.h"
#import "DFDetailPraiseCell.h"
#import "DFDetailCommentCell.h"

#import "DFMomentViewController.h"
#import "WPNewsDetailViewController.h"
#import "UserDetailViewController.h"
#import "IQKeyboardManager.h"


@interface DFTimeLineDetailViewController ()<DFDetailMomentCellDelegate,UITableViewDelegate,UITableViewDataSource,DFMomentInputViewDelegate,DFDetailPraiseCellDelegate,DFDetailCommentCellDelegate>

@property (nonatomic,strong) UITableView * detailTableView;
@property (strong, nonatomic) DFMomentInputView * dfMomentInputView;

@end

@implementation DFTimeLineDetailViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = RGB(0x4699f4);
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    //取消导航栏透明设置
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//
//    self.navigationController.navigationBar.tintColor = RGB(0xffffff);
//    //    [self.navigationController setNavigationBarHidden:YES animated:YES];
//
//    //导航栏透明设置
//    self.navigationController.navigationBar.translucent = YES;
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    //取消导航栏透明设置
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    //恢复标题栏
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = nil;
    self.navigationController.navigationBar.tintColor = THEME_COLOR;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    
    self.navigationController.navigationBar.alpha = 1;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LLSTR(@"104012");
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (_detailModel) {
        [self.view addSubview:self.detailTableView];
//        [self.view addSubview:self.dfMomentInputView];
    }else{
        [[WPBaseManager baseManager] getInterface:@"Chat/ApiCircleOfFriends/getMessage.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"id":self.detailModelId} success:^(id response) {
            if ([[response stringObjectForkey:@"code"] isEqualToString:@"0"]){
                
                NSDictionary * dataDic = [response objectForKey:@"data"];
                DFBaseMomentModel * itModel = [DFBaseMomentModel mj_objectWithKeyValues:dataDic];

                [DFMomentsManager addMediasFromeModel:itModel];
                [DFMomentsManager getLikeOrNotLike:itModel];
                
                self.detailModel = itModel;
                [self.view addSubview:self.detailTableView];
//                [self.view addSubview:self.dfMomentInputView];
            }else{
                [BiChatGlobal showInfo:LLSTR(@"301403") withIcon:[UIImage imageNamed:@"icon_alert"]];
            }
        } failure:^(NSError *error) {
            [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]];
        }];
    }
}


-(void)DFDetailMomentCellToPlayVideoWithMoment:(DFBaseMomentModel *)moment{
    
    NSLog(@"代理过来了，准备播放");
    
    ZFFullScreenViewController * zfull = [[ZFFullScreenViewController alloc]init];
    
    NSDictionary * resourceDic = moment.message.mediasList[0];
    
    //    NSDictionary * resourceDic = [DFLogicTool JsonStringToDictionary:moment.message.mediasList[0]];
    
    NSString * videoUrl = [DFLogicTool getImgWithStr:[resourceDic objectForKey:@"medias_display"]];
    
    if (videoUrl.length > 0) {
        zfull.playVideoUrl = videoUrl;
    }else{
        zfull.playVideoUrl = moment.videoUrlStr;
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

-(DFMomentInputView *)dfMomentInputView{
    if (!_dfMomentInputView) {
        _dfMomentInputView = [[DFMomentInputView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _dfMomentInputView.delegate = self;
        _dfMomentInputView.hidden = YES;
        [self.view addSubview:_dfMomentInputView];
    }
    return _dfMomentInputView;
}

-(UITableView *)detailTableView{
    if (!_detailTableView) {
        
        _detailTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, (isIphonex ? 88 : 64), ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64) ) style:UITableViewStylePlain];
        _detailTableView.backgroundColor = [UIColor whiteColor];
        _detailTableView.delegate = self;
        _detailTableView.dataSource = self;
        _detailTableView.separatorInset = UIEdgeInsetsZero;
        
        _detailTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if ([_detailTableView respondsToSelector:@selector(setLayoutMargins:)]) {
            _detailTableView.layoutMargins = UIEdgeInsetsZero;
        }
        
        _detailTableView.tableHeaderView = nil;
        _detailTableView.tableFooterView = [[UIView alloc]init];
     
        _detailTableView.estimatedRowHeight = 0;
        _detailTableView.estimatedSectionHeaderHeight = 0;
        _detailTableView.estimatedSectionFooterHeight = 0;
    }
    return _detailTableView;
}

#pragma mark - TabelViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1 + 1 +_detailModel.commentList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return [DFDetailMomentCell getReuseableCellHeight:_detailModel];
    }else if (indexPath.row == 1){
        return [DFDetailPraiseCell getCollectionHeightWithModel:_detailModel];
    }else{
        DFDetailCommentCell * commentCell = [[DFDetailCommentCell alloc]init];
        return [commentCell getCommentHeightWithModel:_detailModel.commentList[indexPath.row - 2]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        DFDetailMomentCell *cell = [tableView dequeueReusableCellWithIdentifier: @"DFDetailMomentCell"];
        if (cell == nil ) {
            cell = [[[DFDetailMomentCell class] alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DFDetailMomentCell"];
        }
        
        [cell updateWithItem:_detailModel];
        cell.likeCommentView.hidden = YES;
        cell.delegate = self;
        cell.separatorInset = UIEdgeInsetsZero;
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) cell.layoutMargins = UIEdgeInsetsZero;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }else if (indexPath.row == 1){
        DFDetailPraiseCell *cell = [tableView dequeueReusableCellWithIdentifier: @"DFDetailPraiseCell"];
        if (cell == nil ) {
            cell = [[[DFDetailPraiseCell class] alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DFDetailPraiseCell"];
        }
        //        cell.delegate = self;
        cell.separatorInset = UIEdgeInsetsZero;
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) cell.layoutMargins = UIEdgeInsetsZero;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        [cell updatePraiseWithModel:_detailModel];
        return cell;
    }else{
        DFDetailCommentCell *cell = [tableView dequeueReusableCellWithIdentifier: @"DFDetailCommentCell"];
        if (cell == nil ) {
            cell = [[[DFDetailCommentCell class] alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DFDetailCommentCell"];
        }
        
        if (indexPath.row == 2) {
            cell.commentIcon.hidden = NO;
        }else{
            cell.commentIcon.hidden = YES;
        }
        cell.delegate = self;
        [cell updateCommentWithModel:_detailModel.commentList[indexPath.row - 2]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

//点赞跳转
-(void)clickPraiseCellOnDFDetailPraiseCellWithId:(NSString *)userId
{
    [self pushUserDetailWithUserId:userId];
}

#pragma mark - 点击头像或者名称跳转
-(void)onClickAvatarOnCellLeftBtn:(NSString *)userId{
    [self pushUserDetailWithUserId:userId];
 }

//跳转个人
-(void)clickNameAndAvavtarWithId:(NSString *)userId{
    [self pushUserDetailWithUserId:userId];
}
//跳转网页
-(void)pushUserDetailWithUserId:(NSString *)userId{
    UserDetailViewController * userVC = [[UserDetailViewController alloc]init];
    userVC.uid = userId;
    [self.navigationController pushViewController:userVC animated:YES];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > 1) {
        if (_detailModel.commentList.count) {
            CommentModel * commentModel = _detailModel.commentList[indexPath.row - 2];
            if (indexPath.row > 1) {
                [self clickCommentViewTwo:commentModel momentId:_detailModel.message.momentId];
            }
        }
    }
}

//删除我发表的动态
-(void)deleteMomentWithMoment:(DFBaseMomentModel*)moment
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameroAction = [UIAlertAction actionWithTitle:LLSTR(@"104013") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self deleteMoment:_detailModel];
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

    //删除朋友圈请求
    [[WPBaseManager baseManager] getInterface:@"Chat/ApiCircleOfFriends/delMessage.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"id":_detailModel.message.momentId} success:^(id response) {
        if ([[response stringObjectForkey:@"code"] isEqualToString:@"0"]){
            
            [[DFMomentsManager sharedInstance].moment_arr enumerateObjectsUsingBlock:^(DFBaseMomentModel * obj, NSUInteger idx, BOOL *stop) {
                if ([obj.message.momentId isEqualToString:moment.message.momentId]) {
                    *stop = YES;
                    if (*stop == YES) {
                        [[DFMomentsManager sharedInstance].moment_arr removeObject:obj];
                        [[DFMomentsManager sharedInstance].moment_dict removeObjectForKey:moment.message.momentId];
                        [DFYTKDBManager deleteModelWithId:moment.message.momentId fromeTab:MomentTab];
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_MOMENT_TYPE_RELOADDATA object:nil];

//                        for (UIViewController *controller in self.navigationController.viewControllers) {
//                            if ([controller isKindOfClass:[DFMomentViewController class]]) {
//                                [self.navigationController popToViewController:controller animated:YES];
//                            }
//                        }
                        [self.navigationController popViewControllerAnimated:YES];

                        [BiChatGlobal showInfo:LLSTR(@"301403") withIcon:[UIImage imageNamed:@"icon_OK"]];
                    }else{
                        [BiChatGlobal showInfo:LLSTR(@"301404") withIcon:[UIImage imageNamed:@"icon_alert"]];
                    }
                }
                if (*stop) {
                        //    NSLog(@"array is dataSource");
                }
            }];
        }
    } failure:^(NSError *error) {
        [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]];
    }];
}

#pragma mark - 点赞响应
-(void)on3LikeFromeLineCell:(DFBaseMomentModel *)baseModel
//{
//        //    NSLog(@"[_detailTableView reloadData];");
//    [_detailTableView reloadData];
//}
{
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

    [DFMomentsManager addlikeTestWithModel:baseModel IsPrais:baseModel.message.isPrais];
    [_detailTableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_MOMENT_TYPE_RELOADDATA object:nil];

    [[WPBaseManager baseManager] getInterface:netUrl parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"msgId":baseModel.message.momentId} success:^(id response) {

    } failure:^(NSError *error) {
        [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]];
    }];
}

#pragma mark - 评论流程
//点击评论btn
-(void)clickCommentButtonTwo:(DFBaseMomentModel *)momentModel{
    self.dfMomentInputView.hidden = NO;
    self.dfMomentInputView.replyUser = nil;
    self.dfMomentInputView.momentModel = momentModel;
    self.dfMomentInputView.momentId = momentModel.message.momentId;
    [self.dfMomentInputView momentInputViewShow];
}

//点击发送评论
-(void) sendCommentWithReReplyIdOne:(Commentuser *)replyUser momentModel:(DFBaseMomentModel *)momentModel text:(NSString *) text{
    
    //检查网络
//    if ([DFMomentsManager sharedInstance].networkDisconnected)
//    {
//        [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]];
//        return;
//    }

    CommentModel *commentItem = [[CommentModel alloc] init];
    commentItem.ctime = [[NSDate date] timeIntervalSince1970]*1000;
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

    _detailModel = momentModel;
    [_detailTableView reloadData];
    
//    滚动暂时不设置
//    if (  (2 + _detailModel.commentList.count-1) > 0) {
//        <#statements#>
//    }
    [_detailTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:2 + _detailModel.commentList.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    //这里一定要设置为NO，动画可能会影响到scrollerView
    
    [DFMomentsManager insertMomentModel:momentModel atTopOrBottom:@""];

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_MOMENT_TYPE_RELOADDATA object:nil];
    
    NSDictionary * dict = @{@"id":commentItem.commentId,
                            @"tokenid":[BiChatGlobal sharedManager].token,
                            @"msgId":_detailModel.message.momentId,
                            @"content":text,
                            @"reply_uid":replyUser.uid?replyUser.uid:@""};
    //评论请求
    [[WPBaseManager baseManager] getInterface:@"Chat/ApiCircleOfFriends/addComment.do" parameters:dict success:^(id response)
     {
         //获取积分socket To林超
         [NetworkModule sendMomentWithType:@{@"type":@"COMMENT"} completedBlock:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
         }];
             //    NSLog(@"创建评论成功");
     } failure:^(NSError *error) {
         [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]];
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
        
        if (_detailModel.message.isFriend) {
            cameroAction = [UIAlertAction actionWithTitle:LLSTR(@"104014") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //点击的这条评论的ID 就是要发表的评论中被回复人的ID
                self.dfMomentInputView.hidden = NO;
                self.dfMomentInputView.replyUser = commentModel.commentUser;
                self.dfMomentInputView.momentId = momentId;
                
                DFBaseMomentModel * model = [DFMomentsManager getMomentModelWithMomentId:momentId];
                
                if (!model) {
                    model = self.detailModel;
                }
                
                self.dfMomentInputView.momentModel = model;
                [self.dfMomentInputView momentInputViewShow];
                [self.dfMomentInputView setPlaceHolder:[LLSTR(@"104015") llReplaceWithArray:@[commentModel.commentUser.remark]]];
            }];
        }
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
    
    if (!model) {
        model = self.detailModel;
    }
    [model.commentList enumerateObjectsUsingBlock:^(CommentModel * obj, NSUInteger idx, BOOL *stop) {
        if ([obj.commentId isEqualToString:commentModel.commentId]) {
            *stop = YES;
            if (*stop == YES) {
                [model.commentList removeObject:obj];
                model.cellHeightChange = YES;
                
                _detailModel = model;
                [_detailTableView reloadData];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_MOMENT_TYPE_RELOADDATA object:nil];
                [DFYTKDBManager saveMomentModel:model];//删除评论
            }
        }
        if (*stop) {
                //    NSLog(@"array is arr");
        }
    }];
    
    [[WPBaseManager baseManager] getInterface:@"Chat/ApiCircleOfFriends/delComment.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"id":commentModel.commentId,@"msgId":_detailModel.message.momentId} success:^(id response) {
        if ([[response stringObjectForkey:@"code"] isEqualToString:@"0"]){
            [BiChatGlobal showInfo:LLSTR(@"301401") withIcon:[UIImage imageNamed:@"icon_OK"]];
        }else{
            [BiChatGlobal showInfo:LLSTR(@"301402") withIcon:[UIImage imageNamed:@"icon_alert"]];
        }
    } failure:^(NSError *error) {
        [BiChatGlobal showInfo:LLSTR(@"301001") withIcon:[UIImage imageNamed:@"icon_alert"]];
    }];
}


-(void) clickImgOnDFDetailMomentCellWithThumbImgArr:(NSArray *)thumbImgArr displayImgArr:(NSArray *)displayImgArr withTag:(NSInteger)tag withBaseModel:(DFBaseMomentModel *)baseModel
{
    //    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:[thumbImgArr objectAtIndex:tag]] options:SDWebImageDownloaderHighPriority  progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
    //            //    NSLog(@"receivedSize_%ld-expectedSize_%ld-%@",(long)receivedSize,(long)expectedSize,[NSString stringWithFormat:@"%@",targetURL]);
    //    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
    //            //    NSLog(@"小图下载成功");
    //    }];
    
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
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
        [photos addObject:photo];
    }
    
    browser.photos = photos;
    browser.currentPhotoIndex = tag;
    [browser showOnView:self.navigationController.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)pushWithUrlFromeDFDetailMomentCell:(NSString *)url
{
    
    WPNewsDetailViewController *wnd = [WPNewsDetailViewController new];
    wnd.url = url;
    [self.navigationController pushViewController:wnd animated:YES];
}

-(void)pushWithUrlFromeDFDetailCommentCell:(NSString *)url{
    WPNewsDetailViewController *wnd = [WPNewsDetailViewController new];
    wnd.url = url;
    [self.navigationController pushViewController:wnd animated:YES];
}

@end
