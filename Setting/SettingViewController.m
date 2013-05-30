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


#import "SettingViewController.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "UIBarButtonItem+DesignedButton.h"
#import "PublicDatas.h"
#import "WordSelectPopoverViewController.h"
#import "AppDelegate.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      pData = [PublicDatas instance];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
  
	um = [UtilManager sharedInstance];
  
	// 角丸
	CGSize size = CGSizeMake(5.0, 5.0);
	[um makeViewRound:_btn1Image corners:UIRectCornerAllCorners size:&size];
	[um makeViewRound:_btn2Image corners:UIRectCornerAllCorners size:&size];
	[um makeViewRound:_btn3Image corners:UIRectCornerAllCorners size:&size];
	[um makeViewRound:_btn4Image corners:UIRectCornerAllCorners size:&size];
	[um makeViewRound:_btn5Image corners:UIRectCornerAllCorners size:&size];
	[um makeViewRound:_btn6Image corners:UIRectCornerAllCorners size:&size];
	
	//テキスト設定
	[self bldTextLabel];
	
	// ローディングアラートを生成
	alertView = [[UIAlertView alloc] initWithTitle:[pData getDataForKey:@"DEFINE_SETTING_WORD_LOADING"] message:nil
										  delegate:nil cancelButtonTitle:nil otherButtonTitles:NULL];
	progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
	progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	[alertView addSubview:progress];
	[progress startAnimating];
  
  i= 0;

}
-(void)bldTextLabel
{
	pData = [PublicDatas instance];
	self.title = [pData getDataForKey:@"DEFINE_SETTING_TITLE"];
	titleLabel.text = self.title;
	[titleLabel sizeToFit];
	_textLabel.text = [pData getDataForKey:@"DEFINE_SETTING_TEXTLABEL"];
	
	[_backGroundLabel setText:[pData getDataForKey:@"DEFINE_SETTING_BACKGRNDLABEL"]];
	[_navBarLabel setText:[pData getDataForKey:@"DEFINE_SETTING_NAVBARLABEL"]];
	[_logoLabel setText:[pData getDataForKey:@"DEFINE_SETTING_LOGOLABEL"]];
	[_btn1Label setText:[pData getDataForKey:@"DEFINE_SETTING_BTN1LABEL"]];
	[_btn2Label setText:[pData getDataForKey:@"DEFINE_SETTING_BTN2LABEL"]];
	[_btn3Label setText:[pData getDataForKey:@"DEFINE_SETTING_BTN3LABEL"]];
	[_btn4label setText:[pData getDataForKey:@"DEFINE_SETTING_BTN4LABEL"]];
	[_btn5Label setText:[pData getDataForKey:@"DEFINE_SETTING_BTN5LABEL"]];
	[_btn6label setText:[pData getDataForKey:@"DEFINE_SETTING_BTN6LABEL"]];
	[_syncLabel setText:[pData getDataForKey:@"DEFINE_SETTING_SYNCLABEL"]];
	
}
-(void)bldBtnImg
{
	//BTN1表示
	NSData *iData =[um btn1Type];
	if ( [((NSString*)iData) isEqualToString:@"image"] ) {
		_btn1Segment.selectedSegmentIndex = 0;
	}
	else {
		_btn1Segment.selectedSegmentIndex = 1;
	}
	iData =[um btn1Image];
	if ( iData ) {
		UIImage *img = [UIImage imageWithData:iData];
		_btn1Image.image = img;
	}
	
	//BTN2表示
	iData =[um btn2Type];
	if ( [((NSString*)iData) isEqualToString:@"image"] ) {
		_btn2Segment.selectedSegmentIndex = 0;
	}
	else {
		_btn2Segment.selectedSegmentIndex = 1;
	}
	iData =[um btn2Image];
	if ( iData ) {
		UIImage *img = [UIImage imageWithData:iData];
		_btn2Image.image = img;
	}
	
	//BTN3表示
	iData =[um btn3Type];
	if ( [((NSString*)iData) isEqualToString:@"image"] ) {
		_btn3Segment.selectedSegmentIndex = 0;
	}
	else {
		_btn3Segment.selectedSegmentIndex = 1;
	}
	iData =[um btn3Image];
	if ( iData ) {
		UIImage *img = [UIImage imageWithData:iData];
		_btn3Image.image = img;
	}
	
	//BTN4表示
	iData =[um btn4Type];
	if ( [((NSString*)iData) isEqualToString:@"image"] ) {
		_btn4Segment.selectedSegmentIndex = 0;
	}
	else {
		_btn4Segment.selectedSegmentIndex = 1;
	}
	iData =[um btn4Image];
	if ( iData ) {
		UIImage *img = [UIImage imageWithData:iData];
		_btn4Image.image = img;
	}
	
	//BTN5表示
	iData =[um btn5Type];
	if ( [((NSString*)iData) isEqualToString:@"image"] ) {
		_btn5Segment.selectedSegmentIndex = 0;
	}
	else {
		_btn5Segment.selectedSegmentIndex = 1;
	}
	iData =[um btn5Image];
	if ( iData ) {
		UIImage *img = [UIImage imageWithData:iData];
		_btn5Image.image = img;
	}
	
	//BTN6表示
	iData =[um btn6Type];
	if ( [((NSString*)iData) isEqualToString:@"image"] ) {
		_btn6Segment.selectedSegmentIndex = 0;
	}
	else {
		_btn6Segment.selectedSegmentIndex = 1;
	}
	iData =[um btn6Image];
	if ( iData ) {
		UIImage *img = [UIImage imageWithData:iData];
		_btn6Image.image = img;
	}
}
- (void)didReceiveMemoryWarning
{
  NSLog(@"SettingViewController");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
  
  [self setClearObj];
  [self loadView];
}

