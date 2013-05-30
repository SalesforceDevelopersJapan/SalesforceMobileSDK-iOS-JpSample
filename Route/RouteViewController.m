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

#import "RouteViewController.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "JSONKit.h"
#import "MetricsViewController.h"
#import "MyToolBar.h"

static const CGFloat CalloutYOffset = 25.0f;
static const float InitialZoom = 15.0f;				//ズーム値
static const double SearchAreaLng = 0.0110575296875*2;
static const double SearchAreaLat = 0.0089831916466*2;

//画像読み込みの閾値(単位」Byte）
static const int	MaxLoadingSize = ( 200 * 1024 );

//取引先ロゴ取得を行う=YES  行わない=NO
static const BOOL LogoLoad = YES;


@implementation RouteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.navigationController.navigationBar setHidden:NO];
    
    //バックグラウンド処理制御
    isImgBackJob = YES;
	
    //by**のボタンを有効に
    byJobFlg = YES;
    
	//選択ルート初期化
	selectedRoute = [NSMutableArray array];
	
	//現在地に移動
	moveCurrentPos = YES;
	
	//選択モード(全部表示）
	selectMode =  (SALES_UP) | (SALES_FLAT) | (SALES_DOWN);
	
	//現在地取得準備
	locationManager = [[CLLocationManager alloc]init];
	if ([CLLocationManager locationServicesEnabled]){
		
		//位置情報取得可能なら測位開始
		[locationManager setDelegate:self];
		[locationManager startUpdatingLocation];
	}
	
	um = [UtilManager sharedInstance];
	pData = [PublicDatas instance];

	self.title = [pData getDataForKey:@"DEFINE_ROUTE_TITLE"];
	
	//ナビバー設定
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
	
	//ナビバータイトル色
	titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
	titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.textColor = [UIColor whiteColor]; // change this color
	self.navigationItem.titleView = titleLabel;
	titleLabel.text =self.title;
	[titleLabel sizeToFit];
	
	//地図初期位置
	GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:0
															longitude:0
																 zoom:InitialZoom];
	//地図
	CGRect r = self.mapView.frame;
	r.origin.y = 0;
	map =  [GMSMapView mapWithFrame:r camera:camera];
	map.myLocationEnabled = YES;
	map.delegate = self;
	[self.mapView addSubview:map];
	
	//画像読み込み
	um = [UtilManager sharedInstance];
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

	iData =[um carBtnImage];
	if ( iData ) {
		carImg = [UIImage imageWithData:iData];
	}
	
	iData =[um walkBtnImage];
	if ( iData ) {
		walkImg = [UIImage imageWithData:iData];
	}
	
	//現在地ボタン
	UIButton *currentPosBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[currentPosBtn setBackgroundImage:currentLocationImg forState:UIControlStateNormal];
	[currentPosBtn addTarget:self action:@selector(currentPos) forControlEvents:UIControlEventTouchUpInside];
	currentPosBtn.frame = CGRectMake(10,665, 50, 50);
  // 角丸
  CGSize size = CGSizeMake(5.0, 5.0);
  [um makeViewRound:currentPosBtn corners:UIRectCornerAllCorners size:&size];
	[self.mapView addSubview:currentPosBtn];
	
	[self setNaviRightButton];
	
	//ナビゲーションバーに「戻る」ボタン配置
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] designedBackBarButtonItemWithTitle:@"" type:0 target:self action:@selector(back)];
	self.navigationItem.leftBarButtonItem = backButton;
	
	//切り替えパネル
	UIView *selectPanel = [[UIView alloc]initWithFrame:CGRectMake(730, 665, 280, 50)];
	selectPanel.layer.cornerRadius = 6;
	[selectPanel setBackgroundColor:[UIColor colorWithPatternImage:panelBackImg]];
	
	//徒歩
	byWalkBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 5, 40, 40)];
	[byWalkBtn setBackgroundImage:walkImg forState:UIControlStateNormal];
	[byWalkBtn addTarget:self action:@selector(byWalk) forControlEvents:UIControlEventTouchUpInside];
	[selectPanel addSubview:byWalkBtn];
	
	// 徒歩ボタンテキスト
	byWalkTextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	byWalkTextBtn.frame = CGRectMake(55,0,100,50);
	byWalkTextBtn.titleLabel.font            = [UIFont systemFontOfSize: 18];
	byWalkTextBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
	[byWalkTextBtn setTitle:[pData getDataForKey:@"DEFINE_ROUTE_WALKBTNTITLE"] forState:UIControlStateNormal];
	[byWalkTextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[byWalkTextBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[byWalkTextBtn addTarget:self action:@selector(byWalk) forControlEvents:UIControlEventTouchUpInside];
	[selectPanel addSubview:byWalkTextBtn];
	
	//車
	byCarBtn = [[UIButton alloc]initWithFrame:CGRectMake(145, 5, 40, 40)];
	[byCarBtn setBackgroundImage:carImg forState:UIControlStateNormal];
	[byCarBtn addTarget:self action:@selector(byCar) forControlEvents:UIControlEventTouchUpInside];
	[selectPanel addSubview:byCarBtn];
	
	// 車ボタンテキスト
	byCarTextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	byCarTextBtn.frame = CGRectMake(190,0,100,50);
	byCarTextBtn.titleLabel.font            = [UIFont systemFontOfSize: 18];
	byCarTextBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
	[byCarTextBtn setTitle:[pData getDataForKey:@"DEFINE_ROUTE_CARBTNTITLE"] forState:UIControlStateNormal];
	[byCarTextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[byCarTextBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[byCarTextBtn addTarget:self action:@selector(byCar) forControlEvents:UIControlEventTouchUpInside];
	[selectPanel addSubview:byCarTextBtn];
/*
	//電車ボタン
	byTrainBtn = [[UIButton alloc]initWithFrame:CGRectMake(295, 5, 40, 40)];
	[byTrainBtn setBackgroundImage:SalesDownImg forState:UIControlStateNormal];
	[byTrainBtn addTarget:self action:@selector(byTrain) forControlEvents:UIControlEventTouchUpInside];
	[selectPanel addSubview:byTrainBtn];
	
	// 電車ボタンキスト
	ByTrainTextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	ByTrainTextBtn.frame = CGRectMake(340,0,100,50);
	ByTrainTextBtn.titleLabel.font            = [UIFont systemFontOfSize: 18];
	ByTrainTextBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
	[ByTrainTextBtn setTitle:@"電車" forState:UIControlStateNormal];
	[ByTrainTextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[ByTrainTextBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	[ByTrainTextBtn addTarget:self action:@selector(byTrain) forControlEvents:UIControlEventTouchUpInside];
	[selectPanel addSubview:ByTrainTextBtn];
*/
	byWalkTextBtn.opaque = YES;
	byWalkBtn.opaque = YES;
	byCarTextBtn.opaque = YES;
	byCarBtn.opaque = YES;
	ByTrainTextBtn.opaque = YES;
	byTrainBtn.opaque = YES;
	
	selectPanel.opaque = YES;
	selectPanel.alpha = 1.0;
	[map addSubview:selectPanel];
		
	// ローディングアラートを生成
	alertView = [[UIAlertView alloc] initWithTitle:[pData getDataForKey:@"DEFINE_ROUTE_LOADING"] message:nil
										  delegate:nil cancelButtonTitle:nil otherButtonTitles:NULL];
	progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
	progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	[alertView addSubview:progress];
	[progress startAnimating];
	
	
	// 初回表示フラグ
	isFirst = YES;
	
	[self byWalk];
	
	// ローディングアラートを生成
	alertView = [[UIAlertView alloc] initWithTitle:[pData getDataForKey:@"DEFINE_ROUTE_LOADING"] message:nil
										  delegate:nil cancelButtonTitle:nil otherButtonTitles:NULL];
	progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
	progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	[alertView addSubview:progress];
	[progress startAnimating];

	// viewWillAppear が反応しないように値をクリア
	[self clearCenterPoint];
	

	//店舗ビューからの戻りではない
	isReturn = NO;
  
	// ルート
	rt = [[Route alloc] init];
	[rt getRouteList];
	

}

-(void)viewWillAppear:(BOOL)animated
{

}

- (void)viewDidAppear:(BOOL)animated
{
	if (![returnPos isEqual:[NSNull null]]){

		
		if ( isReturn == YES ) {

			//[[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
			// 地図の中心を指定
			[map setCamera:returnPos];
			isReturn = NO;
		}
	}
	
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

-(void)byWalk
{
	if ( drawProgress == YES ){
		return;
	}
	else if (byJobFlg ==NO) {
        return;
    }else{
        byJobFlg = NO;
        moveMethod = ENUM_MOVEBYWALK;
        byWalkBtn.alpha = 1.0;
        byWalkTextBtn.alpha = 1.0;
        byCarBtn.alpha = 0.3;
        byCarTextBtn.alpha = 0.3;
        ByTrainTextBtn.alpha = 0.3;
        byTrainBtn.alpha = 0.3;
	
        //ルート選択済みの場合は、再検索
        if ( [selectedRoute count])
        {
			retryCount = 0;

			//マップクリア
            [map clear];

            //ピン追加
			drawProgress = YES;
            [self addCompanyPinByArray:selectedRoute];

            //ルート検索
            [self searchRoute:lastSearchFromCurrentPos];
        }
    }
    byJobFlg = YES;
}
-(void)byTrain
{
    if (byJobFlg ==NO) {
        return;
    }else{
        moveMethod = ENUM_MOVEBYTRAIN;
        ByTrainTextBtn.alpha = 1.0;
        byTrainBtn.alpha = 1.0;
        byCarBtn.alpha = 0.3;
        byCarTextBtn.alpha = 0.3;
        byWalkBtn.alpha = 0.3;
        byWalkTextBtn.alpha = 0.3;
    }
    byJobFlg = YES;
}
-(void)byCar
{
	if ( drawProgress == YES ){
		return;
	}
	else if (byJobFlg ==NO) {
        return;
    }else{
        moveMethod = ENUM_MOVEBYCAR;
        byCarBtn.alpha = 1.0;
        byCarTextBtn.alpha = 1.0;
        byWalkBtn.alpha = 0.3;
        byWalkTextBtn.alpha = 0.3;
        ByTrainTextBtn.alpha = 0.3;
        byTrainBtn.alpha = 0.3;
	
        //ルート選択済みの場合は、再検索
        if ( [selectedRoute count])
        {
			retryCount = 0;

            //マップクリア
            [map clear];

            //ピン追加
			drawProgress = YES;
            [self addCompanyPinByArray:selectedRoute];

            //ルート検索
            [self searchRoute:lastSearchFromCurrentPos];
        }
        byJobFlg = YES;
    }
}


-(void)setNaviRightButton
{
	
	//ツールバー（検索窓とリストボタンを設置）
	UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIToolbar *toolbar = [[MyToolBar alloc] initWithFrame:CGRectMake(100.0f, 0.0f, 400.0f, 40.0f)];
	toolbar.backgroundColor = [UIColor clearColor];
	toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	UIBarButtonItem *toolbarBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
	UIFont *font = [UIFont boldSystemFontOfSize:16];
	
	UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[selectBtn setBackgroundColor:[UIColor clearColor]];
	[selectBtn.titleLabel setFont:font];
	[selectBtn setTitle:[pData getDataForKey:@"DEFINE_ROUTE_SELECT"] forState:UIControlStateNormal];
	selectBtn.frame = CGRectMake( 0,0, 100,25);
	[selectBtn addTarget:self action:@selector(SelectPushed) forControlEvents:UIControlEventTouchUpInside];
	toolbar.items = [NSArray arrayWithObjects:space,[[UIBarButtonItem alloc]initWithCustomView:selectBtn], nil];
/*
		// リストボタンの代わりに空ボタンを作成
		UIButton *empBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		empBtn.frame = CGRectMake(0,0,25,25);
		toolbar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc]initWithCustomView:empBtn], nil];
*/
	//ツールバーをナビバーに設置
	self.navigationItem.rightBarButtonItem = toolbarBarButtonItem;
	
}

-(void)SelectPushed
{
	//ダミーデータ
	NSMutableArray *dmy =  [rt getList];

	//ルート一覧をPopoverで表示
	RouteSelectPopoverViewController *rtsV = [[RouteSelectPopoverViewController alloc]init];
	rtsV.delegate = self;
	[rtsV setRouteList:dmy];
	pop = [[UIPopoverController alloc]initWithContentViewController:rtsV];
	pop.delegate = self;
	pop.popoverContentSize = rtsV.view.frame.size;
	[pop presentPopoverFromRect:CGRectMake(950, 0, 0, 0) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

//検索Popoverでセルタップ時のデリゲート
-(void)didSelectRoute:(NSString *)routeName Id:(NSString *)rId
{
	if ( nil == routeName ) {
		return;
	}
	
	//タイトル設定
	pData = [PublicDatas instance];
	NSString *ttl = [NSString stringWithFormat:@"%@%@%@",routeName ,[pData getDataForKey:@"DEFINE_ROUTE_TITLE_CONNECT"] , [pData getDataForKey:@"DEFINE_ROUTE_TITLE"]];
	[titleLabel setText:ttl];
	
	
	[titleLabel sizeToFit];
  
  //アラート表示
	[self alertShow];
	
	//PopOverを消す
	[pop dismissPopoverAnimated:YES];
  
	//戻り先を記録
	pData = [PublicDatas instance];
	[pData setData:@"MAP" forKey:@"ReturnScreen"];
  
	//既存のピン、ルートを消去
	[map clear];
  
  //クエリ作成
  NSString *query1 = @"SELECT  Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, order__c, account__c, duplicatecheck__c, RouteMst__c, duplicatecheck_m__c ";
	NSString *query2 = [NSString stringWithFormat:@"FROM RouteTrn__c WHERE RouteMst__c = '%@' ORDER BY order__c ",rId];
	NSString *query = [query1 stringByAppendingString:query2];
  SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:query];
  [[SFRestAPI sharedInstance] send:request delegate:self];
}

//SOQLのアンサー受信
- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
	NSArray *records = [jsonResponse objectForKey:@"records"];
	NSLog(@"request:didLoadResponse: #records: %d", records.count);
	selectedRoute = [NSMutableArray array];
  
	NSString *where =@"";
	int loopMax = [records count];
	int loopCnt = 0;
	for ( NSDictionary *obj in records ) {
		Company *tempCp = [[Company alloc]init];
		tempCp.company_id = [obj valueForKey:@"account__c"];
		where = [where stringByAppendingString:[NSString stringWithFormat:@"Account__r.Id='%@'", tempCp.company_id ]];
		if ( loopCnt++ != loopMax - 1 ){
			where = [where stringByAppendingString:@" OR "];
		}
		[selectedRoute addObject:tempCp];
	}

	//NSString *query1 = @"SELECT Account__r.Id, Account__r.Name, Account__r.Phone, Account__r.BillingState, Account__r.BillingCity, Account__r.BillingStreet, LatNum__c, LngNum__c,  Account__r.status__c ";
	NSString *query1 = @"SELECT Account__r.Id, Account__r.Name, Account__r.Phone, Account__r.BillingState, Account__r.BillingCity, Account__r.BillingStreet, GPS__Latitude__s, GPS__Longitude__s,  Account__r.status__c ";
	NSString *query2 = [NSString stringWithFormat:@"FROM LatLngObj__c WHERE %@", where];
	NSString *query = [query1 stringByAppendingString:query2];
	
	[[SFRestAPI sharedInstance] performSOQLQuery:query
		//エラーハンドラ
		failBlock:^(NSError *e) {
			NSLog(@"FAILWHALE with error: %@", [e description] );
		}
		completeBlock:^(NSDictionary *results) {
									   
			NSLog(@"%@",results);
									   
			NSArray *records = [results objectForKey:@"records"];
			for ( int i = 0; i < [records count]; i++ ) {
			
				NSDictionary *dict = [records objectAtIndex:i];
				NSDictionary *dic = [dict objectForKey:@"Account__r"];
				NSString *billingCity = [dic objectForKey:@"BillingCity"];
				NSString *billingStreet = [dic objectForKey:@"BillingStreet"];
				NSString *billingState = [dic objectForKey:@"BillingState"];
				NSString *aname = [dic objectForKey:@"Name"];
				NSString *phone = [dic objectForKey:@"Phone"];
        NSString *address;
        if([um chkString:billingState]){
          address = [billingState stringByAppendingString:billingCity];
        }else{
          address = billingCity;
        }
				//double lat = [[dict objectForKey:@"LatNum__c"]floatValue];
				//double lng = [[dict objectForKey:@"LngNum__c"]doubleValue];
				double lat = [[dict objectForKey:@"GPS__Latitude__s"]floatValue];
				double lng = [[dict objectForKey:@"GPS__Longitude__s"]doubleValue];
				NSString *cpId = [dic objectForKey:@"Id"];

				Company *tempCp2;
				for ( int ii = 0; ii < [selectedRoute count]; ii++ ){
					tempCp2 = [selectedRoute objectAtIndex:ii];
          NSLog(@" tempCp2.company_id : %@", tempCp2.company_id);
					if ( [tempCp2.company_id isEqualToString:cpId] ) {
						tempCp2.Address1 = address;
						tempCp2.Address2 = billingStreet;
						tempCp2.phone1 = phone;
						tempCp2.name = aname;
						tempCp2.position = CLLocationCoordinate2DMake(lat, lng);
						NSString *status = [dic objectForKey:@"status__c"];
					
						if (status != nil && ![status isEqual:[NSNull null]]) {
							if([status isEqual:@"SalesUp"]){
								tempCp2.salesStatus = SALES_UP;
							}else if([status isEqual:@"SalesDown"]){
								tempCp2.salesStatus = SALES_DOWN;
							}else{
								tempCp2.salesStatus = SALES_FLAT;
							}
						}else{
							tempCp2.salesStatus = SALES_FLAT;
						}
						NSData *iData;
						UIImage *cpimage;
						NSString *image_key;
						NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
						image_key = [NSString stringWithFormat:@"img_%@",tempCp2.company_id];
						iData = [ud objectForKey:image_key];
						cpimage = [UIImage imageWithData:iData];
						tempCp2.image = cpimage;
					}
				}
			}
			
			//ピン追加
			[self addCompanyPinByArray:selectedRoute];
			
			//デフォルトルート検索
			[self searchRoute:YES];
			
			[self performSelectorInBackground:@selector(requestCpImage) withObject:nil];
		}
	 ];
}


//表示用の企業ロゴを別スレッドで取得
-(void)requestCpImage
{
    //画像取得　バックエンドの処理が終わっていなかったらスキップ
    if(!isImgBackJob){
        return;
    }else{
        isImgBackJob = NO;
		[self retriveImage:selectedRoute];
		
        [self performSelectorOnMainThread:@selector(requestCpImageDidFinish) withObject:nil waitUntilDone:NO];
    }
}

- (void)requestCpImageDidFinish{
    isImgBackJob = YES;
}


-(void)searchRoute:(BOOL)defaultRoute
{
	lastSearchFromCurrentPos = defaultRoute;
	
	if ( defaultRoute == YES ) {
		queryedWaypt = 1;
	}
	else {
		queryedWaypt = 0;
	}

	//既存のピン、ルートを消去
	[map clear];
	

	if ( defaultRoute == NO ) {

		//現在地からのルート
		
		//ルート検索
		NSMutableArray *sortRoute = [self sortWayPoint:selectedRoute];

		//ピン追加
		[self addCompanyPinByArray:sortRoute];
		[self routeByWaypt:sortRoute index:queryedWaypt];
        
		//現在地を含めたルートを表示
		Company *cp = [[Company alloc]init];
		cp.position = myPos;
		NSMutableArray *tmpAry = [sortRoute mutableCopy];
		[tmpAry addObject:cp];
		[self dispRoute:tmpAry];
	}
	else {

		//デフォルトルート検索（現在地を含めないルート）

		//ピン追加
		[self addCompanyPinByArray:selectedRoute];
		
		//ルート検索
		[self routeByWaypt:selectedRoute index:queryedWaypt];
		[self dispRoute:selectedRoute];
	}
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
			
      NSLog(@"status : %@", status);
			if(![status isEqualToString:@"OK"]){
				[self searchRetakeGoogle:target Option:@"駅"];
			}
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
				NSDictionary *dat = [NSDictionary dictionaryWithObjectsAndKeys:	target , @"title",
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
					
					// 確認アラート
					UIAlertView *nonAlertView =
					[[UIAlertView alloc]
					 initWithTitle:[pData getDataForKey:@"DEFINE_ROUTE_NOTFOUND"]
					 message:nil
					 delegate:nil
					 cancelButtonTitle:nil
					 otherButtonTitles:[pData getDataForKey:@"DEFINE_ROUTE_CONFIRM"], nil
					 ];
					[nonAlertView show];
				}
			}
			// NSMutableArray *placemarksArray = [NSMutableArray arrayWithCapacity:[resultsArray count]];
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
				NSDictionary *dat = [NSDictionary dictionaryWithObjectsAndKeys:	target , @"title",
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
	//[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[self alertShow];
	
	NSString *target = searchBar.text;
	
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
				 initWithTitle:[pData getDataForKey:@"DEFINE_ROUTE_NOTFOUND"]
				 message:nil
				 delegate:nil
				 cancelButtonTitle:nil
				 otherButtonTitles:[pData getDataForKey:@"DEFINE_ROUTE_CONFIRM"], nil
				 ];
				[nonAlertView show];
			}
		}
	}];
}

