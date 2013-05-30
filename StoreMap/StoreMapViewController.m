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


#import "StoreMapViewController.h"
#import "CompanyProfiles.h"
#import "PublicDatas.h"
#import "MetricsViewController.h"
#import "OrderViewController.h"
#import "ChatterViewController.h"
#import "Company.h"
#import "UtilManager.h"

static const CGFloat CalloutYOffset = 25.0f;
static const float InitialZoom = 15.0f;				//ズーム値

@implementation StoreMapViewController


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
	  
	if ( cp.image == nil ){
	}
	[_companyProfile setInfo:cp];
	
  um = [UtilManager sharedInstance];
  pData = [PublicDatas instance];
  
	//現在地取得準備
	locationManager = [[CLLocationManager alloc]init];
	if ([CLLocationManager locationServicesEnabled]){
		
		//位置情報取得可能なら測位開始
		[locationManager setDelegate:self];
		[locationManager startUpdatingLocation];
	}
	
	
	//ナビゲーションバー　設定
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
			[self.navigationController.navigationBar setBackgroundImage:img
                                                    forBarMetrics:UIBarMetricsDefault];
		}
	}
	
	//背景設定
	iData =[um backType];
	if ( [((NSString*)iData) isEqualToString:@"gray"] ) {
		self.view.backgroundColor = [UIColor grayColor];
	}
	else if ( [((NSString*)iData) isEqualToString:@"black"] ) {
		self.view.backgroundColor = [UIColor blackColor];
	}
	else {
		iData =[um backImage];
		if ( iData ) {
			UIImage *img = [UIImage imageWithData:iData];
			self.view.backgroundColor = [UIColor colorWithPatternImage:img];
		}
	}
	
	iData =[um currentLoacationBtnImage];
	if ( iData ) {
		currentLocationImg = [UIImage imageWithData:iData];
	}
  
	iData =[um panelBackImage];
	if ( iData ) {
		panelBackImg = [UIImage imageWithData:iData];
	}
	
	iData =[um carBtnImage];
	if ( iData ) {
		carImg = [UIImage imageWithData:iData];
	}
	
	iData =[um walkBtnImage];
	if ( iData ) {
		walkImg = [UIImage imageWithData:iData];
	}
  
	//ナビバータイトル
	pData = [PublicDatas instance];
	self.title = [pData getDataForKey:@"DEFINE_STOREMAP_TITLE"];
	titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
	titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.textColor = [UIColor whiteColor]; // change this color
	self.navigationItem.titleView = titleLabel;
	titleLabel.text =self.title;
	[titleLabel sizeToFit];
  

	//ツールバー
	UIToolbar *toolbar = [[MyToolBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50, 40.0f)];
	toolbar.backgroundColor = [UIColor clearColor];
	toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	UIBarButtonItem *toolbarBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];

	//画面（機能）切り替えボタン
	btnBuilder = [[BuildNavButtons alloc]initWithCompany:cp];
	btnBuilder.delegate = self;

//	metricsBtn = [btnBuilder buildMetricsBtn];

	
//	mapBtn = [btnBuilder buildMapBtn];
//	ordersBtn = [btnBuilder buildOrdersBtn];
//	chatterBtn = [btnBuilder buildChatterBtn];
	
