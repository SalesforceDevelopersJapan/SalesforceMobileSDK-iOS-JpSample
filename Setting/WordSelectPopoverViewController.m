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



#import "WordSelectPopoverViewController.h"
#import "PublicDatas.h"

@interface WordSelectPopoverViewController ()

@end

@implementation WordSelectPopoverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      PublicDatas *pData = [PublicDatas instance];
      textList = [[NSMutableArray alloc] init];
      CGRect frame_size_height = CGRectZero ;
      CGRect table_size_height = CGRectZero ;
      frame_size_height = CGRectMake(0,50,300,520);
      table_size_height = CGRectMake(0,50,300,470);
      
      self.view.frame = frame_size_height;
      UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(0,0,300,50)];
      titleLbl.text = [pData getDataForKey:@"DEFINE_SETTING_WORDPOPOVER_TITLE"];
      titleLbl.backgroundColor = [UIColor blackColor];
      [titleLbl setTextAlignment:NSTextAlignmentCenter];
      
      titleLbl.textColor = [UIColor whiteColor];
      [titleLbl setFont:[UIFont systemFontOfSize:25]];
      [self.view addSubview:titleLbl];
      textFileTable = [[UITableView alloc]initWithFrame:table_size_height style:UITableViewStylePlain];
      textFileTable.delegate = self;
      textFileTable.dataSource = self;
      [self.view addSubview:textFileTable];
      
      [self readTextList];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)readTextList
{
  // ドキュメントディレクトリ読み込み
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
  // ファイル一覧
  NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
  
  // ファイル配列をループ
  for (NSString *file in files) {
    
    //NSLog(@"file : %@", file);
    [textList addObject:file];
  }
  
  // テーブル再読み込み
  [textFileTable reloadData];
  
}

//セル内容設定処理
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

	static NSString *CellIdentifier = @"CellIdentifier";
	
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		
  }
  cell.textLabel.text = [textList objectAtIndex:indexPath.row];
	return  cell;
}


//セルタップ時処理
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *fileName = [textList objectAtIndex:indexPath.row];
	if ([self.delegate respondsToSelector:@selector(didSelectTextFile:)]){
		[self.delegate didSelectTextFile:fileName];
	}
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [textList count];
}


- (void)viewDidUnload {
	[self setDelegate:nil];
	[super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
