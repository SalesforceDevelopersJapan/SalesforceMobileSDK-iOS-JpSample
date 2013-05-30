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

#import "SelectViewController.h"

@implementation SelectViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//		optionArray = [NSMutableArray array];
		_optionArray = [NSArray array];
		self.view.frame = CGRectMake(0,0,300,300);
		_resultTable = [[UITableView alloc]initWithFrame:CGRectMake(0,0,300,300) style:UITableViewStylePlain];
		_resultTable.delegate = self;
		_resultTable.dataSource = self;
		[self.view addSubview:_resultTable];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

//セル内容設定処理
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([_optionArray count]==0){
		return nil;
	}
	static NSString *CellIdentifier = @"CellIdentifier";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

	UIView *cellView = [[UIView alloc]init];
	if ( [self.imageArray count] == [self.optionArray count] ){
		cellView.frame = CGRectMake(0, 0, _resultTable.frame.size.width, 60);
		UIImage *img = [self.imageArray objectAtIndex:indexPath.row];
		UIImageView *imgV = [[UIImageView alloc]init];
		imgV.frame = CGRectMake(0,0,50,50);
		imgV.image = [self resizeImage:img Rect:imgV.frame];
		imgV.frame = [self allignCenter:imgV.frame size:imgV.image.size];

		CGRect rect = imgV.frame;
		rect.origin.y += 10;
		imgV.frame = rect;
		
		UILabel *txtLbl = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, _resultTable.frame.size.width - 60, 60)];
		txtLbl.font = [UIFont boldSystemFontOfSize:16.0f];
		txtLbl.text = [_optionArray objectAtIndex:indexPath.row];
	
		[cellView addSubview:imgV];
		[cellView addSubview:txtLbl];
		[cell addSubview:cellView];
	}
	else {
		cell.textLabel.text = [_optionArray objectAtIndex:indexPath.row];
		cell.detailTextLabel.font = [UIFont systemFontOfSize:8.0f];
	}
	
	return  cell;
}

//セルタップ時処理
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//	if ([self.delegate respondsToSelector:@selector(didSelectOption::)]){
		[self.delegate didSelectOption:indexPath.row tag:(int)self.tag];
//	}
}

//UIImage:imgがRectより大きい場合リサイズする
-(id)resizeImage:(UIImage*)img Rect:(CGRect)Rect
{
	if (( img.size.height > Rect.size.height) || ( img.size.width > Rect.size.width)) {
		NSLog(@"%f : %f",img.size.width,img.size.height);
		float asp = (float)img.size.width / (float)img.size.height;
		CGRect r = CGRectMake(0,0,0,0);
		if ( img.size.width > img.size.height) {
			r.size.width = Rect.size.width;
			r.size.height = r.size.width / asp;
		}
		else {
			r.size.height = Rect.size.height;
			r.size.width = r.size.height * asp;
		}
		
		UIGraphicsBeginImageContext(r.size);
		[img drawInRect:CGRectMake(0,0,r.size.width,r.size.height)];
		img = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
	return img;
}

-(CGRect)allignCenter:(CGRect)rect1 size:(CGSize)siz
{
	CGRect ret;
	ret.origin.x = rect1.origin.x + (( rect1.size.width - siz.width ) / 2.0f );
	ret.origin.y = rect1.origin.y + (( rect1.size.height - siz.height) / 2.0f );
	ret.size = siz;
	
	return ret;
}


-(void)setOpt:(NSMutableArray *)opt
{
	self.optionArray = opt;
	[_resultTable reloadData];
}
-(void)setImg:(NSMutableArray *)imgArray
{
	self.imageArray = imgArray;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return  70.0;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_optionArray count];
}
-(void)setSize:(CGSize)size
{
	CGRect rect = self.view.frame;
	rect.size = size;
	self.view.frame = rect;

	rect = _resultTable.frame;
	rect.size = size;
	_resultTable.frame = rect;
}

- (void)viewDidUnload {
  [self setImageNameArray:nil];
  [self setOptionArray:nil];
  [self setImageArray:nil];
  [self setResultTable:nil];
  [self setDelegate:nil];
  [self setTag:0];
  [super viewDidUnload];
}

@end