//	UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//	toolbar.items = [NSArray arrayWithObjects:space,[[UIBarButtonItem alloc]initWithCustomView:metricsBtn],
//                   [[UIBarButtonItem alloc]initWithCustomView:mapBtn],
//                   [[UIBarButtonItem alloc]initWithCustomView:ordersBtn],
//                   [[UIBarButtonItem alloc]initWithCustomView:chatterBtn],nil];

	
	metricsBtn = [btnBuilder buildMenuBtn];
	toolbar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc]initWithCustomView:metricsBtn],nil];
	
	//ツールバーをナビバーに設置
	self.navigationItem.rightBarButtonItem = toolbarBarButtonItem;
	
	//ナビゲーションバーに「戻る」ボタン配置
	self.navigationItem.leftBarButtonItem = [btnBuilder buildBackBtn];
	
	//切り替えパネル
	UIView *selectPanel = [[UIView alloc]initWithFrame:CGRectMake(695, 490, 280, 50)];
	selectPanel.layer.cornerRadius = 6;
	[selectPanel setBackgroundColor:[UIColor colorWithPatternImage:panelBackImg]];
	
	//徒歩
	byWalkBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 5, 40, 40)];
	[byWalkBtn setBackgroundImage:walkImg forState:UIControlStateNormal];
	[byWalkBtn addTarget:self action:@selector(bywalk) forControlEvents:UIControlEventTouchUpInside];
	[selectPanel addSubview:byWalkBtn];
	
	// 徒歩ボタンテキスト
	byWalkTextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	byWalkTextBtn.frame = CGRectMake(55,0,100,50);
	byWalkTextBtn.titleLabel.font            = [UIFont systemFontOfSize: 18];
	byWalkTextBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
	[byWalkTextBtn setTitle:[pData getDataForKey:@"DEFINE_STOREMAP_WALK"] forState:UIControlStateNormal];
	[byWalkTextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[byWalkTextBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[byWalkTextBtn addTarget:self action:@selector(bywalk) forControlEvents:UIControlEventTouchUpInside];
	[selectPanel addSubview:byWalkTextBtn];
	
	//車
	byCarBtn = [[UIButton alloc]initWithFrame:CGRectMake(145, 5, 40, 40)];
	[byCarBtn setBackgroundImage:carImg forState:UIControlStateNormal];
	[byCarBtn addTarget:self action:@selector(bycar) forControlEvents:UIControlEventTouchUpInside];
	[selectPanel addSubview:byCarBtn];
	
	// 車ボタンテキスト
	byCarTextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	byCarTextBtn.frame = CGRectMake(190,0,100,50);
	byCarTextBtn.titleLabel.font            = [UIFont systemFontOfSize: 18];
	byCarTextBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
	[byCarTextBtn setTitle:[pData getDataForKey:@"DEFINE_STOREMAP_CAR"]  forState:UIControlStateNormal];
	[byCarTextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[byCarTextBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[byCarTextBtn addTarget:self action:@selector(bycar) forControlEvents:UIControlEventTouchUpInside];
	[selectPanel addSubview:byCarTextBtn];
	byWalkTextBtn.opaque = YES;
	byWalkBtn.opaque = YES;
	byCarTextBtn.opaque = YES;
	byCarBtn.opaque = YES;
	
	selectPanel.opaque = YES;
	selectPanel.alpha = 1.0;
	
	//現在地ボタン
	UIButton *currentPosBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[currentPosBtn setBackgroundImage:currentLocationImg forState:UIControlStateNormal];
	[currentPosBtn addTarget:self action:@selector(currentPos) forControlEvents:UIControlEventTouchUpInside];
	currentPosBtn.frame = CGRectMake(10,490, 50, 50);
	
  // 角丸
  CGSize size = CGSizeMake(5.0, 5.0);
  [um makeViewRound:currentPosBtn corners:UIRectCornerAllCorners size:&size];

	// ローディングアラートを生成
	alertView = [[UIAlertView alloc] initWithTitle:[pData getDataForKey:@"DEFINE_STOREMAP_LOADING_TITLE"]
										message:nil
                                        delegate:nil cancelButtonTitle:nil otherButtonTitles:NULL];
	progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
	progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	[alertView addSubview:progress];
	[progress startAnimating];
	
	// GPS利用チェック
	AppDelegate* appli = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	float _zoom =0.0;
	if([appli chkGPS]) _zoom = InitialZoom;
  
	
	//地図初期位置
	GMSCameraPosition *camera= [GMSCameraPosition cameraWithLatitude:cp.position.latitude
                                                         longitude:cp.position.longitude
                                                              zoom:_zoom];
	//地図
	CGRect rect = self.mapBase.bounds;
	rect.size.height += 50;
//	map =  [GMSMapView mapWithFrame:self.mapBase.bounds camera:camera];
	map =  [GMSMapView mapWithFrame:rect camera:camera];
	map.myLocationEnabled = YES;
	map.delegate = self;
	[self.mapBase addSubview:map];
  
	[self.mapBase addSubview:selectPanel];
	[self.mapBase bringSubviewToFront:selectPanel];
	[self.mapBase addSubview:currentPosBtn];
	[self.mapBase bringSubviewToFront:currentPosBtn];
  
	//徒歩選択
	moveMethod = ENUM_MOVEBYWALK;
	byWalkBtn.alpha = 1.0;
	byWalkTextBtn.alpha = 1.0;
	byCarBtn.alpha = 0.3;
	byCarTextBtn.alpha = 0.3;
	
	//ピン追加
	[self addCompanyPin:cp];
  
  // 角丸
  [um makeViewRound:_companyProfile corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:self.mapBase corners:UIRectCornerAllCorners size:&size];
}

//画面遷移
-(void)didPushChangeFunction:(UIViewController *)func
{
	NSString *tgt = NSStringFromClass([func class]);
	NSString *myClass = NSStringFromClass([self class]);
	if ( ![tgt isEqualToString:myClass]){
		[self.navigationController pushViewController:func animated:NO];
	}
}

//ナビゲーションバーの「戻る」ボタン処理
-(void)didPushback:(int)pos
{
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:pos] animated:YES];
}
-(void)didPushbackStep
{
}
-(void)didPushHomeStep
{
}


//会社情報を元にピン追加
-(void)addCompanyPin:(Company*)cpy
{
	GMSCameraPosition *pos = [GMSCameraPosition cameraWithTarget:cpy.position zoom:InitialZoom];
	NSString *title = cpy.name;
	NSNumber *type = [[NSNumber alloc]initWithInt:ENUM_PINCOMPANY];
	NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:	pos,@"position",
                       title,@"title",
                       type,@"type",
                       cpy,@"company",
                       nil];
	
	[self addMarkersToMap:dic];
}