//地点検索
-(void)searchAround:(CLLocationCoordinate2D)point;
{
	double	latmax,
	latmin,
	lngmax,
	lngmin;
	
	//検索地点保存
	searchPos = point;
	
	latmax = point.latitude + SearchAreaLat;
	latmin = point.latitude - SearchAreaLat;
	lngmax = point.longitude + SearchAreaLng;
	lngmin = point.longitude - SearchAreaLng;
	
	//クエリ作成
	//NSString *query1 = @"SELECT Account__r.Id, Account__r.Name, Account__r.Phone, Account__r.BillingState, Account__r.BillingCity, Account__r.BillingStreet, LatNum__c, LngNum__c";
	//NSString *query2 = [NSString stringWithFormat:@"FROM LatLngObj__c WHERE LatNum__c <= %f AND LatNum__c >= %f AND LngNum__c <= %f AND LngNum__c >= %f",latmax,latmin,lngmax,lngmin];

	NSString *query1 = @"SELECT Account__r.Id, Account__r.Name, Account__r.Phone, Account__r.BillingState, Account__r.BillingCity, Account__r.BillingStreet, GPS__Latitude__s, GPS__Longitude__s ";
	NSString *query2 = [NSString stringWithFormat:@"FROM LatLngObj__c WHERE GPS__Latitude__s <= %f AND GPS__Latitude__s >= %f AND GPS__Longitude__s <= %f AND GPS__Longitude__s >= %f",latmax,latmin,lngmax,lngmin];
 
  
	NSString *query = [query1 stringByAppendingString:query2];
	NSLog(@"%@",query);
	SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:query];
	[[SFRestAPI sharedInstance] send:request delegate:self];

}


