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

#import "OrderViewController.h"
#import "PublicDatas.h"
#import "MetricsViewController.h"
#import "OrderInfo.h"
#import "StoreMapViewController.h"
#import "OrderViewController+HistoryScreen.h"
#import "OrderViewController+OrderScreen.h"
#import "OrderViewController+DetailScreen.h"
#import "OrderDefine.h"
#import "ItemBadge.h"
#import "AppDelegate.h"

@implementation OrderViewController


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
	
	um = [UtilManager sharedInstance];

	//共有データのインスタンス取得
	pData = [PublicDatas instance];
 	
	//ナビゲーションバー　設定
	NSData *iData =[um navBarType];
	if ( [((NSString*)iData) isEqualToString:@"gray"] ) {
		[self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
		self.navigationController.navigationBar.tintColor = [UIColor grayColor];
		_orderHeader.backgroundColor = [UIColor grayColor];

		UIView *btnView = [[UIView alloc]initWithFrame:CGRectMake(0,0, 100, 30)];
		btnView.backgroundColor = [UIColor grayColor];
		btnImg = [um convViewToImage:btnView];

	}
	else if ( [((NSString*)iData) isEqualToString:@"black"] ) {
		[self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
		self.navigationController.navigationBar.tintColor = [UIColor blackColor];
		_orderHeader.backgroundColor = [UIColor blackColor];

	    UIView *btnView = [[UIView alloc]initWithFrame:CGRectMake(0,0, 100, 30)];
		btnView.backgroundColor = [UIColor blackColor];
		btnImg = [um convViewToImage:btnView];
	}
	else {
		iData =[um navBarImage];
		if ( iData ) {
			UIImage *img = [UIImage imageWithData:iData];
			btnImg = img;
			[self.navigationController.navigationBar setBackgroundImage:img
                                                    forBarMetrics:UIBarMetricsDefault];
      
			[_orderHeader setBackgroundColor:[UIColor colorWithPatternImage:img]];
			UIImageView *im = [[UIImageView alloc] initWithImage:img];
			[im setFrame:CGRectMake(0, 0, _orderHeader.bounds.size.width, _orderHeader.bounds.size.height)];
      //[orderHeader addSubview:im];
		}
	}

	//ナビバータイトル
	self.title = [pData getDataForKey:@"DEFINE_STORORDER_TITLE"];
	titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
	titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.textColor = [UIColor whiteColor]; // change this color
	self.navigationItem.titleView = titleLabel;
	titleLabel.text =self.title;
	[titleLabel sizeToFit];
	
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
	
	//ツールバー
	UIToolbar *toolbar = [[MyToolBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 40.0f)];
	toolbar.backgroundColor = [UIColor clearColor];
	toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	UIBarButtonItem *toolbarBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
	
	//画面（機能）切り替えボタン
	btnBuilder = [[BuildNavButtons alloc]initWithCompany:cp];
	btnBuilder.delegate = self;
  btnBuilder.cacheDelegate = self;
//	metricsBtn = [btnBuilder buildMetricsBtn];
//	mapBtn = [btnBuilder buildMapBtn];
//	ordersBtn = [btnBuilder buildOrdersBtn];
//	chatterBtn = [btnBuilder buildChatterBtn];
	metricsBtn = [btnBuilder buildMenuBtn];
	
//	UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	toolbar.items = [NSArray arrayWithObjects:
					 [[UIBarButtonItem alloc]initWithCustomView:metricsBtn],
/*					 space,
					 [[UIBarButtonItem alloc]initWithCustomView:mapBtn],
					 [[UIBarButtonItem alloc]initWithCustomView:ordersBtn],
					 [[UIBarButtonItem alloc]initWithCustomView:chatterBtn],*/
					 nil];
	
	//ツールバーをナビバーに設置
	self.navigationItem.rightBarButtonItem = toolbarBarButtonItem;
	
	//ナビゲーションバーに「戻る」ボタン配置
	self.navigationItem.leftBarButtonItem = [btnBuilder buildBackBtn];
	
	[_orderView setUserInteractionEnabled:YES];
	
	//カテゴリ選択ボタン
	UIFont *font = [UIFont boldSystemFontOfSize:16];
	UIButton *catBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	catBtn.frame = CGRectMake(845, 5, 150, 30);
	[catBtn setTitle:[pData getDataForKey:@"DEFINE_STORORDER_FAMILY_BTN_TITLE"] forState:UIControlStateNormal];
	catBtn.backgroundColor = [UIColor clearColor];
	[catBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[catBtn.titleLabel setFont:font];
	[catBtn addTarget:self action:@selector(familySelectPushed:) forControlEvents:UIControlEventTouchUpInside];
	[_orderHeader addSubview:catBtn];
  
	//スクロール設定
	CGRect rect = _orderView.frame;
	rect.origin.x = 0;
	rect.origin.y = 5;
	rect.size.height = 240;
	scrl = [[UIScrollView alloc]initWithFrame:rect];
	[scrl setUserInteractionEnabled:YES];
	//scrl.contentSize = CGSizeMake(1900, 180);
	//[_orderView addSubview:scrl];
	
  // カバーフロー
  carousel = [[iCarousel alloc]initWithFrame:rect];
  carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  carousel.delegate = self;
  carousel.dataSource = self;
  carousel.contentMode = UIViewContentModeScaleAspectFit;
  //carousel.type = iCarouselTypeRotary;
  carousel.type = iCarouselTypeCoverFlow2;
  isFistChg = YES;
  
  UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:carousel.frame];
  backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  backgroundView.backgroundColor = [UIColor blackColor];
  //[_orderView addSubview:backgroundView];
  [_orderView  addSubview:carousel];
  
	//注文配列初期化
	orderArray = [NSMutableDictionary dictionary];
	
	//在庫数減算用配列初期化（For demonstraion
	saledArray = [NSMutableDictionary dictionary];
	
	//会社情報表示
	[_companyProfile setInfo:cp];
	_companyProfile.delegate = self;
	
	salesGraph = [[LineGrapth alloc]initWithFrame:CGRectMake(30, 222, 600, 220)];
	[salesGraph setBackgroundColor:[UIColor whiteColor]];
	salesGraph.graphSizeX = 500;
	salesGraph.graphSizeY = 170;
  
	stockGraph = [[BarGraph alloc]initWithFrame:CGRectMake(660, 222, 300, 220)];
	[stockGraph setBackgroundColor:[UIColor whiteColor]];
	stockGraph.graphSizeX = 220;
	stockGraph.graphSizeY = 170;
  
	//グラフ表示の対象商品名表示用ラベル
	productLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,230, 1000, 30)];
	[productLabel setTextAlignment:NSTextAlignmentLeft];
	[productLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
	[productLabel setBackgroundColor:[UIColor whiteColor]];
	[productLabel setTextColor:[UIColor blackColor]];
	
	//PDFリストを取得
	
	//商品カテゴリ（ファミリ）取得
	[self getProductFmily];
	
	
	[_histroyBtn setTitle:[pData getDataForKey:@"DEFINE_STORORDER_ORDERHISTORY_BTN_TITLE"] forState:UIControlStateNormal];
	[_histroyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_histroyBtn setBackgroundColor:[UIColor colorWithPatternImage:btnImg]];
	[_histroyBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];

	[_orderBtn setTitle:[pData getDataForKey:@"DEFINE_STORORDER_ORDERCONFIRM_BTN_TITLE"] forState:UIControlStateNormal];
	[_orderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_orderBtn setBackgroundColor:[UIColor colorWithPatternImage:btnImg]];
	[_orderBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
	
	// 角丸
	CGSize size = CGSizeMake(5.0, 5.0);
	[um makeViewRound:_companyProfile corners:UIRectCornerAllCorners size:&size];
	[um makeViewRound:_orderHeader corners:UIRectCornerTopLeft|UIRectCornerTopRight size:&size];
	[um makeViewRound:_orderView corners:UIRectCornerBottomLeft|UIRectCornerBottomRight size:&size];
	[um makeViewRound:_histroyBtn corners:UIRectCornerAllCorners size:&size];
	[um makeViewRound:_orderBtn corners:UIRectCornerAllCorners size:&size];

  // 仮画像
  clearImgView = [[UIView alloc]initWithFrame:CGRectMake(0,0, 200, 200)];
  clearImgView.backgroundColor = [UIColor colorWithRed:0.00 green:0.00 blue:.00 alpha:0.0];
  clearData = UIImagePNGRepresentation([um convViewToImage:clearImgView]);
  clearImg = [UIImage imageWithData:clearData];
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


//商品ファミリ（カテゴリ）選択押下時
-(void)familySelectPushed:(id)sender
{
	//小画面表示中は抜ける
	if ( dispChildScreen == YES) {
		return;
	}
	
	if ([familyList count] == 0 ) {
		return;
	}
	if (![self isNull:pop]){
		return;
	}
	
	isFistChg = YES;
  
	UIButton *wrkBtn = (UIButton*)sender;
	
	SelectViewController *sV = [[SelectViewController alloc]init];
	sV.delegate = self;
	sV.tag = ENUM_FAMILYSELECT;
	[sV setOpt:(NSMutableArray*)[familyList allKeys]];
	pop = [[UIPopoverController alloc]initWithContentViewController:sV];
	pop.delegate = self;
	pop.popoverContentSize = sV.view.frame.size;
	[pop presentPopoverFromRect:wrkBtn.frame inView:_orderHeader permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	
}

//商品ファミリ（カテゴリ）選択　/ ソート順指定　デリゲート
-(void)didSelectOption:(int)index tag:(int)tag
{
	
	[pop dismissPopoverAnimated:YES];
	if (![self isNull:pop]){
		pop = nil;
	}
	
	
	if ( tag == ENUM_FAMILYSELECT ) {
    
		//商品ファミリ選択の場合
		if ( index >= [familyList count]) {
			return;
		}
    
		NSArray *keyList = [familyList allKeys];
		if ( ![self isNull:[keyList objectAtIndex:index]] ){
			
			//ファミリー選択
			[self selectFamily:[keyList objectAtIndex:index]];
		}
	}
	else {
    
		//ソート順指定の場合
		if ( index >= [productList count]) {
			return;
		}
    
		Product *pd = [productList objectAtIndex:index];
		NSLog(@"NAME:%@",pd.productName);
    
		//PopOverで選んだ商品のソート順(order__c)を変更する。
		[self changeSortNumber:pd.productId number:selectedItemOder];
		
		//ローディングアラート表示
    NSLog(@"loading %d", __LINE__);
		[self alertShow];
    
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.0]];
    
		//表示商品クリア
		dispProductCount = 0;
		[self clearSubView:scrl];
		
		//商品リスト取得
		[self getProductList:selectedFamily];
	}
}


-(void)selectFamily:(NSString*)famName
{
  //if([selectedFamily isEqualToString:famName]) return;
  NSLog(@"selectedFamily : %@",selectedFamily);
  NSLog(@"famName : %@",famName);
  
	selectedFamily = famName;
	
	//タイトル設定
	[_ordersLabel setText:[ famName stringByAppendingFormat:@"%@%@",[pData getDataForKey:@"DEFINE_STORORDER_LABEL_CONNECT"],self.title]];
	[_ordersLabel sizeToFit];
	
	//ローディングアラート表示
  //	[self alertShow];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	
	//表示商品クリア
	dispProductCount = 0;
	[self clearSubView:scrl];
	
	//商品リスト取得
	[self getProductList:selectedFamily];
	
}

//商品カテゴリが(family)の商品を検索する
-(void)getProductList:(NSString*)family
{
	NSString *query = [NSString stringWithFormat:@"SELECT Id,ProductCode,Name,Family,Description,URL__c ,order__c FROM product2 WHERE IsActive=true AND Family = '%@'  ORDER BY order__c",family];
	SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:query];
	[[SFRestAPI sharedInstance] sendRESTRequest:request
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      
                                      //エラーアラート
                                      alertView = [[UIAlertView alloc]
                                                   initWithTitle:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEM_ERROR"]
                                                   message:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEM_MESSAGE_ERROR"]
                                                   delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEM_OK_ERROR"], nil ];
                                      [alertView show];
                                    }
                                completeBlock:^(id jsonResponse){
                                  productList = [NSMutableArray array];
                                  [carousel reloadData];
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  NSLog(@"%@",dict);
                                  NSArray *records= [dict objectForKey:@"records"];
                                  for ( int i = 0; i < [records count]; i++ ){
                                    NSDictionary *rec = [records objectAtIndex:i];
                                    
                                    Product *pd = [[Product alloc]init];
                                    NSString *pId = [rec objectForKey:@"Id"];
                                    NSString *pDesc = [rec objectForKey:@"Description"];
                                    NSString *pName = [rec objectForKey:@"Name"];
                                    NSString *pFamily = [rec objectForKey:@"Family"];
                                    NSString *pMovie = [rec objectForKey:@"URL__c"];
                                    NSNumber *pSortOrder = [rec objectForKey:@"order__c"];
                                    
                                    pd.productId = pId;
                                    pd.productName = pName;
                                    pd.productFamily = pFamily;
                                    pd.description = pDesc;
                                    pd.movieURL = pMovie;
                                    pd.sortOrder = [pSortOrder intValue];
                                    pd.index = i;
                                    
                                    //商品リストに追加
                                    [productList addObject:pd];
                                    NSLog(@"%d",[productList count]);
                                  }
                                  
                                  NSString *where = @"";
                                  int loopMax = [productList count];
                                  int loopCnt = 0;
                                  for ( Product *tempPd in productList ) {
                                    where = [where stringByAppendingString:[NSString stringWithFormat:@"Product2Id='%@'",tempPd.productId ]];
                                    if ( loopCnt++ != loopMax - 1 ){
                                      where = [where stringByAppendingString:@" OR "];
                                    }
                                  }
                                  
                                  //価格表ID、単価を収得
                                  NSString *query = [NSString stringWithFormat:@"SELECT Id,UnitPrice,Product2Id FROM PricebookEntry WHERE %@ ",where];
                                  SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:query];
                                  [[SFRestAPI sharedInstance] sendRESTRequest:request
                                                                    failBlock:^(NSError *e) {
                                                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                                                      
                                                                      //エラーアラート
                                                                      alertView = [[UIAlertView alloc]
                                                                                   initWithTitle:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMID_ERROR"]
                                                                                   message:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMID_MESSAGE_ERROR"]
                                                                                   delegate:nil
                                                                                   cancelButtonTitle:nil
                                                                                   otherButtonTitles:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMID_OK_ERROR"], nil ];
                                                                      [alertView show];
                                                                    }
                                                                completeBlock:^(id jsonResponse){
                                                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                                                  NSLog(@"%@",dict);
                                                                  NSArray *records= [dict objectForKey:@"records"];
                                                                  for ( int i = 0; i < [ records count]; i++ ) {
                                                                    NSDictionary *rec = [records objectAtIndex:i];
                                                                    NSString *priceBookEntryId = [rec objectForKey:@"Id"];
                                                                    NSNumber *unitPrice = [rec objectForKey:@"UnitPrice"];
                                                                    NSString *prId = [rec objectForKey:@"Product2Id"];
                                                                    
                                                                    for ( int ii = 0; ii < [productList count]; ii++ ){
                                                                      Product *tempPd = [productList objectAtIndex:ii];
                                                                      if ( [tempPd.productId isEqualToString:prId]){
                                                                        tempPd.priceBookEntryId = priceBookEntryId;
                                                                        tempPd.price = [unitPrice intValue];
                                                                        break;
                                                                      }
                                                                    }
                                                                  }
                                                                  //商品画像取得
                                                                  [self getProductsImage];
                                                                  
                                                                  //在庫・入荷予定を取得
                                                                  [self getProductStocks:productList];
                                                                }
                                   ];
                                  
                                  //最初の商品のグラフを表示
                                  currentPrd = [productList objectAtIndex:0];
                                  [self dispGraphs:currentPrd];
                                  if(alertView.visible) {
                                    [alertView dismissWithClickedButtonIndex:0 animated:NO];
                                  }
                                }
	 ];
}