//マーカーピン追加
- (void)addMarkersToMap:(NSDictionary*)dic
{
  UIImage *pinImage;
	Company *cpy;
	
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
			break;
			
		case ENUM_PINCOMPANY:
			cpy = [dic objectForKey:@"company"];
			if ( cpy.salesStatus == SALES_UP) {
				pinImage = [UIImage imageNamed:@"salesup.png"];
			}
			else if ( cpy.salesStatus == SALES_FLAT) {
				pinImage = [UIImage imageNamed:@"salesflat.png"];
			}
			else {
				pinImage = [UIImage imageNamed:@"salesdown.png"];
			}
			op.icon = pinImage;
			break;
			
		default:
			break;
	}
	[map addMarkerWithOptions:op];
	
}

//コールアウト作成
- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(id<GMSMarker>)marker
{
	self.calloutView.hidden = YES;
	
	NSDictionary *userDat = marker.userData;
	NSNumber *type = [userDat objectForKey:@"type"];
	
	//SMCallOutTest
	self.calloutView = [[SMCalloutView alloc] init];
	
	//ピン種別判定
	if ( ENUM_PINCOMPANY != [type intValue]){
		
		//現在地／検索地点の場合 タイトルのみ表示
		[self.calloutView setTitle:[userDat objectForKey:@"title"]];
	}
	else {
		
		//表示データ取得
		Company *cp_ = [userDat objectForKey:@"company"];
		
/*
		//コールアウト右側のボタン
		UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[button addTarget:self action:@selector(calloutAccessoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		self.calloutView.rightAccessoryView = button;
*/		
		self.emptyCalloutView = [[UIView alloc] initWithFrame:CGRectZero];
		
		//画像
		
		UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,60,60)];
		UIImage *leftImage;
		if (cp_.image) {
			leftImage = [self resizeImage:cp_.image Rect:imgV.frame];
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
		//		CGSize nameSize = [cp_.name sizeWithFont:font constrainedToSize:CGSizeMake(300,40) lineBreakMode:NSLineBreakByClipping];
		[nameLbl setLineBreakMode:UILineBreakModeWordWrap];
		nameLbl.numberOfLines = 0;
		CGSize nameSize = [cp_.name sizeWithFont:font constrainedToSize:CGSizeMake(300,40) lineBreakMode:NSLineBreakByWordWrapping];
		
		
		UIFont *font2 = [UIFont systemFontOfSize:12];
		//		CGSize adSize = [[cp_.Address1 stringByAppendingString:[cp Address2]] sizeWithFont:font2 constrainedToSize:CGSizeMake(300,40) lineBreakMode:NSLineBreakByClipping];
//		CGSize adSize = [[cp_.Address1 stringByAppendingString:[cp_ Address2]] sizeWithFont:font2 constrainedToSize:CGSizeMake(300,40) lineBreakMode:NSLineBreakByWordWrapping];
		adLbl.numberOfLines = 0;
		[adLbl setLineBreakMode:UILineBreakModeWordWrap];
		
		//ラベルの大きさを文字列の大きさに合わせる
		CGRect nameRect = nameLbl.frame;
		nameRect.size =  nameSize;
/*
		CGRect adRect = adLbl.frame;
		adRect.size= adSize;
		
		//名前ラベルと住所ラベルの長さを合わせる
		if ( adRect.size.width < nameRect.size.width ){
			adRect.size.width = nameRect.size.width;
		}
		else {
			nameRect.size.width = adRect.size.width;
		}
*/
		//名前ラベル、住所ラベルの位置調整
		nameRect.origin.y = 0;
//		adRect.origin.y = ( nameRect.origin.y + nameRect.size.height)+5;
		nameRect.origin.x = ( imgV.frame.origin.x + imgV.frame.size.width)+8;
//		adRect.origin.x = nameRect.origin.x;
		
		CGRect cRect;
		cRect.origin.x = 0;
		cRect.origin.y = 0;
		cRect.size.width = (nameRect.origin.x + nameRect.size.width)+8;
		if ( nameSize.height > imgV.frame.size.height ) {
			cRect.size.height = nameSize.height;
			
			CGPoint center = imgV.center;
			center.y = nameSize.height/2;
			imgV.center = center;
		}
		else {
			cRect.size.height = (imgV.frame.origin.y + imgV.frame.size.height);
		}
		cView.frame = cRect;
		
		//ラベルにテキストと大きさを設定
		nameLbl.text = cp_.name;
		nameLbl.font = font;
		nameLbl.backgroundColor = [UIColor clearColor];
		nameLbl.textColor = [UIColor whiteColor];
		[nameLbl setFrame:nameRect];
		
		adLbl.text = [cp_.Address1 stringByAppendingString:cp_.Address2];
		adLbl.font = font2;
		adLbl.backgroundColor = [UIColor clearColor];
		adLbl.textColor = [UIColor whiteColor];
//		[adLbl setFrame:adRect];
		
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
  //	[self saveCenterPoint];
	
  return self.emptyCalloutView;
}


