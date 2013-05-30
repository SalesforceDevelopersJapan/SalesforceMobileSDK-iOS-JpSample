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



#import "SalesforceProjectViewController.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MessageWindowViewController.h"
#import "DashBoardViewController.h"
#import "ChatterViewController.h"
#import "RouteViewController.h"
#import "SettingViewController.h"
#import "MapViewController.h"
#import "AppDelegate.h"

#define BTN1_X ( 9 )
#define BTN1_Y ( 9 )
#define BTN1_W ( 235 )
#define BTN1_H ( 236 )

#define BTN2_X ( 253 )
#define BTN2_Y ( 9 )
#define BTN2_W ( 235 )
#define BTN2_H ( 236 )

#define BTN3_X ( 9 )
#define BTN3_Y ( 252 )
#define BTN3_W ( 235 )
#define BTN3_H ( 236 )

#define BTN4_X ( 253 )
#define BTN4_Y ( 252 )
#define BTN4_W ( 235 )
#define BTN4_H ( 236 )

#define BTN5_X ( 9 )
#define BTN5_Y ( 496 )
#define BTN5_W ( 235 )
#define BTN5_H ( 236 )

#define BTN6_X ( 253 )
#define BTN6_Y ( 496 )
#define BTN6_W ( 235 )
#define BTN6_H ( 236 )

static const int Badge_Height = 101;
static const int Badge_Width = 100;

//画像読み込みの閾値(単位」Byte）
static const int	MaxLoadingSize = ( 200 * 1024 );



@implementation SalesforceProjectViewController


- (void)viewDidLoad
{
  [super viewDidLoad];
  /*
   //取引先選択するまではDisable
   [self.metrics setEnabled:NO];
   [self.promo setEnabled:NO];
   [self.order setEnabled:NO];
   [self.chatter setEnabled:NO];
   [self.btn6 setEnabled:NO];
   [self.map setEnabled:NO];
   */
  /*
   //ナビゲーションバー　「取引先」ボタン
   custmerBtn = [[UIBarButtonItem alloc]initWithTitle:@"取引先"
   style:UIBarButtonItemStyleBordered target:self action:@selector(search)];
   self.navigationItem.leftBarButtonItem = custmerBtn;
   */
  
	//ナビゲーションバー　設定
	[self.navigationController.navigationBar setHidden:YES];
  
  pData = [PublicDatas instance];
  
	[self buildScreen];
  
  // syncが必要か？
  isNeedSync = NO;
  um = [UtilManager sharedInstance];
  if(![um isDoneSync]) [self syncAlert];
  [self checkCacheFile];
  [self checkMovieFile];
  
  isBadgeFlg = YES;
 	_badge1.tag = 1;
	_badge2.tag = 2;
  _badge3.tag = 3;
  _badge4.tag = 4;
  _badge5.tag = 5;
  _badge6.tag = 6;
	um = [UtilManager sharedInstance];
  
  // 角丸
  CGSize size = CGSizeMake(5.0, 5.0);
  // ボタン
  [um makeViewRound:_metrics corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_map corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_order corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_promo corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_chatter corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_btn6 corners:UIRectCornerAllCorners size:&size];
  
  // バッヂ
  [um makeViewRound:_badge1 corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_badge2 corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_badge3 corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_badge4 corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_badge5 corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_badge6 corners:UIRectCornerAllCorners size:&size];
  
  [um makeViewRound:_profileImage corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_messageView corners:UIRectCornerAllCorners size:&size];
  
  // キャッシュした画像ファイルの更新チェック
  //AppDelegate* appli = (AppDelegate*)[[UIApplication sharedApplication] delegate];
  //[appli updateCacheFile:NO];
  
  // 認証したユーザー情報にアクセス
  [self getinfo];
}

-(void)getUserInfo
{
  // 認証したユーザー情報にアクセス
  SFAccountManager *sm = [SFAccountManager sharedInstance];
  
  //クエリ作成
  NSString *query = [NSString stringWithFormat:@"SELECT Id, Username, LastName, FirstName, Name, CompanyName, Division, Department, Title, Street, City, State, PostalCode, Country, Email, Phone, Fax FROM User WHERE Id = '%@'", sm.idData.userId];
  NSLog(@"%@",query);
  SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:query];
  [[SFRestAPI sharedInstance] send:request delegate:self];
}

-(void)viewDidAppear:(BOOL)animated
{
	[self buildScreen];
  /*
  // 認証したユーザー情報にアクセス
  SFAccountManager *sm = [SFAccountManager sharedInstance];
  
  //クエリ作成
  NSString *query = [NSString stringWithFormat:@"SELECT Id, Username, LastName, FirstName, Name, CompanyName, Division, Department, Title, Street, City, State, PostalCode, Country, Email, Phone, Fax FROM User WHERE Id = '%@'", sm.idData.userId];
  NSLog(@"%@",query);
  SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:query];
  [[SFRestAPI sharedInstance] send:request delegate:self];
  */
  // メッセージ取得
  NSString *path = @"v27.0/chatter/users/me/messages";
  
	SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodGET path:path queryParams:nil];
  [[SFRestAPI sharedInstance] send:req delegate:self];
}

-(void)getinfo
{
  isBadgeFlg = YES;
 	_badge1.tag = 1;
	_badge2.tag = 2;
  _badge3.tag = 3;
  _badge4.tag = 4;
  _badge5.tag = 5;
  _badge6.tag = 6;
	um = [UtilManager sharedInstance];
  
  // 角丸
  CGSize size = CGSizeMake(5.0, 5.0);
  // ボタン
  [um makeViewRound:_metrics corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_map corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_order corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_promo corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_chatter corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_btn6 corners:UIRectCornerAllCorners size:&size];
  
  // バッヂ
  [um makeViewRound:_badge1 corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_badge2 corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_badge3 corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_badge4 corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_badge5 corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_badge6 corners:UIRectCornerAllCorners size:&size];
  
  [um makeViewRound:_profileImage corners:UIRectCornerAllCorners size:&size];
  [um makeViewRound:_messageView corners:UIRectCornerAllCorners size:&size];
  
  // 認証したユーザー情報にアクセス
  SFAccountManager *sm = [SFAccountManager sharedInstance];
  
  //クエリ作成
  NSString *query = [NSString stringWithFormat:@"SELECT Id, Username, LastName, FirstName, Name, CompanyName, Division, Department, Title, Street, City, State, PostalCode, Country, Email, Phone, Fax FROM User WHERE Id = '%@'", sm.idData.userId];
  NSLog(@"%@",query);
  SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:query];
  [[SFRestAPI sharedInstance] send:request delegate:self];
  
  // メッセージ取得
  NSString *path = @"v27.0/chatter/users/me/messages";
  
	SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodGET path:path queryParams:nil];
  [[SFRestAPI sharedInstance] send:req delegate:self];
}