//ルート全体を表示
-(void)dispRoute:(NSMutableArray*)array
{
	double	latmax,latmin,
	lngmax, lngmin;
	
	latmax = 0;
	lngmax = 0;
	latmin = 999;
	lngmin = 999;

	//検索結果リストから緯度経度の最大値を求める
	for ( int i = 0; i < [array count]; i++ ){
		Company *cp = [array objectAtIndex:i];
		
		if ( cp.position.latitude > latmax ) {
			latmax = cp.position.latitude;
		}
		if ( cp.position.latitude < latmin ) {
			latmin = cp.position.latitude;
		}
		
		if ( cp.position.longitude > lngmax ) {
			lngmax = cp.position.longitude;
		}
		if ( cp.position.longitude < lngmin ) {
			lngmin = cp.position.longitude;
		}
	}
	
	CLLocationCoordinate2D center;
	
	center.latitude = (( latmax - latmin ) / 2 ) + latmin;
	center.longitude = (( lngmax - lngmin ) / 2 ) + lngmin;
	
	[self mapZoom:center points:array];
}

//マップの表示範囲調整
-(void)mapZoom:(CLLocationCoordinate2D)center points:(NSMutableArray*)array
{
	double	latmax,latmin,
	lngmax, lngmin;
	
	latmax = 0;
	lngmax = 0;
	latmin = 999;
	lngmin = 999;
	
	
	//検索結果リストから緯度経度の最大値を求める
	for ( int i = 0; i < [array count]; i++ ){
		Company *cp = [array objectAtIndex:i];
		
		if ( cp.position.latitude > latmax ) {
			latmax = cp.position.latitude;
		}
		if ( cp.position.latitude < latmin ) {
			latmin = cp.position.latitude;
		}
		
		if ( cp.position.longitude > lngmax ) {
			lngmax = cp.position.longitude;
		}
		if ( cp.position.longitude < lngmin ) {
			lngmin = cp.position.longitude;
		}
	}

	CLLocationCoordinate2D southWest,northEast;
	southWest.latitude = latmax;
	southWest.longitude = lngmin;
	northEast.latitude = latmin;
	northEast.longitude = lngmax;
	
	float mapViewWidth = self.mapView.frame.size.width;
	float mapViewHeight = self.mapView.frame.size.height-180;
	
	MKMapPoint point1 = MKMapPointForCoordinate(southWest);
	MKMapPoint point2 = MKMapPointForCoordinate(northEast);

	double mapScaleWidth = mapViewWidth / fabs(point2.x - point1.x);
	double mapScaleHeight = mapViewHeight / fabs(point2.y - point1.y);
	double mapScale = MIN(mapScaleWidth, mapScaleHeight);
	
//	double zoomLevel = 20 + log2(mapScale);
	double zoomLevel = 19.9 + log2(mapScale);
	
	GMSCameraPosition *camera = [GMSCameraPosition
								 cameraWithLatitude: center.latitude
								 longitude: center.longitude
								 zoom: zoomLevel];
	
	[map setCamera:camera];
}