//商品の在庫、入荷予定日を取得
-(void)getProductStock:(Product*)pd  drawGraph:(BOOL)draw
{
	
	//過去の在庫数取得
	NSString *query = [NSString stringWithFormat:@"SELECT Id, Name ,product__c,date__c,quantity__c FROM stock__c  WHERE product__c ='%@' AND date__c <= N_DAYS_AGO:0 ORDER BY date__c DESC",pd.productId];
	SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:query];
	[[SFRestAPI sharedInstance] sendRESTRequest:request
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      inWait = NO;
                                      
                                      //エラーアラート
                                      alertView = [[UIAlertView alloc]
                                                   initWithTitle:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMNON_ERROR"]
                                                   message:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMNON_MESSAGE_ERROR"]
                                                   delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMNON_OK_ERROR"], nil ];
                                      [alertView show];
                                    }
                                completeBlock:^(id jsonResponse){
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  NSLog(@"482 %@",dict);
                                  
                                  NSNumber *recCount = [dict objectForKey:@"totalSize"];
                                  
                                  //取得レコードがあれば、先頭の一件（最新在庫）のみを読んで在庫数確定
                                  if ( [recCount intValue] ){
                                    NSArray *records = [dict objectForKey:@"records"];
                                    NSDictionary *rec = [records objectAtIndex:0];
                                    NSString *date = [rec objectForKey:@"date__c"];
                                    NSNumber *quantity = [rec objectForKey:@"quantity__c"];
                                    
                                    pd.stockArray = [NSMutableArray array];
                                    pd.stockDateArray = [NSMutableArray array];
                                    
                                    //最新の在庫数とその日付を保存
                                    pd.newestStockCount = (int)[quantity doubleValue];
                                    NSDateFormatter* fmt= [[NSDateFormatter alloc] init];
                                    [fmt setDateFormat:@"YYYY-MM-dd"];
                                    pd.newestStockDate = [fmt dateFromString:date];
                                    
                                    
                                    //グラフ表示用データ
                                    //在庫取得日
                                    //				NSDate *tmpDate = [fmt dateFromString:date];
                                    
                                    //在庫取得日は、今日の日付とする
                                    NSDate *tmpDate = [NSDate date];
                                    [pd.stockDateArray addObject:tmpDate];
                                    
                                    //在庫数
                                    [pd.stockArray addObject:quantity];
                                  }
                                  [self getFutureStock:pd drawGraph:draw];
                                  if(alertView.visible) {
                                    [alertView dismissWithClickedButtonIndex:0 animated:NO];
                                  }
                                }
   ];
}

//商品の在庫、入荷予定日を取得
-(void)getProductStocks:(NSArray*)pdArray
{
	NSString *where = @"";
	int loopMax = [pdArray count];
	int loopCnt = 0;
	for ( Product *tempPd in pdArray ) {
		where = [where stringByAppendingString:[NSString stringWithFormat:@"product__c='%@'",tempPd.productId ]];
		if ( loopCnt++ != loopMax - 1 ){
			where = [where stringByAppendingString:@" OR "];
		}
	}
  
	//過去の在庫数取得
	NSString *query = [NSString stringWithFormat:@"SELECT Id, Name ,product__c,date__c,quantity__c FROM stock__c  WHERE (%@) AND date__c <= N_DAYS_AGO:0 ORDER BY date__c DESC",where];
	SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:query];
	[[SFRestAPI sharedInstance] sendRESTRequest:request
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      inWait = NO;
                                      
                                      //エラーアラート
                                      alertView = [[UIAlertView alloc]
                                                   initWithTitle:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMNON_ERROR"]
                                                   message:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMNON_MESSAGE_ERROR"]
                                                   delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMNON_OK_ERROR"], nil ];
                                      [alertView show];
                                    }
                                completeBlock:^(id jsonResponse){
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  NSLog(@"554 %@",dict);
                                  
                                  NSNumber *recCount = [dict objectForKey:@"totalSize"];
                                  
                                  //取得レコードがあれば、先頭の一件（最新在庫）のみを読んで在庫数確定
                                  if ( [recCount intValue] ){
                                    
                                    NSArray *records = [dict objectForKey:@"records"];
                                    NSDictionary *rec;
                                    for ( Product *tempPd in pdArray ) {
                                      
                                      for ( int i = 0; i < [records count]; i++ ) {
                                        
                                        rec = [records objectAtIndex:i];
                                        NSString *prId = [rec objectForKey:@"product__c"];
                                        if ( [tempPd.productId isEqualToString:prId] ){
                                          NSString *date = [rec objectForKey:@"date__c"];
                                          NSNumber *quantity = [rec objectForKey:@"quantity__c"];
                                          
                                          tempPd.stockArray = [NSMutableArray array];
                                          tempPd.stockDateArray = [NSMutableArray array];
                                          
                                          //最新の在庫数とその日付を保存
                                          tempPd.newestStockCount = (int)[quantity doubleValue];
                                          NSDateFormatter* fmt= [[NSDateFormatter alloc] init];
                                          [fmt setDateFormat:@"YYYY-MM-dd"];
                                          tempPd.newestStockDate = [fmt dateFromString:date];
                                          
                                          //グラフ表示用データ
                                          //在庫取得日
                                          //				NSDate *tmpDate = [fmt dateFromString:date];
                                          
                                          //在庫取得日は、今日の日付とする
                                          NSDate *tmpDate = [NSDate date];
                                          [tempPd.stockDateArray addObject:tmpDate];
                                          
                                          //在庫数
                                          [tempPd.stockArray addObject:quantity];
                                          if(tempPd.badgeValue==nil || [tempPd.badgeValue isEqualToString:@""]){
                                            tempPd.badgeValue = [NSString stringWithFormat:@"%@", quantity];
                                          }
                                          //NSLog(@"tempPd.badgeValue %@", tempPd.badgeValue);
                                        }
                                      }
                                      [carousel reloadData];
                                    }
                                    [self getFutureStocks:productList];
                                  }
                                }
	 ];
}



