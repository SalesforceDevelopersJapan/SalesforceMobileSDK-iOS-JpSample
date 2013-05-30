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


#import "MetricsViewController.h"
#import "PublicDatas.h"
#import "Company.h"
#import "OrderViewController.h"
#import "Person.h"
#import "SelectViewController.h"
#import "ViewerViewController.h"
#import "ChatterViewController.h"
#import "storeMapViewController.h"
#import "UtilManager.h"
#import "CircleGraph.h"
#import "GraphData.h"
#import "GraphDataManager.h"
#import "NameCard.h"

@interface MetricsViewController ()

@end

@implementation MetricsViewController


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
  
  isFunctionFlg = YES;
	pData = [PublicDatas instance];
  gm = [GraphDataManager sharedInstance];
  
  // ローディング
  [gm adddLoadingView:_uiview1];
  [gm adddLoadingView:_uiview2];
  [gm adddLoadingView:_uiview3];
  
  [gm requestFamilyList];
  um = [UtilManager sharedInstance];
  
  //取引責任者リスト初期化
  svList = [[NSMutableArray alloc] initWithCapacity:0];
  
	//ナビゲーションバー　設定
	NSData *iData =[um navBarType];
	if ( [((NSString*)iData) isEqualToString:@"gray"] ) {
		[self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
		self.navigationController.navigationBar.tintColor = [UIColor grayColor];
    self.graphTitleView.backgroundColor = [UIColor grayColor];
		self.storeContactHeader.backgroundColor = [UIColor grayColor];
	}
	else if ( [((NSString*)iData) isEqualToString:@"black"] ) {
		[self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
		self.navigationController.navigationBar.tintColor = [UIColor blackColor];
		self.storeContactHeader.backgroundColor = [UIColor blackColor];
    self.graphTitleView.backgroundColor = [UIColor blackColor];
	}
	else {
		iData =[um navBarImage];
		if ( iData ) {
			UIImage *img = [UIImage imageWithData:iData];
			[self.navigationController.navigationBar setBackgroundImage:img
                                                    forBarMetrics:UIBarMetricsDefault];
			
			self.storeContactHeader.backgroundColor = [UIColor colorWithPatternImage:img];
      self.graphTitleView.backgroundColor = [UIColor colorWithPatternImage:img];
		}
	}
  
	//ナビバータイトル
	self.title = [pData getDataForKey:@"DEFINE_METRIX_TITLE"];
	titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
	titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.textColor = [UIColor whiteColor];
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
	//会社情報表示
	if ( cp.image == nil ){
    //		cp.image = [UIImage imageNamed:@"noimage.png"];
	}
	[_companyProfile setInfo:cp];
	_companyProfile.delegate = self;
	
	//スクロールビュー追加
	//rect = CGRectMake(10,5,StoreContactView.frame.size.width - 20, StoreContactView.frame.size.height - 10 );
  CGRect rect = CGRectMake(0,0,_storeContactView.frame.size.width, _storeContactView.frame.size.height);
	scrl = [[UIScrollView alloc]initWithFrame:rect];
	scrl.backgroundColor = [UIColor whiteColor];
	scrl.contentSize = scrl.frame.size;
	//[_storeContactView addSubview:scrl];
	
  // カバーフロー
  carousel = [[iCarousel alloc]initWithFrame:rect];
  carousel.delegate = self;
  carousel.dataSource = self;
  //carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  carousel.contentMode = UIViewContentModeScaleAspectFit;
  carousel.type = iCarouselTypeRotary;
  //carousel.type = iCarouselTypeCoverFlow2;
  UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:rect]; //_storeContactView.frame];
  backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  backgroundView.image = [UIImage imageNamed:@"coverflowbackground.png"];
  [_storeContactView addSubview:backgroundView];
  carousel.backgroundColor = [UIColor whiteColor];
  
  [_storeContactView addSubview:carousel];
  
	//オブジェクトリスト初期化
	ObjArray = [NSMutableArray array];
	
	//CompanyProfileのCheckin CheckOUT有効化
	[_companyProfile setUpCheckInOut];
  
  
  // グラフ用
  UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(listPushed:)];
  tap1.numberOfTapsRequired = 1;    // シングル
  tap1.numberOfTouchesRequired = 1;
  _uiview1.tag = 1;
  [_uiview1 addGestureRecognizer:tap1];
  
  UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(listPushed:)];
  tap2.numberOfTapsRequired = 1;    // シングル
  tap2.numberOfTouchesRequired = 1;
  _uiview2.tag = 2;
  [_uiview2 addGestureRecognizer:tap2];
  
  UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(listPushed:)];
  tap3.numberOfTapsRequired = 1;    // シングル
  tap3.numberOfTouchesRequired = 1;
  _uiview3.tag = 3;
  [_uiview3 addGestureRecognizer:tap3];
  
  //[PublicData setData:cp.company_id forKey:@"company_id"];
  [pData setData:@"company_id_store_metrix" forKey:@"company_id"];
  
  // 角丸
  CGSize size = CGSizeMake(5.0, 5.0);
  [um makeViewRound:_companyProfile corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_graphTitleView corners:UIRectCornerTopLeft|UIRectCornerTopRight size:&size];
  [um makeViewRound:_graphView corners:UIRectCornerBottomLeft|UIRectCornerBottomRight size:&size];
  
  [um makeViewRound:_storeContactHeader corners:UIRectCornerTopLeft|UIRectCornerTopRight size:&size];
  [um makeViewRound:_storeContactView corners:UIRectCornerBottomLeft|UIRectCornerBottomRight size:&size];
	
	
  //取引責任者取得
  [self getSuperVisorlist];
	
  //ラベル設定
  [_scoredLabel setText:[pData getDataForKey:@"DEFINE_METRIX_LABEL_SCORE"]];
  [_contactsLabel setText:[pData getDataForKey:@"DEFINE_METRIX_LABEL_CONTACTS"]];
  [_scoredLabel sizeToFit];
  [_contactsLabel sizeToFit];
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


//CompanyProfileのサムネイルクリック地のデリゲート
-(void)didSelectTileImage:(NSMutableArray *)array index:(int)index
{
  [tV removeFromSuperview];
	tV = [[TileImageViewer alloc]init];
	tV.delegate = self;
	tV.imgArray = array;
	tV.index = index;
	[tV drawRect:tV.frame];
	[self.view addSubview:tV];
}

-(void)didDetectTap
{
	[tV removeFromSuperview];
}


