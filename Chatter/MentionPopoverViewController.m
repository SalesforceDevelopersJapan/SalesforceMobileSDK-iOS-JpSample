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

#import "MentionPopoverViewController.h"
#import "PublicDatas.h"

@implementation MentionPopoverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _mentionIdList = [NSMutableArray array];
    _mentionList = [NSMutableArray array];
    _mentionImageUrlList = [NSMutableArray array];
    //[self getMention];
    
    pData = [PublicDatas instance];
    um = [UtilManager sharedInstance];
    
    NSString *isKeyboard = [pData getDataForKey:@"isKeyboard"];
    
    // キーボードの表示／非表示でサイズを変える
    frame_size_height = CGRectZero ;
    CGRect table_size_height = CGRectZero ;
    if([isKeyboard isEqual: @"YES"]){
      frame_size_height = CGRectMake(0,0,300,180);
      table_size_height = CGRectMake(0,0,300,180);
    }else if ([isKeyboard isEqual: @"NO"]){
      frame_size_height = CGRectMake(0,0,300,470);
      table_size_height = CGRectMake(0,0,300,470);
    }
    /*
    frame_size_height = CGRectZero ;
    CGRect table_size_height = CGRectZero ;
    frame_size_height = CGRectMake(0,0,300,300);
    table_size_height = CGRectMake(0,0,300,300);
    */
    
    self.view.frame = frame_size_height;
    _resultTable = [[UITableView alloc]initWithFrame:table_size_height style:UITableViewStylePlain];
    _resultTable.delegate = self;
    _resultTable.dataSource = self;
    _resultTable.scrollEnabled = YES;
    [self.view addSubview:_resultTable];
  }
  return self;
}

//メンションを取得
-(void)getMention
{
  _mentionIdList = [[NSMutableArray alloc] init];
  _mentionList = [[NSMutableArray alloc] init];
  
  //検索用parameter
	NSDictionary *q = [[NSDictionary alloc]initWithObjectsAndKeys:@"", @"q",nil];

	//リクエスト作成
	NSString *path = @"v27.0/chatter/users";
	SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodGET path:path queryParams:q];
	
	//GET実行
	[[SFRestAPI sharedInstance] sendRESTRequest:req failBlock:^(NSError *e) {
		NSLog(@"FAILWHALE with error: %@", [e description] );
	}
                                completeBlock:^(id jsonResponse){
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  //NSLog(@" mention dict::%@",dict);
                                  
                                  NSMutableArray *users = [dict objectForKey:@"users"];
                                  /*
                                  if([users count]==0){
                                    [self closeMention:nil];
                                    return;
                                  }*/
                                  
                                  for ( int i = 0; i < [users count]; i++){
                                    
                                    //グループを取得
                                    NSMutableDictionary *user = [users objectAtIndex:i];
                                    
                                    //グループ名保存
                                    NSString *name = [NSString stringWithFormat:@"%@ %@", [um chkNullString:[user valueForKey:@"lastName"]],[um chkNullString:[user valueForKey:@"firstName"]]];
                                    
                                    //NSLog(@" user name::%@",name);
                                    
                                    [_mentionList addObject:name];
                                    
                                    //グループID保存
                                    NSString *uId = [user objectForKey:@"id"];
                                    [_mentionIdList addObject:uId];
                                  }
                                  
                                  //[_resultTable reloadData];
                                }];
}

-(void)searchMention:(NSString*)word
{
  if([word length]<1) return;
  
   __mentionList = [[NSMutableArray alloc] init];
   __mentionIdList = [[NSMutableArray alloc] init];
  __mentionImageUrlList = [[NSMutableArray alloc] init];
  
   for (int i=0; i<[_mentionList count]; i++){
     NSString *str = [_mentionList objectAtIndex:i];
     if ([str rangeOfString:word].location != NSNotFound) {
       [__mentionList addObject:str];
       [__mentionIdList addObject:[_mentionIdList objectAtIndex:i]];
       [__mentionImageUrlList addObject:[_mentionImageUrlList objectAtIndex:i]];
     }
   }
  if([__mentionList count]){
    _mentionList = __mentionList;
    _mentionIdList = __mentionIdList;
    _mentionImageUrlList = __mentionImageUrlList;
   [_resultTable reloadData];
  }
}

-(void)viewWillAppear:(BOOL)animated
{
  self.contentSizeForViewInPopover = frame_size_height.size;
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
	if ([_mentionIdList count]==0){
		return nil;
	}
	static NSString *CellIdentifier = @"CellIdentifier";
	
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  
	NSString *userName = [_mentionList objectAtIndex:indexPath.row];
	cell.textLabel.text = userName;
	cell.detailTextLabel.font = [UIFont systemFontOfSize:8.0f];
  
  
  NSString *fullEmailPhotoUrl = [_mentionImageUrlList objectAtIndex:indexPath.row];
  NSData *data = [[NSUserDefaults  standardUserDefaults]objectForKey:fullEmailPhotoUrl];
  UIImage *image = [[UIImage alloc] initWithData:data];
  CGRect Rect =  CGRectMake(0, 0, 50, 50);
  UIImageView *iv = [[UIImageView alloc] initWithImage:[um forceResizeImage:image Rect:Rect]];
  //cell.imageView.image = [um forceResizeImage:image Rect:Rect];
  //cell.imageView.layer.cornerRadius = 4;
  //CGSize size = CGSizeMake(5.0, 5.0);
  //[um makeViewRound:iv corners:UIRectCornerAllCorners size:&size];
  cell.imageView.image = iv.image;
  
	return  cell;
}

//セルタップ時処理
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	NSString *uId = [_mentionIdList objectAtIndex:indexPath.row];
  [pData setData:[_mentionList objectAtIndex:indexPath.row] forKey:@"mention"];
  
  NSLog(@"uid %@", uId);
	if ([self.delegate respondsToSelector:@selector(didSelectMention:)]){
		[self.delegate didSelectMention:uId];
	}
}

-(void)closeMention:(id)sender
{
	if ([self.delegate respondsToSelector:@selector(didCloseMention:)]){
		[self.delegate didCloseMention:sender];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
      return 1;
	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	return [_mentionIdList count];
}

- (void)viewDidUnload {
  //[self setMentionList:nil];
  //[self setMentionIdList:nil];
  [self setResultTable:nil];
  [self setDelegate:nil];
  [self setWord:nil];
	[super viewDidUnload];
}

@end