// ローディングアラートの表示
-(void)alertShow
{
	[NSTimer scheduledTimerWithTimeInterval:10.0f
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

-(void)bywalk
{
	moveMethod = ENUM_MOVEBYWALK;
	byWalkBtn.alpha = 1.0;
	byWalkTextBtn.alpha = 1.0;
	byCarBtn.alpha = 0.3;
	byCarTextBtn.alpha = 0.3;
	
	//マップクリア
	[map clear];
  
	//ピン追加
	[self addCompanyPin:cp];
  
	//ルート検索
	[self alertShow];
	[self getRouteP2P:myPos destination:cp.position];
  
}

-(void)bycar
{
	moveMethod = ENUM_MOVEBYCAR;
	byCarBtn.alpha = 1.0;
	byCarTextBtn.alpha = 1.0;
	byWalkBtn.alpha = 0.3;
	byWalkTextBtn.alpha = 0.3;
	
	//マップクリア
	[map clear];
  
	//ピン追加
	[self addCompanyPin:cp];
  
	//ルート検索
	[self alertShow];
	[self getRouteP2P:myPos destination:cp.position];
  
}

//現在地ボタン押下（ルート検索）
-(void)currentPos
{
	// 位置情報利用チェック
	AppDelegate* appli = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	
	if(![appli chkGPS]) return;
	
	NSArray *aOsVersions = [[[UIDevice currentDevice]systemVersion] componentsSeparatedByString:@"."];
	NSInteger iOsVersionMajor = [[aOsVersions objectAtIndex:0] intValue];
	
	//ピン消去
	[map clear];
	
	// ios 6以上
	if(iOsVersionMajor>=6){
		// ローディング
		[self alertShow];
		
		GMSCameraPosition *pos = [GMSCameraPosition cameraWithLatitude:myPos.latitude longitude:myPos.longitude zoom:InitialZoom];
		[map setCamera:pos];
		
		//ピン追加
		[self addCompanyPin:cp];
		
		//ルート検索
		[self getRouteP2P:myPos destination:cp.position];
	}
	// ios 5
	else{
		// 現在地情報受信開始
		[locationManager startUpdatingLocation];
    
		//ルート検索
		[self getRouteP2P:myPos destination:cp.position];
		
	}
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
  
	//この画面では、ピンは一つだけなので、アノテーションを閉じない方が適当か？
	//    self.calloutView.hidden = YES;
}



- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}
//UIImage:imgがRectより大きい場合リサイズする
-(id)resizeImage:(UIImage*)img Rect:(CGRect)Rect
{
	if (( img.size.height > Rect.size.height) || ( img.size.width > Rect.size.width)) {
		NSLog(@"%f : %f",img.size.width,img.size.height);
		float asp = (float)img.size.width / (float)img.size.height;
		CGRect r = CGRectMake(0,0,0,0);
		if ( img.size.width > img.size.height) {
			r.size.width = Rect.size.width;
			r.size.height = r.size.width / asp;
		}
		else {
			r.size.height = Rect.size.height;
			r.size.width = r.size.height * asp;
		}
		
		UIGraphicsBeginImageContext(r.size);
		[img drawInRect:CGRectMake(0,0,r.size.width,r.size.height)];
		img = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
	return img;
}
- (void)mapView:(GMSMapView *)pMapView didChangeCameraPosition:(GMSCameraPosition *)position {
	
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

//２点間のルートを求める
-(void)getRouteP2P:(CLLocationCoordinate2D)org destination:(CLLocationCoordinate2D)dst
{
	//ルート検索
	NSString *origin = [NSString stringWithFormat:@"origin=%f,%f",org.latitude, org.longitude];
	NSString *destination = [NSString stringWithFormat:@"&destination=%f,%f",dst.latitude, dst.longitude];
	NSString *sens = @"&sensor=false";
	
	NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
	
	//交通手段
	NSString *moveMode;
	switch ((int)moveMethod) {
		case ENUM_MOVEBYCAR:
			moveMode = @"&mode=driving";
			break;
		case ENUM_MOVEBYWALK:
			moveMode = @"&mode=walking";
			break;
		case ENUM_MOVEBYTRAIN:
			moveMode = [NSString stringWithFormat:@"&departure_time=%d&mode=transit", (int)timestamp];
			break;
			
		default:
			moveMode = @"&mode=driving";
			break;
	}
	
	NSString *param = [[[origin stringByAppendingString:destination]stringByAppendingString:sens]stringByAppendingString:moveMode];
	NSString *reqStr = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?%@",param];
	reqStr = [reqStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSLog( @"%@",reqStr);
	
	//リクエスト実行
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:reqStr]];
	(void)[[NSURLConnection alloc]initWithRequest:request delegate:self];
}


//マップの表示範囲調整
-(void)mapZoom:(NSMutableArray*)array
{
	double	latmax,latmin,
	lngmax, lngmin;
	
	latmax = 0;
	lngmax = 0;
	latmin = 999;
	lngmin = 999;
	
	
	//検索結果リストから緯度経度の最大値を求める
	for ( int i = 0; i < [array count]; i++ ){
		Company *cpy = [array objectAtIndex:i];
		
		if ( cpy.position.latitude > latmax ) {
			latmax = cpy.position.latitude;
		}
		if ( cpy.position.latitude < latmin ) {
			latmin = cpy.position.latitude;
		}
		
		if ( cpy.position.longitude > lngmax ) {
			lngmax = cpy.position.longitude;
		}
		if ( cpy.position.longitude < lngmin ) {
			lngmin = cpy.position.longitude;
		}
	}
	CLLocationCoordinate2D center;
	center.longitude = lngmin + (( lngmax - lngmin ) / 2 );
	center.latitude = latmin + (( latmax - latmin ) / 2 );
	
	//中心地から左上、右下までの差分を求める
	double	diffLeft,diffRight,
	diffUp,diffDown;
	
	diffLeft = fabs(center.longitude - lngmin);
	diffRight = fabs(lngmax - center.longitude);
	diffUp = fabs(latmax - center.latitude);
	diffDown = fabs(center.latitude - latmin);
	
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
	float trim = 0.0015f;
	CLLocationCoordinate2D southWest,northEast;
	southWest.latitude = center.latitude + diffUp + trim;
	southWest.longitude = center.longitude - diffLeft - trim;
	northEast.latitude = center.latitude  - diffDown - trim;
	northEast.longitude = center.longitude + diffRight + trim;
	
	float mapViewWidth = self.mapBase.frame.size.width;
	float mapViewHeight = self.mapBase.frame.size.height-180;
	
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
	
	//	GMSCameraPosition *camera = [GMSCameraPosition
	//								 cameraWithLatitude: centreLocation.latitude
	//								 longitude: centreLocation.longitude
	//								 zoom: zoomLevel];
	
	
	GMSCameraPosition *camera = [GMSCameraPosition
                               cameraWithLatitude: center.latitude
                               longitude: center.longitude
                               zoom: zoomLevel];
	
	[map setCamera:camera];
	
}


//受信開始
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	//受信データクリア
	rcvData = [[NSMutableData alloc]init];
}

//データ受信
- (void)connection:(NSURLConnection *) connection didReceiveData:(NSData *)data {
	[rcvData appendData:data];
}


//受信終了　JSONデータからPolyLineを作成
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	//	NSString *rcvString = [[NSString alloc]initWithBytes:rcvData.bytes length:rcvData.length encoding:NSUTF8StringEncoding];
	NSError *error=nil;
	
	NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:rcvData options:NSJSONReadingAllowFragments error:&error];
	NSLog(@"%@",jsonObject);
	
	NSString *status = [jsonObject valueForKey:@"status"];
	
	if ([status isEqualToString:@"ZERO_RESULTS"])  {
		
		// アラートを閉じる
		if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
		
		NSLog(@"ERROR:%@",status);
		routeAlertView = [[UIAlertView alloc]
                      initWithTitle:[pData getDataForKey:@"DEFINE_STOREMAP_TITLE_ROUT_ERROR"]
                      message:[pData getDataForKey:@"DEFINE_STOREMAP_TITLE_ROUT_MESSAGE_NOTFOUND"]
                      delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:[pData getDataForKey:@"DEFINE_STOREMAP_TITLE_ROUT_OK_ERROR"], nil ];
		[routeAlertView show];
		
		return;
	}
	else
		if ( ![status isEqualToString:@"OK"])  {
			NSLog(@"ERROR:%@",status);
			
			// アラートを閉じる
			if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
			
			routeAlertView = [[UIAlertView alloc]
                        initWithTitle:[pData getDataForKey:@"DEFINE_STOREMAP_TITLE_ROUT_ERROR"]
                        message:[NSString stringWithFormat:[pData getDataForKey:@"DEFINE_STOREMAP_TITLE_ROUT_MESSAGE_FAIL"],status]
                        delegate:nil
                        cancelButtonTitle:nil
                        otherButtonTitles:[pData getDataForKey:@"DEFINE_STOREMAP_TITLE_ROUT_OK_ERROR"], nil ];
			[routeAlertView show];
			
			return;
		}
	NSDictionary *routes = [jsonObject valueForKeyPath:@"routes"];
  //	NSArray *legs = [routes valueForKeyPath:@"legs"];
	NSArray *overView = [routes valueForKeyPath:@"overview_polyline"];
	NSDictionary *dic = [overView objectAtIndex:0];
	NSString *point = [dic objectForKey:@"points"];
	NSLog(@"%@",point);
	
	//PolyLine表示
	options = [GMSPolylineOptions options];
	path = [GMSMutablePath path];
	[self polylineWithEncodedString:point];
	options.path = path;
	options.color = [UIColor colorWithRed:0.5f green:0.0f blue:0.5f alpha:0.5f];
	options.width = 5.0f;
	options.geodesic = YES;
	[map addPolylineWithOptions:options];
	
	//ルート検索終了
	
	//マップのZOOMを調整
	Company *tmpcp = [[Company alloc]init];
	tmpcp.position = myPos;
	NSMutableArray *tmpAry = [[NSMutableArray alloc]initWithObjects:cp,tmpcp,nil];
	[self mapZoom:tmpAry];
	
	// アラートを閉じる
	if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
	
}

