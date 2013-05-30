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


#import "DashBoardNaviMenuStartDateViewController.h"
#import "DashBoardNaviMenuEndDateViewController.h"

@interface DashBoardNaviMenuStartDateViewController ()

@end

@implementation DashBoardNaviMenuStartDateViewController

NSMutableArray *yearArray;
NSMutableArray *monthArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      pData = [PublicDatas instance];
        self.title = [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_START"];
      _label.text = [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_START"];
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
  
  NSString *startYear = [dic objectForKey:@"startYear"];
  NSString *startMonth = [dic objectForKey:@"startMonth"];
  if(!startYear){
    startYear = [yearArray objectAtIndex:1];
    [dic setObject:startYear forKey:@"startYear"];
  }
  if(!startMonth){
    startMonth = [monthArray objectAtIndex:0];
    [dic setObject:startMonth forKey:@"startMonth"];
  }
  [gm saveDictionaryFroTag:[pData getDataForKey:@"tag"] Dictionary:dic];
  
  // プリセット
  if(startYear){
    for(int i=0; i<yearArray.count; i++){
      if([startYear isEqualToString:[yearArray objectAtIndex:i]]){
        [_picker selectRow:i inComponent:0 animated:NO];
        break;
      }
    }
    _label.text = [NSString stringWithFormat:@"%@ : %@", [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_START"], startYear];
  }else{
    [_picker selectRow:0 inComponent:0 animated:NO];
  }
  
  if(startMonth){
    for(int i=0; i<monthArray.count; i++){
      if([startMonth isEqualToString:[monthArray objectAtIndex:i]]){
        [_picker selectRow:i inComponent:1 animated:NO];
        break;
      }
    }
    _label.text = [NSString stringWithFormat:@"%@ / %@", _label.text, startMonth];
                   //[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_MONTH"]];
  }else{
    [_picker selectRow:0 inComponent:1 animated:NO];
  }
}

// picker
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{

    if (component == 0){
      return [NSString stringWithFormat:@"%@",[yearArray objectAtIndex:row]];
              //,[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_YEAR"]];
    }else{
      return [NSString stringWithFormat:@"%@",[monthArray objectAtIndex:row]];
              //, [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_MONTH"]];
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
  
  // データ保存
  NSString *startYear = [yearArray objectAtIndex: [_picker selectedRowInComponent:0]];
  NSString *startMonth = [monthArray objectAtIndex: [_picker selectedRowInComponent:1]];
  
  if(startYear){
    [dic setObject:startYear forKey:@"startYear"];
    if(startMonth){
      _label.text = [NSString stringWithFormat:@"%@ : %@ / %@", [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_START"],startYear,startMonth];
      [dic setObject:startMonth forKey:@"startMonth"];
    }else{
      _label.text = [NSString stringWithFormat:@"%@ : %@", [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_START"],startMonth ];//, [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_YEAR"]];
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



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
}

- (void)viewDidUnload {
  [self setPicker:nil];
  [self setLabel:nil];
  [super viewDidUnload];
}
@end
