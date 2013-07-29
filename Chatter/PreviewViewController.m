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

#import "PreviewViewController.h"
#import "PublicDatas.h"

@interface PreviewViewController ()

@end

@implementation PreviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
		_tag = 65534;
  }
	self.withCancelBtn = NO;
  return self;
}

-(void)setContents:(UIView *)contents
{
	[self.view addSubview:contents];
	
	if ( self.withCancelBtn == YES ){
    PublicDatas *pData = [PublicDatas instance];
		UIButton *attachCancelBtn = [UIButton buttonWithType:100];
		[attachCancelBtn setTitle:[pData getDataForKey:@"DEFINE_CHATTER_LABEL_FILEADD_CANCEL"] forState:UIControlStateNormal];
		attachCancelBtn.frame = CGRectMake(5,contents.frame.size.height+10, 100, 30);
		[attachCancelBtn addTarget:self action:@selector(attachCancelPushed) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:attachCancelBtn];
		self.view.frame = CGRectMake(0, 0, contents.frame.size.width,contents.frame.size.height+40);
	}
	else {
		self.view.frame = CGRectMake(0, 0, contents.frame.size.width,contents.frame.size.height);
	}
	
	self.contentSizeForViewInPopover = self.view.frame.size;
}

-(void)attachCancelPushed
{
	if ([self.delegate respondsToSelector:@selector(didAttachAborted:)]){
		[self.delegate didAttachAborted:_tag];
	}
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


-(void)viewWillDisappear:(BOOL)animated
{
}

- (void)viewDidUnload {
  [self setDelegate:nil];
  [self setContents:nil];
  [self setWithCancelBtn:0];
	[super viewDidUnload];
}

@end
