//
//  DFDetailPraiseCell.m
//  BiChat Dev
//
//  Created by chat on 2018/9/4.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "DFDetailPraiseCell.h"
#import "DFDetailPraiseCollectionCell.h"

#define collectW  37
#define collectViewWidth (ScreenWidth - 38 - 20)
#define PraiseNum  9

@interface DFDetailPraiseCell ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) UICollectionView * atCollectionView;
@property (nonatomic,strong) DFBaseMomentModel  * momentModel;

@end

@implementation DFDetailPraiseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createView];
    }
    return self;
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
        make.left.mas_equalTo(38);
//        make.width.mas_equalTo(collectW*8);
        make.width.mas_equalTo(collectViewWidth);
        //        make.right.mas_equalTo(-10);
        make.bottom.mas_equalTo(-5);
    }];
}

+(CGFloat)getCollectionHeightWithModel:(DFBaseMomentModel *)model
{
    if (model.praiseList.count == 0) {
        return 0;
    }else{
        NSInteger  totalNum = (collectViewWidth)/37 + 1;

        NSInteger  count = model.praiseList.count/totalNum;
//        NSInteger  count = PraiseNum/totalNum;
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
//    return PraiseNum;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UINib *nib = [UINib nibWithNibName:@"DFDetailPraiseCollectionCell" bundle:[NSBundle mainBundle]];
    [_atCollectionView registerNib:nib forCellWithReuseIdentifier:@"DFDetailPraiseCollectionCellID"];

    DFDetailPraiseCollectionCell * cell  = (DFDetailPraiseCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"DFDetailPraiseCollectionCellID" forIndexPath:indexPath];

    cell.collectimgView.layer.cornerRadius = (collectW-2-2)/2;
    cell.collectimgView.layer.masksToBounds = YES;
    PraiseModel * pra = self.momentModel.praiseList[indexPath.row];
//    PraiseModel * pra = self.momentModel.praiseList[0];

//    [cell.collectimgView sd_setImageWithURL:[NSURL URLWithString:[DFLogicTool getImgWithStr:pra.avatar]]];
    
    [cell.collectimgView setImageWithURL:[DFLogicTool getImgWithStr:pra.avatar] title:pra.remark size:CGSizeMake(40, 40) placeHolde:nil color:nil textColor:nil];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PraiseModel * pra = self.momentModel.praiseList[indexPath.row];
        //    NSLog(@"praiseId_%@",pra.uid);
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(clickPraiseCellOnDFDetailPraiseCellWithId:)]) {
        [_delegate clickPraiseCellOnDFDetailPraiseCellWithId:pra.uid];
    }
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
//        _backView.backgroundColor = [UIColor greenColor];

        UIImage *image = [UIImage imageNamed:@"likesanjiao"];
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
//        _praiseView.backgroundColor = [UIColor blueColor];
        UIImage *image = [UIImage imageNamed:@"praiseBlueKong"];
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
        _atCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(40, 5, ScreenWidth - 90, 150) collectionViewLayout:layout];
        //        _atCollectionView.layer.cornerRadius = 6;
        //        _atCollectionView.layer.masksToBounds = YES;
        _atCollectionView.backgroundColor = [UIColor clearColor];
        _atCollectionView.delegate = self;
        _atCollectionView.dataSource = self;
        //        _atCollectionView.userInteractionEnabled = YES;
//        _atCollectionView.backgroundColor = [UIColor blueColor];
//        [_atCollectionView registerNib:[UINib nibWithNibName:@"DFDetailPraiseCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"DFDetailPraiseCollectionCellID"];
    }
    return _atCollectionView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