-(void) viewWillAppear:(BOOL)animated
{
	
	//CompanyProfileに画像表示
	[_companyProfile retriveImage];
	
	//行動一覧取得
	[self getEventList];
	
	//下記処理はViewDidLoadに移動
	//取引責任者取得
  //	[self getSuperVisorlist];
  
  // ファイルからグラフ設定を読み出す
  [gm loadGraphSetting];
  
  // 各ウィンドウごとに変数を格納する辞書を作成
  for(int i=1; i<4; i++){
    NSMutableDictionary *tmp = [gm getDictionaryForTag:[NSString stringWithFormat:@"%d", i]];
    // データが無ければ作成
    if(!tmp){
      NSMutableDictionary *_tmp = [gm getPlainGraphData:[NSString stringWithFormat:@"%d", i]];
      [gm saveDictionaryFroTag:[NSString stringWithFormat:@"%d", i] Dictionary:_tmp];
    }
  }
}

-(void)viewDidAppear:(BOOL)animated
{
  // ストアID
  [pData setData:cp.company_id forKey:@"cp_company_id"];
  
  // 各ウィンドウごとにグラフを表示
  for(int i=1; i<4; i++){
    NSMutableDictionary *tmp = [gm getDictionaryForTag:[NSString stringWithFormat:@"%d", i]];
    // データがあればグラフ描画
    if(tmp){
      // グラフ種別
      NSString *grapthIndex = [tmp objectForKey:@"graphIndex"];
      
      if([grapthIndex isEqualToString:@"0"]){
        [self preCircleGraph:[NSString stringWithFormat:@"%d", i]];
      }
      // 棒グラフ
      else if([grapthIndex isEqualToString:@"1"]){
        [NSThread sleepForTimeInterval:0.2];
        [self preBarGraph:[NSString stringWithFormat:@"%d", i]];
      }
      // 折れ線グラフ
      else if([grapthIndex isEqualToString:@"2"]){
        [NSThread sleepForTimeInterval:0.2];
        [self preLineGraph:[NSString stringWithFormat:@"%d", i]];
      }
    }
  }
}

-(void)getSuperVisorlist
{
	NSString *query = [NSString  stringWithFormat:@"SELECT Id, Department, Title,Name ,MailingState,MailingCity,MailingStreet,Twitter__c FROM Contact WHERE AccountId = '%@' order by Id ASC",cp.company_id];
	NSLog(@"%@",query);
	SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:query];
	[[SFRestAPI sharedInstance] send:request delegate:self];
  
}

