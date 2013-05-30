/*
 Copyright (c) 2013, salesforce.com Co.,Ltd. inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "DashBoardNaviTableViewController.h"
#import "DashBoardNaviMenuViewController.h"
#import "DashBoardNaviMenuFamilyViewController.h"
#import "DashBoardNaviMenuStartDateViewController.h"
#import "DashBoardNaviMenuEndDateViewController.h"

@interface DashBoardNaviTableViewController ()

@end

@implementation DashBoardNaviTableViewController
NSArray *array;
NSArray *imgArray;
NSArray *titleArray;
BOOL isGet;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    
    pData = [PublicDatas instance];
    
    self.title = [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE"];
    
    CGSize size = CGSizeMake(300, 400); // size of view in popover
    self.contentSizeForViewInPopover = size;
    
    self.view.frame = CGRectMake(0,0,300,400);

    _resultTable.scrollEnabled = NO;
    
    titleArray = @[
                   [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_CHART_PIE"],
                   [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_CHART_BAR"],
                   [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_CHART_LINE"]];
    
    imgArray = @[
                 [pData getDataForKey:@"DEFINE_DASHBOARD_IMAGE_CHART_PIE"],
                 [pData getDataForKey:@"DEFINE_DASHBOARD_IMAGE_CHART_BAR"],
                 [pData getDataForKey:@"DEFINE_DASHBOARD_IMAGE_CHART_LINE"]];
    
    array =@[@"", //@"比較項目", @"集計項目 : 売上", @"集計開始", @"集計終了"];
    [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_COMPARE"],
    [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_ITEM_TITLE_SALE"],
    [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_START"],
    [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_END"] ];
    
    gm = [GraphDataManager sharedInstance];
  }
  return self;
}


// 日付比較
-(BOOL)compareDateStr:(NSString*)startYear starMonth:(NSString*)startMonth EndYear:(NSString*)endYear EndMonth:(NSString*)endMonth
{
    NSString *startDateStr = [NSString stringWithFormat:@"%@/%2d/01 00:00:00", startYear, [startMonth intValue]];
    NSString *endDateStr = [NSString stringWithFormat:@"%@/%2d/01 00:00:00", endYear, [endMonth intValue]];
  
  NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
  [inputDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
  NSDate *startDate = [inputDateFormatter dateFromString:startDateStr];
  NSDate *endDate = [inputDateFormatter dateFromString:endDateStr];
  
  BOOL ret = YES;
  // 日付を比較
  NSComparisonResult result = [startDate compare:endDate];
  switch(result) {
    case NSOrderedSame: // 一致したとき 同じ月ならOK
      ret = YES;
      break;
      
    case NSOrderedAscending: // startDateが小さいとき
      ret = YES;
      break;
      
    case NSOrderedDescending: // endDateが大きいとき
      ret = NO;
      break;
  }
  return ret;
}

// OKボタン
- (IBAction)pushOk:(id)sender {
  
  
  // タグごとのデータを取得
  NSMutableDictionary *dic = [gm getDictionaryForTag:[pData getDataForKey:@"tag"]];
  
  NSString *startYear = [dic objectForKey:@"startYear"];
  NSString *startMonth = [dic objectForKey:@"startMonth"];
  
  NSString *endYear = [dic objectForKey:@"endYear"];
  NSString *endMonth = [dic objectForKey:@"endMonth"];
  
  BOOL ret = [self compareDateStr:startYear starMonth:startMonth EndYear:endYear EndMonth:endMonth];
  if(ret){
    if ([self.delegate respondsToSelector:@selector(didConfirm)]){
      [self.delegate didConfirm];
    }
  }else{
    // アラートを表示する
    UIAlertView*    alertView;
    alertView = [[UIAlertView alloc]
                 initWithTitle:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_DATE_ERROR"]
                 message:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_DATE_MESSAGE_ERROR"]
                 delegate:nil
                 cancelButtonTitle:nil
                 otherButtonTitles:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_DATE_OK_ERROR"], nil ];
    [alertView show];
  }
}

-(void)viewWillAppear:(BOOL)animated
{
  CGSize size = CGSizeMake(300, 400); // size of view in popover
  self.contentSizeForViewInPopover = size;
  [super viewWillAppear:animated];
  isGet = NO;
  
  //NSLog(@"isGet %d", isGet);
  [_resultTable reloadData];
  
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [array count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
  
	cell.detailTextLabel.font = [UIFont systemFontOfSize:8.0f];
  
  // タグごとのデータを取得
  NSMutableDictionary *dic = [gm getDictionaryForTag:[pData getDataForKey:@"tag"]];
  
  NSString *grapthIndex = [dic objectForKey:@"graphIndex"];
  
  NSString *family = [dic objectForKey:@"family"];
  
  NSString *startYear = [dic objectForKey:@"startYear"];
  NSString *startMonth = [dic objectForKey:@"startMonth"];
  
  NSString *endYear = [dic objectForKey:@"endYear"];
  NSString *endMonth = [dic objectForKey:@"endMonth"];
  
  
  if(!family) family = [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_FAMILY"];
  //if(!startYear) startYear = @"2013";
  if(!startMonth) startMonth = @"1";
  
  NSDate *date = [NSDate date];
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *comps;
  
  // 年月日をとりだす
  comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                      fromDate:date];
  NSInteger year = [comps year];
  NSInteger month = [comps month];
  
  if(!startYear) startYear = [NSString stringWithFormat:@"%d", year];
  if(!endYear) endYear = [NSString stringWithFormat:@"%d", year];
  if(!endMonth) endMonth = [NSString stringWithFormat:@"%d", month];
  
  [dic setObject:family forKey:@"family"];
  [dic setObject:startYear forKey:@"startYear"];
  [dic setObject:startMonth forKey:@"startMonth"];
  [dic setObject:endYear forKey:@"endYear"];
  [dic setObject:endMonth forKey:@"endMonth"];
  
  [gm saveDictionaryFroTag:[pData getDataForKey:@"tag"] Dictionary:dic];
  
    // Configure the cell...
  switch (indexPath.section) {
    case 0:
      cell.imageView.image = [UIImage imageNamed:[imgArray objectAtIndex:[grapthIndex intValue]]];
      cell.textLabel.text = [titleArray objectAtIndex:[grapthIndex intValue]];
      break;
    case 1:
      if(family){
        cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@", [array objectAtIndex:indexPath.section], family];
      }else{
        cell.textLabel.text = [array objectAtIndex:indexPath.section];
      }
      break;
    case 2:
        cell.textLabel.text = [array objectAtIndex:indexPath.section];
      break;
    case 3:
      if(startYear){
        if(startMonth){
          cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@ / %@",[array objectAtIndex:indexPath.section], startYear, startMonth];
                                 //pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_YEAR"]
                                 //[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_MONTH"]];
        }else{
          cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@",[array objectAtIndex:indexPath.section], startYear];//], [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_YEAR"]];
        }
      }else{
        cell.textLabel.text = [array objectAtIndex:indexPath.section];
      }
      break;
    case 4:
      if(endYear){
        if(endMonth){
          cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@ / %@",[array objectAtIndex:indexPath.section], endYear,endMonth];
                                 //[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_YEAR"],[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_MONTH"]];
        }else{
          cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@%@",[array objectAtIndex:indexPath.section], endYear,[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_YEAR"]];
        }
      }else{
        cell.textLabel.text = [array objectAtIndex:indexPath.section];
      }
      break;
    default:
      break;
  }
  
  if(startYear && startMonth && endYear && endMonth && !isGet){
    // 集計終了の月末日
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:[endYear intValue]];
    [comps setMonth:[endMonth intValue]];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *date = [cal dateFromComponents:comps];
    NSRange range = [cal rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    
    // 指定した日付の間でデータを取得する
    gm.startDate = [NSString stringWithFormat:@"%@-%02d-01T00:00:00+00:00", startYear, [startMonth intValue]];
    gm.endDate = [NSString stringWithFormat:@"%@-%02d-%02dT23:59:59+00:00", endYear, [endMonth intValue], range.length];
    
    [gm requestDataList:family startDate:gm.startDate endDate:gm.endDate];
    isGet = YES;
  }
  
  if(indexPath.section==0)
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  else
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
  
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if(indexPath.section==0){
    return 60.0f;
  }
  return 40.0f;;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
  // 次画面のコントローラー
  if(indexPath.section==0){
  }else if(indexPath.section==1){
    // ネットワーク切断からの戻りの場合ファミリーをとりなおす
    NSMutableArray *familyList = [pData getDataForKey:@"familyList"];
    if([familyList count]<=1) [gm requestFamilyList];
    DashBoardNaviMenuFamilyViewController *familyVC = [[DashBoardNaviMenuFamilyViewController alloc] initWithNibName:@"DashBoardNaviMenuFamilyViewController" bundle:nil];
    [self.navigationController pushViewController:familyVC animated:YES];
  }else if(indexPath.section==3){
    DashBoardNaviMenuStartDateViewController *startVC = [[DashBoardNaviMenuStartDateViewController alloc] initWithNibName:@"DashBoardNaviMenuStartDateViewController" bundle:nil];
    [self.navigationController pushViewController:startVC animated:YES];
  }else if(indexPath.section==4){
    DashBoardNaviMenuEndDateViewController *endVC = [[DashBoardNaviMenuEndDateViewController alloc] initWithNibName:@"DashBoardNaviMenuEndDateViewController" bundle:nil];
    [self.navigationController pushViewController:endVC animated:YES];
  }
}

- (void)dealloc {
}
- (void)viewDidUnload {
  [self setResultTable:nil];
  [self setButton:nil];
  [super viewDidUnload];
}

@end
