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


#import "CompanyProfiles.h"
#import "PublicDatas.h"
#import "AppDelegate.h"

@implementation CompanyProfiles

//画像サムネイルサイズ
static const float	THUMBSIZE_X = 55;
static const float	THUMBSIZE_Y = 55;

//画像読み込みの閾値(単位」Byte）
static const int	MAXLOADINGSIZE = ( 200 * 1024 );


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
      pData = [PublicDatas instance];
    }
    return self;
}
- (void)awakeFromNib {

  pData = [PublicDatas instance];
    //xib読み込み
	[[NSBundle mainBundle] loadNibNamed:@"CompanyProfiles" owner:self options:nil];

	//Viewの角を丸める
//	self.layer.cornerRadius = 6;
	_childView.layer.cornerRadius = 3.0;
//	logoImage.layer.cornerRadius = 6;
	[self addSubview:_childView];

	//現在地取得準備
	locationManager = [[CLLocationManager alloc]init];
	if ([CLLocationManager locationServicesEnabled]){
		
		//位置情報取得可能なら測位開始
		[locationManager setDelegate:self];
		[locationManager startUpdatingLocation];
	}
	positionDetected = NO;

	_chkInBtn.opaque = YES;
	_chkInBtn.alpha = 0.0f;
	_chkOutBtn.opaque = YES;
	_chkOutBtn.alpha = 0.0f;

	//住所をタップで地図に移動
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addressTaped)];
	[_addressLabel2 addGestureRecognizer:tap];
	_addressLabel2.userInteractionEnabled = YES;
	
	
	// ローディングアラートを生成
	lAlertView = [[UIAlertView alloc] initWithTitle:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_LOADING_TITLE"]
                                          message:nil
										  delegate:nil cancelButtonTitle:nil otherButtonTitles:NULL];
	progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
	progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	[lAlertView addSubview:progress];
	[progress startAnimating];
}

-(void)setUpCheckInOut
{
	_chkInBtn.opaque = NO;
	_chkInBtn.alpha = 1.0f;
	_chkOutBtn.opaque = NO;
	_chkOutBtn.alpha = 1.0f;
	
	_chkInBtn.enabled = NO;
	_chkOutBtn.enabled = NO;
	
	//24時間以内に作成され、チェックアウトされてないオブジェクトを抽出
	ObjArray = [NSMutableArray array];
	[self getEventList];
	
//	chkInBtn.enabled = YES;
//	chkOutBtn.enabled = NO;
}

// ローディングアラートの表示
-(void)alertShow
{
	[NSTimer scheduledTimerWithTimeInterval:20.0f
									 target:self
								   selector:@selector(performDismiss:)
								   userInfo:lAlertView repeats:NO];
	[lAlertView show];
}
// アラートを閉じるメソッド
- (void)performDismiss:(NSTimer *)theTimer
{
	lAlertView = [theTimer userInfo];
	[lAlertView dismissWithClickedButtonIndex:0 animated:NO];
}

-(void)setAddressLabel:(NSString *)text
{
	adrs1 = text;
  if (adrs1!= nil && ![adrs1 isEqual:[NSNull null]]){
	_addressLabel2.text = [adrs1 stringByAppendingString:adrs1];
  }
}

-(void)setPhoneLabel:(NSString *)text
{
	_phoneLabel2.text = text;
}

-(void)setNameLabel:(NSString *)text
{
	_companyNameLabel.text = text;
}

-(void)setStreetLabel:(NSString*)text
{
	adrs2 = text;
  if (adrs1!= nil && ![adrs1 isEqual:[NSNull null]]){
    _addressLabel2.text = [adrs1 stringByAppendingString:adrs2];
  }else{
    _addressLabel2.text = adrs2;
  }
}

-(void)setInfo:(Company*)cpny
{
  // ネットワーク利用チェック
  AppDelegate* appli = (AppDelegate*)[[UIApplication sharedApplication] delegate];
  [appli chkConn];
  
	NSLog(@"companyID:%@",cpny.company_id);
	_companyNameLabel.text = cpny.name;
  
  if (cpny.Address1!= nil && ![cpny.Address1 isEqual:[NSNull null]]){
    _addressLabel2.text = [cpny.Address1 stringByAppendingString:cpny.Address2];
  }else{
    _addressLabel2.text = cpny.Address2;
  }
	[_addressLabel2 sizeToFit];
	
	
  // streetlabel.text = cpny.Address2;
	_phoneLabel2.text = cpny.phone1;
	NSLog(@"%f",cpny.image.size.width);
	_logoImage.image = [self resizeImage:cpny.image withRect:_logoImage.frame];
	cp = cpny;
  pData = [PublicDatas instance];
}

