//
//  WPCoinDetailViewController.m
//  BiChat
//
//  Created by iMac on 2018/8/1.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPCoinDetailViewController.h"
#import "WPCoinDetailModel.h"
#import "WPNewsDetailViewController.h"

@interface WPCoinDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *tableView;

@property (nonatomic,strong)WPCoinDetailModel *model;
@property (nonatomic,assign)BOOL showAll;


@end

@implementation WPCoinDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self getCoinInfo];
    self.showAll = YES;
    self.title = LLSTR(@"104012");
}

- (void)getCoinInfo {
    [[WPBaseManager baseManager] getInterface:@"Chat/Api/getCoinBaseInfo.do" parameters:@{@"tokenid":[BiChatGlobal sharedManager].token,@"coinType":self.symbol} success:^(id response) {
        self.model = [WPCoinDetailModel mj_objectWithKeyValues:response];
        [self createUI];
    } failure:^(NSError *error) {
        [BiChatGlobal showFailWithString:LLSTR(@"301001")];
    }];
}

- (void)createUI {
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - (isIphonex ? 88 : 64)) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self createHeader];
}

- (void)createHeader {
    UIView *headerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 115)];
    headerV.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = headerV;
    
    UIImageView *imageV = [[UIImageView alloc] init];
    [headerV addSubview:imageV];
    [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerV).offset(15);
        make.width.height.equalTo(@70);
        make.centerY.equalTo(headerV);
    }];
    imageV.layer.cornerRadius = 35;
    imageV.layer.masksToBounds = YES;
    [imageV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].StaticUrl,self.model.imgColor]]];
    
    UILabel *nameLabel = [[UILabel alloc]init];
    [headerV addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageV.mas_right).offset(15);
        make.bottom.equalTo(imageV.mas_centerY).offset(10);
        make.width.equalTo(@200);
        make.height.equalTo(@35);
    }];
    nameLabel.text = self.dSymbol;
    nameLabel.font = Font(28);
    
    UILabel *enNamelabel = [[UILabel alloc]init];
    [headerV addSubview:enNamelabel];
    [enNamelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageV.mas_right).offset(15);
        make.top.equalTo(nameLabel.mas_bottom);
        make.width.equalTo(@200);
        make.height.equalTo(@20);
    }];
    enNamelabel.text = self.model.name.count > 0 ? self.model.name[0] : @"";
    enNamelabel.textColor = THEME_GRAY;
    enNamelabel.font = Font(14);
    
    UILabel *priceLabel = [[UILabel alloc]init];
    [headerV addSubview:priceLabel];
    [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(headerV).offset(-15);
        make.bottom.equalTo(imageV.mas_centerY);
        make.width.equalTo(@200);
        make.height.equalTo(@30);
    }];
    priceLabel.textAlignment = NSTextAlignmentRight;
    priceLabel.text = LLSTR(@"103051");
    priceLabel.textColor = THEME_GRAY;
    priceLabel.font = Font(14);
    
    UILabel *evePriceLabel = [[UILabel alloc]init];
    [headerV addSubview:evePriceLabel];
    [evePriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(headerV).offset(-15);
        make.top.equalTo(priceLabel.mas_bottom);
        make.width.equalTo(@200);
        make.height.equalTo(@30);
    }];
    evePriceLabel.textAlignment = NSTextAlignmentRight;
    evePriceLabel.text = [NSString stringWithFormat:@"$%@",[BiChatGlobal getFormatterStringWithValue:[NSString stringWithFormat:@"%lf",self.model.exchangeUsdAmount]]];
    evePriceLabel.font = Font(28);
}

- (void)resetAllStatus {
    self.showAll = !self.showAll;
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineSpacing = 5;
        CGRect rect  = [self.model.desc boundingRectWithSize:CGSizeMake(ScreenWidth - 30, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : Font(14),NSParagraphStyleAttributeName : paragraphStyle} context:nil];
        CGFloat height = 0;
        if (self.showAll) {
            height = rect.size.height;
        } else {
            if (rect.size.height > 65 ) {
                height = 65;
            } else {
                height = rect.size.height;
            }
        }
        return height + 30;
    }
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
    headerV.backgroundColor = RGB(0xefeff4);
    UIView *whiteView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, ScreenWidth, 50)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [headerV addSubview:whiteView];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 25, ScreenWidth -30, 20)];
    [headerV addSubview:titleLabel];
    if (section == 0) {
        titleLabel.text = LLSTR(@"103052");
    } else {
        titleLabel.text = LLSTR(@"103053");
    }
    titleLabel.font = Font(16);
    return headerV;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineSpacing = 5;
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
        [attributes setObject:Font(14) forKey:NSFontAttributeName];
        [attributes setObject:[UIColor grayColor] forKey:NSForegroundColorAttributeName];
        
        CGRect rect  = [self.model.desc boundingRectWithSize:CGSizeMake(ScreenWidth - 30, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : Font(14),NSParagraphStyleAttributeName : paragraphStyle} context:nil];
        CGFloat height = 0;
        if (self.showAll) {
            height = rect.size.height;
        } else {
            if (rect.size.height > 65 ) {
                height = 65;
            } else {
                height = rect.size.height;
            }
        }
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, height + 30)];
        view.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc]init];
        [view addSubview:label];
        label.numberOfLines = 0;
        label.font = Font(14);
        label.textColor = [UIColor grayColor];
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:self.model.desc.length > 0 ? self.model.desc : @"" attributes:attributes];
        label.attributedText = attStr;
        label.frame = CGRectMake(15, 10, ScreenWidth - 30, height);
        
