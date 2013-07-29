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

#import "OrderViewController+HistoryScreen.h"
#import "OrderDefine.h"

@implementation OrderViewController (HistoryScreen)
-(void)buildHistoryScreen
{
	
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
	
	self.historyWindow = [[UIView alloc]initWithFrame:CGRectMake(115,80,TOTAL2_WIDTH + 50, 470)];
	historyScrl = [[UIScrollView alloc]initWithFrame:CGRectMake(25,ROW_HEIGHT*3,TOTAL2_WIDTH, 12*ROW_HEIGHT)];
	self.historyWindow.backgroundColor = [UIColor whiteColor];
	[self.historyWindow.layer setBorderWidth:1.0f];
	[self.historyWindow.layer setShadowColor:[[UIColor blackColor]CGColor]];
	[self.historyWindow.layer setShadowOpacity:0.5f];
	
	//ナビゲーションバー　設定
	UIView *historyTitleBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, TOTAL2_WIDTH+50, 40)];
	um = [UtilManager sharedInstance];
	NSData *iData =[um navBarType];
	if ( [((NSString*)iData) isEqualToString:@"gray"] ) {
		[historyTitleBar setBackgroundColor:[UIColor grayColor]];
	}
	else if ( [((NSString*)iData) isEqualToString:@"black"] ) {
		[historyTitleBar setBackgroundColor:[UIColor blackColor]];
	}
	else {
		iData =[um navBarImage];
		if ( iData ) {
			UIImage *img = [UIImage imageWithData:iData];
			[historyTitleBar setBackgroundColor:[UIColor colorWithPatternImage:img]];
		}
	}
	
	UILabel *titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(10,8,100,40)];
	[titleLbl setText:[pData getDataForKey:@"DEFINE_STORORDER_LABEL_ORDERHIST"]];
	titleLbl.backgroundColor = [UIColor clearColor];
	titleLbl.textColor = [UIColor whiteColor];
	titleLbl.font = [UIFont boldSystemFontOfSize:18.0f];
	[titleLbl sizeToFit];
	
	[historyTitleBar addSubview:titleLbl];
	[self.historyWindow addSubview:historyTitleBar];
	
	//ヘッダー追加
	[self.historyWindow addSubview:[self makeHistoryHead]];
	
	//オーダー履歴取得
	rcvCount = 0;
	[self getOrderhistory];
	
	
	[self.historyWindow addSubview:historyScrl];
	
	//終了ボタン
	UIButton *historyCloseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	CGRect r;
	r = historyCloseBtn.frame;
	r.origin.x = TOTAL_WIDTH - 30;
	r.origin.y = 8;
	r.size.width = 80;
	r.size.height = 30;
	[historyCloseBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
	[historyCloseBtn setFrame:r];
	[historyCloseBtn setTitle:[pData getDataForKey:@"DEFINE_STORORDER_LABEL_CLOSE"] forState:UIControlStateNormal];
	[historyCloseBtn addTarget:self action:@selector(historyClosePushed) forControlEvents:UIControlEventTouchUpInside];
	[historyTitleBar addSubview:historyCloseBtn];
	
  [self.view addSubview:clearView];
  
	//表示
	[self.view addSubview:self.historyWindow];
}

-(id)makeHistoryHead
{
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
	
	
	CGRect r;
	UIView *baseView = [[UIView alloc]initWithFrame:CGRectMake(25,ROW_HEIGHT*2,TOTAL_WIDTH,ROW_HEIGHT)];
	baseView.backgroundColor = [UIColor colorWithRed:0.60 green:0.60 blue:0.60 alpha:1.0];
	
	UIView *nameView = [[UIView alloc]initWithFrame:CGRectMake(1,1,NAME2_WIDTH - 2 ,ROW_HEIGHT - 2 )];
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
	
	UIView *dateView = [[UIView alloc]initWithFrame:CGRectMake(NAME2_WIDTH,1, DATE_WIDTH - 1,ROW_HEIGHT - 2 )];
	dateView.backgroundColor = [UIColor darkGrayColor];
	r = dateView.frame;
	r.origin.x = 0;
	r.origin.y = 0;
	UILabel *dateLbl = [[UILabel alloc]initWithFrame:r];
	dateLbl.textAlignment = NSTextAlignmentCenter;
	dateLbl.text = [pData getDataForKey:@"DEFINE_STORORDER_LABEL_DONEDAY"];
	dateLbl.textColor = [UIColor whiteColor];
	dateLbl.backgroundColor = backColor;
	[dateView addSubview:dateLbl];
	
	UIView *quantityView = [[UIView alloc]initWithFrame:CGRectMake((NAME2_WIDTH+DATE_WIDTH),1,QUANTITY_WIDTH - 1,ROW_HEIGHT - 2 )];
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
	
	UIView *statusView = [[UIView alloc]initWithFrame:CGRectMake(( NAME2_WIDTH + DATE_WIDTH + QUANTITY_WIDTH ),1 , STATUS_WIDTH - 1,ROW_HEIGHT - 2 )];
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
	[baseView addSubview:dateView];
	[baseView addSubview:quantityView];
	[baseView addSubview:statusView];
	
	return baseView;
}