-(void)getFutureStocks:(NSArray*)pdArray
{
	NSString *where = @"";
	int loopMax = [pdArray count];
	int loopCnt = 0;
	for ( Product *tempPd in pdArray ) {
		where = [where stringByAppendingString:[NSString stringWithFormat:@"product__c='%@'",tempPd.productId ]];
		if ( loopCnt++ != loopMax - 1 ){
			where = [where stringByAppendingString:@" OR "];
		}
	}
	
	//将来の在庫数取得
	NSString *query2 = [NSString stringWithFormat:@"SELECT Id, Name ,product__c,date__c,quantity__c FROM stock__c  WHERE (%@) AND date__c > N_DAYS_AGO:0 ORDER BY date__c ASC",where];
	SFRestRequest *request2 = [[SFRestAPI sharedInstance] requestForQuery:query2];
	[[SFRestAPI sharedInstance] sendRESTRequest:request2
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      
                                      //エラーアラート
                                      alertView = [[UIAlertView alloc]
                                                   initWithTitle:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEPRE_ERROR"]
                                                   message:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMPRE_MESSAGE_ERROR"]
                                                   delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMPRE_OK_ERROR"], nil ];
                                      [alertView show];
                                    }
                                completeBlock:^(id jsonResponse){
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  NSLog(@"636 %@",dict);
                                  
                                  NSNumber *recCount = [dict objectForKey:@"totalSize"];
                                  
                                  //取得レコードがあれば、直近で在庫数が＋(プラス)になる日付を取得
                                  bool found = NO;
                                  Product *tempPd;
                                  for ( int ii = 0; ii < [productList count]; ii++ ){
                                    tempPd = [productList objectAtIndex:ii];
                                    
                                    if ( [recCount intValue] ){
                                      NSArray *records = [dict objectForKey:@"records"];
                                      for ( int i = 0; i < [records count]; i++ ) {
                                        NSDictionary *rec = [records objectAtIndex:i];
                                        NSString *prId = [rec objectForKey:@"product__c"];
                                        if (![tempPd.productId isEqualToString:prId]){
                                          continue;
                                        }
                                        
                                        NSNumber *quantity = [rec objectForKey:@"quantity__c"];
                                        NSString *date = [rec objectForKey:@"date__c"];
                                        if ( [quantity intValue] >= 1 ) {
                                          NSDateFormatter* fmt= [[NSDateFormatter alloc] init];
                                          
                                          //直近の入荷日（オーダー詳細画面で使用）
                                          [fmt setDateFormat:@"YYYY-MM-dd"];
                                          if ( found  == NO ) {
                                            tempPd.arrivalStockCount = (int)[quantity doubleValue];
                                            tempPd.arrivalStockDate = [fmt dateFromString:date];
                                            found = YES;
                                          }
                                          
                                          //グラフ表示用データ
                                          if ([tempPd.stockDateArray count]<6 ) {
                                            
                                            //在庫取得日
                                            NSDate *tmpDate = [fmt dateFromString:date];
                                            
                                            [tempPd.stockDateArray addObject:tmpDate];
                                            
                                            //在庫数
                                            [tempPd.stockArray addObject:quantity];
                                          }
                                        }
                                      }
                                    }
                                  }
                                  if(alertView.visible) {
                                    [alertView dismissWithClickedButtonIndex:0 animated:NO];
                                  }
                                }
	 ];
}
-(void)getFutureStock:(Product*)pd drawGraph:(BOOL)draw
{
	//将来の在庫数取得
	NSString *query2 = [NSString stringWithFormat:@"SELECT Id, Name ,product__c,date__c,quantity__c FROM stock__c  WHERE product__c ='%@' AND date__c > N_DAYS_AGO:0 ORDER BY date__c ASC",pd.productId];
	SFRestRequest *request2 = [[SFRestAPI sharedInstance] requestForQuery:query2];
	[[SFRestAPI sharedInstance] sendRESTRequest:request2
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      
                                      //エラーアラート
                                      alertView = [[UIAlertView alloc]
                                                   initWithTitle:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEPRE_ERROR"]
                                                   message:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMPRE_MESSAGE_ERROR"]
                                                   delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMPRE_OK_ERROR"], nil ];
                                      [alertView show];
                                    }
                                completeBlock:^(id jsonResponse){
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  NSLog(@"710 %@",dict);
                                  
                                  NSNumber *recCount = [dict objectForKey:@"totalSize"];
                                  
                                  //取得レコードがあれば、直近で在庫数が＋(プラス)になる日付を取得
                                  bool found = NO;
                                  if ( [recCount intValue] ){
                                    NSArray *records = [dict objectForKey:@"records"];
                                    for ( int i = 0; i < [records count]; i++ ) {
                                      NSDictionary *rec = [records objectAtIndex:i];
                                      NSNumber *quantity = [rec objectForKey:@"quantity__c"];
                                      NSString *date = [rec objectForKey:@"date__c"];
                                      if ( [quantity intValue] >= 1 ) {
                                        NSDateFormatter* fmt= [[NSDateFormatter alloc] init];
                                        
                                        //直近の入荷日（オーダー詳細画面で使用）
                                        [fmt setDateFormat:@"YYYY-MM-dd"];
                                        if ( found  == NO ) {
                                          pd.arrivalStockCount = (int)[quantity doubleValue];
                                          pd.arrivalStockDate = [fmt dateFromString:date];
                                          found = YES;
                                        }
                                        
                                        //グラフ表示用データ
                                        if ([pd.stockDateArray count]<6 ) {
                                          
                                          //在庫取得日
                                          NSDate *tmpDate = [fmt dateFromString:date];
                                          
                                          [pd.stockDateArray addObject:tmpDate];
                                          
                                          //在庫数
                                          [pd.stockArray addObject:quantity];
                                        }
                                      }
                                    }
                                  }
                                  if ( draw == YES ) {
                                    [self setupStockGraph:pd];
                                  }
                                }
	 ];
}

-(void)getSales:(Product*)prd
{
	//保存配列初期化
	itemSales = [NSMutableDictionary dictionary];
	totalSales = [NSMutableDictionary dictionary];
	
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
  
	NSString *dateStr = [NSString stringWithFormat:@"%d-%02d-%02d",year,month,day];
	NSString *query = [NSString stringWithFormat:@"SELECT PricebookEntryId,CreatedDate,TotalPrice,status__c ,Opportunity.CloseDate ,Opportunity.AccountId FROM OpportunityLineItem  WHERE Opportunity.CloseDate >= %@ AND Opportunity.AccountId = '%@' ORDER BY Opportunity.CloseDate DESC",dateStr,cp.company_id];
	SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:query];
  
  NSLog(@"%@",query);
	[[SFRestAPI sharedInstance] sendRESTRequest:request
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      if(alertView.visible) {
                                        [alertView dismissWithClickedButtonIndex:0 animated:NO];
                                      }
                                      
                                      //エラーアラート
                                      alertView = [[UIAlertView alloc]
                                                   initWithTitle:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMSALE_ERROR"]
                                                   message:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMSALE_MESSAGE_ERROR"]
                                                   delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMSALE_OK_ERROR"], nil ];
                                      [alertView show];
                                      return;
                                    }
                                completeBlock:^(id jsonResponse){
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  NSLog(@"%@",dict);
                                  NSArray *records = [dict objectForKey:@"records"];
                                  NSDateFormatter* fmt= [[NSDateFormatter alloc] init];
                                  [fmt setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.000Z"];
                                  
                                  for ( int i = 0; i < [records count]; i++ ) {
                                    NSDictionary *rec = [records objectAtIndex:i];
                                    
                                    //年・月を辞書のキー名にする
                                    NSMutableArray  *dateArr = [rec objectForKey:@"Opportunity"];
                                    NSString *dateStr = [dateArr valueForKey:@"CloseDate"];
                                    
                                    NSString *keyName = [dateStr substringToIndex:7];
                                    
                                    //価格表上のID
                                    NSString *pId = [rec objectForKey:@"PricebookEntryId"];
                                    
                                    //売り上げ
                                    NSNumber *sales = [rec objectForKey:@"TotalPrice"];
                                    
                                    //総売上保存
                                    NSNumber *dat = [totalSales objectForKey:keyName];
                                    if ([self isNull:dat]) {
                                      [totalSales setObject:sales forKey:keyName];
                                    }
                                    else {
                                      
                                      //年・月をキーとするデータがあれば、それに加算する。
                                      float val = [dat floatValue];
                                      val += [sales floatValue];
                                      dat = [NSNumber numberWithFloat:val];
                                      [totalSales setObject:dat forKey:keyName];
                                    }
                                    
                                    if ([pId isEqualToString:prd.priceBookEntryId]) {
                                      NSNumber *dat = [itemSales objectForKey:keyName];
                                      if ([self isNull:dat]) {
                                        [itemSales setObject:sales forKey:keyName];
                                      }
                                      else {
                                        
                                        //年・月をキーとするデータがあれば、それに加算する。
                                        float val = [dat floatValue];
                                        val += [sales floatValue];
                                        dat = [NSNumber numberWithFloat:val];
                                        [itemSales setObject:dat forKey:keyName];
                                      }
                                    }
                                  }
                                  [self setupSalesGraph:prd];
                                  if(alertView.visible) {
                                    [alertView dismissWithClickedButtonIndex:0 animated:NO];
                                  }
                                }
	 ];
}


//画像取得呼び出し
-(void)getProductsImage
{
	//画像読み込み済み数を初期化
	imgLoadCount =0;
  
	//画像読みk見
  //	for (int i = 0; i < [productList count]; i++){
  //		[self getProductImage:[productList objectAtIndex:i]];
  //	}
  
	[self getProductsImage:productList];
  
}

