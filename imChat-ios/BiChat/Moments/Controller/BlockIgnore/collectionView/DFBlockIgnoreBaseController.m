//
//  DFBlockIgnoreBaseController.m
//  BiChat
//
//  Created by chat on 2018/9/19.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "DFBlockIgnoreBaseController.h"
#import "DFBlockIgnoreCollectCell.h"

#define collectW  (ScreenWidth - 20)/8

@interface DFBlockIgnoreBaseController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@end


@implementation DFBlockIgnoreBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];    
    _dataSourceArr = [NSMutableArray arrayWithCapacity:10];
    [self createView];
}

-(void)createView{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backView];
    [_backView addSubview:self.atCollectionView];
    
    [_backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    [_atCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(10);
        make.right.bottom.mas_equalTo(-10);
//        make.left.mas_equalTo(10);
//        make.width.mas_equalTo(collectW*8);
    }];
}

//-(void)updatePraiseWithModel:(DFBaseMomentModel*)momentModel{
//    self.momentModel = momentModel;
//    [_atCollectionView reloadData];
//}

#pragma mark collectionView代理方法
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return  _dataSourceArr.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DFBlockIgnoreCollectCell * cell = (DFBlockIgnoreCollectCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"DFBlockIgnoreCollectCellID" forIndexPath:indexPath];
    cell.collectimgView.layer.cornerRadius = 45/2;
    cell.collectimgView.layer.masksToBounds = YES;
    
    if (_dataSourceArr.count) {
        NSDictionary * blockIgnoreDic = _dataSourceArr[indexPath.row];
        [cell.collectimgView setImageWithURL:[DFLogicTool getImgWithStr:[blockIgnoreDic objectForKey:@"avatar"]] title:[blockIgnoreDic objectForKey:@"nickName"] size:CGSizeMake(40, 40) placeHolde:nil color:nil textColor:nil];
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(_atCollectionView.mj_w,45);
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
        _backView.backgroundColor = [UIColor whiteColor];
        _backView.userInteractionEnabled = YES;
    }
    return _backView;
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
        _atCollectionView = [[UICollectionView alloc]initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:layout];
        //        _atCollectionView.layer.cornerRadius = 6;
        //        _atCollectionView.layer.masksToBounds = YES;
//        _atCollectionView.backgroundColor = [UIColor blueColor];
        _atCollectionView.delegate = self;
        _atCollectionView.dataSource = self;
        //        _atCollectionView.userInteractionEnabled = YES;
        [_atCollectionView registerNib:[UINib nibWithNibName:@"DFBlockIgnoreCollectCell" bundle:nil] forCellWithReuseIdentifier:@"DFBlockIgnoreCollectCellID"];
    }
    return _atCollectionView;
}

@end