-(void)setClearObj
{
  [self setLogoImage:nil];
	[self setBackSegment:nil];
	[self setTab1Segment:nil];
	[self setTab2Segment:nil];
	[self setTabBarSegment:nil];
	[self setNavBarSegment:nil];
	[self setLogoSegment:nil];
	[self setBtn1Segment:nil];
	[self setBtn2Segment:nil];
	[self setBtn3Segment:nil];
	[self setBtn4Segment:nil];
	[self setBtn6Segment:nil];
	[self setBtn5Segment:nil];
	[self setBtn6Segment:nil];
	[self setBtn1Image:nil];
	[self setBtn2Image:nil];
	[self setBtn3Image:nil];
	[self setBtn4Image:nil];
	[self setBtn5Image:nil];
	[self setBtn6Image:nil];
	[self setLogoLabel:nil];
	[self setBackGroundLabel:nil];
	[self setNavBarLabel:nil];
	[self setBtn1Label:nil];
	[self setLogoLabel:nil];
	[self setBtn2Label:nil];
	[self setBtn3Label:nil];
	[self setBtn4label:nil];
	[self setBtn5Label:nil];
	[self setBtn6label:nil];
  [self setTextSegment:nil];
  [self setTextLabel:nil];
  [self setSyncLabel:nil];
}

- (void)viewDidUnload {
  [self setClearObj];
  [super viewDidUnload];
}


-(void)viewDidAppear:(BOOL)animated
{
	
	//
	//設定内容を画面に反映
	//
	
	self.title = [pData getDataForKey:@"DEFINE_SETTING_TITLE"];
	//ナビバータイトル
	titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
	titleLabel.text = self.title;
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
	titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.textColor = [UIColor whiteColor]; // change this color
	self.navigationItem.titleView = titleLabel;
	titleLabel.text =self.title;
	[titleLabel sizeToFit];
	
	UIImage *backgroundImage = [UIImage imageNamed:@"wallpaper.jpg"];
	self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];

	um = [UtilManager sharedInstance];

	//ロゴ表示
	NSData	*iData =[um logoType];
	if ( [((NSString*)iData) isEqualToString:@"image"] ) {
		_logoSegment.selectedSegmentIndex = 0;
	}
	else {
		_logoSegment.selectedSegmentIndex = 1;
	}
	iData =[um logoImage];
	if ( iData ) {
		UIImage *img = [UIImage imageWithData:iData];
		_logoImage.image = img;
	}
	
	//背景
	iData =[um backType];
	if ( [((NSString*)iData) isEqualToString:@"gray"] ) {
		_backSegment.selectedSegmentIndex = 0;
		self.view.backgroundColor = [UIColor grayColor];
	}
	else if ( [((NSString*)iData) isEqualToString:@"black"] ) {
		_backSegment.selectedSegmentIndex = 1;
		self.view.backgroundColor = [UIColor blackColor];
	}
	else if ( [((NSString*)iData) isEqualToString:@"image"] ) {
		_backSegment.selectedSegmentIndex = 2;
		iData =[um backImage];
		if ( iData ) {
			UIImage *img = [UIImage imageWithData:iData];
			self.view.backgroundColor = [UIColor colorWithPatternImage:img];
		}
	}
	else {
		_backSegment.selectedSegmentIndex = 3;
		iData =[um backImage];
		if ( iData ) {
			UIImage *img = [UIImage imageWithData:iData];
			self.view.backgroundColor = [UIColor colorWithPatternImage:img];
		}
	}

	//戻るボタン
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] designedBackBarButtonItemWithTitle:@"" type:0 target:self action:@selector(back)];
	self.navigationItem.leftBarButtonItem = backButton;

	