//画像取得
-(void)getProductsImage:(NSMutableArray*)pdArray
{
	NSString *where = @"";
	int loopMax = [pdArray count];
	int loopCnt = 0;
	for ( Product *tempPd in pdArray ) {
    
		//画像URL初期化
		tempPd.imgURLArray = [NSMutableArray array];
		tempPd.imgNameArray = [NSMutableArray array];
    tempPd.imgIdArray = [NSMutableArray array];
    tempPd.imgDateArray = [NSMutableArray array];
    
		where = [where stringByAppendingString:[NSString stringWithFormat:@"ParentId='%@'",tempPd.productId ]];
		if ( loopCnt++ != loopMax - 1 ){
			where = [where stringByAppendingString:@" OR "];
		}
    
    // キャッシュ用ディレクトリ生成
    [um makeDir:tempPd.productId];
	}
	
	
	//NSString *query = [NSString stringWithFormat:@"SELECT ParentId,Name,Body,BodyLength, Id, LastModifiedDate FROM Attachment WHERE %@ ORDER BY CreatedDate DESC",where];
  // main.jpgが最後になるように
  NSString *query = [NSString stringWithFormat:@"SELECT ParentId,Name,Body,BodyLength, Id, LastModifiedDate FROM Attachment WHERE %@ ORDER BY Name ASC",where];
  //NSLog(@"query 894 : %@", query);
	SFRestRequest *req = [[SFRestAPI sharedInstance] requestForQuery:query];
	[[SFRestAPI sharedInstance] sendRESTRequest:req
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      alertView = [[UIAlertView alloc]
                                                   initWithTitle:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMIMAGE_ERROR"]
                                                   message:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMIMAGE_MESSAGE_ERROR"]
                                                   delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMIMAGE_OK_ERROR"], nil ];
                                      [alertView show];
                                    }
                                completeBlock:^(id jsonResponse){
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  NSLog(@"%@",dict);
                                  
                                  //アラート表示
                                  //		[self alertShow];
                                  //		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
                                  
                                  //受信データクリア
                                  rcvData = [[NSMutableData alloc]init];
                                  
                                  NSArray *records = [dict objectForKey:@"records"];
                                  for ( int i = 0; i< [records count]; i++ ){
                                    
                                    NSDictionary *rec = [records objectAtIndex:i];
                                    NSString *url = [rec objectForKey:@"Body"];
                                    NSString *name = [rec objectForKey:@"Name"];
                                    NSString *bodyLength = [rec objectForKey:@"BodyLength"];
                                    NSString *prId = [rec objectForKey:@"ParentId"];
                                    NSString *Id = [rec objectForKey:@"Id"];
                                    NSString *Date = [rec objectForKey:@"LastModifiedDate"];
                                    
                                    // 画像のみ
                                    if(!(([um isInclude:[name uppercaseString]cmp:@"MAIN."]
                                          ||[um isInclude:name cmp:@"01."]
                                          ||[um isInclude:name cmp:@"02."])
                                         && [um isInclude:[name uppercaseString] cmp:@"JPG"]
                                         )) continue;
                                    
                                    int bSize = [bodyLength intValue];
                                    NSLog(@"%d : %@", __LINE__, url);
                                    NSLog(@"bSize : %d : %d", __LINE__, bSize );
                                    
                                    Product *tempPd = [[Product alloc]init];
                                    BOOL found = NO;
                                    for ( int ii = 0; ii <[productList count]; ii++ ){
                                      tempPd = [productList objectAtIndex:ii];
                                      if ( [tempPd.productId isEqualToString:prId]) {
                                        found = YES;
                                        break;
                                      }
                                    }
                                    if ( found == NO){
                                      continue;
                                    }
                                    
                                    //画像サイズが閾値より大きい場合は読み込まない
                                    if ( MAXLOADINGSIZE <= bSize ) {
                                      [tempPd.imgURLArray addObject:@"sizeover"];
                                      [tempPd.imgNameArray addObject:@"sizeover"];
                                      [tempPd.imgDateArray addObject:@"sizeover"];
                                      [tempPd.imgIdArray addObject:@"sizeover"];
                                      continue;
                                    }
                                    
                                    BOOL searchResult = [self isInclude:[name uppercaseString]cmp:@"MAIN."];
                                    
                                    if ( [tempPd.imgURLArray count] <= 3 ){
                                      [tempPd.imgURLArray addObject:url];
                                      [tempPd.imgNameArray addObject:name];
                                      [tempPd.imgDateArray addObject:Date];
                                      [tempPd.imgIdArray addObject:Id];
                                    }
                                    
                                    if ( searchResult == YES ) {
                                      
                                      if([um existProductFile:prId name:name]){
                                        UIImage *img = [[UIImage alloc]initWithData:[um loadProductFile:prId name:name]];
                                        //画像保存
                                        tempPd.image = img;
                                        if (++imgLoadCount == [productList count]) {
                                          //[self dispProducts];
                                          [carousel reloadData];
                                        }
                                      }else{
                                      
                                        //商品画像表示
                                        
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
                                        rcvData = [NSURLConnection sendSynchronousRequest:requestDoc returningResponse:&resp error:&err];
                                        
                                        if ( !err ){
                                          if ( searchResult == YES ){
                                            UIImage *img = [[UIImage alloc]initWithData:rcvData];
                                            
                                            //画像保存
                                            tempPd.image = img;
                                            if (++imgLoadCount == [productList count]) {
                                              //[self dispProducts];
                                              [carousel reloadData];
                                            }
                                            
                                            // ファイルを保存
                                            [um saveProductFile:prId name:name data:rcvData];
                                          }
                                        }
                                        else{
                                          alertView = [[UIAlertView alloc]
                                                       initWithTitle:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMIMAGE_ERROR"]
                                                       message:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMIMAGE_MESSAGE_ERROR"]
                                                       delegate:nil
                                                       cancelButtonTitle:nil
                                                       otherButtonTitles:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMIMAGE_OK_ERROR"], nil ];
                                          [alertView show];
                                        }
                                      }
                                    }
                                  }
                                  // main.jpgがない場合にnoimageを代用
                                  for (Product *pd in productList ){
                                    NSLog(@"%d productName : %@", __LINE__, pd.productName);
                                    
                                    // main.jpg がない場合の処理
                                    NSData *imgData = UIImageJPEGRepresentation(pd.image, 0);
                                    //NSLog(@"Size of Image(bytes):%d",[imgData length]);
                                    
                                    if([imgData length]>0) continue;
                                    
                                    // 代わりの画像を指定
                                    pd.image = [UIImage imageNamed:@"product_noimage.png"];
                                    [pd.imgURLArray addObject:@"product_noimage.jpg"];
                                    [pd.imgNameArray addObject:@"main.jpg"];
                                    [pd.imgDateArray addObject:pd.image];
                                    [pd.imgIdArray addObject:@"product_noimage.png"];
                                  }
                                  [carousel reloadData];
                                }];
}


//画像取得
-(void)getProductImage:(Product*)pd
{
	//NSString *query = [NSString stringWithFormat:@"SELECT Name,Body,BodyLength, Id, LastModifiedDate FROM Attachment WHERE ParentId='%@' ORDER BY Name, CreatedDate DESC",pd.productId];
   // main.jpgが最後になるように
  	NSString *query = [NSString stringWithFormat:@"SELECT Name,Body,BodyLength, Id, LastModifiedDate FROM Attachment WHERE ParentId='%@' ORDER BY Name ASC",pd.productId];;
	SFRestRequest *req = [[SFRestAPI sharedInstance] requestForQuery:query];
	[[SFRestAPI sharedInstance] sendRESTRequest:req
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      alertView = [[UIAlertView alloc]
                                                   initWithTitle:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMIMAGE_ERROR"]
                                                   message:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMIMAGE_MESSAGE_ERROR"]
                                                   delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMIMAGE_OK_ERROR"], nil ];
                                      [alertView show];
                                    }
                                completeBlock:^(id jsonResponse){
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  NSLog(@"%@",dict);
                                  
                                  //アラート表示
                                  //		[self alertShow];
                                  [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
                                  
                                  //受信データクリア
                                  rcvData = [[NSMutableData alloc]init];
                                  
                                  //画像URL初期化
                                  pd.imgURLArray = [NSMutableArray array];
                                  pd.imgNameArray = [NSMutableArray array];
                                  pd.imgIdArray = [NSMutableArray array];
                                  pd.imgDateArray = [NSMutableArray array];
                                  
                                  NSArray *records = [dict objectForKey:@"records"];
                                  for ( int i = 0,addCnt = 0; i< [records count]; i++ ){
                                    
                                    NSDictionary *rec = [records objectAtIndex:i];
                                    NSString *url = [rec objectForKey:@"Body"];
                                    NSString *name = [rec objectForKey:@"Name"];
                                    NSString *bodyLength = [rec objectForKey:@"BodyLength"];
                                    NSString *Id = [rec objectForKey:@"Id"];
                                    NSString *Date = [rec objectForKey:@"LastModifiedDate"];
                                    
                                    // 画像のみ
                                    if(!(([um isInclude:[name uppercaseString]cmp:@"MAIN."]
                                          ||[um isInclude:name cmp:@"01."]
                                          ||[um isInclude:name cmp:@"02."])
                                         && [um isInclude:[name uppercaseString] cmp:@"JPG"]
                                         )) continue;
                                    
                                    int bSize = [bodyLength intValue];
                                    NSLog(@"%@",url);
                                    
                                    
                                    //画像サイズが閾値より大きい場合は読み込まない
                                    if ( MAXLOADINGSIZE <= bSize ) {
                                      [pd.imgURLArray addObject:@"sizeover"];
                                      [pd.imgNameArray addObject:@"sizeover"];
                                      [pd.imgDateArray addObject:@"sizeover"];
                                      [pd.imgIdArray addObject:@"sizeover"];
                                      continue;
                                    }
                                    
                                    BOOL searchResult = [self isInclude:[name uppercaseString]cmp:@"MAIN."];
                                    
                                    if ( addCnt++ <= 3 ){
                                      [pd.imgURLArray addObject:url];
                                      // 保存用配列
                                      [pd.imgNameArray addObject:name];
                                      [pd.imgDateArray addObject:Date];
                                      [pd.imgIdArray addObject:Id];
                                    }
                                    NSLog(@"pd.imgNameArray %d %@", __LINE__, pd.imgNameArray);
                                    
                                    if ( searchResult == YES ) {
                                      
                                      //ロゴ表示
                                      
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
                                      rcvData = [NSURLConnection sendSynchronousRequest:requestDoc returningResponse:&resp error:&err];
                                      
                                      if ( !err ){
                                        if ( searchResult == YES ){
                                          UIImage *img = [[UIImage alloc]initWithData:rcvData];
                                          //画像を配列に保存
                                          pd.image = img;
                                          if (++imgLoadCount == [productList count]) {
                                            [self dispProducts];
                                          }
                                        }
                                      }
                                      else{
                                        alertView = [[UIAlertView alloc]
                                                     initWithTitle:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMIMAGE_ERROR"]
                                                     message:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMIMAGE_MESSAGE_ERROR"]
                                                     delegate:nil
                                                     cancelButtonTitle:nil
                                                     otherButtonTitles:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMIMAGE_OK_ERROR"], nil ];
                                        [alertView show];
                                      }
                                    }
                                  }
                                  
                                  // main.jpgがない場合にnoimageを代用
                                    NSLog(@"%d productName : %@", __LINE__, pd.productName);
                                    
                                    // main.jpg がない場合の処理
                                    NSData *imgData = UIImageJPEGRepresentation(pd.image, 0);
                                    //NSLog(@"Size of Image(bytes):%d",[imgData length]);
                                    
                                  if(![imgData length]>0){
                                    // 代わりの画像を指定
                                    pd.image = [UIImage imageNamed:@"product_noimage.png"];
                                    [pd.imgURLArray addObject:@"product_noimage.jpg"];
                                    [pd.imgNameArray addObject:@"main.jpg"];
                                    [pd.imgDateArray addObject:pd.image];
                                    [pd.imgIdArray addObject:@"product_noimage.png"];
                                  }
                                  [carousel reloadData];
                                }];
}

-(void)dispProducts
{
	for ( int i = 0 ;i < [productList count]; i++) {
		[self productDisp:[productList objectAtIndex:i]];
		NSLog(@"%d:%d",i,((Product*)[productList objectAtIndex:i]).sortOrder  );
	}
	if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
}


// ローディングアラートの表示
-(void)alertShow
{
	// ローディングアラートを生成
	alertView = [[UIAlertView alloc] initWithTitle:[pData getDataForKey:@"DEFINE_STORORDER_LOADING_TITLE"] message:nil
                                        delegate:nil cancelButtonTitle:nil otherButtonTitles:NULL];
	progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
	progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	[alertView addSubview:progress];
	[progress startAnimating];
	
	[NSTimer scheduledTimerWithTimeInterval:20.0f
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

-(void)viewDidAppear:(BOOL)animated
{
}


//CompanyProfileで住所タップのデリゲート
-(void)didAddressTaped
{
	//小画面表示中は抜ける
	if ( dispChildScreen == YES) {
		return;
	}
	
	StoreMapViewController *mapVC;
	mapVC = [[StoreMapViewController alloc]initWithNibName:@"StoreMapViewController" bundle:[NSBundle mainBundle] company:cp ];
	[self.navigationController pushViewController:mapVC animated:NO];
}

-(void)productDisp:(Product*)pd
{
	static const float MAXIMAGE_X = 160;
	static const float MAXIMAGE_Y = 120;
	
	CGRect rect;
	UIImageView *productImg = [[UIImageView alloc]init];
	rect.size.width = MAXIMAGE_X;
	rect.size.height = MAXIMAGE_Y;
	rect.origin.x = 0;
	rect.origin.y = 0;
	UIImage *resize = [self resizeImage:pd.image Rect:rect];
	productImg.image = resize;
	rect.size.width = resize.size.width;
	rect.size.height = resize.size.height;
	rect.origin.x = ( dispProductCount * MAXIMAGE_X + 30 ) + (MAXIMAGE_X - resize.size.width) / 2;
	rect.origin.y = 10;
	productImg.frame = rect;
	productImg.tag = pd.index;
	[scrl addSubview:productImg];
  
	dTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapDetect:)];
	productImg.userInteractionEnabled = YES;
	dTap.numberOfTapsRequired = 2;
	[productImg addGestureRecognizer:dTap];
  
	sTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapDetect:)];
	sTap.numberOfTapsRequired = 1;
	[productImg addGestureRecognizer:sTap];
  
	lt= [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longtap:)];
	lt.numberOfTapsRequired = 0;
	lt.minimumPressDuration = 1;
	[productImg addGestureRecognizer:lt];
	
	//設定済みの発注量を読み込み
	OrderInfo *od = [orderArray objectForKey:pd.productId];
	int qty = od.quanty;
	
	UIButton *qBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  //	qBtn = [self setBtn:qBtn num:dispProductCount];
	rect.size.width = 100;
	rect.size.height = 30;
	rect.origin.x = ( dispProductCount * MAXIMAGE_X + 30 ) + (MAXIMAGE_X - rect.size.width) / 2;
	rect.origin.y = 140;
	qBtn.frame = rect;
	qBtn.titleLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:14];
	[qBtn setTitle:[NSString stringWithFormat:[pData getDataForKey:@"DEFINE_STORORDER_UNIT_TITLE"],qty] forState:UIControlStateNormal];
	[qBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -40,0,-40)];
	[qBtn addTarget:self action:@selector(btnPush:) forControlEvents:UIControlEventTouchUpInside];
	qBtn.tag = pd.index;
	
	[scrl addSubview:productImg];
	[scrl addSubview:qBtn];
  
	//スクロール範囲設定
	CGSize siz = scrl.contentSize;
	siz.width = ( productImg.frame.origin.x + productImg.frame.size.width+100);
	[scrl setContentSize:siz];
	dispProductCount++;
}