//受け取ったオブジェクトがNSString以外なら空のNSStringを返す
-(NSString*)chkString:(id)tgt
{
  @try {
    NSString *cls = NSStringFromClass([tgt class]);
    if ( ![cls isEqualToString:@"__NSCFString"]) {
      return @"";
    }
    else {
      return tgt;
    }
  }@catch (NSException *exception) {
    NSLog(@"main:Caught %@:%@", [exception name], [exception reason]);
    return @"";
  }
}

//複数地点のルート検索
-(void)routeByWaypt:(NSMutableArray *)ary index:(int)index
{
	Company *cp;
	
	
	if ( [ary count] == 0) {
		return;
	}
	if ( [ary count] <= index){
		return;
	}
	
	Company *tempcp;
	CLLocationCoordinate2D org;
	CLLocationCoordinate2D dst;
		
	tempcp = [ary objectAtIndex:0];

	//最初の地点から検索の場合は、現在地をスタート地点とする
	if ( index == 0 ) {
		org = myPos;
	}
	else {
		cp = [ary objectAtIndex:index - 1];
		org = cp.position;
	}
	
	cp = [ary objectAtIndex:index];
	dst = cp.position;
	
	//2点間のルート検索実行
	[self getRouteP2P:org destination:dst];
	
}

//２点間のルートを求める
-(void)getRouteP2P:(CLLocationCoordinate2D)org destination:(CLLocationCoordinate2D)dst
{
	
	//ルート検索
	NSString *origin = [NSString stringWithFormat:@"origin=%f,%f",org.latitude, org.longitude];
	NSString *destination = [NSString stringWithFormat:@"&destination=%f,%f",dst.latitude, dst.longitude];
	NSString *sens = @"&sensor=false";

	if (( org.latitude == dst.latitude ) && ( org.longitude == dst.longitude )){
		if (( [selectedRoute count] - 1 ) > queryedWaypt ){
			[self routeByWaypt:selectedRoute index:++queryedWaypt];
		}
		else {
			//ルート検索終了
			// アラートを閉じる
			if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
		}
		return;
	}
	
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

//companyの配列を受け取り、ピンを追加
-(void)addCompanyPinByArray:(NSMutableArray*)ary
{
	for( int i = 0; i < [ary count]; i++){
		Company *cp = [ary objectAtIndex:i];
        cp.sortKey2 = i+1;
		[self addCompanyPin:[ary objectAtIndex:i]];
	}
}

//会社情報を元にピン追加
-(void)addCompanyPin:(Company*)cp
{
	GMSCameraPosition *pos = [GMSCameraPosition cameraWithTarget:cp.position zoom:InitialZoom];
	NSString *title = cp.name;
    NSNumber *sortkey = [[NSNumber alloc]initWithInt:cp.sortKey2];
	NSNumber *type = [[NSNumber alloc]initWithInt:ENUM_PINCOMPANY];
	NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:	pos,@"position",
						 title,@"title",
						 type,@"type",
						 cp,@"company",
                         sortkey,@"sortkey",
						 nil];
	
	[self addMarkersToMap:dic];
}

