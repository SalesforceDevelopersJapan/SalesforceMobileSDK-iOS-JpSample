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


#import "DashBoardBarTableViewController.h"
#import "DashBoardBarItemViewController.h"
#import "DashBoardBarTermViewController.h"
#import "DashBoardBarMonthViewController.h"

@interface DashBoardBarTableViewController ()

@end

@implementation DashBoardBarTableViewController

NSArray *array;
NSArray *imgArray;
NSArray *titleArray;
BOOL isGet;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      pData = [PublicDatas instance];
      
      self.title = [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE"];
      _resultTable.scrollEnabled = NO;
      
      titleArray = @[
                     [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_CHART_PIE"],
                     [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_CHART_BAR"],
                     [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_CHART_LINE"]];
      
      imgArray = @[
                   [pData getDataForKey:@"DEFINE_DASHBOARD_IMAGE_CHART_PIE"],
                   [pData getDataForKey:@"DEFINE_DASHBOARD_IMAGE_CHART_BAR"],
                   [pData getDataForKey:@"DEFINE_DASHBOARD_IMAGE_CHART_LINE"]];
                   
      array = @[@"", //@"集計項目", @"集計期間" ,@"年度開始月"];
      [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_ITEM"],
      [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_TERM"],
      [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_STARTMONTH"]];
       
      um = [UtilManager sharedInstance];
      gm = [GraphDataManager sharedInstance];
    }
    return self;
}


// OKボタン
- (IBAction)pushOk:(id)sender {
  if(!isGet) return;
  if([self.delegate respondsToSelector:@selector(didConfirmBar)]){
		[self.delegate didConfirmBar];
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload {
  [self setResultTable:nil];
  [self setButton:nil];
  [self setDelegate:nil];
	[super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated
{
  CGSize size = CGSizeMake(300, 400); // size of view in popover
  self.contentSizeForViewInPopover = size;
  [super viewWillAppear:animated];
  isGet = NO;
  
  [_resultTable reloadData];
  
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
  if(indexPath.section==0){
    cell.imageView.image = [UIImage imageNamed:[imgArray objectAtIndex:1]];
    cell.textLabel.text = [titleArray objectAtIndex:1];
  }else{
    cell.textLabel.text = [array objectAtIndex:indexPath.section];;
  }
	cell.detailTextLabel.font = [UIFont systemFontOfSize:8.0f];
  
  // タグごとのデータを取得
  NSMutableDictionary *dic = [gm getDictionaryForTag:[pData getDataForKey:@"tag"]];
  
  NSString *grapthIndex = [dic objectForKey:@"graphIndex"];
  /*
   barMonth 開始付月
   barItem @"売上", @"商談数"
   barTerm @"年間", @"四半期", @"前四半期"
   */
   NSString *barMonth = [dic objectForKey:@"barMonth"];
   NSString *barItem = [dic objectForKey:@"barItem"];
   NSString *barTerm = [dic objectForKey:@"barTerm"];
  
  //NSLog(@"barItem :%@", barItem);
  //NSLog(@"barTerm :%@", barTerm);
  //NSLog(@"barMonth :%@", barMonth);
  if(!barMonth) barMonth = @"1";
  if(!barItem) barItem = [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_SALE"];//@"売上";
  if(!barTerm) barTerm = [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_YEARTERM"];//@"年間";
  
  [dic setObject:barItem forKey:@"barItem"];
  [dic setObject:barTerm forKey:@"barTerm"];
  [dic setObject:barMonth forKey:@"barMonth"];
  
  [gm saveDictionaryFroTag:[pData getDataForKey:@"tag"] Dictionary:dic];
  
  // Configure the cell...
  switch (indexPath.section) {
    case 0:
      cell.imageView.image = [UIImage imageNamed:[imgArray objectAtIndex:[grapthIndex intValue]]];
      cell.textLabel.text = [titleArray objectAtIndex:[grapthIndex intValue]];
      break;
    case 1:
      if(barItem){
        cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@", [array objectAtIndex:indexPath.section], barItem];
      }else{
        cell.textLabel.text = [array objectAtIndex:indexPath.section];
      }
      break;
    case 2:
      if(barTerm){
        cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@", [array objectAtIndex:indexPath.section], barTerm];
      }else{
        cell.textLabel.text = [array objectAtIndex:indexPath.section];
      }
      break;
    case 3:
      if(barMonth){
        cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@", [array objectAtIndex:indexPath.section], barMonth];
      }else{
        cell.textLabel.text = [array objectAtIndex:indexPath.section];
      }
      break;
    default:
      break;
  }

  isGet = YES;

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
    DashBoardBarItemViewController *itemVC = [[DashBoardBarItemViewController alloc] initWithNibName:@"DashBoardBarItemViewController" bundle:nil];
    [self.navigationController pushViewController:itemVC animated:YES];
  }
  else if(indexPath.section==2){
    DashBoardBarTermViewController *VC = [[DashBoardBarTermViewController alloc] initWithNibName:@"DashBoardBarTermViewController" bundle:nil];
    [self.navigationController pushViewController:VC animated:YES];
  }else if(indexPath.section==3){
    DashBoardBarMonthViewController *monthVC = [[DashBoardBarMonthViewController alloc] initWithNibName:@"DashBoardBarMonthViewController" bundle:nil];
    [self.navigationController pushViewController:monthVC animated:YES];
  }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