//ロングタップ検出
-(void)longtap:(id)sender
{
	static BOOL reenter = NO;
	
	//小画面表示中は抜ける
	if ( dispChildScreen == YES) {
		return;
	}
	
	reenter = ( reenter == NO) ? YES : NO;
	
	if ( reenter == NO) {
		return;
	}
	if ([pop isPopoverVisible] ){
		return;
	}
	
	UILongPressGestureRecognizer *recognizer = (UILongPressGestureRecognizer*) sender;
	NSLog(@"LONGTAP :%d",recognizer.view.tag);
  
	Product *pd = [productList objectAtIndex:recognizer.view.tag];
	NSLog(@"NAME:%@  SORT:%d",pd.productName,pd.sortOrder);
  
	//ロングタップされた商品の表示順(order__c)を保存
  //	selectedItemOder = pd.sortOrder;
	selectedItemOder = pd.index+1;
	
	NSMutableArray *optList = [NSMutableArray array];
	NSMutableArray *imgList = [NSMutableArray array];
	for ( int i = 0; i < [productList count]; i++ ){
		Product *tmpPd = [productList objectAtIndex:i];
		[optList addObject:tmpPd.productName];
		[imgList addObject:tmpPd.image];
	}
  
	SelectViewController *sV = [[SelectViewController alloc]init];
	sV.delegate = self;
	sV.tag = ENUM_SORTORDER;
	[sV setOpt:optList];
	[sV setImg:imgList];
	[sV setSize:CGSizeMake(300,500)];
	pop = [[UIPopoverController alloc]initWithContentViewController:sV];
	pop.delegate = self;
	pop.popoverContentSize = sV.view.frame.size;
	//[pop presentPopoverFromRect:recognizer.view.frame inView:scrl permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
  [pop presentPopoverFromRect:CGRectMake(carousel.currentItemView.bounds.size.width/2, carousel.currentItemView.bounds.size.height/2, 0, 130) inView:carousel.currentItemView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

}

//シングルタップ検出
-(void)tapDetect:(id)sender
{
  /*
	if ([dblTapTimer isValid]) {
		//グラフの二重呼び出しを避けるため
		return;
	}
	
	//１秒後にグラフ呼び出し
	dblTapTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(callGraph) userInfo:NO repeats:NO];
	
	//タップした商品（tag)を保存
	UILongPressGestureRecognizer *recognizer = (UILongPressGestureRecognizer*)sender;
	singleTapedTag = recognizer.view.tag;
  */
  
  //グラフ２重呼び出し防止タイマーを停止
	[dblTapTimer invalidate];
	
	//小画面表示中は抜ける
	if ( dispChildScreen == YES) {
		return;
	}
  
	UILongPressGestureRecognizer *recognizer = (UILongPressGestureRecognizer*)sender;
	Product *prd = [productList objectAtIndex:recognizer.view.tag];
	
	//詳細画面表示
	//[self alertShow];
	[self buildDetailWindow:prd];
  dblTapTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(dummy) userInfo:NO repeats:NO];
}

-(void)callGraph
{
	Product *prd = [productList objectAtIndex:singleTapedTag];
	
	//オーダー時のグラフ再表示の為、保存
	currentPrd = prd;
	
	[self dispGraphs:prd];
}

-(void)dispGraphs:(Product*)prd
{
	
	//タイトル設定
	NSString *ttl = prd.productName;
	[productLabel setText:ttl];
	[productLabel sizeToFit];
  
	//ローディングアラート表示
  NSLog(@"loading %d", __LINE__);
	//[self alertShow];
	
	[self getSales:prd];
	[self getProductStock:prd drawGraph:YES];
  
  if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
}

-(void)setupStockGraph:(Product*)prd
{
	if ([self isNull:[stockGraph superview]]) {
		[_orderView addSubview:stockGraph];
	}
	if ( [self isNull:[productLabel superview]]){
		[_orderView addSubview:productLabel];
	}
	
	NSMutableArray *stockArray = [NSMutableArray arrayWithArray:prd.stockArray];
	
	//売上済みの数値で在庫数を補正(For demonstration
	NSArray *keys = [saledArray allKeys];
	NSNumber *subVal;
	for (NSString *key in keys ){
		if ([prd.productId isEqualToString:key]) {
			subVal = [saledArray objectForKey:key];
			if ( [prd.stockDateArray count]){
				//オリジナルの配列から在庫を読み、売上分を補正しコピーの配列に書き戻す
				int qty = [[prd.stockArray objectAtIndex:0]intValue] - [subVal intValue];
				[stockArray setObject:[NSNumber numberWithInt:qty] atIndexedSubscript:0];
			}
		}
	}
	
	//横軸ラベル
	NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
	[fmt setDateFormat:@"M/d"];
	NSMutableArray *dateArray = [NSMutableArray array];
	for ( int i = 0; i < [prd.stockDateArray count]; i++ ) {
		[dateArray addObject:[fmt stringFromDate:[prd.stockDateArray objectAtIndex:i]]];
	}
	[stockGraph setXLblAry:dateArray];
	
	//データ設定
	NSArray *datArray = [NSArray arrayWithObject:stockArray];
	[stockGraph setDatAry:(NSMutableArray*)datArray];
	
	//グラフ最大値
  //	NSNumber *max = [[NSNumber alloc]initWithFloat:[self calcGraphMax:prd.stockArray]];
	NSNumber *max = [[NSNumber alloc]initWithFloat:300.0];
	NSMutableArray *maxArray = [NSMutableArray arrayWithObject:max];
	[stockGraph setMaxValAry:maxArray];
	
	//データ名設定
	[stockGraph setNameAry:[NSMutableArray arrayWithObjects:[pData getDataForKey:@"DEFINE_STORORDER_ITEMEXIST_TITLE"], nil]];
	
	//区切り数
	[stockGraph setY_section:4];
	
	//バーの太さ
	[stockGraph setBarWidth:20.0f];
	
	[self clearSubView:stockGraph];
	
	//描画
	[stockGraph setNeedsDisplay];
	
	// アラートを閉じる
	if(alertView.visible) {
		[alertView dismissWithClickedButtonIndex:0 animated:NO];
	}
  
}


-(float)calcGraphMax:(NSArray*)ary
{
	float max = 0;
	for ( int i = 0; i < [ary count]; i++ ){
		float val = [[ary objectAtIndex:i]floatValue];
		if ( max < val ) {
			max = val;
		}
	}
	
	if (( max >= 1 ) && ( max <= 10 )) {
		return 10.0f;
	}
	if (( max >= 10 ) && ( max <= 100 )) {
		return 100.0f;
	}
	if (( max >= 100 ) && ( max <= 1000 )) {
		return 1000.0f;
	}
	if (( max >= 1000 ) && ( max <= 10000 )) {
		return 10000.0f;
	}
	if (( max >= 10000 ) && ( max <= 100000 )) {
		return 100000.0f;
	}
	if (( max >= 100000 ) && ( max <= 1000000 )) {
		return 1000000.0f;
	}
	return FLT_MAX;
}

