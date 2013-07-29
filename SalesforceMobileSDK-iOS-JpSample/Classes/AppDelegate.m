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


#import "AppDelegate.h"
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import "RootViewController.h"
#import "SalesforceProjectViewController.h"
#import "Reachability.h"
#import "GoogleMaps/GoogleMaps.h"
#import "UtilManager.h"

/*
 NOTE if you ever need to update these, you can obtain them from your Salesforce org,
 (When you are logged in as an org administrator, go to Setup -> Develop -> Remote Access -> New )
 */


// Fill these in when creating a new Remote Access client on Force.com
static NSString *const RemoteAccessConsumerKey = @"3MVG9Iu66FKeHhINkB1l7xt7kR8czFcCTUhgoA8Ol2Ltf1eYHOU4SqQRSEitYFDUpqRWcoQ2.dBv_a1Dyu5xa";
static NSString *const OAuthRedirectURI = @"testsfdc:///mobilesdk/detect/oauth/done";


@implementation AppDelegate

#pragma mark - Remote Access / OAuth configuration


- (NSString*)remoteAccessConsumerKey {
    return RemoteAccessConsumerKey;
}

- (NSString*)oauthRedirectURI {
    return OAuthRedirectURI;
}

#pragma mark - App lifecycle


//NOTE be sure to call all super methods you override.


- (UIViewController*)newRootViewController {

	[GMSServices provideAPIKey:@"AIzaSyAGqEl5pULXGJs1OT2p5UMYyYINb8_52Lc"];
	
  //テキストリソース設定
  UtilManager *um = [UtilManager sharedInstance];
  [um applyUserSetting];
  
	//共有データ初期化
	_pData = [PublicDatas instance];
	NSMutableArray *history = [NSMutableArray array];			//表示履歴
	[_pData setData:history forKey:@"history"];					//共有データに追加
	[self setUserDefaults];
	[self setTextResource];
	[self setMyInfo];

    SalesforceProjectViewController  *rootVC = [[SalesforceProjectViewController alloc] initWithNibName:@"Start" bundle:nil];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:rootVC];
    [rootVC release];
    
    return navVC;
}

-(void)setTextResource
{
	_pData = [PublicDatas instance];
}

-(void)setMyInfo
{
	NSString *myId = [SFAccountManager sharedInstance].idData.userId;
	NSString *myLastName = [SFAccountManager sharedInstance].idData.lastName;
	NSString *myFirstName = [SFAccountManager sharedInstance].idData.firstName;
	NSLog(@"%@:%@:%@",myId,myLastName,myFirstName);
	
	if ([myId isEqual:[NSNull null] ]){
		myId = @"";
	}
	if ( [myFirstName isEqual:[NSNull null]]){
		myFirstName = @"";
	}
	if ( [myLastName isEqual:[NSNull null]]){
		myLastName = @"";
	}
	
	NSString *myName = [myLastName stringByAppendingString:myFirstName];
	[_pData setData:myId forKey:@"myId"];
	[_pData setData:myName forKey:@"myName"];
}

-(void)setUserDefaults
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  // ロゴ画像のデータのみ先の削除
  NSDictionary * _dic = [ud dictionaryRepresentation];
  for(NSString *str in [_dic allKeys]){
    NSRange range = [str rangeOfString:@"img_"];
    if (range.location != NSNotFound) {
      [ud removeObjectForKey:str];
    }
  }
  
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	NSData *idata;
	
  UtilManager *um = [UtilManager sharedInstance];
  
	[dic setObject:@"default" forKey:[um makeId:@"btn1Type"]];
	[dic setObject:@"default" forKey:[um makeId:@"btn2Type"]];
	[dic setObject:@"default" forKey:[um makeId:@"btn3Type"]];
	[dic setObject:@"default" forKey:[um makeId:@"btn4Type"]];
	[dic setObject:@"default" forKey:[um makeId:@"btn5Type"]];
	[dic setObject:@"default" forKey:[um makeId:@"btn6Type"]];
	
	[dic setObject:@"default" forKey:[um makeId:@"backBtnType"]];
	[dic setObject:@"default" forKey:[um makeId:@"backType"]];
	[dic setObject:@"default" forKey:[um makeId:@"logoType"]];
  
	[dic setObject:@"default" forKey:[um makeId:@"navBarType"]];
	[dic setObject:@"default" forKey:[um makeId:@"tabBarType"]];
	[dic setObject:@"default" forKey:[um makeId:@"tab1Type"]];
	[dic setObject:@"default" forKey:[um makeId:@"tab2Type"]];
  
	[dic setObject:@"default" forKey:[um makeId:@"listBtnImage"]];
	[dic setObject:@"default" forKey:[um makeId:@"panelBackImage"]];
	[dic setObject:@"default" forKey:[um makeId:@"SalesUpImage"]];
	[dic setObject:@"default" forKey:[um makeId:@"SalesFlatImage"]];
	[dic setObject:@"default" forKey:[um makeId:@"SalesDownImage"]];
	[dic setObject:@"default" forKey:[um makeId:@"currentLoacationBtnType"]];
  
	[dic setObject:@"default" forKey:[um makeId:@"carBtnImage"]];
	[dic setObject:@"default" forKey:[um makeId:@"walkBtnImage"]];
  
	//	idata = UIImagePNGRepresentation([UIImage imageNamed:@"homeicon.png"]);
	UIImage *img = [um forceResizeImage:[UIImage imageNamed:@"homeicon.png"] Rect:CGRectMake(0,0, 25, 25)];
	idata = UIImagePNGRepresentation(img);
	[dic setObject:idata forKey:[um makeId:@"backBtnImage"]];
	
	
	idata = UIImagePNGRepresentation([UIImage imageNamed:@"SFDC_BackImg.png"]);
	[dic setObject:idata forKey:[um makeId:@"backImage"]];
  
