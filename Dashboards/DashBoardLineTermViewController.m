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

#import "DashBoardLineTermViewController.h"

@interface DashBoardLineTermViewController ()

@end

@implementation DashBoardLineTermViewController

NSArray *termArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      pData = [PublicDatas instance];
        // Custom initialization
      self.title = [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_TERM"];
      gm = [GraphDataManager sharedInstance];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload {
  [self setPicker:nil];
  [self setLabel:nil];
	[super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated
{
  CGSize size = CGSizeMake(300, 400); // size of view in popover
  self.contentSizeForViewInPopover = size;
  
  pData = [PublicDatas instance];
  termArray = @[//@"年間", @"四半期", @"前四半期"];
  [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_YEARTERM"],
  [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_QTERM"],
  [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_PREQTERM"] ];
  
  NSMutableDictionary *dic = [gm getDictionaryForTag:[pData getDataForKey:@"tag"]];
  
  NSString *lineterm = [dic objectForKey:@"lineTerm"];
  if(!lineterm){
    lineterm = [termArray objectAtIndex:0];
    [dic setObject:lineterm forKey:@"lineTerm"];
  }
  if(lineterm){
    for(int i=0; i<termArray.count; i++){
      if([lineterm isEqualToString:[termArray objectAtIndex:i]]){
        [_picker selectRow:i inComponent:0 animated:NO];
        break;
      }
    }
    _label.text = [NSString stringWithFormat:@"%@ : %@", [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_TERM"], lineterm];
  }else{
    [_picker selectRow:0 inComponent:0 animated:NO];
    [dic setObject:[termArray objectAtIndex:0] forKey:@"lineTerm"];
  }
  [gm saveDictionaryFroTag:[pData getDataForKey:@"tag"] Dictionary:dic];
}

// picker
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
  
  return [termArray objectAtIndex:row];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
  return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component{
  return [termArray count];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
  
  _label.text = [NSString stringWithFormat:@"%@ : %@", [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_TERM"],[termArray objectAtIndex: [_picker selectedRowInComponent:0]]];
  
  NSMutableDictionary *dic = [gm getDictionaryForTag:[pData getDataForKey:@"tag"]]; 
  [dic setObject:[termArray objectAtIndex: [_picker selectedRowInComponent:0]] forKey:@"lineTerm"];
  //NSLog(@"%@", dic);
  [gm saveDictionaryFroTag:[pData getDataForKey:@"tag"] Dictionary:dic];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
  return  240.0;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
