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


#import "MemoViewController.h"
#import "MyToolBar.h"
#import "Company.h"

@interface MemoViewController ()

@end

@implementation MemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil company:(Company*)cpny
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
		cp = cpny;
  }
  return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
  
  um = [UtilManager sharedInstance];
  pData = [PublicDatas instance];
  
  navigationBar = [[UINavigationBar alloc] initWithFrame:_memoTitleBar.frame];
  
  //ナビゲーションバー　設定
	NSData *iData =[um navBarType];
	if ( [((NSString*)iData) isEqualToString:@"gray"] ) {
		[navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
		navigationBar.tintColor = [UIColor grayColor];
//    self.graphTitleView.backgroundColor = [UIColor grayColor];
//		self.storeContactHeader.backgroundColor = [UIColor grayColor];
	}
	else if ( [((NSString*)iData) isEqualToString:@"black"] ) {
		[navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
		navigationBar.tintColor = [UIColor blackColor];
//		self.storeContactHeader.backgroundColor = [UIColor blackColor];
//    self.graphTitleView.backgroundColor = [UIColor blackColor];
	}
	else {
		iData =[um navBarImage];
		if ( iData ) {
			UIImage *img = [UIImage imageWithData:iData];
			[navigationBar setBackgroundImage:img
                                                    forBarMetrics:UIBarMetricsDefault];
			
//			self.storeContactHeader.backgroundColor = [UIColor colorWithPatternImage:img];
//      self.graphTitleView.backgroundColor = [UIColor colorWithPatternImage:img];
		}
	}
  
  
  // ナビゲーションアイテムを生成
  UINavigationItem* naviItem = [[UINavigationItem alloc] initWithTitle:@""];//[pData getDataForKey:@"DEFINE_MEMO_TITLE"]];
  //UIImage *closeImg = [UIImage imageNamed:@"Close.png"];
  //UIButton *customView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
  UIButton *customView = [UIButton buttonWithType:UIButtonTypeCustom];
  customView.frame = CGRectMake(0, 0, 40, 20);
  //[customView setBackgroundImage:closeImg forState:UIControlStateNormal];
  [customView.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
  [customView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  //customView.titleLabel.text = [pData getDataForKey:@"DEFINE_MEMO_LABEL_CLOSE"];
  [customView setTitle:[pData getDataForKey:@"DEFINE_MEMO_LABEL_CLOSE"]  forState:UIControlStateNormal];
  [customView addTarget:self action:@selector(clickClose:) forControlEvents:UIControlEventTouchUpInside];
  [customView sizeToFit];
  UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
  
  //UIBarButtonItem *backButton = [[UIBarButtonItem alloc]designedBackBarButtonItemWithTitle:@"" type:1  target:self action:@selector(clickClose:)];
  
  // ナビゲーションアイテムの右側に戻るボタンを設置

  UIButton *titleView = [UIButton buttonWithType:UIButtonTypeCustom];
  titleView.frame = CGRectMake(0, 0, 100, 20);
  [titleView.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
  [titleView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  titleView.titleLabel.text = [pData getDataForKey:@"DEFINE_MEMO_TITLE"];
  [titleView setTitle:[pData getDataForKey:@"DEFINE_MEMO_TITLE"]  forState:UIControlStateNormal];
  naviItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:titleView];
  
  blackImg = [UIImage imageNamed:@"Pen_Black.png"];
  blueImg = [UIImage imageNamed:@"Pen_Blue.png"];
  redImg = [UIImage imageNamed:@"Pen_Red.png"];
  eraseImg = [UIImage imageNamed:@"Eraser.png"];
  
  // Menu
  penButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
  [penButton setBackgroundImage:blackImg forState:UIControlStateNormal];
  [penButton addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
  UIBarButtonItem* menuButton = [[UIBarButtonItem alloc] initWithCustomView:penButton];
  
  // Save
  UIImage *saveImg = [UIImage imageNamed:@"Save.png"];
  UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
  [saveBtn setBackgroundImage:saveImg forState:UIControlStateNormal];
  [saveBtn addTarget:self action:@selector(saveImage:) forControlEvents:UIControlEventTouchUpInside];
  UIBarButtonItem* saveButton  = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
  saveButton.tag = 4;
  
  UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
  
  //UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 160.0f, 44.0f)];
  MyToolBar *toolbar = [[MyToolBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 160.0f, 44.0f)];

  toolbar.backgroundColor = [UIColor clearColor];
  toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
  
  UIBarButtonItem *toolbarBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
  
  toolbar.items = [NSArray arrayWithObjects: space, menuButton,
                   saveButton, buttonItem, nil];
  
  naviItem.rightBarButtonItem = toolbarBarButtonItem;
  
  //ナビバータイトル
  /*
	self.title = [pData getDataForKey:@"DEFINE_MEMO_TITLE"];
  titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
	titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.textColor = [UIColor whiteColor];
	naviItem.titleView = titleLabel;
	titleLabel.text =self.title;
	[titleLabel sizeToFit];
  */
  // ナビゲーションバーにナビゲーションアイテムを設置
  [navigationBar pushNavigationItem:naviItem animated:YES];
  
  //Memo
  memoBoard = [[MemoBoard alloc]initWithFrame:_boardView.frame];
  memoBoard.center = _boardView.center;
  memoBoard.backgroundColor = [UIColor whiteColor];
  memoBoard.penMode = 0;
  // Penの色 最初は黒 0, 1:赤, 2:青, 3:白
  [pData setData:[NSString stringWithFormat:@"%d", memoBoard.penMode] forKey:@"tag"];
  
	[self.view addSubview:memoBoard];
  _boardView.backgroundColor = [UIColor clearColor];
  
  navigationBar.center = _memoTitleBar.center;
  [self.view addSubview:navigationBar];
  navigationBar.backgroundColor = [UIColor clearColor];
  
	// ローディングアラートを生成
	alertView = [[UIAlertView alloc] initWithTitle:[pData getDataForKey:@"DEFINE_MEMO_TITLE_LOADING"] message:nil
                                        delegate:nil cancelButtonTitle:nil otherButtonTitles:NULL];
	progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
	progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	[alertView addSubview:progress];
	[progress startAnimating];
}


// Menu表示
-(void)showMenu:(id)sender
{
  UIButton *button = (UIButton*)sender;
  
  
  @try{
    settingController = [[SettingWidthViewController alloc] initWithNibName:@"SettingWidthViewController" bundle:nil];
    settingController.delegate = self;
    
    float val = memoBoard.width0;
    /*
    switch (memoBoard.penMode) {
        // 黒の太さ
      case 0:
        val = memoBoard.width0;
        break;
        //青の太さ
      case 1:
        val = memoBoard.width1;
        break;
        //赤の太さ
      case 2:
        val = memoBoard.width2;
        break;
        // 白の太さ
      case 3:
        val = memoBoard.width3;
        break;
      default:
        val = memoBoard.width0;
        break;
    }*/
    settingController.widthSlider.value = val;
    
    //PopOverを消す
    if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
    
    pop = [[UIPopoverController alloc] initWithContentViewController:settingController];
    //pop.popoverBackgroundViewClass = [MemoPopoverBackgroundView class];
    pop.popoverContentSize = settingController.view.frame.size;
    [pop presentPopoverFromRect:CGRectMake(button.frame.origin.x+795,
                                           navigationBar.frame.origin.y + button.frame.origin.y,
                                           button.frame.size.width,
                                           button.frame.size.height)
                         inView:self.view
       permittedArrowDirections:UIPopoverArrowDirectionAny
                       animated:YES];
  }@catch (NSException *exception) {
    NSLog(@"main:Caught %@:%@", [exception name], [exception reason]);
  }
}

// delegate  色選択のコールバック
-(void)chgColor:(int)mode
{
  memoBoard.penMode = mode;
  
  float val;
  switch (mode) {
    // 黒の太さ
    case 0:
      val = memoBoard.width0;
      [penButton setBackgroundImage:blackImg forState:UIControlStateNormal];
      break;
      //赤の太さ
    case 1:
      val = memoBoard.width1;
      [penButton setBackgroundImage:redImg forState:UIControlStateNormal];
      break;
      //青の太さ
    case 2:
      val = memoBoard.width2;
      [penButton setBackgroundImage:blueImg forState:UIControlStateNormal];
      break;
      // 白の太さ
    case 3:
      val = memoBoard.width3;
      [penButton setBackgroundImage:eraseImg forState:UIControlStateNormal];
      break;
    default:
      val = memoBoard.width0;
      [penButton setBackgroundImage:blackImg forState:UIControlStateNormal];
      break;
  }
  settingController.widthSlider.value = val;
  
  //PopOverを消す
  if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
}

// delegate  線の太さ設定のコールバック
- (void) chgSlider:(CGFloat)fVol
{
  memoBoard.width0 = fVol;
  memoBoard.width1 = fVol;
  memoBoard.width2 = fVol;
  memoBoard.width3 = fVol;
  /*
  switch (memoBoard.penMode) {
      // 黒の太さ
    case 0:
      memoBoard.width0 = fVol;
      break;
      //青の太さ
    case 1:
      memoBoard.width1 = fVol;
      break;
      //赤の太さ
    case 2:
      memoBoard.width2 = fVol;
      break;
      // 白の太さ
    case 3:
      memoBoard.width3 = fVol;
      break;
    default:
      memoBoard.width0 = fVol;
      break;
  }*/
}

// close処理
- (void)clickClose:(id)sender
{
  //[self dismissViewControllerAnimated:YES completion:nil];
  
  float w = [UIScreen mainScreen].bounds.size.width;
  float h = [UIScreen mainScreen].bounds.size.height;
  
  [self.view setClipsToBounds:YES];
  
  // フリップ移動
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:0.7];
  self.view.alpha = 0.0;
  //self.view.frame = CGRectMake(w/2-self.view.bounds.size.width/2, h/2-self.view.bounds.size.height/2, 200,120);
  //self.view.center = CGPointMake(w/2-self.view.bounds.size.width/2, h/2-self.view.bounds.size.height/2);
  
  [self.view setFrame:CGRectMake(w+150-self.view.bounds.size.width/2, h/2-self.view.bounds.size.height/2, 200,120)];
  
  [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(viewDisappear:finished:context:)];
  [UIView commitAnimations];
  
}

- (void)viewDisappear:(NSString *)animationID finished:(NSNumber *) finished context:(void *) context
{
  [self.view removeFromSuperview];
  
  // delegateのメソッドを起動
  if ([self.delegate respondsToSelector:@selector(didClose:)]){
		[self.delegate didClose:nil];
	}
}


-(void)saveImage:(id)sender
{
  UIAlertView *alertConfirm = [[UIAlertView alloc]
               initWithTitle: [pData getDataForKey:@"DEFINE_MEMO_TITLE_CONFIRM"]
               message:[pData getDataForKey:@"DEFINE_MEMO_TITLE_CONFIRM_MESSAGE"]
               delegate:self
               cancelButtonTitle:[pData getDataForKey:@"DEFINE_MEMO_TITLE_CONFIRM_CANCEL"]
               otherButtonTitles:[pData getDataForKey:@"DEFINE_MEMO_TITLE_CONFIRM_OK"], nil ];
  [alertConfirm show];
}

//アラートのボタン押下デリゲート
-(void)alertView:(UIAlertView*)alertViewButon
clickedButtonAtIndex:(NSInteger)buttonIndex
{
  
  switch (buttonIndex) {
    case 0:
      break;
    case 1:
      [self saveImageDo:nil];
      break;
    default:
      break;
  }
}

// 手書きメモを画像にしてSFに送信
-(void)saveImageDo:(id)sender
{
  @try{
  // ローディング
  [self alertShow];
  
  NSString *opId = cp.company_id;
  
  //開始・終了時間
  NSDate *stJPN= [NSDate dateWithTimeIntervalSinceNow:0];
  
  //オブジェクト名に使用する為のフォーマット
  NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
  [fmt setDateFormat:@"yyyy-MM-dd_HH:mm:ss"];
  
  //日付を文字列化
  NSString *sttForObjName = [fmt stringFromDate:stJPN];
  
  NSString *path2 = @"/services/data/v26.0/sobjects/Attachment/";
  NSString *title2 = [NSString stringWithFormat:@"%@_%@.PNG",
                      [pData getDataForKey:@"DEFINE_MEMO_FILE"],
                      sttForObjName];
    
  //メモを画像化し、NSData => Base64 Encodeする
  UIGraphicsBeginImageContext(memoBoard.frame.size);
  [memoBoard.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  NSData *sendData = UIImagePNGRepresentation(image);
  NSString *encodedString = [self base64forData:sendData];
  NSDictionary *param2;
  param2 = [NSDictionary dictionaryWithObjectsAndKeys:	title2,@"Name",
            encodedString,@"Body",
            opId,@"ParentId",
            nil];
  
  SFRestRequest *req2 =[SFRestRequest requestWithMethod:SFRestMethodPOST path:path2 queryParams:param2];
  
  [[SFRestAPI sharedInstance] sendRESTRequest:req2
                                      failBlock:^(NSError *e) {
                                        //失敗アラート
                                        alertView = [[UIAlertView alloc]
                                                     initWithTitle:[pData getDataForKey:@"DEFINE_MEMO_TITLE_SAVE_ERROR"]
                                                     message:[pData getDataForKey:@"DEFINE_MEMO_TITLE_SAVE_MESSAGE_ERROR"]
                                                     delegate:nil
                                                     cancelButtonTitle:[pData getDataForKey:@"DEFINE_MEMO_TITLE_SAVE_OK_ERROR"]
                                                     otherButtonTitles: nil ];
                                        [alertView show];
                                        NSLog(@"FAILWHALE with error: %@", [e description] );
                                      }
                                  completeBlock:^(id jsonResponse){
                                    // アラートを閉じる
                                    if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
                                    NSDictionary *dict = (NSDictionary *)jsonResponse;
                                    NSLog(@"%@",dict);
                                    
                                    //成功アラート
                                    alertView = [[UIAlertView alloc]
                                                 initWithTitle:[pData getDataForKey:@"DEFINE_MEMO_TITLE_SAVE_SUCCESS"]
                                                 message:[pData getDataForKey:@"DEFINE_MEMO_TITLE_SAVE_MESSAGE_SUCCESS"]
                                                 delegate:nil
                                                 cancelButtonTitle:[pData getDataForKey:@"DEFINE_MEMO_TITLE_SAVE_OK_SUCCESS"]
                                                 otherButtonTitles:nil];
                                    [alertView show];
                                  }
   ];
   
  }@catch (NSException *exception) {
    NSLog(@"main:Caught %@:%@", [exception name], [exception reason]);
  }
}

-(NSString*)base64forData:(NSData*)theData {
	const uint8_t* input = (const uint8_t*)[theData bytes];
	NSInteger length = [theData length];
	
	static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
	
	NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
	uint8_t* output = (uint8_t*)data.mutableBytes;
	
	NSInteger i;
	for (i=0; i < length; i += 3) {
		NSInteger value = 0;
		NSInteger j;
		for (j = i; j < (i + 3); j++) {
			value <<= 8;
			
			if (j < length) {
				value |= (0xFF & input[j]);
			}
		}
		
		NSInteger theIndex = (i / 3) * 4;
		output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
		output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
		output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
		output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
	}
	
	return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
  if ((orientation == UIInterfaceOrientationLandscapeLeft) ||
      (orientation == UIInterfaceOrientationLandscapeRight )){
    return YES;
  }
  return NO;
}

- (void)viewDidUnload {
  [self setBoardView:nil];
  [self setMemoTitleBar:nil];
  [super viewDidUnload];
}


@end