/*
	//設定2画面へ
	UIBarButtonItem *settingBtn2 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPageCurl target:self action:@selector(setting2)];
	self.navigationItem.rightBarButtonItem = settingBtn2;
*/	
	//タブバー
	iData =[um tabBarType];
	if ( [((NSString*)iData) isEqualToString:@"gray"] ) {
		_tabBarSegment.selectedSegmentIndex = 0;
	}
	else if ( [((NSString*)iData) isEqualToString:@"black"] ) {
		_tabBarSegment.selectedSegmentIndex = 1;
	}
	else if ( [((NSString*)iData) isEqualToString:@"image"] ) {
		_tabBarSegment.selectedSegmentIndex = 2;
	}
	else {
		_tabBarSegment.selectedSegmentIndex = 3;
	}
	
	//ナビバー設定
	[self.navigationController.navigationBar setHidden:NO];
	iData =[um navBarType];
	if ( [((NSString*)iData) isEqualToString:@"gray"] ) {
		[self.navigationController.navigationBar setBackgroundImage:nil
													  forBarMetrics:UIBarMetricsDefault];
		self.navigationController.navigationBar.tintColor = [UIColor grayColor];
		_navBarSegment.selectedSegmentIndex = 0;
	}
	
	else if ( [((NSString*)iData) isEqualToString:@"black"] ) {
		[self.navigationController.navigationBar setBackgroundImage:nil
													  forBarMetrics:UIBarMetricsDefault];
		self.navigationController.navigationBar.tintColor = [UIColor blackColor];
		_navBarSegment.selectedSegmentIndex = 1;
	}
	else if ( [((NSString*)iData) isEqualToString:@"image"] ) {
		iData =[um navBarImage];
		if ( iData ) {
			UIImage *img = [UIImage imageWithData:iData];
			[self.navigationController.navigationBar setBackgroundImage:img
														  forBarMetrics:UIBarMetricsDefault];
		}
		_navBarSegment.selectedSegmentIndex = 2;
	}
	else {
		iData =[um navBarImage];
		if ( iData ) {
			UIImage *img = [UIImage imageWithData:iData];
			[self.navigationController.navigationBar setBackgroundImage:img
														  forBarMetrics:UIBarMetricsDefault];
		}
		_navBarSegment.selectedSegmentIndex = 3;
	}
	
	[self bldBtnImg];
	
  // テキスト設定
  iData =[um wordSetting];
	if ( iData ) {
		_textSegment.selectedSegmentIndex = 0;
	}
	else {
		_textSegment.selectedSegmentIndex = 1;
	}
  
  
	currentBackGroundSetting = _backSegment.selectedSegmentIndex;
	currentNaviSetting = _navBarSegment.selectedSegmentIndex;
}


//ImagePickerで画像を選択時のデリゲート
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *img;
	NSData *idata;
	NSString *key;
	UIBarButtonItem *backButton;
	
	//画像取得
	img = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	switch (tag) {
      
		case 1:
			//ロゴ表示
			_logoImage.image = img;
			key = [um makeId:@"logoImage"];		//保存キー
			img = [self resizeImage:img Rect:_logoImage.frame];
			break;
      
		case 2:
			//背景表示
			key = [um makeId:@"backImage"];		//保存キー
      
			//画面より大きい場合はリサイズする
			img = [self resizeImage:img Rect:self.view.frame];
			self.view.backgroundColor = [UIColor colorWithPatternImage:img];
			break;
			
		case 12:
			//ナビバー表示
			key = [um makeId:@"navBarImage"];		//保存キー
      
			//ナビゲーションバーより大きい場合はリサイズする
			img = [self resizeImage:img Rect:self.navigationController.navigationBar.frame];
			[self.navigationController.navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
			break;
      
		case 20:
			//BTN1ボタン表示
			key = [um makeId:@"btn1Image"];		//保存キー
      
			//ボタンより大きい場合はリサイズする
			img = [self resizeImage:img Rect:_btn1Image.frame];
			_btn1Image.image = img;
			break;
      
		case 21:
			//BTN2ボタン表示
			key = [um makeId:@"btn2Image"];		//保存キー
      
			//ボタンより大きい場合はリサイズする
			img = [self resizeImage:img Rect:_btn2Image.frame];
			_btn2Image.image = img;
			break;
			
		case 22:
			//BTN3ボタン表示
			key = [um makeId:@"btn3Image"];		//保存キー
      
			//ボタンより大きい場合はリサイズする
			img = [self resizeImage:img Rect:_btn3Image.frame];
			_btn3Image.image = img;
			break;
      
		case 23:
			//BTN4ボタン表示
			key = [um makeId:@"btn4Image"];		//保存キー
      
			//ボタンより大きい場合はリサイズする
			img = [self resizeImage:img Rect:_btn4Image.frame];
			_btn4Image.image = img;
			break;
      
		case 24:
			//BTN5ボタン表示
			key = [um makeId:@"btn5Image"];		//保存キー
			
			//ボタンより大きい場合はリサイズする
			img = [self resizeImage:img Rect:_btn5Image.frame];
			_btn5Image.image = img;
			break;
			
		case 25:
			//BTN6ボタン表示
			key = [um makeId:@"btn6Image"];		//保存キー
			
			//ボタンより大きい場合はリサイズする
			img = [self resizeImage:img Rect:_btn6Image.frame];
			_btn6Image.image = img;
			break;
      
		default:
			break;
	}
  
	//画像保存
	idata = UIImagePNGRepresentation(img);
	[[NSUserDefaults standardUserDefaults]setObject:idata forKey:key];
	if ( ![[NSUserDefaults standardUserDefaults]synchronize]){
		NSLog(@"Error");
	}
  
	//戻るボタン再設定
	if ( tag == 10 ) {
		self.navigationItem.leftBarButtonItem = nil;
		backButton = [[UIBarButtonItem alloc] designedBackBarButtonItemWithTitle:@"" type:1 target:self action:@selector(back)];
		self.navigationItem.leftBarButtonItem = backButton;
	}
  
	[self.pop dismissPopoverAnimated:YES];	//ポップオーバーを消す
}