-(void)setupSalesGraph:(Product*)prd
{
	if ([self isNull:[salesGraph superview]] ){
		[_orderView addSubview:salesGraph];
	}
	
	
	NSMutableArray *itemDat = [NSMutableArray array];
	NSMutableArray *totalDat = [NSMutableArray array];
	NSMutableArray *LblArray = [NSMutableArray array];
  
	//集計開始年・月を求める
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents * cmp = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:[NSDate date]];
	NSInteger year = cmp.year ;
	NSInteger month = cmp.month;
	
	if ( month == 12 ) {
		month = 1;
	}
	else {
		month++;
		year--;
	}
	
	for ( int i = 0 ; i < 12 ; i++ ) {
		NSString *yearMonth = [NSString stringWithFormat:@"%d-%02d",year,month];
    
		//全売り上げ
		NSNumber *valTotal = [totalSales objectForKey:yearMonth];
		if ([self isNull:valTotal]) {
			valTotal = [NSNumber numberWithFloat:0.0f];
		}
		[totalDat addObject:valTotal];
		
		NSNumber *valItem = [itemSales objectForKey:yearMonth];
		if ([self isNull:valItem]) {
			valItem = [NSNumber numberWithFloat:0.0f];
		}
		[itemDat addObject:valItem];
		
		//月
		[LblArray addObject:[self convertMonth:month]];
		
		
		if ( ++month == 13 ) {
			month = 1;
			year++;
		}
	}
	
	//横軸ラベル
	[salesGraph setXLblAry:LblArray];
	
	//データ設定
	NSMutableArray *datArray = [NSMutableArray arrayWithObjects:totalDat,itemDat,nil];
	[salesGraph setDatAry:datArray];
	
  //totalとにitem、それぞれの最大値を取得
  NSNumber * totalmax = [totalDat valueForKeyPath:@"@max.intValue"];
  NSNumber * itemmax = [itemDat valueForKeyPath:@"@max.intValue"];
  int totalmaxint = [totalmax intValue];
  int itemmaxint = [itemmax intValue];
  
  //totalの一番頭の数値に+1　して、のこりは0に
  int tdigit = (int)log10(totalmaxint) + 1;
  int tdigit_num = 10;
  for (int i = 1; i < tdigit -1 ; i++ ) {
    tdigit_num = tdigit_num * 10;
  }
  totalmaxint = totalmaxint / tdigit_num;
  totalmaxint ++;
  totalmaxint = totalmaxint * tdigit_num;
  
  //itemの値を2倍して、頭から2桁目を四捨五入
	if ( itemmaxint ) {
		itemmaxint = itemmaxint *2;
		int idigit = (int)log10(itemmaxint) + 1;
		int idigit_num = 10;
		for (int i = 1; i < idigit -2 ; i++ ) {
			idigit_num = idigit_num * 10;
		}
		itemmaxint = itemmaxint / idigit_num;
		itemmaxint = (itemmaxint +5) / 10;
		itemmaxint = itemmaxint *10 * idigit_num;
		
		if ( itemmaxint == 0 ){
			itemmaxint = 10;
		}
	}
	else {
		itemmaxint = 10;
	}
	
	//グラフ最大値
	//	NSNumber *max = [[NSNumber alloc]initWithFloat:[self calcGraphMax:prd.stockArray]];
	NSNumber *max1 = [[NSNumber alloc]initWithFloat:(float)totalmaxint];
	NSNumber *max2 = [[NSNumber alloc]initWithFloat:(float)itemmaxint];
	NSMutableArray *maxArray = [NSMutableArray arrayWithObjects:max1,max2, nil];
	[salesGraph setMaxValAry:maxArray];
	
	//データ名設定
	[salesGraph setNameAry:[NSMutableArray arrayWithObjects:[pData getDataForKey:@"DEFINE_STORORDER_ALLSALE_TITLE"],prd.productName ,nil]];
	
	//区切り数
	[salesGraph setY_section:4];
	
	//描画
	[salesGraph setNeedsDisplay];
	
	[self clearSubView:salesGraph];
	
	// アラートを閉じる
	if(alertView.visible) {
		[alertView dismissWithClickedButtonIndex:0 animated:NO];
	}
  
}

//月を数値から英語表記に変換
-(NSString*)convertMonth:(int)month {
	switch (month) {
		case 1:
			return @"Jan.";
			break;
		case 2:
			return @"Feb.";
			break;
		case 3:
			return @"Mar.";
			break;
		case 4:
			return @"Apr.";
			break;
		case 5:
			return @"May.";
			break;
		case 6:
			return @"June.";
			break;
		case 7:
			return @"July.";
			break;
		case 8:
			return @"Aug.";
			break;
		case 9:
			return @"Sept.";
			break;
		case 10:
			return @"Oct.";
			break;
		case 11:
			return @"Nov.";
			break;
		case 12:
			return @"Dec.";
			break;
		default:
			break;
	}
	return @"";
}



//ダブルタップ検出
-(void)doubleTapDetect:(id)sender
{
	
	//グラフ２重呼び出し防止タイマーを停止
	[dblTapTimer invalidate];
	
	//小画面表示中は抜ける
	if ( dispChildScreen == YES) {
		return;
	}
  
	UILongPressGestureRecognizer *recognizer = (UILongPressGestureRecognizer*)sender;
	Product *prd = [productList objectAtIndex:recognizer.view.tag];
	
	//詳細画面表示
	[self alertShow];
	[self buildDetailWindow:prd];
}