//SOQLのアンサー受信
- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
  
  // プロフィール recordsを解析
  // メッセージ messagesを解析
  NSArray *records = [jsonResponse objectForKey:@"records"];
  NSLog(@"request:didLoadResponse: #records: %d", records.count);
  
  NSArray *messages = [jsonResponse objectForKey:@"messages"];
  NSLog(@"request:didLoadResponse: #messages: %d", messages.count);
  
  NSArray *items = [jsonResponse objectForKey:@"items"];
  NSLog(@"request:didLoadResponse: #messages: %d", items.count);
  
  // ユーザー情報の場合
  if(records>0){
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
      _nameLabel.text = [NSString stringWithFormat:@"%@ %@", [userObj valueForKey:@"LastName"],[userObj valueForKey:@"FirstName"]];
    }else if([um chkString:[userObj objectForKey:@"LastName"]]){
      _nameLabel.text = [NSString stringWithFormat:@"%@", [userObj valueForKey:@"LastName"]];
    }
    // 会社名
    if([um chkString:[userObj objectForKey:@"CompanyName"]]){
      _companyLabel.text = [userObj objectForKey:@"CompanyName"];
    }
    // 部署、役職
    NSString *Department = (NSString *)[userObj objectForKey:@"Department"];
    NSString *Title = (NSString *)[userObj objectForKey:@"Title"];
    if (Department != nil && ![Department isEqual:[NSNull null]]) {
      if(Title != nil && ![Title isEqual:[NSNull null]]) {
        _departmentLabel.text = [NSString stringWithFormat:@"%@ %@",Department ,Title];
      }else{
        _departmentLabel.text = Department;
      }
    }
    
    // 電話
    if([um chkString:[userObj objectForKey:@"Phone"]]){
      _phoneLabel.text = [NSString stringWithFormat:@"Tel: %@",[userObj objectForKey:@"Phone"]];
    }else{
      _phoneLabel.text = [pData getDataForKey:@"DEFINE_TOP_PHONE"];
    }
    // Fax
    if([um chkString:[userObj objectForKey:@"Fax"]]){
      _faxLabel.text = [NSString stringWithFormat:@"Fax: %@",[userObj objectForKey:@"Fax"]];
    }else{
      _faxLabel.text = [pData getDataForKey:@"DEFINE_TOP_FAX"];
    }
    // E-mail
    if([um chkString:[userObj objectForKey:@"Email"]]){
      _emailLabel.text = [NSString stringWithFormat:@"Email: %@",[userObj objectForKey:@"Email"]];
    }else{
      _emailLabel.text = [pData getDataForKey:@"DEFINE_TOP_EMAIL"];
    }
    // トークンを取得
    NSString *access_token = [[[[SFRestAPI sharedInstance]coordinator]credentials]accessToken];
    NSLog(@"access_token %@", access_token);
    
    // 認証したユーザー情報にアクセス
    SFAccountManager *sm = [SFAccountManager sharedInstance];
    
    // URLを指定してHTTPリクエストを生成 プロフィール画像　トークンが必要
    NSString *str = [NSString stringWithFormat:@"%@?oauth_token=%@",[sm.idData.pictureUrl absoluteString], access_token];
    
    NSURL *url = [NSURL URLWithString:str];
    NSLog(@"url ..%@",url);
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
           UIImage *img = [UIImage imageWithData:data];
           
           //取得画像にUIImageViewの縦横比をあわせる
           float asp = img.size.height / img.size.width;
           CGRect rect = _profileImage.frame;
           rect.size.height = rect.size.width * asp;
           _profileImage.frame = rect;
           _profileImage.image = img;
           // 角丸
           CGSize size = CGSizeMake(5.0, 5.0);
           [um makeViewRound:_profileImage corners:UIRectCornerAllCorners size:&size];
         }
         if(error){
           NSLog(@"error %@", error);
           UIAlertView *failAlert = [[UIAlertView alloc]
                                     initWithTitle:nil
                                     message:[pData getDataForKey:@"DEFINE_TOP_ALERT_IMAREADERRMSG"]
                                     delegate:self
                                     cancelButtonTitle:nil
                                     otherButtonTitles:[pData getDataForKey:@"DEFINE_TOP_ALERTOK"], nil ];
           
           [failAlert show];
         }
       }@catch (NSException *exception) {
         NSLog(@"main:Caught %@:%@", [exception name], [exception reason]);
       }@finally {
       }
     }];
  }
  // messagesの場合
  else if(messages.count>0){
    //NSLog(@"json %@", jsonResponse);
    //NSLog(@"--------------------");
    if(!MessageIndex) MessageIndex = 0;
    messageList = [[NSMutableArray alloc] init];
    
    for ( NSDictionary *obj in messages ) {
      
      // メッセージ表示用ビュー
      MessageWindowViewController *mwVC = [[MessageWindowViewController alloc] initWithNibName:@"MessageWindowViewController" bundle:nil];
      mwVC.view.frame = CGRectMake(47, 30, 402, 200);
      
      NSArray *allKeys = [obj allKeys];
      // メッセージ単位で回す
      for(int i=0; i<[allKeys count]; i++){
        NSString *_key = [allKeys objectAtIndex:i];
        // メッセージ本文
        if([_key isEqual:@"body"]){
          NSDictionary *bodyDic = [obj valueForKey:_key];
          mwVC.bodyTextView.text = [bodyDic objectForKey:@"text"];
        }
        // 送信日時
        else if([_key isEqual:@"sentDate"] && [um chkString:[obj valueForKey:_key]]){
          mwVC.dateLabel.text = [um conv2Tz:[obj valueForKey:_key]];
        }
        // 送信者情報
        else if([_key isEqual:@"sender"]){
          NSDictionary *senderDic = [obj valueForKey:_key];
          NSArray *allKeys = [senderDic allKeys];
          for(int i=0; i<[allKeys count]; i++){
            NSString *_key = [allKeys objectAtIndex:i];
            // ユーザーID
            if([_key isEqual:@"id"]){
              mwVC.userId = [obj valueForKey:_key];
            }
            // サムネイル画像
            if([_key isEqual:@"photo"]){
              NSDictionary *picDic = [senderDic valueForKey:_key];
              NSString *standardEmailPhotoUrl =[picDic valueForKey:@"standardEmailPhotoUrl"];
              NSLog(@"standardEmailPhotoUrl %@ ", standardEmailPhotoUrl);
              if([um chkString:standardEmailPhotoUrl]){
                NSURL *url = [NSURL URLWithString:standardEmailPhotoUrl];
                NSData *data = [NSData dataWithContentsOfURL:url];
                mwVC.userPhoto.image = [[UIImage alloc] initWithData:data];
                CGSize size = CGSizeMake(5.0, 5.0);
                [um makeViewRound:mwVC.userPhoto corners:UIRectCornerAllCorners size:&size];
                
              }
            }
            // 氏名
            if([_key isEqual:@"name"]){
              if([um chkString:[senderDic valueForKey:_key]]) mwVC.nameLabel.text = [senderDic valueForKey:_key];
            }
            // 会社名
            if([_key isEqual:@"companyName"]){
              if([um chkString:[senderDic valueForKey:_key]]) mwVC.companyLabel.text = [senderDic valueForKey:_key];
            }
            // 役職
            if([_key isEqual:@"title"]){
              if([um chkString:[senderDic valueForKey:_key]]) mwVC.postLabel.text = [senderDic valueForKey:_key];
            }
          }
        }
      }
      [messageList addObject:mwVC.view];
    } // for
    
    // メッセージがあれば表示
    if([messageList count]){
      // 402x200
      //[messageView addSubview:[messageList objectAtIndex:MessageIndex]];
      NSLog(@"list count %d", [messageList count]);
      _scrollView.pagingEnabled = YES;
      _scrollView.contentSize = CGSizeMake(402*[messageList count], 0);
      //scrollView.showsHorizontalScrollIndicator = NO;
      //scrollView.showsVerticalScrollIndicator = NO;
      _scrollView.scrollsToTop = YES;
      _scrollView.scrollEnabled = NO;
      for(int i=0; i<[messageList count]; i++){
        UIView *iv = [messageList objectAtIndex:i];
        // CGRectMake(47, 30, 402, 200);
        
        iv.frame = CGRectMake(402*i,0, 402, 200);
        [_scrollView addSubview:iv];
      }
      
      [leftBtn removeFromSuperview];
      [rightBtn removeFromSuperview];
      
      NSString *path;
      path =  [[NSBundle mainBundle] pathForResource:@"leftgray" ofType:@"png"];
      leftGrayImg = [[UIImage alloc] initWithContentsOfFile:path];
      
      path =  [[NSBundle mainBundle] pathForResource:@"rightgray" ofType:@"png"];
      rightGrayImg = [[UIImage alloc] initWithContentsOfFile:path];
      
      path =  [[NSBundle mainBundle] pathForResource:@"leftblue" ofType:@"png"];
      leftBlueImg = [[UIImage alloc] initWithContentsOfFile:path];
      
      path =  [[NSBundle mainBundle] pathForResource:@"rightblue" ofType:@"png"];
      rightBlueImg = [[UIImage alloc] initWithContentsOfFile:path];
      
      // 初回は左ボタンはOFF
      leftBtn = [[UIButton alloc]
                 initWithFrame:CGRectMake(7, 100, 40, 40)];
      [leftBtn setBackgroundImage:leftGrayImg forState:UIControlStateNormal];
      leftBtn.enabled = NO;
      [_messageView addSubview:leftBtn];
      [leftBtn addTarget:self action:@selector(leftBtnPush:) forControlEvents:UIControlEventTouchUpInside];
      
      rightBtn = [[UIButton alloc]
                  initWithFrame:CGRectMake(451, 100, 40, 40)];
      
      // メッセージが1つのときは右ボタンをOFF
      if([messageList count]==1){
        [rightBtn setBackgroundImage:rightGrayImg forState:UIControlStateNormal];
        rightBtn.enabled = NO;
      }else{
        [rightBtn setBackgroundImage:rightBlueImg forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(rightBtnPush:) forControlEvents:UIControlEventTouchUpInside];
      }
      [_messageView addSubview:rightBtn];

      // 戻りの際の調整
      if(MessageIndex){
        [self adjustMessageButton];
      }
    }else{
      _messageView.alpha = 1.0f;
    }
  }
}

