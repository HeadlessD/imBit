//
//  DFDrageImageView.h
//  BiChat Dev
//
//  Created by chat on 2018/11/7.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DFDrageImageView : UIView<UICollectionViewDelegate, UICollectionViewDataSource>{
    
    NSMutableArray *_dataSource;    //声明数据源数组
}
@property (nonatomic, strong) UICollectionView *collectionView; //单元格视图



@end