-(void)btnPush:(id)sender
{
	if (![self isNull:pop]){
		return;
	}
	
	//小画面表示中は抜ける
	if ( dispChildScreen == YES) {
		return;
	}
	
	qv = [[QuantyPopOverViewController alloc]init];
	qv.delegate = self;
	qv.maxQuanty = 20;						//最大数量
	qv.tag = ((UIButton*)sender).tag;		//押下されたボタンの識別用
	pop = [[UIPopoverController alloc]initWithContentViewController:qv];
	pop.delegate = self;
	pop.popoverContentSize = qv.view.frame.size;
	//[pop presentPopoverFromRect:((UIButton*)sender).frame inView:scrl permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
  [pop presentPopoverFromRect:CGRectMake(carousel.currentItemView.bounds.size.width/2, carousel.currentItemView.bounds.size.height/2, 0, 130) inView:carousel.currentItemView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

//POPOverで発注量決定時に呼ばれるデリゲート
-(void)didSelectQuanty:(NSInteger)qty tag:(NSInteger)tag
{
	if (![self isNull:pop]){
		[pop dismissPopoverAnimated:YES];
		pop = nil;
	}
	
  // カーソル上のボタン
  for ( id view in [carousel.currentItemView subviews]) {
		NSString *className = NSStringFromClass([view class]);
		if ([className isEqualToString:@"UIRoundedRectButton"]){
      UIButton *btn = (UIButton*)view;
      [btn setTitle:[NSString stringWithFormat:[pData getDataForKey:@"DEFINE_STORORDER_UNIT_TITLE"],qty] forState:UIControlStateNormal];
		}
	}
  /*
	UIButton *btn = (UIButton*)[self searchBtn:tag];
	[btn setTitle:[NSString stringWithFormat:[pData getDataForKey:@"DEFINE_STORORDER_UNIT_TITLE"],qty] forState:UIControlStateNormal];
  */
	Product *pd = [productList objectAtIndex:tag];
	OrderInfo *od =
	[[OrderInfo alloc]init];
	
	od.price = pd.price;
	od.product_id = pd.productId;
	od.priceBookEntryId = pd.priceBookEntryId;
	od.product_name = pd.productName;
	od.quanty = qty;
  
	//在庫状況
	if ( pd.newestStockCount <= 0) {
		if ( pd.arrivalStockCount <= 0 )
		{
			//在庫無し・入荷予定無し
			od.status = [pData getDataForKey:@"DEFINE_STORORDER_NON_TITLE"];
		}
		else {
      
			//在庫無し・入荷予定無し
			NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
			[fmt setDateFormat:@"M/d"];
			od.status = [[fmt stringFromDate:pd.arrivalStockDate]stringByAppendingString:[pData getDataForKey:@"DEFINE_STORORDER_PRE_TITLE"]];
		}
	}
	else {
		
		//在庫あり
		od.status = [pData getDataForKey:@"DEFINE_STORORDER_EXIST_TITLE"];
	}
	
	[orderArray setObject:od forKey:pd.productId];
}

//tag番号を元にボタンを探す
-(id)searchBtn:(int)tag
{
	for ( id view in [scrl subviews]) {
		NSString *className = NSStringFromClass([view class]);
		if ([className isEqualToString:@"UIRoundedRectButton"]){
			if (((UIButton*)view).tag == tag ) {
				return view;
			}
		}
	}
	return nil;
}



- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

//商品カテゴリ（ファミリー）取得
-(void)getProductFmily
{
	NSString *query = @"SELECT family FROM product2 order by Id ASC";
	SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:query];
	[[SFRestAPI sharedInstance] sendRESTRequest:request
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      
                                      //エラーアラート
                                      alertView = [[UIAlertView alloc]
                                                   initWithTitle:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMCAT_ERROR"]
                                                   message:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMCAT_MESSAGE_ERROR"]
                                                   delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMCAT_OK_ERROR"], nil ];
                                      [alertView show];
                                      
                                    }
                                completeBlock:^(id jsonResponse){
                                  familyList = [NSMutableDictionary dictionary];
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  NSLog(@"%@",dict);
                                  NSArray *records= [dict objectForKey:@"records"];
                                  for ( int i= 0; i < [records count]; i++ ){
                                    NSDictionary *rec = [records objectAtIndex:i];
                                    NSString *familyName = [rec objectForKey:@"Family"];
                                    
                                    //familyListに既に同名のファミリーがあれば、その値をインクリメント
                                    NSNumber *cnt;
                                    if ([[familyList allKeys] containsObject:familyName]) {
                                      cnt = [familyList objectForKey:familyName];
                                      int cntVal = [cnt intValue];
                                      cnt = [[NSNumber alloc]initWithInt:++cntVal];
                                    }
                                    else {
                                      
                                      //ファミリー名のキーが存在しなければ値0でキーを作成
                                      cnt = [[NSNumber alloc]initWithInt:0];
                                    }
                                    
                                    //辞書のキー名＝ファミリー名　値＝アイテム数
                                    [familyList setObject:cnt forKey:familyName];
                                  }
                                  
                                  //商品が最も多いファミリーをデフォルトで選択
                                  int maxVal = 0;
                                  selectedFamily = @"";
                                  NSArray *allkeys = [familyList allKeys];
                                  for ( NSString *key in allkeys ) {
                                    NSNumber *num = [familyList objectForKey:key];
                                    if ( [num intValue] >= maxVal ){
                                      selectedFamily = key;
                                      maxVal = [num intValue];
                                    }
                                  }
                                  
                                  //ファミリ選択
                                  if ( ![selectedFamily isEqualToString:@""] ) {
                                    [self selectFamily:selectedFamily];
                                  }
                                }
   ];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
  if ((orientation == UIInterfaceOrientationLandscapeLeft) ||
      (orientation == UIInterfaceOrientationLandscapeRight )){
    return YES;
  }
  return NO;
}

- (void)viewDidUnload {
	[self setOrderBtn:nil];
	[self setHistroyBtn:nil];
	[self setOrderHeader:nil];
	[self setOrdersLabel:nil];
  [self setCompanyProfile:nil];
  [self setOrderView:nil];
  [self setProduct1:nil];
  [self setOrderWindow:nil];
  [self setSign:nil];
  [self setHistoryWindow:nil];
	[super viewDidUnload];
}


- (IBAction)orderPushed:(id)sender {
	
	//小画面表示中は抜ける
	if ( dispChildScreen == YES) {
		return;
	}
	[self buildOrderScreen];
	
	return;
}

-(void)changeSortNumber:(NSString*)pId number:(int)num
{
	//投稿用parameter
	NSString *path = [@"/services/data/v26.0/sobjects/product2/" stringByAppendingString:pId];
	NSDictionary *param = [[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",num],@"order__c",nil];
	SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodPATCH path:path queryParams:param];
	
	//POST実行
	[[SFRestAPI sharedInstance] sendRESTRequest:req
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                    }
                                completeBlock:^(id jsonResponse){
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  NSLog(@"%@",dict);
                                }
	 ];
}


//オブジェクトがNULLであるかチェック
-(BOOL)isNull:(id)tgt
{
	if ((( tgt == [NSNull null] ) || ([tgt isEqual:[NSNull null]] ) || ( tgt ==  nil ))){
		return YES;
	}
	return NO;
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

//UIImage:imgがRectより大きい場合リサイズする
-(id)resizeImage:(UIImage*)img Rect:(CGRect)rect
{
	if (( img.size.height > rect.size.height) || ( img.size.width > rect.size.width)) {
		NSLog(@"%f : %f",img.size.width,img.size.height);
		float asp = (float)img.size.width / (float)img.size.height;
		CGRect r = CGRectMake(0,0,0,0);
		if ( img.size.width > img.size.height) {
			r.size.width = rect.size.width;
			r.size.height = r.size.width / asp;
		}
		else {
			r.size.height = rect.size.height;
			r.size.width = r.size.height * asp;
		}
		
		UIGraphicsBeginImageContext(r.size);
		[img drawInRect:CGRectMake(0,0,r.size.width,r.size.height)];
		img = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
	return img;
}

-(id)forceResizeImage:(UIImage*)img Rect:(CGRect)rect
{
	//if (( img.size.height > rect.size.height) || ( img.size.width > rect.size.width)) {
		NSLog(@"%f : %f",img.size.width,img.size.height);
		float asp = (float)img.size.width / (float)img.size.height;
		CGRect r = CGRectMake(0,0,0,0);
		if ( img.size.width > img.size.height) {
			r.size.width = rect.size.width;
			r.size.height = r.size.width / asp;
		}
		else {
			r.size.height = rect.size.height;
			r.size.width = r.size.height * asp;
		}
    NSLog(@"%f : %f",r.size.width,r.size.height);
		
		UIGraphicsBeginImageContext(r.size);
		[img drawInRect:CGRectMake(0,0,r.size.width,r.size.height)];
		img = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	//}
	return img;
}

-(void)clearSubView:(UIView*)tgt
{
	for (UIView *view in [tgt subviews]) {
		[view removeFromSuperview];
	}
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	if (![self isNull:pop]){
		pop = nil;
	}
}


//詳細画面のClose押下時デリゲート
-(void)didclosePushed{
	[pop dismissPopoverAnimated:YES];
	pop= nil;
}


-(void)viewWillClose
{
}

//発注履歴表示
- (IBAction)historyPushed:(id)sender {
	
	//小画面表示中は抜ける
	if ( dispChildScreen == YES) {
		return;
	}
	[self buildHistoryScreen];
	
}
-(CGRect)allignCenter:(CGRect)rect1 size:(CGSize)siz
{
	CGRect ret;
	ret.origin.x = rect1.origin.x + (( rect1.size.width - siz.width ) / 2.0f );
	ret.origin.y = rect1.origin.y + (( rect1.size.height - siz.height) / 2.0f );
	ret.size = siz;
	
	return ret;
}



//デリゲート
-(void)didBeginSign
{
	if ( orderDisable == NO ) {
		orderExec.alpha = 1.0;
		orderExec.enabled = YES;
	}
}
-(void)logoImageFound:(UIImage *)img
{
}

-(void)didSelectTileImage:(NSMutableArray *)array index:(int)index
{
}

-(void)requestMoviePlay:(NSString*)url
{
}

-(void)detectMyPosition:(CLLocationCoordinate2D)pos
{
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel_
{
	if ( carousel_ == carousel2) {
		return [imgArray count];
	}
  NSLog(@"productList : %@", productList);
  return [productList count];
}

- (UIView *)carousel:(iCarousel *)carousel_ viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
	if ( carousel_ == carousel2) {
		if (view == nil)
		{
			float img_x = 291; //150;//orderDetailScreen.detailPrimaryImage.frame.size.width;
			float img_y = 241; //150;//orderDetailScreen.detailPrimaryImage.frame.size.height;
			UIImageView *iv = nil;

			CGRect rect;
			UIImageView *productImg = [[UIImageView alloc]init];
			rect.size.width = img_x;
			rect.size.height = img_y;
			rect.origin.x = 0;
			rect.origin.y = 0;
			
			view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, img_x, img_y)];
//			UIImage *resize = [self resizeImage:[imgArray objectForKey:[NSString stringWithFormat:@"%d",index]] Rect:rect];
//			productImg.image = resize;
			UIImage *tmpimg = [ self resizeImage:[imgArray objectForKey:[NSString stringWithFormat:@"%d",index]] Rect:CGRectMake(0,0,291,241)];
		
			CGRect tempRect = CGRectMake(0,0,tmpimg.size.width,tmpimg.size.height);
			productImg.image = tmpimg;
			productImg.frame = tempRect;
			//view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,
			//									productImg.frame.size.width,
			//									productImg.frame.size.height)];
			
			
			productImg.layer.shadowOffset = CGSizeMake(10, 10);
			productImg.layer.shadowOpacity = 0.0f;
			rect.size.width = productImg.frame.size.width;
			rect.size.height = productImg.frame.size.height;
			rect.origin.x = (view.bounds.size.width-productImg.frame.size.width)/2;
			rect.origin.y = 10;
			productImg.frame = rect;
			view.backgroundColor = [UIColor whiteColor];
			iv = productImg;
			[iv setFrame:CGRectMake((view.bounds.size.width-iv.bounds.size.width)/2, 15, iv.bounds.size.width, iv.bounds.size.height)];
      iv.center = view.center;
			[view addSubview:iv];
		}
		return view;
	}
	
  
  static const float MAXIMAGE_X = 200;
	static const float MAXIMAGE_Y = 180;
  UIImageView *iv = nil;
  //create new view if no view is available for recycling
  if (view == nil)
  {
    view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MAXIMAGE_X+20, MAXIMAGE_Y+50)];
    
    Product *pd = [productList objectAtIndex:index];
    
    CGRect rect;
    UIImageView *productImg = [[UIImageView alloc]init];
    rect.size.width = MAXIMAGE_X;
    rect.size.height = MAXIMAGE_Y;
    rect.origin.x = 0;
    rect.origin.y = 0;
    // 仮画像
    NSData *imgData = UIImageJPEGRepresentation(pd.image, 0);
    if([imgData length]==0){
      pd.image = clearImg;
    }
    UIImage *resize = [self resizeImage:pd.image Rect:rect];
    productImg.image = resize;
    rect.size.width = resize.size.width;
    rect.size.height = resize.size.height;
    rect.origin.x = (view.bounds.size.width-rect.size.width)/2;
    rect.origin.y = 10;
    productImg.frame = rect;
    productImg.tag = pd.index;
    
    iv = productImg;
    
    view.backgroundColor = [UIColor clearColor];
    [iv setFrame:CGRectMake((view.bounds.size.width-iv.bounds.size.width)/2, 15, iv.bounds.size.width, iv.bounds.size.height)];
    [view addSubview:iv];
    if(isFistChg && index==0) iv.alpha = 0.0;
    //NSLog(@"%d pd.badgeValue : %@", __LINE__, pd.badgeValue);
    if(pd.badgeValue!=nil && ![pd.badgeValue isEqualToString:@""]){
      CGRect r = CGRectMake(view.bounds.size.width-80, 10, 45, 20);
      ItemBadge* bagde = [[ItemBadge alloc] initWithFrame:r];
      bagde.textLabel.text = [NSString stringWithFormat:@"%@", pd.badgeValue];
      [view addSubview:bagde];
    }
    productImg.userInteractionEnabled = YES;
    
    sTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapDetect:)];
    sTap.numberOfTapsRequired = 1;
    [productImg addGestureRecognizer:sTap];
    
    lt= [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longtap:)];
    lt.numberOfTapsRequired = 0;
    lt.minimumPressDuration = 1;
    [productImg addGestureRecognizer:lt];
    
    //設定済みの発注量を読み込み
    OrderInfo *od = [orderArray objectForKey:pd.productId];
    int qty = od.quanty;
    
    UIButton *qBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //	qBtn = [self setBtn:qBtn num:dispProductCount];
    rect.size.width = 100;
    rect.size.height = 30;
    rect.origin.x = (view.bounds.size.width-rect.size.width)/2;
    rect.origin.y = 172;
    qBtn.frame = rect;
    qBtn.titleLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:14];
    [qBtn setTitle:[NSString stringWithFormat:[pData getDataForKey:@"DEFINE_STORORDER_UNIT_TITLE"],qty] forState:UIControlStateNormal];
    [qBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -40,0,-40)];
    [qBtn addTarget:self action:@selector(btnPush:) forControlEvents:UIControlEventTouchUpInside];
    qBtn.tag = pd.index;
    qBtn.hidden = YES;
    [view addSubview:qBtn];
  }
  
  return view;
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
  //note: placeholder views are only displayed on some carousels if wrapping is disabled
  return 0;
}