// ボタンデフォルト
-(void) adjustMessageButton
{
  
  if (MessageIndex<1) {
    MessageIndex = 0;
    [leftBtn setBackgroundImage:leftGrayImg forState:UIControlStateNormal];
    leftBtn.enabled = NO;
    [rightBtn setBackgroundImage:rightBlueImg forState:UIControlStateNormal];
    rightBtn.enabled = YES;
  }
  else if (MessageIndex>=[messageList count]-1) {
    MessageIndex=[messageList count]-1;
    [leftBtn setBackgroundImage:leftBlueImg forState:UIControlStateNormal];
    leftBtn.enabled = YES;
    [rightBtn setBackgroundImage:rightGrayImg forState:UIControlStateNormal];
    rightBtn.enabled = NO;
  }
  else{
    [leftBtn setBackgroundImage:leftBlueImg forState:UIControlStateNormal];
    leftBtn.enabled = YES;
    [rightBtn setBackgroundImage:rightBlueImg forState:UIControlStateNormal];
    rightBtn.enabled = YES;
  }
}

// 左ボタン
-(void)leftBtnPush:(id)sender{
  @try {
    if (MessageIndex<1) {
      MessageIndex = 0;
      return;
    }
    MessageIndex--;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [_scrollView setContentOffset:CGPointMake(402*MessageIndex, 0)];
    [UIView commitAnimations];
    
    [rightBtn setBackgroundImage:rightBlueImg forState:UIControlStateNormal];
    rightBtn.enabled = YES;
    
    if(MessageIndex<=0){
      [leftBtn setBackgroundImage:leftGrayImg forState:UIControlStateNormal];
      leftBtn.enabled = NO;
    }
  }@catch (NSException *exception) {
    NSLog(@"main:Caught %@:%@", [exception name], [exception reason]);
    MessageIndex=0;
    [_scrollView setContentOffset:CGPointMake(402*MessageIndex, 0)];
    // 初回は左ボタンはOFF
    [leftBtn setBackgroundImage:leftGrayImg forState:UIControlStateNormal];
    leftBtn.enabled = NO;
    // メッセージが1つのときは右ボタンをOFF
    if([messageList count]==1){
      [rightBtn setBackgroundImage:rightGrayImg forState:UIControlStateNormal];
      rightBtn.enabled = NO;
    }else{
      rightBtn.enabled = YES;
    }
  }
}