//        UIButton *showAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [view addSubview:showAllBtn];
//        [showAllBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.bottom.equalTo(view);
//            make.right.equalTo(view).offset(-10);
//            make.width.height.equalTo(@30);
//        }];
//        [showAllBtn addTarget:self action:@selector(resetAllStatus) forControlEvents:UIControlEventTouchUpInside];
//        showAllBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 0, -5, 0);
//        if (self.showAll) {
//            [showAllBtn setImage:Image(@"arrow_up_detail") forState:UIControlStateNormal];
//        } else {
//            [showAllBtn setImage:Image(@"arrow_down_detail") forState:UIControlStateNormal];
//        }
//        [showAllBtn setTitleColor:LightBlue forState:UIControlStateNormal];
        return view;
    }
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.textColor = THEME_GRAY;
    cell.textLabel.font = Font(14);
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.font = Font(14);
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = LLSTR(@"103054");
            cell.detailTextLabel.text = self.model.sites.count > 0 ? self.model.sites[0] : @"";
            cell.detailTextLabel.textColor = LightBlue;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = LLSTR(@"103055");
            cell.detailTextLabel.text = self.model.whitePaper;
            cell.detailTextLabel.textColor = LightBlue;
        }
    } else {
        if (indexPath.row == 0) {
            NSTimeInterval interval = self.model.time / 1000.0;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            cell.textLabel.text = LLSTR(@"103056");
            cell.detailTextLabel.text = [formatter stringFromDate:date];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = LLSTR(@"103057");
            cell.detailTextLabel.text = [BiChatGlobal getFormatterStringWithValue:[NSString stringWithFormat:@"%ld",self.model.total]];
        } else if (indexPath.row == 2) {
            cell.textLabel.text = LLSTR(@"103058");
            cell.detailTextLabel.text = [BiChatGlobal getFormatterStringWithValue:[NSString stringWithFormat:@"%ld",self.model.circulationTotal]];
        } else if (indexPath.row == 3) {
            cell.textLabel.text = LLSTR(@"103059");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"$%@",[BiChatGlobal getFormatterStringWithValue:[NSString stringWithFormat:@"%ld",self.model.totalUsdAmount]]];
        } else if (indexPath.row == 4) {
            cell.textLabel.text = LLSTR(@"103060");
            cell.detailTextLabel.text = [BiChatGlobal getFormatterStringWithValue:[NSString stringWithFormat:@"%ld",self.model.position]];
        } else if (indexPath.row == 5) {
            cell.textLabel.text = LLSTR(@"103061");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"$%@",[BiChatGlobal getFormatterStringWithValue:[NSString stringWithFormat:@"%ld",self.model.turnover_24]]];
        } else if (indexPath.row == 6) {
            cell.textLabel.text = LLSTR(@"103062");
            cell.detailTextLabel.text = [BiChatGlobal getFormatterStringWithValue:[NSString stringWithFormat:@"%ld",self.model.volume_24]];
        } else if (indexPath.row == 7) {
            cell.textLabel.text = LLSTR(@"103063");
            cell.detailTextLabel.text = [BiChatGlobal getFormatterStringWithValue:[NSString stringWithFormat:@"%ld",self.model.tickerNum]];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        if (self.model.sites.count == 0) {
            return;
        }
        NSString *str = self.model.sites[0];
        if (str.length == 0) {
            return;
        }
        WPNewsDetailViewController *detailVC = [[WPNewsDetailViewController alloc]init];
        detailVC.url = self.model.sites[0];
        if (![self.model.sites[0] containsString:@"http://"] && ![self.model.sites[0] containsString:@"https://"]) {
            detailVC.url = [NSString stringWithFormat:@"http://%@",self.model.sites[0]];
        }
        [self.navigationController pushViewController:detailVC animated:YES];
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        WPNewsDetailViewController *detailVC = [[WPNewsDetailViewController alloc]init];
        detailVC.url = self.model.whitePaper;
        if (![self.model.whitePaper containsString:@"http://"] && ![self.model.whitePaper containsString:@"https://"]) {
            detailVC.url = [NSString stringWithFormat:@"http://%@",self.model.whitePaper];
        }
        [self.navigationController pushViewController:detailVC animated:YES];
    }
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