- (UIView *)carousel:(iCarousel *)carousel_ placeholderViewAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
	UIImageView *iv = nil;
	if ( carousel_ == carousel2) {
		return view;
	}
  
	static const float MAXIMAGE_X = 200;
	static const float MAXIMAGE_Y = 180;
  //create new view if no view is available for recycling
  if (view == nil)
  {
    view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MAXIMAGE_X+20, MAXIMAGE_Y+50)];
    
    Product *pd = [productList objectAtIndex:index];
    CGRect rect;
    UIImageView *productImg = [[UIImageView alloc]init];
    rect.size.width = MAXIMAGE_X;
    rect.size.height = MAXIMAGE_Y;
    rect.origin.x = 0;
    rect.origin.y = 0;
    // 仮画像
    NSData *imgData = UIImageJPEGRepresentation(pd.image, 0);
    if([imgData length]==0){
      pd.image = clearImg;
    }
    UIImage *resize = [self resizeImage:pd.image Rect:rect];
    productImg.image = resize;
    rect.size.width = resize.size.width;
    rect.size.height = resize.size.height;
    rect.origin.x = ( dispProductCount * MAXIMAGE_X + 30 ) + (MAXIMAGE_X - resize.size.width) / 2;
    rect.origin.y = 10;
    productImg.frame = rect;
    productImg.tag = pd.index;
    
    iv = productImg;
    
    view.backgroundColor = [UIColor clearColor];
    [iv setFrame:CGRectMake((view.bounds.size.width-iv.bounds.size.width)/2, 5, iv.bounds.size.width, iv.bounds.size.height)];
    [view addSubview:iv];
    if(isFistChg && index==0) iv.alpha = 0.0;
    if(pd.badgeValue!=nil && ![pd.badgeValue isEqualToString:@""]){
      CGRect r = CGRectMake(view.bounds.size.width-80, 10, 45, 20);
      ItemBadge* bagde = [[ItemBadge alloc] initWithFrame:r];
      bagde.textLabel.text = [NSString stringWithFormat:@"%@", pd.badgeValue];
      [view addSubview:bagde];
    }
    productImg.userInteractionEnabled = YES;
    
    sTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapDetect:)];
    sTap.numberOfTapsRequired = 1;
    [productImg addGestureRecognizer:sTap];
    
    lt= [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longtap:)];
    lt.numberOfTapsRequired = 0;
    lt.minimumPressDuration = 1;
    [productImg addGestureRecognizer:lt];
    
    //設定済みの発注量を読み込み
    OrderInfo *od = [orderArray objectForKey:pd.productId];
    int qty = od.quanty;
    
    UIButton *qBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //	qBtn = [self setBtn:qBtn num:dispProductCount];
    rect.size.width = 100;
    rect.size.height = 30;
    rect.origin.x = ( dispProductCount * MAXIMAGE_X + 30 ) + (MAXIMAGE_X - rect.size.width) / 2;
    rect.origin.y = 172;
    qBtn.frame = rect;
    qBtn.titleLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:14];
    [qBtn setTitle:[NSString stringWithFormat:[pData getDataForKey:@"DEFINE_STORORDER_UNIT_TITLE"],qty] forState:UIControlStateNormal];
    [qBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -40,0,-40)];
    [qBtn addTarget:self action:@selector(btnPush:) forControlEvents:UIControlEventTouchUpInside];
    qBtn.tag = pd.index;
    
    [view addSubview:qBtn];
    
  }
  
  return view;
}


- (CATransform3D)carousel:(iCarousel *)_carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
  //implement 'flip3D' style carousel
  transform = CATransform3DRotate(transform, M_PI / 30.0f, 0.0f, 1.0f, 0.0f);
  return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * _carousel.itemWidth);
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
  //customize carousel display
  switch (option)
  {
    case iCarouselOptionWrap:
    {
      //normally you would hard-code this to YES or NO
      return YES; //wrap;
    }
    case iCarouselOptionSpacing:
    {
      //add a bit of spacing between the item views
      if(_carousel==carousel2) return value * 2.0f;
      return value * 1.10f;
    }
    case iCarouselOptionFadeMax:
    {
      if (_carousel.type == iCarouselTypeCustom)
      {
        //set opacity based on distance from camera
        return 0.0f;
      }
      return value;
    }
    default:
    {
      return value;
    }
  }
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)_carousel
{
  if ( _carousel == carousel2) {
		return;
	}
  NSLog(@" index : %d", _carousel.currentItemIndex);
  isFistChg = NO;
  
  // 前後の拡大画像を削除、ボタンを無効
  int nextIndex = _carousel.currentItemIndex+1;
  if(nextIndex>=[productList count]) nextIndex=0;
  int prevIndex = _carousel.currentItemIndex-1;
  if(prevIndex<0) prevIndex =[productList count]-1;
  
  NSLog(@"_carousel.currentItemIndex : %d", _carousel.currentItemIndex);
  
  Product *pd = [productList objectAtIndex:_carousel.currentItemIndex];
  NSLog(@"pd : %@", pd);
  NSLog(@"pd.imgNameArray: %@", pd.imgNameArray);
  NSLog(@"pd.imgIdArray: %@", pd.imgIdArray);
  NSLog(@"pd.imgURLArray: %@", pd.imgURLArray);
  
  NSLog(@"nextIndex : %d", nextIndex);
  NSLog(@"prevIndex : %d", prevIndex);
  [self removeIndexImage:[carousel itemViewAtIndex:nextIndex] index:nextIndex];
  [self removeIndexImage:[carousel itemViewAtIndex:prevIndex] index:prevIndex];
  [self removeIndexImage:[carousel itemViewAtIndex:prevIndex] index:_carousel.currentItemIndex];
   /*
  if(currentImgview !=nil) [currentImgview removeFromSuperview];
  for (UIView* view in [carousel.currentItemView subviews]){
    if ([view isKindOfClass:[UIImageView class]]) {
      view.alpha = 0.0;
    }
  }
  */
}


- (void)carouselWillBeginScrollingAnimation:(iCarousel *)_carousel
{
  if(_carousel != carousel2){
    NSLog(@"carouselWillBeginScrollingAnimation : %d", _carousel.currentItemIndex);
  }
}

// カーソルが変わった場合、該当する商品のグラフを表示
- (void)carouselDidEndScrollingAnimation:(iCarousel *)_carousel;
{

  NSLog(@" chg index : %d", _carousel.currentItemIndex);
  if ( _carousel == carousel2) {
		return;
	}
  if ([dblTapTimer isValid]) {
		//グラフの二重呼び出しを避けるため
		return;
	}
  
  // 初回以外
  if(!isFistChg){
    singleTapedTag = _carousel.currentItemIndex;
    //グラフ呼び出し
    //dblTapTimer = [NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(callGraph) userInfo:NO repeats:NO];
    dblTapTimer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(dummy) userInfo:NO repeats:NO];
    [self callGraph];
  }
   
  // 初回の二重起動対策
  BOOL flg = NO;
  for (UIView* view in [carousel.currentItemView subviews]){
    if ([view isKindOfClass:[UIImageView class]]) {
      view.alpha = 1.0;
      if(view==currentImgview){
        flg = YES; break;
      }
    }
  }
  for (UIView* view in [carousel.currentItemView subviews]){
    if ([view isKindOfClass:[UIImageView class]]) {
      if(flg) continue;
      
      Product *pd = [productList objectAtIndex:view.tag];
      currentImgview = [[UIImageView alloc]init];
      currentImgrect = CGRectZero;
      currentImgrect.size.width = view.bounds.size.width*1.2>220 ? 220:view.bounds.size.width*1.2;
      currentImgrect.size.height = view.bounds.size.height*1.2>180 ? 180 : view.bounds.size.height*1.2;
      currentImgrect.origin.x = 0;
      currentImgrect.origin.y = 0;
      UIImage *resize = [self forceResizeImage:pd.image Rect:currentImgrect];
      currentImgrect.size.width = resize.size.width;
      currentImgrect.size.height = resize.size.height;
      
      currentImgview.image = resize;
      currentImgview.frame = currentImgrect;
      currentImgview.tag = view.tag;
      currentImgview.userInteractionEnabled = YES;
      
      sTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapDetect:)];
      sTap.numberOfTapsRequired = 1;
      [currentImgview addGestureRecognizer:sTap];
      
      [currentImgview setFrame:CGRectMake((carousel.currentItemView.bounds.size.width-currentImgview.bounds.size.width)/2, 15, currentImgview.bounds.size.width, currentImgview.bounds.size.height)];
      currentImgview.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
      currentImgview.center = view.center;
      currentImgview.alpha = 1.0;
      view.alpha = 1.0;
      [carousel.currentItemView addSubview:currentImgview];
      
      UIButton *button;
      for (UIView* view in [carousel.currentItemView subviews]){
        if ([view isKindOfClass:[UIButton class]]) {
          button = (UIButton*)view;
          [button setFrame:CGRectMake(button.frame.origin.x, carousel.currentItemView.bounds.size.height -button.bounds.size.height-20, button.bounds.size.width, button.bounds.size.height)];
        }
      }
       
      [UIView beginAnimations:nil context:nil];
      [UIView setAnimationDelegate:self];
      [UIView setAnimationDuration:0.1];
      [currentImgview setFrame:CGRectMake((carousel.currentItemView.bounds.size.width-resize.size.width)/2, 15, resize.size.width, resize.size.height)];
      //currentImgview.alpha = 0.0;
      //[UIView setAnimationDidStopSelector:@selector(imageViewAppear:finished:context:)];
      [UIView commitAnimations];
      
      break;
    }
  }
  // バッヂをフロントに、ボタンを有効化
  for (UIView* view in [carousel.currentItemView subviews]){
    if ([view isKindOfClass:[ItemBadge class]]) {
      [carousel.currentItemView bringSubviewToFront:view];
    }
    if ([view isKindOfClass:[UIButton class]]) {
      view.hidden = NO;
      [carousel.currentItemView bringSubviewToFront:view];
    }
  }
}

- (CGFloat)carouselItemWidth:(iCarousel *)_carousel
{
  if(_carousel==carousel) return 300;
  return carousel.currentItemView.bounds.size.width;
}

// 消したUIImageViewを戻す
- (void)imageViewAppear:(NSString *)animationID finished:(NSNumber *) finished context:(void *) context
{
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDuration:0.6];
  [currentImgview setFrame:CGRectMake((carousel.currentItemView.bounds.size.width-currentImgrect.size.width)/2, 15, currentImgrect.size.width, currentImgrect.size.height)];
  currentImgview.alpha = 1.0;
  [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:currentImgview cache:YES];
  [UIView setAnimationDidStopSelector:@selector(graphViewAppear:finished:context:)];
  [UIView commitAnimations];
}

// グラフ表示
- (void)graphViewAppear:(NSString *)animationID finished:(NSNumber *) finished context:(void *) context
{
  for (UIView* view in [carousel.currentItemView subviews]){
    if ([view isKindOfClass:[UIImageView class]]) {
      if(view!=currentImgview){
        view.alpha = 1.0;
      }
    }
  }
  
  // 初回以外
  if(!isFistChg){
    singleTapedTag = carousel.currentItemIndex;
    //グラフ呼び出し
    //dblTapTimer = [NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(callGraph) userInfo:NO repeats:NO];
    dblTapTimer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(dummy) userInfo:NO repeats:NO];
	  [self callGraph];
  }
}

-(void)dummy
{
}

// ファイル更新
-(void)didCacheFileUpdate
{
  // メニューを閉じる
  [btnBuilder dismissMenu];
  isFistChg = YES;
  
  // キャッシュした画像ファイルの更新
  AppDelegate* appli = (AppDelegate*)[[UIApplication sharedApplication] delegate];
  [appli updateCacheFile:YES];
}

// currentを外れたスライドの拡大写真を削除、ボタンを非表示に
-(void)removeIndexImage:(UIView*)Item index:(int)index
{
  Item = [carousel itemViewAtIndex:index];
  for (UIView* view in [Item subviews]){
    if ([view isKindOfClass:[UIImageView class]]) {
      if(view==currentImgview){
        NSLog(@"remove %d", index);
        [view removeFromSuperview];
      }//else{
      // view.alpha = 1.0;
      //}
    }
    if ([view isKindOfClass:[UIButton class]]) {
      view.hidden = YES;
    }
  }
}


@end