//背景選択
- (IBAction)backSlected:(id)sender {
	int sel = ((UISegmentedControl*)sender).selectedSegmentIndex;
	UIImagePickerControllerSourceType src;
	UIImagePickerController *imagePicker;
	UIImage * img;
	NSData *idata;
  
	oldBackGroundSetting = currentBackGroundSetting;
	currentBackGroundSetting = sel;
  
	switch (sel) {
		case 0:
			//背景グレー
			[[NSUserDefaults standardUserDefaults]setObject:@"gray" forKey:[um makeId:@"backType"]];
			self.view.backgroundColor = [UIColor grayColor];
			break;
      
		case 1:
			//背景黒
			[[NSUserDefaults standardUserDefaults]setObject:@"black" forKey:[um makeId:@"backType"]];
			self.view.backgroundColor = [UIColor blackColor];
			break;
      
		case 2:
			//背景画像
			[[NSUserDefaults standardUserDefaults]setObject:@"image" forKey:[um makeId:@"backType"]];
			src = UIImagePickerControllerSourceTypePhotoLibrary;
			imagePicker =[[UIImagePickerController alloc]init];
			imagePicker.sourceType = src;
			imagePicker.delegate = self;
			tag = 2;					//背景選択
			_pop = [[UIPopoverController alloc]initWithContentViewController:imagePicker];
			_pop.delegate = self;
			_pop.popoverContentSize = imagePicker.view.frame.size;
			[_pop presentPopoverFromRect:_backSegment.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
			break;
      
		case 3:
			//デフォルト
			[[NSUserDefaults standardUserDefaults]setObject:@"default" forKey:[um makeId:@"backType"]];
			img = [UIImage imageNamed:@"SFDC_BackImg.png"];
			idata = UIImagePNGRepresentation(img);
			[[NSUserDefaults standardUserDefaults]setObject:idata forKey:[um makeId:@"backImage"]];
			if ( ![[NSUserDefaults standardUserDefaults]synchronize]){
				NSLog(@"Error");
			}
			self.view.backgroundColor = [UIColor colorWithPatternImage:img];
			break;
      
		default:
			break;
	}
}

//ロゴ選択
- (IBAction)logoSelected:(id)sender {
	int sel = ((UISegmentedControl*)sender).selectedSegmentIndex;
	UIImagePickerControllerSourceType src;
	UIImagePickerController *imagePicker;
	UIImage * img;
	NSData *idata;
	
	switch (sel) {
		case 0:		//アルバムから選択
			[[NSUserDefaults standardUserDefaults]setObject:@"image" forKey:[um makeId:@"logoType"]];
			src = UIImagePickerControllerSourceTypePhotoLibrary;
			imagePicker =[[UIImagePickerController alloc]init];
			imagePicker.sourceType = src;
			imagePicker.delegate = self;
			tag = 1;					//Logo選択
			_pop = [[UIPopoverController alloc]initWithContentViewController:imagePicker];
			_pop.delegate = self;
			_pop.popoverContentSize = imagePicker.view.frame.size;
			[_pop presentPopoverFromRect:_logoSegment.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
			break;
      
		case 1:
			//デフォルト
			[[NSUserDefaults standardUserDefaults]setObject:@"default" forKey:[um makeId:@"logoType"]];
			img = [UIImage imageNamed:@"logo.png"];
			idata = UIImagePNGRepresentation(img);
			[[NSUserDefaults standardUserDefaults]setObject:idata forKey:[um makeId:@"logoImage"]];
			if ( ![[NSUserDefaults standardUserDefaults]synchronize]){
				NSLog(@"Error");
			}
			img = [self resizeImage:img Rect:_logoImage.frame];
			_logoImage.image = img;
			break;
	}
}


- (IBAction)navBarSelected:(id)sender {
	int sel = ((UISegmentedControl*)sender).selectedSegmentIndex;
	UIImagePickerControllerSourceType src;
	UIImagePickerController *imagePicker;
	NSData *idata;
	UIImage *img;
	
	oldNaviSetting = currentNaviSetting;
	currentNaviSetting = sel;
	
	switch (sel) {
		case 0:
			//背景グレー
			[[NSUserDefaults standardUserDefaults]setObject:@"gray" forKey:[um makeId:@"navBarType"]];
			[self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
			[self.navigationController.navigationBar setTintColor:[UIColor grayColor]];
			break;
			
		case 1:
			//背景黒
			[[NSUserDefaults standardUserDefaults]setObject:@"black" forKey:[um makeId:@"navBarType"]];
			[self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
			[self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
			break;
			
		case 2:
			//背景画像
			[[NSUserDefaults standardUserDefaults]setObject:@"image" forKey:[um makeId:@"navBarType"]];
			src = UIImagePickerControllerSourceTypePhotoLibrary;
			imagePicker =[[UIImagePickerController alloc]init];
			imagePicker.sourceType = src;
			imagePicker.delegate = self;
			tag = 12;					//ナビバー選択
			_pop = [[UIPopoverController alloc]initWithContentViewController:imagePicker];
			_pop.delegate = self;
			_pop.popoverContentSize = imagePicker.view.frame.size;
			[_pop presentPopoverFromRect:_navBarSegment.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
			break;
			
		case 3:
			//デフォルト
			[[NSUserDefaults standardUserDefaults]setObject:@"default" forKey:[um makeId:@"navBarType"]];
//			img = [UIImage imageNamed:@"title.png"];
			img = [um forceResizeImage:[UIImage imageNamed:@"title.png"] Rect:self.navigationController.navigationBar.frame];
			idata = UIImagePNGRepresentation(img);
			NSLog(@"%f:%f",img.size.width,img.size.height);
			[[NSUserDefaults standardUserDefaults]setObject:idata forKey:[um makeId:@"navBarImage"]];

			idata =[um navBarImage];
			if ( idata ) {
				img = [UIImage imageWithData:idata];
				NSLog(@"%f:%f",img.size.width,img.size.height);
			}
			
			if ( ![[NSUserDefaults standardUserDefaults]synchronize]){
				NSLog(@"Error");
			}
			[self.navigationController.navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
			break;
			
		default:
			break;
	}
}

// テキスト設定の選択
- (IBAction)textSelected:(id)sender {
  	int sel = ((UISegmentedControl*)sender).selectedSegmentIndex;
  
	switch (sel) {
		case 0:		//選択
    {
      //PopOverを消す
      if(_pop.popoverVisible) [_pop dismissPopoverAnimated:YES];
      WordSelectPopoverViewController *popoverViewController = [[WordSelectPopoverViewController alloc] init];
      popoverViewController.delegate = self;
      
			tag = 30; //text 設定 選択
			_pop = [[UIPopoverController alloc]initWithContentViewController:popoverViewController];
			_pop.delegate = self;
			_pop.popoverContentSize = popoverViewController.view.frame.size;
			[_pop presentPopoverFromRect:_textSegment.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
       
			break;
    }
		case 1:
    {
			//デフォルト
		[alertView show];
      [[NSUserDefaults standardUserDefaults]setObject:nil forKey:[um makeId:@"settingFile"]];
	  um = [[UtilManager alloc]init];
	  [um applyUserSetting];
	  AppDelegate* appli = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	  [appli bldTopBtns];
	  [self bldTextLabel];
	  [self bldBtnImg];

      if ( ![[NSUserDefaults standardUserDefaults]synchronize]){
        NSLog(@"Error");
      }
      _textSegment.selectedSegmentIndex = 1;

		// アラートを閉じる
		if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];

			break;
    }
    default:
      break;
	}
}

// テキスト選択時のデリゲート
-(void)didSelectTextFile:(NSString*)fileName
{
  [alertView show];

  // 選択したファイルを保存
  [[NSUserDefaults standardUserDefaults]setObject:fileName forKey:[um makeId:@"settingFile"]];
  um = [[UtilManager alloc]init];
  [um applyUserSetting];
  AppDelegate* appli = (AppDelegate*)[[UIApplication sharedApplication] delegate];
  [appli bldTopBtns];
  [self bldTextLabel];
  [self bldBtnImg];


  if ( ![[NSUserDefaults standardUserDefaults]synchronize]){
		NSLog(@"Error");
	}
  [_pop dismissPopoverAnimated:YES];
  _textSegment.selectedSegmentIndex = 0;
	
	// アラートを閉じる
	if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];

}


//UIImage:imgがRectより大きい場合リサイズする
-(id)resizeImage:(UIImage*)img Rect:(CGRect)rect
{
  
	if (( img.size.height > rect.size.height) ||
      ( img.size.width > rect.size.width)) {
		
		UIGraphicsBeginImageContext(rect.size);
		[img drawInRect:CGRectMake(0,0,rect.size.width,rect.size.height)];
		img = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
	return img;
}

//ナビゲーションバーの「戻る」ボタン処理
-(void)back
{
  //PopOverを消す
  if(_pop.popoverVisible) [_pop dismissPopoverAnimated:YES];
  
	[self.navigationController.navigationBar setHidden:YES];
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
}


- (IBAction)btn1Selected:(id)sender {
	int sel = ((UISegmentedControl*)sender).selectedSegmentIndex;
	UIImagePickerControllerSourceType src;
	UIImagePickerController *imagePicker;
	UIImage * img;
	NSData *idata;
	
	switch (sel) {
		case 0:		//アルバムから選択
			[[NSUserDefaults standardUserDefaults]setObject:@"image" forKey:[um makeId:@"btn1Type"]];
			src = UIImagePickerControllerSourceTypePhotoLibrary;
			imagePicker =[[UIImagePickerController alloc]init];
			imagePicker.sourceType = src;
			imagePicker.delegate = self;
			tag = 20;					//BTN1選択
			_pop = [[UIPopoverController alloc]initWithContentViewController:imagePicker];
			_pop.delegate = self;
			_pop.popoverContentSize = imagePicker.view.frame.size;
			[_pop presentPopoverFromRect:_btn1Segment.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
			break;
			
		case 1:
			//デフォルト
			um = [UtilManager sharedInstance];
			[[NSUserDefaults standardUserDefaults]setObject:@"default" forKey:[um makeId:@"btn1Type"]];
			idata = [um btn1DefaultImage];
			img = [UIImage imageWithData:idata];
			[[NSUserDefaults standardUserDefaults]setObject:idata forKey:[um makeId:@"btn1Image"]];
			if ( ![[NSUserDefaults standardUserDefaults]synchronize]){
				NSLog(@"Error");
			}
			img = [self resizeImage:img Rect:_btn1Image.frame];
			_btn1Image.image = img;
			break;
	}
}

- (IBAction)btn2Selected:(id)sender {
	int sel = ((UISegmentedControl*)sender).selectedSegmentIndex;
	UIImagePickerControllerSourceType src;
	UIImagePickerController *imagePicker;
	UIImage * img;
	NSData *idata;
	
	switch (sel) {
		case 0:		//アルバムから選択
			[[NSUserDefaults standardUserDefaults]setObject:@"image" forKey:[um makeId:@"btn2Type"]];
			src = UIImagePickerControllerSourceTypePhotoLibrary;
			imagePicker =[[UIImagePickerController alloc]init];
			imagePicker.sourceType = src;
			imagePicker.delegate = self;
			tag = 21;					//BTN2選択
			_pop = [[UIPopoverController alloc]initWithContentViewController:imagePicker];
			_pop.delegate = self;
			_pop.popoverContentSize = imagePicker.view.frame.size;
			[_pop presentPopoverFromRect:_btn2Segment.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
			break;
			
		case 1:
			//デフォルト
			um = [UtilManager sharedInstance];
			[[NSUserDefaults standardUserDefaults]setObject:@"default" forKey:[um makeId:@"btn2Type"]];
			idata = [um btn2DefaultImage];
			img = [UIImage imageWithData:idata];
			[[NSUserDefaults standardUserDefaults]setObject:idata forKey:[um makeId:@"btn2Image"]];
			if ( ![[NSUserDefaults standardUserDefaults]synchronize]){
				NSLog(@"Error");
			}
			img = [self resizeImage:img Rect:_btn2Image.frame];
			_btn2Image.image = img;
			break;
	}
}

- (IBAction)btn3Selected:(id)sender {
	int sel = ((UISegmentedControl*)sender).selectedSegmentIndex;
	UIImagePickerControllerSourceType src;
	UIImagePickerController *imagePicker;
	UIImage * img;
	NSData *idata;
	
	switch (sel) {
		case 0:		//アルバムから選択
			[[NSUserDefaults standardUserDefaults]setObject:@"image" forKey:[um makeId:@"btn3Type"]];
			src = UIImagePickerControllerSourceTypePhotoLibrary;
			imagePicker =[[UIImagePickerController alloc]init];
			imagePicker.sourceType = src;
			imagePicker.delegate = self;
			tag = 22;					//BTN3選択
			_pop = [[UIPopoverController alloc]initWithContentViewController:imagePicker];
			_pop.delegate = self;
			_pop.popoverContentSize = imagePicker.view.frame.size;
			[_pop presentPopoverFromRect:_btn3Segment.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
			break;
			
		case 1:
			//デフォルト
			um = [UtilManager sharedInstance];
			[[NSUserDefaults standardUserDefaults]setObject:@"default" forKey:[um makeId:@"btn3Type"]];
			idata = [um btn3DefaultImage];
			img = [UIImage imageWithData:idata];
			[[NSUserDefaults standardUserDefaults]setObject:idata forKey:[um makeId:@"btn3Image"]];
			if ( ![[NSUserDefaults standardUserDefaults]synchronize]){
				NSLog(@"Error");
			}
			img = [self resizeImage:img Rect:_btn3Image.frame];
			_btn3Image.image = img;
			break;
	}
}

- (IBAction)btn4Selected:(id)sender {
	int sel = ((UISegmentedControl*)sender).selectedSegmentIndex;
	UIImagePickerControllerSourceType src;
	UIImagePickerController *imagePicker;
	UIImage * img;
	NSData *idata;
	
	switch (sel) {
		case 0:		//アルバムから選択
			[[NSUserDefaults standardUserDefaults]setObject:@"image" forKey:[um makeId:@"btn4Type"]];
			src = UIImagePickerControllerSourceTypePhotoLibrary;
			imagePicker =[[UIImagePickerController alloc]init];
			imagePicker.sourceType = src;
			imagePicker.delegate = self;
			tag = 23;					//BTN4選択
			_pop = [[UIPopoverController alloc]initWithContentViewController:imagePicker];
			_pop.delegate = self;
			_pop.popoverContentSize = imagePicker.view.frame.size;
			[_pop presentPopoverFromRect:_btn4Segment.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
			break;
			
		case 1:
			//デフォルト
			um = [UtilManager sharedInstance];
			[[NSUserDefaults standardUserDefaults]setObject:@"default" forKey:[um makeId:@"btn4Type"]];
			idata = [um btn4DefaultImage];
			img = [UIImage imageWithData:idata];
			[[NSUserDefaults standardUserDefaults]setObject:idata forKey:[um makeId:@"btn4Image"]];
			if ( ![[NSUserDefaults standardUserDefaults]synchronize]){
				NSLog(@"Error");
			}
			img = [self resizeImage:img Rect:_btn4Image.frame];
			_btn4Image.image = img;
			break;
	}
}

- (IBAction)btn5Selected:(id)sender {
	int sel = ((UISegmentedControl*)sender).selectedSegmentIndex;
	UIImagePickerControllerSourceType src;
	UIImagePickerController *imagePicker;
	UIImage * img;
	NSData *idata;
	
	switch (sel) {
		case 0:		//アルバムから選択
			[[NSUserDefaults standardUserDefaults]setObject:@"image" forKey:[um makeId:@"btn5Type"]];
			src = UIImagePickerControllerSourceTypePhotoLibrary;
			imagePicker =[[UIImagePickerController alloc]init];
			imagePicker.sourceType = src;
			imagePicker.delegate = self;
			tag = 24;					//BTN5選択
			_pop = [[UIPopoverController alloc]initWithContentViewController:imagePicker];
			_pop.delegate = self;
			_pop.popoverContentSize = imagePicker.view.frame.size;
			[_pop presentPopoverFromRect:_btn5Segment.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
			break;
			
		case 1:
			//デフォルト
			um = [UtilManager sharedInstance];
			[[NSUserDefaults standardUserDefaults]setObject:@"default" forKey:[um makeId:@"btn5Type"]];
			idata = [um btn5DefaultImage];
			img = [UIImage imageWithData:idata];
			[[NSUserDefaults standardUserDefaults]setObject:idata forKey:[um makeId:@"btn5Image"]];
			if ( ![[NSUserDefaults standardUserDefaults]synchronize]){
				NSLog(@"Error");
			}
			img = [self resizeImage:img Rect:_btn5Image.frame];
			_btn5Image.image = img;
			break;
	}
}

- (IBAction)btn6Selected:(id)sender {
	int sel = ((UISegmentedControl*)sender).selectedSegmentIndex;
	UIImagePickerControllerSourceType src;
	UIImagePickerController *imagePicker;
	UIImage * img;
	NSData *idata;
	
	switch (sel) {
		case 0:		//アルバムから選択
			[[NSUserDefaults standardUserDefaults]setObject:@"image" forKey:[um makeId:@"btn6Type"]];
			src = UIImagePickerControllerSourceTypePhotoLibrary;
			imagePicker =[[UIImagePickerController alloc]init];
			imagePicker.sourceType = src;
			imagePicker.delegate = self;
			tag = 25;					//BTN6選択
			_pop = [[UIPopoverController alloc]initWithContentViewController:imagePicker];
			_pop.delegate = self;
			_pop.popoverContentSize = imagePicker.view.frame.size;
			[_pop presentPopoverFromRect:_btn6Segment.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
			break;
			
		case 1:
			//デフォルト
			um = [UtilManager sharedInstance];
			[[NSUserDefaults standardUserDefaults]setObject:@"default" forKey:[um makeId:@"btn6Type"]];
			idata = [um btn6DefaultImage];
			img = [UIImage imageWithData:idata];
			[[NSUserDefaults standardUserDefaults]setObject:idata forKey:[um makeId:@"btn6Image"]];
			if ( ![[NSUserDefaults standardUserDefaults]synchronize]){
				NSLog(@"Error");
			}
			img = [self resizeImage:img Rect:_btn6Image.frame];
			_btn6Image.image = img;
			break;
	}
}

-(void)didSelectImage:(UIImage *)img
{
	NSData *idata;
	NSString *key;
	
	switch (tag) {
		case 10:
			key = @"backBtnImage";		//保存キー
			idata = UIImagePNGRepresentation(img);
			break;
			
		default:
			break;
	}
	
	//共有データに保存
	[[NSUserDefaults standardUserDefaults]setObject:idata forKey:key];
	if ( ![[NSUserDefaults standardUserDefaults]synchronize]){
		NSLog(@"Error");
	}
	//戻るボタン再設定
	if ( tag == 10 ) {
		self.navigationItem.leftBarButtonItem = nil;
		UIBarButtonItem *backButton = [[UIBarButtonItem alloc] designedBackBarButtonItemWithTitle:@"" type:1 target:self action:@selector(back)];
		self.navigationItem.leftBarButtonItem = backButton;
	}
	
	//PopOver消去
	[_pop dismissPopoverAnimated:YES];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
  if ((orientation == UIInterfaceOrientationLandscapeLeft) ||
      (orientation == UIInterfaceOrientationLandscapeRight )){
    return YES;
  }
  return NO;
}


-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
  NSLog(@"tag : %d", tag);
  
	switch (tag) {
		case 1:
			_logoSegment.selectedSegmentIndex = 1;
			break;
			
		case 2:
			_backSegment.selectedSegmentIndex = oldBackGroundSetting;
			break;
      
		case 12:
			_navBarSegment.selectedSegmentIndex = oldNaviSetting;
			break;
			
		case 20:
			_btn1Segment.selectedSegmentIndex = 1;
			break;
      
		case 21:
			_btn2Segment.selectedSegmentIndex = 1;
			break;
			
		case 22:
			_btn3Segment.selectedSegmentIndex = 1;
			break;
      
		case 23:
			_btn4Segment.selectedSegmentIndex = 1;
			break;
      
		case 24:
			_btn5Segment.selectedSegmentIndex = 1;
			break;
      
		case 25:
			_btn6Segment.selectedSegmentIndex = 1;
			break;
      
		case 30:
			_textSegment.selectedSegmentIndex = 1;
			break;
      
		default:
			break;
	}
}

- (IBAction)pushSyncBtn:(id)sender {
  [self alertShow];
  [self updateCacheFile];
}

-(void)updateMovieFile
{
  // カウント初期化
  i = 0;
  
  //[self alertShow];
  
  //クエリ作成
  NSString *query = [NSString stringWithFormat:@"SELECT Id,ProductCode,Name,Family,Description,URL__c ,order__c, LastModifiedDate  FROM product2 WHERE IsActive=true  ORDER BY order__c"];
  NSLog(@"%@",query);
  SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:query];
  [[SFRestAPI sharedInstance] send:request delegate:self];
}

//SOQLのアンサー受信
- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse
{
  
  NSArray *records = [jsonResponse objectForKey:@"records"];
  NSLog(@"request:didLoadResponse: #records: %d", records.count);
  
  [self getMovie:records];
}

-(void)getMovie:(NSArray *)records
{
    int count = [records count];
  
    if(count==0) [self finishFiles];
    
    for(NSDictionary *dic in records){
      if(![um chkString:[dic objectForKey:@"URL__c"]]) count--;
    }
    
    for(NSDictionary *dic in records){
      //NSLog(@"dic : %@", dic);
      NSString *pId = [dic objectForKey:@"Id"];
      // 動画URL
      NSString *pMovie = [dic objectForKey:@"URL__c"];
      NSLog(@"movie %d", [um chkString:pMovie]);
      if(![um chkString:pMovie]) continue;
      
      // URLがある場合  URLが等しい  更新年月日チェック
      if([um existProductMovieFile:pId] 
          && [pMovie isEqualToString:[um loadProductMovieFileURL:pId] ]
          && ![um compareMovieDate:pId DBdate:[dic objectForKey:@"LastModifiedDate"]]
         ){
        NSLog(@"### OK ###");
      }else{
        // urlを保存
        [um saveMovieURL:pId url:pMovie];
        // URLを指定してHTTPリクエストを生成
        // 動画URL
        NSURL *url = [NSURL URLWithString:pMovie];
        
        // HTTPリクエストオブジェクトを生成
        NSURLRequest* request = [NSURLRequest
                                 requestWithURL:url];
        
        // HTTP同期通信を実行
        NSURLResponse* response = nil;
        NSError* error = nil;
        NSData* data = [NSURLConnection
                        sendSynchronousRequest:request
                        returningResponse:&response
                        error:&error];
        
        NSLog(@"file size %lld", [response expectedContentLength]);
        // 取得したデータ
        if(data){
          [um saveProductMovieFile:pId data:data];
          //i++;
        }
      }
      i++;
      NSLog(@"count %d  i %d", count, i);
      if(i==count){
        [self finishFiles];
      }
    }
}

// 画像キャッシュファイルの更新メソッド 
-(void)updateCacheFile
{
  pData = [PublicDatas instance];
  um = [UtilManager sharedInstance];
  NSString *query = @"SELECT ParentId,Name,Body,BodyLength, Id, LastModifiedDate FROM Attachment ORDER BY CreatedDate DESC";
  //NSLog(@"%@",query);
  SFRestRequest *req = [[SFRestAPI sharedInstance] requestForQuery:query];
  [[SFRestAPI sharedInstance] sendRESTRequest:req
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      
                                    }
                                completeBlock:^(id jsonResponse){
                                  
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  
                                  //NSLog(@"45 %@",dict);
                                  for(NSDictionary *dic in [dict objectForKey:@"records"]){
                                    NSString *productId = [dic objectForKey:@"ParentId"];
                                    //NSString *Id = [dic objectForKey:@"Id"];
                                    NSString *Name = [dic objectForKey:@"Name"];
                                      
                                    if(!(([um isInclude:[Name uppercaseString]cmp:@"MAIN."]
                                       ||[um isInclude:Name cmp:@"01."]
                                       ||[um isInclude:Name cmp:@"02."])
                                       && [um isInclude:[Name uppercaseString] cmp:@"JPG"]
                                       )) continue;
                                    
                                      // ファイル更新
                                        // 年月日チェック
                                        if(![um compareFileDate:productId name:Name date:[dic objectForKey:@"LastModifiedDate"]]) continue;
                                        
                                        //リクエスト作成
                                        NSString *url = [dic objectForKey:@"Body"];
                                        NSString *instance = [[[[[SFRestAPI sharedInstance] coordinator] credentials] instanceUrl]absoluteString];
                                        NSString *fullUrl = [instance stringByAppendingString:url];
                                        NSLog(@"full url : %@", fullUrl);
                                        NSURL *myURL = [NSURL URLWithString:fullUrl];
                                        NSMutableURLRequest *requestDoc = [[NSMutableURLRequest alloc]initWithURL:myURL];
                                        
                                        //OAuth認証情報をヘッダーに追加
                                        NSString *token = [@"OAuth " stringByAppendingString:[[[[SFRestAPI sharedInstance]coordinator]credentials]	accessToken]];
                                        
                                        [requestDoc addValue:token forHTTPHeaderField:@"Authorization"];
                                        
                                        NSURLResponse *resp;
                                        NSError *err;
                                        @try {
                                          NSData *rcvData = [NSURLConnection sendSynchronousRequest:requestDoc returningResponse:&resp error:&err];
                                          // ファイルを保存
                                          [um saveProductFile:productId name:Name data:rcvData];
                                        }
                                        @catch (NSException *exception) {
                                          NSLog(@"name  :%@",exception.name);
                                          NSLog(@"reason:%@",exception.reason);
                                        }
                                  }
                                  [self updateMovieFile];
                                }
  ];
}


-(void)finishFiles
{
  if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
  
  // 完了アラート
  alertView = [[UIAlertView alloc]
               initWithTitle:@""
               message:[pData getDataForKey:@"DEFINE_SETTING_SYNC_TITLE_UPDATEDONE_MESSAGE"]
               delegate:nil
               cancelButtonTitle:nil
               otherButtonTitles:[pData getDataForKey:@"DEFINE_SETTING_SYNC_TITLE_UPDATEDONE_OK"], nil ];
  [alertView show];
  [um doneSyncFile];
}


// ローディングアラートの表示
-(void)alertShow
{
  pData = [PublicDatas instance];
	// ローディングアラートを生成
	alertView = [[UIAlertView alloc] initWithTitle:[pData getDataForKey:@"DEFINE_SETTING_SYNC_LOADING"] message:nil
                                        delegate:nil cancelButtonTitle:nil otherButtonTitles:NULL];
	progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
	progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	[alertView addSubview:progress];
	[progress startAnimating];
	
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

@end