// 右ボタン
-(void)rightBtnPush:(id)sender{
  @try {
    if (MessageIndex>[messageList count]-1) {
      MessageIndex = [messageList count]-1;
      return;
    }
    MessageIndex++;
    if(MessageIndex<=[messageList count]-1){
      
      [UIView beginAnimations:nil context:nil];
      [UIView setAnimationDelegate:self];
      [UIView setAnimationDuration:0.5];
      [_scrollView setContentOffset:CGPointMake(402*MessageIndex, 0)];
      [UIView commitAnimations];
      
      [leftBtn setBackgroundImage:leftBlueImg forState:UIControlStateNormal];
      leftBtn.enabled = YES;
    }
    if(MessageIndex>=[messageList count]-1){
      [rightBtn setBackgroundImage:rightGrayImg forState:UIControlStateNormal];
      rightBtn.enabled = NO;
    }
  }@catch (NSException *exception) {
    NSLog(@"main:Caught %@:%@", [exception name], [exception reason]);
    MessageIndex=0;
    [_scrollView setContentOffset:CGPointMake(402*MessageIndex, 0)];
    // 初回は左ボタンはOFF
    [leftBtn setBackgroundImage:leftGrayImg forState:UIControlStateNormal];
    leftBtn.enabled = NO;
    // メッセージが1つのときは右ボタンをOFF
    if([messageList count]==1){
      [rightBtn setBackgroundImage:rightGrayImg forState:UIControlStateNormal];
      rightBtn.enabled = NO;
    }else{
      rightBtn.enabled = YES;
    }
  }
}


-(void)buildScreen
{
  
	//背景設定
	um = [UtilManager sharedInstance];
	NSData *iData =[um backType];
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
	
	//画像表示
	iData =[um logoImage];
	if ( iData ) {
		UIImage *img = [UIImage imageWithData:iData];
		
		//取得画像にUIImageViewの縦横比をあわせる
		float asp = img.size.height / img.size.width;
		CGRect rect = _companyLogo.frame;
		rect.size.height = rect.size.width * asp;
		_companyLogo.frame = rect;
		_companyLogo.image = img;
	}
	
  CGSize size = CGSizeMake(5.0, 5.0);
	//ボタン表示
	iData =[um btn1Image];
	if ( iData ) {
		UIImage *img = [UIImage imageWithData:iData];
		//[_metrics setBackgroundImage:img forState:UIControlStateNormal];
    UIButton *btn1 = [um makeImageButton:img withAction:@selector(metricsPushed:)];
    [btn1 setFrame:CGRectMake(BTN1_X, BTN1_Y,BTN1_W, BTN1_H)];
    [um makeViewRound:btn1 corners:UIRectCornerAllCorners size:&size];
    [self.view addSubview:btn1];
	}
	
	iData =[um btn2Image];
	if ( iData ) {
		UIImage *img = [UIImage imageWithData:iData];
		//[_map setBackgroundImage:img forState:UIControlStateNormal];
    UIButton *btn2 = [um makeImageButton:img withAction:@selector(mapPushed:)];
    [btn2 setFrame:CGRectMake(BTN2_X, BTN2_Y,BTN2_W, BTN2_H)];
    [um makeViewRound:btn2 corners:UIRectCornerAllCorners size:&size];
    [self.view addSubview:btn2];
	}
	
	iData =[um btn3Image];
	if ( iData ) {
		UIImage *img = [UIImage imageWithData:iData];
		//[_order setBackgroundImage:img forState:UIControlStateNormal];
    
    UIButton *btn3 = [um makeImageButton:img withAction:@selector(orderPushed:)];
    [btn3 setFrame:CGRectMake(BTN3_X, BTN3_Y,BTN3_W, BTN3_H)];
    [um makeViewRound:btn3 corners:UIRectCornerAllCorners size:&size];
    [self.view addSubview:btn3];
	}
	
	iData =[um btn4Image];
	if ( iData ) {
		UIImage *img = [UIImage imageWithData:iData];
		//[_chatter setBackgroundImage:img forState:UIControlStateNormal];
    UIButton *btn4 = [um makeImageButton:img withAction:@selector(chatterPushed:)];
    [btn4 setFrame:CGRectMake(BTN4_X, BTN4_Y,BTN4_W, BTN4_H)];
    [um makeViewRound:btn4 corners:UIRectCornerAllCorners size:&size];
    [self.view addSubview:btn4];
	}
	
	iData =[um btn5Image];
	if ( iData ) {
		UIImage *img = [UIImage imageWithData:iData];
		//[_promo setBackgroundImage:img forState:UIControlStateNormal];
    UIButton *btn5 = [um makeImageButton:img withAction:@selector(promotionPushed:)];
    [btn5 setFrame:CGRectMake(BTN5_X, BTN5_Y,BTN5_W, BTN5_H)];
    [um makeViewRound:btn5 corners:UIRectCornerAllCorners size:&size];
    [self.view addSubview:btn5];
	}
	
	iData =[um btn6Image];
	if ( iData ) {
		UIImage *img = [UIImage imageWithData:iData];
		//[_btn6 setBackgroundImage:img forState:UIControlStateNormal];
    UIButton *btn6 = [um makeImageButton:img withAction:nil];
    [btn6 setFrame:CGRectMake(BTN6_X, BTN6_Y,BTN6_W, BTN6_H)];
    [um makeViewRound:btn6 corners:UIRectCornerAllCorners size:&size];
    [self.view addSubview:btn6];
	}
	
	
	//バッヂ表示
	iData =[um badge1];
	if ( iData ) {
		UIImage *img = [UIImage imageWithData:iData];
    
		//取得画像にUIImageViewの縦横比をあわせる
		float asp = img.size.height / img.size.width;
		CGRect rect = CGRectMake(_badge1.frame.origin.x, _badge1.frame.origin.y, 100, 101);
		rect.size.height = rect.size.height * asp;
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
  
  UILongPressGestureRecognizer *longPress1 = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(badge1LongPressed:)];
  
  UILongPressGestureRecognizer *longPress2 = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(badge2LongPressed:)];
  
  UILongPressGestureRecognizer *longPress3 = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(badge3LongPressed:)];
  
  UILongPressGestureRecognizer *longPress4 = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(badge4LongPressed:)];
  
  UILongPressGestureRecognizer *longPress5 = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(badge5LongPressed:)];
  
  UILongPressGestureRecognizer *longPress6 = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(badge6LongPressed:)];
  
  longPress1.minimumPressDuration = 2.0;
  longPress2.minimumPressDuration = 2.0;
  longPress3.minimumPressDuration = 2.0;
  longPress4.minimumPressDuration = 2.0;
  longPress5.minimumPressDuration = 2.0;
  longPress6.minimumPressDuration = 2.0;
  
  [_badge1 addGestureRecognizer:longPress1];
  [_badge2 addGestureRecognizer:longPress2];
  [_badge3 addGestureRecognizer:longPress3];
  [_badge4 addGestureRecognizer:longPress4];
  [_badge5 addGestureRecognizer:longPress5];
  [_badge6 addGestureRecognizer:longPress6];
  
  
  UITapGestureRecognizer *doubleTap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(badge1DoublePushed:)];
  
  UITapGestureRecognizer *doubleTap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(badge2DoublePushed:)];
  
  UITapGestureRecognizer *doubleTap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(badge3DoublePushed:)];
  
  UITapGestureRecognizer *doubleTap4 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(badge4DoublePushed:)];
  
  UITapGestureRecognizer *doubleTap5 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(badge5DoublePushed:)];
  
  UITapGestureRecognizer *doubleTap6 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(badge6DoublePushed:)];
  
  
  doubleTap1.numberOfTapsRequired = 2;
  doubleTap2.numberOfTapsRequired = 2;
  doubleTap3.numberOfTapsRequired = 2;
  doubleTap4.numberOfTapsRequired = 2;
  doubleTap5.numberOfTapsRequired = 2;
  doubleTap6.numberOfTapsRequired = 2;
  
  [_badge1 addGestureRecognizer:doubleTap1];
  [_badge2 addGestureRecognizer:doubleTap2];
  [_badge3 addGestureRecognizer:doubleTap3];
  [_badge4 addGestureRecognizer:doubleTap4];
  [_badge5 addGestureRecognizer:doubleTap5];
  [_badge6 addGestureRecognizer:doubleTap6];
  
  _messageLabel.text = [pData getDataForKey:@"DEFINE_TOP_LABEL_MESSAGE"];
}

