//
//  CountrySelectorViewController.m
//  BiChat
//
//  Created by Admin on 2018/3/15.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "BiChatGlobal.h"
#import "CountrySelectorViewController.h"
#import "JSONKit.h"
#import "pinyin.h"

@interface CountrySelectorViewController ()

@end

@implementation CountrySelectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLSTR(@"107110");
    
    [self initAreaCode];
    [self.tableView reloadData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [array4AreaCode count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[array4AreaCode objectAtIndex:section]count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 ||
        [[array4AreaCode objectAtIndex:section]count] == 0)
        return 0;
    else
        return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0 ||
        [[array4AreaCode objectAtIndex:section]count] == 0)
        return nil;

    UIView *view4Header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    view4Header.backgroundColor = THEME_TABLEBK_LIGHT;
    
    //title
    UILabel *label4Title = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 100, 20)];
    if (section <= 26)
        label4Title.text = [NSString stringWithFormat:@"%c", (int)('a' + section - 1)];
    else
        label4Title.text = @"#";
    label4Title.text = [label4Title.text uppercaseString];
    label4Title.font = [UIFont systemFontOfSize:16];
    [view4Header addSubview:label4Title];
    
    return view4Header;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *toBeReturned = [[NSMutableArray alloc]init];
    [toBeReturned addObject:@"."];
    
    for(char c = 'A' ;c<='Z';c++)
    {
        if ([[array4AreaCode objectAtIndex:(c-'A' + 1)]count] > 0)
            [toBeReturned addObject:[NSString stringWithFormat:@"%c",c]];
    }
    if ([[array4AreaCode objectAtIndex:27]count] > 0)
        [toBeReturned addObject:@"#"];
    
    return toBeReturned;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if ([title isEqualToString:@"#"])
        return 27;
    else if ([title characterAtIndex:0] >= 'A' && [title characterAtIndex:0] <= 'Z')
        return ([title characterAtIndex:0] - 'A' + 1);
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    
    // Configure the cell...
    NSString *str4Country = [NSString stringWithFormat:@"%@  %@",
                             [[[array4AreaCode objectAtIndex:indexPath.section]objectAtIndex:indexPath.row]objectForKey:@"flag"],
                             [[[array4AreaCode objectAtIndex:indexPath.section]objectAtIndex:indexPath.row]objectForKey:@"country"]];
    cell.textLabel.text = str4Country;
    
    if ([[[[array4AreaCode objectAtIndex:indexPath.section]objectAtIndex:indexPath.row]objectForKey:@"code"]length] == 0)
    {
        cell.textLabel.textColor = THEME_GRAY;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    if ([self.currentSelectedCode isEqualToString:[[[array4AreaCode objectAtIndex:indexPath.section]objectAtIndex:indexPath.row]objectForKey:@"code"]])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
    
    //开始通知
    if (self.delegate && [self.delegate respondsToSelector:@selector(countrySelected:countryFlag:countryCode:)])
        [self.delegate countrySelected:[[[array4AreaCode objectAtIndex:indexPath.section]objectAtIndex:indexPath.row]objectForKey:@"country"]
                           countryFlag:[[[array4AreaCode objectAtIndex:indexPath.section]objectAtIndex:indexPath.row]objectForKey:@"flag"]
                           countryCode:[[[array4AreaCode objectAtIndex:indexPath.section]objectAtIndex:indexPath.row]objectForKey:@"code"]];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 私有函数

- (void)initAreaCode
{
    if (array4AreaCode != nil)
        return;
    
    array4AreaCode = [NSMutableArray array];
    
    //开始查找置顶的条目
    NSMutableArray *array4Sticky = [NSMutableArray array];
    for (NSDictionary *item in [BiChatGlobal sharedManager].array4CountryInfo)
    {
        if ([[item objectForKey:@"sticky"]boolValue])
            [array4Sticky addObject:item];
    }
    [array4AreaCode addObject:array4Sticky];
    
    //开始添加其他的所有条目
    for (int i = 0; i < 27; i ++)
        [array4AreaCode addObject:[NSMutableArray array]];
    
    for (NSDictionary *item in [BiChatGlobal sharedManager].array4CountryInfo)
    {
        if ([[item objectForKey:@"country"]length] == 0 || [[item objectForKey:@"sticky"]boolValue])
            continue;
        char c = pinyinFirstLetter([[item objectForKey:@"country"]characterAtIndex:0]);
        if (c >= 'a' && c <= 'z')
            [[array4AreaCode objectAtIndex:(c-'a' + 1)]addObject:item];
        else
            [[array4AreaCode objectAtIndex:27]addObject:item];
    }
}

@end
