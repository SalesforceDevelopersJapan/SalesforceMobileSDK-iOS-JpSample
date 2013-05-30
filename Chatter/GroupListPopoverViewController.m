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

#import "GroupListPopoverViewController.h"
#import "Company.h"
#import "PublicDatas.h"

@implementation GroupListPopoverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      _groupIdList = [NSMutableArray array];
      _groupList = [NSMutableArray array];
      //		[self getMyGroup];
      
      pData = [PublicDatas instance];
      NSString *isKeyboard = [pData getDataForKey:@"isKeyboard"];
      
      // キーボードの表示／非表示でサイズを変える
      CGRect frame_size_height = CGRectZero ;
      CGRect table_size_height = CGRectZero ;
      if([isKeyboard isEqual: @"YES"]){
        frame_size_height = CGRectMake(0,50,300,300);
        table_size_height = CGRectMake(0,50,300,250);
      }else if ([isKeyboard isEqual: @"NO"]){
        frame_size_height = CGRectMake(0,50,300,520);
        table_size_height = CGRectMake(0,50,300,470);
      }
      
      self.view.frame = frame_size_height;
      UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0,0,300,50)];
      titleLbl.text = @"List";
      titleLbl.backgroundColor = [UIColor blackColor];
      [titleLbl setTextAlignment:NSTextAlignmentCenter];
      titleLbl.textColor = [UIColor whiteColor];
      [titleLbl setFont:[UIFont systemFontOfSize:25]];
      [self.view addSubview:titleLbl];
      _resultTable = [[UITableView alloc]initWithFrame:table_size_height style:UITableViewStylePlain];
      _resultTable.delegate = self;
      _resultTable.dataSource = self;
      _resultTable.scrollEnabled = YES;
      [self.view addSubview:_resultTable];
    }
    return self;
}

//所属するグループを取得
-(void)getMyGroup
{
	//リクエスト作成
	NSString *path = @"v27.0/chatter/users/me/groups";
	SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodGET path:path queryParams:nil];
	
	//GET実行
	[[SFRestAPI sharedInstance] sendRESTRequest:req failBlock:^(NSError *e) {
		NSLog(@"FAILWHALE with error: %@", [e description] );
	}
								  completeBlock:^(id jsonResponse){
									  NSDictionary *dict = (NSDictionary *)jsonResponse;
									  NSLog(@"dict::%@",dict);
									  NSMutableArray *groups = [dict objectForKey:@"groups"];
									
									  //デフォルトで追加
									  [_groupList addObject:[pData getDataForKey:@"DEFINE_CHATTER_LABEL_FOLLOW_ADD"]];
									  [_groupIdList addObject:@"Follow"];
									  [_groupList addObject:[pData getDataForKey:@"DEFINE_CHATTER_LABEL_TOME_ADD"]];
									  [_groupIdList addObject:@"toMe"];
									  [_groupList addObject:[pData getDataForKey:@"DEFINE_CHATTER_LABEL_BOOKMARK_ADD"]];
									  [_groupIdList addObject:@"bookMark"];
									  [_groupList addObject:[pData getDataForKey:@"DEFINE_CHATTER_LABEL_ALLCOMPANY_ADD"]];
									  [_groupIdList addObject:@"AllOfCompany"];
									  
									  for ( int i = 0; i < [groups count]; i++){
										  
										  //グループを取得
										  NSMutableDictionary *grp = [groups objectAtIndex:i];

										  //グループ名保存
										  NSString *name = [grp objectForKey:@"name"];
										  [_groupList addObject:name];
										  
										  //グループID保存
										  NSString *gId = [grp objectForKey:@"id"];
										  [_groupIdList addObject:gId];
									  }

									  [_resultTable reloadData];
								  }];
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

//セル内容設定処理
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([_groupIdList count]==0){
		return nil;
	}
	static NSString *CellIdentifier = @"CellIdentifier";
	
	int row =  (indexPath.section * 4) + indexPath.row;
	
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

	NSString *grpName = [_groupList objectAtIndex:row];
	cell.textLabel.text = grpName;
	cell.detailTextLabel.font = [UIFont systemFontOfSize:8.0f];
	return  cell;
}

//セルタップ時処理
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int row = (indexPath.section * 4)+indexPath.row;
	
	NSString *gId = [_groupIdList objectAtIndex:row];
	if ([self.delegate respondsToSelector:@selector(didSelectGroup:)]){
		[self.delegate didSelectGroup:gId];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
	
	return 2;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	pData = [PublicDatas instance];
    switch(section) {
        case 0: // 1個目のセクションの場合
            return [pData getDataForKey:@"DEFINE_CHATTER_LABEL_FEED"];
            break;
        case 1: // 2個目のセクションの場合
            return [pData getDataForKey:@"DEFINE_CHATTER_LABEL_GROUP"];
            break;
    }
    return nil; //ビルド警告回避用
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == 0) {
        if ( [_groupIdList count] ) {
			return 4;
		}
		else {
			return  0;
		}
    }
	if(section == 1) {
        if ( [_groupIdList count] ) {
			return [_groupIdList count] - 4;
		}
		else {
			return  0;
		}
	}
	return 0;
}

- (void)viewDidUnload {
  [self setGroupList:nil];
  [self setGroupIdList:nil];
  [self setResultTable:nil];
  [self setDelegate:nil];
	[super viewDidUnload];
}

@end