//SOQLのアンサー受信
- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
  
	pData = [PublicDatas instance];
  um = [UtilManager sharedInstance];
  
	NSLog(@"%@",jsonResponse);
	NSArray *records = [jsonResponse objectForKey:@"records"];
	if ( [self isNull:records] == NO ) {
		
		//取引責任者リスト初期化
		svList = [NSMutableArray array];
		
		float y = 0;
		for ( int i = 0; i < [records count]; i++ ){
			NSDictionary *rec = [records objectAtIndex:i];
			Person *ps = [[Person alloc]init];
			ps.name = [rec objectForKey:@"Name"];
			ps.userId = [rec objectForKey:@"Id"];
			ps.twitterAccount = [rec objectForKey:@"Twitter__c"];
      
      if([um chkString:[rec objectForKey:@"MailingState"]] && [um chkString:[rec objectForKey:@"MailingCity"]] && [um chkString:[rec objectForKey:@"MailingStreet"]]){
        ps.address = [[[rec objectForKey:@"MailingState"]stringByAppendingString:[rec objectForKey:@"MailingCity"]]stringByAppendingString:[rec objectForKey:@"MailingStreet"]];
      }
			ps.belongsto = [rec objectForKey:@"Department"];
			ps.position = [rec objectForKey:@"Title"];
			
			//リストに追加
			[svList addObject:ps];
			
			//
			//取引責任者、部署・約束、住所、チェックイン・アウトボタンを作る
			//
			
			CGRect rect = CGRectMake(0, 0, 130, 35);
			UIButton *name = [UIButton buttonWithType:UIButtonTypeCustom];
			name.frame = rect;
			name.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
			[name setTitle:[self isStringEmpty:ps.name] forState:UIControlStateNormal];
			[name setBackgroundColor:[UIColor clearColor]];
			[name setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[name addTarget:self action:@selector(svBtnPushed:) forControlEvents:UIControlEventTouchUpInside];
			name.tag = i;
			
			rect = CGRectMake(150, 0, 180, 35);
			UIButton *pos = [UIButton buttonWithType:UIButtonTypeCustom];
			pos.frame = rect;
			NSString *temp = [[[self isStringEmpty:ps.belongsto]stringByAppendingString:@" "]stringByAppendingString:[self isStringEmpty:ps.position]];
			pos.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
			[pos setTitle:temp forState:UIControlStateNormal];
			[pos setBackgroundColor:[UIColor clearColor]];
			[pos setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[pos addTarget:self action:@selector(svBtnPushed:) forControlEvents:UIControlEventTouchUpInside];
			pos.tag = i;
			
			rect = CGRectMake(350, 0, 310, 35);
			UIButton *address = [UIButton buttonWithType:UIButtonTypeCustom];
			address.frame = rect;
			address.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
			[address setTitle:[self isStringEmpty:ps.address] forState:UIControlStateNormal];
			[address setBackgroundColor:[UIColor clearColor]];
			[address setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[address addTarget:self action:@selector(svBtnPushed:) forControlEvents:UIControlEventTouchUpInside];
			address.tag = i;
      
			rect = CGRectMake(705, 3, 25 ,25);
			UIButton *twitterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			twitterBtn.frame = rect;
			[twitterBtn setBackgroundImage:[UIImage imageNamed:@"Twitter.png"] forState:UIControlStateNormal];
			[twitterBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[twitterBtn addTarget:self action:@selector(svBtnPushed:) forControlEvents:UIControlEventTouchUpInside];
			twitterBtn.tag = i+3000;
      
			rect = CGRectMake(745, 3, 25 ,25);
			UIButton *contactChatterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			contactChatterBtn.frame = rect;
			[contactChatterBtn setBackgroundImage:[UIImage imageNamed:@"ContactChatterIcon.png"] forState:UIControlStateNormal];
			[contactChatterBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[contactChatterBtn addTarget:self action:@selector(svBtnPushed:) forControlEvents:UIControlEventTouchUpInside];
			contactChatterBtn.tag = i+4000;
			
			rect = CGRectMake(800, 3, 70, 25);
			UIButton *chkIn = [UIButton buttonWithType:UIButtonTypeCustom];
			chkIn.frame = rect;
			[chkIn setBackgroundImage:[UIImage imageNamed:@"CheckIn.png"] forState:UIControlStateNormal];
			[chkIn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[chkIn addTarget:self action:@selector(svBtnPushed:) forControlEvents:UIControlEventTouchUpInside];
			chkIn.tag = i+1000;
      
			rect = CGRectMake(880, 3, 70, 25);
			UIButton *chkOut = [UIButton buttonWithType:UIButtonTypeCustom];
			chkOut.frame = rect;
			[chkOut setBackgroundImage:[UIImage imageNamed:@"CheckOut.png"] forState:UIControlStateNormal];
			[chkOut setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[chkOut addTarget:self action:@selector(svBtnPushed:) forControlEvents:UIControlEventTouchUpInside];
			chkOut.tag = i+2000;
      
			//チェックアウトが行われてないオブジェクトがある場合は、チェックイン：無効　チェックアウト：有効
			chkOut.enabled = NO;
			chkIn.enabled = YES;
			for ( int i =0; i < [ObjArray count]; i++) {
				NSDictionary *dic = [ObjArray objectAtIndex:i];
				NSString *ObjName = [dic objectForKey:@"Subject"];
				NSString *evId = [dic objectForKey:@"Id"];
				NSString *cmp = [[cp.name stringByAppendingString:@"_"]stringByAppendingString:[self isStringEmpty:ps.name]];
				if ( [self isInclude:ObjName cmp:cmp] == YES ) {
					chkOut.enabled = YES;
					chkIn.enabled = NO;
					
					//EventIDを配列に保存する。管理者のIDをキーとする
					NSString *svId =[NSString stringWithFormat:@"chkin_%@",ps.userId];
					[pData setData:evId forKey:svId];
          // ボタンを無効化
          [self changeBtnState:(chkOut.tag) state:YES];
          [self changeBtnState:(chkIn.tag) state:NO];
					break;
				}
			}
			rect = CGRectMake(0, y, 1000, 30);
			UIView *base = [[UIView alloc]initWithFrame:rect];
			[base setBackgroundColor:[UIColor whiteColor]];
      
			rect = CGRectMake(0, y+30, 1000, 2);
			UIView *border = [[UIView alloc]initWithFrame:rect];
			[border setBackgroundColor:[UIColor blackColor]];
      
			//Twitterアカウントが設定されている場合のみ、Twitterボタンを表示
			if ( ![self isNull:ps.twitterAccount]) {
				[base addSubview:twitterBtn];
			}
			
			[base addSubview:name];
			[base addSubview:pos];
			[base addSubview:address];
			[base addSubview:contactChatterBtn];
			[base addSubview:chkIn];
			[base addSubview:chkOut];
      
			[scrl addSubview:base];
			[scrl addSubview:border];
			
			CGSize siz = scrl.contentSize;
			y+= base.frame.size.height+border.frame.size.height;
			siz.height = y;
			scrl.contentSize = siz;
		}
    
    // カーソル更新
    [carousel reloadData];
	}
}

-(void)svBtnPushed:(id)sender
{
	
	UIButton *wrkBtn = (UIButton*)sender;
	if (wrkBtn.tag >= 4000){
		pushedTag = wrkBtn.tag - 4000;
		Person *ps = [svList objectAtIndex:pushedTag];
    
		[btnBuilder dismissMenu];
		
		//戻り先を記録
		pData = [PublicDatas instance];
		[pData setData:@"STORE" forKey:@"ReturnScreen"];
		
		//Chatter表示
		ChatterViewController *chatter = [[ChatterViewController alloc]init];
		[chatter setInitialId:ps.userId];
		[chatter setInitialName:ps.name];
		[chatter setInitialCompnay:cp];
		[chatter setChatterType:1];					//取引先責任者のチャター
		
		//ナビゲーションバー　設定
		[self.navigationController.navigationBar setHidden:NO];
		
		//画面遷移
		[self.navigationController pushViewController:chatter animated:YES];
    
	}
	else if (wrkBtn.tag >= 3000){
		pushedTag = wrkBtn.tag - 3000;
		Person *ps = [svList objectAtIndex:pushedTag];
    
		[btnBuilder dismissMenu];
    
		//TwitterPage表示
		
		//リクエスト作成
		NSString *url = [NSString stringWithFormat:@"https://twitter.com/%@",ps.twitterAccount];
		NSURL *myURL = [NSURL URLWithString:url];
		NSMutableURLRequest *requestDoc = [[NSMutableURLRequest alloc]initWithURL:myURL];
		
		//viewerViewController内のUIWebviewで表示
		ViewerViewController *vView = [[ViewerViewController alloc]init];
		[vView setReq:requestDoc];
		
		//ナビゲーションバー　設定
		[self.navigationController.navigationBar setHidden:NO];
		
		//画面遷移
		[self.navigationController pushViewController:vView animated:YES];
    
	}
	else if (wrkBtn.tag >= 2000){
    
		//チェックアウト
		pushedTag = wrkBtn.tag - 2000;
    
		isCheckIN = NO;
		alertView = [[UIAlertView alloc]
                 initWithTitle: [pData getDataForKey:@"DEFINE_METRIX_TITLE_CHECKOUT"]
                 message:[pData getDataForKey:@"DEFINE_METRIX_TITLE_CHECKOUT_MESSAGE"]
                 delegate:self
                 cancelButtonTitle:[pData getDataForKey:@"DEFINE_METRIX_TITLE_CHECKOUT_CANCEL"]
                 otherButtonTitles:[pData getDataForKey:@"DEFINE_METRIX_TITLE_CHECKOUT_OK"], nil ];
    alertView.tag = wrkBtn.tag;
		[alertView show];
    
    // ボタンを無効化
    [self changeBtnState:(wrkBtn.tag) state:NO];
	}
	else if ( wrkBtn.tag >= 1000){
		
		//チェックイン
		pushedTag = wrkBtn.tag - 1000;
    
		isCheckIN = YES;
		alertView = [[UIAlertView alloc]
                 initWithTitle: [pData getDataForKey:@"DEFINE_METRIX_TITLE_CHECKIN"]
                 message:[pData getDataForKey:@"DEFINE_METRIX_TITLE_CHECKIN_MESSAGE"]
                 delegate:self
                 cancelButtonTitle:[pData getDataForKey:@"DEFINE_METRIX_TITLE_CHECKIN_CANCEL"]
                 otherButtonTitles:[pData getDataForKey:@"DEFINE_METRIX_TITLE_CHECKIN_OK"], nil ];
    alertView.tag = wrkBtn.tag;
		[alertView show];
    
    // ボタンを無効化
    [self changeBtnState:(wrkBtn.tag) state:NO];
	}
	else {
    /*
     SelectViewController *sV = [[SelectViewController alloc]init];
     sV.delegate = self;
     pop = [[UIPopoverController alloc]initWithContentViewController:sV];
     pop.delegate = self;
     pop.popoverContentSize = sV.view.frame.size;
     CGRect rect = wrkBtn.frame;
     UIView *tmp = [wrkBtn superview];
     CGRect frm = tmp.frame;
     frm.origin.y+= 20;
     [pop presentPopoverFromRect:frm inView:scrl permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
     selectedSV = [svList objectAtIndex:wrkBtn.tag];
     */
	}
}

//アラートのボタン押下デリゲート
-(void)alertView:(UIAlertView*)alertViewButon
clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if ( isCheckIN == YES) {
		switch (buttonIndex) {
			case 0:
        NSLog(@"isCheckIN == YES");
        NSLog(@" alertView.tag : %d", alertViewButon.tag);
        NSLog(@" pushedTag : %d", pushedTag);
        // 1000 チェックイン
        if(alertViewButon.tag==1000){
          //チェックイン有効化
          [self changeBtnState:(alertViewButon.tag) state:YES];
        }
				break;
			case 1:
				[self doChkIN:pushedTag];
				break;
			default:
				break;
		}
	}
	else {
		switch (buttonIndex) {
			case 0:
        NSLog(@"isCheckIN == NO");
        NSLog(@" alertView.tag : %d", alertViewButon.tag);
        NSLog(@" pushedTag : %d", pushedTag);
        // 2000 チェックアウト
        if(alertViewButon.tag==2000){
          //チェックアウト有効化
          [self changeBtnState:(alertViewButon.tag) state:YES];
        }
				break;
			case 1:
				[self doChkOUT:pushedTag];
				break;
			default:
				break;
		}
	}
}

/*
 -(void)didSelectOption:(int)opt
 {
 NSLog(@"%d",opt);
 [pop dismissPopoverAnimated:YES];
 
 if ( opt == 0 ) {
 
 //TwitterPage表示
 
 //リクエスト作成
 NSString *url = [NSString stringWithFormat:@"https://twitter.com/%@",selectedSV.twitterAccount];
 NSURL *myURL = [NSURL URLWithString:url];
 NSMutableURLRequest *requestDoc = [[NSMutableURLRequest alloc]initWithURL:myURL];
 
 //viewerViewController内のUIWebviewで表示
 viewerViewController *vView = [[viewerViewController alloc]init];
 [vView setReq:requestDoc];
 
 //ナビゲーションバー　設定
 [self.navigationController.navigationBar setHidden:NO];
 
 //画面遷移
 [self.navigationController pushViewController:vView animated:YES];
 }
 else {
 
 //戻り先を記録
 pData = [publicData instance];
 [pData setData:@"STORE" forKey:@"ReturnScreen"];
 
 //Chatter表示
 chatterViewController *chatter = [[chatterViewController alloc]init];
 [chatter setInitialId:selectedSV.userId];
 [chatter setInitialName:selectedSV.name];
 [chatter setInitialCompnay:cp];
 [chatter setChatterType:1];					//取引先責任者のチャター
 
 //ナビゲーションバー　設定
 [self.navigationController.navigationBar setHidden:NO];
 
 //画面遷移
 [self.navigationController pushViewController:chatter animated:YES];
 }
 }
 */

//NSStringがNull相当の場合、空のNSStringを返す
-(NSString*)isStringEmpty:(NSString*)tgt
{
	if ((( tgt == (NSString *)[NSNull null] ) || ([tgt isEqual:[NSNull null]] ) || ( tgt ==  nil ))){
		NSString *ret = @"";
		return ret;
	}
	return tgt;
	
}
//オブジェクトがNULLであるかチェック
-(BOOL)isNull:(id)tgt
{
	if ((( tgt == [NSNull null] ) || ([tgt isEqual:[NSNull null]] ) || ( tgt ==  nil ))){
		return YES;
	}
	return NO;
}

//チェックイン実行
-(void)doChkIN:(int)index
{
	//責任者名取得
	Person *ps = [svList objectAtIndex:index];
	NSString *name = ps.name;
	
	//ID取得
	NSString *svId =[NSString stringWithFormat:@"chkin_%@",ps.userId];
	
	//
	//新規行動登録
	//
	NSString *path = @"/services/data/v26.0/sobjects/Event/";
	pData = [PublicDatas instance];
	NSString *myName = [pData getDataForKey:@"myName"];
	
	//開始・終了時間
	NSDate *stJPN= [NSDate dateWithTimeIntervalSinceNow:0];
  //	NSDate *edJPN= [NSDate dateWithTimeIntervalSinceNow:+(60*60)];
	
	//登録用フォーマット
	NSDateFormatter *fmt1 = [[NSDateFormatter alloc] init];
	[fmt1 setDateFormat:@"yyyy-MM-dd'T'HH:mm:00Z"];
	
	//オブジェクト名に使用する為のフォーマット
	NSDateFormatter *fmt2 = [[NSDateFormatter alloc] init];
	[fmt2 setDateFormat:@"yyyy-MM-dd_HH:mm:ss"];
	
	//日付を文字列化
	NSString *sttForRegist = [fmt1 stringFromDate:stJPN];
	NSString *sttForObjName = [fmt2 stringFromDate:stJPN];
	
	//投稿用parameter
	//投稿用parameter
	NSString *title = [NSString stringWithFormat:@"%@_%@_%@_%@_%@",[pData getDataForKey:@"DEFINE_METRIX_TITLE_EVENT"],sttForObjName, myName, cp.name,name];
  //	NSString *title = [NSString stringWithFormat:@"行動_%@_%@_%@_%@", sttForObjName, myName, cp.name,name];
	NSDictionary *param;
	if ( positionDetected == YES ){
    
		//位置取得済みであれば、緯度経度を付加する。
		NSString *lat = [NSString stringWithFormat:@"%f",myPos.latitude];
		NSString *lng = [NSString stringWithFormat:@"%f",myPos.longitude];
		param = [NSDictionary dictionaryWithObjectsAndKeys:	title,@"Subject",
             cp.company_id,@"WhatId",
             ps.userId,@"WhoId",
             @"false",@"IsAllDayEvent",
             sttForRegist, @"ActivityDateTime",
             lat,@"GPS_checkin__Latitude__s",
             lng,@"GPS_checkin__Longitude__s",
             sttForRegist,@"timeStamp_checkin__c",
             @"60",@"DurationInMinutes",nil];
	}
	else {
		param = [NSDictionary dictionaryWithObjectsAndKeys:	title,@"Subject",
             cp.company_id,@"WhatId",
             ps.userId,@"WhoId",
             @"false",@"IsAllDayEvent",
             sttForRegist, @"ActivityDateTime",
             @"60",@"DurationInMinutes",nil];
	}
	
	SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodPOST path:path queryParams:param];
	
	[[SFRestAPI sharedInstance] sendRESTRequest:req
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      
                                      //エラーアラート
                                      alertView = [[UIAlertView alloc]
                                                   initWithTitle:[pData getDataForKey:@"DEFINE_METRIX_TITLE_CHECKIN_ERROR"]
                                                   message:[pData getDataForKey:@"DEFINE_METRIX_TITLE_CHECKIN_MESSAGE_ERROR"]
                                                   delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:[pData getDataForKey:@"DEFINE_METRIX_TITLE_CHECKIN_OK_ERROR"], nil ];
                                      [alertView show];
                                      
                                      //失敗時チェックイン有効化
                                      [self changeBtnState:(index+1000) state:YES];
                                    }
                                completeBlock:^(id jsonResponse){
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  NSLog(@"%@",dict);
                                  
                                  NSNumber *success = [dict objectForKey:@"success"];
                                  if ( [success intValue] == 1 ){
                                    checkInID = [dict objectForKey:@"id"];
                                    
                                    //チェックアウトボタン有効化
                                    [self changeBtnState:(index+2000) state:YES];
                                    
                                    //チェックイン無効化
                                    [self changeBtnState:(index+1000) state:NO];
                                    
                                    //チェックインを保存
                                    pData = [PublicDatas instance];
                                    [pData setData:checkInID forKey:svId];
                                    
                                    //成功アラート
                                    alertView = [[UIAlertView alloc]
                                                 initWithTitle:[pData getDataForKey:@"DEFINE_METRIX_TITLE_CHECKIN_SUCCESS"]
                                                 message:[pData getDataForKey:@"DEFINE_METRIX_TITLE_CHECKIN_MESSAGE_SUCCESS"]
                                                 delegate:nil
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:[pData getDataForKey:@"DEFINE_METRIX_TITLE_CHECKIN_OK_SUCCESS"], nil ];
                                    [alertView show];
                                  }
                                  else {
                                    
                                    //失敗アラート
                                    alertView = [[UIAlertView alloc]
                                                 initWithTitle:[pData getDataForKey:@"DEFINE_METRIX_TITLE_CHECKIN_ERROR"]
                                                 message:[pData getDataForKey:@"DEFINE_METRIX_TITLE_CHECKIN_MESSAGE_ERROR"]
                                                 delegate:nil
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:[pData getDataForKey:@"DEFINE_METRIX_TITLE_CHECKIN_OK_ERROR"], nil ];
                                    [alertView show];
                                  }
                                }];
}
-(void)changeBtnState:(int)index state:(BOOL)state
{
	id view;
	id childview;
	for ( view in [scrl subviews]) {
		NSString *className = NSStringFromClass([view class]);
		if ([className isEqualToString:@"UIView"]){
			for ( childview in [view subviews]) {
				NSString *childclassName = NSStringFromClass([childview class]);
				if ([childclassName isEqualToString:@"UIButton"]){
					if (((UIButton*)childview).tag == index) {
						((UIButton*)childview).enabled = state;
						break;
					}
				}
			}
		}
	}
  for ( view in [nameCardCenter subviews]) {
    NSString *className = NSStringFromClass([view class]);
    NSLog(@"classname %@", className);
    if ([className isEqualToString:@"UIButton"]){
      if (((UIButton*)view).tag == index) {
        ((UIButton*)view).enabled = state;
        NSLog(@"tag %d", index);
        NSLog(@"state %d", state);
        NSLog(@"break");
        break;
      }
    }
  }
}

//チェックアウト実行
-(void)doChkOUT:(int)index
{
	//ID取得
	Person *ps = [svList objectAtIndex:index];
	NSString *svId =[NSString stringWithFormat:@"chkin_%@",ps.userId];
  
	//ChkIN IDを取得
	pData = [PublicDatas instance];
	NSString *chkinId =  [pData getDataForKey:svId];
	
	NSString *path = [@"/services/data/v26.0/sobjects/Event/" stringByAppendingString:chkinId];
	
	//開始・終了時間
	NSDate *stJPN= [NSDate dateWithTimeIntervalSinceNow:0];
	
	//登録用フォーマット
	NSDateFormatter *fmt1 = [[NSDateFormatter alloc] init];
	[fmt1 setDateFormat:@"yyyy-MM-dd'T'HH:mm:00Z"];
	
	//日付を文字列化
	NSString *sttForRegist = [fmt1 stringFromDate:stJPN];
	
	//位置取得済みであれば、緯度経度を付加する。
	NSString *lat = [NSString stringWithFormat:@"%f",myPos.latitude];
	NSString *lng = [NSString stringWithFormat:@"%f",myPos.longitude];
	NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:
                         cp.company_id,@"WhatId",
                         lat,@"GPS_checkout__Latitude__s",
                         lng,@"GPS_checkout__Longitude__s",
                         sttForRegist,@"timeStamp_checkout__c",nil];
	
	SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodPATCH path:path queryParams:param];
	
	[[SFRestAPI sharedInstance] sendRESTRequest:req
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      
                                      //エラーアラート
                                      alertView = [[UIAlertView alloc]
                                                   initWithTitle:[pData getDataForKey:@"DEFINE_METRIX_TITLE_CHECKOUT_ERROR"]
                                                   message:[pData getDataForKey:@"DEFINE_METRIX_TITLE_CHECKOUT_MESSAGE_ERROR"]
                                                   delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:[pData getDataForKey:@"DEFINE_METRIX_TITLE_CHECKOUT_OK_ERROR"], nil ];
                                      [alertView show];
                                      //失敗時チェックアウト有効化
                                      [self changeBtnState:(index+2000) state:YES];
                                    }
                                completeBlock:^(id jsonResponse){
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  NSLog(@"%@",dict);
                                  
                                  //チェックイン有効化
                                  [self changeBtnState:(index+1000) state:YES];
                                  
                                  //チェックアウト無効化
                                  [self changeBtnState:(index+2000) state:NO];
                                  
                                  //成功アラート
                                  alertView = [[UIAlertView alloc]
                                               initWithTitle:[pData getDataForKey:@"DEFINE_METRIX_TITLE_CHECKOUT_SUCCESS"]
                                               message:[pData getDataForKey:@"DEFINE_METRIX_TITLE_CHECKOUT_MESSAGE_SUCCESS"]
                                               delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:[pData getDataForKey:@"DEFINE_METRIX_TITLE_CHECKOUT_OK_SUCCESS"], nil ];
                                  
                                  [alertView show];
                                }
	 ];
}

