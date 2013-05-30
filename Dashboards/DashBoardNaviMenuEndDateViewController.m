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


#import "DashBoardNaviMenuEndDateViewController.h"

@interface DashBoardNaviMenuEndDateViewController ()

@end

@implementation DashBoardNaviMenuEndDateViewController

NSMutableArray *yearArray;
NSMutableArray *monthArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      pData = [PublicDatas instance];
      self.title = [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_END"];
      _label.text = [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_END"];
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
  CGSize size = CGSizeMake(300, 380); // size of view in popover
  self.contentSizeForViewInPopover = size;
  
  NSDate *date = [NSDate date];
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *comps;
  
  // 年月日をとりだす
  comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                      fromDate:date];
  NSString *year = [NSString stringWithFormat:@"%d", [comps year]];
  
  // 1年前
  comps = [[NSDateComponents alloc] init];
  [comps setYear:-1];
  NSDate *date1 = [calendar dateByAddingComponents:comps toDate:date options:0];
  NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
  [inputDateFormatter setDateFormat:@"yyyy"];
  NSString *lastyear = [inputDateFormatter stringFromDate:date1];
  
  yearArray = [[NSMutableArray alloc] initWithObjects:lastyear, year, nil];
  monthArray = [[NSMutableArray alloc] init];
  for(int i=1; i<13; i++){
    [monthArray addObject:[NSString stringWithFormat:@"%d",i]];
  }
  
  [_picker selectRow:1 inComponent:0 animated:NO];
  pData = [PublicDatas instance];
  
  // タグごとのデータを取得
  NSMutableDictionary *dic = [gm getDictionaryForTag:[pData getDataForKey:@"tag"]];
  
  NSString *endYear = [dic objectForKey:@"endYear"]; 
  NSString *endMonth = [dic objectForKey:@"endMonth"]; 
  if(!endYear){
    endYear = [yearArray objectAtIndex:1];
    [dic setObject:endYear forKey:@"endYear"];
  }
  if(!endMonth){
    endMonth = [monthArray objectAtIndex:0];
    [dic setObject:endMonth forKey:@"endMonth"];
  }
  
  [gm saveDictionaryFroTag:[pData getDataForKey:@"tag"] Dictionary:dic];
  // プリセット
  if(endYear){
    for(int i=0; i<yearArray.count; i++){
      if([endYear isEqualToString:[yearArray objectAtIndex:i]]){
        [_picker selectRow:i inComponent:0 animated:NO];
        break;
      }
    }
    _label.text = [NSString stringWithFormat:@"%@ : %@", [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_END"], endYear];
  }else{
    [_picker selectRow:0 inComponent:0 animated:NO];
  }
  
  if(endMonth){
    for(int i=0; i<monthArray.count; i++){
      if([endMonth isEqualToString:[monthArray objectAtIndex:i]]){
        [_picker selectRow:i inComponent:1 animated:NO];
        break;
      }
    }
    _label.text = [NSString stringWithFormat:@"%@ / %@", _label.text, endMonth];
  }else{
    [_picker selectRow:0 inComponent:1 animated:NO];
  }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// picker
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
  
  if (component == 0){
    return [NSString stringWithFormat:@"%@",[yearArray objectAtIndex:row]];
  }else{
    return [NSString stringWithFormat:@"%@",[monthArray objectAtIndex:row]];
  }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
  return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component{
  if (component == 0){
    return [yearArray count];
  }else{
    return [monthArray count];
  }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
  // タグごとのデータを取得
  NSMutableDictionary *dic = [gm getDictionaryForTag:[pData getDataForKey:@"tag"]];
  
  NSString *endYear = [yearArray objectAtIndex: [_picker selectedRowInComponent:0]];
  NSString *endMonth = [monthArray objectAtIndex: [_picker selectedRowInComponent:1]];
  
  pData = [PublicDatas instance];
  
  // 保存
  if(endYear){
    [dic setObject:endYear forKey:@"endYear"];
    if(endMonth){
      _label.text = [NSString stringWithFormat:@"%@ : %@ / %@", [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_END"],endYear, endMonth];
      [dic setObject:endMonth forKey:@"endMonth"];
    }else{
      _label.text = [NSString stringWithFormat:@"%@ : %@",[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_END"], endMonth];
    }
    [gm saveDictionaryFroTag:[pData getDataForKey:@"tag"] Dictionary:dic];
  }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	if (component == 0){
		return  140.0;
	}else{
		return 100.0;
  }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
  return 40.0;
}



- (void)dealloc {
}

- (void)viewDidUnload {
  [self setPicker:nil];
  [self setLabel:nil];
  [super viewDidUnload];
}
@end
