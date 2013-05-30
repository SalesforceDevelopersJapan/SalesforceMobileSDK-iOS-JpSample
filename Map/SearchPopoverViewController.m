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


#import "SearchPopoverViewController.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SFNativeRestAppDelegate.h"
#import "SFRestAPI+Blocks.h"

@implementation SearchPopoverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      
      _pData = [PublicDatas instance];
      NSString *isKeyboard = [_pData getDataForKey:@"isKeyboard"];
      CGRect frame_size_height = CGRectZero ;
      CGRect table_size_height = CGRectZero ;
      if([isKeyboard isEqual: @"YES"]){
        frame_size_height = CGRectMake(0,50,300,220);
        table_size_height = CGRectMake(0,50,300,170);
      }else if ([isKeyboard isEqual: @"NO"]){
        frame_size_height = CGRectMake(0,50,300,520);
        table_size_height = CGRectMake(0,50,300,470);
      }
      
      self.view.frame = frame_size_height;
      UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0,0,300,50)];
      titleLbl.text = [_pData getDataForKey:@"DEFINE_MAP_CUSTOMER"];
      titleLbl.backgroundColor = [UIColor blackColor];
      [titleLbl setTextAlignment:NSTextAlignmentCenter];
      
      titleLbl.textColor = [UIColor whiteColor];
      [titleLbl setFont:[UIFont systemFontOfSize:25]];
      [self.view addSubview:titleLbl];
      _resultTable = [[UITableView alloc]initWithFrame:table_size_height style:UITableViewStylePlain];
      _resultTable.delegate = self;
      _resultTable.dataSource = self;
      [self.view addSubview:_resultTable];
    }
    return self;
}

-(void)setCompanyList:(NSMutableArray *)cpl
{
	_companyList = cpl;
	[_resultTable reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
	[self setResultTable:nil];
	[super viewDidUnload];
}

-(NSString*)chkString:(id)tgt
{
	NSString *cls = NSStringFromClass([tgt class]);
	if ( ![cls isEqualToString:@"__NSCFString"]) {
		return @"";
	}
	else {
        return tgt;
	}
}

//セル内容設定処理
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([_companyList count]==0){
		return nil;
	}
	static NSString *CellIdentifier = @"CellIdentifier";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		
    }
	Company *cp = [_companyList objectAtIndex:indexPath.row];
	cell.textLabel.text = cp.name;
	cell.detailTextLabel.font = [UIFont systemFontOfSize:8.0f];
//	cell.textLabel.text = [NSString stringWithFormat:@"%f:%@", (float)cp.currentSales / (float)cp.oldSales,cp.name];
//	cell.detailTextLabel.text = [[cp Address1]stringByAppendingString:[cp Address2]];

	if ( cp.salesStatus == SALES_UP) {
		cell.imageView.image = [UIImage imageNamed:@"salesup.png"];
	}
	else if ( cp.salesStatus == SALES_FLAT) {
		cell.imageView.image = [UIImage imageNamed:@"salesflat.png"];
	}
	else {
		cell.imageView.image = [UIImage imageNamed:@"salesdown.png"];
	}
//	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return  cell;
}

//セルタップ時処理
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Company *cp = [_companyList objectAtIndex:indexPath.row];
	if ([self.delegate respondsToSelector:@selector(didSelectCompany:)]){
		[self.delegate didSelectCompany:cp];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_companyList count];
}


/*
//検索処理
-(void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
	
	//検索文字が空白の場合は、検索解除（前表示）
	if ( [srchBar.text isEqualToString:@""]) {
		searchList = [companyList mutableCopy];
		dataCount = [searchList count];
		[self.resultTable reloadData];
		return;
	}
	
	company *cp = [[company alloc]init];
	searchList = [NSMutableArray array];					//検索結果保存用
	for ( int wrk = 0; wrk < [companyList count]; wrk++) {
		cp = [companyList objectAtIndex:wrk];

		//検索バーのtextが会社名に含まれるか検索
		NSRange searchResult = [cp.name rangeOfString:searchBar.text];
		if (searchResult.location != NSNotFound) {
			[searchList addObject:cp];
		}
	}
	dataCount = [searchList count];
	[self.resultTable reloadData];
}


//取引先一覧を取得
-(void)getCompanyList
{
	NSString *query = @"SELECT Id,Name,BillingStreet,BillingCity,BillingState,Phone FROM Account";
	
	[[SFRestAPI sharedInstance] performSOQLQuery:query
	 //エラーハンドラ
									   failBlock:^(NSError *e) {
										   NSLog(@"FAILWHALE with error: %@", [e description] );
									   }
	 
	 //受信ハンドラ
								   completeBlock:^(NSDictionary *results) {
									   
									   companyList = [NSMutableArray array];
									   searchList = [NSMutableArray array];
									   
									   //受信データから各項目を抽出
									   NSArray *records = [results objectForKey:@"records"];
									   
									   for ( int wrk = 0 ; wrk < [records count]; wrk++ ) {
										   NSDictionary *dic = [records objectAtIndex:wrk];
										   NSString *billingCity = [self chkString:[dic objectForKey:@"BillingCity"]];
										   NSString *billingStreet = [self chkString:[dic objectForKey:@"BillingStreet"]];
										   NSString *billingState = [self chkString:[dic objectForKey:@"BillingState"]];
										   NSString *name = [self chkString:[dic objectForKey:@"Name"]];
										   NSString *phone = [self chkString:[dic objectForKey:@"Phone"]];
										   NSString *address = [billingState stringByAppendingString:billingCity];
										   NSString *Id = [dic objectForKey:@"Id"];
										   
										   //データ保存
										   company *temp = [[company alloc]init];
										   temp.company_id = Id;
										   temp.name = name;
										   temp.Address1 = address;
										   temp.Address2 = billingStreet;
										   temp.phone1 = phone;
										   
										   [companyList addObject:temp];
										   [searchList addObject:temp];
									   }
									   dataCount = [searchList count];
									   [self.resultTable reloadData];
								   }];
}
*/

@end
