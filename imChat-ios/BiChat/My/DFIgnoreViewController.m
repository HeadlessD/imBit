//
//  DFIgnoreViewController.m
//  BiChat
//
//  Created by chat on 2018/9/12.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "DFIgnoreViewController.h"

@interface DFIgnoreViewController ()

@end

@implementation DFIgnoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"不看他／她的";
    self.view.backgroundColor = [UIColor whiteColor];
    [NetworkModule getMyPrivacyProfile:^(BOOL success, BOOL isTimeOut, NSInteger errorCode, id  _Nullable data) {
        
        
        NSArray * ignoreMomentArr = [[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"ignoreMoment"];
        //        NSArray * blockMomentArr = [[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"blockMoment"];
        //        if (ignoreMomentArr.count) {
        //            for (NSDictionary * ignoreDic in ignoreMomentArr) {
        //                NSString * ignoreId = [ignoreDic objectForKey:@"uid"];
        //                if ([ignoreId isEqualToString:self.uid]) {
        //                    self.ignoreView.mySwitch.on = YES;
        //                }else{
        //                    self.ignoreView.mySwitch.on = NO;
        //                }
        //            }
        //        }
        
        //        NSArray * ignoreMomentArr = [[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"ignoreMoment"];
        NSArray * blockMomentArr = [[BiChatGlobal sharedManager].dict4MyPrivacyProfile objectForKey:@"blockMoment"];
        //        if (blockMomentArr.count) {
        //            for (NSDictionary * blockDic in blockMomentArr) {
        //                NSString * blockId = [blockDic objectForKey:@"uid"];
        //                if ([blockId isEqualToString:self.uid]) {
        //                    self.blockView.mySwitch.on = YES;
        //                }else{
        //                    self.blockView.mySwitch.on = NO;
        //                }
        //            }
        //        }
        
    }];
}




-(void)createView{
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.backView];
    [_backView addSubview:self.praiseView];
    [_backView addSubview:self.atCollectionView];
    
    [_backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.bottom.mas_equalTo(0);
    }];
    
    [_praiseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(25);
        make.left.mas_equalTo(15);
        make.width.mas_equalTo(15);
        make.height.mas_equalTo(14);
    }];
    
    [_atCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15);
        make.left.mas_equalTo(40);
        make.width.mas_equalTo(collectW*8);
        //        make.right.mas_equalTo(-10);
        make.bottom.mas_equalTo(-5);
    }];
}

+(CGFloat)getCollectionHeightWithModel:(DFBaseMomentModel *)model
{
    if (model.praiseList.count == 0) {
        return 0;
    }else{
        NSInteger  count = model.praiseList.count/8;
        return collectW * (count+1) +20;
    }
}

-(void)updatePraiseWithModel:(DFBaseMomentModel*)momentModel{
    self.momentModel = momentModel;
    
    if (momentModel.praiseList.count) {
        _praiseView.hidden = NO;
    }else{
        _praiseView.hidden = YES;
    }
    [_atCollectionView reloadData];
}

#pragma mark collectionView代理方法
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.momentModel.praiseList.count;
    //    return 9;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DFDetailPraiseCollectionCell * cell = (DFDetailPraiseCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"DFDetailPraiseCollectionCellID" forIndexPath:indexPath];
    cell.collectimgView.layer.cornerRadius = (collectW-2-2)/2;
    cell.collectimgView.layer.masksToBounds = YES;
    PraiseModel * pra = self.momentModel.praiseList[indexPath.row];
    
    //    [cell.collectimgView sd_setImageWithURL:[NSURL URLWithString:[DFLogicTool getImgWithStr:pra.avatar]]];
    
    [cell.collectimgView setImageWithURL:[DFLogicTool getImgWithStr:pra.avatar] title:pra.nickName size:CGSizeMake(40, 40) placeHolde:nil color:nil textColor:nil];
    
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PraiseModel * pra = self.momentModel.praiseList[indexPath.row];
    NSLog(@"praiseId_%@",pra.uid);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    //    return CGSizeMake(_atCollectionView.mj_w/7,_atCollectionView.mj_w/7);
    return CGSizeMake(collectW,collectW);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

-(UIImageView *)backView{
    if (!_backView) {
        _backView = [[UIImageView alloc]init];
        _backView.backgroundColor = [UIColor clearColor];
        
        UIImage *image = [UIImage imageNamed:@"LikeCmtBg"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(20, 30, 10, 10) resizingMode:UIImageResizingModeStretch];
        _backView.image = image;
        _backView.userInteractionEnabled = YES;
    }
    return _backView;
}

-(UIImageView *)praiseView{
    if (!_praiseView) {
        _praiseView = [[UIImageView alloc]init];
        _praiseView.backgroundColor = [UIColor clearColor];
        UIImage *image = [UIImage imageNamed:@"praiseSmall"];
        _praiseView.image = image;
        _praiseView.hidden = YES;
    }
    return _praiseView;
}

-(UICollectionView *)atCollectionView
{
    if (!_atCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        //设置collectionView滚动方向
        //        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        // 设置水平滚动方向
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        //初始化collectionView
        _atCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(70, 5, ScreenWidth - 90, 150) collectionViewLayout:layout];
        //        _atCollectionView.layer.cornerRadius = 6;
        //        _atCollectionView.layer.masksToBounds = YES;
        _atCollectionView.backgroundColor = [UIColor clearColor];
        _atCollectionView.delegate = self;
        _atCollectionView.dataSource = self;
        //        _atCollectionView.userInteractionEnabled = YES;
        [_atCollectionView registerNib:[UINib nibWithNibName:@"DFDetailPraiseCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"DFDetailPraiseCollectionCellID"];
    }
    return _atCollectionView;
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

@end