-(id)makeHistoryRow:(OrderInfo*)info row:(int)row
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
	UIView *baseView = [[UIView alloc]initWithFrame:CGRectMake(0,row,TOTAL2_WIDTH,ROW_HEIGHT)];
	baseView.backgroundColor = [UIColor colorWithRed:0.60 green:0.60 blue:0.60 alpha:1.0];
	
	UIView *nameView = [[UIView alloc]initWithFrame:CGRectMake(1,0,NAME2_WIDTH - 2 ,ROW_HEIGHT - 1 )];
	nameView.backgroundColor = [UIColor lightGrayColor];
	r = nameView.frame;
	r.origin.x = 0;
	r.origin.y = 1;
	r.size.height--;
	UILabel *nameLbl = [[UILabel alloc]initWithFrame:r];
	nameLbl.textAlignment = NSTextAlignmentCenter;
	nameLbl.text = [NSString stringWithFormat:@" %@",info.product_name];
	nameLbl.backgroundColor = col;
	
	//nameLbl.UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right);
	[nameLbl setTextAlignment:NSTextAlignmentLeft];
	[nameView addSubview:nameLbl];
	
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	df.dateFormat  = [pData getDataForKey:@"DEFINE_STORORDER_LABEL_DAYFORMAT"];
	
	UIView *dateView = [[UIView alloc]initWithFrame:CGRectMake(NAME2_WIDTH,0, DATE_WIDTH - 1,ROW_HEIGHT - 1 )];
	dateView.backgroundColor = [UIColor lightGrayColor];
	r = dateView.frame;
	r.origin.x = 0;
	r.origin.y = 1;
	r.size.height--;
	UILabel *dateLbl = [[UILabel alloc]initWithFrame:r];
	dateLbl.textAlignment = NSTextAlignmentCenter;
	dateLbl.text = [df stringFromDate:info.date];
	dateLbl.backgroundColor = col;
	[dateLbl setTextAlignment:NSTextAlignmentCenter];
	[dateView addSubview:dateLbl];
	
	UIView *quantityView = [[UIView alloc]initWithFrame:CGRectMake((NAME2_WIDTH+DATE_WIDTH),0,QUANTITY_WIDTH - 1,ROW_HEIGHT - 1 )];
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
	
	UIView *statusView = [[UIView alloc]initWithFrame:CGRectMake(( NAME2_WIDTH+DATE_WIDTH+QUANTITY_WIDTH),0 , STATUS_WIDTH - 1,ROW_HEIGHT - 1 )];
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
	[baseView addSubview:dateView];
	[baseView addSubview:quantityView];
	[baseView addSubview:statusView];
	
	return baseView;
}

-(void)getOrderhistory
{
	[self alertShow];
	historyArray = [NSMutableArray array];
	
	[NSTimer scheduledTimerWithTimeInterval:30.0f
                                   target:self
                                 selector:@selector(timeUp)
                                 userInfo:nil
                                  repeats:NO ];
	
	NSString *query = [NSString stringWithFormat:@"SELECT Quantity,CreatedDate,PricebookEntryId,status__c , Opportunity.CloseDate,Opportunity.accountId FROM OpportunityLineItem WHERE Opportunity.AccountId ='%@' AND Opportunity.CreatedDate > N_DAYS_AGO:90 ORDER BY Opportunity.CloseDate DESC",cp.company_id];
	
	
	SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:query];
	[[SFRestAPI sharedInstance] sendRESTRequest:request
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      if(alertView.visible){
                                        [alertView dismissWithClickedButtonIndex:0 animated:NO];
                                      }
                                      
                                      //エラーアラート
                                      alertView = [[UIAlertView alloc]
                                                   initWithTitle:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMHIST_ERROR"]
                                                   message:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMHIST_MESSAGE_ERROR"]
                                                   delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMHIST_OK_ERROR"], nil ];
                                      [alertView show];
                                      return;
                                    }
                                completeBlock:^(id jsonResponse){
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  NSLog(@"%@",dict);
                                  NSArray *records = [dict objectForKey:@"records"];
                                  NSDateFormatter* fmt= [[NSDateFormatter alloc] init];
                                  [fmt setDateFormat:@"yyyy-MM-dd"];
                                  
                                  for ( int i = 0; i < [records count]; i++ ) {
                                    NSDictionary *rec = [records objectAtIndex:i];
                                    
                                    NSArray  *dateArry = [rec objectForKey:@"Opportunity"];
                                    
                                    NSString *dateStr  = [dateArry valueForKey:@"CloseDate"];
                                    NSNumber *qty = [rec objectForKey:@"Quantity"];
                                    NSString *priceBookId = [rec objectForKey:@"PricebookEntryId"];
                                    NSString *status = [rec objectForKey:@"status__c"];
                                    
                                    OrderInfo *oi = [[OrderInfo alloc]init];
                                    oi.date= [fmt dateFromString:dateStr];
                                    oi.quanty = [qty intValue];
                                    oi.priceBookEntryId = priceBookId;
                                    if (![um chkString:status]){
                                      oi.status = [pData getDataForKey:@"DEFINE_STORORDER_LABEL_CONFIRM"];
                                    }
                                    else {
                                      oi.status = status;
                                    }
                                    [historyArray addObject:oi];
                                  }
                                  [self getHistoryName];
                                  
                                }];
	
}