//	idata = UIImagePNGRepresentation([UIImage imageNamed:@"title.png"]);
	img = [um forceResizeImage:[UIImage imageNamed:@"title.png"] Rect:CGRectMake(0,0, 1024, 44)];
	idata = UIImagePNGRepresentation(img);
	[dic setObject:idata forKey:[um makeId:@"navBarImage"]];
	
	idata = UIImagePNGRepresentation([UIImage imageNamed:@"logo.png"]);
	[dic setObject:idata forKey:[um makeId:@"logoImage"]];
	
	idata = UIImagePNGRepresentation([UIImage imageNamed:@"title.png"]);
	[dic setObject:idata forKey:[um makeId:@"tab1Image"]];
	
	idata = UIImagePNGRepresentation([UIImage imageNamed:@"title.png"]);
	[dic setObject:idata forKey:[um makeId:@"tab2Image"]];
	
	idata = UIImagePNGRepresentation([UIImage imageNamed:@"title.png"]);
	[dic setObject:idata forKey:[um makeId:@"tabBarImage"]];
  
	idata = UIImagePNGRepresentation([UIImage imageNamed:@"currentlocation.png"]);
	[dic setObject:idata forKey:[um makeId:@"currentLoacationBtnImage"]];
  
	idata = UIImagePNGRepresentation([UIImage imageNamed:@"listicon.png"]);
	[dic setObject:idata forKey:[um makeId:@"listBtnImage"]];
  
	idata = UIImagePNGRepresentation([UIImage imageNamed:@"panelback.png"]);
	[dic setObject:idata forKey:[um makeId:@"panelBackImage"]];
	
	idata = UIImagePNGRepresentation([UIImage imageNamed:@"salesup.png"]);
	[dic setObject:idata forKey:[um makeId:@"SalesUpImage"]];
	
	idata = UIImagePNGRepresentation([UIImage imageNamed:@"salesdown.png"]);
	[dic setObject:idata forKey:[um makeId:@"SalesDownImage"]];
	
	idata = UIImagePNGRepresentation([UIImage imageNamed:@"salesflat.png"]);
	[dic setObject:idata forKey:[um makeId:@"SalesFlatImage"]];
	
	idata = UIImagePNGRepresentation([UIImage imageNamed:@"caricon.png"]);
	[dic setObject:idata forKey:[um makeId:@"carBtnImage"]];
  
	idata = UIImagePNGRepresentation([UIImage imageNamed:@"walkicon.png"]);
	[dic setObject:idata forKey:[um makeId:@"walkBtnImage"]];
	[ud registerDefaults:dic];
	
	[self bldTopBtns];
}