//マーカーピン追加
- (void)addMarkersToMap:(NSDictionary*)dic
{
    UIImage *pinImage;
	
	GMSMarkerOptions *op = [[GMSMarkerOptions alloc] init];
	GMSCameraPosition *pos = [dic objectForKey:@"position"];
	op.position = pos.target;
	op.title = [dic objectForKey:@"title"];
	op.userData = dic;
	op.groundAnchor = CGPointMake(0.5, 1.0);
	
	//ピンの画像指定
	NSNumber *num = [dic objectForKey:@"type"];
    NSNumber *sortkey = 0;
    NSString *cpimg = @"";
    
	switch ([num intValue]) {
		case ENUM_PINSEARCHLOCATION:
		case ENUM_PINCURRENTLOCATION:
			pinImage = [UIImage imageNamed:@"location1.png"];
			op.icon = pinImage;
			
			//検索地点を記録
			lastSerachLocation = op;
			break;
			
		case ENUM_PINCOMPANY:
  
            sortkey = [dic objectForKey:@"sortkey"];
            cpimg = [NSString stringWithFormat:@"cp_img_%@.png",sortkey];
            pinImage = [UIImage imageNamed:cpimg];
            
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
		
		NSLog(@"%f:%f",mapView.center.x, mapView.center.y);
		
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
    if (map.selectedMarker) {
        
		[pop dismissPopoverAnimated:NO];
		
        id<GMSMarker> marker = map.selectedMarker;
        NSDictionary  *userData = marker.userData;
		Company *cp = [userData objectForKey:@"company"];
		NSLog(@"ID:%@",cp.company_id);

		//戻り先を記録
		pData = [PublicDatas instance];
		[pData setData:@"MAP" forKey:@"ReturnScreen"];

		// 中心地点を記憶
		[self saveCenterPoint];

		isReturn = YES;
		
		//店舗ビューに遷移
		MetricsViewController *metVC = [[MetricsViewController alloc]initWithNibName:@"Metrics" bundle:[NSBundle mainBundle]company:cp];
		[self.navigationController pushViewController:metVC animated:YES];
	}
}

//UIImage:imgがRectより大きい場合リサイズする
-(id)resizeImage:(UIImage*)img Rect:(CGRect)rect
{
	if (( img.size.height > rect.size.height) ||
		( img.size.width > rect.size.width)) {
        
        float asp;
        int height = rect.size.height;
        int width  = rect.size.width;
        int x = 0;
        int y = 0;
        
        if (img.size.height > img.size.width) {
            asp = img.size.width / img.size.height;
            width = width * asp;
            x = (rect.size.width - width)/2;
        }else{
            asp = img.size.height / img.size.width;
            height = height * asp;
            y = (rect.size.height - height)/2;
        }
		
		UIGraphicsBeginImageContext(rect.size);
		[img drawInRect:CGRectMake(x,y,width,height)];
		img = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
	return img;
}

- (void)mapView:(GMSMapView *)pMapView didChangeCameraPosition:(GMSCameraPosition *)position
{
	
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
	}
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
//		[self searchAround:myPos];
		//[locationManager stopUpdatingLocation];
	}
}