//Google Direction APIから取得したPoint情報をエンコードし、PolyLine表示する
-(void)polylineWithEncodedString:(NSString *)encodedString {
	
  const char *bytes = [encodedString UTF8String];
  NSUInteger length = [encodedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
  NSUInteger idx = 0;
	
  float latitude = 0;
  float longitude = 0;
  while (idx < length) {
    char byte = 0;
    int res = 0;
    char shift = 0;
		
    do {
      byte = bytes[idx++] - 63;
      res |= (byte & 0x1F) << shift;
      shift += 5;
    } while (byte >= 0x20);
		
    float deltaLat = ((res & 1) ? ~(res >> 1) : (res >> 1));
    latitude += deltaLat;
		
    shift = 0;
    res = 0;
		
    do {
      byte = bytes[idx++] - 0x3F;
      res |= (byte & 0x1F) << shift;
      shift += 5;
    } while (byte >= 0x20);
		
    float deltaLon = ((res & 1) ? ~(res >> 1) : (res >> 1));
    longitude += deltaLon;
		
    float finalLat = latitude * 1E-5;
    float finalLon = longitude * 1E-5;
		
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(finalLat, finalLon);
		[path addCoordinate:coord];
  }
}


//位置取得時処理
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	CLLocation *location;
	
	//初回の位置取得時のみ地図を移動（自身の位置追跡しない）
	location = [locations objectAtIndex:0];
  /*
   if ( moveCurrentPos == YES) {
   
   
   GMSCameraPosition *pos = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude zoom:InitialZoom];
   [map setCamera:pos];
   moveCurrentPos = NO;
   }
   */
	myPos = location.coordinate;
	[locationManager startUpdatingLocation];
}

