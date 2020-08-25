//
//  DFPublicBaseViewController.m
//  DFTimelineView
//
//  Created by 豆凯强 on 17/10/15.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#import "DFPublicBaseViewController.h"

#define TableHeaderHeight 380*([UIScreen mainScreen].bounds.size.width / 375.0)
#define CoverHeight 280*([UIScreen mainScreen].bounds.size.width / 375.0)

#define AvatarSize 70*([UIScreen mainScreen].bounds.size.width / 375.0)
#define AvatarRightMargin 10
#define AvatarPadding 2

#define NickFont [UIFont systemFontOfSize:18]

#define SignFont [UIFont systemFontOfSize:12]

@interface DFPublicBaseViewController()

@property (nonatomic, strong) UIImageView *coverView;

@property (nonatomic, strong) UIImageView *userAvatarView;

@property (nonatomic, strong) UILabel *userNickView;

@property (nonatomic, strong) UILabel *userSignView;

@property (nonatomic, assign) BOOL isLoadingMore;

@property (nonatomic,strong) UITapGestureRecognizer  * coverTapGes;
@property (nonatomic,strong) UITapGestureRecognizer  * avatarTap;
@property (nonatomic,strong) UILongPressGestureRecognizer  * rightTap;

@end

@implementation DFPublicBaseViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _isLoadingMore = NO;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];

    [self.view addSubview:self.tableView];
    
#ifdef __IPHONE_9_0
    if(self.traitCollection.forceTouchCapability==UIForceTouchCapabilityAvailable){
        [self registerForPreviewingWithDelegate:self sourceView:self.tableView];
    }
#endif
    [self initHeader];
}

-(void)dealloc{
    if (_coverTapGes) {
        _coverTapGes = nil;
    }
    if (_rightTap) {
        _rightTap = nil;
    }
    if (_avatarTap) {
        _avatarTap = nil;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //第一次进入时 btn和导航栏预设 因为不滑动 不会走滑动方法内的设置
    if (self.tableView.contentOffset.y > 200) {
        [self.rightButton setImage:[UIImage imageNamed:@"cameraBlack"] forState:UIControlStateNormal];
        
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
        self.navigationController.navigationBar.tintColor = RGB(0x000000);
        
        //取消导航栏透明设置
        //        self.navigationController.navigationBar.translucent = NO;
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:nil];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
        
        if (self.tableView.contentOffset.y <= 300) {
            CGFloat alpha = (self.tableView.contentOffset.y - 200)/100;
            self.navigationController.navigationBar.alpha = alpha;
        }else{
            self.navigationController.navigationBar.alpha = 1;
        }
    }else{
        
        [self.rightButton setImage:[UIImage imageNamed:@"cameraWhite"] forState:UIControlStateNormal];
        
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        self.navigationController.navigationBar.tintColor = RGB(0xffffff);
        
        //导航栏透明设置
        self.navigationController.navigationBar.translucent = YES;
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        
        if (self.tableView.contentOffset.y >= 100) {
            CGFloat alpha = (1 - (self.tableView.contentOffset.y - 100)/100);
            self.navigationController.navigationBar.alpha = alpha;
        }else{
            self.navigationController.navigationBar.alpha = 1;
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
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

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -(isIphonex ? 88 : 64), ScreenWidth, ScreenHeight + (isIphonex ? 88 : 64) + IPX_BOTTOM_SAFE_H) style:UITableViewStylePlain];
        //_tableView.backgroundColor = [UIColor darkGrayColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.tableFooterView=[[UIView alloc]init];
        //    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
        // 设置自动切换透明度(在导航栏下面自动隐藏)
        header.automaticallyChangeAlpha = YES;
        // 隐藏时间
        header.lastUpdatedTimeLabel.hidden = YES;
        _tableView.mj_header = header;
        
        _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
        
        if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            _tableView.layoutMargins = UIEdgeInsetsZero;
        }
        
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
    }
    return _tableView;
}

