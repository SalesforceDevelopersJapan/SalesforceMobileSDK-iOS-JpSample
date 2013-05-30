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


#import "DashBoardNaviMenuViewController.h"
#import "AppDelegate.h"

@interface DashBoardNaviMenuViewController ()

@end

@implementation DashBoardNaviMenuViewController
NSArray *imgArray;
NSArray *titleArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        pData = [PublicDatas instance];
      
      CGSize size = CGSizeMake(300, 400); // size of view in popover
      self.contentSizeForViewInPopover = size;
      
      titleArray = @[
                     [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_CHART_PIE"],
                     [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_CHART_BAR"],
                     [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_CHART_LINE"]];
      
      imgArray = @[
                   [pData getDataForKey:@"DEFINE_DASHBOARD_IMAGE_CHART_PIE"],
                   [pData getDataForKey:@"DEFINE_DASHBOARD_IMAGE_CHART_BAR"],
                   [pData getDataForKey:@"DEFINE_DASHBOARD_IMAGE_CHART_LINE"]];
      
        _resultTable.layer.cornerRadius = 10.0f;
        _resultTable.scrollEnabled = NO;
      
      // ネットワーク利用チェック
      AppDelegate* appli = (AppDelegate*)[[UIApplication sharedApplication] delegate];
      [appli chkConn];
      
      gm = [GraphDataManager sharedInstance];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


-(void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  CGSize size = CGSizeMake(300, 400); // size of view in popover
  self.contentSizeForViewInPopover = size;
  
  pData = [PublicDatas instance];
  self.title = [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_CHART"];
  
  _resultTable.scrollEnabled = NO;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [titleArray count];
}

//セル内容設定処理
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([titleArray count]==0){
		return nil;
	}
	static NSString *CellIdentifier = @"CellIdentifier";
	
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		
  }
  
  cell.imageView.image = [UIImage imageNamed:[imgArray objectAtIndex:indexPath.row]];
	cell.textLabel.text = [titleArray objectAtIndex:indexPath.row];
	cell.detailTextLabel.font = [UIFont systemFontOfSize:8.0f];
  //	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  cell.selectionStyle = UITableViewCellSelectionStyleGray;
  
	return  cell;
}


//セルタップ時処理
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  /*
  DashBoardNaviMenuFamilyViewController *familyVC = [[DashBoardNaviMenuFamilyViewController alloc] initWithNibName:@"DashBoardNaviMenuFamilyViewController" bundle:nil];
  [self.navigationController pushViewController:familyVC animated:YES];
   */
  
  // タグごとのデータを取得
  NSMutableDictionary *dic = [gm getDictionaryForTag:[pData getDataForKey:@"tag"]];
  
  
  [pData setData:[NSString stringWithFormat:@"%d", indexPath.row] forKey:@"graphIndex"];
  [dic setObject:[NSString stringWithFormat:@"%d", indexPath.row] forKey:@"graphIndex"];
 
  [gm saveDictionaryFroTag:[pData getDataForKey:@"tag"] Dictionary:dic];
  
  if(indexPath.row==0){
    DashBoardNaviTableViewController *table = [[DashBoardNaviTableViewController alloc] initWithNibName:@"DashBoardNaviTableViewController" bundle:nil];
    table.delegate = self;
    [self.navigationController pushViewController:table animated:YES];
  }else if(indexPath.row==1){
    DashBoardBarTableViewController *table = [[DashBoardBarTableViewController alloc] initWithNibName:@"DashBoardBarTableViewController" bundle:nil];
    table.delegate = self;
    [self.navigationController pushViewController:table animated:YES];
  }else if(indexPath.row==2){
    DashBoardLineTableViewController *table = [[DashBoardLineTableViewController alloc] initWithNibName:@"DashBoardLineTableViewController" bundle:nil];
    table.delegate = self;
    [self.navigationController pushViewController:table animated:YES];
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if(indexPath.section==0){
    return 100.0f;
  }
  return 40.0f;;
}

// OKボタン
- (void)didConfirm
{
  if ([self.delegate respondsToSelector:@selector(didConfirm)]){
		[self.delegate didConfirm];
	}
}

// OKボタン Bar
- (void)didConfirmBar
{
  if ([self.delegate respondsToSelector:@selector(didConfirmBar)]){
		[self.delegate didConfirmBar];
	}
}

// OKボタン Line
- (void)didConfirmLine
{
  if ([self.delegate respondsToSelector:@selector(didConfirmLine)]){
		[self.delegate didConfirmLine];
	}
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
}
- (void)viewDidUnload {
  [self setResultTable:nil];
  [super viewDidUnload];
}
@end