//ナビゲーションバーの「戻る」ボタン処理
-(void)back
{
	[pop dismissPopoverAnimated:YES];
	//ナビゲーションバー　設定
	[self.navigationController.navigationBar setHidden:YES];
	
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


//現在地ボタン押下（ルート検索）
-(void)currentPos
{
	pData = [PublicDatas instance];

	if ( ![selectedRoute count]) {
		routeAlertView = [[UIAlertView alloc]
					  initWithTitle:[pData getDataForKey:@"DEFINE_ROUTE_NOTSELECTEDTITLE"]
					  message:[pData getDataForKey:@"DEFINE_ROUTE_NOTSELECTEDMSG"]
					  delegate:nil
					  cancelButtonTitle:nil
					  otherButtonTitles:@"OK", nil ];
		[routeAlertView show];
		return;
	}
	
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
		
//		moveCurrentPos = YES;
		GMSCameraPosition *pos = [GMSCameraPosition cameraWithLatitude:myPos.latitude longitude:myPos.longitude zoom:InitialZoom];
		[map setCamera:pos];

		//ピン追加
		[self addCompanyPinByArray:selectedRoute];
		
		//現在地からのルート表示
		//ルート検索
		[self searchRoute:NO];
		
		//現在地を含めたルートを表示
		Company *cp = [[Company alloc]init];
		cp.position = myPos;
		NSMutableArray *tmpAry = [selectedRoute mutableCopy];
		[tmpAry addObject:cp];
		[self dispRoute:tmpAry];
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
}

//
//以下、ルート検索のデリゲート
//

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
//	NSLog(@"%@",jsonObject);
	
	NSString *status = [jsonObject valueForKey:@"status"];
  NSLog(@"status : %@", status);
	if ([status isEqualToString:@"ZERO_RESULTS"])  {

		if ( retryCount++ < 2 ){
			//再検索
            [self searchRoute:lastSearchFromCurrentPos];
		}
		else {
			// アラートを閉じる
			drawProgress = NO;
			if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
			pData = [PublicDatas instance];
			NSLog(@"ERROR:%@",status);
			routeAlertView = [[UIAlertView alloc]
							  initWithTitle:[pData getDataForKey:@"DEFINE_ROUTE_SEARCHERRTITLE"]
							  message:[pData getDataForKey:@"DEFINE_ROUTE_NOVALIDROUTE"]
							  delegate:nil
							  cancelButtonTitle:nil
							  otherButtonTitles:[pData getDataForKey:@"DEFINE_ROUTE_ALERTOK"], nil ];
			[routeAlertView show];
		}
		return;
	}
	else
	if ( ![status isEqualToString:@"OK"])  {
		NSLog(@"ERROR:%@",status);

		
		if ( retryCount++ < 2 ){
			//再検索
            [self searchRoute:lastSearchFromCurrentPos];
		}
		else {
			// アラートを閉じる
			drawProgress = NO;
			if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];

			routeAlertView = [[UIAlertView alloc]
							 initWithTitle:[pData getDataForKey:@"DEFINE_ROUTE_SEARCHERRTITLE"]
							 message:[NSString stringWithFormat:@"%@\n(%@)",[pData getDataForKey:@"DEFINE_ROUTE_SEARCHFAILED"] ,status]
							 delegate:nil
							 cancelButtonTitle:nil
							 otherButtonTitles:[pData getDataForKey:@"DEFINE_ROUTE_ALERTOK"], nil ];
			[routeAlertView show];
		}
		return;
	}
	NSDictionary *routes = [jsonObject valueForKeyPath:@"routes"];
