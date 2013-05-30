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


#import "FileNameInputViewController.h"
#import "PublicDatas.h"

@implementation FileNameInputViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
  PublicDatas *pData = [PublicDatas instance];
  
	UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(1,1, 200, 20)];
	[title setText:[pData getDataForKey:@"DEFINE_CHATTER_LABEL_FILENAME"]];
	[title setBackgroundColor:[UIColor clearColor]];
	[title setTextColor:[UIColor whiteColor]];
	[title setTextAlignment:NSTextAlignmentCenter];
	
	_fileNameView = [[UITextField alloc]initWithFrame:CGRectMake(1, 23, 200, 18)];
	_fileNameView.backgroundColor = [UIColor whiteColor];
	UIButton *okBtn = [UIButton buttonWithType:100];
	[okBtn setTitle:[pData getDataForKey:@"DEFINE_CHATTER_LABEL_OK"] forState:UIControlStateNormal];
	okBtn.frame = CGRectMake( 1, 55, 80, 30);
	[self.view addSubview:_fileNameView];
	[okBtn addTarget:self action:@selector(okPushed) forControlEvents:UIControlEventTouchUpInside];
		
	UIButton *cancelBtn = [UIButton buttonWithType:100];
	[cancelBtn setTitle:[pData getDataForKey:@"DEFINE_CHATTER_LABEL_CANCEL"] forState:UIControlStateNormal];
	cancelBtn.frame = CGRectMake( 120, 55, 80, 30);
	[cancelBtn addTarget:self action:@selector(cancelPushed) forControlEvents:UIControlEventTouchUpInside];

	[self.view addSubview:title];
	[self.view addSubview:_fileNameView];
	[self.view addSubview:okBtn];
	[self.view addSubview:cancelBtn];
	
	self.view.frame = CGRectMake(0,0,200,90);
}

-(BOOL)chkFileName:(NSString*)str
{
	const char* cp = [str UTF8String];

	if (cp == NULL || cp[0] == '\0')
	{
		return NO;
	}
	
	const char *pt = cp;
	while (*pt != '\0' ) {
		char c = *pt++;
		// 使用できない文字ではないか
        if (/*( c <= 31 ) ||*/ ( c == '<' ) || ( c == '>' ) || ( c == ':')
			|| ( c == '"' ) || ( c == '/' ) || ( c == '\\' ) || ( c == '|' )
			|| ( c == '*' ) || ( c == '?' )) {
			return NO;
		}
	}
	return YES;
}
-(void)okPushed
{
	if ( NO == [self chkFileName:_fileNameView.text]){
		NSLog(@"INVALID FILENAME");

		if ([self.delegate respondsToSelector:@selector(invalidFileName:)]){
			[self.delegate invalidFileName:self.fileName];
		}

	}
	else
	if ([self.delegate respondsToSelector:@selector(didFinishInput:)]){
		[self.delegate didFinishInput:_fileNameView.text];
	}
}
-(void)cancelPushed
{
	if ([self.delegate respondsToSelector:@selector(didAttachCanceld)]){
		[self.delegate didAttachCanceld];
	}
}

-(void)viewDidAppear:(BOOL)animated
{
	_fileNameView.text = self.fileName;
	[self.fileNameView becomeFirstResponder];
}

- (void)viewDidUnload {
  [self setDelegate:nil];
  [self setFileName:nil];
  [self setFileNameView:nil];
	[super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
