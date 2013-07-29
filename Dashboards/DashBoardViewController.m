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


#import "DashBoardViewController.h"
#import "UIBarButtonItem+DesignedButton.h"
#import "BarGraph.h"
#import "GraphData.h"
#import "CircleGraph.h"
#import "LineGrapth.h"

@implementation DashBoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil company:(Company*)cp
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
  
  pData = [PublicDatas instance];
  
  self.title = [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE"];
  
  _graphTitleLabel.text = [pData getDataForKey:@"DEFINE_DASHBOARD_GRAPH_TITLE"];
  _badgeTitleLabel.text = [pData getDataForKey:@"DEFINE_DASHBOARD_BADGE_TITLE"];
  //ナビバータイトル色
	UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:20.0];
	label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	label.textAlignment = NSTextAlignmentCenter;
	label.textColor = [UIColor whiteColor]; // change this color
	self.navigationItem.titleView = label;
	label.text =self.title;
	[label sizeToFit];
  
  //NSLog(@"title %@", self.title);
  // ストアデータは読まない
  [pData setData:@"" forKey:@"company_id"];
  gm = [GraphDataManager sharedInstance];
  // ローディング
  [gm adddLoadingView:_uiview1];
  [gm adddLoadingView:_uiview2];
  [gm adddLoadingView:_uiview3];
  
  [gm requestFamilyList];
  
  um = [UtilManager sharedInstance];
  
  //[fSel setSelectedTab:0];
  //[fSel drawRect:fSel.frame];
  
  //ナビゲーションバーに「戻る」ボタン配置
  UIBarButtonItem *backButton = [[UIBarButtonItem alloc] designedBackBarButtonItemWithTitle:@"" type:0 target:self action:@selector(back)];
  self.navigationItem.leftBarButtonItem = backButton;

  //ナビバー設定
  um = [UtilManager sharedInstance];

  [self.navigationController.navigationBar setHidden:NO];
  NSData *iData =[um navBarType];
  if ( [((NSString*)iData) isEqualToString:@"gray"] ) {
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor grayColor];
    [_graphTitleView setBackgroundColor:[UIColor grayColor]];
    [_badgeTitleView setBackgroundColor:[UIColor grayColor]];
  }
  
  else if ( [((NSString*)iData) isEqualToString:@"black"] ) {
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [_graphTitleView setBackgroundColor:[UIColor blackColor]];
    [_badgeTitleView setBackgroundColor:[UIColor blackColor]];
  }
  else {
    iData =[um navBarImage];
    if ( iData ) {
      UIImage *img = [UIImage imageWithData:iData];
      [self.navigationController.navigationBar setBackgroundImage:img
                                                    forBarMetrics:UIBarMetricsDefault];
      [_graphTitleView setBackgroundColor:[UIColor colorWithPatternImage:img]];
      [_badgeTitleView setBackgroundColor:[UIColor colorWithPatternImage:img]];
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
  
  [self buildScreen];
  
  // 角丸
  CGSize size = CGSizeMake(5.0, 5.0);
  [um makeViewRound:_graphTitleView corners:UIRectCornerTopLeft|UIRectCornerTopRight size:&size];
  [um makeViewRound:_badgeTitleView corners:UIRectCornerTopLeft|UIRectCornerTopRight size:&size];
  [um makeViewRound:_graphView corners:UIRectCornerBottomLeft|UIRectCornerBottomRight size:&size];
  [um makeViewRound:_badgesView corners:UIRectCornerBottomLeft|UIRectCornerBottomRight size:&size];
  
  // バッヂ
  [um makeViewRound:_badge1 corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_badge2 corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_badge3 corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_badge4 corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_badge5 corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_badge6 corners:UIRectCornerAllCorners size:&size];
  
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(listPushed:)];
  tap.numberOfTapsRequired = 1;    // シングル
  tap.numberOfTouchesRequired = 1;
  
  //[graphView addGestureRecognizer:tap];
  
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
  
  
  attachList = [[NSMutableArray alloc] init];
  // メッセージ取得
  NSString *path = @"v27.0/chatter/users/me/groups";
  
  SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodGET path:path queryParams:nil];
  [[SFRestAPI sharedInstance] send:req delegate:self];
  
  um = [UtilManager sharedInstance];
  [_companyProfile setNameLabel:@""];
  [_companyProfile setAddressLabel:@""];
  [_companyProfile setPhoneLabel:@""];
  //[CompanyProfile setLogoImage:nil];
  
  // 認証したユーザー情報にアクセス
  SFAccountManager *sm = [SFAccountManager sharedInstance];
  
  //クエリ作成
  NSString *query = [NSString stringWithFormat:@"SELECT Id, Username, LastName, FirstName, Name, CompanyName, Division, Department, Title, Street, City, State, PostalCode, Country, Email, Phone, Fax FROM User WHERE Id = '%@'", sm.idData.userId];
  NSLog(@"%@",query);
  SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:query];
  //[[SFRestAPI sharedInstance] send:request delegate:self];
  
  //GET実行
	[[SFRestAPI sharedInstance] sendRESTRequest:request failBlock:^(NSError *e) {
		NSLog(@"FAILWHALE with error: %@", [e description] );
	}
                                completeBlock:^(id jsonResponse){
                                  NSArray *records = [jsonResponse objectForKey:@"records"];
                                  NSMutableDictionary *userObj = [[NSMutableDictionary alloc]init];
                                  
                                  for ( NSDictionary *obj in records ) {
                                    //[userObj setValue:[obj valueForKey:@"CompanyName"] forKey:@"CompanyName"];
                                    NSArray *allKeys = [obj allKeys];
                                    for(int i=0; i<[allKeys count]; i++){
                                      //NSLog(@"%@ = %@",[allKeys objectAtIndex:i], [obj valueForKey:[allKeys objectAtIndex:i]]);
                                      [userObj setValue:[obj valueForKey:[allKeys objectAtIndex:i]] forKey:[allKeys objectAtIndex:i]];
                                    }
                                  }
                                  
                                  // 各ラベルにプロフィール割当
                                  if([um chkString:[userObj objectForKey:@"LastName"]] && [um chkString:[userObj objectForKey:@"FirstName"]]){
                                    [_companyProfile setNameLabel:[NSString stringWithFormat:@"%@ %@", [userObj valueForKey:@"LastName"],[userObj valueForKey:@"FirstName"]] ];
                                  }else if([um chkString:[userObj objectForKey:@"LastName"]]){
                                    [_companyProfile setNameLabel:[NSString stringWithFormat:@"%@", [userObj valueForKey:@"LastName"]]];
                                  }
                                  // 住所
                                  if([um chkString:[userObj objectForKey:@"State"]]){
                                    UILabel *clabel = [[UILabel alloc] initWithFrame:CGRectMake(240, 53, 600, 25)];
                                    NSString *str;
                                    //[str stringByAppendingString:[userObj objectForKey:@"CompanyName"]];
                                    str = [userObj objectForKey:@"State"];
                                    if([um chkString:[userObj objectForKey:@"City"]]){
                                      str = [NSString stringWithFormat:@"%@ %@", str, [userObj objectForKey:@"City"]];
                                    }
                                    if([um chkString:[userObj objectForKey:@"Street"]]){
                                      str = [NSString stringWithFormat:@"%@ %@", str, [userObj objectForKey:@"Street"]];
                                    }
                                    clabel.text = str;
                                    [_companyProfile addSubview:clabel];
                                  }
                                  // 電話
                                  if([um chkString:[userObj objectForKey:@"Phone"]]){
                                    [_companyProfile setPhoneLabel:[NSString stringWithFormat:@"%@",[userObj objectForKey:@"Phone"]]];
                                  }else{
                                    //phoneLabel.text = @"Tel:";
                                  }
                                }];
  
  
  // トークンを取得
  NSString *access_token = [[[[SFRestAPI sharedInstance]coordinator]credentials]accessToken];
  
  // URLを指定してHTTPリクエストを生成 プロフィール画像　トークンが必要
  NSString *str = [NSString stringWithFormat:@"%@?oauth_token=%@",[sm.idData.pictureUrl absoluteString], access_token];
  
  NSURL *url = [NSURL URLWithString:str];
  
  // HTTPリクエストオブジェクトを生成
  NSURLRequest *_request = [NSURLRequest
                            requestWithURL:url];
  
  // NSOperationQueueオブジェクトを生成
  NSOperationQueue *queue = [NSOperationQueue mainQueue];
  
  // HTTP非同期通信を行う
  [NSURLConnection sendAsynchronousRequest:_request queue:queue completionHandler:
   // 完了時のハンドラ
   ^(NSURLResponse *res, NSData *data, NSError *error) {
     @try {
       // 取得したデータ
       if(data){
         // 画像として画面に表示
         _companyProfile.logoImage.image = [um resizeImage:[UIImage imageWithData:data] Rect:_companyProfile.logoImage.frame];
         //[UIImage imageWithData:data];
         // 角丸
         CGSize size = CGSizeMake(5.0, 5.0);
         [um makeViewRound:_companyProfile.logoImage corners:UIRectCornerAllCorners size:&size];
         _companyProfile.logoImage.layer.masksToBounds = YES;
         _companyProfile.logoImage.layer.cornerRadius = 5.0;
       }
       if(error){
         NSLog(@"error %@", error);
       }
     }@catch (NSException *exception) {
       NSLog(@"main:Caught %@:%@", [exception name], [exception reason]);
     }@finally {
     }
   }];
}