-(void)bldTopBtns
{
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	
	UtilManager *um = [UtilManager sharedInstance];

	//ボタンのデフォルト画像をUIViewから作る
	[dic setObject:[self bldBtnImg:1] forKey:[um makeId:@"btn1Image"]];
	[dic setObject:[self bldBtnImg:2] forKey:[um makeId:@"btn2Image"]];
	[dic setObject:[self bldBtnImg:3] forKey:[um makeId:@"btn3Image"]];
	[dic setObject:[self bldBtnImg:4] forKey:[um makeId:@"btn4Image"]];
	[dic setObject:[self bldBtnImg:5] forKey:[um makeId:@"btn5Image"]];
	[dic setObject:[self bldBtnImg:6] forKey:[um makeId:@"btn6Image"]];
	
	[dic setObject:[self bldBtnImg:1] forKey:[um makeId:@"btn1DefaultImage"]];
	[dic setObject:[self bldBtnImg:2] forKey:[um makeId:@"btn2DefaultImage"]];
	[dic setObject:[self bldBtnImg:3] forKey:[um makeId:@"btn3DefaultImage"]];
	[dic setObject:[self bldBtnImg:4] forKey:[um makeId:@"btn4DefaultImage"]];
	[dic setObject:[self bldBtnImg:5] forKey:[um makeId:@"btn5DefaultImage"]];
	[dic setObject:[self bldBtnImg:6] forKey:[um makeId:@"btn6DefaultImage"]];
	[ud registerDefaults:dic];
	
}
-(NSData*)bldBtnImg:(int)num
{
	NSData *idata = nil;

	UIView *btnImg = [[UIView alloc]initWithFrame:CGRectMake(0,0, 200, 200)];
	UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(10,-10, 190, 50)];
	lbl.backgroundColor = [UIColor clearColor];
	lbl.textColor = [UIColor whiteColor];
	[btnImg addSubview:lbl];

  UtilManager *um = [UtilManager sharedInstance];
  
	switch (num) {
		case 1:

			lbl.text = [_pData getDataForKey:@"DEFINE_APP_LABEL_MAP"];
			btnImg.backgroundColor = [UIColor colorWithRed:0.00 green:0.50 blue:1.00 alpha:1.0];
			idata = UIImagePNGRepresentation([um convViewToImage:btnImg]);
			break;

		case 2:
			lbl.text = [_pData getDataForKey:@"DEFINE_APP_LABEL_ROUTE"];
			btnImg.backgroundColor = [UIColor colorWithRed:0.09 green:0.59 blue:0.75 alpha:1.0];
			idata = UIImagePNGRepresentation([um convViewToImage:btnImg]);
			break;
			
		case 3:
			lbl.text = [_pData getDataForKey:@"DEFINE_APP_LABEL_DASHBOARD"];
			btnImg.backgroundColor = [UIColor colorWithRed:0.01 green:0.41 blue:0.64 alpha:1.0];
			idata = UIImagePNGRepresentation([um convViewToImage:btnImg]);
			break;
			
		case 4:
			lbl.text = [_pData getDataForKey:@"DEFINE_APP_LABEL_CHATTER"];
			btnImg.backgroundColor = [UIColor colorWithRed:0.04 green:0.24 blue:0.50 alpha:1.0];
			idata = UIImagePNGRepresentation([um convViewToImage:btnImg]);
			break;
			
		case 5:
			lbl.text = [_pData getDataForKey:@"DEFINE_APP_LABEL_SETTING"];
			btnImg.backgroundColor = [UIColor colorWithRed:0.02 green:0.62 blue:0.87 alpha:1.0];
			idata = UIImagePNGRepresentation([um convViewToImage:btnImg]);
			break;
			
		case 6:
			lbl.text = [_pData getDataForKey:@"DEFINE_APP_LABEL_NON"];
			btnImg.backgroundColor = [UIColor colorWithRed:0.44 green:0.63 blue:0.75 alpha:1.0];
			idata = UIImagePNGRepresentation([um convViewToImage:btnImg]);
			break;

		default:
			break;
	}
	[lbl release];
	[btnImg release];
	
	return idata;
}


// ネットワークの状態をチェックするメソッド
-(BOOL)chkConn
{
  BOOL canComm = [self canDoComm];
  if ( !canComm ) {
    
    // アラートビューを作成する
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:[_pData getDataForKey:@"DEFINE_APP_ALERT_COMM"]
                                       message:[_pData getDataForKey:@"DEFINE_APP_ALERT_COMM_MESSAGE"]
                                      delegate:nil
                             cancelButtonTitle:nil
                             otherButtonTitles:[_pData getDataForKey:@"DEFINE_APP_ALERT_COMM_OK"],nil];
    // アラートビューを表示
    [alert show];
    // ここで止めて次に進まない
    return false;
  }
  return true;
}

// ネットワークにつながっているか確認するメソッド
-(BOOL)canDoComm{
  Reachability *curReach = [Reachability reachabilityForInternetConnection];
  NetworkStatus netStatus = [curReach currentReachabilityStatus];
  NSLog(@"status %d", netStatus);
  switch (netStatus) {
    case NotReachable:
      break;
    case ReachableViaWWAN:
      return true;
    case ReachableViaWiFi:
      return true;
  }
  return false;
}