//	NSArray *legs = [routes valueForKeyPath:@"legs"];
	NSArray *overView = [routes valueForKeyPath:@"overview_polyline"];
	NSDictionary *dic = [overView objectAtIndex:0];
	NSString *point = [dic objectForKey:@"points"];
//	NSLog(@"%@",point);
	
	//PolyLine表示
	options = [GMSPolylineOptions options];
	path = [GMSMutablePath path];
	[self polylineWithEncodedString:point];
	options.path = path;
	options.color = [UIColor colorWithRed:0.5f green:0.0f blue:0.5f alpha:0.5f];
	options.width = 5.0f;
	options.geodesic = YES;
	[map addPolylineWithOptions:options];
	
	if (( [selectedRoute count] - 1 ) > queryedWaypt ){
		[self routeByWaypt:selectedRoute index:++queryedWaypt];
	}
	else {
		//ルート検索終了
		drawProgress = NO;
		// アラートを閉じる
		if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
	}
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

-(NSMutableArray*)sortWayPoint:(NSMutableArray*)ary
{
	NSMutableArray *src = [NSMutableArray arrayWithArray:ary];
	
	int cnt = 0;
	int index = 0 ;
//	int lmax = [src count];
	Company *moveObj = [[Company alloc]init];
	CLLocationDistance wrkDist;
	CLLocation *lc = [[CLLocation alloc]initWithLatitude:myPos.latitude longitude:myPos.longitude];
	#pragma unused(moveObj)
    
	wrkDist = DBL_MAX;
	for ( int i = 0; i< [src count]; i++ ) {
		Company *cp = [src objectAtIndex:i];
		CLLocation *cmpLc = [[CLLocation alloc]initWithLatitude:cp.position.latitude longitude:cp.position.longitude];
		CLLocationDistance dist = [lc distanceFromLocation:cmpLc];
		if ( wrkDist > dist) {
			wrkDist = dist;
			index = i;
		}
	}
	moveObj = [src objectAtIndex:index];
	moveObj.sortKey1 = cnt++;
	for ( int i = index + 1; i < [src count]; i++ ){
		moveObj = [src objectAtIndex:i];
		moveObj.sortKey1 = cnt++;
	}
	
	for ( int i = 0; i < index; i++ ){
		moveObj = [src objectAtIndex:i];
		moveObj.sortKey1 = cnt++;
	}
	
	//ソート対象となるキーを指定した、NSSortDescriptorの生成
	NSSortDescriptor *sortDescNumber;
	sortDescNumber = [[NSSortDescriptor alloc] initWithKey:@"sortKey1" ascending:YES];
	
	NSMutableArray *sortDescArray;
	sortDescArray = [NSMutableArray arrayWithObjects:sortDescNumber, nil];
	NSArray *sortArray = [src mutableCopy];
	NSArray *sorttempArray = [sortArray sortedArrayUsingDescriptors:sortDescArray];
	return [sorttempArray mutableCopy];

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
	if(_lat)[userDefault setDouble:map.camera.target.latitude forKey:@"lat"];
	if(_lon)[userDefault setDouble:map.camera.target.longitude forKey:@"lon"];
	[userDefault setFloat:map.camera.zoom forKey:@"zoom"];
	[userDefault setDouble:[[UIDevice currentDevice] orientation] forKey:@"orientation"];
	[userDefault synchronize];
  
  NSLog(@"save lat %f", [userDefault doubleForKey:@"lat"]);
  NSLog(@"save lon %f", [userDefault doubleForKey:@"lon"]);
	NSLog(@"save zoom %f", [userDefault floatForKey:@"zoom"]);
	
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

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // エラー情報を表示する。
    NSLog(@"Connection failed! Error - %@ %@",
		  [error localizedDescription],
		  [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	
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
-(void)retriveImage:(NSMutableArray*)cpnyArray
{
	//画像読み込み設定がOFFの場合、読み込みを行わずに抜ける
	if ( NO == LogoLoad ){
		return;
	}
	if ( [cpnyArray count] == 0) {
		return;
	}
	
	NSString *where =@"";
	int loopMax = [cpnyArray count];
	int loopCnt = 0;
	for ( Company *tempCp in cpnyArray ) {
		where = [where stringByAppendingString:[NSString stringWithFormat:@"ParentId='%@'", tempCp.company_id ]];
		if ( loopCnt++ != loopMax - 1 ){
			where = [where stringByAppendingString:@" OR "];
		}
	}
	pData = [PublicDatas instance];
	
	NSString *query = [NSString stringWithFormat:@"SELECT ParentId, Name,Body,BodyLength FROM Attachment WHERE %@ ",where];

	SFRestRequest *req = [[SFRestAPI sharedInstance] requestForQuery:query];
	[[SFRestAPI sharedInstance] sendRESTRequest:req
		failBlock:^(NSError *e) {
			NSLog(@"FAILWHALE with error: %@", [e description] );
			alertView = [[UIAlertView alloc]
            initWithTitle:[pData getDataForKey:@"DEFINE_ROUTE_IMGREADERRTITLE"]
            message:[pData getDataForKey:@"DEFINE_ROUTE_IMAREADERRMSG"]
            delegate:nil
            cancelButtonTitle:nil
            otherButtonTitles:[pData getDataForKey:@"DEFINE_ROUTE_ALERTOK"], nil ];
			[alertView show];
		}
		completeBlock:^(id jsonResponse){
			NSDictionary *dict = (NSDictionary *)jsonResponse;
            NSLog(@"%@",dict);
									  
			//アラート表示
 //         [self alertShow];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
									  
            //受信データクリア
            rcvData = [[NSMutableData alloc]init];
            NSString *image_key;
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            NSArray *records = [dict objectForKey:@"records"];
			NSLog(@"%@",records);
				for ( int i = 0; i< [records count]; i++ ){
					NSDictionary *rec = [records objectAtIndex:i];
                    NSString *url = [rec objectForKey:@"Body"];
                    NSString *name = [rec objectForKey:@"Name"];
                    NSString *bodyLength = [rec objectForKey:@"BodyLength"];
					NSString *cpId = [rec objectForKey:@"ParentId"];
                    int bSize = [bodyLength intValue];
 					
					Company *tempCp = [[Company alloc]init];
					for ( int ii = 0; ii < [selectedRoute count]; ii++ ){
						tempCp = [selectedRoute objectAtIndex:ii];
						if ([tempCp.company_id isEqualToString:cpId]) {
							break;
						}
					}
					
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
											  
						NSURLResponse *resp;
						NSError *err;
                                              
						NSData *rcvTmpData = [NSURLConnection sendSynchronousRequest:requestDoc returningResponse:&resp error:&err];
						rcvData = [rcvTmpData mutableCopy];
          									  
						//共用データのインスタンス取得
						pData = [PublicDatas instance];
						if ( !err ){
							UIImage *img = [[UIImage alloc]initWithData:rcvData];
							tempCp.image = img;
                                                  
							NSData *imageData = UIImagePNGRepresentation(img);
							image_key = [NSString stringWithFormat:@"img_%@",tempCp.company_id];
							[ud setObject:imageData forKey:image_key];
							[ud synchronize];
                                                  
						}
						else {
							// アラートを閉じる
							//if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
												  
							NSLog(@"FAILWHALE with error: %@", [err description] );
							alertView = [[UIAlertView alloc]
												initWithTitle:[pData getDataForKey:@"DEFINE_ROUTE_IMGREADERRTITLE"]
												message:[pData getDataForKey:@"DEFINE_ROUTE_IMGREADERRMSG"]
												delegate:nil
												cancelButtonTitle:nil
												otherButtonTitles:[pData getDataForKey:@"DEFINE_ROUTE_ALERTOK"], nil ];
							[alertView show];
						}
					}
				}
			}
		];
}

//str1がstr2を含む場合はYESを返す
-(BOOL)isInclude:(NSString*)str1 cmp:(NSString*)cmp
{
	NSRange result = [str1 rangeOfString:cmp];
	if (result.location == NSNotFound){
		return NO;
	}
	return  YES;
}

-(void)viewDidUnload
{
	[self setMapView:nil];
	[super viewDidUnload];
}


@end