//ナビゲーションバーの「設定」ボタン処理
-(void)setting
{
	SettingViewController *setVC = [[SettingViewController alloc]initWithNibName:@"settingViewController" bundle:[NSBundle mainBundle]];
	[self.navigationController pushViewController:setVC animated:YES];
  
}

//ナビゲーションバーの「取引先」ボタン処理
-(void)search
{
}

-(void)viewWillDisappear:(BOOL)animated
{
	[pop dismissPopoverAnimated:NO];
}

- (void)didReceiveMemoryWarning
{
  NSLog(@"SalesForceProjectViewController");
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
  
  [self clearObj];
  [self loadView];
  [self getinfo];
  return;
}

-(void)clearObj
{
  [self setCompanyLogo:nil];
  [self setMetrics:nil];
  [self setOrder:nil];
  [self setChatter:nil];
  [self setBadge1:nil];
  [self setBadge2:nil];
  [self setBadge3:nil];
  [self setBadge4:nil];
  [self setBadge5:nil];
  [self setBadge6:nil];
  [self setProfileImage:nil];
  [self setBtn6:nil];
  [self setPromo:nil];
  [self setMap:nil];
  [self setCompanyLabel:nil];
  [self setNameLabel:nil];
  [self setDepartmentLabel:nil];
  [self setPhoneLabel:nil];
  [self setFaxLabel:nil];
  [self setEmailLabel:nil];
  [self setMessageView:nil];
  [self setScrollView:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
  if ((orientation == UIInterfaceOrientationLandscapeLeft) ||
      (orientation == UIInterfaceOrientationLandscapeRight )){
    return YES;
  }
  return NO;
}

- (void)viewDidUnload {
	[self clearObj];
	[super viewDidUnload];
}

- (IBAction)metricsPushed:(id)sender {
  isBadgeFlg = NO;
	MapViewController *mapVC = [[MapViewController alloc]initWithNibName:@"MapViewController" bundle:[NSBundle mainBundle]];
	[self.navigationController pushViewController:mapVC animated:YES];
  
}

- (IBAction)mapPushed:(id)sender {
  UIButton *button = (UIButton*)sender;
  button.enabled = NO;
  isBadgeFlg = NO;
	RouteViewController *rtVC = [[RouteViewController alloc]initWithNibName:@"RouteViewController" bundle:[NSBundle mainBundle]];
	[self.navigationController pushViewController:rtVC animated:YES];
}

- (IBAction)orderPushed:(id)sender {
	isBadgeFlg = NO;
	//戻り先を記録
	pData = [PublicDatas instance];
	[pData setData:@"ROOT" forKey:@"ReturnScreen"];
	
	//画面遷移
	DashBoardViewController *dashVC = [[DashBoardViewController alloc]initWithNibName:@"DashBoardViewController" bundle:[NSBundle mainBundle] company:cpy];
	[self.navigationController pushViewController:dashVC animated:YES];
}
- (IBAction)promotionPushed:(id)sender {
  isBadgeFlg = NO;
	//戻り先を記録
	pData = [PublicDatas instance];
	[pData setData:@"ROOT" forKey:@"ReturnScreen"];
	
	//画面遷移
	SettingViewController *setVC = [[SettingViewController alloc]initWithNibName:@"SettingViewController" bundle:[NSBundle mainBundle]];
	[self.navigationController pushViewController:setVC animated:YES];
}

- (IBAction)chatterPushed:(id)sender {
  isBadgeFlg = NO;
	//戻り先を記録
	pData = [PublicDatas instance];
	[pData setData:@"ROOT" forKey:@"ReturnScreen"];
	
	//画面遷移
	ChatterViewController *chatterVC = [[ChatterViewController alloc]initWithNibName:@"ChatterViewController" bundle:[NSBundle mainBundle]];
	[self.navigationController pushViewController:chatterVC animated:YES];
}


//
//以下バッヂ1~6押下時処理
//
- (IBAction)badge1Pushed:(id)sender {
  if(isBadgeFlg){
    [pop dismissPopoverAnimated:YES];	//ポップオーバーを消す
    isBadgeFlg = NO;
    UIImagePickerControllerSourceType src = UIImagePickerControllerSourceTypePhotoLibrary;
    UIImagePickerController *imagePicker =[[UIImagePickerController alloc]init];
    imagePicker.sourceType = src;
    imagePicker.delegate = self;
    tag = 1;
    pop = [[UIPopoverController alloc]initWithContentViewController:imagePicker];
    pop.delegate = self;
    pop.popoverContentSize = imagePicker.view.frame.size;
    [pop presentPopoverFromRect:_badge1.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
  }
  isBadgeFlg = YES;
}

- (IBAction)badge2Pushed:(id)sender {
  if(isBadgeFlg){
    [pop dismissPopoverAnimated:YES];	//ポップオーバーを消す
    isBadgeFlg = NO;
    UIImagePickerControllerSourceType src = UIImagePickerControllerSourceTypePhotoLibrary;
    UIImagePickerController *imagePicker =[[UIImagePickerController alloc]init];
    imagePicker.sourceType = src;
    imagePicker.delegate = self;
    tag = 2;
    pop = [[UIPopoverController alloc]initWithContentViewController:imagePicker];
    pop.delegate = self;
    pop.popoverContentSize = imagePicker.view.frame.size;
    [pop presentPopoverFromRect:_badge2.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
  }
  isBadgeFlg = YES;
}

- (IBAction)badge3Pushed:(id)sender {
  if(isBadgeFlg){
    [pop dismissPopoverAnimated:YES];	//ポップオーバーを消す
    isBadgeFlg = NO;
    UIImagePickerControllerSourceType src = UIImagePickerControllerSourceTypePhotoLibrary;
    UIImagePickerController *imagePicker =[[UIImagePickerController alloc]init];
    imagePicker.sourceType = src;
    imagePicker.delegate = self;
    tag = 3;
    pop = [[UIPopoverController alloc]initWithContentViewController:imagePicker];
    pop.delegate = self;
    pop.popoverContentSize = imagePicker.view.frame.size;
    [pop presentPopoverFromRect:_badge3.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
  }
  isBadgeFlg = YES;
}

- (IBAction)badge4Pushed:(id)sender {
  if(isBadgeFlg){
    [pop dismissPopoverAnimated:YES];	//ポップオーバーを消す
    isBadgeFlg = NO;
    UIImagePickerControllerSourceType src = UIImagePickerControllerSourceTypePhotoLibrary;
    UIImagePickerController *imagePicker =[[UIImagePickerController alloc]init];
    imagePicker.sourceType = src;
    imagePicker.delegate = self;
    tag = 4;
    pop = [[UIPopoverController alloc]initWithContentViewController:imagePicker];
    pop.delegate = self;
    pop.popoverContentSize = imagePicker.view.frame.size;
    [pop presentPopoverFromRect:_badge4.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
  }
  isBadgeFlg = YES;
}

- (IBAction)badge5Pushed:(id)sender {
  if(isBadgeFlg){
    [pop dismissPopoverAnimated:YES];	//ポップオーバーを消す
    isBadgeFlg = NO;
    UIImagePickerControllerSourceType src = UIImagePickerControllerSourceTypePhotoLibrary;
    UIImagePickerController *imagePicker =[[UIImagePickerController alloc]init];
    imagePicker.sourceType = src;
    imagePicker.delegate = self;
    tag = 5;
    pop = [[UIPopoverController alloc]initWithContentViewController:imagePicker];
    pop.delegate = self;
    pop.popoverContentSize = imagePicker.view.frame.size;
    [pop presentPopoverFromRect:_badge5.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
  }
  isBadgeFlg = YES;
}
- (IBAction)badge6Pushed:(id)sender{
  if(isBadgeFlg){
    [pop dismissPopoverAnimated:YES];	//ポップオーバーを消す
    isBadgeFlg = NO;
    UIImagePickerControllerSourceType src = UIImagePickerControllerSourceTypePhotoLibrary;
    UIImagePickerController *imagePicker =[[UIImagePickerController alloc]init];
    imagePicker.sourceType = src;
    imagePicker.delegate = self;
    tag = 6;
    pop = [[UIPopoverController alloc]initWithContentViewController:imagePicker];
    pop.delegate = self;
    pop.popoverContentSize = imagePicker.view.frame.size;
    [pop presentPopoverFromRect:_badge6.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
  }
  isBadgeFlg = YES;
}


//
//以下バッヂ1~6長押し時処理
//
-(IBAction)badge1LongPressed:(id)sender{}

-(IBAction)badge2LongPressed:(id)sender{
}

-(IBAction)badge3LongPressed:(id)sender{
}

-(IBAction)badge4LongPressed:(id)sender{
}

-(IBAction)badge5LongPressed:(id)sender{
}

-(IBAction)badge6LongPressed:(id)sender{
}


//
//以下バッヂ1~6ダブルタップ時処理
//
-(IBAction)badge1DoublePushed:(id)sender{
  
  if(isBadgeFlg){
    isBadgeFlg = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"Badge1"];
    BOOL successful = [[NSUserDefaults standardUserDefaults]synchronize
                       ];
    if (!successful) {
      NSLog(@"%@", [pData getDataForKey:@"DEFINE_TOP_DELETEDATAERR"]);
      return;
    }
    
    UIImage * img;
    NSData *idata;
    NSString *path =  [[NSBundle mainBundle] pathForResource:@"badge" ofType:@"png"];
    img = [[UIImage alloc] initWithContentsOfFile:path];
    //img = [UIImage imageNamed:@"badge.png"];
    idata = UIImagePNGRepresentation(img);
    if ( ![[NSUserDefaults standardUserDefaults]synchronize]){
      NSLog(@"Error");
    }
    
    _badge1.frame = CGRectMake(_badge1.frame.origin.x, _badge1.frame.origin.y, 100, 101);
    [_badge1 setBackgroundImage:img forState:UIControlStateNormal];
    
    isBadgeFlg = YES;
  }
  
}

-(IBAction)badge2DoublePushed:(id)sender{
  
  if(isBadgeFlg){
    isBadgeFlg = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"Badge2"];
    BOOL successful = [[NSUserDefaults standardUserDefaults]synchronize
                       ];
    if (!successful) {
      NSLog(@"%@", [pData getDataForKey:@"DEFINE_TOP_DELETEDATAERR"]);
      return;
    }
    
    UIImage * img;
    NSData *idata;
    NSString *path =  [[NSBundle mainBundle] pathForResource:@"badge" ofType:@"png"];
    img = [[UIImage alloc] initWithContentsOfFile:path];
    //img = [UIImage imageNamed:@"badge.png"];
    idata = UIImagePNGRepresentation(img);
    if ( ![[NSUserDefaults standardUserDefaults]synchronize]){
      NSLog(@"Error");
    }
    
    _badge2.frame = CGRectMake(_badge2.frame.origin.x, _badge2.frame.origin.y, 100, 101);
    [_badge2 setBackgroundImage:img forState:UIControlStateNormal];
    
    isBadgeFlg = YES;
  }
  
}

-(IBAction)badge3DoublePushed:(id)sender{
  
  if(isBadgeFlg){
    isBadgeFlg = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"Badge3"];
    BOOL successful = [[NSUserDefaults standardUserDefaults]synchronize
                       ];
    if (!successful) {
      NSLog(@"%@", [pData getDataForKey:@"DEFINE_TOP_DELETEDATAERR"]);
      return;
    }
    
    UIImage * img;
    NSData *idata;
    NSString *path =  [[NSBundle mainBundle] pathForResource:@"badge" ofType:@"png"];
    img = [[UIImage alloc] initWithContentsOfFile:path];
    //img = [UIImage imageNamed:@"badge.png"];
    idata = UIImagePNGRepresentation(img);
    if ( ![[NSUserDefaults standardUserDefaults]synchronize]){
      NSLog(@"Error");
    }
    
    _badge3.frame = CGRectMake(_badge3.frame.origin.x, _badge3.frame.origin.y, 100, 101);
    [_badge3 setBackgroundImage:img forState:UIControlStateNormal];
    
    isBadgeFlg = YES;
  }
  
}

-(IBAction)badge4DoublePushed:(id)sender{
  
  if(isBadgeFlg){
    isBadgeFlg = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"Badge4"];
    BOOL successful = [[NSUserDefaults standardUserDefaults]synchronize
                       ];
    if (!successful) {
      NSLog(@"%@", [pData getDataForKey:@"DEFINE_TOP_DELETEDATAERR"]);
      return;
    }
    
    UIImage * img;
    NSData *idata;
    NSString *path =  [[NSBundle mainBundle] pathForResource:@"badge" ofType:@"png"];
    img = [[UIImage alloc] initWithContentsOfFile:path];
    //img = [UIImage imageNamed:@"badge.png"];
    idata = UIImagePNGRepresentation(img);
    if ( ![[NSUserDefaults standardUserDefaults]synchronize]){
      NSLog(@"Error");
    }
    
    _badge4.frame = CGRectMake(_badge4.frame.origin.x, _badge4.frame.origin.y, 100, 101);
    [_badge4 setBackgroundImage:img forState:UIControlStateNormal];
    
    isBadgeFlg = YES;
  }
  
}

-(IBAction)badge5DoublePushed:(id)sender{
  
  if(isBadgeFlg){
    isBadgeFlg = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"Badge5"];
    BOOL successful = [[NSUserDefaults standardUserDefaults]synchronize
                       ];
    if (!successful) {
      NSLog(@"%@", [pData getDataForKey:@"DEFINE_TOP_DELETEDATAERR"]);
      return;
    }
    
    UIImage * img;
    NSData *idata;
    NSString *path =  [[NSBundle mainBundle] pathForResource:@"badge" ofType:@"png"];
    img = [[UIImage alloc] initWithContentsOfFile:path];
    //img = [UIImage imageNamed:@"badge.png"];
    idata = UIImagePNGRepresentation(img);
    if ( ![[NSUserDefaults standardUserDefaults]synchronize]){
      NSLog(@"Error");
    }
    
    _badge5.frame = CGRectMake(_badge5.frame.origin.x, _badge5.frame.origin.y, 100, 101);
    [_badge5 setBackgroundImage:img forState:UIControlStateNormal];
    
    isBadgeFlg = YES;
  }
}

-(IBAction)badge6DoublePushed:(id)sender{
  
  if(isBadgeFlg){
    isBadgeFlg = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"Badge6"];
    BOOL successful = [[NSUserDefaults standardUserDefaults]synchronize
                       ];
    if (!successful) {
      NSLog(@"%@", [pData getDataForKey:@"DEFINE_TOP_DELETEDATAERR"]);
      return;
    }
    
    UIImage * img;
    NSData *idata;
    NSString *path =  [[NSBundle mainBundle] pathForResource:@"badge" ofType:@"png"];
    img = [[UIImage alloc] initWithContentsOfFile:path];
    //img = [UIImage imageNamed:@"badge.png"];
    idata = UIImagePNGRepresentation(img);
    if ( ![[NSUserDefaults standardUserDefaults]synchronize]){
      NSLog(@"Error");
    }
    
    _badge6.frame = CGRectMake(_badge6.frame.origin.x, _badge6.frame.origin.y, 100, 101);
    [_badge6 setBackgroundImage:img forState:UIControlStateNormal];
    
    isBadgeFlg = YES;
  }
}


//ImagePickerで画像を選択時のデリゲート
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *img;
	NSData *idata;
	NSString *key;
  
	//画像取得
	img = [info objectForKey:UIImagePickerControllerOriginalImage];
  float asp;
  int height = Badge_Height;
  int width  = Badge_Width;
  
  NSData* pidata = UIImagePNGRepresentation(img);
  int bytesize = pidata.length;
  
  
  //画像サイズが閾値より大きい場合はアラートを出す
  if ( MaxLoadingSize <=  bytesize) {
    //todo
    
    alertView = [[UIAlertView alloc]
                 initWithTitle:[pData getDataForKey:@"DEFINE_TOP_IMAGEREADERR"]
                 message:[pData getDataForKey:@"DEFINE_TOP_IMAGESIZETOOLARGE"]
                 delegate:nil
                 cancelButtonTitle:nil
                 otherButtonTitles:[pData getDataForKey:@"DEFINE_TOP_ALERTOK"], nil ];
    [alertView show];
    
    [pop dismissPopoverAnimated:YES];	//ポップオーバーを消す
    isBadgeFlg = YES;
    
    return;
  }
  
  
  if (img.size.height > img.size.width) {
    asp = img.size.width / img.size.height;
    width = width * asp;
  }else{
    asp = img.size.height / img.size.width;
    height = height * asp;
  }
  
  
  CGRect rect;
  
	switch (tag) {
			
		case 1:
      rect = CGRectMake(_badge1.frame.origin.x, _badge1.frame.origin.y, width, height);
      _badge1.frame = rect;
      
			[_badge1 setBackgroundImage:img forState:UIControlStateNormal];
			key = [um makeId:@"Badge1"];		//保存キー
			break;
		case 2:
      rect = CGRectMake(_badge2.frame.origin.x, _badge2.frame.origin.y, width, height);
      _badge2.frame = rect;
      
			[_badge2 setBackgroundImage:img forState:UIControlStateNormal];
			key = [um makeId:@"Badge2"];		//保存キー
			break;
		case 3:
      rect = CGRectMake(_badge3.frame.origin.x, _badge3.frame.origin.y, width, height);
      _badge3.frame = rect;
      
			[_badge3 setBackgroundImage:img forState:UIControlStateNormal];
			key = [um makeId:@"Badge3"];		//保存キー
			break;
		case 4:
      rect = CGRectMake(_badge4.frame.origin.x, _badge4.frame.origin.y, width, height);
      _badge4.frame = rect;
      
			[_badge4 setBackgroundImage:img forState:UIControlStateNormal];
			key = [um makeId:@"Badge4"];		//保存キー
			break;
		case 5:
      rect = CGRectMake(_badge5.frame.origin.x, _badge5.frame.origin.y, width, height);
      _badge5.frame = rect;
      
			[_badge5 setBackgroundImage:img forState:UIControlStateNormal];
			key = [um makeId:@"Badge5"];		//保存キー
			break;
		case 6:
      rect = CGRectMake(_badge6.frame.origin.x, _badge6.frame.origin.y, width, height);
      _badge6.frame = rect;
      
			[_badge6 setBackgroundImage:img forState:UIControlStateNormal];
			key = [um makeId:@"Badge6"];		//保存キー
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
	[pop dismissPopoverAnimated:YES];	//ポップオーバーを消す
  isBadgeFlg = YES;
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController*)picker {
  isBadgeFlg = YES;
}

/*
 //履歴ボタン
 - (IBAction)historyBtnPushed:(id)sender {
 
 //履歴画面をPopoverで表示
 historyPopOverViewController *hist = [[historyPopOverViewController alloc]init];
 hist.delegate = self;
 pop = [[UIPopoverController alloc]initWithContentViewController:hist];
 pop.delegate = self;
 pop.popoverContentSize = hist.view.frame.size;
 [pop presentPopoverFromRect:historyBtn.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
 
 }
 */

//地図ボタン
/*
 - (IBAction)mapBtnPushed:(id)sender {
 mapSearchViewController *mapVC = [[mapSearchViewController alloc]initWithNibName:@"mapSearchViewController" bundle:[NSBundle mainBundle]];
 [self.navigationController pushViewController:mapVC animated:YES];
 }
 */

//オブジェクトがNULLであるかチェック
-(BOOL)isNull:(id)tgt
{
	if ((( tgt == [NSNull null] ) || ([tgt isEqual:[NSNull null]] ) || ( tgt ==  nil ))){
		return YES;
	}
	return NO;
}

// 画像キャッシュファイルの更新チェック
-(void)checkCacheFile
{
  if(isNeedSync) return;
  
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
                                    
                                    @try{
                                      // ファイル更新
                                      // 年月日チェック
                                      if([um compareFileDate:productId name:Name date:[dic objectForKey:@"LastModifiedDate"]]) {
                                        if(isNeedSync) return;
                                        // Syncありアラート
                                        [self syncAlert];
                                        break;
                                      }
                                      
                                    }@catch (NSException *exception) {
                                      NSLog(@"name  :%@",exception.name);
                                      NSLog(@"reason:%@",exception.reason);
                                    }
                                  }
                                }
   ];
}

// 動画キャッシュファイルの更新チェック
-(void)checkMovieFile
{
  if(isNeedSync) return;
  
  um = [UtilManager sharedInstance];
  NSString *query = @"SELECT Id,ProductCode,Name,Family,Description,URL__c ,order__c, LastModifiedDate  FROM product2 WHERE IsActive=true  ORDER BY order__c";
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
                                      if(isNeedSync) return;
                                      // Syncありアラート
                                      [self syncAlert];
                                      break;
                                    }
                                  }
                                }
   ];
}

-(void)syncAlert
{
  isNeedSync = YES;
  // Syncありアラート
  alertView = [[UIAlertView alloc]
               initWithTitle:[pData getDataForKey:@"DEFINE_TOP_SYNC_ALERT_UPDATEEXIST_TITLE"]
               message:[pData getDataForKey:@"DEFINE_TOP_SYNC_ALERT_UPDATEEXIST_MESSAGE"]
               delegate:nil
               cancelButtonTitle:nil
               otherButtonTitles:[pData getDataForKey:@"DEFINE_TOP_SYNC_ALERT_UPDATEEXIST_OK"], nil ];
  [alertView show];
}


@end
