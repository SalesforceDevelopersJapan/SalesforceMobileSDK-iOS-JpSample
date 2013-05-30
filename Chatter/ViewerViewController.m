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

#import "ViewerViewController.h"
#import "UIBarButtonItem+DesignedButton.h"
#import "PublicDatas.h"

@implementation ViewerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		_disableIndicator = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.webV.delegate = self;

	//ナビゲーションバーに「戻る」ボタン配置
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc]designedBackBarButtonItemWithTitle:@"" type:1  target:self action:@selector(back)];
	self.navigationItem.leftBarButtonItem = backButton;
	
	
	// ローディングアラートを生成
  PublicDatas *pData = [PublicDatas instance];
	alertView = [[UIAlertView alloc] initWithTitle:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_LOADING"] message:nil
										  delegate:nil cancelButtonTitle:nil otherButtonTitles:NULL];
	progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
	progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	[alertView addSubview:progress];
	[progress startAnimating];
}
-(void)back
{
	[self.navigationController popViewControllerAnimated:YES];
}
-(void)viewDidAppear:(BOOL)animated
{
	[self.webV loadRequest:_req];
	self.webV.scalesPageToFit = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// インジケータ表示
-(void)webViewDidStartLoad:(UIWebView*)webView{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

	// ローディング
	if ( NO == _disableIndicator ) {
		[self alertShow];
	}
}


// ページ読込完了時にインジケータを非表示にする
-(void)webViewDidFinishLoad:(UIWebView*)webView{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	// アラートを閉じる
	if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
}
// ローディングアラートの表示
-(void)alertShow
{
	[NSTimer scheduledTimerWithTimeInterval:30.0f
									 target:self
								   selector:@selector(performDismiss:)
								   userInfo:alertView repeats:NO];
	[alertView show];
}
// アラートを閉じるメソッド
- (void)performDismiss:(NSTimer *)theTimer
{
	alertView = [theTimer userInfo];
	[alertView dismissWithClickedButtonIndex:0 animated:NO];
}
- (void)viewDidUnload {
	[self setReq:nil];
	[self setWebV:nil];
  [self setDelegate:nil];
	[super viewDidUnload];
}
-(void)viewDidDisappear:(BOOL)animated
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	if ([self.delegate respondsToSelector:@selector(viewWillClose)]){
		[self.delegate viewWillClose];
	}
}
@end
