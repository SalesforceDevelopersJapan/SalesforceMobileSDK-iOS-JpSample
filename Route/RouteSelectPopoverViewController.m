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


#import "RouteSelectPopoverViewController.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Company.h"
#import "SFNativeRestAppDelegate.h"
#import "SFRestAPI+Blocks.h"

@implementation RouteSelectPopoverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
		_pData = [PublicDatas instance];
    um = [UtilManager sharedInstance];
    
		self.view.frame = CGRectMake(0,50,300,520);
		UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0,0,300,50)];
		titleLbl.text = [_pData getDataForKey:@"DEFINE_ROUTE_POPOVERTITLE"];
		titleLbl.backgroundColor = [UIColor blackColor];
		[titleLbl setTextAlignment:NSTextAlignmentCenter];
		titleLbl.textColor = [UIColor whiteColor];
		[titleLbl setFont:[UIFont systemFontOfSize:25]];
		[self.view addSubview:titleLbl];
		_resultTable = [[UITableView alloc]initWithFrame:CGRectMake(0,50,300,470) style:UITableViewStylePlain];
		_resultTable.delegate = self;
		_resultTable.dataSource = self;
		[self.view addSubview:_resultTable];
  }
  return self;
}

-(void)setRouteList:(NSMutableArray *)rtl
{
	_routeList = rtl;
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

//セル内容設定処理
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([_routeList count]==0){
		return nil;
	}
	static NSString *CellIdentifier = @"CellIdentifier";
	
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		
  }
  NSDictionary *tmp = [_routeList objectAtIndex:indexPath.row];
	cell.textLabel.text = [um chkNullString:[tmp valueForKey:@"Name"]];
	cell.detailTextLabel.font = [UIFont systemFontOfSize:8.0f];
	return  cell;
}

//セルタップ時処理
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSDictionary *tmp = [_routeList objectAtIndex:indexPath.row];
  NSLog(@"%@", tmp);
	if ([self.delegate respondsToSelector:@selector(didSelectRoute:Id:)]){
		[self.delegate didSelectRoute:[um chkNullString:[tmp valueForKey:@"Name"]] Id:[tmp valueForKey:@"Id"]];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [_routeList count];
}


@end