//行動一覧を取得
-(void)getEventList
{
  ObjArray = [NSMutableArray array];
  
	//開始時間
	NSDate *stJPN= [NSDate dateWithTimeIntervalSinceNow:-(24*60*60)];
	NSDateFormatter *fmt1 = [[NSDateFormatter alloc] init];
	[fmt1 setDateFormat:@"yyyy-MM-dd'T'HH:mm:00Z"];
	NSString *sttForRegist = [fmt1 stringFromDate:stJPN];
  
	pData = [PublicDatas instance];
	NSString *myId = [pData getDataForKey:@"myId"];
  
	//24H以内に自分のIDで作成され、チェックインのみの（チェックアウトしてない）オブジェクトを抽出
	NSString *query = [NSString  stringWithFormat:@"SELECT Subject ,Id,StartDateTime from Event WHERE OwnerId ='%@' AND StartDateTime >=%@ AND timestamp_checkin__c <> NULL AND timestamp_Checkout__c = NULL",myId ,sttForRegist ];
	NSLog(@"%@",query);
	SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:query];
	[[SFRestAPI sharedInstance] sendRESTRequest:request
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      
                                      //エラーアラート
                                      alertView = [[UIAlertView alloc]
                                                   initWithTitle:[pData getDataForKey:@"DEFINE_METRIX_TITLE_EVENT_ERROR"]
                                                   message:[pData getDataForKey:@"DEFINE_METRIX_TITLE_EVENT_MESSAGE_ERROR"]
                                                   delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:[pData getDataForKey:@"DEFINE_METRIX_TITLE_EVENT_OK_ERROR"], nil ];
                                      [alertView show];
                                    }
                                completeBlock:^(id jsonResponse){
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  NSLog(@"%@",dict);
                                  NSArray *records = [dict objectForKey:@"records"];
                                  
                                  for ( int i = 0; i < [records count]; i++ ) {
                                    NSDictionary *rec = [records objectAtIndex:i];
                                    [ObjArray addObject:rec];
                                  }
                                  // 名刺のチェックイン／アウト 有効／無効
                                  NSString *pName = [pData getDataForKey:@"PersonName"];
                                  int pIndex = [[pData getDataForKey:@"PersonIndex"] intValue];
                                  NSString *pId = [pData getDataForKey:@"PersonUserId"];
                                  
                                  // 通常
                                  [self changeBtnState:(pIndex+2000) state:NO]; //チェックアウト無効
                                  [self changeBtnState:(pIndex+1000) state:YES];
                                  
                                  NSLog(@"cp.name %@", cp.name);
                                  NSLog(@"pName %@", pName);
                                  
                                  if([um chkString:cp.name] && [um chkString:pName]){
                                    for ( int i =0; i < [ObjArray count]; i++) {
                                      NSDictionary *dic = [ObjArray objectAtIndex:i];
                                      NSString *ObjName = [dic objectForKey:@"Subject"];
                                      NSString *evId = [dic objectForKey:@"Id"];
                                      
                                      NSString *cmp = [[cp.name stringByAppendingString:@"_"]stringByAppendingString:pName];
                                      NSLog(@"cmp %@", cmp);
                                      // DBに名前があればチェックインを無効にする
                                      if ( [self isInclude:ObjName cmp:cmp] == YES ) {
                                        NSLog(@"#################");
                                        
                                        //EventIDを配列に保存する。管理者のIDをキーとする
                                        NSString *svId =[NSString stringWithFormat:@"chkin_%@",pId];
                                        [pData setData:evId forKey:svId];
                                        
                                        NSLog(@"chkOut.tag : %d", pIndex+2000);
                                        NSLog(@"chkIn.tag : %d", pIndex+1000);
                                        NSLog(@"#################");
                                        // ボタンを無効化
                                        [self changeBtnState:(pIndex+2000) state:YES]; //チェックアウト有効
                                        [self changeBtnState:(pIndex+1000) state:NO];
                                        break;
                                      }
                                    }
                                  }
                                }
	 ];
}

