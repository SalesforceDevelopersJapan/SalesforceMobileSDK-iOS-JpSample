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


#import "MapViewController.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "JSONKit.h"
#import "MetricsViewController.h"
#import "AppDelegate.h"
#import "PinDefine.h"
#import "MyToolBar.h"
#import "building.h"
#import "BuildingView.h"
#import "ItemBadge.h"
#import "ModeSelectViewController.h"

static const CGFloat CalloutYOffset = 25.0f;
static const float InitialZoom = 15.0f;				//ズーム値
//static const double SearchAreaLng = 0.0110575296875*2;
//static const double SearchAreaLat = 0.0089831916466*2;
static const double SearchAreaLng = 0.0110575296875;
static const double SearchAreaLat = 0.0089831916466;

//画像読み込みの閾値(単位」Byte）
static const int	MaxLoadingSize = ( 200 * 1024 );

//取引先ロゴ取得を行う=YES  行わない=NO
static const BOOL LogoLoad = YES;

//マーカーピン直径　最大値
static const double MaxDimeter = 200;
static const double MinDimeter = 30;


@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil company:(Company*)cp
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
		comp = cp;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
	[self.navigationController.navigationBar setHidden:NO];
  
	//初期モード
	dispType = ENUM_DISPNORMAL; //Sales UP/ DOWN / FLAT
//	dispType = ENUM_DISPVISIT; //訪問回数
//	dispType = ENUM_DISPOPP; //商談件数
	
  isImgBackJob = YES;
	isLstBtnDisp = YES;
	
	//取引先リスト
	companyList = [NSMutableArray array];
	selectedList = [NSMutableArray array];
	
	//現在地に移動
	moveCurrentPos = YES;
	
	//選択モード(全部表示）
	selectMode =  (SALES_UP) | (SALES_FLAT) | (SALES_DOWN | (BUILDING));
	
	//現在地取得準備
	locationManager = [[CLLocationManager alloc]init];
	if ([CLLocationManager locationServicesEnabled]){
		
		//位置情報取得可能なら測位開始
		[locationManager setDelegate:self];
		[locationManager startUpdatingLocation];
	}
  //NSLog(@" gps enable %d", [CLLocationManager locationServicesEnabled]);
  //NSLog(@"appli gps enable %d", [CLLocationManager authorizationStatus]);
  
	pData = [PublicDatas instance];
	self.title = [pData getDataForKey:@"DEFINE_MAP_TITLE"];
  
	//ナビバー設定
	um = [UtilManager sharedInstance];
	NSData *iData =[um navBarType];
	if ( [((NSString*)iData) isEqualToString:@"gray"] ) {
		[self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
		self.navigationController.navigationBar.tintColor = [UIColor grayColor];
	}
	
	else if ( [((NSString*)iData) isEqualToString:@"black"] ) {
		[self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
		self.navigationController.navigationBar.tintColor = [UIColor blackColor];
	}
	else {
		iData =[um navBarImage];
		if ( iData ) {
			UIImage *img = [UIImage imageWithData:iData];
			NSLog(@"%f:%f",img.size.width,img.size.width);
      [self.navigationController.navigationBar setBackgroundImage:img
                                                    forBarMetrics:UIBarMetricsDefault];
		}
	}
  
	
	//ナビバータイトル色
	label = [[UILabel alloc]initWithFrame:CGRectZero];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:20.0];
	label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	label.textAlignment = NSTextAlignmentCenter;
	label.textColor = [UIColor whiteColor]; // change this color
	self.navigationItem.titleView = label;
//	label.text =self.title;
//	[label sizeToFit];
	[self setNavbartitle];
	
	// GPS利用チェック
	AppDelegate* appli = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	float _zoom =0.0;
	if([appli chkGPS]) _zoom = InitialZoom;
  
	// UtilManager
	um = [UtilManager sharedInstance];
  
	//地図初期位置
	GMSCameraPosition *camera= [GMSCameraPosition cameraWithLatitude:0
                                                         longitude:0 zoom:_zoom];
	//地図
	CGRect r = self.mapView.frame;
	r.origin.y = 0;
	map =  [GMSMapView mapWithFrame:r camera:camera];
	map.myLocationEnabled = YES;
	map.delegate = self;
	[self.mapView addSubview:map];
	
	//画像読み込み
	iData =[um currentLoacationBtnImage];
	if ( iData ) {
		currentLocationImg = [UIImage imageWithData:iData];
	}
  
	iData =[um listBtnImage];
	if ( iData ) {
		listBtnImg = [UIImage imageWithData:iData];
	}
  
	iData =[um panelBackImage];
	if ( iData ) {
		panelBackImg = [UIImage imageWithData:iData];
	}
  
	iData =[um salesUpImage];
	if ( iData ) {
		salesUpImg = [UIImage imageWithData:iData];
	}
  
	iData =[um salesFlatImage];
	if ( iData ) {
		salesFlatImg = [UIImage imageWithData:iData];
	}
  
	iData =[um salesDownImage];
	if ( iData ) {
		salesDownImg = [UIImage imageWithData:iData];
	}
  
	//現在地ボタン
	UIButton *currentPosBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[currentPosBtn setBackgroundImage:currentLocationImg forState:UIControlStateNormal];
	[currentPosBtn addTarget:self action:@selector(currentPos) forControlEvents:UIControlEventTouchUpInside];
	currentPosBtn.frame = CGRectMake(10,645, 50, 50);
  
	// 角丸
	CGSize size = CGSizeMake(5.0, 5.0);
	[um makeViewRound:currentPosBtn corners:UIRectCornerAllCorners size:&size];
	[self.mapView addSubview:currentPosBtn];
  
  
	[self setNaviRightButton:NO];
	
	//ナビゲーションバーに「戻る」ボタン配置
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] designedBackBarButtonItemWithTitle:@"" type:0 target:self action:@selector(back)];
	self.navigationItem.leftBarButtonItem = backButton;
	
	//初回はセレクトパネルにビル表示
	[self buildSelectPanel:YES];
	
	// ローディングアラートを生成
	alertView = [[UIAlertView alloc] initWithTitle:[pData getDataForKey:@"DEFINE_ROUTE_LOADING"] message:nil
										  delegate:nil cancelButtonTitle:nil otherButtonTitles:NULL];
	progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
	progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	[alertView addSubview:progress];
	[progress startAnimating];
	
	// 初回表示フラグ
	isFirst = YES;
	
	// UtilManager
	um = [UtilManager sharedInstance];
	[um loadSearchWordList];
	
	// viewWillAppear が反応しないように値をクリア
	[self clearCenterPoint];
	
	//キーボードの初期状態をセット
	NSString *isKeyboard = @"NO";
	pData = [PublicDatas instance];
	[pData setData:isKeyboard forKey:@"isKeyboard"];
	
	//キーボード表示した時
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	//キーボードが非表示になった時
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


