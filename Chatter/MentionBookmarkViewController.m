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

#import "MentionBookmarkViewController.h"

@interface MentionBookmarkViewController ()

@end

@implementation MentionBookmarkViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      menuList = [NSMutableArray array];
      pData = [PublicDatas instance];
      
      CGRect frame_size_height = CGRectZero ;
      CGRect table_size_height = CGRectZero ;
      frame_size_height = CGRectMake(0,0,300,90);
      table_size_height = CGRectMake(0,0,300,90);
      
      self.view.frame = frame_size_height;
      _resultTable = [[UITableView alloc]initWithFrame:table_size_height style:UITableViewStylePlain];
      _resultTable.delegate = self;
      _resultTable.dataSource = self;
      _resultTable.scrollEnabled = YES;
      [self.view addSubview:_resultTable];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
  self.contentSizeForViewInPopover = CGSizeMake(300, 90);
}

// 0 bookmark add
// 1 bookmark delete
-(void)setMenu:(int)num
{
  menuList = [NSMutableArray array];
  
  if(num==0){
    [menuList addObject:[pData getDataForKey:@"DEFINE_CHATTER_BOOKMARK_ADD"]];
    [menuList addObject:[pData getDataForKey:@"DEFINE_CHATTER_POST_DELETE"]];
    bookmarkAdd = YES;
  }
  else{
    [menuList addObject:[pData getDataForKey:@"DEFINE_CHATTER_BOOKMARK_DELETE"]];
    [menuList addObject:[pData getDataForKey:@"DEFINE_CHATTER_POST_DELETE"]];
    bookmarkAdd = NO;
  }
  [_resultTable reloadData];
}

//セル内容設定処理
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([menuList count]==0){
		return nil;
	}
	static NSString *CellIdentifier = @"CellIdentifier";
	
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  
	cell.textLabel.text = [menuList objectAtIndex:indexPath.row];
	cell.detailTextLabel.font = [UIFont systemFontOfSize:8.0f];
  
	return  cell;
}

//セルタップ時処理
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if(indexPath.row==0){
    if ([self.delegate respondsToSelector:@selector(didSelectBookmark:)]){
      [self.delegate didSelectBookmark:nil];
    }
  }
  // 削除
  else{
    if ([self.delegate respondsToSelector:@selector(didSelectDelete:)]){
      [self.delegate didSelectDelete:nil];
    }
  }
/*
  
  NSLog(@"uid %@", uId);
	if ([self.delegate respondsToSelector:@selector(didSelectMention:)]){
		[self.delegate didSelectMention:uId];
	}
 */
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
	return [menuList count];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