//CompanyProfileで住所タップのデリゲート
-(void)didAddressTaped
{
	[btnBuilder dismissMenu];
  
	StoreMapViewController *mapVC;
	mapVC = [[StoreMapViewController alloc]initWithNibName:@"StoreMapViewController" bundle:[NSBundle mainBundle] company:cp ];
	[self.navigationController pushViewController:mapVC animated:NO];
}


//CompanyProfileからLOGO画像をデリゲートで受け取る
-(void)logoImageFound:(UIImage *)img
{
	cp.image = img;
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

//位置取得時のデリゲート
-(void)detectMyPosition:(CLLocationCoordinate2D)pos
{
	myPos = pos;
	positionDetected = YES;
}


// タップ時
-(void)listPushed:(id)sender
{
  
  // メインの辞書をcompany_idのキーで作成し、
  // uiview1,2,3をに対する変数をれぞれ dic1, dic2, dic3 の辞書に格納
  // @"graphIndex"
  // 0: 円グラフ
  // 1: 棒グラフ
  // 2: 折れ線グラフ
  
  // どのビューをタップしたか
  NSString *tagValue = [NSString stringWithFormat:@"%d", [(UIGestureRecognizer *)sender view].tag];
  
  [pData setData:tagValue forKey:@"tag"];
  
  NSMutableArray *familyList = [gm getFamilyList];
  
  if(!familyList.count) return;
  
  // ファミリー選択項目
  [pData setData:familyList forKey:@"familyList"];
  
  CGPoint tapPoint = [sender locationInView:self.view];
  
  //PopOverを消す
  if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
  
  UINavigationController *nav = [[UINavigationController alloc] init];
  
  DashBoardNaviMenuViewController *menu = [[DashBoardNaviMenuViewController alloc] init];
  menu.delegate = self;
  
  [nav pushViewController:menu animated:YES];
  nav.view.frame = CGRectMake(0, 0, 300, 400);
  
	//リストをPopoverで表示
	pop = [[UIPopoverController alloc]initWithContentViewController:nav];
	pop.delegate = self;
	[pop presentPopoverFromRect:CGRectMake(tapPoint.x, tapPoint.y, 0, 0) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
  
}


// OKボタン 円グラフ
- (void)didConfirm
{
  //PopOverを消す
  if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
  
  // 円グラフ描画メソッド
  [self preCircleGraph:[pData getDataForKey:@"tag"]];
}

// 円グラフ描画 前準備
-(void) preCircleGraph:(NSString*)tag
{
  NSMutableDictionary *dic = [gm getDictionaryForTag:tag];
  
  NSString *family = [dic objectForKey:@"family"];
  
  NSString *startYear = [dic objectForKey:@"startYear"];
  NSString *startMonth = [dic objectForKey:@"startMonth"];
  
  NSString *endYear = [dic objectForKey:@"endYear"];
  NSString *endMonth = [dic objectForKey:@"endMonth"];
  
  if(family && startYear && startMonth && endYear && endMonth){
    // 描画するViewを指定
    UIView *baseView;
    NSString *tagValue = tag;
    if([tagValue isEqualToString:@"1"]){
      baseView = _uiview1;
    }else if([tagValue isEqualToString:@"2"]){
      baseView = _uiview2;
    }else{
      baseView = _uiview3;
    }
    
    // 集計終了の月末日
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:[endYear intValue]];
    [comps setMonth:[endMonth intValue]];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *date = [cal dateFromComponents:comps];
    NSRange range = [cal rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    
    // 指定した日付の間でデータを取得する
    NSString *startDate = [NSString stringWithFormat:@"%@-%02d-01", startYear, [startMonth intValue]];
    NSString *endDate = [NSString stringWithFormat:@"%@-%02d-%02d", endYear, [endMonth intValue], range.length];
    
    // 円グラフ描画
    NSLog(@"company_id %@", [pData getDataForKey:@"cp_company_id"]);
    [gm requestDataList:family startDate:startDate endDate:endDate UIView:baseView tag:tag];
  }
}




// 棒グラフ OKボタン
- (void)didConfirmBar
{
  //PopOverを消す
  if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
  
  // 棒グラフ描画
  [self preBarGraph:[pData getDataForKey:@"tag"]];
}

// 棒グラフ描画 前準備
-(void) preBarGraph:(NSString*)tag
{
  // 描画するViewを指定
  UIView *baseView;
  NSString *tagValue = tag;
  if([tagValue isEqualToString:@"1"]){
    baseView = _uiview1;
  }else if([tagValue isEqualToString:@"2"]){
    baseView = _uiview2;
  }else{
    baseView = _uiview3;
  }
  [gm performBarGraph:tag UIView:baseView];
}


// 折れ線グラフ OKボタン
- (void)didConfirmLine
{
  //PopOverを消す
  if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
  
  // 折れ線グラフ描画 前準備
  [self preLineGraph:[pData getDataForKey:@"tag"]];
}

// 折れ線グラフ描画 前準備
-(void) preLineGraph:(NSString*)tag
{
  // 描画するViewを指定
  UIView *baseView;
  NSString *tagValue = tag;
  if([tagValue isEqualToString:@"1"]){
    baseView = _uiview1;
  }else if([tagValue isEqualToString:@"2"]){
    baseView = _uiview2;
  }else{
    baseView = _uiview3;
  }
  [gm performLineGraph:tag UIView:baseView];
}



#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
  return [svList count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
  
  //create new view if no view is available for recycling
  if (view == nil)
  {
    //NSLog(@" svList 1 : %@", svList);
    //取引責任者、部署・約束、住所、チェックイン・アウトボタンを作る
    Person *person = [svList objectAtIndex:index];
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"NameCard" owner:nil options:nil];
    NameCard *nameCard;
    
    for (id currentObject in objects) {
      if ([currentObject isKindOfClass:[NameCard class]]) {
        nameCard = (NameCard*)currentObject;
        nameCard.nameLabel.text = person.name;
        nameCard.departmentLabel.text = [self isStringEmpty:person.belongsto];
        nameCard.positionLabel.text = [self isStringEmpty:person.position];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buildNameCardWindow:)];
        tap.numberOfTapsRequired = 1;    // シングル
        tap.numberOfTouchesRequired = 1;
        nameCard.tag = index;
        [nameCard addGestureRecognizer:tap];
        
      }
      break;
    }
    view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, nameCard.bounds.size.width, nameCard.bounds.size.height+6)];//nameCard.frame];
    //[view.layer setBorderWidth:1.0f];
    //view.layer.borderColor = [[UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f]CGColor];
    [nameCard setFrame:CGRectMake(0, 0, nameCard.bounds.size.width, nameCard.bounds.size.height)];
    [view addSubview:nameCard];
    
    view.backgroundColor = [UIColor whiteColor];
    nameCard.layer.shadowOffset = CGSizeMake(5.0, 5.0);
    nameCard.layer.shadowColor = [UIColor blackColor].CGColor;
    nameCard.layer.shadowOpacity = 0.7f;
    [nameCard.layer setBorderWidth:1.0];
    nameCard.layer.borderColor = [UIColor blackColor].CGColor;
  }
  return view;
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
  //note: placeholder views are only displayed on some carousels if wrapping is disabled
  return 0;
}

- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
  
  //create new view if no view is available for recycling
  if (view == nil)
  {
    Person *person = [svList objectAtIndex:index];
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"NameCard" owner:nil options:nil];
    NameCard *nameCard;
    
    for (id currentObject in objects) {
      if ([currentObject isKindOfClass:[NameCard class]]) {
        nameCard = (NameCard*)currentObject;
        nameCard.nameLabel.text = person.name;
        nameCard.departmentLabel.text = [self isStringEmpty:person.belongsto];
        nameCard.positionLabel.text = [self isStringEmpty:person.position];
      }
      break;
    }
    view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, nameCard.bounds.size.width, nameCard.bounds.size.height+6)];//nameCard.frame];
    //[view.layer setBorderWidth:0.0f];
    //view.layer.borderColor = [[UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f]CGColor];
    [nameCard setFrame:CGRectMake(0, 0, nameCard.bounds.size.width, nameCard.bounds.size.height)];
    [view addSubview:nameCard];
    view.backgroundColor = [UIColor whiteColor];
    nameCard.layer.shadowOffset = CGSizeMake(5.0, 5.0);
    nameCard.layer.shadowColor = [UIColor blackColor].CGColor;
    nameCard.layer.shadowOpacity = 0.7f;
    [nameCard.layer setBorderWidth:1.0];
    nameCard.layer.borderColor = [UIColor blackColor].CGColor;
  }
  return view;
}