-(void)buildSelectPanel:(BOOL)builDisp
{
	
	[selectPanel removeFromSuperview];
	
	float trimX = 0;
	if ( builDisp == false){
		trimX = 145;
	}
	
	//絞り込みパネル
	selectPanel = [[UIView alloc]initWithFrame:CGRectMake(410 + trimX,645, 605 - trimX, 50)];
	selectPanel.layer.cornerRadius = 6;
	[selectPanel setBackgroundColor:[UIColor colorWithPatternImage:panelBackImg]];

	
	//SalesUpボタン
	salesUpBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 5, 40, 40)];
	[salesUpBtn setBackgroundImage:salesUpImg forState:UIControlStateNormal];
	[salesUpBtn addTarget:self action:@selector(salesUpPushed) forControlEvents:UIControlEventTouchUpInside];
	[selectPanel addSubview:salesUpBtn];
	
	// SalesUPボタンテキスト
	salesUpTextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	salesUpTextBtn.frame = CGRectMake(50,0,100,50);
	salesUpTextBtn.titleLabel.font            = [UIFont systemFontOfSize: 18];
	salesUpTextBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
	[salesUpTextBtn setTitle:[pData getDataForKey:@"DEFINE_MAP_SALESUP"] forState:UIControlStateNormal];
	[salesUpTextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[salesUpTextBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[salesUpTextBtn addTarget:self action:@selector(salesUpPushed) forControlEvents:UIControlEventTouchUpInside];
	[selectPanel addSubview:salesUpTextBtn];
  
	//SalesFlatボタン
	salesFlatBtn = [[UIButton alloc]initWithFrame:CGRectMake(150, 5, 40, 40)];
	[salesFlatBtn setBackgroundImage:salesFlatImg forState:UIControlStateNormal];
	[salesFlatBtn addTarget:self action:@selector(salesFlatPushed) forControlEvents:UIControlEventTouchUpInside];
	[selectPanel addSubview:salesFlatBtn];
  
	// SalesFlatボタンテキスト
	salesFlatTextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	salesFlatTextBtn.frame = CGRectMake(195,0,100,50);
	salesFlatTextBtn.titleLabel.font            = [UIFont systemFontOfSize: 18];
	salesFlatTextBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
	[salesFlatTextBtn setTitle:[pData getDataForKey:@"DEFINE_MAP_SALESFLAT"] forState:UIControlStateNormal];
	[salesFlatTextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[salesFlatTextBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[salesFlatTextBtn addTarget:self action:@selector(salesFlatPushed) forControlEvents:UIControlEventTouchUpInside];
	[selectPanel addSubview:salesFlatTextBtn];
  
	//SalesDownボタン
	salesDownBtn = [[UIButton alloc]initWithFrame:CGRectMake(300, 5, 40, 40)];
	[salesDownBtn setBackgroundImage:salesDownImg forState:UIControlStateNormal];
	[salesDownBtn addTarget:self action:@selector(salesDownPushed) forControlEvents:UIControlEventTouchUpInside];
	[selectPanel addSubview:salesDownBtn];
  
	// SalesDownボタンテキスト
	salesDownTextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	salesDownTextBtn.frame = CGRectMake(350,0,100,50);
	salesDownTextBtn.titleLabel.font            = [UIFont systemFontOfSize: 18];
	salesDownTextBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
	[salesDownTextBtn setTitle:[pData getDataForKey:@"DEFINE_MAP_SALESDOWN"] forState:UIControlStateNormal];
	[salesDownTextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[salesDownTextBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[salesDownTextBtn addTarget:self action:@selector(salesDownPushed) forControlEvents:UIControlEventTouchUpInside];
	[selectPanel addSubview:salesDownTextBtn];
  
	if ( builDisp == true){

		//Buildingボタン
		buildingImg = [UIImage imageNamed:@"Building.png"];
		buildingBtn = [[UIButton alloc]initWithFrame:CGRectMake(465, 5, 40, 40)];
		[buildingBtn setBackgroundImage:buildingImg forState:UIControlStateNormal];
		[buildingBtn addTarget:self action:@selector(buildingPushed) forControlEvents:UIControlEventTouchUpInside];
		[selectPanel addSubview:buildingBtn];
  
		// Buildingボタンテキスト
		buildingTextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		buildingTextBtn.frame = CGRectMake(505,0,100,50);
		buildingTextBtn.titleLabel.font            = [UIFont systemFontOfSize: 18];
		buildingTextBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
		[buildingTextBtn setTitle:@"Building" forState:UIControlStateNormal];
		[buildingTextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[buildingTextBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
		[buildingTextBtn addTarget:self action:@selector(buildingPushed) forControlEvents:UIControlEventTouchUpInside];
		[selectPanel addSubview:buildingTextBtn];
	}

	if ( selectMode & SALES_UP){
		salesUpBtn.opaque = NO;
		salesUpBtn.alpha = 1;
		salesUpBtn.opaque = NO;
		salesUpBtn.alpha = 1;
		[salesUpTextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	}
	else {
		salesUpBtn.opaque = YES;
		salesUpBtn.alpha = 0.3;
		salesUpBtn.opaque = YES;
		salesUpBtn.alpha = 0.3;
		[salesUpTextBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
	}
	if ( selectMode & SALES_DOWN){
		salesDownBtn.opaque = NO;
		salesDownBtn.alpha = 1;
		salesDownBtn.opaque = NO;
		salesDownBtn.alpha = 1;
		[salesDownTextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	}
	else {
		salesDownBtn.opaque = YES;
		salesDownBtn.alpha = 0.3;
		salesDownBtn.opaque = YES;
		salesDownBtn.alpha = 0.3;
		[salesDownTextBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
	}
	if ( selectMode & SALES_FLAT){
		salesFlatBtn.opaque = NO;
		salesFlatBtn.alpha = 1;
		salesFlatLbl.opaque = NO;
		salesFlatLbl.alpha = 1;
		[salesFlatTextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	}
	else {
		salesFlatBtn.opaque = YES;
		salesFlatBtn.alpha = 0.3;
		salesFlatLbl.opaque = YES;
		salesFlatLbl.alpha = 0.3;
		[salesFlatTextBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
	}
	if ( selectMode & BUILDING){
		buildingBtn.opaque = NO;
		buildingBtn.alpha = 1;
		[buildingTextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	}
	else {
		buildingBtn.opaque = YES;
		buildingBtn.alpha = 0.3;
		[buildingTextBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
	}
	
	selectPanel.opaque = YES;
	selectPanel.alpha = 1.0;
	[map addSubview:selectPanel];
  
}

- (void)viewWillAppear:(BOOL)animated
{
  
}

-(void) keyboardWillShow:(NSNotification*)notification
{
  NSString *isKeyboard = @"YES";
  pData = [PublicDatas instance];
  [pData setData:isKeyboard forKey:@"isKeyboard"];
}

- (void) keyboardWillHide:(NSNotification*)notification
{
  NSString *isKeyboard = @"NO";
  pData = [PublicDatas instance];
  [pData setData:isKeyboard forKey:@"isKeyboard"];
}

// ローディングアラートの表示
-(void)alertShow
{
  if(!alertView.visible){
    [NSTimer scheduledTimerWithTimeInterval:30.0f
                                     target:self
                                   selector:@selector(performDismiss:)
                                   userInfo:alertView repeats:NO];
    [alertView show];
  }
}

// アラートを閉じるメソッド
- (void)performDismiss:(NSTimer *)theTimer
{
  alertView = [theTimer userInfo];
  [alertView dismissWithClickedButtonIndex:0 animated:NO];
}

-(void)setNaviRightButton:(BOOL)lstBtn
{
  
	//検索窓
	_sBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 250, 40)];
	
	//検索窓を四角くする
	for (UIView *searchBarSubview in [_sBar subviews]) {
    if ([searchBarSubview conformsToProtocol:@protocol(UITextInputTraits)]) {
      @try {
        [(UITextField *)searchBarSubview setBorderStyle:UITextBorderStyleRoundedRect];
      }
      @catch (NSException * e) {
        // ignore exception
      }
    }
  }
	_sBar.delegate = self;
	_sBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
  
  if([um.searchWordList count]>0){
    // 履歴表示のためブックマークボタンを追加
    _sBar.showsBookmarkButton = YES;
  }
  
	//ツールバー（検索窓とリストボタンを設置）
//	UIToolbar *toolbar = [[MyToolBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 40.0f)];
	UIToolbar *toolbar = [[MyToolBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 370.0f, 40.0f)];
	toolbar.backgroundColor = [UIColor clearColor];
	toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	UIBarButtonItem *toolbarBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
  
	UIFont *font = [UIFont boldSystemFontOfSize:16];
	UIButton *modeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[modeBtn.titleLabel setFont:font];
	[modeBtn setTitle:[pData getDataForKey:@"DEFINE_MAP_MODEBTN"] forState:UIControlStateNormal];
	modeBtn.frame = CGRectMake(0,0, 70,50 );
	[modeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[modeBtn addTarget:self action:@selector(modePushed) forControlEvents:UIControlEventTouchUpInside];
	
	if ( lstBtn == YES) {
		//リストボタン
    
		UIButton *listBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[listBtn setBackgroundImage:listBtnImg forState:UIControlStateNormal];
		listBtn.frame = CGRectMake(0,0, 25,25);
		[listBtn addTarget:self action:@selector(listPushed) forControlEvents:UIControlEventTouchUpInside];
//		toolbar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc]initWithCustomView:listBtn],[[UIBarButtonItem alloc]initWithCustomView:_sBar], nil];
		toolbar.items = [NSArray arrayWithObjects:	[[UIBarButtonItem alloc]initWithCustomView:modeBtn],
													[[UIBarButtonItem alloc]initWithCustomView:listBtn],
													[[UIBarButtonItem alloc]initWithCustomView:_sBar], nil];
	}
	else {
		// リストボタンの代わりに空ボタンを作成
		UIButton *empBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		empBtn.frame = CGRectMake(0,0,25,25);
    
//		toolbar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc]initWithCustomView:empBtn],[[UIBarButtonItem alloc]initWithCustomView:_sBar], nil];
		toolbar.items = [NSArray arrayWithObjects:	[[UIBarButtonItem alloc]initWithCustomView:empBtn],
													[[UIBarButtonItem alloc]initWithCustomView:modeBtn],
													[[UIBarButtonItem alloc]initWithCustomView:_sBar], nil];
	}
	
  // 検索ワードを設定
  _sBar.text = searchWord;
  
	//ツールバーをナビバーに設置
	self.navigationItem.rightBarButtonItem = toolbarBarButtonItem;
  	isLstBtnDisp = lstBtn;

}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
  //PopOverを消す
	if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
  //PopOverを消す
	if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
  //PopOverを消す
	if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
}

-(void)listPushed
{
	if ( bdView.isCovered == true){
		return;
	}
	
  //PopOverを消す
  if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
  
	//リストをPopoverで表示
	SearchPopoverViewController *srch = [[SearchPopoverViewController alloc]init];
	[srch setCompanyList:selectedList];
	srch.delegate = self;
	pop = [[UIPopoverController alloc]initWithContentViewController:srch];
	pop.delegate = self;
	pop.popoverContentSize = srch.view.frame.size;
	[pop presentPopoverFromRect:CGRectMake(740, 0, 0, 0) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
  
}

//検索Popoverでセルタップ時のデリゲート
-(void)didSelectCompany:(Company*)cp
{
  
	if ( nil == cp ) {
		return;
	}
	
  //PopOverを消す
  if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
	
	//戻り先を記録
	pData = [PublicDatas instance];
	[pData setData:@"MAP" forKey:@"ReturnScreen"];
	
	//StoreViewに画面遷移
	MetricsViewController *metVC = [[MetricsViewController alloc]initWithNibName:@"Metrics" bundle:[NSBundle mainBundle] company:cp];
	[self.navigationController pushViewController:metVC animated:YES];
}

// bookmarkボタン押下時
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
  //PopOverを消す
  if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
  
  //リストをPopoverで表示
	WordPopoverViewController *wordPop = [[WordPopoverViewController alloc]init];
	[wordPop setSearchWordList:um.searchWordList];
	wordPop.delegate = self;
	pop = [[UIPopoverController alloc]initWithContentViewController:wordPop];
	pop.delegate = self;
	pop.popoverContentSize = wordPop.view.frame.size;
	[pop presentPopoverFromRect:CGRectMake(980, 0, 0, 0) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

// 履歴セルタップ時
-(void)didSelectWord:(NSString*)word
{
	if ( bdView.isCovered == true){
		return;
	}
	
  self.sBar.text = @"";
  
  //PopOverを消す
  if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
  
  // 検索ワードを保持
  searchWord = word;
  [um addSearchWordList:searchWord];
  
  self.sBar.text = searchWord;
  
  //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  [self alertShow];
  
  NSString *target = searchWord;
  
  //ピンを前削除
  [map clear];
  
  // googl map apiでジオコード
  [self searchGoogle:target];
}

// 履歴削除時
-(void)didDeleteWord
{
  if([um.searchWordList count]>0){
    // 履歴表示のためブックマークボタンを追加
    _sBar.showsBookmarkButton = YES;
  }else{
    _sBar.showsBookmarkButton = NO;
    //PopOverを消す
    if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
  }
  _sBar.text = @"";
}

// キャンセル時
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
  //PopOverを消す
  if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
}

//Buildingボタン押下
-(void)buildingPushed
{
	if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
	
	//コールアウト消去
	self.calloutView.hidden = YES;
	
	//SalesUPのビットをトグル
	selectMode ^= BUILDING;
	
	//SelectModeの該当ビットがOFFならボタンとラベルを半透明にする
	if ( selectMode & BUILDING){
		buildingBtn.opaque = NO;
		buildingBtn.alpha = 1;
		[buildingTextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	}
	else {
		buildingBtn.opaque = YES;
		buildingBtn.alpha = 0.3;
		[buildingTextBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
	}
	
	//ピンを前削除
	[map clear];
	
	
	//ピンを前削除
	[map clear];
	
	//検索地点ピンを再設置
	if ( lastSerachLocation != nil ){
		[map addMarkerWithOptions:lastSerachLocation];
	}
	
	//フィルタリング処理
	selectedList = [self applyFiller:selectMode src:sortedList];
	
	//ピン再設置
	[self addCompanyPinByArray:selectedList];
	
	if (( selectMode & BUILDING)&&(dispType==ENUM_DISPNORMAL)){
		[self addBulindingPinByArray:buildingList];
	}
}

//SalesUPボタン押下時
-(void)salesUpPushed
{
  //PopOverを消す
  if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
  
	//コールアウト消去
	self.calloutView.hidden = YES;
  
	//SalesUPのビットをトグル
	selectMode ^= SALES_UP;
  
	//SelectModeの該当ビットがOFFならボタンとラベルを半透明にする
	if ( selectMode & SALES_UP){
		salesUpBtn.opaque = NO;
		salesUpBtn.alpha = 1;
		salesUpLbl.opaque = NO;
		salesUpLbl.alpha = 1;
    [salesUpTextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	}
	else {
		salesUpBtn.opaque = YES;
		salesUpBtn.alpha = 0.3;
		salesUpLbl.opaque = YES;
		salesUpLbl.alpha = 0.3;
    [salesUpTextBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
	}
	
	//ピンを前削除
	[map clear];
	
	//検索地点ピンを再設置
	if ( lastSerachLocation != nil ){
		[map addMarkerWithOptions:lastSerachLocation];
	}
	
	//フィルタリング処理
	selectedList = [self applyFiller:selectMode src:sortedList];
	
	//ピン再設置
	[self addCompanyPinByArray:selectedList];
	if (( selectMode & BUILDING)&&(dispType == ENUM_DISPNORMAL)){
		[self addBulindingPinByArray:buildingList];
	}
}

//SalesUPボタン押下時
-(void)salesFlatPushed
{
  //PopOverを消す
  if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
  
	//コールアウト消去
	self.calloutView.hidden = YES;
  
	//SalesFlatのビットをトグル
	selectMode ^= SALES_FLAT;
	
	//SelectModeの該当ビットがOFFならボタンとラベルを半透明にする
	if ( selectMode & SALES_FLAT){
		salesFlatBtn.opaque = NO;
		salesFlatBtn.alpha = 1;
		salesFlatLbl.opaque = NO;
		salesFlatLbl.alpha = 1;
    [salesFlatTextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	}
	else {
		salesFlatBtn.opaque = YES;
		salesFlatBtn.alpha = 0.3;
		salesFlatLbl.opaque = YES;
		salesFlatLbl.alpha = 0.3;
    [salesFlatTextBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
	}
	
	//ピンを前削除
	[map clear];
	
	//検索地点ピンを再設置
	if ( lastSerachLocation != nil ){
		[map addMarkerWithOptions:lastSerachLocation];
	}
	
	//フィルタリング処理
	selectedList = [self applyFiller:selectMode src:sortedList];
	
	//ピン再設置
	[self addCompanyPinByArray:selectedList];
	if (( selectMode & BUILDING)&&(dispType==ENUM_DISPNORMAL)){
		[self addBulindingPinByArray:buildingList];
	}
}

//SalesDownボタン押下時
-(void)salesDownPushed
{
  //PopOverを消す
  if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
  
	//コールアウト消去
	self.calloutView.hidden = YES;
  
	//SalesDownのビットをトグル
	selectMode ^= SALES_DOWN;
	
	//SelectModeの該当ビットがOFFならボタンとラベルを半透明にする
	if ( selectMode & SALES_DOWN){
		salesDownBtn.opaque = NO;
		salesDownBtn.alpha = 1;
		salesDownLbl.opaque = NO;
		salesDownLbl.alpha = 1;
    [salesDownTextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	}
	else {
		salesDownBtn.opaque = YES;
		salesDownBtn.alpha = 0.3;
		salesDownLbl.opaque = YES;
		salesDownLbl.alpha = 0.3;
    [salesDownTextBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
	}
	
	//ピンを前削除
	[map clear];
	
	//検索地点ピンを再設置
	if ( lastSerachLocation != nil ){
		[map addMarkerWithOptions:lastSerachLocation];
	}
	
	//フィルタリング処理
	selectedList = [self applyFiller:selectMode src:sortedList];
	
	//ピン再設置
	[self addCompanyPinByArray:selectedList];
	if (( selectMode & BUILDING)&&(dispType==ENUM_DISPNORMAL)){
		[self addBulindingPinByArray:buildingList];
	}
}


//取引先リストにフィルターを適用する
-(NSMutableArray*)applyFiller:(int)filter src:(NSMutableArray*)srcList
{
	NSMutableArray *ret = [NSMutableArray array];
	searchText = self.sBar.text;
  
	for (int i = 0; i <[srcList count]; i++ ){
		Company *cp = [srcList objectAtIndex:i];
		
		if ( cp.salesStatus & filter ){
			[ret addObject:cp];
		}
	}
  
	//件数が0になった場合は、リストボタンを消す
	if ( [ret count]) {
		[self setNaviRightButton:YES];
		self.sBar.text = searchText;
	}
	else {
		[self setNaviRightButton:NO];
	}
	return ret;
}

//取引先リストを売上げ順にソートする
-(NSMutableArray*)sortList:(NSMutableArray*)srcList
{
	NSMutableArray *ret = [NSMutableArray array];
	int loopmax = [srcList count];
	
  NSMutableArray *retUp = [NSMutableArray array];
  NSMutableArray *retDown = [NSMutableArray array];
  NSMutableArray *retFlat = [NSMutableArray array];
  
  // 売り上げ別に配列を作成
  for( int l = 0 ; l < loopmax; l++ ){
    Company *tmp = [srcList objectAtIndex:l];
    switch (tmp.salesStatus) {
      case SALES_UP:
        [retUp addObject:tmp];
        break;
        
      case SALES_DOWN:
        [retDown addObject:tmp];
        break;
        
      case SALES_FLAT:
        [retFlat addObject:tmp];
        break;
      default:
        [retFlat addObject:tmp];
        break;
    }
  }
  // 売り上げ別に社名でソート
  [retUp sortUsingFunction: listCompare context: nil];
  [retFlat sortUsingFunction: listCompare context: nil];
  [retDown sortUsingFunction: listCompare context: nil];
  
  // 配列を結合
  [ret addObjectsFromArray:retUp];
  [ret addObjectsFromArray:retFlat];
  [ret addObjectsFromArray:retDown];
  
  return ret;
}

// 社名を比較するメソッド
NSComparisonResult listCompare (id obj1, id obj2, void* context)
{
  //自分が比較したいオブジェクトに変換
  Company* my = obj1;
  Company* target = obj2;
  
  return [target.name localizedCaseInsensitiveCompare:my.name];
}

// google map での検索
-(void)searchGoogle:(NSString *)address
{
  // エンコード
  NSString *target= address = [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  
  // google maps api へリクエストを送信
  NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSString stringWithFormat:@"%@", target], @"address", nil];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://maps.googleapis.com/maps/api/geocode/json"]];
  [parameters setValue:@"true" forKey:@"sensor"];
  [parameters setValue:[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode] forKey:@"language"];
  NSMutableArray *paramStringsArray = [NSMutableArray arrayWithCapacity:[[parameters allKeys] count]];
  
  for(NSString *key in [parameters allKeys]) {
    NSObject *paramValue = [parameters valueForKey:key];
    [paramStringsArray addObject:[NSString stringWithFormat:@"%@=%@", key, paramValue]];
  }
  
  NSString *paramsString = [paramStringsArray componentsJoinedByString:@"&"];
  NSString *baseAddress = request.URL.absoluteString;
  baseAddress = [baseAddress stringByAppendingFormat:@"?%@", paramsString];
  //NSLog(@"url %@", baseAddress);
  [request setURL:[NSURL URLWithString:baseAddress]];
  
  NSOperationQueue *queue = [NSOperationQueue mainQueue];
  
  [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *res, NSData *data, NSError *error) {
    
    if(data){
      NSDictionary *responseDict = [data objectFromJSONData];
      NSArray *resultsArray = [responseDict valueForKey:@"results"];
      NSString *status = [responseDict valueForKey:@"status"];
      
      if(![status isEqualToString:@"OK"]){
        [self searchRetakeGoogle:target Option:@"駅"];
      }
      
      NSArray *addr = [resultsArray valueForKey:@"address_components"];
      NSString *formatted_address;
      for(NSArray *add in addr){
        for(NSDictionary *a in add){
          formatted_address = [a valueForKey:@"short_name"];
          if(formatted_address) break;
        }
      }
      
      if(!formatted_address) formatted_address = address;
      
      //NSMutableArray *placemarksArray = [NSMutableArray arrayWithCapacity:[resultsArray count]];
      for(NSDictionary *placemarkDict in resultsArray){
        NSDictionary *coordinateDict = [[placemarkDict valueForKey:@"geometry"] valueForKey:@"location"];
        
        float lat = [[coordinateDict valueForKey:@"lat"] floatValue];
        float lng = [[coordinateDict valueForKey:@"lng"] floatValue];
        
        //緯度経度を取得
        CLLocationCoordinate2D tmp;
        tmp.latitude = lat;
        tmp.longitude = lng;
        
        //表示領域の中心に設定
        GMSCameraPosition *pos = [GMSCameraPosition cameraWithLatitude:tmp.latitude longitude:tmp.longitude zoom:InitialZoom];
        [map setCamera:pos];
        
        //検索地点にマーカー追加
        NSNumber *type = [[NSNumber alloc]initWithInt:ENUM_PINSEARCHLOCATION];
        NSDictionary *dat = [NSDictionary dictionaryWithObjectsAndKeys:	formatted_address , @"title",
                             pos,@"position",
                             type,@"type",nil];
        //検索地点にピン追加
        [self addMarkersToMap:dat];
        //地点検索処理
        [self searchAround:tmp];
        break;
      }
    }
    NSLog(@" error %@", error);
  }];
}

-(void)searchRetakeGoogle:(NSString *)address Option:(NSString*)opt
{
  // エンコード
  NSString *tmpAddr = [NSString stringWithFormat:@"%@%@", address, opt];
  NSString *target= address = [tmpAddr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  
  // 最後の1文字
  int length = [address length];
  NSString *lastStr = [address substringFromIndex:length-1];
  
  // google maps api へリクエストを送信
  NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSString stringWithFormat:@"%@", target], @"address", nil];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://maps.googleapis.com/maps/api/geocode/json"]];
  [parameters setValue:@"true" forKey:@"sensor"];
  [parameters setValue:[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode] forKey:@"language"];
  NSMutableArray *paramStringsArray = [NSMutableArray arrayWithCapacity:[[parameters allKeys] count]];
  
  for(NSString *key in [parameters allKeys]) {
    NSObject *paramValue = [parameters valueForKey:key];
    [paramStringsArray addObject:[NSString stringWithFormat:@"%@=%@", key, paramValue]];
  }
  
  NSString *paramsString = [paramStringsArray componentsJoinedByString:@"&"];
  NSString *baseAddress = request.URL.absoluteString;
  baseAddress = [baseAddress stringByAppendingFormat:@"?%@", paramsString];
  //NSLog(@"url %@", baseAddress);
  [request setURL:[NSURL URLWithString:baseAddress]];
  
  NSOperationQueue *queue = [NSOperationQueue mainQueue];
  
  [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *res, NSData *data, NSError *error) {
    
    if(data){
      NSDictionary *responseDict = [data objectFromJSONData];
      NSArray *resultsArray = [responseDict valueForKey:@"results"];
      NSString *status = [responseDict valueForKey:@"status"];
      
      if(![status isEqualToString:@"OK"]){
        if([lastStr isEqualToString:@"駅"] && [opt isEqualToString:@"駅"]){
          [self searchRetakeGoogle:target Option:@"町"];
        }else if([lastStr isEqualToString:@"町"] &&[opt isEqualToString:@"町"]){
          [self searchRetakeGoogle:target Option:@"区"];
        } if([lastStr isEqualToString:@"区"] &&[opt isEqualToString:@"区"]){
          [self searchRetakeGoogle:target Option:@"市"];
        } if([lastStr isEqualToString:@"市"] &&[opt isEqualToString:@"市"]){
          [self searchRetakeGoogle:target Option:@"村"];
        } if([lastStr isEqualToString:@"町"] &&[opt isEqualToString:@"町"]){
          [self searchRetakeGoogle:target Option:@"町"];
        }else{
          // アラートを閉じる
          if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
          
          [selectedList removeAllObjects];
          [sortedList removeAllObjects];
          
          
          // 確認アラート
          UIAlertView *nonAlertView =
          [[UIAlertView alloc]
           initWithTitle:[pData getDataForKey:@"DEFINE_MAP_NOTFOUND"]
           message:nil
           delegate:nil
           cancelButtonTitle:nil
           otherButtonTitles:[pData getDataForKey:@"DEFINE_MAP_CONFIRM"], nil
           ];
          [nonAlertView show];
          
          
          [self setNaviRightButton:YES];
          self.sBar.text = searchText;
        }
      }
      
      NSArray *addr = [resultsArray valueForKey:@"address_components"];
      NSString *formatted_address;
      for(NSArray *add in addr){
        for(NSDictionary *a in add){
          formatted_address = [a valueForKey:@"short_name"];
          if(formatted_address) break;
        }
      }
      
      if(!formatted_address) formatted_address = tmpAddr;
      
      for(NSDictionary *placemarkDict in resultsArray){
        NSDictionary *coordinateDict = [[placemarkDict valueForKey:@"geometry"] valueForKey:@"location"];
        
        float lat = [[coordinateDict valueForKey:@"lat"] floatValue];
        float lng = [[coordinateDict valueForKey:@"lng"] floatValue];
        
        //緯度経度を取得
        CLLocationCoordinate2D tmp;
        tmp.latitude = lat;
        tmp.longitude = lng;
        
        //表示領域の中心に設定
        GMSCameraPosition *pos = [GMSCameraPosition cameraWithLatitude:tmp.latitude longitude:tmp.longitude zoom:InitialZoom];
        [map setCamera:pos];
        
        //検索地点にマーカー追加
        NSNumber *type = [[NSNumber alloc]initWithInt:ENUM_PINSEARCHLOCATION];
        NSDictionary *dat = [NSDictionary dictionaryWithObjectsAndKeys:	formatted_address , @"title",
                             pos,@"position",
                             type,@"type",nil];
        //検索地点にピン追加
        [self addMarkersToMap:dat];
        //地点検索処理
        [self searchAround:tmp];
        break;
      }
    }
    NSLog(@" error %@", error);
  }];
}


//サーチバー入力で逆ジオコーディング
-(void)searchBarSearchButtonClicked:
(UISearchBar*)searchBar
{
	if ( bdView.isCovered == true){
		return;
	}
	
  // コールアウトを消す
  [self.calloutView dismissCalloutAnimated:YES];
  
  //PopOverを消す
	if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
  
  //取引先リスト
	companyList = [[NSMutableArray array] init];
	selectedList = [[NSMutableArray array] init];
  sortedList = [[NSMutableArray array] init];
  
  // 検索ワードを保持
  searchWord = searchBar.text;
  [um addSearchWordList:searchWord];
  
  //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  [self alertShow];
  
	NSString *target = searchBar.text;
  //	CLGeocoder *geocoder = [[CLGeocoder alloc]init];
  
	//ピンを前削除
	[map clear];
	
  // googl map apiでジオコード
  [self searchGoogle:target];
  
  // ios SDK でジオコードする場合は下のコメントを外してください。
  /*
   [geocoder geocodeAddressString:target completionHandler:^(NSArray* placemarks, NSError* error) {
   
   [searchBar resignFirstResponder];
   for(int i=0; i<[placemarks count]; i++){
   NSLog(@"--------%@", [placemarks objectAtIndex:i]);
   }
   if ([placemarks count]){
   
   //最初の検索結果を使用
   CLPlacemark	*wrk = [placemarks objectAtIndex:0];
   
   //緯度経度を取得
   CLLocationCoordinate2D tmp = wrk.location.coordinate;
   
   //表示領域の中心に設定
   GMSCameraPosition *pos = [GMSCameraPosition cameraWithLatitude:tmp.latitude longitude:tmp.longitude zoom:initialZoom];
   [map setCamera:pos];
   
   //検索地点にマーカー追加
   NSNumber *type = [[NSNumber alloc]initWithInt:PIN_SEARCHLOCATION];
   NSDictionary *dat = [NSDictionary dictionaryWithObjectsAndKeys:	target , @"title",
   pos,@"position",
   type,@"type",nil];
   //検索地点にピン追加
   [self addMarkersToMap:dat];
   
   //地点検索処理
   [self searchAround:tmp];
   }
   // 見つからないときは再検索
   else{
   [self searchRetake:target Option:@"駅"];
   }
   }];
   */
}

// 再検索用のメソッド
-(void)searchRetake:(NSString*)str Option:(NSString*)opt
{
  int length = [str length];
  NSString *lastStr = [str substringFromIndex:length-1];
  
  NSString *target = [NSString stringWithFormat:@"%@%@", str, opt];
	CLGeocoder *geocoder = [[CLGeocoder alloc]init];
  [geocoder geocodeAddressString:target completionHandler:^(NSArray* placemarks, NSError* error) {
		if ([placemarks count]){
			
			//最初の検索結果を使用
			CLPlacemark	*wrk = [placemarks objectAtIndex:0];
			
			//緯度経度を取得
			CLLocationCoordinate2D tmp = wrk.location.coordinate;
			
			//表示領域の中心に設定
			GMSCameraPosition *pos = [GMSCameraPosition cameraWithLatitude:tmp.latitude longitude:tmp.longitude zoom:InitialZoom];
			[map setCamera:pos];
      
			//検索地点にマーカー追加
			NSNumber *type = [[NSNumber alloc]initWithInt:ENUM_PINSEARCHLOCATION];
			NSDictionary *dat = [NSDictionary dictionaryWithObjectsAndKeys:	target , @"title",
                           pos,@"position",
                           type,@"type",nil];
			//検索地点にピン追加
			[self addMarkersToMap:dat];
      
			//地点検索処理
			[self searchAround:tmp];
		}else{
      if([lastStr isEqualToString:@"駅"] && [opt isEqualToString:@"駅"]){
        [self searchRetake:str Option:@"町"];
      }else if([lastStr isEqualToString:@"町"] &&[opt isEqualToString:@"町"]){
        [self searchRetake:str Option:@"区"];
      } if([lastStr isEqualToString:@"区"] &&[opt isEqualToString:@"区"]){
        [self searchRetake:str Option:@"市"];
      } if([lastStr isEqualToString:@"市"] &&[opt isEqualToString:@"市"]){
        [self searchRetake:str Option:@"村"];
      } if([lastStr isEqualToString:@"町"] &&[opt isEqualToString:@"町"]){
        [self searchRetake:str Option:@"町"];
      }else{
        // アラートを閉じる
        if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
        
        // 確認アラート
        UIAlertView *nonAlertView =
        [[UIAlertView alloc]
         initWithTitle:[pData getDataForKey:@"DEFINE_MAP_NOTFOUND"]
         message:nil
         delegate:nil
         cancelButtonTitle:nil
         otherButtonTitles:[pData getDataForKey:@"DEFINE_MAP_CONFIRM"], nil
         ];
        [nonAlertView show];
        
        [self setNaviRightButton:YES];
        self.sBar.text = searchText;
      }
    }
	}];
}

//地点検索
-(void)searchAround:(CLLocationCoordinate2D)point;
{
  searchFlg = NO; // 結果受信後にYESに
  
	// ローディング
	[self alertShow];
  /*
   double	latmax,
   latmin,
   lngmax,
   lngmin;
   */
	
	//検索地点保存
	searchPos = point;
	
	//zoom用配列初期化
	aryForZoom = [NSMutableArray array];
	
	latmax = point.latitude + SearchAreaLat;
	latmin = point.latitude - SearchAreaLat;
	lngmax = point.longitude + SearchAreaLng;
	lngmin = point.longitude - SearchAreaLng;
	
	//クエリ作成
	NSString *query1 = @"SELECT Account__r.Id, Account__r.Name, Account__r.Phone, Account__r.BillingState, Account__r.BillingCity, Account__r.BillingStreet, GPS__Latitude__s, GPS__Longitude__s, Account__r.status__c ";
	NSString *query2 = [NSString stringWithFormat:@"FROM LatLngObj__c WHERE GPS__Latitude__s <= %f AND GPS__Latitude__s >= %f AND GPS__Longitude__s <= %f AND GPS__Longitude__s >= %f",latmax,latmin,lngmax,lngmin];
  
	NSString *query = [query1 stringByAppendingString:query2];
	NSLog(@"%@",query);
	requestArround = [[SFRestAPI sharedInstance] requestForQuery:query];
	[[SFRestAPI sharedInstance] send:requestArround delegate:self];
  
	// ビル検索
	if ( dispType == ENUM_DISPNORMAL){
		[self getBuildingInfo];
	}
}

-(void)getBuildingInfo
{
	//ビルディング検索
	NSString *query1 = @"SELECT Id,Name, floor__c,GPS__Latitude__s, GPS__Longitude__s ";
	NSString *query2 = [NSString stringWithFormat:@"FROM Building__c WHERE GPS__Latitude__s <= %f AND GPS__Latitude__s >= %f AND GPS__Longitude__s <= %f AND GPS__Longitude__s >= %f",latmax,latmin,lngmax,lngmin];
	
	NSString *query = [query1 stringByAppendingString:query2];
	NSLog(@"%@",query);
	requestbuilding = [[SFRestAPI sharedInstance] requestForQuery:query];
	[[SFRestAPI sharedInstance] send:requestbuilding delegate:self];
	
}

//ビルの情報を受信
-(void)rcvBuilding:(id)jsonResponse
{
	NSArray *records = [jsonResponse objectForKey:@"records"];
  NSLog(@"request:didLoadResponse: #records: %d", records.count);
	
	buildingList = [NSMutableArray array];
	
	for ( NSDictionary *obj in records ) {
		CLLocationCoordinate2D point;
		point.latitude = [[obj objectForKey:@"GPS__Latitude__s"] doubleValue];
		point.longitude = [[obj objectForKey:@"GPS__Longitude__s"] doubleValue];
		NSString *name = [obj objectForKey:@"Name"];
		NSString *bId = [obj objectForKey:@"Id"];
		NSNumber *maxFloor = [obj objectForKey:@"floor__c"];
		building *tmpBd = [[building alloc]init];
		
		tmpBd.buildingId = bId;
		tmpBd.name = name;
		tmpBd.position = point;
		tmpBd.maxFloor = maxFloor;
		[buildingList addObject:tmpBd];
		
		//ズーム用配列に追加
		Company *tempcp = [[Company alloc]init];
		tempcp.position = point;
		[aryForZoom addObject:tempcp];
	}
	[self getFloorInfo:buildingList];

	if (( selectMode & BUILDING)&&(dispType==ENUM_DISPNORMAL)){
		[self addBulindingPinByArray:buildingList];
	}
	
  //	[self mapZoom:searchPos points:aryForZoom];
  
}


//ビルに含まれる取引先を求める
-(void)getFloorInfo:(NSMutableArray*)ary
{
	if ( [ary count] == 0 ){
		return;
	}
  
	building *tmpbd = [ary objectAtIndex:0];
	NSString *where = [NSString stringWithFormat:@"Building__c = '%@' ", tmpbd.buildingId];
	
	for ( int i = 1; i < [ary count]; i++ ){
		tmpbd = [ary objectAtIndex:i];
		NSString *add = [NSString stringWithFormat:@" OR Building__c='%@'",tmpbd.buildingId];
		where = [NSString stringWithFormat:@"%@%@", where,add];
	}
  
	//クエリ作成
	NSString *query = [NSString stringWithFormat:@"SELECT Building__c, account__c, floor__c FROM B_Account__c WHERE %@ ORDER BY floor__c DESC",where];
	
	NSLog(@"%@",query);
	requestFloor = [[SFRestAPI sharedInstance] requestForQuery:query];
	[[SFRestAPI sharedInstance] send:requestFloor delegate:self];
}


//ビルに含まれる取引先を受信
-(void)rcvFoor:(id)jsonResponse
{
	NSLog(@"%@",jsonResponse);
	NSArray *records = [jsonResponse objectForKey:@"records"];
  NSLog(@"request:didLoadResponse: #records: %d", records.count);
	
	for ( int i = 0 ; i< [records count]; i++) {
		NSDictionary *dic = [records objectAtIndex:i];
		NSString *bId = [dic objectForKey:@"Building__c"];
		NSNumber *flrNum = [dic objectForKey:@"floor__c"];
		NSString *cpId = [dic objectForKey:@"account__c"];
		Company *tempcp = [[Company alloc]init];
		NSMutableDictionary *flrDict = [NSMutableDictionary dictionary];
    
		tempcp.company_id = cpId;
		
		[flrDict setObject:tempcp forKey:@"cp"];
		[flrDict setObject:[flrNum stringValue] forKey:@"name"];
		
		//取引先のIDとフロア番号を保存
		for ( int ii = 0 ; ii < [buildingList count]; ii++ ) {
			building *tempbd = [buildingList objectAtIndex:ii];
			if ( [tempbd.buildingId isEqualToString:bId] ) {
				[tempbd.includeArray addObject:flrDict];
				break;
			}
		}
	}
	
	//会社名を求める
  //	for ( int ii = 0 ; ii < [buildingList count]; ii++ ) {
  //		building *tempbd = [buildingList objectAtIndex:ii];
  //		[self getCompanyName:tempbd];
  //	}
	[self getCompanyName:buildingList];
}

//ビルに含まれる取引先名を受信
-(void)rcvCpName:(id)jsonResponse
{
	NSLog(@"%@",jsonResponse);
	NSArray *records = [jsonResponse objectForKey:@"records"];
  NSLog(@"request:didLoadResponse: #records: %d", records.count);
	
	for ( int i = 0 ; i< [records count]; i++) {
		NSDictionary *dic = [records objectAtIndex:i];
		
		if ([dic objectForKey:@"Account__r"] != [NSNull null]){
			NSDictionary *customObj = [dic objectForKey:@"Account__r"];
			CLLocationCoordinate2D point;
			point.latitude = [[dic objectForKey:@"GPS__Latitude__s"] doubleValue];
			point.longitude = [[dic objectForKey:@"GPS__Longitude__s"] doubleValue];
			NSString *cpName = [customObj objectForKey:@"Name"];
			NSString *cpId = [customObj objectForKey:@"Id"];
			NSString *state = [self chkString:[customObj objectForKey:@"BillingState"]];
			NSString *city = [self chkString:[customObj objectForKey:@"BillingCity"]];
			NSString *street = [self chkString:[customObj objectForKey:@"BillingStreet"]];
			NSString *phone = [self chkString:[customObj objectForKey:@"Phone"]];
			NSString *status = [self chkString:[customObj objectForKey:@"status__c"]];
      
			for ( int i = 0 ; i < [buildingList count]; i++){
				building *tempbd = [buildingList objectAtIndex:i];
				for( int ii = 0 ; ii < [tempbd.includeArray count]; ii++){
					NSDictionary *tempDic = [tempbd.includeArray objectAtIndex:ii];
					Company *tempcp = [tempDic objectForKey:@"cp"];
          
					if ( [tempcp.company_id isEqualToString:cpId] ){
						tempcp.name = cpName;
						tempcp.Address1 = [state stringByAppendingString:city];
						tempcp.Address2 = street;
						tempcp.phone1 = phone;
						tempcp.position = point;
						if (status != nil && ![status isEqual:[NSNull null]]) {
							if([status isEqual:@"SalesUp"]){
								tempcp.salesStatus = SALES_UP;
							}else if([status isEqual:@"SalesDown"]){
								tempcp.salesStatus = SALES_DOWN;
							}else{
								tempcp.salesStatus = SALES_FLAT;
							}
						}else{
							tempcp.salesStatus = SALES_FLAT;
						}
            //						break;
					}
				}
			}
		}
	}
}


//ビルに含まれる取引先の社名を求める
//-(void)getCompanyName:(building*)bd
-(void)getCompanyName:(NSMutableArray*)bdary
{
	if ( [bdary count] == 0 ){
		return;
	}
	building *tmpBd = [bdary objectAtIndex:0];
	NSMutableArray *ary = tmpBd.includeArray;
	
	NSMutableDictionary *dic =[ary objectAtIndex:0];
	Company *tempcp = [dic objectForKey:@"cp"];
	NSString *where = [NSString stringWithFormat:@"Account__r.Id = '%@' ", tempcp.company_id];
	for ( int i = 1; i < [ary count]; i++ ){
		dic = [ary objectAtIndex:i];
		tempcp = [dic objectForKey:@"cp"];
		NSString *add = [NSString stringWithFormat:@" OR Account__r.Id='%@'",tempcp.company_id];
		where = [NSString stringWithFormat:@"%@%@", where,add];
	}
  
	for ( int ii = 1; ii < [bdary count]; ii++ ){
		tmpBd = [bdary objectAtIndex:ii];
		ary = tmpBd.includeArray;
		for ( int i = 0; i < [ary count]; i++ ){
			dic = [ary objectAtIndex:i];
			tempcp = [dic objectForKey:@"cp"];
			NSString *add = [NSString stringWithFormat:@" OR Account__r.Id='%@'",tempcp.company_id];
			where = [NSString stringWithFormat:@"%@%@", where,add];
		}
	}
	
  //	NSString *query = [NSString stringWithFormat:@"SELECT Name,Id,Phone,BillingState,BillingCity,BillingStreet FROM Account WHERE %@",where];
  
	//クエリ作成
	NSString *query1 = @"SELECT Account__r.Id, Account__r.Name, Account__r.Phone, Account__r.BillingState, Account__r.BillingCity, Account__r.BillingStreet, GPS__Latitude__s, GPS__Longitude__s, Account__r.status__c ";
	NSString *query2 = [NSString stringWithFormat:@"FROM LatLngObj__c WHERE %@",where];
  
	NSString *query = [query1 stringByAppendingString:query2];
	
	NSLog(@"%@",query);
	requestCpName = [[SFRestAPI sharedInstance] requestForQuery:query];
	[[SFRestAPI sharedInstance] send:requestCpName delegate:self];
  
}


//SOQLのアンサー受信
- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
  
	if ( request == requestbuilding ) {
		[self rcvBuilding:jsonResponse];
		return;
	}
	else if ( request == requestFloor) {
		[self rcvFoor:jsonResponse];
		return;
	}
	else if ( request == requestCpName ){
		[self rcvCpName:jsonResponse];
		return;
	}
	
  // 初回の受信時のみクリアに
  NSLog(@"searchFlg : %d", searchFlg);
  if(!searchFlg){
    companyList = [NSMutableArray array];
	}
  
  NSArray *records = [jsonResponse objectForKey:@"records"];
  NSLog(@"request:didLoadResponse: #records: %d", records.count);
	
	// アラートを閉じる
	if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
	
	for ( NSDictionary *obj in records ) {
		CLLocationCoordinate2D point;
		//point.latitude = [[obj objectForKey:@"LatNum__c"] doubleValue];
		//point.longitude = [[obj objectForKey:@"LngNum__c"] doubleValue];
		
		point.latitude = [[obj objectForKey:@"GPS__Latitude__s"] doubleValue];
		point.longitude = [[obj objectForKey:@"GPS__Longitude__s"] doubleValue];
    
		if ([obj objectForKey:@"Account__r"] != [NSNull null]){
			NSDictionary *customObj = [obj objectForKey:@"Account__r"];
			NSString *title = [self chkString:[customObj objectForKey:@"Name"]];
			NSString *cid = [self chkString:[customObj objectForKey:@"Id"]];
			NSString *state = [self chkString:[customObj objectForKey:@"BillingState"]];
			NSString *city = [self chkString:[customObj objectForKey:@"BillingCity"]];
			NSString *street = [self chkString:[customObj objectForKey:@"BillingStreet"]];
			NSString *phone = [self chkString:[customObj objectForKey:@"Phone"]];
			NSString *status = [self chkString:[customObj objectForKey:@"status__c"]];
			
			Company *tempcp = [[Company alloc]init];
			tempcp.company_id = cid;
			tempcp.position = point;
			tempcp.name = title;
			tempcp.Address1 = [state stringByAppendingString:city];
			tempcp.Address2 = street;
			tempcp.phone1 = phone;
			
			if (status != nil && ![status isEqual:[NSNull null]]) {
				if([status isEqual:@"SalesUp"]){
					tempcp.salesStatus = SALES_UP;
				}else if([status isEqual:@"SalesDown"]){
					tempcp.salesStatus = SALES_DOWN;
				}else{
					tempcp.salesStatus = SALES_FLAT;
				}
			}else{
				tempcp.salesStatus = SALES_FLAT;
			}
   
			NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
			NSData *iData;
			UIImage *cpimage;
			NSString *image_key;
      
			image_key = [NSString stringWithFormat:@"img_%@",tempcp.company_id];
			iData = [ud objectForKey:image_key];
			cpimage = [UIImage imageWithData:iData];
			tempcp.image = cpimage;
      
			[companyList addObject:tempcp];
			[aryForZoom addObject:tempcp];
		}
	}
	//[self getBuildingInfo];

	//売上/従業員数を求める
	[self getEmployee:companyList];
	
	// アラートを閉じる
	if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
  
	if ( [companyList count]) {
		
		//ソート
		sortedList = [self sortList:companyList];
		
		//フィルタリング処理
		selectedList = [self applyFiller:selectMode src:sortedList];
	
		if ( dispType == ENUM_DISPNORMAL) {
			//ピン追加
			[self addCompanyPinByArray:selectedList];
		
			//マップサイズ調整
			[self mapZoom:searchPos points:aryForZoom];
		}
	}
	// 検索結果が無い場合
	else{
		[self setNaviRightButton:NO];
		[selectedList removeAllObjects];
		[sortedList removeAllObjects];
	}
	
  
	// 初回表示フラグ
	isFirst = NO;
  
  // 検索中フラグ
  searchFlg = YES;
  
  [self performSelectorInBackground:@selector(requestCpImage) withObject:nil];
}

//マップの表示範囲調整
-(void)mapZoom:(CLLocationCoordinate2D)center points:(NSMutableArray*)array
{
  NSLog(@"aryForZoom : %@", aryForZoom);
  NSLog(@"aryForZoom count : %d", [aryForZoom count]);
  if([aryForZoom count]==0)return;
  
	double	latmax_,latmin_,
  lngmax_, lngmin_;
	
	
#if 0
 	latmax_ = 0;
 	lngmax_ = 0;
 	latmin_ = 999;
 	lngmin_ = 999;
	//検索結果リストから緯度経度の最大値を求める
	for ( int i = 0; i < [array count]; i++ ){
		Company *cp = [array objectAtIndex:i];
    
		if ( cp.position.latitude > latmax_ ) {
			latmax_ = cp.position.latitude;
		}
		if ( cp.position.latitude < latmin_ ) {
			latmin_ = cp.position.latitude;
		}
		
		if ( cp.position.longitude > lngmax_ ) {
			lngmax_ = cp.position.longitude;
		}
		if ( cp.position.longitude < lngmin_ ) {
			lngmin_ = cp.position.longitude;
		}
	}
#else
	latmax_ = latmax;
	lngmax_ = lngmax;
	latmin_ = latmin;
	lngmin_ = lngmin;
#endif
	//中心地から左上、右下までの差分を求める
	double	diffLeft,diffRight,
  diffUp,diffDown;
	
	diffLeft = fabs(center.longitude - lngmin_);
	diffRight = fabs(lngmax_ - center.longitude);
	diffUp = fabs(latmax_ - center.latitude);
	diffDown = fabs(center.latitude - latmin_);
	
	//中心点から左端、右端までの距離を揃える
	if ( diffLeft > diffRight ) {
		diffRight = diffLeft;
	}
	else {
		diffLeft = diffRight;
	}
  
	//中心点から上端、下端までの距離を揃える
	if ( diffUp > diffDown ) {
		diffDown = diffUp;
	}
	else {
		diffUp = diffDown;
	}
	
	//表示範囲の南西、北東点を求める
	CLLocationCoordinate2D southWest,northEast;
	southWest.latitude = center.latitude + diffUp;
	southWest.longitude = center.longitude - diffLeft;
	northEast.latitude = center.latitude  - diffDown;
	northEast.longitude = center.longitude + diffRight;
  
	float mapViewWidth = self.mapView.frame.size.width;
	float mapViewHeight = self.mapView.frame.size.height-180;
	
	MKMapPoint point1 = MKMapPointForCoordinate(southWest);
	MKMapPoint point2 = MKMapPointForCoordinate(northEast);
  
  //	MKMapPoint centrePoint = MKMapPointMake(
  //											(point1.x + point2.x) / 2,
  //											(point1.y + point2.y) / 2);
  //	CLLocationCoordinate2D centreLocation = MKCoordinateForMapPoint(centrePoint);
	double mapScaleWidth = mapViewWidth / fabs(point2.x - point1.x);
	double mapScaleHeight = mapViewHeight / fabs(point2.y - point1.y);
	double mapScale = MIN(mapScaleWidth, mapScaleHeight);
	
	double zoomLevel = 20 + log2(mapScale);
	
	GMSCameraPosition *camera = [GMSCameraPosition
                               cameraWithLatitude: center.latitude
                               longitude: center.longitude
                               zoom: zoomLevel];
  
	[map setCamera:camera];
	
}

//受け取ったオブジェクトがNSString以外なら空のNSStringを返す
-(NSString*)chkString:(id)tgt
{
	NSString *cls = NSStringFromClass([tgt class]);
	if ( ![cls isEqualToString:@"__NSCFString"]) {
		return @"";
	}
	else {
		return tgt;
	}
}

//Buildingの配列を受け取り、ピンを追加
-(void)addBulindingPinByArray:(NSMutableArray*)ary
{
	for( int i = 0; i < [ary count]; i++){
		[self addBuildingPin:[ary objectAtIndex:i]];
	}
	
}

//companyの配列を受け取り、ピンを追加
-(void)addCompanyPinByArray:(NSMutableArray*)ary
{
	for( int i = 0; i < [ary count]; i++){
		[self addCompanyPin:[ary objectAtIndex:i]];
	}
}

//ビル情報を元にピン追加
-(void)addBuildingPin:(building *)bd
{
	GMSCameraPosition *pos = [GMSCameraPosition cameraWithTarget:bd.position zoom:InitialZoom];
	NSString *title = bd.name;
	NSNumber *type = [[NSNumber alloc]initWithInt:ENUM_PINBUILDING];
	NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:	pos,@"position",
                       title,@"title",
                       type,@"type",
                       bd,@"company",
                       nil];
	
	[self addMarkersToMap:dic];
	
}

//会社情報を元にピン追加
-(void)addCompanyPin:(Company*)cp
{
	GMSCameraPosition *pos = [GMSCameraPosition cameraWithTarget:cp.position zoom:InitialZoom];
	NSString *title = cp.name;
	NSNumber *type = [[NSNumber alloc]initWithInt:ENUM_PINCOMPANY];
	NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:	pos,@"position",
                       title,@"title",
                       type,@"type",
                       cp,@"company",
                       nil];
	
	[self addMarkersToMap:dic];
}

//UIViewをUIImageに変換する
- (UIImage*)createUIImageFromUIView:(UIView*)view
{
    UIGraphicsBeginImageContext( CGSizeMake( view.bounds.size.width, view.bounds.size.height ) );
    CGContextScaleCTM( UIGraphicsGetCurrentContext(), 1.0f, 1.0f );
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}

-(UIImage*)makeCircleMarker:(float)dimeter badge:(int)badge color:(UIColor*)color
{
	//バッジ用フォント
	UIFont *font = [UIFont boldSystemFontOfSize:18];
	
	//バッジサイズを求める為に、UILabelを使う
	UILabel *strLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 100)];
	strLabel.text = [NSString stringWithFormat:@"%d",badge];
	[strLabel setFont:font];
	[strLabel setLineBreakMode:UILineBreakModeWordWrap];
	[strLabel sizeToFit];
	CGSize bSize = strLabel.frame.size;

	//バッジ作成
	CGRect r = CGRectMake(0, 0, bSize.width+10, bSize.height);
	ItemBadge* bagdeView = [[ItemBadge alloc] initWithFrame:r];
	bagdeView.textLabel.text = [NSString stringWithFormat:@"%d", badge];

	//ピンマーカーの円を作成
	CGRect rect = CGRectMake(0, 0, dimeter, dimeter);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
	
	//FillColor
	CGContextSetFillColorWithColor(contextRef, color.CGColor);
	
	//DrawColor
	CGContextSetStrokeColorWithColor(contextRef,  [[UIColor clearColor]CGColor]);
	
    //円を描画
	CGContextFillEllipseInRect(contextRef, CGRectMake(0, 0, dimeter, dimeter));
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
	imgV.image = img;

	//ベースビューに円のイメージを貼る
	//マーカタップ時に吹き出しが真ん中から出るように全体の横幅を調整する
	CGRect viewRect;
	if ( bagdeView.frame.size.width*2 > dimeter) {
		viewRect = CGRectMake(0, 0, (bagdeView.frame.size.width+(dimeter/5))*2, bagdeView.frame.size.height/2 + dimeter );
		CGPoint center = imgV.center;
//		center.x = bagdeView.frame.size.width;
		center.x = bagdeView.frame.size.width+(dimeter/5);
		center.y += bagdeView.frame.size.height / 2;
		imgV.center = center;

		CGRect badgeRect = bagdeView.frame;
//		badgeRect.origin.x = center.x;
		badgeRect.origin.x = center.x+(dimeter/5);
		badgeRect.origin.y = 0;
		bagdeView.frame = badgeRect;
	}
	else {
		viewRect = CGRectMake(0, 0, (dimeter+(dimeter/5)*2), bagdeView.frame.size.height/2 + dimeter );
		CGPoint center = imgV.center;
		center.y += bagdeView.frame.size.height / 2;
//		center.y += bagdeView.frame.size.height+50;
		center.x += +(dimeter/5);
		imgV.center = center;

		CGRect badgeRect = bagdeView.frame;
//		badgeRect.origin.x = dimeter/2;
		badgeRect.origin.x = dimeter/2+(dimeter/5)+(dimeter/5);
		badgeRect.origin.y = 0;
		bagdeView.frame = badgeRect;
	}
	
	UIView *baseView = [[UIView alloc]initWithFrame:viewRect];
	[baseView setBackgroundColor:[UIColor clearColor]];
	[baseView addSubview:imgV];
	[baseView addSubview:bagdeView];

	return [self createUIImageFromUIView:baseView];
 }


//円マーカーを追加
-(void)addCircleMarkerToMap:(NSDictionary*)dic
{
    UIImage *pinImage;
	double dimeter = 0;
	UIColor *color;

	GMSMarkerOptions *op = [[GMSMarkerOptions alloc] init];
	GMSCameraPosition *pos = [dic objectForKey:@"position"];
	Company *cp = [dic objectForKey:@"company"];
	op.position = pos.target;
	op.title = [dic objectForKey:@"title"];
	op.userData = dic;
	op.groundAnchor = CGPointMake(0.5, 0);
	
	
	//ピンの画像指定
	NSNumber *num = [dic objectForKey:@"type"];
	switch ([num intValue]) {
		case ENUM_PINSEARCHLOCATION:
		case ENUM_PINCURRENTLOCATION:
			pinImage = [UIImage imageNamed:@"location1.png"];
			op.icon = pinImage;
			
			//検索地点を記録
			lastSerachLocation = op;
			break;
			
		case ENUM_PINCOMPANY:

			//マーカーピンの色を求める
			if ( cp.salesStatus == SALES_UP) {
				color = [UIColor colorWithRed:0.45 green:0.71 blue:0.43 alpha:0.7];
			}
			else if ( cp.salesStatus == SALES_FLAT) {
				color = [UIColor colorWithRed:1.00 green:0.73 blue:0.22 alpha:0.7];
			}
			else {
				color = [UIColor colorWithRed:0.73 green:0.30 blue:0.32 alpha:0.7];
			}
/*
			//マーカピンの直径を求める
			dimeter = (cp.yearSales +1)* (cp.employee+1) / 10000;
			if ( dimeter > MaxDimeter ) {
				dimeter = MaxDimeter;
			}
			if ( dimeter < MinDimeter ) {
				dimeter = MinDimeter;
			}
*/
			dimeter = [self getRadius:cp];
			
			int badgeVal = 0;
			if (dispType == ENUM_DISPVISIT){
				//バッジに訪問回数を表示
				badgeVal = cp.visitCount;
			}
			else {
				//バッジに商談数を表示
				badgeVal = cp.opportunityCount;
			}
//			dimeter = 200;
//			badgeVal = 100000;
			op.icon = [self makeCircleMarker:dimeter badge:badgeVal color:color];
			op.groundAnchor = CGPointMake(0.5, [self getTrimVal:dimeter]);
//			op.icon = [self makeCircleMarker:200 badge:100 color:color];
//			op.groundAnchor = CGPointMake(0.5, 0.67);

			break;

		case ENUM_PINBUILDING:
			pinImage = [UIImage imageNamed:@"Building.png"];
			op.icon = pinImage;
			break;
		default:
			break;
	}
	[map addMarkerWithOptions:op];
}
-(float)getTrimVal:(float)dimeter
{
	/*
	 30:1.2
	 40:1.1
	 50:1.0
	 60:0.9
	 70:0.85
	 90:0.80
	 100:0.78
	 110:0.76
	 120:0.75
	 130:0.74
	 140:0.73
	 150:0.72
	 160:0.71
	 170:0.70
	 180:0.69
	 190:0.68
	 200:0.67
*/
	
	if (dimeter <= 30 )return 1.2f;
	if (dimeter <= 40 )return 1.1f;
	if (dimeter <= 50 )return 1.0f;
	if (dimeter <= 60 )return 0.9f;
	if (dimeter <= 70 )return 0.85f;
	if (dimeter <= 80 )return 0.82f;
	if (dimeter <= 90 )return 0.80f;
	if (dimeter <= 100 )return 0.78f;
	if (dimeter <= 110 )return 0.76f;
	if (dimeter <= 120 )return 0.75f;
	if (dimeter <= 130 )return 0.74f;
	if (dimeter <= 140 )return 0.73f;
	if (dimeter <= 150 )return 0.72f;
	if (dimeter <= 160 )return 0.71f;
	if (dimeter <= 170 )return 0.70f;
	if (dimeter <= 180 )return 0.69f;
	if (dimeter <= 190 )return 0.68f;
	if (dimeter <= 200 )return 0.67f;

	return 0.66f;
}
//マーカーピン追加
- (void)addMarkersToMap:(NSDictionary*)dic
{
	//円マーカー描画の場合は、別関数で処理
	if ( dispType != ENUM_DISPNORMAL){
		[self addCircleMarkerToMap:dic];
		return;
	}
    UIImage *pinImage;
	Company *cp;
  
	GMSMarkerOptions *op = [[GMSMarkerOptions alloc] init];
	GMSCameraPosition *pos = [dic objectForKey:@"position"];
	op.position = pos.target;
	op.title = [dic objectForKey:@"title"];
	op.userData = dic;
	op.groundAnchor = CGPointMake(0.5, 1.0);
  
	//ピンの画像指定
	NSNumber *num = [dic objectForKey:@"type"];
	switch ([num intValue]) {
		case ENUM_PINSEARCHLOCATION:
		case ENUM_PINCURRENTLOCATION:
			pinImage = [UIImage imageNamed:@"location1.png"];
			op.icon = pinImage;
      
			//検索地点を記録
			lastSerachLocation = op;
			break;
			
		case ENUM_PINCOMPANY:
			cp = [dic objectForKey:@"company"];
			if ( cp.salesStatus == SALES_UP) {
				pinImage = [UIImage imageNamed:@"salesup.png"];
			}
			else if ( cp.salesStatus == SALES_FLAT) {
				pinImage = [UIImage imageNamed:@"salesflat.png"];
			}
			else {
				pinImage = [UIImage imageNamed:@"salesdown.png"];
			}
			op.icon = pinImage;
			break;
		case ENUM_PINBUILDING:
			pinImage = [UIImage imageNamed:@"Building.png"];
			op.icon = pinImage;
			break;
		default:
			break;
	}
	[map addMarkerWithOptions:op];
	
}
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(id<GMSMarker>)marker
{
	NSDictionary *userDat = marker.userData;
	NSNumber *type = [userDat objectForKey:@"type"];
	
	CLLocationCoordinate2D anchor = marker.position;
	CGPoint point = [mapView.projection pointForCoordinate:anchor];
	NSLog(@"%f:%f",point.x, point.y);
	CGRect startRect;
	startRect.origin =CGPointMake(point.x - 50, point.y - 100 );
  //	startRect.size = CGSizeZero;
	startRect.size = CGSizeMake(100,200);
	
	if ( point.x >= (1024/2)) {
		finalPoint.x = 200;
	}
	else {
		finalPoint.x = 200 + ( 1024 / 2 );
	}
	finalPoint.y = 50;
	bdView.baseView.alpha = 0.5f;
	bdView.baseView.frame = startRect;
	
	//ピン種別判定
	if ( ENUM_PINBUILDING == [type intValue]){
		
		building *bd = [userDat objectForKey:@"company"];
		bdView = [[BuildingView alloc]init];
		bdView.bd = bd;
		bdView.delegate = self;
		
		// フリップ移動前処理
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDuration:0.0];
		bdView.baseView.alpha = 0.3f;
		bdView.baseView.frame = startRect;
		[UIView setAnimationDidStopSelector:@selector(dispViewAppear:finished:context:)];
		[UIView commitAnimations];
		
		[self.view addSubview:bdView.coverView];
		[self.view addSubview:[bdView buildView]];
		
		
		//既存のコールアウトを消去
		self.calloutView.hidden = YES;
    
		//コールアウトは表示しない
		return YES;
	}
	
	//コールアウト表示
	return NO;
}

// フリップ移動
- (void)dispViewAppear:(NSString *)animationID finished:(NSNumber *) finished context:(void *) context
{
	CGRect endRect = CGRectMake(finalPoint.x,finalPoint.y, 300, 440);
  
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.5];
	bdView.baseView.alpha = 1.0;
	bdView.baseView.frame = endRect;
  
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:bdView.baseView cache:YES];
	[UIView setAnimationDidStopSelector:@selector(dispViewAppear2:finished:context:)];
	[UIView commitAnimations];
	
	
}
- (void)dispViewAppear2:(NSString *)animationID finished:(NSNumber *) finished context:(void *) context
{
	[bdView buildfinish];
	[bdView setCoverAlpha];
}


//ビルのフロアをタップした時のデリゲート
-(void)didTapFloor:(Company *)cp
{
	//戻り先を記録
	pData = [PublicDatas instance];
	[pData setData:@"MAP" forKey:@"ReturnScreen"];
	
	// 中心地点を記憶
	[self saveCenterPoint];
	
	//店舗ビューに遷移
	if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
	MetricsViewController *metVC = [[MetricsViewController alloc]initWithNibName:@"Metrics" bundle:[NSBundle mainBundle]company:cp];
	
	//ナビゲーションバー　設定
	[self.navigationController.navigationBar setHidden:NO];
	
	//画面遷移
	[self.navigationController pushViewController:metVC animated:YES];
}

//コールアウト作成
- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(id<GMSMarker>)marker
{
	self.calloutView.hidden = YES;
	
	
	NSDictionary *userDat = marker.userData;
	NSNumber *type = [userDat objectForKey:@"type"];
	
	//SMCallOutTest
	self.calloutView = [[SMCalloutView alloc] init];
	
  if ( ENUM_PINCOMPANY != [type intValue]){
		
		//現在地／検索地点の場合 タイトルのみ表示
		[self.calloutView setTitle:[userDat objectForKey:@"title"]];
	}
	else {
    
		//表示データ取得
		Company *cp = [userDat objectForKey:@"company"];
    
    
		//コールアウト右側のボタン
		UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[button addTarget:self action:@selector(calloutAccessoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		self.calloutView.rightAccessoryView = button;
    
		self.emptyCalloutView = [[UIView alloc] initWithFrame:CGRectZero];
    
		//画像
    
		UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,60,60)];
    UIImage *leftImage;
    if (cp.image) {
      leftImage = [self resizeImage:cp.image Rect:imgV.frame];
    }else{
      leftImage = [self resizeImage:[UIImage imageNamed:@"noimage.png"] Rect:imgV.frame];
    }
		imgV.image = leftImage;
		CGSize siz = leftImage.size;
		CGRect rect = imgV.frame;
		rect.size = siz;
		imgV.frame = rect;
    
    
		//コールアウトのContentビュー作成
		UIView *cView = [[UIView alloc]initWithFrame:CGRectZero];			//仮のサイズ
		UILabel *nameLbl = [[UILabel alloc]initWithFrame:CGRectZero];		//仮のサイズ
		UILabel *adLbl = [[UILabel alloc]initWithFrame:CGRectZero];			//仮のサイズ
    
		//文字列の大きさを求める
		UIFont *font = [UIFont systemFontOfSize:18];
    //		CGSize nameSize = [cp.name sizeWithFont:font constrainedToSize:CGSizeMake(300,40) lineBreakMode:NSLineBreakByClipping];
		[nameLbl setLineBreakMode:UILineBreakModeWordWrap];
		nameLbl.numberOfLines = 0;
		CGSize nameSize = [cp.name sizeWithFont:font constrainedToSize:CGSizeMake(300,40) lineBreakMode:NSLineBreakByWordWrapping];
    
		
		UIFont *font2 = [UIFont systemFontOfSize:12];
    //		CGSize adSize = [[cp.Address1 stringByAppendingString:[cp Address2]] sizeWithFont:font2 constrainedToSize:CGSizeMake(300,40) lineBreakMode:NSLineBreakByClipping];
		CGSize adSize = [[cp.Address1 stringByAppendingString:[cp Address2]] sizeWithFont:font2 constrainedToSize:CGSizeMake(300,40) lineBreakMode:NSLineBreakByWordWrapping];
		adLbl.numberOfLines = 0;
		[adLbl setLineBreakMode:UILineBreakModeWordWrap];
		
		//ラベルの大きさを文字列の大きさに合わせる
		CGRect nameRect = nameLbl.frame;
		nameRect.size =  nameSize;
    
		CGRect adRect = adLbl.frame;
		adRect.size= adSize;
    
		//名前ラベルと住所ラベルの長さを合わせる
		if ( adRect.size.width < nameRect.size.width ){
			adRect.size.width = nameRect.size.width;
		}
		else {
			nameRect.size.width = adRect.size.width;
		}
    
		//名前ラベル、住所ラベルの位置調整
		nameRect.origin.y = 0;
		adRect.origin.y = ( nameRect.origin.y + nameRect.size.height)+5;
		nameRect.origin.x = ( imgV.frame.origin.x + imgV.frame.size.width)+8;
		adRect.origin.x = nameRect.origin.x;
    
		CGRect cRect;
		cRect.origin.x = 0;
		cRect.origin.y = 0;
		cRect.size.width = (nameRect.origin.x + nameRect.size.width)+8;
		if (( nameSize.height + adSize.height) > imgV.frame.size.height ) {
			cRect.size.height = nameSize.height + adSize.height;
      
			CGPoint center = imgV.center;
			center.y = ( nameSize.height + adSize.height)/2;
			imgV.center = center;
		}
		else {
			cRect.size.height = (imgV.frame.origin.y + imgV.frame.size.height);
		}
		cView.frame = cRect;
    
		//ラベルにテキストと大きさを設定
		nameLbl.text = cp.name;
		nameLbl.font = font;
		nameLbl.backgroundColor = [UIColor clearColor];
		nameLbl.textColor = [UIColor whiteColor];
		[nameLbl setFrame:nameRect];
    
		adLbl.text = [cp.Address1 stringByAppendingString:cp.Address2];
		adLbl.font = font2;
		adLbl.backgroundColor = [UIColor clearColor];
		adLbl.textColor = [UIColor whiteColor];
		[adLbl setFrame:adRect];
    
		[cView addSubview:imgV];
		[cView addSubview:nameLbl];
		[cView addSubview:adLbl];
		self.calloutView.contentView = cView;
		
		self.calloutView.title = marker.title;
	}
  
	self.calloutView.calloutOffset = CGPointMake(0, -CalloutYOffset);
	self.calloutView.hidden = NO;
  
	CLLocationCoordinate2D anchor = marker.position;
	CGPoint point = [mapView.projection pointForCoordinate:anchor];
  CGRect calloutRect = CGRectZero;
  calloutRect.origin = point;
  calloutRect.size = CGSizeZero;
  [self.calloutView presentCalloutFromRect:calloutRect
                                    inView:mapView
                         constrainedToView:mapView
                  permittedArrowDirections:SMCalloutArrowDirectionDown
                                  animated:YES];
  
  // マップ内にinfowindowが収まる処理
  // 左に行き過ぎた
  CGFloat disx = self.calloutView.frame.origin.x;
  // 右に行き過ぎた
  CGFloat rightx = self.calloutView.frame.origin.x + self.calloutView.bounds.size.width;
  // 上に行き過ぎた
  CGFloat disy = point.y-self.calloutView.bounds.size.height-14;
  // 上記のどれかに当てはまる場合
  if(disy<0|| disx<0 || rightx > self.view.bounds.size.width){
    
    // マップの中心座標を取得
    CGPoint newpoint = CGPointMake(mapView.center.x, mapView.center.y);
    
    // 左に行き過ぎた場合は右にずらす
    if(disx<0) newpoint.x = newpoint.x + disx -10;
    // 右に行き過ぎた場合は左にずらす
    if(rightx > self.view.bounds.size.width) newpoint.x = newpoint.x +(rightx-self.view.bounds.size.width)+10;
    // 上に行き過ぎた場合は下にずらす
    if(disy<0) newpoint.y = newpoint.y + disy -5;
    
    // ずらした座標から新しい緯度経度を取得してマップの中心に指定
    CLLocationCoordinate2D cd = [mapView.projection coordinateForPoint:newpoint];
    GMSCameraPosition *pos = [GMSCameraPosition cameraWithLatitude:cd.latitude longitude:cd.longitude zoom:mapView.camera.zoom];
    if (( cd.latitude != 0.0f) && ( cd.longitude != 0.0f )){
      [map setCamera:pos];
    }
  }
  
  // 中心地点を記憶
  [self saveCenterPoint];
  
  return self.emptyCalloutView;
}


- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
  self.calloutView.hidden = YES;
}


//コールアウトビューのボタンタップ時処理 StoreViewに遷移
- (void)calloutAccessoryButtonTapped:(id)sender {
  
  //PopOverを消す
  if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
  
  if (map.selectedMarker) {
    
    id<GMSMarker> marker = map.selectedMarker;
    NSDictionary  *userData = marker.userData;
		Company *cp = [userData objectForKey:@"company"];
		
		//戻り先を記録
		pData = [PublicDatas instance];
		[pData setData:@"MAP" forKey:@"ReturnScreen"];
		
    
    // 中心地点を記憶
    [self saveCenterPoint];
    
		//店舗ビューに遷移
		if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
		MetricsViewController *metVC = [[MetricsViewController alloc]initWithNibName:@"Metrics" bundle:[NSBundle mainBundle]company:cp];
    
		//ナビゲーションバー　設定
		[self.navigationController.navigationBar setHidden:NO];
		
		
		//画面遷移
		[self.navigationController pushViewController:metVC animated:YES];
	}
}


//UIImage:imgがRectより大きい場合リサイズする
-(id)resizeImage:(UIImage*)img Rect:(CGRect)Rect
{
	if (( img.size.height > Rect.size.height) ||
      ( img.size.width > Rect.size.width)) {
    
    float asp;
    int height = Rect.size.height;
    int width  = Rect.size.width;
    int x = 0;
    int y = 0;
    
    if (img.size.height > img.size.width) {
      asp = img.size.width / img.size.height;
      width = width * asp;
      x = (Rect.size.width - width)/2;
    }else{
      asp = img.size.height / img.size.width;
      height = height * asp;
      y = (Rect.size.height - height)/2;
    }
		
		UIGraphicsBeginImageContext(Rect.size);
		[img drawInRect:CGRectMake(x,y,width,height)];
		img = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
	return img;
}


- (void)mapView:(GMSMapView *)pMapView didChangeCameraPosition:(GMSCameraPosition *)position {
  
  /* move callout with map drag */
  if (pMapView.selectedMarker != nil && !self.calloutView.hidden) {
    CLLocationCoordinate2D anchor = [pMapView.selectedMarker position];
    
    CGPoint arrowPt = self.calloutView.backgroundView.arrowPoint;
    
    CGPoint pt = [pMapView.projection pointForCoordinate:anchor];
    pt.x -= arrowPt.x;
    pt.y -= arrowPt.y + CalloutYOffset;
    
    self.calloutView.frame = (CGRect) {.origin = pt, .size = self.calloutView.frame.size };
  } else {
    self.calloutView.hidden = YES;
  }
  
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

//位置取得時処理
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	CLLocation *location;
	
	//初回の位置取得時のみ地図を移動（自身の位置追跡しない）
	location = [locations objectAtIndex:0];
  
  /*
   //デバッグ用に渋谷の位置を登録
   CLLocationCoordinate2D loc;
   loc.latitude  = 35.658273;
   loc.longitude = 139.701024;
   location = [[CLLocation alloc]initWithLatitude:loc.latitude longitude:loc.longitude];
   */
	
	if ( moveCurrentPos == YES) {
		
		
		GMSCameraPosition *pos = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude zoom:InitialZoom];
		[map setCamera:pos];
		moveCurrentPos = NO;
    /*
     //現在地にピンを立てる
     NSString *title = @"現在地";
     NSNumber *type = [[NSNumber alloc]initWithInt:PIN_CURRENTLOCATION];
     NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:pos,@"position",
     title,@"title",
     type,@"type",
     nil];
     [self addMarkersToMap:dic];
     */
		
		//地点検索処理
		[self searchAround:location.coordinate];
	}
	myPos = location.coordinate;
	[locationManager startUpdatingLocation];
}

//位置取得時処理 ios 5
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
  // 位置情報を取り出す
  myPos = newLocation.coordinate;
  
  if ( moveCurrentPos == YES) {
    // ローディング
    [self alertShow];
    moveCurrentPos = NO;
    GMSCameraPosition *pos = [GMSCameraPosition cameraWithLatitude:myPos.latitude longitude:myPos.longitude zoom:InitialZoom];
    [map setCamera:pos];
    
    /*
     //現在地にピンを立てる
     NSString *title = @"現在地";
     NSNumber *type = [[NSNumber alloc]initWithInt:PIN_CURRENTLOCATION];
     NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:pos,@"position",
     title,@"title",
     type,@"type",
     nil];
     [self addMarkersToMap:dic];
     */
    //地点検索処理
    [self searchAround:myPos];
    //[locationManager stopUpdatingLocation];
  }
}


//ナビゲーションバーの「戻る」ボタン処理
-(void)back
{
	if ( bdView.isCovered == true){
		return;
	}
  //PopOverを消す
  if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
  
	//ナビゲーションバー　設定
	[self.navigationController.navigationBar setHidden:YES];
  
	//画面遷移
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
}

-(void)segmentSel:(UISegmentedControl*)seg
{
	int sel = seg.selectedSegmentIndex;
  
	switch (sel) {
		case 0:
			map.mapType = kGMSTypeNormal;
			break;
		case 1:
			map.mapType = kGMSTypeHybrid;
			break;
		case 2:
			map.mapType = kGMSTypeSatellite;
			break;
		case 3:
			map.mapType = kGMSTypeTerrain;
			break;
		default:
			break;
	}
}


//現在地ボタン押下
-(void)currentPos
{
  //PopOverを消す
  if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
  
  // 位置情報利用チェック
  AppDelegate* appli = (AppDelegate*)[[UIApplication sharedApplication] delegate];
  
  if(![appli chkGPS]) return;
  
  // コールアウトを消す
  [self.calloutView dismissCalloutAnimated:YES];
  
  
  //取引先リスト
  companyList = [[NSMutableArray array] init];
  selectedList = [[NSMutableArray array] init];
  sortedList = [[NSMutableArray array] init];
  
  // リストボタンで復活しないように
  lastSerachLocation = nil;
  
  // 現在の検索ワードも消す
  searchWord = @"";
  
  NSArray *aOsVersions = [[[UIDevice currentDevice]systemVersion] componentsSeparatedByString:@"."];
  NSInteger iOsVersionMajor = [[aOsVersions objectAtIndex:0] intValue];
  
  // 検索窓のキーワード消去
  self.sBar.text = @"";
	//ピン消去
	[map clear];
	
  // ios 6以上
  if(iOsVersionMajor>=6){
    // ローディング
    [self alertShow];
    
    //    moveCurrentPos = YES;
    GMSCameraPosition *pos = [GMSCameraPosition cameraWithLatitude:myPos.latitude longitude:myPos.longitude zoom:InitialZoom];
    [map setCamera:pos];
    [locationManager startUpdatingLocation];
    
    
    /*
     //現在地にピンを立てる
     NSString *title = @"現在地";
     NSNumber *type = [[NSNumber alloc]initWithInt:PIN_CURRENTLOCATION];
     NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:pos,@"position",
     title,@"title",
     type,@"type",
     nil];
     [self addMarkersToMap:dic];
     */
    //地点検索処理
    [self searchAround:myPos];
	}
  // ios 5
  else{
    // 現在地情報受信開始
    [locationManager startUpdatingLocation];
  }
}


//更新
-(void)renew
{
	GMSCameraPosition *cam = [GMSCameraPosition cameraWithLatitude:comp.position.latitude longitude:comp.position.longitude zoom:12];
	[map setCamera:cam];
	
	//PolyLine,marker削除
	[map clear];
  //	[self addMarkersToMap];
}

-(void)viewDidDisappear:(BOOL)animated
{
	[map stopRendering];
  //キーボード表示・非表示の通知を終了
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewDidUnload
{
	[self setCalloutView:nil];
	[self setEmptyCalloutView:nil];
	[self setSBar:nil];
	[self setMapView:nil];
	[super viewDidUnload];
  
}



// 中心を記憶するメソッド
-(void) saveCenterPoint
{
  NSNumber *num = [NSNumber numberWithDouble:map.camera.target.latitude];
  int _lat = [num intValue];
  num = [NSNumber numberWithDouble:map.camera.target.longitude];
  int _lon = [num intValue];
  
  // 中心地点を記憶
  NSUserDefaults *userDefault =[NSUserDefaults standardUserDefaults];
  if (_lat>0)[userDefault setDouble:map.camera.target.latitude forKey:@"lat"];
  if (_lon>0)[userDefault setDouble:map.camera.target.longitude forKey:@"lon"];
  [userDefault setDouble:map.camera.zoom forKey:@"zoom"];
  [userDefault setDouble:[[UIDevice currentDevice] orientation] forKey:@"orientation"];
  [userDefault synchronize];
  
}

// 中心の値をクリア
-(void) clearCenterPoint
{
  // 値をクリア
  NSUserDefaults *userDefault =[NSUserDefaults standardUserDefaults];
  [userDefault removeObjectForKey:@"lat"];
  [userDefault removeObjectForKey:@"lon"];
  [userDefault removeObjectForKey:@"zoom"];
  [userDefault removeObjectForKey:@"orientation"];
  [userDefault synchronize];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
	
}
-(void)viewDidAppear:(BOOL)animated
{
}

//表示用の企業ロゴを別スレッドで取得
-(void)requestCpImage
{
  //画像取得　バックエンドの処理が終わっていなかったらスキップ
  if(!isImgBackJob){
    return;
  }else{
    isImgBackJob = NO;
		[self retriveImage:companyList];
		
    [self performSelectorOnMainThread:@selector(requestCpImageDidFinish) withObject:nil waitUntilDone:NO];
  }
}


- (void)requestCpImageDidFinish{
  isImgBackJob = YES;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  if( interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
     interfaceOrientation == UIInterfaceOrientationLandscapeLeft )
    return YES;
  
  return NO;
}

//画像取得
//-(void)retriveImage:(Company*)cpny
-(void)retriveImage:(NSMutableArray*)cpnyAry
{
	//画像読み込み設定がOFFの場合、読み込みを行わずに抜ける
	if ( NO == LogoLoad ){
		return;
	}
  
	if ( [cpnyAry count] == 0) {
		return;
	}
	
	NSString *where =@"";
	int loopMax = [cpnyAry count];
	for ( int i = 0; i < loopMax; i++) {
		Company *tempCp = [cpnyAry objectAtIndex:i];
		where = [where stringByAppendingString:[NSString stringWithFormat:@"ParentId='%@' ", tempCp.company_id ]];
		if ( i != loopMax - 1 ){
			where = [where stringByAppendingString:@" OR "];
		}
	}
	
	NSLog(@"%@",where);
	
	NSString *query = [NSString stringWithFormat:@"SELECT ParentId, Name,Body,BodyLength FROM Attachment WHERE %@ ORDER BY CreatedDate DESC",where];
	SFRestRequest *req = [[SFRestAPI sharedInstance] requestForQuery:query];
	[[SFRestAPI sharedInstance] sendRESTRequest:req
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      alertView = [[UIAlertView alloc]
                                                   initWithTitle:[pData getDataForKey:@"DEFINE_MAP_IMGREADERRTITLE"]
                                                   message:[pData getDataForKey:@"DEFINE_MAP_IMAREADERRMSG"]
                                                   delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:[pData getDataForKey:@"DEFINE_MAP_ALERTOK"], nil ];
                                      [alertView show];
                                    }
                                completeBlock:^(id jsonResponse){
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  NSLog(@"%@",dict);
                                  
                                  //アラート表示
                                  //			[self alertShow];
                                  [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
                                  
                                  //受信データクリア
                                  rcvData = [[NSMutableData alloc]init];
                                  NSString *image_key;
                                  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                                  
                                  NSArray *records = [dict objectForKey:@"records"];
                                  for ( int i = 0; i< [records count]; i++ ){
                                    NSDictionary *rec = [records objectAtIndex:i];
                                    NSString *url = [rec objectForKey:@"Body"];
                                    NSString *name = [rec objectForKey:@"Name"];
                                    NSString *bodyLength = [rec objectForKey:@"BodyLength"];
                                    NSString *cpId = [rec objectForKey:@"ParentId"];
                                    
                                    Company *cpny;
                                    for ( int i = 0; i < [cpnyAry count]; i++ ){
                                      cpny = [cpnyAry objectAtIndex:i];
                                      if ( [cpny.company_id isEqualToString:cpId] ){
                                        break;
                                      }
                                    }
                                    
                                    int bSize = [bodyLength intValue];
                                    NSLog(@"%@",url);
                                    
                                    //ロゴ画像を読み込み
                                    if ([self isInclude:[name uppercaseString]cmp:@"LOGO."] == YES ) {
                                      
                                      //画像サイズが閾値より大きい場合は読み込まない
                                      if ( MaxLoadingSize <= bSize ) {
                                        continue;
                                      }
                                      
                                      //リクエスト作成
                                      NSString *instance = [[[[[SFRestAPI sharedInstance] coordinator] credentials] instanceUrl]absoluteString];
                                      NSString *fullUrl = [instance stringByAppendingString:url];
                                      NSURL *myURL = [NSURL URLWithString:fullUrl];
                                      NSMutableURLRequest *requestDoc = [[NSMutableURLRequest alloc]initWithURL:myURL];
                                      
                                      //OAuth認証情報をヘッダーに追加
                                      NSString *token = [@"OAuth " stringByAppendingString:[[[[SFRestAPI sharedInstance]coordinator]credentials]	accessToken]];
                                      [requestDoc addValue:token forHTTPHeaderField:@"Authorization"];
                                      
                                      //					[NSURLConnection connectionWithRequest:requestDoc delegate:self];
                                      NSURLResponse *resp;
                                      NSError *err;
                                      
                                      NSData *rcvTmpData = [NSURLConnection sendSynchronousRequest:requestDoc returningResponse:&resp error:&err];
                                      rcvData = [rcvTmpData mutableCopy];
                                      
                                      
                                      //共用データのインスタンス取得
                                      pData = [PublicDatas instance];
                                      if ( !err ){
                                        UIImage *img = [[UIImage alloc]initWithData:rcvData];
                                        cpny.image = img;
                                        
                                        NSData *imageData = UIImagePNGRepresentation(img);
                                        image_key = [NSString stringWithFormat:@"img_%@",cpny.company_id];
                                        [ud setObject:imageData forKey:image_key];
                                        [ud synchronize];
                                      }
                                      else {
                                        // アラートを閉じる
                                        //						if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
                                        
                                        NSLog(@"FAILWHALE with error: %@", [err description] );
                                        alertView = [[UIAlertView alloc]
                                                     initWithTitle:[pData getDataForKey:@"DEFINE_MAP_IMGREADERRTITLE"]
                                                     message:[pData getDataForKey:@"DEFINE_MAP_IMAREADERRMSG"]
                                                     delegate:nil
                                                     cancelButtonTitle:nil
                                                     otherButtonTitles:[pData getDataForKey:@"DEFINE_MAP_ALERTOK"], nil ];
                                        [alertView show];
                                      }
                                    }
                                  }
                                }
	 ];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
	[bdView dismissView];
	return YES;
}
//str1がcmpを含む場合はYESを返す
-(BOOL)isInclude:(NSString*)str1 cmp:(NSString*)cmp
{
	NSRange result = [str1 rangeOfString:cmp];
	if (result.location == NSNotFound){
		return NO;
	}
	return  YES;
}

-(void)getSales:(NSMutableArray*)cpList
{
	if ([cpList count]== 0) {
		return;
	}
	
	//集計開始年・月を求める
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents * cmp = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:[NSDate date]];
	NSInteger year = cmp.year ;
	NSInteger month = cmp.month;
	NSInteger day = 1;
	
	if ( month == 12 ) {
		month = 1;
	}
	else {
		month++;
		year--;
	}

	int loopMax = [cpList count];
	int loopCnt = 0;
	NSString *where=@"";
	for ( Company *tempcp in cpList ) {
		where = [where stringByAppendingString:[NSString stringWithFormat:@"Opportunity.AccountId ='%@'",tempcp.company_id]];
		if ( loopCnt++ != loopMax - 1 ){
			where = [where stringByAppendingString:@" OR "];
		}
	}
	
	NSString *dateStr = [NSString stringWithFormat:@"%d-%02d-%02d",year,month,day];
	NSString *query = [NSString stringWithFormat:@"SELECT CreatedDate,TotalPrice,status__c ,Opportunity.CloseDate ,Opportunity.AccountId FROM OpportunityLineItem  WHERE Opportunity.CloseDate >= %@ AND (%@) ORDER BY Opportunity.CloseDate DESC",dateStr,where];
	NSLog(@"%@",query);
	SFRestRequest *req = [[SFRestAPI sharedInstance] requestForQuery:query];
	[[SFRestAPI sharedInstance] sendRESTRequest:req
									  failBlock:^(NSError *e) {
										  NSLog(@"FAILWHALE with error: %@", [e description] );
										  alertView = [[UIAlertView alloc]
													   initWithTitle:[pData getDataForKey:@"DEFINE_MAP_SALES_RCVERRTITLE"]
													   message:[pData getDataForKey:@"DEFINE_MAP_SALES_RCVERRMSG"]
													   delegate:nil
													   cancelButtonTitle:nil
													   otherButtonTitles:[pData getDataForKey:@"DEFINE_MAP_SALES_RCVERROK"], nil ];
										  [alertView show];
									  }
	 
								  completeBlock:^(id jsonResponse){
									  NSDictionary *dict = (NSDictionary *)jsonResponse;
									  NSLog(@"%@",dict);
									  NSArray *records = [dict objectForKey:@"records"];
									  for ( int i = 0; i< [records count]; i++ ){
										  NSDictionary *rec = [records objectAtIndex:i];
										  NSDictionary *opportunity = [rec objectForKey:@"Opportunity"];
										  NSString *cpId = [opportunity objectForKey:@"AccountId"];
										  NSNumber *sales = [rec objectForKey:@"TotalPrice"];
										  
										  for ( Company *tempCp in cpList){
											  if ([cpId isEqualToString:tempCp.company_id]){
												  if (![sales isEqual:[NSNull null]]){
													  tempCp.yearSales += [sales doubleValue];
													  break;
												  }
											  }
										  }
									  }
									  for ( Company *tempCp in cpList){
										  NSLog(@"%@:%f",tempCp.name,tempCp.yearSales);
									  }
									  [self getEmployee:cpList];
									  
								  }
	 ];
}

-(void)getEmployee:(NSMutableArray*)cpList
{
	if ([cpList count]== 0) {
		return;
	}
	int loopMax = [cpList count];
	int loopCnt = 0;
	NSString *where=@"";
	for ( Company *tempcp in cpList ) {
		where = [where stringByAppendingString:[NSString stringWithFormat:@"Id ='%@'",tempcp.company_id]];
		if ( loopCnt++ != loopMax - 1 ){
			where = [where stringByAppendingString:@" OR "];
		}
	}
	
	NSString *query = [NSString stringWithFormat:@"SELECT Id, AnnualRevenue,NumberOfEmployees,activity__c,oppcount__c FROM Account WHERE (%@) ",where];
	NSLog(@"%@",query);
	SFRestRequest *req = [[SFRestAPI sharedInstance] requestForQuery:query];
	[[SFRestAPI sharedInstance] sendRESTRequest:req
									  failBlock:^(NSError *e) {
										  NSLog(@"FAILWHALE with error: %@", [e description] );
										  alertView = [[UIAlertView alloc]
													   initWithTitle:[pData getDataForKey:@"DEFINE_MAP_EMPLY_RCVERRTITLE"]
													   message:[pData getDataForKey:@"DEFINE_MAP_EMPLY_RCVERRMSG"]
													   delegate:nil
													   cancelButtonTitle:nil
													   otherButtonTitles:[pData getDataForKey:@"DEFINE_MAP_EMPLY_RCVERROK"], nil ];
										  [alertView show];
									  }
	 
								  completeBlock:^(id jsonResponse){
									  NSDictionary *dict = (NSDictionary *)jsonResponse;
									  NSLog(@"%@",dict);
									  NSArray *records = [dict objectForKey:@"records"];
									  for ( int i = 0; i< [records count]; i++ ){
										  NSDictionary *rec = [records objectAtIndex:i];
										  NSString *cpId = [rec objectForKey:@"Id"];
										  NSNumber *emp = [rec objectForKey:@"NumberOfEmployees"];
										  NSNumber *act = [rec objectForKey:@"activity__c"];
										  NSNumber *opp = [rec objectForKey:@"oppcount__c"];
										  NSNumber *sales = [rec objectForKey:@"AnnualRevenue"];
										  for ( Company *tempCp in cpList){
											  if ([cpId isEqualToString:tempCp.company_id]){
												  if (![emp isEqual:[NSNull null]]){
													  tempCp.employee =[emp intValue];
												  }
												  if (![act isEqual:[NSNull null]]){
													  tempCp.visitCount =[act intValue];
												  }
												  if (![opp isEqual:[NSNull null]]){
													  tempCp.opportunityCount =[opp intValue];
												  }
												  if (![sales isEqual:[NSNull null]]){
													  tempCp.yearSales =[sales doubleValue];
												  }
											  }
										  }
									  }
									  for ( Company *tempCp in cpList){
										  NSLog(@"%@:従業員数:%d 売上:%f 訪問数:%d 商談数%d",tempCp.name,tempCp.employee ,
												tempCp.yearSales ,tempCp.visitCount, tempCp.opportunityCount);
									  }
									  //ピン追加
									  [self addCompanyPinByArray:selectedList];
									  
									  //マップサイズ調整
									  [self mapZoom:searchPos points:aryForZoom];
								  }
	 ];

	
}
-(void)modePushed
{
	if ( bdView.isCovered == true){
		return;
	}
	
	//PopOverを消す
	if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
	
	NSMutableArray *modeList = [[NSMutableArray alloc]initWithObjects:[pData getDataForKey:@"DEFINE_MAP_MODE_NORMAL"],
								[pData getDataForKey:@"DEFINE_MAP_MODE_VISIT"],
								[pData getDataForKey:@"DEFINE_MAP_MODE_OPP"], nil];
	
	
	//リストをPopoverで表示
	ModeSelectPopUpViewController *modeSel = [[ModeSelectPopUpViewController alloc]init];
	[modeSel setItemList:modeList];
	modeSel.delegate = self;
	pop = [[UIPopoverController alloc]initWithContentViewController:modeSel];
	pop.delegate = self;
	pop.popoverContentSize = modeSel.view.frame.size;
	if ( isLstBtnDisp == YES ) {
		[pop presentPopoverFromRect:CGRectMake(705, 0, 0, 0) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
	else {
		[pop presentPopoverFromRect:CGRectMake(730, 0, 0, 0) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
}
-(void)didSelectMode:(int)index
{
	dispType = index;
	[pop dismissPopoverAnimated:NO];
	
	//絞り込みパネル再構築
	if ( dispType == ENUM_DISPNORMAL ){
		[self buildSelectPanel:YES];
	}
	else {
		[self buildSelectPanel:NO];
	}
	
	//画面タイトル変更
	[self setNavbartitle];
	
	//ピンを前削除
	[map clear];
	
	//検索地点ピンを再設置
	if ( lastSerachLocation != nil ){
		[map addMarkerWithOptions:lastSerachLocation];
	}
	
	//フィルタリング処理
	selectedList = [self applyFiller:selectMode src:sortedList];
	
	//ピン再設置
	[self addCompanyPinByArray:selectedList];
	if (( selectMode & BUILDING)&&( dispType == ENUM_DISPNORMAL)){
		[self addBulindingPinByArray:buildingList];
	}
}
-(void)setNavbartitle
{
	NSString *title;
	if ( dispType == ENUM_DISPNORMAL){
		title = [pData getDataForKey:@"DEFINE_MAP_MODE_NORMAL"];
		label.text = self.title;
	}
	else if ( dispType == ENUM_DISPVISIT){
		title = [pData getDataForKey:@"DEFINE_MAP_MODE_VISIT"];
		label.text = [NSString stringWithFormat:@"%@ - %@",title,self.title];
	}
	else if ( dispType == ENUM_DISPOPP){
		title = [pData getDataForKey:@"DEFINE_MAP_MODE_OPP"];
		label.text = [NSString stringWithFormat:@"%@ - %@",title,self.title];
	}
	[label sizeToFit];

}

-(double)getRadius:(Company*)tempCp
{
	double radius;
	double empVal=(double)0;
	double salesVal=(double)0;
	double tempSalesVal;
	double tempRad;
	
	if ( tempCp.employee <= 0 ) empVal = (double)0;
	else if ( tempCp.employee < 10 ) empVal = (double)1;
	else if ( tempCp.employee < 99 ) empVal = (double)2;
	else if ( tempCp.employee < 999 ) empVal = (double)3;
	else if ( tempCp.employee >= 1000 ) empVal = (double)4;

	tempSalesVal = tempCp.yearSales / (double)10000;
	if ( tempSalesVal <= (double)0) salesVal = (double)0;
	else if ( tempSalesVal <= (double)99) salesVal = (double)1;
	else if ( tempSalesVal <= (double)999) salesVal = (double)2;
	else if ( tempSalesVal <= (double)9999) salesVal = (double)3;
	else if ( tempSalesVal >= (double)999) salesVal = (double)4;
	
	//0.5-3.7
	tempRad = (( empVal * salesVal)/(double)5.0) + (double)0.5;
	
	radius = (double)50.0 * tempRad;
	
	if ( radius > MaxDimeter ) radius = MaxDimeter;
	if ( radius < MinDimeter ) radius = MinDimeter;
	
	return  radius;
	
}

@end