-(BOOL)chkGPS
{
  NSLog(@" gps enable %d", [CLLocationManager locationServicesEnabled]);
  NSLog(@"appli gps enable %d", [CLLocationManager authorizationStatus]);
  NSLog(@"fiest %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"first"]);
  
  // 初回起動時はlocationServicesEnabledのみのチェック
  if(![[NSUserDefaults standardUserDefaults] stringForKey:@"first"]){
    if([CLLocationManager locationServicesEnabled]){
      return true;
    }
  }
  
  if([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus]==3)){
    return true;
  }else{
    // アラートビューを作成する
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:[_pData getDataForKey:@"DEFINE_APP_ALERT_LOCATION"]
                                       message:[_pData getDataForKey:@"DEFINE_APP_ALERT_LOCATION_MESSAGE"]
                                      delegate:nil
                             cancelButtonTitle:nil
                             otherButtonTitles:[_pData getDataForKey:@"DEFINE_APP_ALERT_LOCATION_OK"],nil];
    // アラートビューを表示
    [alert show];
    // ここで止めて次に進まない
    return false;
  }
}

// キャッシュファイルの更新メソッド YES:ファイルまで更新 NO:アラートのみ
-(void)updateCacheFile:(BOOL)fileUpdate
{
  _pData = [PublicDatas instance];
  UtilManager *um = [UtilManager sharedInstance];
  NSMutableArray *IDs = [um getProductIDs];
  
  NSString *where = @"";
  int loopMax = [IDs count];
	int loopCnt = 0;
  
	for (NSString *pid in IDs ) {
    
		//画像URL初期
		where = [where stringByAppendingString:[NSString stringWithFormat:@"ParentId='%@'",pid ]];
		if ( loopCnt++ != loopMax - 1 ){
			where = [where stringByAppendingString:@" OR "];
		}
	}
	NSString *query = [NSString stringWithFormat:@"SELECT ParentId,Name,Body,BodyLength, Id, LastModifiedDate FROM Attachment WHERE %@ ORDER BY CreatedDate DESC",where];
  SFRestRequest *req = [[SFRestAPI sharedInstance] requestForQuery:query];
  [[SFRestAPI sharedInstance] sendRESTRequest:req
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      
                                    }
                                completeBlock:^(id jsonResponse){
                                  
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  
                                  //ファイル更新時は先にローディングを表示
                                  if(fileUpdate) [self alertShow];
                                  
                                  //NSLog(@"45 %@",dict);
                                  for(NSDictionary *dic in [dict objectForKey:@"records"]){
                                    NSString *productId = [dic objectForKey:@"ParentId"];
                                    NSString *Id = [dic objectForKey:@"Id"];
                                    
                                    // 端末内にあるファイルのみ考える
                                    if(![um existProductFile:productId name:Id]) continue;
                                      
                                    BOOL b = [um compareCacheDate:[dic objectForKey:@"LastModifiedDate"]];
                                    NSLog(@"BOOL %d", b);
                                    if(b){
                                      if(!fileUpdate){
                                        [_pData setData:@"YES" forKey:@"fileRenew"];
                                        // アラート
                                        alertView = [[UIAlertView alloc]
                                                                  initWithTitle:@""
                                                                  message:[_pData getDataForKey:@"DEFINE_APP_TITLE_UPDATEEXIST_MESSAGE"] 
                                                                  delegate:nil
                                                                  cancelButtonTitle:nil
                                                                  otherButtonTitles:[_pData getDataForKey:@"DEFINE_APP_TITLE_UPDATEEXIST_OK"], nil ];
                                        [alertView show];
                                        break;
                                      }
                                      // ファイル更新
                                      else{
                                        
                                        
                                        // 年月日チェック
                                        if(![um compareFileDate:productId name:Id date:[dic objectForKey:@"LastModifiedDate"]]) continue;
                                        
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
                                          [um saveProductFile:productId name:Id data:rcvData];
                                        }
                                        @catch (NSException *exception) {
                                          NSLog(@"name  :%@",exception.name);
                                          NSLog(@"reason:%@",exception.reason);
                                        }
                                        
                                      }
                                      }
                                  }
                                  if(fileUpdate){
                                    [_pData setData:@"" forKey:@"fileRenew"];
                                    if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
                                    
                                    // 完了アラート
                                    alertView = [[UIAlertView alloc]
                                                              initWithTitle:@""
                                                              message:[_pData getDataForKey:@"DEFINE_APP_TITLE_UPDATEDONE_MESSAGE"]
                                                              delegate:nil
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:[_pData getDataForKey:@"DEFINE_APP_TITLE_UPDATEDONE_OK"], nil ];
                                    [alertView show];
                                  }
                                }
   
	 ];
}

// ローディングアラートの表示
-(void)alertShow
{
  _pData = [PublicDatas instance];
	// ローディングアラートを生成
	alertView = [[UIAlertView alloc] initWithTitle:[_pData getDataForKey:@"DEFINE_APP_LOADING_TITLE"] message:nil
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



@end

