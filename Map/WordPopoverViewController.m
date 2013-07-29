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


#import "WordPopoverViewController.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface WordPopoverViewController ()

@end

@implementation WordPopoverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    
    _pData = [PublicDatas instance];
    NSString *isKeyboard = [_pData getDataForKey:@"isKeyboard"];
    CGRect frame_size_height = CGRectZero;
    CGRect table_size_height = CGRectZero;
    if([isKeyboard isEqual: @"YES"]){
      frame_size_height = CGRectMake(0,50,300,270);
      table_size_height = CGRectMake(0,50,300,220);
    }else if ([isKeyboard isEqual: @"NO"]){
      frame_size_height = CGRectMake(0,50,300,520);
      table_size_height = CGRectMake(0,50,300,470);
    }
    
    // Custom initialization
    self.view.frame = frame_size_height;
    UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0,0,300,50)];
	  titleLbl.text = [_pData getDataForKey:@"DEFINE_MAP_HISTORY"];
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

-(void)setSearchWordList:(NSMutableArray *)list
{
	_searchWordList = [self reversedArray :list];
	[_resultTable reloadData];
}

// 配列を逆に読む
- (NSMutableArray *)reversedArray :(NSMutableArray *)arr{
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:[arr count]];
  NSEnumerator *enumerator = [arr reverseObjectEnumerator];
  for (id element in enumerator) {
    [array addObject:element];
  }
  return array;
}

- (void)viewDidLoad
{
  //searchWordList = [[NSMutableArray alloc]init];
  
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  
  um = [UtilManager sharedInstance];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [_searchWordList count];
}

//セル内容設定処理
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([_searchWordList count]==0){
		return nil;
	}
	static NSString *CellIdentifier = @"CellIdentifier";
	
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		
  }
  
	cell.textLabel.text = [_searchWordList objectAtIndex:indexPath.row];
	cell.detailTextLabel.font = [UIFont systemFontOfSize:8.0f];
  //	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return  cell;
}


//セルタップ時処理
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *word  = [_searchWordList objectAtIndex:indexPath.row];
  
  if ([self.delegate respondsToSelector:@selector(didSelectWord:)]){
    [self.delegate didSelectWord:word];
  }
  
}

// セルスワイプで削除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  [um deleteSearchWordListByWord:[_searchWordList objectAtIndex:indexPath.row]];
  [_searchWordList removeObjectAtIndex:indexPath.row];
  [tableView reloadData];
  [self.delegate didDeleteWord];
}

- (void)dealloc {
}



- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