-(void) initHeader
{
    CGFloat x,y,width, height;
    x=0;
    y=0;
    width = self.view.frame.size.width;
    height = TableHeaderHeight;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    _tableView.tableHeaderView = headerView;
    
    //封面
    height = CoverHeight;
    
    [self.coverView addGestureRecognizer:self.coverTapGes];
    
    self.coverWidth  = width*2;
    self.coverHeight = height*2;
    [headerView addSubview:_coverView];
    
    //用户头像
    x = self.view.frame.size.width - AvatarRightMargin - AvatarSize;
    y = _coverView.frame.size.height - AvatarSize/2;
    width = AvatarSize;
    height = width;
    
    _userAvatarView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    _userAvatarView.layer.cornerRadius = _userAvatarView.frame.size.width/2;
    _userAvatarView.layer.masksToBounds = YES;
    _userAvatarView.backgroundColor = [UIColor clearColor];
    _userAvatarView.userInteractionEnabled = YES;

    [_userAvatarView addGestureRecognizer:self.avatarTap];
    
    [headerView addSubview:_userAvatarView];
    //    [avatarBg addSubview:_userAvatarView];
    self.userAvatarSize = width*2;
    
    //用户昵称
    if (_userNickView == nil) {
        _userNickView = [[UILabel alloc] initWithFrame:CGRectZero];
        _userNickView.textColor = [UIColor whiteColor];
        _userNickView.font = NickFont;
        _userNickView.numberOfLines = 1;
        _userNickView.adjustsFontSizeToFitWidth = NO;
//        _userNickView.lineBreakMode = NSLineBreakByTruncatingTail;
        [headerView addSubview:_userNickView];
    }
    
    //用户签名
    if (_userSignView== nil) {
        _userSignView = [[UILabel alloc] initWithFrame:CGRectZero];
        _userSignView.textColor = [UIColor lightGrayColor];
        _userSignView.font = SignFont;
        _userSignView.numberOfLines = 1;
        _userSignView.adjustsFontSizeToFitWidth = NO;
        [headerView addSubview:_userSignView];
    }
}

-(UIImageView *)coverView{
    if (!_coverView) {
        _coverView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CoverHeight)];
        _coverView.backgroundColor = [UIColor darkGrayColor];
        _coverView.userInteractionEnabled = YES;
        _coverView.contentMode = UIViewContentModeScaleAspectFill;
        _coverView.layer.masksToBounds = YES;
    }
    return _coverView;
}

-(UITapGestureRecognizer *)coverTapGes{
    if (!_coverTapGes) {
        _coverTapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeCoverImg)];
    }
    return _coverTapGes;
}

-(UITapGestureRecognizer *)avatarTap{
    if (!_avatarTap) {
        _avatarTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickAvatarOnHeadView)];
    }
    return _avatarTap;
}

-(UILongPressGestureRecognizer *)rightTap{
    if (!_rightTap) {
        _rightTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressCamera:)];
    }
    return _rightTap;
}

#pragma mark - TabelViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - PullMoreFooterDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_isLoadingMore) {
        return;
    }

    if (scrollView.contentOffset.y > 200) {
        [_rightButton setImage:[UIImage imageNamed:@"cameraBlack"] forState:UIControlStateNormal];

        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
        self.navigationController.navigationBar.tintColor = RGB(0x000000);

        //取消导航栏透明设置
//        self.navigationController.navigationBar.translucent = NO;
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:nil];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];

        if (scrollView.contentOffset.y <= 300) {
            CGFloat alpha = (scrollView.contentOffset.y - 200)/100;
            self.navigationController.navigationBar.alpha = alpha;
        }else{
            self.navigationController.navigationBar.alpha = 1;
        }
    }else{
        
        [_rightButton setImage:[UIImage imageNamed:@"cameraWhite"] forState:UIControlStateNormal];

        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        self.navigationController.navigationBar.tintColor = RGB(0xffffff);

        //导航栏透明设置
        self.navigationController.navigationBar.translucent = YES;
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
        if (scrollView.contentOffset.y >= 100) {
            CGFloat alpha = (1 - (scrollView.contentOffset.y - 100)/100);
            self.navigationController.navigationBar.alpha = alpha;
        }else{
            self.navigationController.navigationBar.alpha = 1;
        }
    }
}

