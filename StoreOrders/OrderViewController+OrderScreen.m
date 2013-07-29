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

#import "OrderViewController+OrderScreen.h"
#import "OrderInfo.h"
#import "OrderDefine.h"

@implementation OrderViewController (OrderScreen)
-(void)buildOrderScreen
{
	int total = 0;
	int wrk = 0;
	
	//小画面表示中
	dispChildScreen = YES;
	
  // ボタン無効、透明ビューの配置
  metricsBtn.enabled = NO;
	mapBtn.enabled = NO;
	ordersBtn.enabled = NO;
	chatterBtn.enabled = NO;
  self.navigationItem.leftBarButtonItem.enabled = NO;
  
  clearView = [[UIView alloc] initWithFrame:self.view.frame];
  
  
	//ポップオーバー表示中は消す
  [pop dismissPopoverAnimated:YES];
	
	self.orderWindow = [[UIView alloc]initWithFrame:CGRectMake(100,80,TOTAL_WIDTH+80, 470)];
	orderScrl = [[UIScrollView alloc]initWithFrame:CGRectMake(40,ROW_HEIGHT*3,TOTAL_WIDTH, 6*ROW_HEIGHT)];
	self.orderWindow.backgroundColor = [UIColor whiteColor];
	[self.orderWindow.layer setBorderWidth:1.0f];
	[self.orderWindow.layer setShadowColor:[[UIColor blackColor]CGColor]];
	[self.orderWindow.layer setShadowOpacity:0.5f];
	
	//ナビゲーションバー　設定
	um = [UtilManager sharedInstance];
	UIView *orderTitleBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOTAL_WIDTH+80, 40)];
	NSData *iData =[um navBarType];
	if ( [((NSString*)iData) isEqualToString:@"gray"] ) {
		[orderTitleBar setBackgroundColor:[UIColor grayColor]];
	}
	else if ( [((NSString*)iData) isEqualToString:@"black"] ) {
		[orderTitleBar setBackgroundColor:[UIColor blackColor]];
	}
	else {
		iData =[um navBarImage];
		if ( iData ) {
			UIImage *img = [UIImage imageWithData:iData];
			[orderTitleBar setBackgroundColor:[UIColor colorWithPatternImage:img]];
		}
	}
	
	UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(10,8,100,40)];
	[titleLbl setText:[pData getDataForKey:@"DEFINE_STORORDER_LABEL_ORDER"]];
	titleLbl.backgroundColor = [UIColor clearColor];
	titleLbl.textColor = [UIColor whiteColor];
	titleLbl.font = [UIFont boldSystemFontOfSize:18.0f];
	[titleLbl sizeToFit];
	
	[orderTitleBar addSubview:titleLbl];
	[self.orderWindow addSubview:orderTitleBar];
	
	//ヘッダー追加
	[self.orderWindow addSubview:[self makeOrderHead]];
	
	//データ追加
	NSArray *keys = [orderArray allKeys];
	int rCount = 0;
	for ( NSString *key in keys ){
		OrderInfo *i = [orderArray objectForKey:key];
		if ( i.quanty){
			[orderScrl addSubview:[self makeOrderRow:i row:wrk++]];
			total += ( i.price * i.quanty);
			rCount++;
		}
	}
	orderScrl.contentSize = CGSizeMake(TOTAL_WIDTH, rCount * ROW_HEIGHT);
	
	//合計追加
	//	[orderScrl addSubview:[self makesum:total row:wrk2]];
	[self.orderWindow addSubview:orderScrl];
	
	//サイン
	self.sign = [[SignBoard alloc]initWithFrame:CGRectMake(25, (orderScrl.frame.origin.y + orderScrl.frame.size.height + 10), 600, 150)];
	self.sign.delegate = self;
	self.sign.backgroundColor = [UIColor whiteColor];
	[self.orderWindow addSubview:self.sign];
	[self.orderWindow bringSubviewToFront:self.sign];
	
	//確定ボタン
	orderExec = [UIButton buttonWithType:UIButtonTypeCustom];
	CGRect r = orderExec.frame;
	r.origin.x = 650;
	r.origin.y = 400;
	r.size.width = 166;
	r.size.height = 40;
	[orderExec setFrame:r];
	//	[orderExec setTitle:@"確定"forState:UIControlStateNormal];
  //	[orderExec setBackgroundImage:[UIImage imageNamed:@"OrderPlaceButton.png"] forState:UIControlStateNormal];
	[orderExec addTarget:self action:@selector(exec) forControlEvents:UIControlEventTouchUpInside];
	orderExec.opaque = YES;
	orderExec.alpha = 0.5;
	orderExec.enabled = NO;
	[orderExec setTitle:[pData getDataForKey:@"DEFINE_STORORDER_ORDERPLACE_BTN_TITLE"] forState:UIControlStateNormal];
	[orderExec setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[orderExec setBackgroundColor:[UIColor colorWithPatternImage:btnImg]];
	[orderExec.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
	CGSize size = CGSizeMake(5.0, 5.0);
	[um makeViewRound:orderExec corners:UIRectCornerAllCorners size:&size];
  
	
	[self.orderWindow addSubview:orderExec];
	
	//終了ボタン
	UIButton *orderCloseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	r = orderCloseBtn.frame;
	r.origin.x = TOTAL_WIDTH;
	r.origin.y = 8;
	r.size.width = 80;
	r.size.height = 30;
	[orderCloseBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
	[orderCloseBtn setFrame:r];
	[orderCloseBtn setTitle:[pData getDataForKey:@"DEFINE_STORORDER_LABEL_CLOSE"] forState:UIControlStateNormal];
	[orderCloseBtn addTarget:self action:@selector(orderClosePushed) forControlEvents:UIControlEventTouchUpInside];
	[orderTitleBar addSubview:orderCloseBtn];
	
  [self.view addSubview:clearView];
	//表示
	[self.view addSubview:self.orderWindow];
	
	
	//全発注量が0の場合はオーダーボタンを無効化する
	keys = [orderArray allKeys];
	int totalQuantity  =0;
	for ( NSString *key in keys ){
		OrderInfo *i = [orderArray objectForKey:key];
		totalQuantity += i.quanty;
	}
	if ( totalQuantity == 0 ){
		orderDisable = YES;
	}
	else {
		orderDisable = NO;
	}
}




-(id)makeOrderHead
{
	CGRect r;
	UIView *baseView = [[UIView alloc]initWithFrame:CGRectMake(40,ROW_HEIGHT*2,TOTAL_WIDTH,ROW_HEIGHT)];
	baseView.backgroundColor = [UIColor colorWithRed:0.60 green:0.60 blue:0.60 alpha:1.0];
	
	//背景設定
	UIColor *backColor;
	um = [UtilManager sharedInstance];
	NSData *iData =[um navBarType];
	if ( [((NSString*)iData) isEqualToString:@"gray"] ) {
		backColor = [UIColor grayColor];
	}
	else if ( [((NSString*)iData) isEqualToString:@"black"] ) {
		backColor = [UIColor blackColor];
	}
	else {
		iData =[um navBarImage];
		if ( iData ) {
			UIImage *img = [UIImage imageWithData:iData];
			backColor = [UIColor colorWithPatternImage:img];
		}
	}
	
	
	UIView *nameView = [[UIView alloc]initWithFrame:CGRectMake(1,1,NAME_WIDTH - 2 ,ROW_HEIGHT - 2 )];
	nameView.backgroundColor = [UIColor darkGrayColor];
	r = nameView.frame;
	r.origin.x = 0;
	r.origin.y = 0;
	UILabel *nameLbl = [[UILabel alloc]initWithFrame:r];
	nameLbl.textAlignment = NSTextAlignmentCenter;
	nameLbl.text = [pData getDataForKey:@"DEFINE_STORORDER_LABEL_ITEM"];
	nameLbl.textColor = [UIColor whiteColor];
	nameLbl.backgroundColor = backColor;
	[nameView addSubview:nameLbl];
	
	UIView *quantityView = [[UIView alloc]initWithFrame:CGRectMake((NAME_WIDTH /*+PRICE_WIDTH*/),1,QUANTITY_WIDTH - 1,ROW_HEIGHT - 2 )];
	quantityView.backgroundColor = [UIColor darkGrayColor];
	r = quantityView.frame;
	r.origin.x = 0;
	r.origin.y = 0;
	UILabel *quantityLbl = [[UILabel alloc]initWithFrame:r];
	quantityLbl.textAlignment = NSTextAlignmentCenter;
	quantityLbl.text = [pData getDataForKey:@"DEFINE_STORORDER_LABEL_ORDERNUM"];
	quantityLbl.textColor = [UIColor whiteColor];
	quantityLbl.backgroundColor = backColor;
	[quantityView addSubview:quantityLbl];
	
	UIView *statusView = [[UIView alloc]initWithFrame:CGRectMake(( NAME_WIDTH+QUANTITY_WIDTH),1 , STATUS_WIDTH - 1,ROW_HEIGHT - 2 )];
	statusView.backgroundColor = [UIColor darkGrayColor];
	r = statusView.frame;
	r.origin.x = 0;
	r.origin.y = 0;
	UILabel *statusLbl = [[UILabel alloc]initWithFrame:r];
	statusLbl.textAlignment = NSTextAlignmentCenter;
	statusLbl.text = [pData getDataForKey:@"DEFINE_STORORDER_LABEL_CON"];
	statusLbl.textColor = [UIColor whiteColor];
	statusLbl.backgroundColor = backColor;
	[statusView addSubview:statusLbl];
	
	[baseView addSubview:nameView];
	[baseView addSubview:quantityView];
	[baseView addSubview:statusView];
	
	return baseView;
}

-(id)makeOrderRow:(OrderInfo*)info row:(int)row
{
	UIColor *col;
	
	if ( row % 2 ){
		col = [UIColor colorWithRed:0.8 green:0.9 blue:0.9 alpha:1.0];
	}
	else {
		col = [UIColor whiteColor];
	}
	row *= ROW_HEIGHT;
	
	CGRect r;
	UIView *baseView = [[UIView alloc]initWithFrame:CGRectMake(0,row,TOTAL_WIDTH,ROW_HEIGHT)];
	baseView.backgroundColor = [UIColor colorWithRed:0.60 green:0.60 blue:0.60 alpha:1.0];
	
	UIView *nameView = [[UIView alloc]initWithFrame:CGRectMake(1,0,NAME_WIDTH - 2 ,ROW_HEIGHT - 1 )];
	nameView.backgroundColor = [UIColor lightGrayColor];
	r = nameView.frame;
	r.origin.x = 0;
	r.origin.y = 1;
	r.size.height--;
	UILabel *nameLbl = [[UILabel alloc]initWithFrame:r];
	nameLbl.textAlignment = NSTextAlignmentCenter;
	nameLbl.text = [NSString stringWithFormat:@" %@",info.product_name];
	nameLbl.backgroundColor = col;
	[nameLbl setTextAlignment:NSTextAlignmentLeft];
	[nameView addSubview:nameLbl];
	/*
	 UIView *priceView = [[UIView alloc]initWithFrame:CGRectMake(NAME_WIDTH,1, PRICE_WIDTH - 1,ROW_HEIGHT - 1 )];
	 priceView.backgroundColor = [UIColor lightGrayColor];
	 r = priceView.frame;
	 r.origin.x = 0;
	 r.origin.y = 0;
	 UILabel *priceLbl = [[UILabel alloc]initWithFrame:r];
	 priceLbl.textAlignment = NSTextAlignmentCenter;
	 priceLbl.text = [NSString stringWithFormat:@"%d",info.price];
	 priceLbl.backgroundColor = col;
	 [priceView addSubview:priceLbl];
	 */
	UIView *quantityView = [[UIView alloc]initWithFrame:CGRectMake((NAME_WIDTH/*+PRICE_WIDTH*/),0,QUANTITY_WIDTH - 1,ROW_HEIGHT - 1 )];
	quantityView.backgroundColor = [UIColor lightGrayColor];
	r = quantityView.frame;
	r.origin.x = 0;
	r.origin.y = 1;
	r.size.height--;
	UILabel *quantityLbl = [[UILabel alloc]initWithFrame:r];
	quantityLbl.textAlignment = NSTextAlignmentCenter;
	quantityLbl.text = [NSString stringWithFormat:@"%d",info.quanty];
	quantityLbl.backgroundColor = col;
	[quantityView addSubview:quantityLbl];
	
	/*
	 UIView *sumView = [[UIView alloc]initWithFrame:CGRectMake(( NAME_WIDTH + PRICE_WIDTH + QUANTITY_WIDTH),1 , SUM_WIDTH - 1,ROW_HEIGHT - 1 )];
	 sumView.backgroundColor = [UIColor lightGrayColor];
	 r = sumView.frame;
	 r.origin.x = 0;
	 r.origin.y = 0;
	 UILabel *sumLbl = [[UILabel alloc]initWithFrame:r];
	 sumLbl.textAlignment = NSTextAlignmentCenter;
	 sumLbl.text = [NSString stringWithFormat:@"%d",(info.price * info.quanty)];
	 sumLbl.backgroundColor = col;
	 [sumView addSubview:sumLbl];
	 */
	
	UIView *statusView = [[UIView alloc]initWithFrame:CGRectMake(( NAME_WIDTH/*+PRICE_WIDTH*/+QUANTITY_WIDTH/*+SUM_WIDTH*/),0 , STATUS_WIDTH - 1,ROW_HEIGHT - 1 )];
	statusView.backgroundColor = [UIColor lightGrayColor];
	r = statusView.frame;
	r.origin.x = 0;
	r.origin.y = 1;
	r.size.height--;
	UILabel *statusLbl = [[UILabel alloc]initWithFrame:r];
	statusLbl.textAlignment = NSTextAlignmentCenter;
	statusLbl.backgroundColor = col;
	statusLbl.text = info.status;
	
	[statusView addSubview:statusLbl];
	[baseView addSubview:nameView];
	//	[baseView addSubview:priceView];
	[baseView addSubview:quantityView];
	//	[baseView addSubview:sumView];
	[baseView addSubview:statusView];
	
	return baseView;
}

-(id)makesum:(int)total row:(int)row
{
	CGRect r;
	UIColor *col = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
	row *= ROW_HEIGHT;
	
	UIView *baseView = [[UIView alloc]initWithFrame:CGRectMake(0,row,TOTAL_WIDTH,ROW_HEIGHT)];
	baseView.backgroundColor = [UIColor blackColor];
	
	UIView *quantityView = [[UIView alloc]initWithFrame:CGRectMake((NAME_WIDTH+PRICE_WIDTH),1,QUANTITY_WIDTH - 1,ROW_HEIGHT - 1 )];
	quantityView.backgroundColor = [UIColor lightGrayColor];
	r = quantityView.frame;
	r.origin.x = 0;
	r.origin.y = 0;
	UILabel *quantityLbl = [[UILabel alloc]initWithFrame:r];
	quantityLbl.textAlignment = NSTextAlignmentCenter;
	quantityLbl.text = [pData getDataForKey:@"DEFINE_STORORDER_LABEL_TOTAL"];
	quantityLbl.backgroundColor = col;
	[quantityView addSubview:quantityLbl];
	
	UIView *sumView = [[UIView alloc]initWithFrame:CGRectMake(( NAME_WIDTH + PRICE_WIDTH + QUANTITY_WIDTH),1 , SUM_WIDTH - 1,ROW_HEIGHT - 1 )];
	sumView.backgroundColor = [UIColor lightGrayColor];
	r = sumView.frame;
	r.origin.x = 0;
	r.origin.y = 0;
	UILabel *sumLbl = [[UILabel alloc]initWithFrame:r];
	sumLbl.textAlignment = NSTextAlignmentCenter;
	sumLbl.text = [NSString stringWithFormat:@"%d",total];
	sumLbl.backgroundColor = col;
	[sumView addSubview:sumLbl];
	
	[baseView addSubview:quantityView];
	[baseView addSubview:sumView];
	
	return baseView;
}


-(void)exec
{
	//	[self makeDummyData];
	
	//オーダー実行
	[self doOrder];
	
	//画面を閉じる
	[self orderClosePushed];
}

-(void)orderClosePushed
{
	[self.orderWindow removeFromSuperview];
	self.orderWindow = nil;
	
	dispChildScreen = NO;
  
  [clearView removeFromSuperview];
  metricsBtn.enabled = YES;
	mapBtn.enabled = YES;
	ordersBtn.enabled = YES;
	chatterBtn.enabled = YES;
  self.navigationItem.leftBarButtonItem.enabled = YES;
  
}
//オーダー実行
- (void)doOrder{
	
	//
	//新規商談作成
	//
	[self alertShow];

	NSString *path = @"/services/data/v26.0/sobjects/Opportunity/";
	
	//開始・終了時間
	NSDate *stJPN= [NSDate dateWithTimeIntervalSinceNow:0];
	NSDate *edJPN= [NSDate dateWithTimeIntervalSinceNow:+(60*60)];
	
	//登録用フォーマット
	NSDateFormatter *fmt1 = [[NSDateFormatter alloc] init];
	[fmt1 setDateFormat:@"yyyy-MM-dd'T'HH:mm:00Z"];
	
	//オブジェクト名に使用する為のフォーマット
	NSDateFormatter *fmt2 = [[NSDateFormatter alloc] init];
	[fmt2 setDateFormat:@"yyyy-MM-dd_HH:mm:ss"];
	
	//日付を文字列化
	NSString *endForRegist = [fmt1 stringFromDate:edJPN];
	NSString *sttForObjName = [fmt2 stringFromDate:stJPN];
	
	//投稿用parameter
	NSString *title = [NSString stringWithFormat:@"%@_%@",
                     [pData getDataForKey:@"DEFINE_STORORDER_OPPORTUNITY"],
                     sttForObjName];
	NSDictionary *param;
	
	param = [NSDictionary dictionaryWithObjectsAndKeys:	title,@"Name",
           cp.company_id,@"AccountId",
           @"Closed Won",@"StageName",
           endForRegist,@"CloseDate",
           nil];
	
	SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodPOST path:path queryParams:param];
	
	[[SFRestAPI sharedInstance] sendRESTRequest:req
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      
                                      //エラーアラート
                                      alertView = [[UIAlertView alloc]
                                                   initWithTitle:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_SIGN_ERROR"]
                                                   message:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_SIGN_MESSAGE_ERROR"]
                                                   delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_SIGN_OK_ERROR"], nil ];
                                      
                                      [alertView show];
                                    }
                                completeBlock:^(id jsonResponse){
                                  
                                  //
                                  //サイン登録
                                  //
                                  
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  //NSLog(@"%@",dict);
                                  
                                  NSString *opId = [dict objectForKey:@"id"];
                                  NSNumber *success = [dict objectForKey:@"success"];
                                  NSArray *err = [dict objectForKey:@"errors"];
                                  if ([err count] == 0 ){
                                    if ( [success intValue] == 1 ){
                                      NSString *path2 = @"/services/data/v26.0/sobjects/Attachment/";
                                      NSString *title2 = [NSString stringWithFormat:@"%@_%@.PNG",
                                                          [pData getDataForKey:@"DEFINE_STORORDER_SIGN"],
                                                          sttForObjName];
                                      
                                      //サインを画像化し、NSData => Base64 Encodeする
                                      UIGraphicsBeginImageContext(self.sign.frame.size);
                                      [self.sign.layer renderInContext:UIGraphicsGetCurrentContext()];
                                      UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                                      NSData *sendData = UIImagePNGRepresentation(image);
                                      NSString *encodedString = [self base64forData:sendData];
                                      NSDictionary *param2;
                                      param2 = [NSDictionary dictionaryWithObjectsAndKeys:	title2,@"Name",
                                                encodedString,@"Body",
                                                opId,@"ParentId",
                                                nil];
                                      
                                      SFRestRequest *req2 =[SFRestRequest requestWithMethod:SFRestMethodPOST path:path2 queryParams:param2];
                                      
                                      [[SFRestAPI sharedInstance] sendRESTRequest:req2
                                                                        failBlock:^(NSError *e) {
                                                                          NSLog(@"FAILWHALE with error: %@", [e description] );
                                                                        }
                                                                    completeBlock:^(id jsonResponse){
                                                                      //NSDictionary *dict = (NSDictionary *)jsonResponse;
                                                                      //NSLog(@"%@",dict);
                                                                    }
                                       ];
                                      
                                      //発注内容を商談に登録
                                      [self setOpportunityItem:opId];
                                    }
                                  }
                                }
	 ];
}

-(NSString*)base64forData:(NSData*)theData {
	const uint8_t* input = (const uint8_t*)[theData bytes];
	NSInteger length = [theData length];
	
	static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
	
	NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
	uint8_t* output = (uint8_t*)data.mutableBytes;
	
	NSInteger i;
	for (i=0; i < length; i += 3) {
		NSInteger value = 0;
		NSInteger j;
		for (j = i; j < (i + 3); j++) {
			value <<= 8;
			
			if (j < length) {
				value |= (0xFF & input[j]);
			}
		}
		
		NSInteger theIndex = (i / 3) * 4;
		output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
		output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
		output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
		output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
	}
	
	return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

-(void)setOpportunityItem:(NSString*)opId
{
	//オーダー内容取得
	
	//キー（商品ID)を取得
	NSArray *keys = [orderArray allKeys];
	orderNum = [orderArray count];

	for ( NSString *pId in keys ) {
		
		//製品単位でオーダー取得
		OrderInfo *od = [orderArray objectForKey:pId];
		
		if ( od.quanty == 0 ){
			continue;
		}
		
		NSString *path = @"/services/data/v26.0/sobjects/OpportunityLineItem/";
		
		//投稿用parameter
		NSDictionary *param;
		
		param = [NSDictionary dictionaryWithObjectsAndKeys:	opId,@"OpportunityId",
             od.priceBookEntryId,@"PriceBookEntryId",
             [NSString stringWithFormat:@"%d",od.quanty],@"Quantity",
             [NSString stringWithFormat:@"%d",od.price],@"UnitPrice",
             nil];
		
		SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodPOST path:path queryParams:param];
		
		[[SFRestAPI sharedInstance] sendRESTRequest:req
                                      failBlock:^(NSError *e) {
                                        NSLog(@"FAILWHALE with error: %@", [e description] );
                                        
                                        // アラートを閉じる
                                        if(alertView.visible) {
                                          [alertView dismissWithClickedButtonIndex:0 animated:NO];
                                        }
                                        
                                        //エラーアラート
                                        alertView = [[UIAlertView alloc]
                                                     initWithTitle:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ORDER_ERROR"]
                                                     message:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ORDER_MESSAGE_ERROR"]
                                                     delegate:nil
                                                     cancelButtonTitle:nil
                                                     otherButtonTitles:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ORDER_OK_ERROR"], nil ];
                                        [alertView show];
                                      }
                                  completeBlock:^(id jsonResponse){
                                    //NSDictionary *dict = (NSDictionary *)jsonResponse;
                                    //NSLog(@"%@",dict);
                                    
                                    // 在庫数の更新
                                    [self minusOpportunityItem:pId orderInfo:od OpportunityId:opId];
                                    
                                  }
		 ];
	}
	
	//売上分を在庫数から減算する為の配列(For Demonstration)
	NSNumber *subVal;
	OrderInfo *od;
	if ( [orderArray count] ){
		NSArray *keys = [orderArray allKeys];
		for ( NSString *key in keys ){
			od = [orderArray objectForKey:key];
			if ( ![um chkString:[saledArray objectForKey:key]] ) {
				subVal = [[NSNumber alloc]initWithInt:od.quanty];
			}
			else {
				subVal = [saledArray objectForKey:key];
				int val = [subVal intValue] + od.quanty;
				subVal = [NSNumber numberWithInt:val];
			}
			[saledArray setObject:subVal forKey:key];
		}
	}
	
	
	//オーダーリストクリア
	orderArray = [NSMutableDictionary dictionary];
	
	//ポップオーバーを消す
	[pop dismissPopoverAnimated:YES];
	
  
	//発注数表示を0に戻す
	for ( int i = 0; i < [productList count]; i++){
		UIButton *btn = (UIButton*)[self searchBtn:i];
    //		[btn setTitle:[NSString stringWithFormat:@"%d箱",0] forState:UIControlStateNormal];
		[btn setTitle:[NSString stringWithFormat:[pData getDataForKey:@"DEFINE_STORORDER_POP_UNIT_TITLE"],0] forState:UIControlStateNormal];
	}
	
	//オーダー画面を閉じる
	[self orderClosePushed];
	/*
	cmpltAlert = [[UIAlertView alloc]
                initWithTitle:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_COMPLETE"]
                message:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_COMPLETE_MESSAGE"]
                delegate:self
                cancelButtonTitle:nil
                otherButtonTitles:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_COMPLETE_OK"], nil ];
	[cmpltAlert show];
	*/
}

// 在庫マスターの在庫を引き当て
-(void)minusOpportunityItem:(NSString*)pId orderInfo:(OrderInfo*)od OpportunityId:(NSString*)opId
{
  orderCompNum = 0;
  
  // 商品情報を取得
  Product *pd;
  for ( int i = 0; i < [productList count]; i++ ){
    Product *tempPd = [productList objectAtIndex:i];
    if ( [tempPd.productId isEqualToString:pId]){
      pd = tempPd;
      break;
    }
  }
  
	NSString *path = @"/services/data/v26.0/sobjects/stock__c/";
	
	//時間
	NSDate *stJPN= [NSDate dateWithTimeIntervalSinceNow:0];
	
	//登録用フォーマット
	NSDateFormatter *fmt1 = [[NSDateFormatter alloc] init];
	[fmt1 setDateFormat:@"yyyy-MM-dd"];
	
	
	//日付を文字列化
	NSString *sttForObjName = [fmt1 stringFromDate:stJPN];
	
  // 認証したユーザー情報にアクセス
  SFAccountManager *sm = [SFAccountManager sharedInstance];
  
	//投稿用parameter
	NSDictionary *param;
	
	param = [NSDictionary dictionaryWithObjectsAndKeys:sm.idData.userId, @"OwnerId",
           //sm.idData.userId, @"CreatedById",
           //sm.idData.userId, @"LastModifiedById",
           pd.productId,@"product__c",
           @"出庫",@"TransactionType__c",
           opId,@"Opportunity__c",
           sttForObjName,@"date__c",
           [[NSNumber alloc] initWithInteger:od.quanty], @"quantity__c",
           nil];
	
	SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodPOST path:path queryParams:param];
	
	[[SFRestAPI sharedInstance] sendRESTRequest:req
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      
                                      // アラートを閉じる
                                      if(alertView.visible) {
                                        [alertView dismissWithClickedButtonIndex:0 animated:NO];
                                      }
                                      
                                      //エラーアラート
                                      UIAlertView *ealertView = [[UIAlertView alloc]
                                                   initWithTitle:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_NUM_ERROR"]
                                                   message:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_NUM_MESSAGE_ERROR"]
                                                   delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_NUM_OK_ERROR"], nil ];
                                      
                                      [ealertView show];
                                      orderCompNum++;
                                    }
                                completeBlock:^(id jsonResponse){
                                  
                                  //
                                  //ok
                                  //
                                  
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  NSLog(@"%@",dict);
                                  
                                  orderCompNum++;
                                  if(orderNum == orderCompNum){
                                    // アラートを閉じる
                                    if(alertView.visible) {
                                      [alertView dismissWithClickedButtonIndex:0 animated:NO];
                                    }
                                    cmpltAlert = [[UIAlertView alloc]
                                                  initWithTitle:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_COMPLETE"]
                                                  message:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_COMPLETE_MESSAGE"]
                                                  delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_COMPLETE_OK"], nil ];
                                    [cmpltAlert show];
                                  }
                                }
	 ];

}

/*
// 在庫マスターの在庫を引き当て
-(void)minusOpportunityItem:(NSString*)pId orderInfo:(OrderInfo*)od
{
  // 商品情報を取得
  Product *pd;
  for ( int i = 0; i < [productList count]; i++ ){
    Product *tempPd = [productList objectAtIndex:i];
    if ( [tempPd.productId isEqualToString:pId]){
      pd = tempPd;
      break;
    }
  }
  
  // 最新の在庫数
  int _badgeVal = [pd.badgeValue intValue];
  
  // 注文した数を引く
  int newq = _badgeVal-od.quanty;
  
  NSString *qVal = [NSString stringWithFormat:@"%d", newq];
  
  // 該当商品のstock__cレコード更新
  //投稿用parameter
  NSDictionary *messageSegments = [[NSDictionary alloc]initWithObjectsAndKeys:qVal, @"quantity__c",nil];
  
  //リクエスト作成
  NSString *url = [NSString stringWithFormat:@"/services/data/v26.0/sobjects/stock__c/%@", pd.stock__c_id];
  SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodPATCH path:url queryParams:messageSegments];
  
  //POST実行
  [[SFRestAPI sharedInstance] sendRESTRequest:req
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                    }
                                completeBlock:^(id jsonResponse){
                                  //NSDictionary  *dic = (NSDictionary *)jsonResponse;
                                  //NSLog(@"%d : dic::%@",__LINE__,dic);
                                }
   ];
  
}
 */

//オーダー完了アラートのボタン押下
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	//グラフを再表示
	[self dispGraphs:currentPrd];
  [carousel reloadData];
  
  // current index以外のバッヂを更新
  if(orderNum >1)[self getProductListBadge:selectedFamily];
}


//商品カテゴリが(family)の商品のバッヂ数更新
-(void)getProductListBadge:(NSString*)family
{
	NSString *query = [NSString stringWithFormat:@"SELECT Id,ProductCode,Name,Family,Description,URL__c ,order__c, StockCount__c FROM product2 WHERE IsActive=true AND Family = '%@'  ORDER BY order__c",family];
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
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  //NSLog(@"%d : dic : %@",__LINE__,dict);
                                  
                                  // 本日日付
                                  NSDateFormatter* fmt= [[NSDateFormatter alloc] init];
                                  [fmt setDateFormat:@"YYYY-MM-dd"];
                                  [fmt setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
                                  NSString *dateStr = [fmt stringFromDate:[NSDate date]];
                                  NSDate *tmpDate = [fmt dateFromString:dateStr];
                                  
                                  NSLog(@"%d dateStr %@", __LINE__, dateStr);
                                  NSLog(@"%d tmpDate %@", __LINE__, tmpDate);
                                  
                                  NSArray *records= [dict objectForKey:@"records"];
                                  for ( int i = 0; i < [records count]; i++ ){
                                    NSDictionary *rec = [records objectAtIndex:i];
                                    
                                    NSString *pId = [um chkNullString:[rec objectForKey:@"Id"]];
                                    NSNumber *pStockCount = [rec objectForKey:@"StockCount__c"];
                                    
                                    // 商品情報を取得
                                    Product *pd;
                                    for ( int i = 0; i < [productList count]; i++ ){
                                      Product *tempPd = [productList objectAtIndex:i];
                                      if ( [tempPd.productId isEqualToString:pId]){
                                        pd = tempPd;
                                        break;
                                      }
                                    }
                                    
                                    @try {
                                      pd.StockCount__c = [pStockCount intValue];
                                      pd.badgeValue = [NSString stringWithFormat:@"%@", pStockCount];
                                    }
                                    @catch (NSException *exception) {
                                      pd.StockCount__c = 0;
                                      pd.badgeValue = @"0";
                                    }
                                    
                                    /*
                                    // バッヂ数を変更
                                    for ( int i = 0; i < [productList count]; i++ ){
                                      for(UIView *view in [[carousel itemViewAtIndex:i] subviews]){
                                        if ([view isKindOfClass:[ItemBadge class]]) {
                                          ItemBadge *iv = (ItemBadge*)view;
                                          iv.textLabel.text = [NSString stringWithFormat:@"%@", pd.badgeValue];
                                          NSLog(@"%d pd.badgeValue %@", __LINE__, pd.badgeValue);
                                        }
                                      }
                                    }
                                     */
                                  }
                                  
                                }
	 ];
}

@end