- (void)drawRect:(CGRect)rect
{
}


//チェックイン押下時処理
- (IBAction)ChkInPushed:(id)sender {
	isCheckIN = YES;
  alertView = [[UIAlertView alloc]
               initWithTitle: [pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_CHECKIN"]
               message:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_CHECKIN_MESSAGE"]
               delegate:self
               cancelButtonTitle:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_CHECKIN_CANCEL"]
               otherButtonTitles:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_CHECKIN_OK"], nil ];
  [alertView show];
  // ボタンを無効化
  _chkInBtn.enabled = NO;
}

//チェックイン実行
-(void)doChkIN
{
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
	NSString *title = [NSString stringWithFormat:@"行動_%@_%@_%@", sttForObjName, myName, cp.name];
	NSDictionary *param;
	if ( positionDetected == YES ){
		//位置取得済みであれば、緯度経度を付加する。
		NSString *lat = [NSString stringWithFormat:@"%f",myPos.latitude];
		NSString *lng = [NSString stringWithFormat:@"%f",myPos.longitude];
/*
		param = [NSDictionary dictionaryWithObjectsAndKeys:	title,@"Subject",
							   cp.company_id,@"WhatId",
							   @"",@"DRID__c",
							   @"false",@"IsAllDayEvent",
							   sttForRegist, @"ActivityDateTime",
							   lat,@"GPS_checkin_LatNum__c",
							   lng,@"GPS_checkin_LngNum__c",
							   sttForRegist,@"timeStamp_checkin__c",
							   @"60",@"DurationInMinutes",nil];
*/
		param = [NSDictionary dictionaryWithObjectsAndKeys:	title,@"Subject",
				 cp.company_id,@"WhatId",
				 @"false",@"IsAllDayEvent",
				 sttForRegist, @"ActivityDateTime",
             lat,@"GPS_checkin__Latitude__s",
             lng,@"GPS_checkin__Longitude__s",
				 sttForRegist,@"timeStamp_checkin__c",
				 @"60",@"DurationInMinutes",nil];

	
	}
	else {
/*
		param = [NSDictionary dictionaryWithObjectsAndKeys:	title,@"Subject",
							   cp.company_id,@"WhatId",
							   @"",@"DRID__c",
							   @"false",@"IsAllDayEvent",
							   sttForRegist, @"ActivityDateTime",
							   @"60",@"DurationInMinutes",nil];
*/
		param = [NSDictionary dictionaryWithObjectsAndKeys:	title,@"Subject",
				 cp.company_id,@"WhatId",
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
                 initWithTitle:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_CHECKIN_ERROR"]
                 message:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_CHECKIN_MESSAGE_ERROR"]
                 delegate:nil
                 cancelButtonTitle:nil
                 otherButtonTitles:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_CHECKIN_OK_ERROR"], nil ];
		[alertView show];
    // 失敗時にはボタンを戻す
    _chkInBtn.enabled = YES;
	}
	completeBlock:^(id jsonResponse){
		NSDictionary *dict = (NSDictionary *)jsonResponse;
		NSLog(@"%@",dict);

		NSNumber *success = [dict objectForKey:@"success"];
		if ( [success intValue] == 1 ){
			
			//チェックイン成功
			checkInID = [dict objectForKey:@"id"];
			_chkInBtn.enabled = NO;
			_chkOutBtn.enabled = YES;

      //成功アラート
      alertView = [[UIAlertView alloc]
                   initWithTitle:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_CHECKIN_SUCCESS"]
                   message:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_CHECKIN_MESSAGE_SUCCESS"]
                   delegate:nil
                   cancelButtonTitle:nil
                   otherButtonTitles:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_CHECKIN_OK_SUCCESS"], nil ];
      [alertView show];
		}
		else {
			
      //失敗アラート
      alertView = [[UIAlertView alloc]
                   initWithTitle:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_CHECKIN_ERROR"]
                   message:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_CHECKIN_MESSAGE_ERROR"]
                   delegate:nil
                   cancelButtonTitle:nil
                   otherButtonTitles:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_CHECKIN_OK_ERROR"], nil ];
      [alertView show];
      // 失敗時にはボタンを戻す
      _chkInBtn.enabled = YES;
		}
	}];
}

//チェックアウト押下時処理
- (IBAction)chkOutPushed:(id)sender {
	isCheckIN = NO;
  alertView = [[UIAlertView alloc]
               initWithTitle: [pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_CHECKOUT"]
               message:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_CHECKOUT_MESSAGE"]
               delegate:self
               cancelButtonTitle:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_CHECKOUT_CANCEL"]
               otherButtonTitles:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_CHECKOUT_OK"], nil ];
  [alertView show];
  // ボタンを無効化
  _chkOutBtn.enabled = NO;
}

//チェックアウト実行
-(void)doChkOUT
{
	if ([checkInID isEqual:[NSNull null]]){
		return;
	}
	
	NSString *path = [@"/services/data/v26.0/sobjects/Event/" stringByAppendingString:checkInID];
	
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
                   initWithTitle:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_CHECKOUT_ERROR"]
                   message:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_CHECKOUT_MESSAGE_ERROR"]
                   delegate:nil
                   cancelButtonTitle:nil
                   otherButtonTitles:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_CHECKOUT_OK_ERROR"], nil ];
      [alertView show];
      
      // 失敗時にはボタンを有効化
      _chkOutBtn.enabled = YES;
		}
		completeBlock:^(id jsonResponse){
			NSDictionary *dict = (NSDictionary *)jsonResponse;
			NSLog(@"%@",dict);
			_chkInBtn.enabled = YES;
			_chkOutBtn.enabled = NO;

      //成功アラート
      alertView = [[UIAlertView alloc]
                   initWithTitle:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_CHECKOUT_SUCCESS"]
                   message:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_CHECKOUT_MESSAGE_SUCCESS"]
                   delegate:nil
                   cancelButtonTitle:nil
                   otherButtonTitles:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_CHECKOUT_OK_SUCCESS"], nil ];
      
      [alertView show];
		}
	 ];
}

//行動一覧を取得
-(void)getEventList
{
	//開始・終了時間
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
                   initWithTitle:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_EVENT_ERROR"]
                   message:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_EVENT_MESSAGE_ERROR"]
                   delegate:nil
                   cancelButtonTitle:nil
                   otherButtonTitles:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_EVENT_OK_ERROR"], nil ];
      [alertView show];
		}
		completeBlock:^(id jsonResponse){
			NSDictionary *dict = (NSDictionary *)jsonResponse;
			NSLog(@"%@",dict);
			NSArray *records = [dict objectForKey:@"records"];
						
			for ( int i = 0; i < [records count]; i++ ) {
				NSDictionary *rec = [records objectAtIndex:i];
				NSString *ObjName = [rec objectForKey:@"Subject"];
				NSString *evId = [rec objectForKey:@"Id"];
				
				//名称の最後が会社名と一致する場合
				if ( [ObjName hasSuffix:cp.name] ) {
					_chkOutBtn.enabled = YES;
					_chkInBtn.enabled = NO;
					checkInID = evId;
					return;
				}
			}
			checkInID = @"";
			_chkOutBtn.enabled = NO;
			_chkInBtn.enabled = YES;

		}
	 ];
}



//画像取得
-(void)retriveImage
{
	//共用データのインスタンス取得
	pData = [PublicDatas instance];
	
	//キャッシュされている画像の取引先を取得
	Company *cachedCP = [pData getDataForKey:@"imageCachedCompnay"];
	imgCache = [NSMutableArray array];

	//ロゴ画像か?
	logoFound = NO;

	//保存用配列クリア
	imgArray = [NSMutableArray array];
	
	if ( [cachedCP.company_id isEqualToString:cp.company_id] == YES ) {

		//キャッシュがあれば読み込み
		imgCnt = 0;
		NSMutableArray *cacheArray = [pData getDataForKey:@"imageCache"];
		for (int i = 0 ; i < [cacheArray count]; i++ ) {
			NSData *cacheData = [cacheArray objectAtIndex:i];
			[self tileImage:cacheData];
			[imgCache addObject:cacheData];
			NSLog(@"%d",[imgCache count]);

		}
		if ( imgCnt ){

			//キャッシュ済みの画像を重複して読み込むことを防止するため、６枚読み込んだ事にする
			imgCnt = 6;
		}
		
		NSData *logoCache =[[NSData alloc]init];
		if ( nil != [pData getDataForKey:@"companyLogoCache"] ) {
			logoCache = [pData getDataForKey:@"companyLogoCache"];
			if ( [logoCache length]){
				UIImage *img = [[UIImage alloc]initWithData:logoCache];
				_logoImage.image = [self resizeImage:img withRect:_logoImage.frame];
				logoFound = YES;
				[pData setData:logoCache forKey:@"companyLogoCache"];
			}
		}
		
		if (( imgCnt == 6) && ( logoFound == YES)) {
			return;
		}
        #pragma unused(logoCache)
	}
	
  
	NSString *query = [NSString stringWithFormat:@"SELECT Name,Body,BodyLength FROM Attachment WHERE ParentId='%@' ORDER BY CreatedDate DESC",cp.company_id];;
	SFRestRequest *req = [[SFRestAPI sharedInstance] requestForQuery:query];
	[[SFRestAPI sharedInstance] sendRESTRequest:req
		failBlock:^(NSError *e) {
			NSLog(@"FAILWHALE with error: %@", [e description] );
      //エラーアラート
      alertView = [[UIAlertView alloc]
                   initWithTitle:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_IMAGE_ERROR"]
                   message:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_IMAGE_MESSAGE_ERROR"]
                   delegate:nil
                   cancelButtonTitle:nil
                   otherButtonTitles:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_IMAGE_OK_ERROR"], nil ];
      [alertView show];
		}
		completeBlock:^(id jsonResponse){
			NSDictionary *dict = (NSDictionary *)jsonResponse;
			NSLog(@"%@",dict);

			//アラート表示
			[self alertShow];
			[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
			
			//受信データクリア
			rcvData = [[NSMutableData alloc]init];
						
			NSArray *records = [dict objectForKey:@"records"];
			for ( int i = 0,addCnt = 0; i< [records count]; i++ ){
				
				NSDictionary *rec = [records objectAtIndex:i];
				NSString *url = [rec objectForKey:@"Body"];
				NSString *name = [rec objectForKey:@"Name"];
				NSString *bodyLength = [rec objectForKey:@"BodyLength"];
				int bSize = [bodyLength intValue];
				NSLog(@"%@",url);
        NSLog(@"name : %@",name);
				BOOL searchResult = [self isInclude:[name uppercaseString]cmp:@"LOGO."];
				NSLog(@"searchResult : %d",searchResult);
        
				//最大6枚までの画像を読み込み
				if (( searchResult == YES ) || ( imgCnt < 6 )) {

					//画像サイズが閾値より大きい場合は読み込まない
					if ( MAXLOADINGSIZE <= bSize ) {
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
						if ( searchResult == YES ){
							UIImage *img = [[UIImage alloc]initWithData:rcvData];

							//ロゴをキャッシュ
							[pData setData:rcvData forKey:@"companyLogoCache"];
							
							//画像キャッシュした取引先を保存
							[pData setData:cp forKey:@"imageCachedCompnay"];

							_logoImage.image = [self resizeImage:img withRect:_logoImage.frame];
							logoFound = YES;
							
							//デリゲートで画像をmetricsViewControllerに渡す
							if ([self.delegate respondsToSelector:@selector(logoImageFound:)]){
								[self.delegate logoImageFound:[self resizeImage:img withRect:_logoImage.frame]];
							}
						}
						else {
							if ( addCnt++ < 6 ) {
                @try {
                  //サムネイル表示
                  [self tileImage:rcvData];
                  
                  //キャッシュ
                  [imgCache addObject:rcvData];
                }
                @catch (NSException *exception) {
                  NSLog(@"main:Caught %@:%@", [exception name], [exception reason]);
                }
							}
						}
					}
					else {

						// アラートを閉じる
						if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];

						NSLog(@"FAILWHALE with error: %@", [err description] );
            //エラーアラート
            alertView = [[UIAlertView alloc]
                         initWithTitle:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_IMAGE_ERROR"]
                         message:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_IMAGE_MESSAGE_ERROR"]
                         delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:[pData getDataForKey:@"DEFINE_COMPANYPROFILE_TITLE_IMAGE_OK_ERROR"], nil ];
            [alertView show];

					}
				}
			}
			if ( logoFound == NO) {
				UIImage *img = [UIImage imageNamed:@"logo_noimage.png"];
				_logoImage.image = [self resizeImage:img withRect:_logoImage.frame];
				[pData removeDataForKey:@"companyLogoCache"];

				//デリゲートで画像をmetricsViewControllerに渡す
				if ([self.delegate respondsToSelector:@selector(logoImageFound:)]){
					[self.delegate logoImageFound:[self resizeImage:img withRect:_logoImage.frame]];
				}
			}

			//画像キャッシュ保存
			NSLog(@"%d",[imgCache count]);
			if ( [imgCache count] ) {
				[pData setData:imgCache forKey:@"imageCache"];
			
				//画像キャッシュした取引先を保存
				[pData setData:cp forKey:@"imageCachedCompnay"];
			}
			else {
				[pData removeDataForKey:@"imageCache"];
				
			}
			// アラートを閉じる
			if(lAlertView.visible) [lAlertView dismissWithClickedButtonIndex:0 animated:NO];
		}
	 ];
}


//受信開始
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	//受信データクリア
	rcvData = [[NSMutableData alloc]init];
	
	//保存用配列クリア
	imgArray = [NSMutableArray array];
}

//データ受信
- (void)connection:(NSURLConnection *) connection didReceiveData:(NSData *)data {
	[rcvData appendData:data];
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

//画像受信終了 CompanyProfile右側にタイル上に画像を並べる
//-(void)connectionDidFinishLoading:(NSURLConnection *)connection
-(void)tileImage:(NSData*)rcvDat;
{
	NSData *dat;
	float x,y;
	x = (imgCnt % 3) * ( THUMBSIZE_X + 10 ) +780;
	y = (imgCnt / 3 ) * ( THUMBSIZE_X + 5 ) + 5;
	
	dat = rcvDat;
	UIButton *imgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	imgBtn.frame =  CGRectMake(0, 0 , THUMBSIZE_X, THUMBSIZE_Y);
	UIImage *img = [[UIImage alloc]initWithData:dat];
	[imgArray addObject:img];
	UIImage *resized =  [self resizeImage:img withRect:imgBtn.frame];
	CGSize siz = resized.size;
	CGRect rect;
	rect.origin.x = x;
	rect.origin.y = y;
	rect.size = siz;
	imgBtn.frame = rect;
	imgBtn.tag = imgCnt;
	[imgBtn addTarget:self action:@selector(tileBtnPushed:) forControlEvents:UIControlEventTouchUpInside];
	[imgBtn setBackgroundImage:resized forState:UIControlStateNormal];
	[self addSubview:imgBtn];
	imgCnt++;
}

//画像配列をDelegeteで渡す
-(void)tileBtnPushed:(id)sender
{
	UIButton *wrkBtn = (UIButton*)sender;

//	if ([self.delegate respondsToSelector:@selector(didSelectTileImage:arg2:)]){
		[self.delegate didSelectTileImage:imgArray index:wrkBtn.tag];
//	}
}

-(void)addressTaped
{
	if ([self.delegate respondsToSelector:@selector(didAddressTaped)]){
		[self.delegate didAddressTaped];
	}
}

//位置取得時処理 ios 5
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
	// 位置情報を取り出す
	myPos = newLocation.coordinate;
	positionDetected = YES;
	
	if ([self.delegate respondsToSelector:@selector(detectMyPosition:)]){
		[self.delegate detectMyPosition:myPos];
	}
}

//位置取得時処理
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	CLLocation *location;
	
	//初回の位置取得時のみ地図を移動（自身の位置追跡しない）
	location = [locations objectAtIndex:0];
	myPos = location.coordinate;
	positionDetected = YES;

	if ([self.delegate respondsToSelector:@selector(detectMyPosition:)]){
		[self.delegate detectMyPosition:myPos];
	}
}

//UIImage:imgがRectより大きい場合リサイズする
-(id)resizeImage:(UIImage*)img withRect:(CGRect)Rect
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

-(void)alertView:(UIAlertView*)alertViewButon
clickedButtonAtIndex:(NSInteger)buttonIndex {

	if ( isCheckIN == YES) {
		switch (buttonIndex) {
			case 0:
        // キャンセル時にはボタンを有効化
        _chkInBtn.enabled = YES;
				break;
			case 1:
				[self doChkIN];
				break;
			default:
				break;
		}
	}
	else {
		switch (buttonIndex) {
			case 0:
        // キャンセル時にはボタンを有効化
        _chkOutBtn.enabled = YES;
				break;
			case 1:
				[self doChkOUT];
				break;
			default:
				break;
		}
	}
}

@end
