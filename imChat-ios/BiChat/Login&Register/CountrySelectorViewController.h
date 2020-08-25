//
//  CountrySelectorViewController.h
//  BiChat
//
//  Created by Admin on 2018/3/15.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CountrySelectDelegate <NSObject>
@optional
- (void)countrySelected:(NSString *)countryName countryFlag:(NSString *)countryFlag countryCode:(NSString *)countryCode;
@end

@interface CountrySelectorViewController : UITableViewController
{
    NSMutableArray *array4AreaCode;
}

@property (nonatomic, retain) NSString *currentSelectedCode;
@property (nonatomic, weak) id<CountrySelectDelegate> delegate;

@end