- (CATransform3D)carousel:(iCarousel *)_carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
  transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
  return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * carousel.itemWidth);
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
      return value * 1.00f;
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

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
  NSLog(@" index : %d", index);
  //[self buildNameCardWindow:index];
}

// カーソルが変わった場合、該当する商品のグラフを表示
- (void)carouselDidEndScrollingAnimation:(iCarousel *)_carousel;
{
  NSLog(@" chg index : %d", _carousel.currentItemIndex);
}

// 名刺を表示
-(void)buildNameCardWindow:(id)sender
{
  [nameCardCenter removeFromSuperview];
  
  // チェックイン／アウトボタン有効／無効のため
  [self getEventList];
  
  [clearView removeFromSuperview];
  
  [btnBuilder dismissMenu];
  metricsBtn.enabled = NO;
  self.navigationItem.leftBarButtonItem.enabled = NO;
  NSUInteger index = ((UIGestureRecognizer *)sender).view.tag;
  clearView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
  clearView.backgroundColor = [UIColor blackColor];
  clearView.alpha = 0.0;
  UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeNameCardWindow:)];
	closeTap.numberOfTapsRequired = 1;
	[clearView addGestureRecognizer:closeTap];
  [self.view addSubview:clearView];
  
  // 名刺の拡大表示
  NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"NameCardMain" owner:nil options:nil];
  Person *person = [svList objectAtIndex:index];
  
  for (id currentObject in objects) {
    if ([currentObject isKindOfClass:[NameCard class]]) {
      nameCardCenter = (NameCard*)currentObject;
      
      nameCardCenter.nameLabel.text = person.name;
      [pData setData:person.name forKey:@"PersonName"];
      [pData setData:[NSString stringWithFormat:@"%d",index] forKey:@"PersonIndex"];
      [pData setData:person.userId forKey:@"PersonUserId"];
      nameCardCenter.departmentLabel.text = [self isStringEmpty:person.belongsto];
      nameCardCenter.positionLabel.text = [self isStringEmpty:person.position];
      nameCardCenter.addressLabel.numberOfLines = 0;
      [nameCardCenter.addressLabel setLineBreakMode:UILineBreakModeWordWrap];
      
      NSString *addressAndTel = [[[self isStringEmpty:person.address] stringByAppendingString:@"\n"]stringByAppendingString:cp.phone1];
      //		nameCardCenter.addressLabel.text = [self isStringEmpty:person.address];
      nameCardCenter.addressLabel.text = addressAndTel;
      [nameCardCenter.addressLabel sizeToFit];
      //   nameCardCenter.telLabel.text = cp.phone1;
      if([um chkString:person.twitterAccount ]){
        [nameCardCenter.twitterBtn addTarget:self action:@selector(svBtnPushed:) forControlEvents:UIControlEventTouchUpInside];
        nameCardCenter.twitterBtn.tag = index+3000;
      }else{
        nameCardCenter.twitterBtn.hidden = YES;
        nameCardCenter.twitterBtn.enabled = NO;
      }
      
      
      [nameCardCenter.contactChatterBtn addTarget:self action:@selector(svBtnPushed:) forControlEvents:UIControlEventTouchUpInside];
      nameCardCenter.contactChatterBtn.tag = index+4000;
      
      [nameCardCenter.chkInBtn addTarget:self action:@selector(svBtnPushed:) forControlEvents:UIControlEventTouchUpInside];
      nameCardCenter.chkInBtn.tag = index+1000;
      
      [nameCardCenter.chkOutBtn addTarget:self action:@selector(svBtnPushed:) forControlEvents:UIControlEventTouchUpInside];
      nameCardCenter.chkOutBtn.tag = index+2000;
      
      //チェックアウト最初は両方無効にする  getEventListメソッド内で行う
      nameCardCenter.chkOutBtn.enabled = NO;
      nameCardCenter.chkInBtn.enabled = NO;
      
      nameCardCenter.layer.shadowOffset = CGSizeMake(10.0, 10.0);
      nameCardCenter.layer.shadowColor = [UIColor blackColor].CGColor;
      nameCardCenter.layer.shadowOpacity = 0.0f;
    }
    break;
  }
  [nameCardCenter.layer setBorderWidth:1.0f];
  nameCardCenter.layer.borderColor = [[UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f]CGColor];
  nameCardCenter.frame = CGRectMake(0, 0, 200,120);
  nameCardCenter.center = self.storeContactView.center;
  
  [self.view addSubview:nameCardCenter];
  
  UISwipeGestureRecognizer* swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeNameCardWindow:)];
  swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
  [nameCardCenter addGestureRecognizer:swipeGesture];
  
  nameCardCenter.nameLabel.alpha = 0.0;
  nameCardCenter.departmentLabel.alpha = 0.0;
  nameCardCenter.positionLabel.alpha = 0.0;
  nameCardCenter.chkInBtn.alpha = 0.0;
  nameCardCenter.chkOutBtn.alpha = 0.0;
  nameCardCenter.twitterBtn.alpha = 0.0;
  nameCardCenter.contactChatterBtn.alpha = 0.0;
  nameCardCenter.addressLabel.alpha = 0.0;
  nameCardCenter.telLabel.alpha = 0.0;
  
  // フリップ移動前処理
  [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.01];
  nameCardCenter.alpha = 0.5f;
  [UIView setAnimationDidStopSelector:@selector(dispViewAppear:finished:context:)];
	[UIView commitAnimations];
}


