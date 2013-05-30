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


#import "ChatterViewController.h"
#import "ViewerViewController.h"
#import "PreviewViewController.h"
#import "MetricsViewController.h"
#import "StoreMapViewController.h"
#import "OrderViewController.h"
#import "PreviewViewController.h"
#import "UtilManager.h"
#import "Person.h"
#import "FeedItem.h"
#import "PublicDatas.h"
#import "MyToolBar.h"
#import "ChatterViewController+Screen.h"
#import "ChatterViewController+Preview.h"
#import "ChatterViewController+Group.h"
#import "ChatterViewController+Util.h"
#import "ChatterViewController+Me.h"
#import "PinDefine.h"

NSString *hasImgPickerStatus = @"NO";

@implementation ChatterViewController

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
  isFirst = YES;
  hasImgPickerStatus = @"NO";
  [super viewDidLoad];
  
  um = [UtilManager sharedInstance];
  pData = [PublicDatas instance];
  CGSize size = CGSizeMake(5.0, 5.0);
  
	btnBuilder = [[BuildNavButtons alloc]initWithCompany:_initialCompnay];
	btnBuilder.delegate = self;
	
	//編集禁止
	self.descriptionTextView.editable = NO;
	
	//添付ファイル管理用配列初期化
	upFileArray = [NSMutableDictionary dictionary];
	upFileEXTArray = [NSMutableDictionary dictionary];
	upFileNameArray = [NSMutableDictionary dictionary];
  
	//タイムライン保存用配列初期化
	myTimeLine = [NSDictionary dictionary];
	
	//アイコン保持用配列初期化
	iconArray = [NSMutableDictionary dictionary];
	
	//ナビバー設定
	[self.navigationController.navigationBar setHidden:NO];
	um = [UtilManager sharedInstance];
	NSData *iData =[um navBarType];
	if ( [((NSString*)iData) isEqualToString:@"gray"] ) {
		[self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
		self.navigationController.navigationBar.tintColor = [UIColor grayColor];
		self.memberHeaderView.backgroundColor = [UIColor grayColor];
		self.fileListHeaderView.backgroundColor = [UIColor grayColor];
		self.postHeaderView.backgroundColor = [UIColor grayColor];
    
		UIView *btnView = [[UIView alloc]initWithFrame:CGRectMake(0,0, 100, 30)];
		btnView.backgroundColor = [UIColor grayColor];
		btnImg = [um convViewToImage:btnView];
	}
	
	else if ( [((NSString*)iData) isEqualToString:@"black"] ) {
		[self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
		self.navigationController.navigationBar.tintColor = [UIColor blackColor];
		self.memberHeaderView.backgroundColor = [UIColor blackColor];
		self.fileListHeaderView.backgroundColor = [UIColor blackColor];
		self.postHeaderView.backgroundColor = [UIColor blackColor];
    
		UIView *btnView = [[UIView alloc]initWithFrame:CGRectMake(0,0, 100, 30)];
		btnView.backgroundColor = [UIColor blackColor];
		btnImg = [um convViewToImage:btnView];
	}
	else {
		iData =[um navBarImage];
		if ( iData ) {
			UIImage *img = [UIImage imageWithData:iData];
			btnImg = img;
			[self.navigationController.navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
			[self.memberHeaderView setBackgroundColor:[UIColor colorWithPatternImage:img]];
			[self.fileListHeaderView setBackgroundColor:[UIColor colorWithPatternImage:img]];
			[self.postHeaderView setBackgroundColor:[UIColor colorWithPatternImage:img]];
		}
	}
  
	//ナビバータイトル
	self.title = [pData getDataForKey:@"DEFINE_CHATTER_TITLE"];
	titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
	titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.textColor = [UIColor whiteColor];
	self.navigationItem.titleView = titleLabel;
	titleLabel.text = self.title;
	[titleLabel sizeToFit];
  
	//タイトル
	UIFont *font = [UIFont boldSystemFontOfSize:20];
	UILabel *postLabel = [[UILabel alloc]initWithFrame:CGRectMake(20,5, 200, 25)];
	postLabel.font = font;
	postLabel.textColor = [UIColor whiteColor];
	postLabel.backgroundColor = [UIColor clearColor];
	[postLabel setText:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_SHARE"]];
	[self.postHeaderView addSubview:postLabel];
  
	memberLabel = [[UILabel alloc]initWithFrame:CGRectMake(20,5, 200, 25)];
	memberLabel.font = font;
	memberLabel.textColor = [UIColor whiteColor];
	memberLabel.backgroundColor = [UIColor clearColor];
	[memberLabel setText:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_MEMBERS"]];
	[self.memberHeaderView addSubview:memberLabel];
  
	UILabel *fileListLabel = [[UILabel alloc]initWithFrame:CGRectMake(20,5, 200, 25)];
	fileListLabel.font = font;
	fileListLabel.textColor = [UIColor whiteColor];
	fileListLabel.backgroundColor = [UIColor clearColor];
	[fileListLabel setText:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_GROUPFILES"]];
	[self.fileListHeaderView addSubview:fileListLabel];
	
	//背景設定
	um = [UtilManager sharedInstance];

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
  
	//投稿用TextViewとボタンを追加
	postInput = [[UITextView alloc]initWithFrame:CGRectMake(10,5, self.postView.frame.size.width - 20, 55)];
	postInput.tag = 65535;
	postInput.layer.borderWidth = 1;
	postInput.layer.cornerRadius = 4;
	postInput.delegate = self;
	postInput.layer.borderColor = [[UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f]CGColor];
	[self.postView addSubview:postInput];
	
	//投稿ボタン
	UIButton *postBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	postBtn.frame = CGRectMake((postInput.frame.origin.x + postInput.frame.size.width) - 100, 65, 100, 30);
	[postBtn setTitle:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_SHARE"] forState:UIControlStateNormal];
	font = [UIFont boldSystemFontOfSize:16];
	[postBtn.titleLabel setFont:font];
	[postBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[postBtn setBackgroundColor:[UIColor colorWithPatternImage:btnImg]];
	postBtn.tag = 65535;
	[postBtn addTarget:self action:@selector(postToFeed:) forControlEvents:UIControlEventTouchUpInside];
  // 角丸
  [um makeViewRound:postBtn corners:UIRectCornerAllCorners size:&size];
	[self.postView addSubview:postBtn];
  
	//ファイル添付ボタン
	UIImage *attachImg = [UIImage imageNamed:@"attachfileicon.png"];
	UIButton *attachBtn = [[UIButton alloc]initWithFrame:CGRectMake(postInput.frame.origin.x + 30, 70, 23, 21)];
	[attachBtn setBackgroundImage:attachImg forState:UIControlStateNormal];
	attachBtn.tag = 65535;
	[attachBtn addTarget:self action:@selector(attachFile:) forControlEvents:UIControlEventTouchUpInside];
	[self.postView addSubview:attachBtn];
  
	//FeedViewにスクロールビューを追加
	scrl = [[UIScrollView alloc]initWithFrame:CGRectMake(10,10,self.feedView.frame.size.width - 20, self.feedView.frame.size.height -20 )];
	scrl.backgroundColor = [UIColor whiteColor];
	scrl.bounces = NO;
  
	//GroupFile欄にスクロールビューを追加
	fileScrl = [[UIScrollView alloc]initWithFrame:CGRectMake(10,10,self.fileListView.frame.size.width - 20 , self.fileListView.frame.size.height - 20 )];
	fileScrl.backgroundColor = [UIColor whiteColor];
	[self.fileListView addSubview:fileScrl];
  
	[self.feedView addSubview:scrl];
	
	//DescriptionLabel初期値
	[_descriptionLabel setText:[pData getDataForKey:@"DEFINE_CHATTER_LABEL_DESCRIPTION"]];
	
	// ローディングアラートを生成
	alertView = [[UIAlertView alloc] initWithTitle:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_LOADING"] message:nil
                                        delegate:nil cancelButtonTitle:nil otherButtonTitles:NULL];
	progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
	progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	[alertView addSubview:progress];
	[progress startAnimating];
  
	[[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillBeHidden:)
                                               name:UIKeyboardWillHideNotification object:nil];
  
  //キーボード表示した時
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  
  //キーボードの初期状態をセット
  NSString *isKeyboard = @"NO";
  pData = [PublicDatas instance];
  [pData  setData:isKeyboard forKey:@"isKeyboard"];
  
  // 角丸
  [um makeViewRound:_descriptionView corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_feedView corners:UIRectCornerAllCorners size:&size];
  
  [um makeViewRound:_postHeaderView corners:UIRectCornerTopLeft|UIRectCornerTopRight size:&size];
  [um makeViewRound:_postView corners:UIRectCornerBottomLeft|UIRectCornerBottomRight size:&size];
  
  [um makeViewRound:_memberHeaderView corners:UIRectCornerTopLeft|UIRectCornerTopRight size:&size];
  [um makeViewRound:_MemberView corners:UIRectCornerBottomLeft|UIRectCornerBottomRight size:&size];
  
  [um makeViewRound:_fileListHeaderView corners:UIRectCornerTopLeft|UIRectCornerTopRight size:&size];
  [um makeViewRound:_fileListView corners:UIRectCornerBottomLeft|UIRectCornerBottomRight size:&size];
  
}

// キーボード表示時にコメント欄が上に表示されるように
- (void)textViewDidBeginEditing:(UITextView *)textView{
  if(textView.tag>40) return;
  scrl.contentOffset = CGPointMake(0, textView.frame.origin.y-100);
}

-(void)viewWillAppear:(BOOL)animated
{
	feedCount = 0;
	
	NSLog(@"self.chatterType %d", self.chatterType);

	[self buildButton];
	
  // TOPから初回
	if ( self.chatterType == ENUM_CHATTERME ) {
    
		//グループ取得
		[self getMyGroup];
		
		[[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"selectGroup"];
		
		toolbar.items = [NSArray arrayWithObjects:space,[[UIBarButtonItem alloc]initWithCustomView:groupBtn],[[UIBarButtonItem alloc]initWithCustomView:reloadBtn], nil];
    
		//ツールバーをナビバーに設置
		self.navigationItem.rightBarButtonItem = toolbarBarButtonItem;
 
		// Chatterのデフォルト表示を「自分がフォローするもの」に
		[self getFirstMyTimeLine:0 url:@"v27.0/chatter/feeds/news/me/feed-items?pageSize=15"];

//		[self getMyTimeLine:0 url:nil]; DEFINE_CHATTER_TITLE_CONNECT
//		isFirst = NO;
		NSString *ttl = [[[pData getDataForKey:@"DEFINE_CHATTER_LABEL_FOLLOW"]
						 stringByAppendingString:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_CONNECT"]]
						  stringByAppendingString:[pData getDataForKey:@"DEFINE_CHATTER_TITLE"]];
		[titleLabel setText:ttl];
		[titleLabel sizeToFit];
		
		//自分の画像を取得
		[self getMyImage];
		
		//自分のIDを取得
		[self getMyId];
    
	}
	else if ( self.chatterType == ENUM_CHATTERCLIENT ) {
    
		//取引先責任者のチャター
    
		[self setInitialId];
    
		//取引先・取引先責任者のSubscriptionIDを取得 (nilの場合はフォローしていない状態)
		[self getSubscriptionId];
		
		//画面タイトル設定
		NSString *ttl = [[[[_initialName stringByAppendingString:@" "]
							stringByAppendingString:_initialCompnay.name]
							stringByAppendingString:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_CONNECT"]]
							stringByAppendingString:[pData getDataForKey:@"DEFINE_CHATTER_TITLE"]];
		[titleLabel setText:ttl];
		[titleLabel sizeToFit];
    
		//ロゴ表示
		UIImage *resize = [self resizeImage:_initialCompnay.image Rect:self.groupImageView.frame];
		self.groupImageView.image = resize;
		CGRect rect = self.groupImageView.frame;
		rect.size = resize.size;
		rect.origin.x = (( self.groupImageView.frame.origin.x + self.groupImageView.frame.size.width ) / 2 ) - ( resize.size.width / 2 );
		self.groupImageView.frame = rect;
    
		//Description Label位置調整
		rect= self.descriptionLabel.frame;
		rect.origin.y = self.groupImageView.frame.origin.y + self.groupImageView.frame.size.height+20;
		self.descriptionLabel.frame = rect;
		
		//Description設定
		NSString *desc = [[[_initialCompnay.name stringByAppendingString:[pData getDataForKey:@"DEFINE_CHATTER_LABEL_NO"]]stringByAppendingString:_initialName]stringByAppendingString:[pData getDataForKey:@"DEFINE_CHATTER_LABEL_ABOUT"]];
		self.descriptionTextView.text = [self stringReplacement:desc];
		rect = self.descriptionTextView.frame;
		rect.origin.y = self.descriptionLabel.frame.origin.y + self.descriptionLabel.frame.size.height + 10;
		self.descriptionTextView.frame = rect;
    
		//Members => Followers に変更する
		[memberLabel setText:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_FOLLOWERS"]];
    
		//自分のIDを取得
		[self getMyId];
    
	}
	else {
		
		//取引先のチャター
		
    [self setInitialId];
    
		//取引先・取引先責任者のSubscriptionIDを取得 (nilの場合はフォローしていない状態)
		[self getSubscriptionId];
    
		//画面タイトル設定
		NSString *ttl = [[_initialCompnay.name stringByAppendingString:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_CONNECT"]]stringByAppendingString:[pData getDataForKey:@"DEFINE_CHATTER_TITLE"]];
		[titleLabel setText:ttl];
		[titleLabel sizeToFit];
    
		//ロゴ表示
		UIImage *resize = [self resizeImage:_initialCompnay.image Rect:self.groupImageView.frame];
		self.groupImageView.image = resize;
		CGRect rect = self.groupImageView.frame;
		rect.size = resize.size;
		rect.origin.x = (( self.groupImageView.frame.origin.x + self.groupImageView.frame.size.width ) / 2 ) - ( resize.size.width / 2 );
		self.groupImageView.frame = rect;
    
		//Description Label位置調整
		rect= self.descriptionLabel.frame;
		rect.origin.y = self.groupImageView.frame.origin.y + self.groupImageView.frame.size.height+20;
		self.descriptionLabel.frame = rect;
		
		//Description設定
		NSString *desc = [_initialCompnay.name stringByAppendingString:[pData getDataForKey:@"DEFINE_CHATTER_LABEL_ABOUTCAHT"]];
		self.descriptionTextView.text = [self stringReplacement:desc];
		rect = self.descriptionTextView.frame;
		rect.origin.y = self.descriptionLabel.frame.origin.y + self.descriptionLabel.frame.size.height + 10;
		self.descriptionTextView.frame = rect;
		
		//Members => Followers に変更する
		[memberLabel setText:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_FOLLOWERS"]];
    
		//自分のIDを取得
		[self getMyId];
	}
	
	//ナビゲーションバーに「戻る」ボタン配置
	if ( _chatterType == 2 ){
		backBtn = [btnBuilder buildBackBtn];
		self.navigationItem.leftBarButtonItem = backBtn;
	}
	else if ( _chatterType == 1 ){
		backBtn = [btnBuilder buildBackStepBtn];
		self.navigationItem.leftBarButtonItem = backBtn;
	}
	else {
		backBtn = [btnBuilder buildHomeStepBtn];
		self.navigationItem.leftBarButtonItem = backBtn;
	}
	
	// ローディング
	[self alertShow];
  
	if ( _chatterType ) {
    NSLog(@"chatterTYpe %d", _chatterType);
		//StoreViewから呼ばれた場合、ここでTLを表示する
		//Feed取得
		[self getMyTimeLine:0 url:nil];
	}
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
-(void)didPushHomeStep
{
	[self.navigationController.navigationBar setHidden:YES];
	[self.navigationController popViewControllerAnimated:YES];
}
-(void)didPushbackStep
{
	[self.navigationController popViewControllerAnimated:YES];
}

//取引責任者・取引先指定（Storeページからの呼び出しで使用）
-(void)setInitialId
{
	currentGroup = _initialId;
	groupBtn.enabled = NO;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)updateBtnPushed:(id)sender {
	//Feed取得
	self.updateBtn.enabled = NO;
	[self getMyTimeLine:0 url:nil];
	self.updateBtn.enabled = YES;
}

-(void)reload
{
	feedCount = 0;
	[self getMyTimeLine:0 url:nil];
	
	//取引先、取引先責任者のチャターの場合、フォロワーを再検索
	if ( _chatterType ) {
		[self getFollowers];
	}
  // 自分の情報
  [self getMyId];
  // 自分の画像
  [self getMyImage];
  // グループ
  [self getMyGroup];
}

//GroupSelect押下時処理
-(void)groupPushed
{
  @try{
    //PopOverを消す
    if(pop.popoverVisible) [pop dismissPopoverAnimated:YES];
    
    //GroupをPopoverで表示
    GroupListPopoverViewController *gList = [[GroupListPopoverViewController alloc]init];
    gList.delegate = self;
    [gList setGroupList:grpArray];
    [gList setGroupIdList:grpIdArray];
    pop = [[UIPopoverController alloc]initWithContentViewController:gList];
    pop.delegate = self;
    pop.popoverContentSize = gList.view.frame.size;
    [pop presentPopoverFromRect:CGRectMake(945, -20,0,0) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
  }@catch (NSException *exception) {
    NSLog(@"main:Caught %@:%@", [exception name], [exception reason]);
  }
}

//グループ選択
-(void)didSelectGroup:(NSString *)groupId
{
  // feedカウントをリセット
  feedCount = 0;
  
	[pop dismissPopoverAnimated:YES];
	
	currentGroup = groupId;
	
	//メンバーリストクリア
	[self clearSubView:self.MemberView];
  
	//メンバーリスト作成
	[self getMemberList];
  
	//グループ説明を取得
	[self getGroupDedcription];
	
	//Feed取得
	//[self getMyTimeLine:0 url:nil];
  
  if(isFirst != YES){
    [self getMyTimeLine:0 url:nil];
  }
  
	//選択したグループを保存
	[[NSUserDefaults standardUserDefaults]setObject:currentGroup forKey:@"selectGroup"];
}

//グループの所属メンバーを取得する
-(void)getMemberList
{
	NSString *path = [NSString stringWithFormat:@"v27.0/chatter/groups/%@/members",currentGroup];
	SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodGET path:path queryParams:nil];
	
	//メンバーリスト初期化
	memberList = [NSMutableArray array];
	
	[[SFRestAPI sharedInstance] sendRESTRequest:req failBlock:^(NSError *e) {
		NSLog(@"FAILWHALE with error: %@", [e description] );
	}
                                completeBlock:^(id jsonResponse){
                                  for (UIView* view in [self.MemberView subviews]){
                                    [view removeFromSuperview];
                                  }
                                  UIScrollView *msv = [[UIScrollView alloc] initWithFrame:self.MemberView.bounds];
                                  msv.backgroundColor = [UIColor whiteColor];
                                  UIView *uv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.MemberView.bounds.size.width, self.MemberView.bounds.size.height)];
                                  uv.backgroundColor = [UIColor whiteColor];
                                  int height = 0;
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  //NSLog(@"dict::%@",dict);
                                  NSArray *members = [dict objectForKey:@"members"];
                                  for ( int i = 0; i< [members count]; i++ ){
                                    NSMutableDictionary *member = [members objectAtIndex:i];
                                    NSMutableDictionary *user = [member objectForKey:@"user"];
                                    NSMutableDictionary *photo = [user objectForKey:@"photo"];
                                    NSString *standardEmailPhotoUrl = [photo objectForKey:@"standardEmailPhotoUrl"];
                                    
                                    Person *pr = [[Person alloc]init];
                                    pr.userId = [user objectForKey:@"id"];
                                    pr.name = [user objectForKey:@"name"];
                                    
                                    if ( [standardEmailPhotoUrl length]) {
                                      NSURL *url = [NSURL URLWithString:standardEmailPhotoUrl];
                                      NSData *data = [NSData dataWithContentsOfURL:url];
                                      UIImage *image = [[UIImage alloc] initWithData:data];
                                      
                                      int x = ((( self.MemberView.frame.size.width - 30 ) / 4 )+5) * ( i % 4 )+5;
                                      int y = (((self.MemberView.frame.size.height - 50 ) / 4 )+15) * ( i / 4 )+5;
                                      
                                      UIButton *memberBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                                      CGRect Rect =  CGRectMake(x, y, 50, 50);
                                      memberBtn.frame = Rect;
                                      memberBtn.tag = i;
									  um = [UtilManager sharedInstance];
									  CGSize size = CGSizeMake(5.0, 5.0);
									  [um makeViewRound:memberBtn corners:UIRectCornerAllCorners size:&size];

                                      [memberBtn setBackgroundImage:[self resizeImage:image Rect:memberBtn.frame]forState:UIControlStateNormal];
                                      [memberBtn addTarget:self action:@selector(memberBtnPushed:) forControlEvents:UIControlEventTouchUpInside];
                                      //[self.MemberView addSubview:memberBtn];
                                      pr.img = image;
                                      [uv addSubview:memberBtn];
                                      height = y +50;
                                    }
                                    [memberList addObject:pr];
                                  }
                                  height = height +5;
                                  [uv setFrame:CGRectMake(0, 0, self.MemberView.bounds.size.width, height)];
                                  msv.contentSize = uv.bounds.size;
                                  [msv addSubview:uv];
                                  [self.MemberView addSubview:msv];
                                }];
}

//フィードを取得
-(void)getFirstMyTimeLine:(float)pos url:(NSString*)url
{
  isFirst = NO;
  
	NSString *path;
  
  addPoint = 0;
  
  // ローディング
  [self alertShow];
  
  //ファイルリストビュークリア
  [self clearSubView:fileScrl];
  fileViewAddPoint = 0;
  
  //取得済みFeedをクリア
  [self clearSubView:scrl];
  
  //FeedID配列をクリア
  feedIdArray = [NSMutableArray array];
  tagNum = 0;
  
  //コメント用TextViewの内容保存用配列をクリア
  commentArray = [NSMutableDictionary dictionary];
  
  //添付管理用配列クリア
  attacheArray = [NSMutableDictionary dictionary];
  attachNum = 0;
  
  path = url;
  
	//受信完了まで待つ
	inWait = YES;
	
	SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodGET path:path queryParams:nil];
	
	[[SFRestAPI sharedInstance] sendRESTRequest:req failBlock:^(NSError *e) {
		NSLog(@"FAILWHALE with error: %@", [e description] );
    
		// アラートを閉じる
		if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
    
		//応答受信済み
		inWait = NO;
	}
                                completeBlock:^(id jsonResponse){
                                  
                                  NSString *nextPageUrl;
                                  if (( url == ( NSString *)[NSNull null] ) || ([url isEqual:[NSNull null]] ) || ( url ==  nil )){
                                    myTimeLine = (NSMutableDictionary *)jsonResponse;
                                    //nextPageUrl = [myTimeLine objectForKey:@"nextPageUrl"];
                                    @try {
                                      nextPageUrl = [myTimeLine objectForKey:@"nextPageUrl"];
                                    }
                                    @catch (NSException *exception) {
                                      NSLog(@"main:Caught %@:%@", [exception name], [exception reason]);
                                    }
                                    @finally {
                                    }
                                    
                                    //NSLog(@"myTimeLine::%@",myTimeLine);
                                    
                                    //1ページ目
                                    [self buildTimeLine:myTimeLine firstPage:YES];
                                    scrl.contentOffset = CGPointMake(0, pos);
                                  }
                                  else {
                                    NSDictionary *otherPages = (NSDictionary *)jsonResponse;
                                    if(otherPages.count){
                                      //nextPageUrl = [otherPages objectForKey:@"nextPageUrl"];
                                      @try {
                                        nextPageUrl = [otherPages objectForKey:@"nextPageUrl"];
                                      }
                                      @catch (NSException *exception) {
                                        NSLog(@"%d", __LINE__);
                                        NSLog(@"main:Caught %@:%@", [exception name], [exception reason]);
                                      }
                                      @finally {
                                      }
                                    }
                                    //NSLog(@"myTimeLine::%@",otherPages);
                                    
                                    //2ページ目以降
                                    [self buildTimeLine:otherPages firstPage:NO];
                                    scrl.contentOffset = CGPointMake(0, pos);
                                  }
                                  //応答受信済み
                                  inWait = NO;
                                  
                                  //次のページ
                                  if (( nextPageUrl != ( NSString *) [NSNull null] ) && (![nextPageUrl isEqual:[NSNull null]])&&(nextPageUrl !=  nil )){
                                    //15件までの読み込みとする
                                    NSLog(@"feed count %d", feedCount);
                                    if (feedCount < FEED_MAX_COUNT) {
                                      [self getMyTimeLine:scrl.contentOffset.y url:nextPageUrl];
                                    }
                                  }
                                  
                                  //受信完了又はタイムアップまで待つ
                                  
                                  while (inWait == YES){
                                    @try {
                                      [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
                                    }
                                    @catch (NSException *exception) {
                                      NSLog(@"%d", __LINE__);
                                      NSLog(@"main:Caught %@:%@", [exception name], [exception reason]);
                                    }
                                  }
                                  
                                  // アラートを閉じる
                                  if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
                                  
                                  //投稿終了
                                  postInProgress = NO;
                                }];
}

//フィードを取得
-(void)getMyTimeLine:(float)pos url:(NSString*)url
{
  
	NSString *path;
  
	//読み込みURLが指定されている場合は、addpointを初期化しない（addPoint以降にコンテンツを追記させる為）
	if (( url == ( NSString *)[NSNull null] ) || ([url isEqual:[NSNull null]] ) || ( url ==  nil )){
		addPoint = 0;
    
		// ローディング
		[self alertShow];
    
		//ファイルリストビュークリア
		[self clearSubView:fileScrl];
		fileViewAddPoint = 0;
    
		//取得済みFeedをクリア
		[self clearSubView:scrl];
		
		//FeedID配列をクリア
		feedIdArray = [NSMutableArray array];
		tagNum = 0;
    
		//コメント用TextViewの内容保存用配列をクリア
		commentArray = [NSMutableDictionary dictionary];
    
		//添付管理用配列クリア
		attacheArray = [NSMutableDictionary dictionary];
		attachNum = 0;
    //		path = [NSString stringWithFormat:@"v27.0/chatter/feeds/record/%@/feed-items",currentGroup];
    if([currentGroup length] == 0){
      switch (_chatterType) {
        case ENUM_CHATTERME:
          path = [NSString stringWithFormat:@"v27.0/chatter/feeds/news/me/feed-items?sort=LastModifiedDateDesc"];
          break;
        case ENUM_CHATTERCLIENT:
          path =
          [NSString stringWithFormat:@"v27.0/chatter/feeds/record/%@/feed-items?sort=LastModifiedDateDesc", self.initialId];
          break;
        case ENUM_CHATTEROTHER:
          path =
          [NSString stringWithFormat:@"v27.0/chatter/feeds/record/%@/feed-items?sort=LastModifiedDateDesc", self.initialId];
          break;
        default:
          break;
      }
    }else{  
			//自分がフォローするもの
			if ([currentGroup isEqualToString:@"Follow"]) {
				path = @"v27.0/chatter/feeds/news/me/feed-items";
				NSString *ttl =[[[pData getDataForKey:@"DEFINE_CHATTER_LABEL_FOLLOW"]
								stringByAppendingString:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_CONNECT"] ]
								stringByAppendingString:[pData getDataForKey:@"DEFINE_CHATTER_TITLE"]];
				[titleLabel setText:ttl];
				[titleLabel sizeToFit];
				[self getMyImage];
			}
			//自分宛
			else if ([currentGroup isEqualToString:@"toMe"]) {
				path = @"v27.0/chatter/feeds/to/me/feed-items";
				NSString *ttl =[[[pData getDataForKey:@"DEFINE_CHATTER_LABEL_TOME"]
								 stringByAppendingString:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_CONNECT"] ]
								stringByAppendingString:[pData getDataForKey:@"DEFINE_CHATTER_TITLE"]];
				[titleLabel setText:ttl];
				[titleLabel sizeToFit];
				[self getMyImage];
			}
		//ブックマーク
			else if ([currentGroup isEqualToString:@"bookMark"]) {
				path = @"v27.0/chatter/feeds/bookmarks/me/feed-items";
				NSString *ttl =[[[pData getDataForKey:@"DEFINE_CHATTER_LABEL_BOOKMARK"]
								 stringByAppendingString:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_CONNECT"] ]
								stringByAppendingString:[pData getDataForKey:@"DEFINE_CHATTER_TITLE"]];
				[titleLabel setText:ttl];
				[titleLabel sizeToFit];
				[self getMyImage];
			}
			//全ての会社
			else if ([currentGroup isEqualToString:@"AllOfCompany"]) {
				path = @"v27.0/chatter/feeds/company/feed-items";
				NSString *ttl =[[[pData getDataForKey:@"DEFINE_CHATTER_LABEL_ALLCOMPANY"]
								 stringByAppendingString:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_CONNECT"] ]
								stringByAppendingString:[pData getDataForKey:@"DEFINE_CHATTER_TITLE"]];
				[titleLabel setText:ttl];
				[titleLabel sizeToFit];
				[self getMyImage];
			}
			//グループ
			else {
				path = [NSString stringWithFormat:@"v27.0/chatter/feeds/record/%@/feed-items?sort=LastModifiedDateDesc",currentGroup];
			}
		}
	}
	else {
		path = url;
	}
  
	//受信完了まで待つ
	inWait = YES;
	
	SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodGET path:path queryParams:nil];
	
	[[SFRestAPI sharedInstance] sendRESTRequest:req failBlock:^(NSError *e) {
		NSLog(@"FAILWHALE with error: %@", [e description] );
    
		// アラートを閉じる
		if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
    
		//応答受信済み
		inWait = NO;
	}
                                completeBlock:^(id jsonResponse){
                                  
                                  NSString *nextPageUrl;
                                  if (( url == ( NSString *)[NSNull null] ) || ([url isEqual:[NSNull null]] ) || ( url ==  nil )){
                                    myTimeLine = (NSMutableDictionary *)jsonResponse;
                                    //nextPageUrl = [myTimeLine objectForKey:@"nextPageUrl"];
                                    @try {
                                      nextPageUrl = [myTimeLine objectForKey:@"nextPageUrl"];
                                    }
                                    @catch (NSException *exception) {
                                      NSLog(@"main:Caught %@:%@", [exception name], [exception reason]);
                                    }
                                    @finally {
                                    }
                                    
                                    //1ページ目
                                    [self buildTimeLine:myTimeLine firstPage:YES];
                                    scrl.contentOffset = CGPointMake(0, pos);
                                  }
                                  else {
                                    NSDictionary *otherPages = (NSDictionary *)jsonResponse;
                                    if(otherPages.count){
                                      //nextPageUrl = [otherPages objectForKey:@"nextPageUrl"];
                                      @try {
                                        nextPageUrl = [otherPages objectForKey:@"nextPageUrl"];
                                      }
                                      @catch (NSException *exception) {
                                        NSLog(@"%d", __LINE__);
                                        NSLog(@"main:Caught %@:%@", [exception name], [exception reason]);
                                      }
                                      @finally {
                                      }
                                    }
                                    //NSLog(@"myTimeLine::%@",otherPages);
                                    
                                    //2ページ目以降
                                    [self buildTimeLine:otherPages firstPage:NO];
                                    scrl.contentOffset = CGPointMake(0, pos);
                                  }
                                  //応答受信済み
                                  inWait = NO;
                                  
                                  //次のページ
                                  if (( nextPageUrl != ( NSString *)[NSNull null] ) && (![nextPageUrl isEqual:[NSNull null]])&&(nextPageUrl !=  nil )){
                                    //15件までの読み込みとする
                                    NSLog(@"feed count %d", feedCount);
                                    if (feedCount < FEED_MAX_COUNT) {
                                      [self getMyTimeLine:scrl.contentOffset.y url:nextPageUrl];
                                    }
                                  }
                                  
                                  //受信完了又はタイムアップまで待つ
                                  
                                  while (inWait == YES){
                                    @try {
                                      [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
                                    }
                                    @catch (NSException *exception) {
                                      NSLog(@"%d", __LINE__);
                                      NSLog(@"main:Caught %@:%@", [exception name], [exception reason]);
                                    }
                                  }
                                  
                                  // アラートを閉じる
                                  if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
                                  
                                  //投稿終了
                                  postInProgress = NO;
                                }];
}

//タイムライン構築
-(void)buildTimeLine:(NSDictionary*)feeds firstPage:(BOOL)first
{
	CGFloat y;
	if ( first == YES ) {
    
		//ファイルリストビュークリア
		[self clearSubView:fileScrl];
		fileViewAddPoint = 0;
    
		y = 20.0f;
		tagNum = 0;
	}
	else {
		y = addPoint;
	}
	NSArray *items = [feeds objectForKey:@"items"];
	for ( int i = 0; i< [items count]; i++ ){
		NSMutableDictionary *item = [items objectAtIndex:i];
		y = [self makeFeedCell:item position:y comment:NO];
		
		//再表示用に保存(再表示は全てPage1として扱うので、重複して保存されることは無い
		if (first == NO && [items count]) {
			[[myTimeLine objectForKey:@"items"]addObject:item];
		}
    feedCount ++;
    if(feedCount>=FEED_MAX_COUNT)break;
    //NSLog(@"item -> %@", item);
	}
	addPoint = y;
}

//タイムライン内の個別の投稿を表示する
-(float)makeFeedCell:(NSMutableDictionary*)ary position:(float)positionY comment:(BOOL)commmentFlag
{
	//Feed格納用
	FeedItem *feed = [[FeedItem alloc]init];
	
	//投稿者情報
	NSDictionary *actor = [ary objectForKey:@"actor"];
	feed.createdDate = [self conv2Tz:[ary objectForKey:@"createdDate"]];
	feed.feedId = [ary objectForKey:@"id"];
	NSDictionary *pre = [ary objectForKey:@"preamble"];
  
	NSNumber *isBookmarked;
	NSString *motifUrl;
	NSString *motifFullURL;
	NSNumber *isDeleteRestricted;
	
	if ( commmentFlag == YES) {
		NSDictionary *user = [ary objectForKey:@"user"];
		NSDictionary *photo = [user objectForKey:@"photo"];
		feed.actorId = [user objectForKey:@"id"];
		feed.actorName = [user objectForKey:@"name"];
		feed.actorStandardEmailPhotoUrl = [photo objectForKey:@"standardEmailPhotoUrl"];
		feed.actorSmallPhotoUrl = [photo objectForKey:@"smallPhotoUrl"];
		feed.actorMediumPhotoUrl = [photo objectForKey:@"mediumPhotoUrl"];
		feed.actorLargePhotoUrl = [photo objectForKey:@"largePhotoUrl"];
		isDeleteRestricted = [ary objectForKey:@"isDeleteRestricted"];
	}
	else {
		NSDictionary *photo = [actor objectForKey:@"photo"];
		feed.actorId = [actor objectForKey:@"id"];
    //		feed.actorName = [actor objectForKey:@"name"];
		feed.actorName = [self stringReplacement:[pre objectForKey:@"text"]];
		feed.actorStandardEmailPhotoUrl = [photo objectForKey:@"standardEmailPhotoUrl"];
		feed.actorSmallPhotoUrl = [photo objectForKey:@"smallPhotoUrl"];
		feed.actorMediumPhotoUrl = [photo objectForKey:@"mediumPhotoUrl"];
		feed.actorLargePhotoUrl = [photo objectForKey:@"largePhotoUrl"];
		isBookmarked = [ary objectForKey:@"isBookmarkedByCurrentUser"];
		
		NSArray *ms = [pre objectForKey:@"messageSegments"];
		NSDictionary *motif = [[ms objectAtIndex:0]objectForKey:@"motif"];
		NSString *instance = [[[[[SFRestAPI sharedInstance] coordinator] credentials] instanceUrl]absoluteString];
    
		motifUrl = [motif objectForKey:@"smallIconUrl"];
		motifFullURL = [NSString stringWithFormat:@"%@%@",instance,motifUrl];
		isDeleteRestricted = [ary objectForKey:@"isDeleteRestricted"];
	}
	
	//本文取得
	NSDictionary *body = [ary objectForKey:@"body"];
	feed.text = [body objectForKey:@"text"];
  
	@try
	{
		feed.text = [feed.text stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
	}
	@catch (NSException *exception)
	{
		NSLog(@"name  :%@",exception.name);
		NSLog(@"reason:%@",exception.reason);
	}
	@try{
		feed.text = [feed.text stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
		}
	@catch (NSException *exception)
	{
		NSLog(@"name  :%@",exception.name);
		NSLog(@"reason:%@",exception.reason);
	}
  
	//コメントの場合はビューをインデントする
	float x;
	if ( commmentFlag == YES) {
		x = 50;
	}
	else {
		x = 0;
	}
	
	//Feed表示用View
	UIView *feedCell = [[UIView alloc]initWithFrame:CGRectMake(x, positionY, scrl.frame.size.width, 0)];
	feedCell.backgroundColor = [UIColor whiteColor];
	CGSize baseSize;
	baseSize.width = scrl.frame.size.width-60;
	baseSize.height = 10;							//仮設定
  
	//使用フォント
	UIFont *font = [UIFont systemFontOfSize:14.0];
  
	@try{
		//画像取得
		if ( [motifFullURL length]) {
			
			NSData *data;
			data = [iconArray objectForKey:motifFullURL];
      
			//画像がキャッシュ済みであればそれを使う
			if (![data length]) {
				NSURL *url = [NSURL URLWithString:motifFullURL];
				data = [NSData dataWithContentsOfURL:url];
				//画像をキャッシュする
				[iconArray setObject:data forKey:motifFullURL];
			}
			UIImage *image = [[UIImage alloc] initWithData:data];
			CGSize siz = image.size;
			NSLog(@"%f:%f", siz.width,siz.height);
			UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(55, 0, 16, 16)];
			imgView.image = image;
			[feedCell addSubview:imgView];
		}
	}
	@catch (NSException *exception)
	{
		NSLog(@"name  :%@",exception.name);
		NSLog(@"reason:%@",exception.reason);
	}
	
	//投稿者ラベル
	UILabel *actorLbl;
	if ( commmentFlag == NO) {
		//actorLbl = [[UILabel alloc]initWithFrame:CGRectMake(74, 0 , (baseSize.width /2 ) + 100, 15 )];
    actorLbl = [[UILabel alloc]initWithFrame:CGRectMake(74, 0 , 220, 15 )];
	}
	else {
		//actorLbl = [[UILabel alloc]initWithFrame:CGRectMake(53, 0 , (baseSize.width /2 ) + 100, 15 )];
    actorLbl = [[UILabel alloc]initWithFrame:CGRectMake(53, 0 , 220, 15 )];
	}
	actorLbl.backgroundColor = [UIColor whiteColor];
	actorLbl.text = feed.actorName;
	actorLbl.font = font;
//	actorLbl.lineBreakMode = NSLineBreakByTruncatingHead;
	actorLbl.lineBreakMode = NSLineBreakByTruncatingTail;
	actorLbl.textAlignment = NSTextAlignmentLeft;
	//[actorLbl sizeToFit];
	
	//投稿時間ラベル
	UILabel *dateLbl = [[UILabel alloc]initWithFrame:CGRectMake((baseSize.width/2)-x + 80, 0, (baseSize.width/2)-60, 15)];
	dateLbl.backgroundColor = [UIColor whiteColor];
	dateLbl.text= feed.createdDate;
	dateLbl.textAlignment = NSTextAlignmentRight;
	dateLbl.font = font;
	[dateLbl sizeToFit];
	
	//textラベルのサイズを求める
	CGRect rect = CGRectMake(55, 15, baseSize.width, baseSize.height);
	UILabel *textlbl = [[UILabel alloc]initWithFrame:rect];
	textlbl.text = [self stringReplacement:feed.text];								//本文設定
	textlbl.lineBreakMode = NSLineBreakByWordWrapping;
	textlbl.numberOfLines = 0;
	[textlbl sizeToFit];
	CGSize textSize = textlbl.frame.size;
	textlbl.backgroundColor =[UIColor whiteColor];
	textlbl.font = font;
	
	//textの大きさに合わせfeedCellのサイズを調整
	CGRect cellFrame = feedCell.frame;
  
	//BookMark追加・解除
	if ( commmentFlag == NO ){
		rect.size.width = 50;
		rect.size.height = 25;
		rect.origin.x = 435;
		rect.origin.y = dateLbl.frame.origin.y-3;
		UIButton *bookMarkBtn;;
		if ( [isBookmarked intValue] == 0) {
			bookMarkBtn = [[UIButton alloc]initWithFrame:rect];
			[bookMarkBtn setTitle:@"＋" forState:UIControlStateNormal];
			bookMarkBtn.tag = tagNum;
			[bookMarkBtn setTitleColor:[UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f] forState:UIControlStateNormal];
			[bookMarkBtn addTarget:self action:@selector(bookMarkAdd:) forControlEvents:UIControlEventTouchUpInside];
			[bookMarkBtn.titleLabel setFont:[UIFont systemFontOfSize:20.0]];
		}
		else {
			bookMarkBtn = [[UIButton alloc]initWithFrame:rect];
			[bookMarkBtn setTitle:@"ー" forState:UIControlStateNormal];
			[bookMarkBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			bookMarkBtn.tag = tagNum;
			[bookMarkBtn setTitleColor:[UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f] forState:UIControlStateNormal];
			[bookMarkBtn addTarget:self action:@selector(bookMarkDel:) forControlEvents:UIControlEventTouchUpInside];
			[bookMarkBtn.titleLabel setFont:[UIFont systemFontOfSize:20.0]];
		}
		[feedCell addSubview:bookMarkBtn];
	}
  
	if ( [isDeleteRestricted intValue] == 0 ){
		rect.size.width = 50;
		rect.size.height = 25;
		if ( commmentFlag == NO ){
			rect.origin.x = 460;
		}
		else {
			rect.origin.x = 410;
		}
		rect.origin.y =dateLbl.frame.origin.y - 5;
		UIButton *delBtn = [[UIButton alloc]initWithFrame:rect];
		delBtn.tag = tagNum;
		[delBtn setTitleColor:[UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f] forState:UIControlStateNormal];
		[delBtn.titleLabel setFont:[UIFont systemFontOfSize:25.0]];
		[delBtn setTitle:@"×" forState:UIControlStateNormal];
		if ( commmentFlag == YES ){
			[delBtn addTarget:self action:@selector(deleteComment:) forControlEvents:UIControlEventTouchUpInside];
		}
		else {
			[delBtn addTarget:self action:@selector(deletePost:) forControlEvents:UIControlEventTouchUpInside];
		}
		[feedCell addSubview:delBtn];
	}
	
	@try{
		//画像取得
		if ( [feed.actorStandardEmailPhotoUrl length]) {
      
			NSData *data;
			data = [iconArray objectForKey:feed.actorId];

			//画像がキャッシュ済みであればそれを使う
			if (![data length]) {
				NSString *imageURL = feed.actorStandardEmailPhotoUrl;
				NSURL *url = [NSURL URLWithString:imageURL];
				data = [NSData dataWithContentsOfURL:url];

				//画像をキャッシュする
				[iconArray setObject:data forKey:feed.actorId];
			}
			UIImage *image = [[UIImage alloc] initWithData:data];
			UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
			imgView.image = image;

			um = [UtilManager sharedInstance];
			CGSize size = CGSizeMake(5.0, 5.0);
			[um makeViewRound:imgView corners:UIRectCornerAllCorners size:&size];
			[feedCell addSubview:imgView];
		}
	}
	@catch (NSException *exception)
	{
		NSLog(@"name  :%@",exception.name);
		NSLog(@"reason:%@",exception.reason);
	}
  
	//添付ファイル
	NSMutableDictionary *attach = [ary objectForKey:@"attachment"];
  
	if  ( ![attach isEqual:[NSNull null]]) {
    //NSLog(@" attr %@", attach);
    
    // 「自分がフォローするもの」の場合、download url が無い場合があるので先にチェックする
    NSString *_downLoadUrl;
    NSString *_thumbnailUrl;
    if([attach count]>0){
      _downLoadUrl = (NSString*)[attach objectForKey:@"downloadUrl"];
      _thumbnailUrl = (NSString*)[attach objectForKey:@"thumbnailUrl"];
      //NSLog(@"thumbnailUrl  %@", _thumbnailUrl );
    }
    
    if(_downLoadUrl != nil && ![_downLoadUrl  isEqual:[NSNull null]]){
      
      //NSLog(@"downLoadUrl %@", _downLoadUrl );
      
      //DownLoadボタン
      UIImage *attachImg = [UIImage imageNamed:@"icon_attachedfile.png"];
      rect.size = attachImg.size;
      rect.origin.x = 60;
      rect.origin.y = textlbl.frame.origin.y + textlbl.frame.size.height + 15;
      UIButton *aBtn = [[UIButton alloc]initWithFrame:rect];
      aBtn.frame = rect;
      [aBtn setBackgroundImage:attachImg forState:UIControlStateNormal];
      aBtn.tag = attachNum;
      [aBtn addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
      
      NSString *fileName = [self stringReplacement:[attach objectForKey:@"title"]];
      UIButton *fileNameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
      cellFrame.size.height = textSize.height + 25;
      
      fileNameBtn.frame = CGRectMake((aBtn.frame.origin.x + aBtn.frame.size.width + 10 ), aBtn.frame.origin.y - 3 ,( feedCell.frame.origin.y + feedCell.frame.size.width ) -90, 20 );
      [fileNameBtn setBackgroundColor:[UIColor clearColor]];
      [fileNameBtn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
      [fileNameBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
      fileNameBtn.tag = attachNum;
      [fileNameBtn addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
      [fileNameBtn.titleLabel setFont:font];
      [fileNameBtn setTitle:fileName forState:UIControlStateNormal];
      
      //左寄せ
      fileNameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
      
      [feedCell addSubview:aBtn];
      [feedCell addSubview:fileNameBtn];
      
      //ダウンロードURLをdictionaryで管理する
      NSString *downLoadUrl = [attach objectForKey:@"downloadUrl"];
      NSString *tag = [NSString stringWithFormat:@"%d",attachNum];
      
      @try {
        if(downLoadUrl!= nil && ![downLoadUrl isEqualToString:@""]){
          [attacheArray setObject:downLoadUrl forKey:tag];
        }
      }
      @catch (NSException *exception) {
        NSLog(@"%d", __LINE__);
        NSLog(@"main:Caught %@:%@", [exception name], [exception reason]);
      }
      @finally {
        
      }
      //GroupFiles欄に追加
      [self addFileView:attachNum text:fileName];
      
      attachNum++;
      
    }else if(_thumbnailUrl != nil && ![_thumbnailUrl isEqual:[NSNull null]]){
      // _thumbnailUrl = (NSString*)[attach objectForKey:@"thumbnailUrl"];
      //DownLoadボタン
      UIImage *attachImg = [UIImage imageNamed:@"icon_attachedfile.png"];
      rect.size = attachImg.size;
      rect.origin.x = 60;
      rect.origin.y = textlbl.frame.origin.y + textlbl.frame.size.height + 15;
      UIButton *aBtn = [[UIButton alloc]initWithFrame:rect];
      aBtn.frame = rect;
      [aBtn setBackgroundImage:attachImg forState:UIControlStateNormal];
      aBtn.tag = attachNum;
      [aBtn addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
      
      NSString *fileName = [self stringReplacement:[attach objectForKey:@"componentName"]];
      UIButton *fileNameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
      cellFrame.size.height = textSize.height + 25;
      
      fileNameBtn.frame = CGRectMake((aBtn.frame.origin.x + aBtn.frame.size.width + 10 ), aBtn.frame.origin.y - 3 ,( feedCell.frame.origin.y + feedCell.frame.size.width ) -90, 20 );
      [fileNameBtn setBackgroundColor:[UIColor clearColor]];
      [fileNameBtn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
      [fileNameBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
      fileNameBtn.tag = attachNum;
      [fileNameBtn addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
      [fileNameBtn.titleLabel setFont:font];
      [fileNameBtn setTitle:fileName forState:UIControlStateNormal];
      
      //左寄せ
      fileNameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
      
      [feedCell addSubview:aBtn];
      [feedCell addSubview:fileNameBtn];
      
      //ダウンロードURLをdictionaryで管理する
      NSString *downLoadUrl = [attach objectForKey:@"fullSizeImageUrl"];
      //NSLog(@" fullSizeImageUrl %@", downLoadUrl);
      NSString *tag = [NSString stringWithFormat:@"%d",attachNum];
      
      @try {
        if(downLoadUrl!= nil && ![downLoadUrl isEqualToString:@""]){
          [attacheArray setObject:downLoadUrl forKey:tag];
          NSLog(@"%@", attacheArray);
        }
      }
      @catch (NSException *exception) {
        NSLog(@"%d", __LINE__);
        NSLog(@"main:Caught %@:%@", [exception name], [exception reason]);
      }
      //GroupFiles欄に追加
      [self addFileView:attachNum text:fileName];
      
      attachNum++;
    }
	}
	else {
		cellFrame.size.height = textSize.height;
	}
  
	//Like(いいね)
	UIImage *likesImg = [UIImage imageNamed:@"likeicon.png"];
	rect.size.width = 22;
	rect.size.height = 22;
	rect.origin.x = 100;
	rect.origin.y = cellFrame.size.height + 30;
	UIButton *likeBtn = [[UIButton alloc]initWithFrame:rect];
	[likeBtn setBackgroundImage:likesImg forState:UIControlStateNormal];
	likeBtn.tag = tagNum;
  
	if ( commmentFlag == YES ) {
		[likeBtn addTarget:self action:@selector(commentLikePost:) forControlEvents:UIControlEventTouchUpInside];
	}
	else {
		[likeBtn addTarget:self action:@selector(feedLikePost:) forControlEvents:UIControlEventTouchUpInside];
	}
	[feedCell addSubview:likeBtn];
  
	//Like数
	NSMutableDictionary *likes = [ary objectForKey:@"likes"];
	NSMutableArray *likes2  = [likes objectForKey:@"likes"];
	int likesNum = [likes2 count];
	UILabel *likeCount = [[UILabel alloc]initWithFrame:CGRectMake((likeBtn.frame.origin.x + likeBtn.frame.size.width +8), rect.origin.y + 8, 100, 10)];
	likeCount.text = [NSString stringWithFormat:@"%d",likesNum];
	likeCount.font = font;
	[feedCell addSubview:likeCount];
	
	cellFrame.size.height+= 40;
	
	[feedCell setFrame:cellFrame];
	[feedCell addSubview:actorLbl];
	[feedCell addSubview:dateLbl];
	[feedCell addSubview:textlbl];
	[scrl addSubview:feedCell];
  
	//戻り値
	float ret = (positionY + feedCell.frame.size.height + 50);
	
	rect = feedCell.frame;
	rect.size.height = ret;
	feedCell.frame = rect;
  
	//FeedID保存
	[feedIdArray addObject:feed.feedId];
  
	//コメント表示処理で、自身(makeFeedCell)に再入する為に、tagNumがズレる対策にローカル変数に保存する
	//この場所以降はtagNumではなくrsvTagを使う事
	int rsvTag = tagNum++;
	
	//残りコメントページ取得
	NSString *nextPageUrl = [[ary objectForKey:@"comments"]objectForKey:@"nextPageUrl"];
	if (( nextPageUrl != ( NSString *)[NSNull null] ) && (![nextPageUrl isEqual:[NSNull null]])&&(nextPageUrl !=  nil )){
		[self retriveOtherComments:nextPageUrl pos:ret addArray:[[ary objectForKey:@"comments"]objectForKey:@"comments"]];
    
		//nextPageURLのコメントデータは元スレッドのデータに追加済みの為、項目削除
		[[ary objectForKey:@"comments"]removeObjectForKey:@"nextPageUrl"];
		ret = addPoint;
	}
  
	//コメント表示
	NSArray *comments = [[ary objectForKey:@"comments"]objectForKey:@"comments"];
	for ( int i = 0 ; i < [comments count]; i++ ){
		NSMutableDictionary *com = [[NSMutableDictionary alloc]initWithDictionary:[comments objectAtIndex:i]];
		ret = [self makeFeedCell:com position:ret comment:YES];
	}
  
	
	//コメント投稿欄
	//UITextViewに枠線を付けるため、一回り大きいViewに載せる
	if ( commmentFlag == NO ) {
		
		NSString *comText = [commentArray objectForKey:[NSString stringWithFormat:@"%d",rsvTag]];
		
    //		UIView *comView  = [[UIView alloc]initWithFrame:CGRectMake(30, ret, scrl.frame.size.width - 60, 80)];
    //		comView.backgroundColor = [UIColor blackColor];
		UITextView *commentInput = [[UITextView alloc]initWithFrame:CGRectMake(30, ret, scrl.frame.size.width - 60, 80)];
		commentInput.tag = rsvTag;
		commentInput.text = comText;
		commentInput.delegate = self;
		commentInput.layer.cornerRadius = 4;
		commentInput.layer.borderWidth = 1;
		commentInput.layer.borderColor = [[UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f]CGColor];
    //		[comView addSubview:commentInput];
		[scrl addSubview:commentInput];
		ret += commentInput.frame.size.height+10;
    
		//ファイル添付ボタン
		UIImage *attachImg = [UIImage imageNamed:@"attachfileicon.png"];
		rect.size = attachImg.size;
		rect.origin.x = ATTACHBTN_XPOS;
		rect.origin.y = ret+5;
		UIButton *attachBtn = [[UIButton alloc]initWithFrame:rect];
		[attachBtn setBackgroundImage:attachImg forState:UIControlStateNormal];
		attachBtn.tag = rsvTag;
		[attachBtn addTarget:self action:@selector(attachFile:) forControlEvents:UIControlEventTouchUpInside];
		[scrl addSubview:attachBtn];
		
		//既に添付ファイルが選択済みの場合
		NSString *rsvTagStr = [NSString stringWithFormat:@"%d",rsvTag];
		NSData *sendData = [upFileArray objectForKey:rsvTagStr];
    
    @try{
      if( [sendData length]){
        
        //ファイル名取得
        NSString *fileName = [[[upFileNameArray objectForKey:rsvTagStr]stringByAppendingString:@"." ]stringByAppendingString:[upFileEXTArray objectForKey:rsvTagStr]];
        
        //ファイル選択済みボタン表示
        UIButton *selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rect.origin.x = 80;
        rect.origin.y = ret+2;
        rect.size.width = 170;
        rect.size.height = 20;
        selectedBtn.titleLabel.font = font;
        selectedBtn.backgroundColor = [UIColor whiteColor];
        [selectedBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //			[selectedBtn setTitle:@"ファイル選択済み" forState:UIControlStateNormal];
        [selectedBtn setTitle:fileName forState:UIControlStateNormal];
        selectedBtn.frame = rect;
        selectedBtn.tag = rsvTag;
        
        //左寄せ
        selectedBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        [selectedBtn addTarget:self action:@selector(previewAttach:) forControlEvents:UIControlEventTouchUpInside];
        [scrl addSubview:selectedBtn];
      }
      
    }
    @catch (NSException *exception)
    {
      NSLog(@"name  :%@",exception.name);
      NSLog(@"reason:%@",exception.reason);
    }
		//投稿ボタン
		UIFont *font = [UIFont boldSystemFontOfSize:16];
		UIButton *postBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		postBtn.frame = CGRectMake((commentInput.frame.origin.x + commentInput.frame.size.width) - 100, ret, 100, 30);
		[postBtn setTitle:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_SHARE"] forState:UIControlStateNormal];
		[postBtn.titleLabel setFont:font];
		[postBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[postBtn setBackgroundColor:[UIColor colorWithPatternImage:btnImg]];
		[postBtn addTarget:self action:@selector(postToFeed:) forControlEvents:UIControlEventTouchUpInside];
		postBtn.tag = rsvTag;
    //		postBtn.layer.cornerRadius = 4;
    // 角丸
    CGSize size = CGSizeMake(5.0, 5.0);
    [um makeViewRound:postBtn corners:UIRectCornerAllCorners size:&size];
		[scrl addSubview:postBtn];
		ret += postBtn.frame.size.height + 50;
	}
	
	rect.size = scrl.contentSize;
	rect.size.height = ret+400;
	[scrl setContentSize:rect.size];
  
	return ret;
}

//コメントの残りページ取得処理
-(float)retriveOtherComments:(NSString*)url pos:(float)pos addArray:(NSMutableArray*)addArray
{
	inWait = YES;
	SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodGET path:url queryParams:nil];
	
	[NSTimer scheduledTimerWithTimeInterval:30.0f
                                   target:self
                                 selector:@selector(timeUp)
                                 userInfo:nil
                                  repeats:NO ];
	
	[[SFRestAPI sharedInstance] sendRESTRequest:req failBlock:^(NSError *e) {
		NSLog(@"FAILWHALE with error: %@", [e description] );
		// アラートを閉じる
		if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
		inWait = NO;
	}
                                completeBlock:^(id jsonResponse){
                                  NSDictionary  *otherCommment = (NSDictionary *)jsonResponse;
                                  NSLog(@"otherCooment::%@",otherCommment);
                                  NSArray *items = [otherCommment objectForKey:@"comments"];
                                  float y = pos;
                                  for ( int i = 0 ; i < [items count] ; i++ ){
                                    y = [self makeFeedCell:[items objectAtIndex:i] position:y comment:YES];
                                    
                                    //コメントデータを元スレッドの配列に追加する(再読み込時にnextPageURLを読み込まずともスレッドを再現出来るようにする）
                                    [addArray addObject:[items objectAtIndex:i]];
                                  }
                                  inWait = NO;
                                  addPoint = y;
                                }];
	
	//受信完了又はタイムアップまで待つ
	while (inWait == YES){
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	}
	return addPoint;
}

//タイムアップ監視用
-(void)timeUp
{
	inWait = NO;
}

-(void)didAttachAborted
{
	[self didAttachCanceld];
}


//ファイル添付押下時処理
-(void)attachFile :(id)sender
{
  
  if([hasImgPickerStatus isEqual: @"HAS"]){
    return;
  }else{
    @try {
      //PopOverを消す
      if(pop.popoverVisible) [pop dismissPopoverAnimated:NO];
      hasImgPickerStatus = @"HAS";
      UIButton *wrkBtn = (UIButton*)sender;
      [scrl endEditing:NO];
      [postInput endEditing:NO];
      [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
      
      //ImagePickerでファイル選択
      if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
      {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [imagePickerController setAllowsEditing:YES];
        [imagePickerController setDelegate:self];
        imagePickerController.tabBarItem.tag = wrkBtn.tag;
        if([hasImgPickerStatus isEqual: @"BACK"]){
          return;
        }else{
          pop = [[UIPopoverController alloc]initWithContentViewController:imagePickerController];
          if ( wrkBtn.tag == 65535 ){
            [pop presentPopoverFromRect:wrkBtn.frame inView:self.postView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
          }
          else {
            [pop presentPopoverFromRect:wrkBtn.frame inView:scrl permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
          }
        }
      }
    }@catch (NSException *exception) {
        NSLog(@"main:Caught %@:%@", [exception name], [exception reason]);
    }
  }
  hasImgPickerStatus = @"NO";
}

//添付ファイル選択時に呼ばれるデリゲート
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  //	NSLog(@"%@",info);
  
	//カレントのtagを保存
	lastSelectTag = picker.tabBarItem.tag;
	
	// オリジナル画像
	UIImage *originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
  
	// 編集画像
	UIImage *editedImage = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
	UIImage *saveImage;
	
	if(editedImage)
	{
		saveImage = editedImage;
	}
	else
	{
		saveImage = originalImage;
	}
  
	NSData *saveData;
	NSString *fileExt;
	NSURL *refUrl = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
	NSString *referenceURL = [refUrl absoluteString];
  
	if ([referenceURL length]){
		NSRange range = [referenceURL rangeOfString:@"PNG"];
		if (range.location != NSNotFound) {
			saveData = [[NSData alloc]initWithData:UIImagePNGRepresentation(saveImage)];
			fileExt = @"png";
		}
		else {
			saveData = [[NSData alloc]initWithData:UIImageJPEGRepresentation(saveImage, 90.0)];
			fileExt = @"jpg";
		}
	}
  
	//日付時刻をデフォルトファイル名とする
	//NSDate *date = [NSDate date];
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	df.dateFormat  = @"yyyyMMdd_HHmmss";
	
	//選択したデータを保存
	NSString *tag = [NSString stringWithFormat:@"%d",picker.tabBarItem.tag];
	[upFileArray setObject:saveData forKey:tag];
	[upFileEXTArray setObject:fileExt forKey:tag];
	[upFileNameArray setObject:[df stringFromDate:[NSDate date]] forKey:tag];
	
	if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
	{
		// カメラから呼ばれた場合は画像をフォトライブラリに保存してViewControllerを閉じる
		UIImageWriteToSavedPhotosAlbum(saveImage, nil, nil, nil);
		[self dismissViewControllerAnimated:YES completion:nil];
	}
	else
	{
		// フォトライブラリから呼ばれた場合はPopOverを閉じる
		[pop dismissPopoverAnimated:YES];
	}
	
	//ファイル名入力用ポップオーバー
	FileNameInputViewController *fInput = [[FileNameInputViewController alloc]init];
	fInput.delegate = self;
	pop = [[UIPopoverController alloc]initWithContentViewController:fInput];
	pop.delegate = self;
	pop.popoverContentSize = fInput.view.frame.size;
	
	//PopOverの外をタップしても消さない為の処理
	NSMutableArray *views = [[NSMutableArray alloc] init];
	[views addObject:self.view];
	pop.passthroughViews = views;
	
	if ( picker.tabBarItem.tag == 65535 ) {
    
		//既に添付ファイルが選択済みの場合
		NSString *tag = [NSString stringWithFormat:@"%d",picker.tabBarItem.tag];
		NSData *sendData = [upFileArray objectForKey:tag];
    
		if( [sendData length]){
      
			//ファイル添付のボタンを探す
			id view;
			for ( view in [self.postView subviews]) {
				NSString *className = NSStringFromClass([view class]);
				if ([className isEqualToString:@"UIButton"]){
					UIButton *tmpBtn = (UIButton*)view;
					if ( tmpBtn.frame.origin.y == 70 ){
						//日付時刻をデフォルトファイル名とする
						[fInput setFileName:[df stringFromDate:[NSDate date]]];
					
						//ファイルネーム入力画面表示
						[pop presentPopoverFromRect:((UIButton*)view).frame inView:self.postView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
          
						//ファイルネーム入力中
						fileNameInputInProgress = YES;
						break;
					}
				}
			}
		}
		return;
	}
	
	//ボタンを探す
	id view;
	for ( view in [scrl subviews]) {
		NSString *className = NSStringFromClass([view class]);
		if ([className isEqualToString:@"UIButton"]){
			if (((UIButton*)view).frame.origin.x == ATTACHBTN_XPOS) {
				if (((UIButton*)view).tag == picker.tabBarItem.tag ) {
          
					//スクロール位置を保存
					float pos = ((UIButton*)view).frame.origin.y - scrl.contentOffset.y ;
					//NSLog(@"%f",pos);
					
					moveValue = 0;
					if ( pos > 110 ) {
						moveValue = pos - 110;
					}
					
					//スクロール領域を広げる
					CGSize area = CGSizeMake( scrl.contentSize.width, scrl.contentSize.height + moveValue);
					scrl.contentSize = area;
					
					//日付時刻をデフォルトファイル名とする
					[fInput setFileName:[df stringFromDate:[NSDate date]]];
					
					//キーボードに隠れないようスクロールする
					CGPoint pt = CGPointMake( scrl.contentOffset.x , scrl.contentOffset.y + moveValue );
					[scrl setContentOffset:pt animated:YES];
					[pop presentPopoverFromRect:((UIButton*)view).frame inView:scrl permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
          
					//ファイルネーム入力中
					fileNameInputInProgress = YES;
					break;
				}
			}
		}
	}
}

//無効なファイル名のデリゲート
-(void)invalidFileName:(NSString *)defaultName
{
	//デフォルトファイル名を保存
	NSString *tag = [NSString stringWithFormat:@"%d",lastSelectTag];
	[upFileNameArray setObject:defaultName forKey:tag];
	fileNameAlertView = [[UIAlertView alloc]
                       initWithTitle:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_FILE_ERROR"]
                       message:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_FILE_MESSAGE_ERROR"]
                       delegate:nil
                       cancelButtonTitle:nil
                       otherButtonTitles:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_FILE_OK_ERROR"], nil ];
	[fileNameAlertView show];
  
	//PopOverを消す
	[pop dismissPopoverAnimated:YES];
  
	//ファイルネーム入力終了
	fileNameInputInProgress = NO;
	
	//投稿(not comment)欄にファイル名のボタン追加
	if ( lastSelectTag == 65535 ) {
		[fileAttachedButton removeFromSuperview];
		
		//ファイル名取得
		NSString *fileName = [[[upFileNameArray objectForKey:tag]stringByAppendingString:@"."]stringByAppendingString:[upFileEXTArray objectForKey:tag]];
		
		//使用フォント
		UIFont *font = [UIFont systemFontOfSize:14.0];
		
		//ファイル選択済みボタン表示
		fileAttachedButton = [UIButton buttonWithType:UIButtonTypeCustom];
		CGRect rect;
		rect.origin.x = 70;
		rect.origin.y = self.postView.frame.size.height - 37;
		rect.size.width = 170;
		rect.size.height = 20;
		fileAttachedButton.titleLabel.font = font;
		fileAttachedButton.backgroundColor = [UIColor clearColor];
		[fileAttachedButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[fileAttachedButton setTitle:fileName forState:UIControlStateNormal];
		
		//左寄せ
		fileAttachedButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		
		fileAttachedButton.frame = rect;
		fileAttachedButton.tag = lastSelectTag;
		[fileAttachedButton addTarget:self action:@selector(previewAttach:) forControlEvents:UIControlEventTouchUpInside];
		
		[self.postView addSubview:fileAttachedButton];
		
		return;
	}
  
	//
	//「ファイル選択済み」を表示させるため、タイムラインを再構築
	//
	
	//スクロール位置を保存
	CGPoint pt;
	pt.x = 0;
	pt.y = scrl.contentOffset.y;
	
	//取得済みFeedをクリア
	[self clearSubView:scrl];
	
	//タイムライン再構築
	[self buildTimeLine:myTimeLine firstPage:YES];
	
	//スクロール位置再設定
	scrl.contentOffset = pt;
}

//添付取りやめ
-(void)didAttachCanceld{
  
	//添付ファイル、ファイル名、拡張子を削除
	NSString *tag = [NSString stringWithFormat:@"%d",lastSelectTag];
	[upFileArray removeObjectForKey:tag];
	[upFileEXTArray removeObjectForKey:tag];
	[upFileNameArray removeObjectForKey:tag];
	
	//PopOverを消す
	[pop dismissPopoverAnimated:YES];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
  
	//ファイルネーム入力中
	fileNameInputInProgress = NO;

	if ( lastSelectTag == 65535 ){
		[fileAttachedButton removeFromSuperview];
		return;
	}
	
	//スクロール位置を保存
	[self alertShow];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	CGPoint pt;
	pt.x = 0;
	pt.y = scrl.contentOffset.y;
	
	//取得済みFeedをクリア
	[self clearSubView:scrl];
	feedCount = 0;

	//タイムライン再構築
	[self buildTimeLine:myTimeLine firstPage:YES];
	
	//スクロール位置再設定
	scrl.contentOffset = pt;
  
	// アラートを閉じる
	if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
}

//ファイル名入力終了時のデリゲート
-(void)didFinishInput:(NSString *)fileName
{
	//ファイル名を保存
	NSString *tag = [NSString stringWithFormat:@"%d",lastSelectTag];
	[upFileNameArray setObject:fileName forKey:tag];
  
	//ファイルネーム入力中
	fileNameInputInProgress = NO;
  
	//PopOverを消す
	[pop dismissPopoverAnimated:NO];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	
	//投稿(not comment)欄にファイル名のボタン追加
	if ( lastSelectTag == 65535 ) {
		[fileAttachedButton removeFromSuperview];
    
		//ファイル名取得
		NSString *fileName = [[[upFileNameArray objectForKey:tag]stringByAppendingString:@"."]stringByAppendingString:[upFileEXTArray objectForKey:tag]];
		
		//使用フォント
		UIFont *font = [UIFont systemFontOfSize:14.0];
		
		//ファイル選択済みボタン表示
		fileAttachedButton = [UIButton buttonWithType:UIButtonTypeCustom];
		CGRect rect;
		rect.origin.x = 70;
		rect.origin.y = self.postView.frame.size.height - 37;
		rect.size.width = 170;
		rect.size.height = 20;
		fileAttachedButton.titleLabel.font = font;
		fileAttachedButton.backgroundColor = [UIColor clearColor];
		[fileAttachedButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[fileAttachedButton setTitle:fileName forState:UIControlStateNormal];
		
		//左寄せ
		fileAttachedButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		fileAttachedButton.frame = rect;
		fileAttachedButton.tag = lastSelectTag;
		[fileAttachedButton addTarget:self action:@selector(previewAttach:) forControlEvents:UIControlEventTouchUpInside];
		[self.postView addSubview:fileAttachedButton];
		
		return;
	}
	
	//
	//ファイル名を表示させるため、タイムラインを再構築
	//
	[self alertShow];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
  
	//スクロール位置を保存
	CGPoint pt;
	pt.x = 0;
	pt.y = scrl.contentOffset.y;
	
	//取得済みFeedをクリア
	[self clearSubView:scrl];
	feedCount = 0;
	//タイムライン再構築
	[self buildTimeLine:myTimeLine firstPage:YES];
  //	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
	
	//スクロール位置再設定
	scrl.contentOffset = pt;
  
	// アラートを閉じる
	if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
}

//グループファイル欄にファイルリストを追加
-(void)addFileView:(int)tag text:(NSString*)text
{
	//使用フォント
	UIFont *font = [UIFont systemFontOfSize:14.0];
	
	CGRect rect;
	UIImage *attachImg = [UIImage imageNamed:@"icon_attachedfile.png"];
	rect.size = attachImg.size;
	rect.origin.x = 0;
	rect.origin.y = fileViewAddPoint + 5;
	UIButton *aBtn = [[UIButton alloc]initWithFrame:rect];
	aBtn.frame = rect;
	[aBtn setBackgroundImage:attachImg forState:UIControlStateNormal];
	aBtn.tag = tag;
	[aBtn addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
	[fileScrl addSubview:aBtn];
  
	UIButton *fileNameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	float x = aBtn.frame.origin.x + aBtn.frame.size.width + 5;
	fileNameBtn.frame = CGRectMake(x, fileViewAddPoint + 5  , fileScrl.frame.size.width -x ,15 );
	[fileNameBtn setBackgroundColor:[UIColor clearColor]];
	[fileNameBtn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
	[fileNameBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	fileNameBtn.tag = tag;
	[fileNameBtn addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
	[fileNameBtn.titleLabel setFont:font];
	[fileNameBtn setTitle:text forState:UIControlStateNormal];
	
	//左寄せ
	fileNameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	
	if ( aBtn.frame.size.height > fileNameBtn.frame.size.height ){
		fileViewAddPoint += aBtn.frame.size.height + 20;
	}
	else {
		fileViewAddPoint += fileNameBtn.frame.size.height + 20;
	}
	[fileScrl addSubview:fileNameBtn];
	
	CGSize cSize = CGSizeMake(self.fileListView.frame.size.width - 20, fileViewAddPoint+50);
	[fileScrl setContentSize:cSize];
  fileScrl.bounces = NO;
}

//コメントに対しLike
-(void)commentLikePost:(id)sender
{
	if( postInProgress == YES) {
		return;
	}
	
	//連投防止
	postInProgress = YES;
	
	//アラート表示
	[self alertShow];
	
	UIButton *wrkBtn = (UIButton*)sender;
	
	//ボタンのtagからFeedIDを求める
	NSString *feedId = [feedIdArray objectAtIndex:wrkBtn.tag];
	
	//リクエスト作成
	NSString *url = [NSString stringWithFormat:@"v27.0/chatter/comments/%@/likes",feedId];
	SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodPOST path:url queryParams:nil];
	
	//POST実行
	[[SFRestAPI sharedInstance] sendRESTRequest:req
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      
                                      // アラートを閉じる
                                      postInProgress = NO;
                                      
                                      if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
                                      
                                    }
                                completeBlock:^(id jsonResponse){
                                  
                                  //スクロール位置を保存
                                  CGPoint pt;
                                  pt.x = 0;
                                  pt.y = scrl.contentOffset.y;
                                  
                                  //取得済みFeedをクリア
                                  [self clearSubView:scrl];
                                  
                                  feedCount = 0;
                                  
                                  //タイムライン再構築
                                  [self getMyTimeLine:pt.y url:nil];
                                  
                                  //スクロール位置再設定
                                  scrl.contentOffset = pt;
                                }];
}

-(void)bookMarkAdd:(id)sender
{
	if( postInProgress == YES) {
		return;
	}
	
	//連投防止
	postInProgress = YES;
  
	UIButton *wrkBtn = (UIButton*)sender;
	
	//ボタンのtagからFeedIDを求める
	NSString *feedId = [feedIdArray objectAtIndex:wrkBtn.tag];
	
	//ブックマーク追加
	[self bookMark:feedId value:YES];
}

-(void)bookMarkDel:(id)sender
{
	if( postInProgress == YES) {
		return;
	}
	
	//連投防止
	postInProgress = YES;
	
	UIButton *wrkBtn = (UIButton*)sender;
	
	//ボタンのtagからFeedIDを求める
	NSString *feedId = [feedIdArray objectAtIndex:wrkBtn.tag];
	
	//ブックマーク追加
	[self bookMark:feedId value:NO];
}


//BookMark設定
-(void)bookMark:(NSString*)feedId value:(BOOL)value
{
  
	NSString *val;
	if ( value == YES) {
		val = @"true";
	}
	else {
		val = @"false";
	}

	
	//投稿用parameter
	NSDictionary *messageSegments = [[NSDictionary alloc]initWithObjectsAndKeys:val, @"isBookmarkedByCurrentUser",nil];
	
	//リクエスト作成
	NSString *url = [NSString stringWithFormat:@"v27.0/chatter/feed-items/%@",feedId];
	SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodPATCH path:url queryParams:messageSegments];
	
	//POST実行
	[[SFRestAPI sharedInstance] sendRESTRequest:req
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      postInProgress = NO;
                                      
                                      // アラートを閉じる
                                      if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
                                    }
                                completeBlock:^(id jsonResponse){
                                  //			NSDictionary  *otherCommment = (NSDictionary *)jsonResponse;
                                  //			NSLog(@"otherCooment::%@",otherCommment);
                                  
                                  if ( value == YES ) {
                                    bookmarkAlert = [[UIAlertView alloc]
                                                     initWithTitle:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_BOOKMARK"]
                                                     message:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_BOOKMARK_MESSAGE"]
                                                     delegate:self
                                                     cancelButtonTitle:nil
                                                     otherButtonTitles:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_BOOKMARK_OK"], nil ];
                                  }
                                  else {
                                    bookmarkAlert = [[UIAlertView alloc]
                                                     initWithTitle:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_BOOKMARK_DEL"]
                                                     message:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_BOOKMARK_DEL_MESSAGE"]
                                                     delegate:self
                                                     cancelButtonTitle:nil
                                                     otherButtonTitles:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_BOOKMARK_DEL_OK"], nil ];
                                  }
                                  [bookmarkAlert show];
                                }
   ];
}

-(void)deletePost:(id)sender
{
  
	if( postInProgress == YES) {
		return;
	}
  
	//連投防止
	postInProgress = YES;
	
	UIButton *wrkBtn = (UIButton*)sender;
	
	//ボタンのtagからFeedIDを求める
	deleteId = [feedIdArray objectAtIndex:wrkBtn.tag];
	
	delAlert =	[[UIAlertView alloc]
               initWithTitle:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_DELETE"]
               message:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_DELETE_MESSAGE"]
               delegate:self
               cancelButtonTitle:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_DELETE_CANCEL"]
               otherButtonTitles:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_DELETE_OK"], nil ];
	[delAlert show];
}

-(void)deleteComment:(id)sender
{
	if( postInProgress == YES) {
		return;
	}
	
	//連投防止
	postInProgress = YES;
	
	UIButton *wrkBtn = (UIButton*)sender;
	
	//ボタンのtagからFeedIDを求める
	deleteId = [feedIdArray objectAtIndex:wrkBtn.tag];
  
	delCommentAlert =	[[UIAlertView alloc]
                     initWithTitle:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_DELETE_COM"]
                     message:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_DELETE_COM_MESSAGE"]
                     delegate:self
                     cancelButtonTitle:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_DELETE_COM_CANCEL"]
                     otherButtonTitles:[pData getDataForKey:@"DEFINE_CHATTER_TITLE_DELETE_COM_OK"], nil ];
	[delCommentAlert show];
  
}


//UIAlertViewのボタン押下デリゲート
-(void)alertView:(UIAlertView *)_alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	postInProgress = NO;
	if ( _alertView == delAlert) {
    
		if ( buttonIndex == 0 ){
      //			NSLog(@"CANCEL");
			return;
		}
		
		else if ( buttonIndex == 1 ){
			//投稿削除
			NSLog(@"OK");
			[self doDelete];
		}
	}
	else if ( _alertView == delCommentAlert){
		if ( buttonIndex == 0 ){
			return;
		}
		else if ( buttonIndex == 1 ){
			//コメント削除
			[self doDeleteComment];
		}
	}
	else if ( _alertView == bookmarkAlert ){
		[self didAlertOKPushed];
	}
}

-(void)doDelete
{
	//リクエスト作成
	NSString *url = [NSString stringWithFormat:@"v27.0/chatter/feed-items/%@",deleteId];
	SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodDELETE path:url queryParams:nil];
	
	//POST実行
	[[SFRestAPI sharedInstance] sendRESTRequest:req
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      postInProgress = NO;
                                      
                                      // アラートを閉じる
                                      if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
                                    }
                                completeBlock:^(id jsonResponse){
                                  [self didAlertOKPushed];
                                }
   ];
}

-(void)doDeleteComment
{
	
	//リクエスト作成
	NSString *url = [NSString stringWithFormat:@"v27.0/chatter/comments/%@",deleteId];
	SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodDELETE path:url queryParams:nil];
	
	//POST実行
	[[SFRestAPI sharedInstance] sendRESTRequest:req
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      postInProgress = NO;
                                      
                                      // アラートを閉じる
                                      if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
                                    }
                                completeBlock:^(id jsonResponse){
                                  //			NSDictionary  *otherCommment = (NSDictionary *)jsonResponse;
                                  //			NSLog(@"otherCooment::%@",otherCommment);
                                  [self didAlertOKPushed];
                                }
   ];
}

-(void)didAlertOKPushed
{
	//スクロール位置を保存
	float pt = scrl.contentOffset.y;
	
	//取得済みFeedをクリア
	[self clearSubView:scrl];
	
	feedCount = 0;
	
	//タイムライン再構築
	[self getMyTimeLine:pt url:nil];
}

//フィードに対しLike
-(void)feedLikePost:(id)sender
{
	if( postInProgress == YES) {
		return;
	}
  
	//連投防止
	postInProgress = YES;
	
	//アラート表示
	[self alertShow];
	
	UIButton *wrkBtn = (UIButton*)sender;
  
	//ボタンのtagからFeedIDを求める
	NSString *feedId = [feedIdArray objectAtIndex:wrkBtn.tag];
  
	//リクエスト作成
	NSString *url = [NSString stringWithFormat:@"v27.0/chatter/feed-items/%@/likes",feedId];
	SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodPOST path:url queryParams:nil];
	
	//POST実行
	[[SFRestAPI sharedInstance] sendRESTRequest:req
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      
                                      // アラートを閉じる
                                      if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
                                    }
                                completeBlock:^(id jsonResponse){
                                  
                                  //スクロール位置を保存
                                  float pt = scrl.contentOffset.y;
                                  
                                  //取得済みFeedをクリア
                                  [self clearSubView:scrl];
                                  
                                  feedCount = 0;
                                  
                                  //タイムライン再構築
                                  [self getMyTimeLine:pt url:nil];
                                  
                                }];
}

-(void)follow
{
	if( postInProgress == YES) {
		return;
	}
	
	//連投防止
	postInProgress = YES;
  
	//投稿用parameter
	NSDictionary *param = [[NSDictionary alloc]initWithObjectsAndKeys:currentGroup,@"subjectId",nil];
	
	//リクエスト作成
	NSString *url = @"v27.0/chatter/users/me/following";
	SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodPOST path:url queryParams:param];
	
	//POST実行
	[[SFRestAPI sharedInstance] sendRESTRequest:req
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      postInProgress = NO;
                                      
                                      // アラートを閉じる
                                      if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
                                    }
                                completeBlock:^(id jsonResponse){
                                  [self getSubscriptionId];
                                  postInProgress = NO;
                                  
                                  UIAlertView *alt = [[UIAlertView alloc]
                                                      initWithTitle:[pData getDataForKey:
                                                                     @"DEFINE_CHATTER_TITLE_FOLLOW"]
                                                      message:[pData getDataForKey:
                                                      @"DEFINE_CHATTER_TITLE_FOLLOW_MESSAGE"]
                                                      delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:[pData getDataForKey:
                                                                         @"DEFINE_CHATTER_TITLE_FOLLOW_OK"], nil ];
                                  [alt show];
                                  [self getFollowers];
                                }
	 ];
}

-(void)unFollow
{
	if( postInProgress == YES) {
		return;
	}
	
	//連投防止
	postInProgress = YES;
	
	//投稿用parameter
  //	NSDictionary *param = [[NSDictionary alloc]initWithObjectsAndKeys:currentGroup,@"subjectId",nil];
	
	//リクエスト作成
	NSString *url = [NSString stringWithFormat:@"v27.0/chatter/subscriptions/%@",currentSubscriptionId];
	SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodDELETE path:url queryParams:nil];
	
	//POST実行
	[[SFRestAPI sharedInstance] sendRESTRequest:req
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      postInProgress = NO;
                                      
                                      // アラートを閉じる
                                      if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
                                    }
                                completeBlock:^(id jsonResponse){
                                  [self getSubscriptionId];
                                  postInProgress = NO;

									UIAlertView *alt = [[UIAlertView alloc]
                                                      initWithTitle:[pData getDataForKey:
                                                                     @"DEFINE_CHATTER_TITLE_REMOVE"]
                                                      message:[pData getDataForKey:
                                                               @"DEFINE_CHATTER_TITLE_REMOVE_MESSAGE"]
                                                      delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:[pData getDataForKey:
                                                                         @"DEFINE_CHATTER_TITLE_REMOVE_OK"], nil ];
                                  [alt show];
                                  [self getFollowers];
                                }
   ];
}

-(void)getSubscriptionId
{
	//リクエスト作成
	NSString *url = @"v27.0/chatter/users/me/following?pageSize=1000";
	SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodGET path:url queryParams:nil];
	
	currentSubscriptionId = @"";
	
	//POST実行
	[[SFRestAPI sharedInstance] sendRESTRequest:req
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      
                                      // アラートを閉じる
                                      if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
                                    }
                                completeBlock:^(id jsonResponse){
                                  NSDictionary  *records = (NSDictionary *)jsonResponse;
                                  NSLog(@"following::%@",records);
                                  NSNumber *total = [records objectForKey:@"total"];
                                  
                                  if ( 0 != [total intValue]){
                                    NSArray *flw = [records objectForKey:@"following"];
                                    for ( int i = 0; i < [flw count]; i++ ){
                                      NSDictionary *rec = [flw objectAtIndex:i];
                                      NSDictionary *subject = [rec objectForKey:@"subject"];
                                      NSString *cpId = [subject objectForKey:@"id"];
                                      NSDictionary *mySubscription = [subject objectForKey:@"mySubscription"];
                                      NSString *subscriptionId = [mySubscription objectForKey:@"id"];
                                      /*
                                      NSLog(@"companyname : %@", [subject objectForKey:@"companyName"]);
                                      NSLog(@"Name : %@ %@", [subject objectForKey:@"firstName"], [subject objectForKey:@"lastName"]);
                                      NSLog(@"self.chatterType : %d", self.chatterType);
                                      NSLog(@"cpId : %@", cpId);
                                      NSLog(@"currentSubscriptionId : %@", currentSubscriptionId);
                                      NSLog(@"---------------------");
                                      */
                                      if ( [currentGroup isEqualToString:cpId] ) {
                                        currentSubscriptionId = subscriptionId;
                                        break;
                                      }
                                    }
                                  }
                                  
                                  //ナビバーボタンを設定
                                  [self buildToolBar];
                                  
                                  //Follower取得・画像表示
                                  [self getFollowers];
                                }
	 ];
}

-(void)getFollowers
{
	//メンバーリストクリア
	[self clearSubView:self.MemberView];
	
	//リクエスト作成
	NSString *url = [NSString stringWithFormat:@"v27.0/chatter/records/%@/followers",currentGroup];
	SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodGET path:url queryParams:nil];
  
	//メンバーリスト初期化
	memberList = [NSMutableArray array];
	
	//POST実行
	[[SFRestAPI sharedInstance] sendRESTRequest:req
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      
                                      // アラートを閉じる
                                      if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
                                    }
                                completeBlock:^(id jsonResponse){
                                  NSDictionary  *records = (NSDictionary *)jsonResponse;
                                  NSLog(@"record::%@",records);
                                  NSNumber *total = [records objectForKey:@"total"];
                                  
                                  if ( 0 != [total intValue]){
                                    NSArray *flws = [records objectForKey:@"followers"];
                                    for( int i = 0; i < [flws count]; i++ ) {
                                      NSDictionary *flw = [flws objectAtIndex:i];
                                      NSDictionary *subscriber = [flw objectForKey:@"subscriber"];
                                      NSDictionary *photo = [subscriber objectForKey:@"photo"];
                                      NSString *standardEmailPhotoUrl = [photo objectForKey:@"standardEmailPhotoUrl"];
                                      
                                      Person *pr = [[Person alloc]init];
                                      pr.userId = [subscriber objectForKey:@"id"];
                                      pr.name = [subscriber objectForKey:@"name"];
                                      
                                      if ( [standardEmailPhotoUrl length]) {
                                        NSURL *url = [NSURL URLWithString:standardEmailPhotoUrl];
                                        NSData *data = [NSData dataWithContentsOfURL:url];
                                        UIImage *image = [[UIImage alloc] initWithData:data];
                                        
                                        int x = ((( self.MemberView.frame.size.width - 30 ) / 4 )+5) * ( i % 4 )+5;
                                        int y = (((self.MemberView.frame.size.height - 50 ) / 4 )+15) * ( i / 4 )+5;
                                        
                                        UIButton *memberBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                                        CGRect Rect =  CGRectMake(x, y, 50, 50);
                                        memberBtn.frame = Rect;
                                        memberBtn.tag = i;
										  
										um = [UtilManager sharedInstance];
										CGSize size = CGSizeMake(5.0, 5.0);
										[um makeViewRound:memberBtn corners:UIRectCornerAllCorners size:&size];

                                        [memberBtn setBackgroundImage:[self resizeImage:image Rect:memberBtn.frame]forState:UIControlStateNormal];
                                        [memberBtn addTarget:self action:@selector(memberBtnPushed:) forControlEvents:UIControlEventTouchUpInside];
                                        [self.MemberView addSubview:memberBtn];
                                        pr.img = image;
                                      }
                                      [memberList addObject:pr];
                                    }
                                  }
                                }
	 ];
}

//添付ファイルダウンロード押下時処理
-(void)download:(id)sender
{
  NSLog(@"attacheArray %@", attacheArray);
  
	UIButton *wrkBtn = (UIButton*)sender;
	
	//メニュー消去
	[btnBuilder dismissMenu];
	
	//ボタンのtagからTextViewの内容を求める
	NSString *tag = [NSString stringWithFormat:@"%d",wrkBtn.tag];
	NSString *downloadUrl = [attacheArray objectForKey:tag];
  
	[pop dismissPopoverAnimated:YES];
	
	//リクエスト作成
	//SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodGET path:downloadUrl queryParams:nil];
	NSString *instance = [[[[[SFRestAPI sharedInstance] coordinator] credentials] instanceUrl]absoluteString];
	NSString *fullUrl = [instance stringByAppendingString:downloadUrl];
	NSURL *myURL = [NSURL URLWithString:fullUrl];
	NSMutableURLRequest *requestDoc = [[NSMutableURLRequest alloc]initWithURL:myURL];
  
	//OAuth認証情報をヘッダーに追加
	NSString *token = [@"OAuth " stringByAppendingString:[[[[SFRestAPI sharedInstance]coordinator]credentials]accessToken]];
	[requestDoc addValue:token forHTTPHeaderField:@"Authorization"];
  //	[NSURLConnection connectionWithRequest:requestDoc delegate:self];
  
	//viewerViewController内のUIWebviewで表示
	ViewerViewController *vView = [[ViewerViewController alloc]init];
	[vView setReq:requestDoc];
	[self.navigationController pushViewController:vView animated:YES];
}

//コメント/新規フィードを投稿
-(void)postToFeed:(id)sender
{
	
	if (( fileNameInputInProgress == YES ) || ( postInProgress == YES )){
		NSLog(@"@exit");
		return;
	}
	
	//投稿処理中（連投防止）
	postInProgress = YES;
	
	UIButton *wrkBtn = (UIButton*)sender;
  
	//ボタンのtagからTextViewの内容を求める
	NSString *tag = [NSString stringWithFormat:@"%d",wrkBtn.tag];
	NSString *commentText = [commentArray objectForKey:tag];
	
  // 空対策
  if([commentText isEqualToString:@""] || commentText==nil){
    postInProgress = NO;
    return;
  }
	//添付ファイル処理
  NSLog(@"file----");
	NSData *sendData = [upFileArray objectForKey:tag];
	if( [sendData length])
	{
		//
		//添付ファイル付き投稿
		//
		
    @try{
      //JSONで投稿するため、改行をエスケープする
      if(commentText==Nil){
        commentText =@"";
      }
      commentText = [commentText stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    }
    @catch (NSException *exception)
    {
      //NSLog(@"name  :%@",exception.name);
      //NSLog(@"reason:%@",exception.reason);
    }
    
		NSError *error = nil;
		
		NSString *access_token = [[[[SFRestAPI sharedInstance]coordinator]credentials]accessToken];
		NSString *instance_url = [[[[[SFRestAPI sharedInstance] coordinator] credentials] instanceUrl]absoluteString];
    
		NSString *header = [NSString stringWithFormat:@"OAuth %@", access_token];
    
		NSString *feedId;
		NSString *urlStr;
    
		if ( wrkBtn.tag != 65535 ){
			feedId = [feedIdArray objectAtIndex:wrkBtn.tag];
			urlStr = [NSString stringWithFormat:@"%@/services/data/v25.0/chatter/feed-items/%@/comments",instance_url, feedId];
		}
		else {
      
      if(currentGroup){
        urlStr = [NSString stringWithFormat:@"%@/services/data/v25.0/chatter/feeds/record/%@/feed-items",instance_url, currentGroup];
      }
			else {
				
				if (([currentGroup isEqualToString:@"Follow"]) ||
            ([currentGroup isEqualToString:@"toMe"]) ||
            ([currentGroup isEqualToString:@"bookMark"]) ||
            ([currentGroup isEqualToString:@"AllOfCompany"])) {
					
					urlStr = [NSString stringWithFormat:@"%@/services/data/v25.0/chatter/feeds/to/me/feed-items",instance_url];
				}
				else {
					switch (_chatterType) {
						case ENUM_CHATTERME:
							myId = myInfo.userId;
							urlStr = [NSString stringWithFormat:@"%@/services/data/v25.0/chatter/feeds/news/%@/feed-items",instance_url,myId];
							break;
						case ENUM_CHATTERCLIENT:
							myId = self.initialId;
							urlStr = [NSString stringWithFormat:@"%@/services/data/v25.0/chatter/feeds/record/%@/feed-items/",instance_url,myId];
							break;
						case ENUM_CHATTEROTHER:
							myId = self.initialId;
							urlStr = [NSString stringWithFormat:@"%@/services/data/v25.0/chatter/feeds/record/%@/feed-items/",instance_url,myId];
							break;
						default:
							break;
					}
				}
      }
		}
		
		NSLog(@"%@",urlStr);
		urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSURL *url = [NSURL URLWithString:urlStr];
		
		NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url
                                                       cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                   timeoutInterval:10.0];
		[req setHTTPMethod:@"POST"];
		[req addValue:header forHTTPHeaderField:@"Authorization"];
		
		NSMutableData *body = [[NSMutableData alloc] init];
		
		NSString *boundary = @"------------------a7V4kRcFA8E79pivMuV2tukQ85cmNKeoEgJgq";
		[req addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
		
		[body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[@"Content-Disposition: form-data; name=\"json\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[@"Content-Type: application/json; charset=UTF-8\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[@"Content-Transfer-Encoding: 8bit\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
		//ファイル名
		NSString *fileStr = [upFileNameArray objectForKey:tag];
		NSString *ext = [upFileEXTArray objectForKey:tag];
		NSString *filename = [[fileStr stringByAppendingString:@"."]stringByAppendingString:ext];
    
		NSString *bodyString = [NSString stringWithFormat:@""
                            "{ \"body\":\r\n"
                            "   {\r\n"
                            "      \"messageSegments\" : [\r\n"
                            "      {\r\n"
                            "         \"type\" : \"Text\", \r\n"
                            "         \"text\" : \"%@ \"\r\n"
                            "      }\r\n"
                            "      ]\r\n"
                            "   }, \r\n"
                            "   \"attachment\": \r\n"
                            "   {\r\n"
                            "      \"desc\": \"\",\r\n"
                            "      \"filename\": \"%@\"\r\n"
                            "   }\r\n"
                            "}", commentText,filename];
		
		[body appendData:[[NSString stringWithFormat:@"%@\r\n", bodyString] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		
		[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"feedItemFileUpload\"; filename=\"%@\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[@"Content-Type: application/octet-stream\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		
		[body appendData:sendData];
		[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		
		[req setHTTPBody:body];
		
		error = nil;
		NSURLResponse *response = nil;
		
		[NSURLConnection sendSynchronousRequest:req
                          returningResponse:&response
                                      error:&error];
		
		NSHTTPURLResponse *httpurlResponse = (NSHTTPURLResponse *)response;
		NSLog(@"response -> %d", [httpurlResponse statusCode]);
    
		feedCount = 0;
		
		//添付解除
		[upFileArray removeObjectForKey:tag];
		[upFileEXTArray removeObjectForKey:tag];
		[upFileNameArray removeObjectForKey:tag];
		self.updateBtn.enabled = NO;
		[self getMyTimeLine:0.0f url:nil];
		self.updateBtn.enabled = YES;
    
		if ( wrkBtn.tag == 65535 ){
			[fileAttachedButton removeFromSuperview];
		}
		
		//保存したコメント入力内容をクリア
		[commentArray removeObjectForKey:tag];
		
		//新規フィード用入力欄をクリア
		postInput.text = @"";
	}
	else {
		//
		//添付ファイル無し
		//
		
		//投稿用parameter
		NSDictionary *messageSegments = [[NSDictionary alloc]initWithObjectsAndKeys:@"Text",@"type",commentText,@"text",nil];
		NSArray *message = [NSArray arrayWithObject:messageSegments];
		NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:message,@"messageSegments", nil];
    
		NSDictionary *body = [[NSDictionary alloc]initWithObjectsAndKeys:dict, @"body", nil];
		NSLog(@"%@",body);
    
		//リクエスト作成
		NSString *feedId;
		NSString *path;
		if ( wrkBtn.tag != 65535 ){
			feedId = [feedIdArray objectAtIndex:wrkBtn.tag];
			path = [NSString stringWithFormat:@"v27.0/chatter/feed-items/%@/comments",feedId];
		}
		else {
      if(currentGroup){
				
				if (([currentGroup isEqualToString:@"Follow"]) ||
            ([currentGroup isEqualToString:@"toMe"]) ||
            ([currentGroup isEqualToString:@"bookMark"]) ||
            ([currentGroup isEqualToString:@"AllOfCompany"])) {
					
					path = @"v27.0/chatter/feeds/to/me/feed-items";
				}
				else {
					path = [NSString stringWithFormat:@"v27.0/chatter/feeds/record/%@/feed-items",currentGroup];
				}
			}
			else {
        switch (_chatterType) {
          case ENUM_CHATTERME:
            myId = myInfo.userId;
            path = [NSString stringWithFormat:@"v27.0/chatter/feeds/news/%@/feed-items",myId];
            break;
          case ENUM_CHATTERCLIENT:
            myId = self.initialId;
            path = [NSString stringWithFormat:@"v27.0/chatter/feeds/record/%@/feed-items",myId];
            break;
          case ENUM_CHATTEROTHER:
            myId = self.initialId;
            path = [NSString stringWithFormat:@"v27.0/chatter/feeds/record/%@/feed-items",myId];
            break;
          default:
            break;
        }
      }
		}
		SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodPOST path:path queryParams:body];
    
		//POST実行
		[[SFRestAPI sharedInstance] sendRESTRequest:req
                                      failBlock:^(NSError *e) {
                                        NSLog(@"FAILWHALE with error: %@", [e description] );
                                      }
                                  completeBlock:^(id jsonResponse){
                                    NSDictionary *dict = (NSDictionary *)jsonResponse;
                                    NSLog(@"%@",dict);
                                    
                                    feedCount = 0;
                                    
                                    //保存したコメント入力内容をクリア
                                    [commentArray removeObjectForKey:tag];
                                    
                                    //新規フィード用入力欄をクリア
                                    postInput.text = @"";
                                    
                                    //添付ファイル管理用配列初期化
                                    upFileArray = [NSMutableDictionary dictionary];
                                    upFileEXTArray = [NSMutableDictionary dictionary];
                                    upFileNameArray = [NSMutableDictionary dictionary];
                                    
                                    //全Feedを再取得
                                    [self getMyTimeLine:0.0f url:nil];
                                  }];
	}
}


//ナビゲーションバーの「戻る」ボタン処理
-(void)back
{
  hasImgPickerStatus = @"BACK";
	int backPos;
  [pop dismissPopoverAnimated:NO];
	
	//戻り先を共有データを取得
	NSString *ret = [pData getDataForKey:@"ReturnScreen"];
	if ( [ret isEqualToString:@"ROOT"] ) {
		backPos = 0;				//開始画面に戻る
		//ナビゲーションバー　設定
		[self.navigationController.navigationBar setHidden:YES];
	}
	else if ( [ret isEqualToString:@"MAP"] ) {
		backPos = 1;				//地図に戻る
		//ナビゲーションバー　設定
		[self.navigationController.navigationBar setHidden:NO];
	}
	else {
		backPos = 2;				//Storeに戻る
		//ナビゲーションバー　設定
		[self.navigationController.navigationBar setHidden:NO];
	}
  
	//画面遷移
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:backPos] animated:YES];
}

//所属するグループを取得
-(void)getMyGroup
{
	//リクエスト作成
	NSString *path = @"v27.0/chatter/users/me/groups";
	SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodGET path:path queryParams:nil];
	
	//GET実行
	[[SFRestAPI sharedInstance] sendRESTRequest:req failBlock:^(NSError *e) {
		NSLog(@"FAILWHALE with error: %@", [e description] );
	}
                                completeBlock:^(id jsonResponse){
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  NSLog(@"dict::%@",dict);
                                  NSMutableArray *groups = [dict objectForKey:@"groups"];
                                  
                                  grpArray = [NSMutableArray array];
                                  grpIdArray = [NSMutableArray array];
                                  
                                  //デフォルトで追加
                                  [grpArray addObject:[pData getDataForKey:@"DEFINE_CHATTER_LABEL_FOLLOW_ADD"]];
                                  [grpIdArray addObject:@"Follow"];
                                  [grpArray addObject:[pData getDataForKey:@"DEFINE_CHATTER_LABEL_TOME_ADD"]];
                                  [grpIdArray addObject:@"toMe"];
                                  [grpArray addObject:[pData getDataForKey:@"DEFINE_CHATTER_LABEL_BOOKMARK_ADD"]];
                                  [grpIdArray addObject:@"bookMark"];
                                  [grpArray addObject:[pData getDataForKey:@"DEFINE_CHATTER_LABEL_ALLCOMPANY_ADD"]];
                                  [grpIdArray addObject:@"AllOfCompany"];
                                  
                                  for ( int i = 0; i < [groups count]; i++){
                                    
                                    //グループを取得
                                    NSMutableDictionary *grp = [groups objectAtIndex:i];
                                    
                                    //グループ名保存
                                    NSString *name = [grp objectForKey:@"name"];
                                    [grpArray addObject:name];
                                    
                                    //グループID保存
                                    NSString *gId = [grp objectForKey:@"id"];
                                    [grpIdArray addObject:gId];
                                  }
                                }];
}

-(void)viewWillDisappear:(BOOL)animated
{
  [pop dismissPopoverAnimated:NO];
}

- (void)viewDidUnload {
	[self setDescriptionView:nil];
	[self setFeedView:nil];
	[self setPostView:nil];
	[self setMemberView:nil];
	[self setFileListView:nil];
	[self setFileListHeaderView:nil];
	[self setMemberHeaderView:nil];
	[self setPostHeaderView:nil];
	[self setDescriptionTextView:nil];
	[self setUpdateBtn:nil];
	[self setDeleteBtn:nil];
	[self setGroupImageView:nil];
	[self setDescriptionLabel:nil];
	[self setDescriptionLabel:nil];
	[super viewDidUnload];
}

@end
