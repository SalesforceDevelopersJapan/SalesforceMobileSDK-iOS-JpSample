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

#import "SettingWidthViewController.h"

@interface SettingWidthViewController ()

@end

@implementation SettingWidthViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      self.view.frame = CGRectMake(0,0,290,120);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
  
  um = [UtilManager sharedInstance];
  
  
  [self.view addSubview:[self buildBlackBtnForBlack]];
  [self.view addSubview:[self buildRedBtnForBlack]];
  [self.view addSubview:[self buildBlueBtnForBlack]];
  [self.view addSubview:[self buildEraseBtnForBlack]];
  
  _widthSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 80, 240.0f, 28.0f)];
  
  _widthSlider.minimumValue = 0.5f;
  _widthSlider.maximumValue = 20.0f;
  
  // 90度まわす。
  //_widthSlider.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
  //_widthSlider.center = self.view.center;
  
  [_widthSlider addTarget:self action:@selector(chgSlider:) forControlEvents:UIControlEventValueChanged];
  
  [self.view addSubview:_widthSlider];
  
  //self.view.frame = CGRectMake(0,0,60,200);
}

-(UIButton*)buildBlackBtnForBlack{
  
  UIView *btnImg = [[UIView alloc]initWithFrame:CGRectMake(0,0, 60, 60)];
  btnImg.backgroundColor = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];
  NSData *idata = UIImagePNGRepresentation([um convViewToImage:btnImg]);
  
	UIButton *blackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[blackBtn setBackgroundImage:[UIImage imageWithData:idata] forState:UIControlStateNormal];
	blackBtn.frame = CGRectMake(10,10, 60,60);
	blackBtn.backgroundColor = [UIColor grayColor];
	[blackBtn addTarget:self action:@selector(didSelectColor:) forControlEvents:UIControlEventTouchUpInside];
	blackBtn.tag = 0;
  
	CGSize size = CGSizeMake(5.0, 5.0);
	[um makeViewRound: blackBtn corners:UIRectCornerAllCorners size:&size];
	
	return blackBtn;
}

-(UIButton*)buildRedBtnForBlack{
  
  UIView *btnImg = [[UIView alloc]initWithFrame:CGRectMake(0,0, 60, 60)];
  btnImg.backgroundColor = [UIColor colorWithRed:1.00 green:0.00 blue:0.00 alpha:1.0];
  NSData *idata = UIImagePNGRepresentation([um convViewToImage:btnImg]);
  
	UIButton *redBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[redBtn setBackgroundImage:[UIImage imageWithData:idata] forState:UIControlStateNormal];
	redBtn.frame = CGRectMake(80,10, 60,60);
	redBtn.backgroundColor = [UIColor grayColor];
	[redBtn addTarget:self action:@selector(didSelectColor:) forControlEvents:UIControlEventTouchUpInside];
	redBtn.tag = 1;
  
	CGSize size = CGSizeMake(5.0, 5.0);
	[um makeViewRound: redBtn corners:UIRectCornerAllCorners size:&size];
	
	return redBtn;
}

-(UIButton*)buildBlueBtnForBlack{
  
  UIView *btnImg = [[UIView alloc]initWithFrame:CGRectMake(0,0, 60, 60)];
  btnImg.backgroundColor = [UIColor colorWithRed:0.00 green:0.00 blue:1.00 alpha:1.0];
  NSData *idata = UIImagePNGRepresentation([um convViewToImage:btnImg]);
  
	UIButton *blueBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[blueBtn setBackgroundImage:[UIImage imageWithData:idata] forState:UIControlStateNormal];
	blueBtn.frame = CGRectMake(150,10, 60,60);
	blueBtn.backgroundColor = [UIColor grayColor];
	[blueBtn addTarget:self action:@selector(didSelectColor:) forControlEvents:UIControlEventTouchUpInside];
	blueBtn.tag = 2;
  
	CGSize size = CGSizeMake(5.0, 5.0);
	[um makeViewRound: blueBtn corners:UIRectCornerAllCorners size:&size];
	
	return blueBtn;
}

-(UIButton*)buildEraseBtnForBlack{
  
  UIView *btnImg = [[UIView alloc]initWithFrame:CGRectMake(0,0, 60, 60)];
  btnImg.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];
  NSData *idata = UIImagePNGRepresentation([um convViewToImage:btnImg]);
  
	UIButton *eraseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[eraseBtn setBackgroundImage:[UIImage imageWithData:idata] forState:UIControlStateNormal];
	eraseBtn.frame = CGRectMake(220,10, 60,60);
	eraseBtn.backgroundColor = [UIColor grayColor];
	[eraseBtn addTarget:self action:@selector(didSelectColor:) forControlEvents:UIControlEventTouchUpInside];
	eraseBtn.tag = 3;
  
	CGSize size = CGSizeMake(5.0, 5.0);
	[um makeViewRound: eraseBtn corners:UIRectCornerAllCorners size:&size];
	
	return eraseBtn;
}

// color
-(void)didSelectColor:(id)sender
{
  UIButton *button =(UIButton*)sender;
  int tag = button.tag;
  
  if ([self.delegate respondsToSelector:@selector(chgColor:)]){
    [self.delegate chgColor:tag];
  }
}

// slider
-(void)chgSlider:(UISlider*)slider{
	if ([self.delegate respondsToSelector:@selector(chgSlider:)]){
		[self.delegate chgSlider:slider.value];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