// フリップ移動
- (void)dispViewAppear:(NSString *)animationID finished:(NSNumber *) finished context:(void *) context
{
  [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.5];
  clearView.alpha = 0.3;
  nameCardCenter.frame = CGRectMake(clearView.center.x -250, clearView.center.y -140, 500, 300);
  
  nameCardCenter.nameLabel.alpha = 1.0;
  nameCardCenter.departmentLabel.alpha = 1.0;
  nameCardCenter.positionLabel.alpha = 1.0;
  nameCardCenter.chkInBtn.alpha = 1.0;
  nameCardCenter.chkOutBtn.alpha = 1.0;
  nameCardCenter.alpha = 1.0;
  nameCardCenter.layer.shadowOpacity = 0.7f;
  
  [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:nameCardCenter cache:YES];
  [UIView setAnimationDidStopSelector:@selector(dispViewAppear2:finished:context:)];
	[UIView commitAnimations];
}

// フリップ移動後処理
- (void)dispViewAppear2:(NSString *)animationID finished:(NSNumber *) finished context:(void *) context
{
  nameCardCenter.twitterBtn.alpha = 1.0;
  nameCardCenter.contactChatterBtn.alpha = 1.0;
  nameCardCenter.telLabel.alpha = 1.0;
  nameCardCenter.addressLabel.alpha = 1.0;
}

// 名刺を戻す
-(void)closeNameCardWindow:(id)sender
{
  nameCardCenter.twitterBtn.alpha = 0.0;
  nameCardCenter.contactChatterBtn.alpha = 0.0;
  nameCardCenter.telLabel.alpha = 0.0;
  
  // フリップ移動
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:0.5];
  clearView.alpha = 0.0;
  nameCardCenter.alpha = 0.0;
  nameCardCenter.frame = CGRectMake(self.storeContactView.center.x-100, self.storeContactView.center.y-60, 200,120);
  [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:nameCardCenter cache:YES];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(clearViewDisappear:finished:context:)];
  [UIView commitAnimations];
  
}

- (void)clearViewDisappear:(NSString *)animationID finished:(NSNumber *) finished context:(void *) context
{
  nameCardCenter.nameLabel.alpha = 0.0;
  nameCardCenter.departmentLabel.alpha = 0.0;
  nameCardCenter.positionLabel.alpha = 0.0;
  nameCardCenter.chkInBtn.alpha = 0.0;
  nameCardCenter.chkOutBtn.alpha = 0.0;
  
  [clearView removeFromSuperview];
  
  metricsBtn.enabled = YES;
  self.navigationItem.leftBarButtonItem.enabled = YES;
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
	[self setCompanyProfile:nil];
  [self setStoreContactHeader:nil];
	[self setStoreContactView:nil];
  [self setUiview1:nil];
  [self setUiview1:nil];
  [self setUiview2:nil];
  [self setUiview3:nil];
  [self setGraphView:nil];
  [self setGraphTitleView:nil];
  [self setScoredLabel:nil];
  [self setContactsLabel:nil];
  [super viewDidUnload];
}

@end