//位置取得時処理 ios 5
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
	NSLog(@"location up");
	
	// 位置情報を取り出す
	myPos = newLocation.coordinate;
  /*
   if ( moveCurrentPos == YES) {
   // ローディング
   [self alertShow];
   moveCurrentPos = NO;
   GMSCameraPosition *pos = [GMSCameraPosition cameraWithLatitude:myPos.latitude longitude:myPos.longitude zoom:InitialZoom];
   [map setCamera:pos];
   }
   */
}


//機能（画面）選択時のデリゲート
//-(void)didSelectFunction:(int)tab
/*
//機能（画面）選択
-(void)didSelectFunction:(id)sender
{
	
	UIButton *wrkBtn = (UIButton*)sender;
	int tab = wrkBtn.tag;
	
	MetricsViewController *metVC;
	OrderViewController *orderVC;
	StoreMapViewController *mapVC;
	ChatterViewController *chatter;
	switch (tab) {
		case 0:
			metVC = [[MetricsViewController alloc]initWithNibName:@"Metrics" bundle:[NSBundle mainBundle] company:cp ];
			[self.navigationController pushViewController:metVC animated:NO];
			break;
			
		case 1:
			mapVC = [[StoreMapViewController alloc]initWithNibName:@"StoreMapViewController" bundle:[NSBundle mainBundle] company:cp ];
			[self.navigationController pushViewController:mapVC animated:NO];
			break;
			
		case 2:
			orderVC = [[OrderViewController alloc]initWithNibName:@"Order" bundle:[NSBundle mainBundle] company:cp ];
			[self.navigationController pushViewController:orderVC animated:NO];
			break;
			
		case 3:
			//Chatter表示
			chatter = [[ChatterViewController alloc]init];
			[chatter setInitialId:cp.company_id];
			[chatter setInitialCompnay:cp];
			[chatter setChatterType:2];				//取引先のチャター
			
			//ナビゲーションバー　設定
			[self.navigationController.navigationBar setHidden:NO];
			
			//画面遷移
			[self.navigationController pushViewController:chatter animated:YES];
			break;
			
		default:
			break;
	}
}
*/

-(void)viewDidDisappear:(BOOL)animated
{
	[map stopRendering];
}
- (void)viewDidUnload {

  [self setCalloutView:nil];
  [self setEmptyCalloutView:nil];
  [self setCompanyProfile:nil];
	[self setMapBase:nil];
	[super viewDidUnload];
}
@end