-(void)getHistoryName
{
	//	rcvCount = 0;
	//	OrderInfo *oi = [[OrderInfo alloc]init];
	//	for ( int i = 0; i < [historyArray count]; i++ ){
	//		oi = [historyArray objectAtIndex:i];
	//		[self getProductNameFromPriceBookId:oi];
	//	}
	[self getProductNameFromPriceBookId:historyArray];
	
	if(alertView.visible){
		[alertView dismissWithClickedButtonIndex:0 animated:NO];
	}
	//    #pragma unused(oi)
}

-(void)getProductNameFromPriceBookId:(NSMutableArray*)odArray
{
	inWait = YES;
	[NSTimer scheduledTimerWithTimeInterval:30.0f
                                   target:self
                                 selector:@selector(timeUp)
                                 userInfo:nil
                                  repeats:NO ];
	NSString *where = @"";
	int loopMax = [odArray count];
	int loopCnt = 0;
	for ( OrderInfo *tempOd in odArray ) {
		where = [where stringByAppendingString:[NSString stringWithFormat:@"Id='%@'",tempOd.priceBookEntryId ]];
		if ( loopCnt++ != loopMax - 1 ){
			where = [where stringByAppendingString:@" OR "];
		}
	}
	
	NSString *query = [NSString stringWithFormat:@"SELECT Id, Name FROM PricebookEntry WHERE %@",where];
	SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:query];
	[[SFRestAPI sharedInstance] sendRESTRequest:request
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      if(alertView.visible) {
                                        [alertView dismissWithClickedButtonIndex:0 animated:NO];
                                      }
                                      //エラーアラート
                                      alertView = [[UIAlertView alloc]
                                                   initWithTitle:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMHIST_ERROR"]
                                                   message:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMHIST_MESSAGE_ERROR"]
                                                   delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:[pData getDataForKey:@"DEFINE_STORORDER_TITLE_ITEMHIST_OK_ERROR"], nil ];
                                      [alertView show];
                                      return ;
                                    }
                                completeBlock:^(id jsonResponse){
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  NSLog(@"%@",dict);
                                  NSNumber *recCount = [dict objectForKey:@"totalSize"];
                                  if ( [recCount intValue]){
                                    NSArray *records = [dict objectForKey:@"records"];
                                    for ( int i = 0; i < [records count]; i++  ) {
                                      NSDictionary *rec = [records objectAtIndex:i];
                                      NSString *pbId = [rec objectForKey:@"Id"];
                                      
                                      OrderInfo *oi = [[OrderInfo alloc]init];
                                      for ( oi in odArray ){
                                        if ( [oi.priceBookEntryId isEqualToString:pbId]) {
                                          NSString *name = [rec objectForKey:@"Name"];
                                          oi.product_name = name;
                                        }
                                      }
                                    }
                                  }
                                  //全件取得したら表示
                                  OrderInfo *tempod;
                                  for ( int i = 0; i < [historyArray count]; i++ ){
                                    tempod = [historyArray objectAtIndex:i];
                                    [historyScrl addSubview:[self makeHistoryRow:tempod row:i]];
                                  }
                                  historyScrl.contentSize = CGSizeMake(TOTAL2_WIDTH, [historyArray count] * ROW_HEIGHT);
                                }
	 ];
}

-(void)timeUp
{
	inWait = NO;
}
-(void)historyClosePushed
{
	[self.historyWindow removeFromSuperview];
	self.historyWindow = nil;
	
	dispChildScreen = NO;
  
  [clearView removeFromSuperview];
  metricsBtn.enabled = YES;
	mapBtn.enabled = YES;
	ordersBtn.enabled = YES;
	chatterBtn.enabled = YES;
  self.navigationItem.leftBarButtonItem.enabled = YES;
}


@end