-(UIButton *)rightButton{
    if (!_rightButton) {
        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//        [_rightButton setImage:[UIImage imageNamed:@"cameraBlack"] forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(onClickCamera:) forControlEvents:UIControlEventTouchUpInside];
        [_rightButton addGestureRecognizer:self.rightTap];
    }
    return _rightButton;
}

-(void) onClickCamera:(id) sender{
    
}

-(void)onLongPressCamera:(UIGestureRecognizer *) gesture
{
    
}

-(void)changeCoverImg{
    
}

-(void)loadNewData
{
    
}

-(void)loadMoreData
{
    
}

-(void)endLoadNew
{
    [_tableView.mj_header endRefreshing];
}

-(void)endLoadMore
{
    [_tableView.mj_footer endRefreshing];
}

#pragma mark - Method
-(void)setOwnCover:(NSString *)url
{
//    NSString * userCover2 = [[DFYTKDBManager sharedInstance].store getStringById:TabKey_UserCover fromTable:OtherTab];
//    if (userCover2.length > 0) {
//        //有老图片先显示原来的图片
//        [_coverView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[DFLogicTool getImgWithStr:userCover2]]]]];
//    }else{
        [_coverView sd_setImageWithURL:[NSURL URLWithString:url]];
//    }
}

-(void)setOtherCover:(NSString *)url
{
    [_coverView sd_setImageWithURL:[NSURL URLWithString:url]];
}

-(void)setCoverWithImage:(UIImage *)img
{
    [_coverView setImage:img];
}

-(void) setUserAvatar:(NSString *) url withName:(NSString *)userName
{
    [_userAvatarView setImageWithURL:url title:userName size:CGSizeMake(40, 40) placeHolde:nil color:nil textColor:nil];
}

-(void)setUserNick:(NSString *)nick
{
    CGFloat x, y, width, height;
    
    NSMutableAttributedString * attrStr = [nick DFTransEmotionWithFont:NickFont];

    CGSize size = [DFAttStringManager getHeightWithContent:attrStr withWidth:320].size;

    if (size.width > (ScreenWidth - _userAvatarView.frame.size.width - 20)) {
        size.width = ScreenWidth - _userAvatarView.frame.size.width - 20;
    }
    
    width = size.width;
    height = size.height;
    x = CGRectGetMinX(_userAvatarView.frame) - width - 10;
    y = CGRectGetMidY(_userAvatarView.frame) - 22 - 5;
    
    if (x <= 0) {
        x = 5;
    }
    
    _userNickView.frame = CGRectMake(x, y, width, 22);
    _userNickView.text = nick;
    _userNickView.backgroundColor = [UIColor clearColor];
}

-(void)setUserSign:(NSString *)sign
{
    
    NSMutableAttributedString * attrStr = [sign DFTransEmotionWithFont:SignFont];

    CGSize size = [DFAttStringManager getHeightWithContent:attrStr withWidth:320].size;
    
    _userSignView.frame = CGRectMake(5, CGRectGetMaxY(_coverView.frame) + 5, ScreenWidth - _userAvatarView.frame.size.width-25, size.height);
    _userSignView.numberOfLines = 0;
    _userSignView.textAlignment = NSTextAlignmentRight;
    _userSignView.text = sign;
    _userSignView.backgroundColor = [UIColor clearColor];
}

-(void)onClickAvatarOnHeadView
{
        //    NSLog(@"点击自己头像1");
}

@end