//-(void)viewWillAppear:(BOOL)animated
-(void)viewDidAppear:(BOOL)animated	
{
  // ファイルからグラフ設定を読み出す
  [gm loadGraphSetting];
  
  // 各ウィンドウごとに変数を格納する辞書を作成
  for(int i=1; i<4; i++){
    NSString *keyStr = [NSString stringWithFormat:@"dic%d", i];
     // データが無ければ作成
    if(![pData getDataForKey:keyStr]){
      NSMutableDictionary *tmp = [gm getPlainGraphData:[NSString stringWithFormat:@"%d", i]];
      [pData setData:tmp forKey:keyStr];
      [gm saveDictionaryFroTag:[NSString stringWithFormat:@"%d", i] Dictionary:tmp];
    }
  }
  
  // ストアID
  [pData setData:@"" forKey:@"cp_company_id"];
  
  // 各ウィンドウごとにグラフを表示
  for(int i=1; i<4; i++){
    NSString *keyStr = [NSString stringWithFormat:@"dic%d", i];
    // データがあればグラフ表示
    if([pData getDataForKey:keyStr]){
      
      // グラフ種別
      NSDictionary *dic = [pData getDataForKey:keyStr];
      NSString *grapthIndex = [dic objectForKey:@"graphIndex"];
      
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

//SOQLのアンサー受信
- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse
{
  
  //NSLog(@"%@", jsonResponse);
  // グループ groupsを解析
  NSArray *groups = [jsonResponse objectForKey:@"groups"];
  //NSLog(@"request:didLoadResponse: #groups: %d", groups.count);
  
  // グループ groupsのフィードを解析
  NSArray *items = [jsonResponse objectForKey:@"items"];
  //NSLog(@"request:didLoadResponse: #items: %d", items.count);
  
  NSArray *records = [jsonResponse objectForKey:@"records"];
  //NSLog(@"request:didLoadResponse: #records: %d", records.count);
  
  // グループ情報の場合
  if(groups>0){
    groupList = [[NSMutableArray alloc] init];
    groupIdList = [[NSMutableArray alloc] init];
    for ( int i = 0; i < [groups count]; i++){
      
      //グループを取得
      NSMutableDictionary *grp = [groups objectAtIndex:i];
      
      //グループ名保存
      NSString *name = [grp objectForKey:@"name"];
      [groupList addObject:name];
      
      //グループID保存
      NSString *gId = [grp objectForKey:@"id"];
      [groupIdList addObject:gId];
    }
    
    // Dashboradのidを取得
    for(int i=0; i<[groupList count]; i++){
      if([[groupList objectAtIndex:i] isEqual:@"Dashboard"]){
        dashboardId = [groupIdList objectAtIndex:i];
        break;
      }
    }
    if(dashboardId){
      // Dashboardのフィードを取得する
      NSString *path = [NSString stringWithFormat:@"v27.0/chatter/feeds/record/%@/feed-items?sort=LastModifiedDateDesc",dashboardId];
      SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodGET path:path queryParams:nil];
      [[SFRestAPI sharedInstance] send:req delegate:self];
    }
  }
  // フィード
  else if([items count]>0){
    feedList = [[NSMutableArray alloc] init];
    //NSMutableArray *attachement = [[NSMutableArray alloc] init];
    
    for ( int i = 0; i< [items count]; i++ ){
      [feedList addObject:[items objectAtIndex:i]];
    }
  }
  else if(records>0){
  }
}



// タップ時
-(void)listPushed:(id)sender
{
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
  
  @try{
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
  }@catch (NSException *exception) {
    NSLog(@"main:Caught %@:%@", [exception name], [exception reason]);
  }
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
  NSString *keyStr = [NSString stringWithFormat:@"dic%@", tag];
  NSMutableDictionary *dic = [pData getDataForKey:keyStr];
  
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



// 画面構成
-(void)buildScreen
{
	um = [UtilManager sharedInstance];

	NSData *iData;

	//バッヂ表示
	iData =[um badge1];
	if ( iData ) {
		UIImage *img = [UIImage imageWithData:iData];
    
		//取得画像にUIImageViewの縦横比をあわせる
		float asp = img.size.height / img.size.width;
		CGRect rect = CGRectMake(_badge1.frame.origin.x, _badge1.frame.origin.y, 100, 101);
		rect.size.height = rect.size.width * asp;
		_badge1.frame = rect;
		[_badge1 setBackgroundImage:img forState:UIControlStateNormal];
	}
	
	iData =[um badge2];
	if ( iData ) {
		UIImage *img = [UIImage imageWithData:iData];
		//取得画像にUIImageViewの縦横比をあわせる
		float asp = img.size.height / img.size.width;
		CGRect rect = CGRectMake(_badge2.frame.origin.x, _badge2.frame.origin.y, 100, 101);
		rect.size.height = rect.size.width * asp;
		_badge2.frame = rect;
		[_badge2 setBackgroundImage:img forState:UIControlStateNormal];
	}
	
	iData =[um badge3];
	if ( iData ) {
		UIImage *img = [UIImage imageWithData:iData];
		//取得画像にUIImageViewの縦横比をあわせる
		float asp = img.size.height / img.size.width;
		CGRect rect = CGRectMake(_badge3.frame.origin.x, _badge3.frame.origin.y, 100, 101);
		rect.size.height = rect.size.width * asp;
		_badge3.frame = rect;
		[_badge3 setBackgroundImage:img forState:UIControlStateNormal];
	}
	
	iData =[um badge4];
	if ( iData ) {
		UIImage *img = [UIImage imageWithData:iData];
		//取得画像にUIImageViewの縦横比をあわせる
		float asp = img.size.height / img.size.width;
		CGRect rect = CGRectMake(_badge4.frame.origin.x, _badge4.frame.origin.y, 100, 101);
		rect.size.height = rect.size.width * asp;
		_badge4.frame = rect;
		[_badge4 setBackgroundImage:img forState:UIControlStateNormal];
	}
	
	iData =[um badge5];
	if ( iData ) {
		UIImage *img = [UIImage imageWithData:iData];
		//取得画像にUIImageViewの縦横比をあわせる
		float asp = img.size.height / img.size.width;
		CGRect rect = CGRectMake(_badge5.frame.origin.x, _badge5.frame.origin.y, 100, 101);
		rect.size.height = rect.size.width * asp;
		_badge5.frame = rect;
		[_badge5 setBackgroundImage:img forState:UIControlStateNormal];
	}

	iData =[um badge6];
	if ( iData ) {
		UIImage *img = [UIImage imageWithData:iData];
		//取得画像にUIImageViewの縦横比をあわせる
		float asp = img.size.height / img.size.width;
		CGRect rect = CGRectMake(_badge6.frame.origin.x, _badge6.frame.origin.y, 100, 101);
		rect.size.height = rect.size.width * asp;
		_badge6.frame = rect;
		[_badge6 setBackgroundImage:img forState:UIControlStateNormal];
	}
	
}

//ナビゲーションバーの「戻る」ボタン処理
-(void)back
{
	[self.navigationController.navigationBar setHidden:YES];
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
  
  [self setUiview1:nil];
  [self setUiview2:nil];
  [self setUiview3:nil];
  [self setBadgesView:nil];
  
  [self setGraphView:nil];
  [self setBadgesView:nil];
  [self setCompanyProfile:nil];
  
  [self setBadge1:nil];
  [self setBadge2:nil];
  [self setBadge3:nil];
  [self setBadge4:nil];
  [self setBadge5:nil];
  [self setBadge6:nil];
  [self setBadgeTitleView:nil];
  [self setGraphTitleView:nil];
	[super viewDidUnload];
}


- (void)dealloc {

}


@end
