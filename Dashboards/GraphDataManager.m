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


#import "GraphDataManager.h"
#import "GraphData.h"
#import "CircleGraph.h"
#import "BarGraph.h"
#import "LineGrapth.h"

@implementation GraphDataManager

static GraphDataManager *_instance = nil;

-(id)init {
  
	if (self = [super init]) {
  }
  
  return self;
}

+(GraphDataManager*)sharedInstance {
	
	if (_instance == nil) {
		_instance = [[GraphDataManager alloc] init];
	}
	return _instance;
}

// グラフ用の辞書を返却
-(NSMutableDictionary*)getDictionaryForTag:(NSString*)tag
{
  PublicDatas *pData = [PublicDatas instance];
  um = [UtilManager sharedInstance];
  
  NSString *company_id = [pData getDataForKey:@"company_id"];
  
  // ストアページではアカウントIDが大本のキー
  if([um chkString:company_id] && ![company_id isEqualToString:@""])
  {
    NSMutableDictionary *baseDic = [pData getDataForKey:company_id];
    if(!baseDic){
      baseDic = [[NSMutableDictionary alloc] init];
      [baseDic setObject:company_id forKey:@"company_id"];
    }
    NSString *keyStr = [NSString stringWithFormat:@"dic%@", tag];
    NSMutableDictionary *dic = [baseDic objectForKey:keyStr];
    //NSLog(@"get basedic %@ %@", baseDic, tag);
    //NSLog(@"get dic %@ %@", dic, tag);
    return dic;
  }
  // ストアでない場合は自分のページ そのままtagがキー
  else{
    NSString *keyStr = [NSString stringWithFormat:@"dic%@", tag];
    NSMutableDictionary *dic = [pData getDataForKey:keyStr];
    return dic;
  }
}

-(void)saveDictionaryFroTag:(NSString *)tag Dictionary:(NSMutableDictionary *)dic
{
  PublicDatas *pData = [PublicDatas instance];
  um = [UtilManager sharedInstance];
  
  NSString *company_id = [pData getDataForKey:@"company_id"];
  
  // ストアページではアカウントIDが大本のキー
  if([um chkString:company_id] && ![company_id isEqualToString:@""])
  {
    NSMutableDictionary *baseDic = [pData getDataForKey:company_id];
    if(!baseDic){
      baseDic = [[NSMutableDictionary alloc] init];
      [baseDic setObject:company_id forKey:@"company_id"];
    }
    NSString *keyStr = [NSString stringWithFormat:@"dic%@", tag];
    //NSLog(@"save dic %@ %@", dic, tag);
    //NSLog(@"save basedic %@ %@", baseDic, tag);
    [baseDic setObject:dic forKey:keyStr];
    [pData setData:baseDic forKey:company_id];
    
    // ファイルに保存
    [self saveGraphSettingCompanyToFile];
  }
  // ストアでない場合は自分のページ そのままtagがキー
  else{
    NSString *keyStr = [NSString stringWithFormat:@"dic%@", tag];
    [pData setData:dic forKey:keyStr];
    
    // ファイルに保存
    [self saveGraphSettingToFile];
  }
}

// グラフ設定をファイルに保存
-(void)saveGraphSettingToFile
{
  PublicDatas *pData = [PublicDatas instance];
  
  // 認証したユーザー情報にアクセス
  SFAccountManager *sm = [SFAccountManager sharedInstance];
  // ユーザーIDをファイル名とする
  NSString *saveFileName = [NSString stringWithFormat:@"%@.dat", sm.idData.userId];
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory //NSDocumentDirectory
                                                       , NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *fileName = [documentsDirectory stringByAppendingPathComponent:saveFileName];
  
  // pData内のグラフに関するデータを取り出す
  NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
  NSArray *keys = @[@"dic1", @"dic2", @"dic3"];
  for(int i=0; i<[keys count]; i++)
  {
    if([pData getDataForKey:[keys objectAtIndex:i]])
    {
      [dic setObject:[pData getDataForKey:[keys objectAtIndex:i]] forKey:[keys objectAtIndex:i]];
    }
  }
  // ファイルに保存
  [dic writeToFile:fileName atomically:YES];
}

// グラフ設定をファイルに保存 企業用
-(void)saveGraphSettingCompanyToFile
{
  PublicDatas *pData = [PublicDatas instance];
  NSString *company_id = [pData getDataForKey:@"company_id"];

  // 認証したユーザー情報にアクセス
  SFAccountManager *sm = [SFAccountManager sharedInstance];
  // ユーザーIDをファイル名とする
  NSString *saveFileName = [NSString stringWithFormat:@"%@_company.dat", sm.idData.userId];
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory //NSDocumentDirectory
                                                       , NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *fileName = [documentsDirectory stringByAppendingPathComponent:saveFileName];
  
  // ストアページではアカウントIDが大本のキー
  if([um chkString:company_id] && ![company_id isEqualToString:@""])
  {
    NSMutableDictionary *baseDic = [pData getDataForKey:company_id];
    if(!baseDic){
      baseDic = [[NSMutableDictionary alloc] init];
      [baseDic setObject:company_id forKey:@"company_id"];
    }
    // ファイルに保存
    [baseDic writeToFile:fileName atomically:YES];
  }
}

// ファイルに保存したデータの読み出し
-(void)loadGraphSetting
{
  PublicDatas *pData = [PublicDatas instance];
  um = [UtilManager sharedInstance];
  
  // 認証したユーザー情報にアクセス
  SFAccountManager *sm = [SFAccountManager sharedInstance];
  // ユーザーIDをファイル名とする
  NSString *saveFileName = [NSString stringWithFormat:@"%@.dat", sm.idData.userId];
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory //NSDocumentDirectory
                                                       , NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *fileName = [documentsDirectory stringByAppendingPathComponent:saveFileName];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  BOOL success = [fileManager fileExistsAtPath:fileName];
  if(success) {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:fileName];
    NSArray *keys = @[@"dic1", @"dic2", @"dic3"];
    for(int i=0; i<[keys count]; i++)
    {
      [pData setData:[dictionary objectForKey:[keys objectAtIndex:i]] forKey:[keys objectAtIndex:i]];
    }
  }
  
  // 企業用データ
  NSString *company_id = [pData getDataForKey:@"company_id"];
  
  saveFileName = [NSString stringWithFormat:@"%@_company.dat", sm.idData.userId];
  fileName = [documentsDirectory stringByAppendingPathComponent:saveFileName];
  success = [fileManager fileExistsAtPath:fileName];
  if(success && [um chkString:company_id] && ![company_id isEqualToString:@""]) {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:fileName];
    [pData setData:dictionary forKey:company_id];
  }
}

// 初回データ返却
-(NSMutableDictionary*)getPlainGraphData:(NSString*)tag
{
  PublicDatas *pData = [PublicDatas instance];

  int _tag = [tag intValue];
  NSLog(@"_tag %d", _tag);
  int _graphIndex = _tag-1;
  NSMutableDictionary *tmp = [[NSMutableDictionary alloc]init];
  [tmp setObject:[NSString stringWithFormat:@"%d", _graphIndex] forKey:@"graphIndex"];
  
  switch (_tag) {
    case 1:
    {
      NSString *family = [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_FAMILY"];
      NSString *startMonth = @"1";
      
      NSDate *date = [NSDate date];
      NSCalendar *calendar = [NSCalendar currentCalendar];
      NSDateComponents *comps;
      
      // 年月日をとりだす
      comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                          fromDate:date];
      NSInteger year = [comps year];
      NSInteger month = [comps month];
      
      NSString *startYear = [NSString stringWithFormat:@"%d", year];
      NSString *endYear = [NSString stringWithFormat:@"%d", year];
      NSString *endMonth = [NSString stringWithFormat:@"%d", month];
      
      [tmp setObject:family forKey:@"family"];
      [tmp setObject:startYear forKey:@"startYear"];
      [tmp setObject:startMonth forKey:@"startMonth"];
      [tmp setObject:endYear forKey:@"endYear"];
      [tmp setObject:endMonth forKey:@"endMonth"];
      break;
      }
    case 2:
    {
      /*
       barMonth 開始付月
       barItem @"売上", @"商談数"
       barTerm @"年間", @"四半期", @"前四半期"
       */
        NSString *barMonth = @"1";
        NSString *barItem = [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_SALE"];
        NSString *barTerm = [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_YEARTERM"];
        
        NSLog(@"barItem :%@", barItem);
        NSLog(@"barTerm :%@", barTerm);
        NSLog(@"barMonth :%@", barMonth);
        
        [tmp setObject:barItem forKey:@"barItem"];
        [tmp setObject:barTerm forKey:@"barTerm"];
        [tmp setObject:barMonth forKey:@"barMonth"];
      break;
    }
    case 3:
    {
      /*
       lineMonth 開始付月
       lineItem @"売上", @"商談数"
       lineTerm @"年間", @"四半期", @"前四半期"
       */
      //NSLog(@"lineMonth :%@", lineMonth);
      NSString *lineMonth = @"1";
      NSString *lineItem = [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_SALE"];
      NSString *lineTerm = [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_YEARTERM"];
      
      [tmp setObject:lineItem forKey:@"lineItem"];
      [tmp setObject:lineTerm forKey:@"lineTerm"];
      [tmp setObject:lineMonth forKey:@"lineMonth"];
      break;
    }
    default:
      break;
  }
  return tmp;
  
}

// ローディングメッセージ
-(void)adddLoadingView:(UIView*)baseView
{
  PublicDatas *pData = [PublicDatas instance];
  
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
  [titleLabel setFrame:CGRectMake((baseView.frame.size.width-titleLabel.frame.size.width)/2, -10,300,40)];
  titleLabel.numberOfLines = 2;
  titleLabel.text = [pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_LOADING"];
  titleLabel.font = [UIFont systemFontOfSize:14.0];
  titleLabel.textAlignment = NSTextAlignmentCenter;
  titleLabel.backgroundColor = [UIColor clearColor];
  [baseView addSubview:titleLabel];
}

// SQLでファミリーを取得
-(void) requestFamilyList
{
  PublicDatas *pData = [PublicDatas instance];
  
  self.familyList = [[NSMutableArray alloc] init];
  
  
  if([[pData getDataForKey:@"familyList"] count]){
    self.familyList = [pData getDataForKey:@"familyList"];
    return;
  }
  
  // すべてのファミリー選択肢
  [self.familyList insertObject:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_FAMILY"] atIndex:0];
  
  //クエリ作成
  NSString *query = @"SELECT Family FROM product2 GROUP BY Family";
  
  NSLog(@"%@",query);
  
  [[SFRestAPI sharedInstance] performSOQLQuery:query
   //エラーハンドラ
                                     failBlock:^(NSError *e) {
                                       NSLog(@"FAILWHALE with error: %@", [e description] );
                                     }
   //受信ハンドラ
                                 completeBlock:^(NSDictionary *results) {
                                   
                                   NSArray *records = [results objectForKey:@"records"];
                                   NSLog(@"request:didLoadResponse: #records: %d", records.count);
                                   
                                   for ( NSDictionary *obj in records ) {
                                     if(![self.familyList containsObject:[obj valueForKey:@"Family"]]){
                                       [self.familyList addObject:[obj valueForKey:@"Family"]];
                                     }
                                   }
                                   [pData setData:self.familyList forKey:@"familyList"];
                                 }];
}

-(NSMutableArray*)getFamilyList
{
  return self.familyList;
}


// ファミリー、期間別に売り上げ金額を取得
-(void)requestDataList:(NSString *)familyStr startDate:(NSString *)startStr endDate:(NSString*)endStr
{
  self.dataList = [[NSMutableArray alloc] init];
  PublicDatas *pData = [PublicDatas instance];
  NSString *company_id = [pData getDataForKey:@"cp_company_id"];
  
  NSLog(@"company_id %@", [pData getDataForKey:@"cp_company_id"]);
  NSLog(@"company_id %@", company_id);
  
  // ファミリー指定の場合
  if(familyStr!=nil && ![familyStr isEqualToString:@""] && ![familyStr isEqualToString:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_FAMILY"]]){
    
    //クエリ作成
    NSString *query1;
    NSString *query2;
    if(company_id!=nil && ![company_id isEqualToString:@""]){
      query1 = @" SELECT PriceBookEntryId  , PriceBookEntry.Product2.Family, PriceBookEntry.Product2.Name , sum(TotalPrice)   ";
      query2 = [NSString stringWithFormat:@" From OpportunityLineItem WHERE Opportunity.Account.Id = '%@' AND PriceBookEntry.Product2.Family = '%@' AND Opportunity.CloseDate >= %@ AND Opportunity.CloseDate <= %@ group by PriceBookEntryId,  PriceBookEntry.Product2.Family, PriceBookEntry.Product2.Name order by sum(TotalPrice) desc", company_id, familyStr, startStr, endStr];
    }else{
      query1 = @" SELECT PriceBookEntryId  , PriceBookEntry.Product2.Family, PriceBookEntry.Product2.Name , sum(TotalPrice)   ";
      query2 = [NSString stringWithFormat:@" From OpportunityLineItem WHERE PriceBookEntry.Product2.Family = '%@' AND CreatedDate >= %@ AND CreatedDate <= %@ group by PriceBookEntryId,  PriceBookEntry.Product2.Family, PriceBookEntry.Product2.Name order by sum(TotalPrice) desc", familyStr, startStr, endStr];
    }
    NSString *query = [query1 stringByAppendingString:query2];
    
    NSLog(@"%@",query);
    
    [[SFRestAPI sharedInstance] performSOQLQuery:query
     //エラーハンドラ
                                       failBlock:^(NSError *e) {
                                         NSLog(@"FAILWHALE with error: %@", [e description] );
                                         inWait = NO;
                                       }
     //受信ハンドラ
                                   completeBlock:^(NSDictionary *results) {
                                     
                                     NSArray *records = [results objectForKey:@"records"];
                                     NSLog(@"request:didLoadResponse: #records: %d", records.count);
                                     
                                     for ( NSDictionary *obj in records ) {
                                       //NSLog(@"obj %@",obj);
                                       //NSLog(@"obj id %@",[obj valueForKey:@"Id"]);
                                       NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
                                       
                                       [tmp setObject:[obj valueForKey:@"Family"] forKey:@"Family"];
                                       //[tmp setObject:[obj valueForKey:@"PriceBookEntryId"] forKey:@"PriceBookEntryId"];
                                       [tmp setObject:[obj valueForKey:@"Name"] forKey:@"Name"];
                                       [tmp setObject:[obj valueForKey:@"expr0"] forKey:@"totalPrice"];
                                       
                                       [self.dataList addObject:tmp];
                                     }
                                     inWait = NO;
                                     
                                   }];
  }else{
    //クエリ作成
    NSString *query1;
    NSString *query2;
    if(company_id!=nil && ![company_id isEqualToString:@""]){
      query1 = @" SELECT PriceBookEntry.Product2.Family ,  sum(TotalPrice)";
      query2 = [NSString stringWithFormat:@" From OpportunityLineItem WHERE  Opportunity.Account.Id = '%@' AND Opportunity.CloseDate >= %@ AND Opportunity.CloseDate <= %@ group by PriceBookEntry.Product2.Family order by sum(TotalPrice) desc ", company_id, startStr, endStr];
    }else{
      query1 = @" SELECT PriceBookEntry.Product2.Family ,  sum(TotalPrice)";
      query2 = [NSString stringWithFormat:@" From OpportunityLineItem WHERE  CreatedDate >= %@ AND CreatedDate <= %@ group by PriceBookEntry.Product2.Family order by sum(TotalPrice) desc ", startStr, endStr];
    }
    NSString *query = [query1 stringByAppendingString:query2];
    NSLog(@"%@",query);
    
    [[SFRestAPI sharedInstance] performSOQLQuery:query
     //エラーハンドラ
                                       failBlock:^(NSError *e) {
                                         NSLog(@"FAILWHALE with error: %@", [e description] );
                                         inWait = NO;
                                       }
     //受信ハンドラ
                                   completeBlock:^(NSDictionary *results) {
                                     
                                     NSArray *records = [results objectForKey:@"records"];
                                     NSLog(@"request:didLoadResponse: #records: %d", records.count);
                                     
                                     for ( NSDictionary *obj in records ) {
                                       //NSLog(@"obj %@",obj);
                                       //NSLog(@"obj id %@",[obj valueForKey:@"Id"]);
                                       NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
                                       
                                       [tmp setObject:[obj valueForKey:@"Family"] forKey:@"Family"];
                                       [tmp setObject:[obj valueForKey:@"Family"] forKey:@"Name"];
                                       [tmp setObject:[obj valueForKey:@"expr0"] forKey:@"totalPrice"];
                                       
                                       [self.dataList addObject:tmp];
                                     }
                                     inWait = NO;
                                     
                                   }];
  }
  
}

-(NSMutableArray*)getDataList
{
  return self.dataList;
}




// 円グラフ描画メソッド
-(void) addCircleGraph:(NSMutableArray*)data UIView:(UIView*)baseView tag:(NSString*)tag
{
  PublicDatas *pData = [PublicDatas instance];
  
  // 既存グラフを消す
  for (UIView *view in [baseView subviews]) {
    //if(![view isMemberOfClass:[UIView class]]) continue;
    [view removeFromSuperview];
  }
  
  NSMutableArray *total = data;
  
  // データなし
  if(!total.count){
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    [titleLabel setFrame:CGRectMake((baseView.frame.size.width-titleLabel.frame.size.width)/2, 10,300,40)];
    titleLabel.numberOfLines = 2;
    titleLabel.text = [pData getDataForKey:@"DEFINE_DASHBOARD_MESSAGE_NODATA"];
    titleLabel.font = [UIFont systemFontOfSize:14.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [baseView addSubview:titleLabel];
    return;
  }
  
  //円グラフ配置
	CircleGraph *circle = [[CircleGraph alloc]initWithFrame:CGRectMake(0,0,300,300)];
	[circle drawRect:circle.frame];
  //circle.center = CGPointMake((graphView.bounds.size.width-circle.bounds.size.width)/2, (graphView.bounds.size.height-circle.bounds.size.height)/2);
  [circle setFrame:CGRectMake((baseView.frame.size.width-circle.frame.size.width)/2, (baseView.frame.size.height-circle.frame.size.height)/2+25,300,300)];
	[baseView addSubview:circle];
  
  // グラフ用データ
  NSMutableArray *graphList = [[NSMutableArray alloc] init];
  for(NSDictionary *dic in total){
    GraphData *dat1 = [[GraphData alloc]init];
    dat1.name = [dic objectForKey:@"Name"];
    dat1.value = [[dic objectForKey:@"totalPrice"] floatValue];
    [graphList addObject:dat1];
  }
	
  // ソート
  NSSortDescriptor *sortPrice = [[NSSortDescriptor alloc] initWithKey:@"value" ascending:YES];
  NSArray *sortDescArray = [NSArray arrayWithObject:sortPrice];
  [graphList sortedArrayUsingDescriptors:sortDescArray];
  
  [circle setData:graphList];
  [circle setNeedsDisplay];
  
  // タグごとのデータを取得
  NSMutableDictionary *dic = [self getDictionaryByTag:tag];
  
  // NSString *grapthIndex = [dic objectForKey:@"graphIndex"];
  NSString *family = [dic objectForKey:@"family"];
  NSString *startYear = [dic objectForKey:@"startYear"];
  NSString *startMonth = [dic objectForKey:@"startMonth"];
  NSString *endYear = [dic objectForKey:@"endYear"];
  NSString *endMonth = [dic objectForKey:@"endMonth"];
  
  //商品ファミリー別売上比率
  //（2013年1月〜2013年4月）
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
  [titleLabel setFrame:CGRectMake((baseView.frame.size.width-titleLabel.frame.size.width)/2, -10,300,40)];
  titleLabel.numberOfLines = 2;
  // 商品ファミリーか個別か
  if([family isEqualToString:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_FAMILY"]] || [family isEqualToString:@""] || family == nil){
    titleLabel.text = [NSString stringWithFormat:@"%@\n（%@ / %@〜%@ / %@）",[pData getDataForKey:@"DEFINE_DASHBOARD_MESSAGE_FAMILY1"],startYear, startMonth, endYear, endMonth];
  }else{
    titleLabel.text = [NSString stringWithFormat:@"%@%@\n（%@ / %@〜%@ / %@）",family, [pData getDataForKey:@"DEFINE_DASHBOARD_MESSAGE_FAMILY2"], startYear, startMonth, endYear, endMonth];
  }
  titleLabel.font = [UIFont systemFontOfSize:14.0];
  titleLabel.textAlignment = NSTextAlignmentCenter;
  [baseView addSubview:titleLabel];
}


// ファミリー、期間別に売り上げ金額を取得してViewに表示
-(void)requestDataList:(NSString *)familyStr startDate:(NSString *)startStr endDate:(NSString*)endStr UIView:(UIView*)view tag:(NSString*)tag
{
  NSMutableArray *dataList = [[NSMutableArray alloc] init];
  PublicDatas *pData = [PublicDatas instance];
  
  NSString *company_id = [pData getDataForKey:@"cp_company_id"];
  
  // ファミリー指定の場合
  if(familyStr!=nil && ![familyStr isEqualToString:@""] && ![familyStr isEqualToString:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_FAMILY"]]){
    
    //クエリ作成
    NSString *query1;
    NSString *query2;
    if(company_id!=nil && ![company_id isEqualToString:@""]){
      query1 = @" SELECT PriceBookEntryId  , PriceBookEntry.Product2.Family, PriceBookEntry.Product2.Name , sum(TotalPrice)   ";
      query2 = [NSString stringWithFormat:@" From OpportunityLineItem WHERE Opportunity.Account.Id = '%@' AND PriceBookEntry.Product2.Family = '%@' AND Opportunity.CloseDate >= %@ AND Opportunity.CloseDate <= %@ group by PriceBookEntryId,  PriceBookEntry.Product2.Family, PriceBookEntry.Product2.Name order by sum(TotalPrice) desc", company_id, familyStr, startStr, endStr];
    }else{
      
      query1 = @" SELECT PriceBookEntryId  , PriceBookEntry.Product2.Family, PriceBookEntry.Product2.Name , sum(TotalPrice)   ";
      query2 = [NSString stringWithFormat:@" From OpportunityLineItem WHERE PriceBookEntry.Product2.Family = '%@' AND Opportunity.CloseDate >= %@ AND Opportunity.CloseDate <= %@ group by PriceBookEntryId,  PriceBookEntry.Product2.Family, PriceBookEntry.Product2.Name order by sum(TotalPrice) desc", familyStr, startStr, endStr];
    }
    NSString *query = [query1 stringByAppendingString:query2];
    
    NSLog(@"%@",query);
    
    [[SFRestAPI sharedInstance] performSOQLQuery:query
     //エラーハンドラ
                                       failBlock:^(NSError *e) {
                                         NSLog(@"FAILWHALE with error: %@", [e description] );
                                       }
     //受信ハンドラ
                                   completeBlock:^(NSDictionary *results) {
                                     
                                     NSArray *records = [results objectForKey:@"records"];
                                     NSLog(@"request:didLoadResponse: #records: %d", records.count);
                                     
                                     for ( NSDictionary *obj in records ) {
                                       NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
                                       [tmp setObject:[obj valueForKey:@"Family"] forKey:@"Family"];
                                       [tmp setObject:[obj valueForKey:@"Name"] forKey:@"Name"];
                                       [tmp setObject:[obj valueForKey:@"expr0"] forKey:@"totalPrice"];
                                       
                                       [dataList addObject:tmp];
                                     }
                                     [self addCircleGraph:dataList UIView:view tag:tag];
                                   }];
  }else{
    //クエリ作成
    NSString *query1;
    NSString *query2;
    if(company_id!=nil && ![company_id isEqualToString:@""]){
      query1 = @" SELECT PriceBookEntry.Product2.Family ,  sum(TotalPrice)";
      query2 = [NSString stringWithFormat:@" From OpportunityLineItem WHERE  Opportunity.Account.Id = '%@' AND Opportunity.CloseDate >= %@ AND Opportunity.CloseDate <= %@ group by PriceBookEntry.Product2.Family order by sum(TotalPrice) desc ", company_id, startStr, endStr];
    }else{
      query1 = @" SELECT PriceBookEntry.Product2.Family ,  sum(TotalPrice)";
      query2 = [NSString stringWithFormat:@" From OpportunityLineItem WHERE  Opportunity.CloseDate >= %@ AND Opportunity.CloseDate <= %@ group by PriceBookEntry.Product2.Family order by sum(TotalPrice) desc ", startStr, endStr];
    }
    NSString *query = [query1 stringByAppendingString:query2];
    
    NSLog(@"%@",query);
    
    [[SFRestAPI sharedInstance] performSOQLQuery:query
     //エラーハンドラ
                                       failBlock:^(NSError *e) {
                                         NSLog(@"FAILWHALE with error: %@", [e description] );
                                       }
     //受信ハンドラ
                                   completeBlock:^(NSDictionary *results) {
                                     
                                     NSArray *records = [results objectForKey:@"records"];
                                     NSLog(@"request:didLoadResponse: #records: %d", records.count);
                                     
                                     for ( NSDictionary *obj in records ) {
                                       NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
                                       [tmp setObject:[obj valueForKey:@"Family"] forKey:@"Family"];
                                       [tmp setObject:[obj valueForKey:@"Family"] forKey:@"Name"];
                                       [tmp setObject:[obj valueForKey:@"expr0"] forKey:@"totalPrice"];
                                       
                                       [dataList addObject:tmp];
                                     }
                                     [self addCircleGraph:dataList UIView:view tag:tag];
                                   }];
  }
  
}

// dic 取得メソッド
-(NSMutableDictionary*)getDictionaryByTag:(NSString*)tag
{
  PublicDatas *pData = [PublicDatas instance];
  NSString *keyStr = [NSString stringWithFormat:@"dic%@", tag];
  NSMutableDictionary *dic;
  // 企業用
  NSString *company_id = [pData getDataForKey:@"cp_company_id"];
  if(company_id!=nil && ![company_id isEqualToString:@""]){
    dic = [self getDictionaryForTag:tag];
  }
  // 個人設定
  else{
    dic = [pData getDataForKey:keyStr];
  }
  return dic;
}


// 棒グラフ描画
-(void) performBarGraph:(NSString*)tag UIView:(UIView*)baseView
{
  PublicDatas *pData = [PublicDatas instance];
  
  NSMutableDictionary *dic = [self getDictionaryByTag:tag];
  
  NSLog(@" dic %@", dic);
  
  NSString *barMonth = [dic objectForKey:@"barMonth"];
  NSString *barItem = [dic objectForKey:@"barItem"];
  NSString *barTerm = [dic objectForKey:@"barTerm"];
  
  NSLog(@" barMonth %@", barMonth);
  NSLog(@" barItem %@", barItem);
  NSLog(@" barTerm %@", barTerm);
  
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *comps = [[NSDateComponents alloc] init];
  
  NSDate *today = [NSDate date];
  NSDate *date1 = [calendar dateByAddingComponents:comps toDate:today options:0];
  
  // 年月日をとりだす
  comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                      fromDate:date1];
  NSInteger year = [comps year];
  NSInteger now_month = [comps month];
  
  int m = [barMonth intValue];
  
  NSMutableArray *startYear = [[NSMutableArray alloc] init];
  NSMutableArray *startMonth = [[NSMutableArray alloc] init];
  NSMutableArray *lastYear = [[NSMutableArray alloc] init];
  NSMutableArray *lastMonth = [[NSMutableArray alloc] init];
  
  // barTerm @"年間", @"四半期", @"前四半期"
  if([barTerm isEqualToString:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_YEARTERM"]]){
    // 選択した月が現在より先の場合は、取得するデータを1年ずらす
    if(m>now_month) year = year-1;
    
    // 今回の表示用
    for(int i=0; i<4; i++){
      int j = m + 3*i;
      if(j>12){
        j = j-12;
        year = year+1;
      }
      [startYear addObject:[NSString stringWithFormat:@"%d", year]];
      [startMonth addObject:[NSString stringWithFormat:@"%d", j]];
    }
    
    // 1年前
    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
    [inputDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    for(int i=0; i<[startYear count]; i++){
      NSString *str = [NSString stringWithFormat:@"%@/%2d/01 00:00:00", [startYear objectAtIndex:i], [[startMonth objectAtIndex:i]intValue]];
      [inputDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
      NSDate *tmpDate = [inputDateFormatter dateFromString:str];
      comps = [[NSDateComponents alloc] init];
      [comps setYear:-1];
      NSDate *date1 = [calendar dateByAddingComponents:comps toDate:tmpDate options:0];
      // 年
      [inputDateFormatter setDateFormat:@"yyyy"];
      [lastYear addObject:[inputDateFormatter stringFromDate:date1]];
      // 月
      [inputDateFormatter setDateFormat:@"MM"];
      [lastMonth addObject:[inputDateFormatter stringFromDate:date1]];
    }
  }else if([barTerm isEqualToString:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_QTERM"]]){
    // 4期分の最初の月を計算 開始月を入力月として全体を4つに分割
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    for(int i=0; i<4; i++){
      int j = m+3*i;
      if(j>12) j=j-12;
      [mArray addObject:[[NSNumber alloc]initWithInt:j]];
    }
    // 開始月の判定 当月が含まれる期間を判定
    for(int i=0; i<[mArray count]; i++){
      int min = [[mArray objectAtIndex:i] intValue];
      int max = min+2;
      if(min<= now_month && now_month<=max){
        m = min;
        break;
      }
    }
    
    // 今回の表示用
    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
    [inputDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSString *intputDateStr = [NSString stringWithFormat:@"%d/%2d/01 00:00:00", year, m];
    NSDate *inputDate = [inputDateFormatter dateFromString:intputDateStr];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    for(int i=0; i<3; i++){
      [comps setMonth:i];
      NSDate *date1 = [calendar dateByAddingComponents:comps toDate:inputDate options:0];
      NSLog(@"date1 %@", date1);
      
      [inputDateFormatter setDateFormat:@"yyyy"];
      NSString *_year = [inputDateFormatter stringFromDate:date1];
      NSLog(@"year %@", _year);
      [startYear addObject:_year];
      
      [inputDateFormatter setDateFormat:@"MM"];
      NSString *_month = [inputDateFormatter stringFromDate:date1];
      NSLog(@"month %@", _month);
      [startMonth addObject:_month];
    }
    
    // 1年前
    [inputDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    for(int i=0; i<[startYear count]; i++){
      NSString *str = [NSString stringWithFormat:@"%@/%2d/01 00:00:00", [startYear objectAtIndex:i], [[startMonth objectAtIndex:i]intValue]];
      [inputDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
      NSDate *tmpDate = [inputDateFormatter dateFromString:str];
      comps = [[NSDateComponents alloc] init];
      [comps setYear:-1];
      NSDate *date1 = [calendar dateByAddingComponents:comps toDate:tmpDate options:0];
      // 年
      [inputDateFormatter setDateFormat:@"yyyy"];
      [lastYear addObject:[inputDateFormatter stringFromDate:date1]];
      // 月
      [inputDateFormatter setDateFormat:@"MM"];
      [lastMonth addObject:[inputDateFormatter stringFromDate:date1]];
    }
  }
  if([barTerm isEqualToString:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_PREQTERM"]]){
    // 4期分の最初の月を計算 開始月を入力月として全体を4つに分割
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    for(int i=0; i<4; i++){
      int j = m+3*i;
      if(j>12) j=j-12;
      [mArray addObject:[[NSNumber alloc]initWithInt:j]];
    }
    // 開始月の判定 当月が含まれる期間を判定
    for(int i=0; i<[mArray count]; i++){
      int min = [[mArray objectAtIndex:i] intValue];
      int max = min+2;
      if(min<= now_month && now_month<=max){
        m = min;
        break;
      }
    }
    
    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
    [inputDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSString *intputDateStr = [NSString stringWithFormat:@"%d/%2d/01 00:00:00", year, m];
    NSDate *inputDate = [inputDateFormatter dateFromString:intputDateStr];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    for(int i=1; i<4; i++){
      [comps setMonth:-i];
      NSDate *date1 = [calendar dateByAddingComponents:comps toDate:inputDate options:0];
      NSLog(@"date1 %@", date1);
      
      [inputDateFormatter setDateFormat:@"yyyy"];
      NSString *_year = [inputDateFormatter stringFromDate:date1];
      NSLog(@"year %@", _year);
      [startYear addObject:_year];
      
      [inputDateFormatter setDateFormat:@"MM"];
      NSString *_month = [inputDateFormatter stringFromDate:date1];
      NSLog(@"month %@", _month);
      [startMonth addObject:_month];
    }
    // 1年前
    for(int i=0; i<[startYear count]; i++){
      NSString *str = [NSString stringWithFormat:@"%@/%2d/01 00:00:00", [startYear objectAtIndex:i], [[startMonth objectAtIndex:i]intValue]];
      [inputDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
      NSDate *tmpDate = [inputDateFormatter dateFromString:str];
      comps = [[NSDateComponents alloc] init];
      [comps setYear:-1];
      NSDate *date1 = [calendar dateByAddingComponents:comps toDate:tmpDate options:0];
      // 年
      [inputDateFormatter setDateFormat:@"yyyy"];
      [lastYear addObject:[inputDateFormatter stringFromDate:date1]];
      // 月
      [inputDateFormatter setDateFormat:@"MM"];
      [lastMonth addObject:[inputDateFormatter stringFromDate:date1]];
    }
  }
  
  // barItem @"売上", @"商談数"
  NSString *select;
  if([barItem isEqualToString:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_SALE"]]){
    select = @" sum(TotalPrice) ";
  }else{
    select = @" count(Id) ";
  }
  NSMutableArray *dataList = [[NSMutableArray alloc] init];
  NSMutableArray *lastdataList = [[NSMutableArray alloc] init];
  
  // 月で回す
  for(int i=0; i<[startMonth count]; i++){
    NSString *startStr;
    NSString *endStr;
    // 開始日
    int m = [[startMonth objectAtIndex:i] intValue];
    int year = [[startYear objectAtIndex:i] intValue];
    startStr = [NSString stringWithFormat:@"%d-%02d-01", year, m];
    
    // 末日の日付
    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
    NSString *str = [NSString stringWithFormat:@"%@/%2d/01 00:00:00", [startYear objectAtIndex:i], [[startMonth objectAtIndex:i]intValue]];
    [inputDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSDate *tmpDate = [inputDateFormatter dateFromString:str];
    comps = [[NSDateComponents alloc] init];
    if([barTerm isEqualToString:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_YEARTERM"]]){
      [comps setMonth:2];
    }else{
      [comps setMonth:0];
    }
    NSDate *date1 = [calendar dateByAddingComponents:comps toDate:tmpDate options:0];
    // 年
    [inputDateFormatter setDateFormat:@"yyyy"];
    NSString *_year = [inputDateFormatter stringFromDate:date1];
    // 月
    [inputDateFormatter setDateFormat:@"MM"];
    NSString *_month = [inputDateFormatter stringFromDate:date1];
    // 日
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSRange range = [cal rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date1];
    
    endStr = [NSString stringWithFormat:@"%@-%02d-%02d", _year, [_month intValue], range.length];
    
    //クエリ作成
    NSString *company_id = [pData getDataForKey:@"cp_company_id"];
    NSLog(@"company_id %@", [pData getDataForKey:@"cp_company_id"]);
    NSLog(@"company_id %@", company_id);
    NSString *query1;
    NSString *query2;
    if(company_id!=nil && ![company_id isEqualToString:@""]){
      query1 = [NSString stringWithFormat:@" SELECT %@ ", select];
      query2 = [NSString stringWithFormat:@" From OpportunityLineItem Where  Opportunity.Account.Id = '%@' AND Opportunity.CloseDate >= %@ AND Opportunity.CloseDate <= %@ ", company_id, startStr, endStr];
    }else{
      query1 = [NSString stringWithFormat:@" SELECT %@ ", select];
      query2 = [NSString stringWithFormat:@" From OpportunityLineItem Where Opportunity.CloseDate >= %@ AND Opportunity.CloseDate <= %@ ", startStr, endStr];
    }
    NSString *query = [query1 stringByAppendingString:query2];
    
    NSLog(@"%@",query);
    
    [NSThread sleepForTimeInterval:0.1];
    
    [[SFRestAPI sharedInstance] performSOQLQuery:query
     //エラーハンドラ
                                       failBlock:^(NSError *e) {
                                         NSLog(@"FAILWHALE with error: %@", [e description] );
                                       }
     //受信ハンドラ
                                   completeBlock:^(NSDictionary *results) {
                                     
                                     NSArray *records = [results objectForKey:@"records"];
                                     NSLog(@"request:didLoadResponse: #records: %d", records.count);
                                     
                                     for ( NSDictionary *obj in records ) {
                                       //NSLog(@"obj %@",obj);
                                       //NSLog(@"obj id %@",[obj valueForKey:@"Id"]);
                                       NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
                                       
                                       [tmp setObject:[NSString stringWithFormat:@"%d", year] forKey:@"year"];
                                       
                                       [tmp setObject:[NSString stringWithFormat:@"%d", m] forKey:@"month"];
                                       
                                       // ソート用
                                       NSString *sortDateStr = [NSString stringWithFormat:@"%d-%02d", year, m];
                                       [tmp setObject:sortDateStr forKey:@"month1"];
                                       
                                       NSString *_t = [obj valueForKey:@"expr0"];
                                       
                                       if([um chkString:_t]){
                                         [tmp setObject:[obj valueForKey:@"expr0"] forKey:@"totalPrice"];
                                       }else{
                                         [tmp setObject:@"0" forKey:@"totalPrice"];
                                       }
                                       
                                       //NSLog(@"obj %@",tmp);
                                       [dataList addObject:tmp];
                                     }
                                     
                                     //ソート対象となるキーを指定した、NSSortDescriptorの生成
                                     NSSortDescriptor *sortDescNumber;
                                     BOOL acc = YES;
                                     //if(![[startYear objectAtIndex:0] isEqualToString:[startYear lastObject]]) acc = NO;
                                     sortDescNumber = [[NSSortDescriptor alloc] initWithKey:@"month1" ascending:acc];
                                     
                                     // NSSortDescriptorは配列に入れてNSArrayに渡す
                                     NSArray *sortDescArray;
                                     sortDescArray = [NSArray arrayWithObjects:sortDescNumber, nil];
                                     
                                     // ソートの実行
                                     NSArray *sortArray;
                                     sortArray = [dataList sortedArrayUsingDescriptors:sortDescArray];
                                     
                                     [dic setObject:sortArray forKey:@"dataList"];
                                   }];
  }
  
  
  // 月で回す
  for(int i=0; i<[lastMonth count]; i++){
    NSString *startStr;
    NSString *endStr;
    // 開始日
    int m = [[lastMonth objectAtIndex:i] intValue];
    int year = [[lastYear objectAtIndex:i] intValue];
    startStr = [NSString stringWithFormat:@"%d-%02d-01", year, m];
    
    // 3ヶ月後の月末日の日付
    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
    NSString *str = [NSString stringWithFormat:@"%@/%2d/01 00:00:00", [lastYear objectAtIndex:i], [[lastMonth objectAtIndex:i]intValue]];
    [inputDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSDate *tmpDate = [inputDateFormatter dateFromString:str];
    comps = [[NSDateComponents alloc] init];
    if([barTerm isEqualToString:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_YEARTERM"]]){
      [comps setMonth:2];
    }else{
      [comps setMonth:0];
    }
    NSDate *date1 = [calendar dateByAddingComponents:comps toDate:tmpDate options:0];
    // 年
    [inputDateFormatter setDateFormat:@"yyyy"];
    NSString *_year = [inputDateFormatter stringFromDate:date1];
    // 月
    [inputDateFormatter setDateFormat:@"MM"];
    NSString *_month = [inputDateFormatter stringFromDate:date1];
    // 日
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSRange range = [cal rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date1];
    
    endStr = [NSString stringWithFormat:@"%@-%02d-%02d", _year, [_month intValue], range.length];
    
    //クエリ作成
    NSString *query1;
    NSString *query2;
    NSString *company_id = [pData getDataForKey:@"cp_company_id"];
    if(company_id!=nil && ![company_id isEqualToString:@""]){
      query1 = [NSString stringWithFormat:@" SELECT %@ ", select];
      query2 = [NSString stringWithFormat:@" From OpportunityLineItem Where Opportunity.Account.Id = '%@' AND Opportunity.CloseDate >= %@ AND Opportunity.CloseDate <= %@ ", company_id, startStr, endStr];
    }else{
      query1 = [NSString stringWithFormat:@" SELECT %@ ", select];
      query2 = [NSString stringWithFormat:@" From OpportunityLineItem Where Opportunity.CloseDate >= %@ AND Opportunity.CloseDate <= %@ ", startStr, endStr];
    }
    NSString *query = [query1 stringByAppendingString:query2];
    
    NSLog(@"%@",query);
    
    [NSThread sleepForTimeInterval:0.1];
    
    [[SFRestAPI sharedInstance] performSOQLQuery:query
     //エラーハンドラ
                                       failBlock:^(NSError *e) {
                                         NSLog(@"FAILWHALE with error: %@", [e description] );
                                       }
     //受信ハンドラ
                                   completeBlock:^(NSDictionary *results) {
                                     
                                     NSArray *records = [results objectForKey:@"records"];
                                     NSLog(@"request:didLoadResponse: #records: %d", records.count);
                                     
                                     for ( NSDictionary *obj in records ) {
                                       //NSLog(@"obj %@",obj);
                                       //NSLog(@"obj id %@",[obj valueForKey:@"Id"]);
                                       NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
                                       
                                       [tmp setObject:[NSString stringWithFormat:@"%d", year] forKey:@"year"];
                                       [tmp setObject:[NSString stringWithFormat:@"%d", m] forKey:@"month"];
                                       // ソート用
                                       NSString *sortDateStr = [NSString stringWithFormat:@"%d-%02d", year, m];
                                       [tmp setObject:sortDateStr forKey:@"month1"];
                                       
                                       NSString *_t = [obj valueForKey:@"expr0"];
                                       
                                       if([um chkString:_t]){
                                         [tmp setObject:[obj valueForKey:@"expr0"] forKey:@"totalPrice"];
                                       }else{
                                         [tmp setObject:@"0" forKey:@"totalPrice"];
                                       }
                                       //NSLog(@"obj %@",tmp);
                                       [lastdataList addObject:tmp];
                                     }
                                     
                                     //ソート対象となるキーを指定した、NSSortDescriptorの生成
                                     NSSortDescriptor *sortDescNumber;
                                     BOOL acc = YES;
                                     sortDescNumber = [[NSSortDescriptor alloc] initWithKey:@"month1" ascending:acc];
                                     
                                     // NSSortDescriptorは配列に入れてNSArrayに渡す
                                     NSArray *sortDescArray;
                                     sortDescArray = [NSArray arrayWithObjects:sortDescNumber, nil];
                                     
                                     // ソートの実行
                                     NSArray *sortArray;
                                     sortArray = [lastdataList sortedArrayUsingDescriptors:sortDescArray];
                                     
                                     //NSLog(@"%@", lastdataList);
                                     [dic setObject:sortArray forKey:@"lastdataList"];
                                     
                                     NSLog(@"datalist count %d", [[dic objectForKey:@"dataList"] count]);
                                     NSLog(@"dlastatalist count %d", [[dic objectForKey:@"lastdataList"] count]);
                                     
                                     //if([[dic objectForKey:@"dataList"] count]==[[dic objectForKey:@"lastdataList"] count]){
                                     
                                     // グラフ数チェック
                                     if(([barTerm isEqualToString:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_YEARTERM"]] && ([[dic objectForKey:@"lastdataList"] count]==4))
                                        ||
                                        (![barTerm isEqualToString:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_YEARTERM"]] && ([[dic objectForKey:@"lastdataList"] count]==3))
                                        )
                                     {
                                       // 棒グラフ
                                       [self addBarGraph:[dic objectForKey:@"dataList"] lastYearData:[dic objectForKey:@"lastdataList"] UIView:baseView tag:tag];
                                     }
                                     //}
                                   }];
  }
}

// 棒グラフ描画
-(void) addBarGraph:(NSMutableArray*)dataList lastYearData:(NSMutableArray*)lastdataList UIView:(UIView*)baseView tag:(NSString*)tag
{
  PublicDatas *pData = [PublicDatas instance];
  
  if([dataList count] != [lastdataList count]){
    [self performBarGraph:tag UIView:baseView];
    return;
  }
  
  //NSLog(@"%@", dataList);
  //NSLog(@"%@", lastdataList);
  
  NSMutableDictionary *dic = [self getDictionaryByTag:tag];
  
  NSString *barTerm = [dic objectForKey:@"barTerm"];
  
  // 既存グラフを消す
  for (UIView *view in [baseView subviews]) {
    //if(![view isMemberOfClass:[UIView class]]) continue;
    [view removeFromSuperview];
  }
  
  NSMutableArray *titleArray = [[NSMutableArray alloc] init];
  NSMutableArray *yearArray = [[NSMutableArray alloc] init];
  NSMutableArray *valueArray = [[NSMutableArray alloc] init];
  for(int i=0; i<[dataList count]; i++){
    NSDictionary *tmp = [dataList objectAtIndex:i];
    [titleArray addObject:[tmp objectForKey:@"month"]];
    [yearArray addObject:[tmp objectForKey:@"year"]];
    [valueArray addObject:[NSNumber numberWithInt:[[tmp objectForKey:@"totalPrice"] intValue]]];
  }
  
  NSMutableArray *oldTitleArray = [[NSMutableArray alloc] init];
  NSMutableArray *oldYearArray = [[NSMutableArray alloc] init];
  NSMutableArray *oldvalueArray = [[NSMutableArray alloc] init];
  for(int i=0; i<[dataList count]; i++){
    NSDictionary *tmp = [lastdataList objectAtIndex:i];
    [oldTitleArray addObject:[tmp objectForKey:@"month"]];
    [oldYearArray addObject:[tmp objectForKey:@"year"]];
    [oldvalueArray addObject:[NSNumber numberWithInt:[[tmp objectForKey:@"totalPrice"] intValue]]];
  }
  
  
  //グラフ表示
	BarGraph *leftGraph = [[BarGraph alloc]initWithFrame:CGRectMake(0, 0, 300, 300)];
  
	//横軸ラベル
  if([barTerm isEqualToString:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_YEARTERM"]]){
    titleArray = [[NSMutableArray alloc] initWithObjects:@"1Q", @"2Q",@"3Q", @"4Q", nil];
  }
	[leftGraph setXLblAry:titleArray];
  
	//データ名 本年度、昨年度
  NSString *company_id = [pData getDataForKey:@"cp_company_id"];
  if(company_id!=nil && ![company_id isEqualToString:@""]){
	[leftGraph setNameAry:[NSMutableArray arrayWithObjects:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_YEARNOW"],[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_YEARPRE"],nil]];
  }else{
  	[leftGraph setNameAry:[NSMutableArray arrayWithObjects:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_YEARNOW"],[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_YEARPRE"],nil]];
  }
  
	//グラフエリアのサイズ
	leftGraph.graphSizeX = 220;
	leftGraph.graphSizeY = 220;
  
	//barの太さ
	leftGraph.barWidth = 20.0f;
  
	//データ
	NSMutableArray *datAry = [NSMutableArray array];
	[datAry addObject:valueArray];
	[datAry addObject:oldvalueArray];
	[leftGraph setDatAry:datAry];
  
  int max1 = 0;
  int max2 = 0;
  int max1F = 0;
  int max2F = 0;
  @try{
    // 最大値
    NSPredicate *maxPred = [NSPredicate predicateWithFormat:
                            @"SELF == max:(%@)", valueArray];
    NSLog(@"%@", [valueArray filteredArrayUsingPredicate:maxPred]);
    max1 = [[[valueArray filteredArrayUsingPredicate:maxPred] objectAtIndex:0] intValue];
    
    // 桁数
    int digit = (int)log10( [[[NSNumber alloc]initWithInt:max1] doubleValue] ) + 1;
    
    float b = (float)(max1/pow(10, digit-1));
    max1F = ceil(b) * pow(10, digit-1);
    NSLog(@"%d", max1F);
    
    maxPred = [NSPredicate predicateWithFormat:
               @"SELF == max:(%@)", oldvalueArray];
    NSLog(@"%@", [oldvalueArray filteredArrayUsingPredicate:maxPred]);
    max2 = [[[oldvalueArray filteredArrayUsingPredicate:maxPred] objectAtIndex:0] intValue]*2;
    
    // 桁数
    int _digit = (int)log10( [[[NSNumber alloc]initWithInt:max2] doubleValue] ) + 1;
    
    float _b = (float)(max2/pow(10, _digit-1));
    max2F = ceil(_b) * pow(10, _digit-1);;
    
    if(max1F<0) max1F =0;
    if(max2F<0) max2F =0;
    
    NSLog(@"max1F %d", max1F);
    NSLog(@"max2F %d", max2F);
    
    if(max1F<max2F) max1F = max2F;
    
    NSNumber *max1_1 = [[NSNumber alloc]initWithInt:max1F];
    //NSNumber *max2_1 = [[NSNumber alloc]initWithInt:max2F];
    NSMutableArray *maxArray = [NSMutableArray arrayWithObjects:max1_1, nil];
    [leftGraph setMaxValAry:maxArray];
  }
  @catch (NSException *exception) {
    NSLog(@"%d", __LINE__);
    NSLog(@"main:Caught %@:%@", [exception name], [exception reason]);
  }
  
  //区切り数
	leftGraph.y_section = 4;
	leftGraph.backgroundColor = [UIColor whiteColor];
	[baseView addSubview:leftGraph];
  
  [dic setObject:[[NSMutableArray alloc]init] forKey:@"dataList"];
  [dic setObject:[[NSMutableArray alloc]init] forKey:@"lastdataList"];
  
  /*
   barMonth 開始付月
   barItem @"売上", @"商談数"
   barTerm @"年間", @"四半期", @"前四半期"
   */
  
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
  [titleLabel setFrame:CGRectMake((baseView.frame.size.width-titleLabel.frame.size.width)/2, -10,300,40)];
  titleLabel.numberOfLines = 2;
  titleLabel.text = [NSString stringWithFormat:@"%@ %@\n",[dic objectForKey:@"barItem"],[dic objectForKey:@"barTerm"]];
  titleLabel.font = [UIFont systemFontOfSize:14.0];
  titleLabel.textAlignment = NSTextAlignmentCenter;
  titleLabel.backgroundColor = [UIColor clearColor];
  [baseView addSubview:titleLabel];
  
}


// 折れ線グラフ実行
-(void) performLineGraph:(NSString*)tag UIView:(UIView*)baseView
{
  PublicDatas *pData = [PublicDatas instance];
  
  NSMutableDictionary *dic = [self getDictionaryByTag:tag];
  
  NSString *lineMonth = [dic objectForKey:@"lineMonth"];
  NSString *lineItem = [dic objectForKey:@"lineItem"];
  NSString *lineTerm = [dic objectForKey:@"lineTerm"];
  
  //NSDate *date = [NSDate date];
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *comps = [[NSDateComponents alloc] init];
  
  NSDate *today = [NSDate date];
  NSDate *date1 = [calendar dateByAddingComponents:comps toDate:today options:0];
  
  // 年月日をとりだす
  comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                      fromDate:date1];
  NSInteger year = [comps year];
  NSInteger now_month = [comps month];
  
  int m = [lineMonth intValue];
  
  NSMutableArray *startYear = [[NSMutableArray alloc] init];
  NSMutableArray *startMonth = [[NSMutableArray alloc] init];
  
  // lineTerm @"年間", @"四半期", @"前四半期"
  if([lineTerm isEqualToString:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_YEARTERM"]]){
    // 選択した月が現在より先の場合は、取得するデータを1年ずらす
    if(m>now_month) year = year-1;
    
    // 今回の表示用
    for(int i=0; i<4; i++){
      int j = m + 3*i;
      if(j>12){
        j = j-12;
        year = year+1;
      }
      [startYear addObject:[NSString stringWithFormat:@"%d", year]];
      [startMonth addObject:[NSString stringWithFormat:@"%d", j]];
    }
  }else if([lineTerm isEqualToString:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_QTERM"]]){
    // 4期分の最初の月を計算 開始月を入力月として全体を4つに分割
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    for(int i=0; i<4; i++){
      int j = m+3*i;
      if(j>12) j=j-12;
      [mArray addObject:[[NSNumber alloc]initWithInt:j]];
    }
    NSLog(@" mArray %@", mArray);
    // 開始月の判定 当月が含まれる期間を判定
    for(int i=0; i<[mArray count]; i++){
      int min = [[mArray objectAtIndex:i] intValue];
      int max = min+2;
      
      NSLog(@" min %d  max %d", min, max);
      
      if(min<= now_month && now_month<=max){
        m = min;
        break;
      }
    }
    NSLog(@" now_month %d", now_month);
    NSLog(@" m %d", m);
    
    // 今回の表示用
    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
    [inputDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSString *intputDateStr = [NSString stringWithFormat:@"%d/%2d/01 00:00:00", year, m];
    NSDate *inputDate = [inputDateFormatter dateFromString:intputDateStr];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    for(int i=0; i<3; i++){
      [comps setMonth:i];
      NSDate *date1 = [calendar dateByAddingComponents:comps toDate:inputDate options:0];
      NSLog(@"date1 %@", date1);
      
      [inputDateFormatter setDateFormat:@"yyyy"];
      NSString *_year = [inputDateFormatter stringFromDate:date1];
      NSLog(@"year %@", _year);
      [startYear addObject:_year];
      
      [inputDateFormatter setDateFormat:@"MM"];
      NSString *_month = [inputDateFormatter stringFromDate:date1];
      NSLog(@"month %@", _month);
      [startMonth addObject:_month];
    }
  }
  if([lineTerm isEqualToString:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_PREQTERM"]]){
    // 4期分の最初の月を計算 開始月を入力月として全体を4つに分割
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    for(int i=0; i<4; i++){
      int j = m+3*i;
      if(j>12) j=j-12;
      [mArray addObject:[[NSNumber alloc]initWithInt:j]];
    }
    
    // 開始月の判定 当月が含まれる期間を判定
    for(int i=0; i<[mArray count]; i++){
      int min = [[mArray objectAtIndex:i] intValue];
      int max = min+2;
      if(min<= now_month && now_month<=max){
        m = min;
        break;
      }
    }
    
    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
    [inputDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSString *intputDateStr = [NSString stringWithFormat:@"%d/%2d/01 00:00:00", year, m];
    NSDate *inputDate = [inputDateFormatter dateFromString:intputDateStr];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    for(int i=1; i<4; i++){
      [comps setMonth:-i];
      NSDate *date1 = [calendar dateByAddingComponents:comps toDate:inputDate options:0];
      NSLog(@"date1 %@", date1);
      
      [inputDateFormatter setDateFormat:@"yyyy"];
      NSString *_year = [inputDateFormatter stringFromDate:date1];
      NSLog(@"year %@", _year);
      [startYear addObject:_year];
      
      [inputDateFormatter setDateFormat:@"MM"];
      NSString *_month = [inputDateFormatter stringFromDate:date1];
      NSLog(@"month %@", _month);
      [startMonth addObject:_month];
    }
  }
  
  // lineItem @"売上", @"商談数"
  NSString *select;
  if([lineItem isEqualToString:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_SALE"]]){
    select = @" sum(TotalPrice) ";
  }else{
    select = @" count(Id) ";
  }
  NSMutableArray *dataList = [[NSMutableArray alloc] init]; // 会社
  NSMutableArray *pdataList = [[NSMutableArray alloc] init]; // 個人
  
  // 月で回す
  for(int i=0; i<[startMonth count]; i++){
    NSString *startStr;
    NSString *endStr;
    // 開始日
    int m = [[startMonth objectAtIndex:i] intValue];
    int year = [[startYear objectAtIndex:i] intValue];
    startStr = [NSString stringWithFormat:@"%d-%02d-01", year, m];
    
    // 末日の日付
    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
    NSString *str = [NSString stringWithFormat:@"%@/%2d/01 00:00:00", [startYear objectAtIndex:i], [[startMonth objectAtIndex:i]intValue]];
    [inputDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSDate *tmpDate = [inputDateFormatter dateFromString:str];
    comps = [[NSDateComponents alloc] init];
    if([lineTerm isEqualToString:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_YEARTERM"]]){
      [comps setMonth:2];
    }else{
      [comps setMonth:0];
    }
    NSDate *date1 = [calendar dateByAddingComponents:comps toDate:tmpDate options:0];
    // 年
    [inputDateFormatter setDateFormat:@"yyyy"];
    NSString *_year = [inputDateFormatter stringFromDate:date1];
    // 月
    [inputDateFormatter setDateFormat:@"MM"];
    NSString *_month = [inputDateFormatter stringFromDate:date1];
    // 日
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSRange range = [cal rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date1];
    
    endStr = [NSString stringWithFormat:@"%@-%02d-%02d", _year, [_month intValue], range.length];
    
    //クエリ作成
    NSString *query1 = [NSString stringWithFormat:@" SELECT %@ ", select];
    NSString *query2 = [NSString stringWithFormat:@" From OpportunityLineItem Where Opportunity.CloseDate >= %@ AND Opportunity.CloseDate <= %@ ", startStr, endStr];
    NSString *query = [query1 stringByAppendingString:query2];
    
    NSLog(@"%@",query);
    
    [NSThread sleepForTimeInterval:0.1];
    
    [[SFRestAPI sharedInstance] performSOQLQuery:query
     //エラーハンドラ
                                       failBlock:^(NSError *e) {
                                         NSLog(@"FAILWHALE with error: %@", [e description] );
                                       }
     //受信ハンドラ
                                   completeBlock:^(NSDictionary *results) {
                                     
                                     NSArray *records = [results objectForKey:@"records"];
                                     NSLog(@"request:didLoadResponse: #records: %d", records.count);
                                     
                                     for ( NSDictionary *obj in records ) {
                                       //NSLog(@"obj %@",obj);
                                       //NSLog(@"obj id %@",[obj valueForKey:@"Id"]);
                                       NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
                                       
                                       [tmp setObject:[NSString stringWithFormat:@"%d", year] forKey:@"year"];
                                       
                                       [tmp setObject:[NSString stringWithFormat:@"%d", m] forKey:@"month"];
                                       
                                       // ソート用
                                       NSString *sortDateStr = [NSString stringWithFormat:@"%d-%02d", year, m];
                                       [tmp setObject:sortDateStr forKey:@"month1"];
                                       
                                       NSString *_t = [obj valueForKey:@"expr0"];
                                       
                                       if([um chkString:_t]){
                                         [tmp setObject:[obj valueForKey:@"expr0"] forKey:@"totalPrice"];
                                       }else{
                                         [tmp setObject:@"0" forKey:@"totalPrice"];
                                       }
                                       
                                       //NSLog(@"obj %@",tmp);
                                       [dataList addObject:tmp];
                                     }
                                     
                                     //ソート対象となるキーを指定した、NSSortDescriptorの生成
                                     NSSortDescriptor *sortDescNumber;
                                     BOOL acc = YES;
                                     sortDescNumber = [[NSSortDescriptor alloc] initWithKey:@"month1" ascending:acc];
                                     
                                     // NSSortDescriptorは配列に入れてNSArrayに渡す
                                     NSArray *sortDescArray;
                                     sortDescArray = [NSArray arrayWithObjects:sortDescNumber, nil];
                                     
                                     // ソートの実行
                                     NSArray *sortArray;
                                     sortArray = [dataList sortedArrayUsingDescriptors:sortDescArray];
                                     
                                     [dic setObject:sortArray forKey:@"dataList"];
                                   }];
  }
  
  
  // 月で回す 個人用
  for(int i=0; i<[startMonth count]; i++){
    NSString *startStr;
    NSString *endStr;
    // 開始日
    int m = [[startMonth objectAtIndex:i] intValue];
    int year = [[startYear objectAtIndex:i] intValue];
    startStr = [NSString stringWithFormat:@"%d-%02d-01", year, m];
    
    // 3ヶ月後の月末日の日付
    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
    NSString *str = [NSString stringWithFormat:@"%@/%2d/01 00:00:00", [startYear objectAtIndex:i], [[startMonth objectAtIndex:i]intValue]];
    [inputDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSDate *tmpDate = [inputDateFormatter dateFromString:str];
    comps = [[NSDateComponents alloc] init];
    if([lineTerm isEqualToString:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_YEARTERM"]]){
      [comps setMonth:2];
    }else{
      [comps setMonth:0];
    }
    NSDate *date1 = [calendar dateByAddingComponents:comps toDate:tmpDate options:0];
    // 年
    [inputDateFormatter setDateFormat:@"yyyy"];
    NSString *_year = [inputDateFormatter stringFromDate:date1];
    // 月
    [inputDateFormatter setDateFormat:@"MM"];
    NSString *_month = [inputDateFormatter stringFromDate:date1];
    // 日
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSRange range = [cal rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date1];
    
    endStr = [NSString stringWithFormat:@"%@-%02d-%02d", _year, [_month intValue], range.length];
    
    // 認証したユーザー情報にアクセス
    SFAccountManager *sm = [SFAccountManager sharedInstance];
    
    //クエリ作成
    NSString *company_id = [pData getDataForKey:@"cp_company_id"];
    NSString *query1;
    NSString *query2;
    if(company_id!=nil && ![company_id isEqualToString:@""]){
      query1 = [NSString stringWithFormat:@" SELECT %@ ", select];
      query2 = [NSString stringWithFormat:@" From OpportunityLineItem Where Opportunity.Account.Id = '%@' AND Opportunity.CloseDate >= %@ AND Opportunity.CloseDate <= %@ ", company_id, startStr, endStr];
    }else{
      query1 = [NSString stringWithFormat:@" SELECT %@ ", select];
      query2 = [NSString stringWithFormat:@" From OpportunityLineItem Where CreatedById = '%@' AND Opportunity.CloseDate >= %@ AND Opportunity.CloseDate <= %@ ", sm.idData.userId, startStr, endStr];
    }
    NSString *query = [query1 stringByAppendingString:query2];
    
    NSLog(@"%@",query);
    
    [NSThread sleepForTimeInterval:0.1];
    
    [[SFRestAPI sharedInstance] performSOQLQuery:query
     //エラーハンドラ
                                       failBlock:^(NSError *e) {
                                         NSLog(@"FAILWHALE with error: %@", [e description] );
                                       }
     //受信ハンドラ
                                   completeBlock:^(NSDictionary *results) {
                                     
                                     NSArray *records = [results objectForKey:@"records"];
                                     NSLog(@"request:didLoadResponse: #records: %d", records.count);
                                     
                                     for ( NSDictionary *obj in records ) {
                                       //NSLog(@"obj %@",obj);
                                       //NSLog(@"obj id %@",[obj valueForKey:@"Id"]);
                                       NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
                                       
                                       [tmp setObject:[NSString stringWithFormat:@"%d", year] forKey:@"year"];
                                       [tmp setObject:[NSString stringWithFormat:@"%d", m] forKey:@"month"];
                                       // ソート用
                                       NSString *sortDateStr = [NSString stringWithFormat:@"%d-%02d", year, m];
                                       [tmp setObject:sortDateStr forKey:@"month1"];
                                       
                                       NSString *_t = [obj valueForKey:@"expr0"];
                                       
                                       if([um chkString:_t]){
                                         [tmp setObject:[obj valueForKey:@"expr0"] forKey:@"totalPrice"];
                                       }else{
                                         [tmp setObject:@"0" forKey:@"totalPrice"];
                                       }
                                       //NSLog(@"obj %@",tmp);
                                       [pdataList addObject:tmp];
                                     }
                                     
                                     //ソート対象となるキーを指定した、NSSortDescriptorの生成
                                     NSSortDescriptor *sortDescNumber;
                                     BOOL acc = YES;
                                     sortDescNumber = [[NSSortDescriptor alloc] initWithKey:@"month1" ascending:acc];
                                     
                                     // NSSortDescriptorは配列に入れてNSArrayに渡す
                                     NSArray *sortDescArray;
                                     sortDescArray = [NSArray arrayWithObjects:sortDescNumber, nil];
                                     
                                     // ソートの実行
                                     NSArray *sortArray;
                                     sortArray = [pdataList sortedArrayUsingDescriptors:sortDescArray];
                                     
                                     //NSLog(@"%@", lastdataList);
                                     [dic setObject:sortArray forKey:@"lastdataList"];
                                     
                                     NSLog(@"%@", lineTerm );
                                     NSLog(@"datalist count %d", [[dic objectForKey:@"dataList"] count]);
                                     NSLog(@"lastatalist count %d", [[dic objectForKey:@"lastdataList"] count]);
                                     
                                     //if([[dic objectForKey:@"dataList"] count]==[[dic objectForKey:@"lastdataList"] count]){
                                     // グラフ数チェック
                                     if(([lineTerm isEqualToString:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_YEARTERM"]] && ([[dic objectForKey:@"lastdataList"] count]==4))
                                        ||
                                        (![lineTerm isEqualToString:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_YEARTERM"]] && ([[dic objectForKey:@"lastdataList"] count]==3))
                                        )
                                     {
                                       // 折れ線グラフ
                                       [self addLineGraph:[dic objectForKey:@"dataList"] lastYearData:[dic objectForKey:@"lastdataList"] UIView:baseView tag:tag];
                                     }
                                     //}
                                   }];
  }
}

// 折れ線グラフ描画
-(void) addLineGraph:(NSMutableArray*)dataList lastYearData:(NSMutableArray*)lastdataList UIView:(UIView*)baseView tag:(NSString*)tag
{
  PublicDatas *pData = [PublicDatas instance];

  if([dataList count] != [lastdataList count]){
    [self performLineGraph:tag UIView:baseView];
    return;
  }
  NSLog(@"dataList %@", dataList);
  NSLog(@"lastdataList %@", lastdataList);
  
  // 既存グラフを消す
  for (UIView *view in [baseView subviews]) {
    //if(![view isMemberOfClass:[UIView class]]) continue;
    [view removeFromSuperview];
  }
  
  NSMutableDictionary *dic = [self getDictionaryByTag:tag];
  
  NSString *lineTerm = [dic objectForKey:@"lineTerm"];
  
  // 既存グラフを消す
  for (UIView *view in [baseView subviews]) {
    //if(![view isMemberOfClass:[UIView class]]) continue;
    [view removeFromSuperview];
  }
  
  NSMutableArray *titleArray = [[NSMutableArray alloc] init];
  NSMutableArray *yearArray = [[NSMutableArray alloc] init];
  NSMutableArray *valueArray = [[NSMutableArray alloc] init];
  for(int i=0; i<[dataList count]; i++){
    NSDictionary *tmp = [dataList objectAtIndex:i];
    [titleArray addObject:[tmp objectForKey:@"month"]];
    [yearArray addObject:[tmp objectForKey:@"year"]];
    [valueArray addObject:[NSNumber numberWithInt:[[tmp objectForKey:@"totalPrice"] intValue]]];
  }
  
  NSMutableArray *oldTitleArray = [[NSMutableArray alloc] init];
  NSMutableArray *oldYearArray = [[NSMutableArray alloc] init];
  NSMutableArray *oldvalueArray = [[NSMutableArray alloc] init];
  for(int i=0; i<[dataList count]; i++){
    NSDictionary *tmp = [lastdataList objectAtIndex:i];
    [oldTitleArray addObject:[tmp objectForKey:@"month"]];
    [oldYearArray addObject:[tmp objectForKey:@"year"]];
    [oldvalueArray addObject:[NSNumber numberWithInt:[[tmp objectForKey:@"totalPrice"] intValue]]];
  }
  
  
  //グラフ表示
  LineGrapth *salesGraph = [[LineGrapth alloc]initWithFrame:CGRectMake(0, 0, 300, 300)];
  
	//横軸ラベル
  if([lineTerm isEqualToString:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_YEARTERM"]]){
    titleArray = [[NSMutableArray alloc] initWithObjects:@"1Q", @"2Q",@"3Q", @"4Q", nil];
  }
	[salesGraph setXLblAry:titleArray];
  
	//データ名
  NSString *company_id = [pData getDataForKey:@"cp_company_id"];
  if(company_id!=nil && ![company_id isEqualToString:@""]){
    [salesGraph setNameAry:[NSMutableArray arrayWithObjects:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_TARGETALLOFFICE"],[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_TARGETCOFFICE"],nil]];
  }else{
    [salesGraph setNameAry:[NSMutableArray arrayWithObjects:[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_TARGETOFFICE"],[pData getDataForKey:@"DEFINE_DASHBOARD_TITLE_TARGETSELF"],nil]];
  }
  
	//グラフエリアのサイズ
	[salesGraph setBackgroundColor:[UIColor whiteColor]];
	salesGraph.graphSizeX = 220;
	salesGraph.graphSizeY = 220;
  
  NSLog(@"valueArray %@", valueArray);
  NSLog(@"oldvalueArray %@", oldvalueArray);
  
	//データ
	NSMutableArray *datAry = [NSMutableArray array];
	[datAry addObject:valueArray];
	[datAry addObject:oldvalueArray];
	[salesGraph setDatAry:datAry];
  
  int max1 = 0;
  int max2 = 0;
  int max1F = 0;
  int max2F = 0;
  @try{
    // 最大値
    NSPredicate *maxPred = [NSPredicate predicateWithFormat:
                            @"SELF == max:(%@)", valueArray];
    NSLog(@"%@", [valueArray filteredArrayUsingPredicate:maxPred]);
    max1 = [[[valueArray filteredArrayUsingPredicate:maxPred] objectAtIndex:0] intValue];
    
    // 桁数
    int digit = (int)log10( [[[NSNumber alloc]initWithInt:max1] doubleValue] ) + 1;
    
    float b = (float)(max1/pow(10, digit-1));
    max1F = ceil(b) * pow(10, digit-1);
    NSLog(@"max1 %d", max1F);
    
    maxPred = [NSPredicate predicateWithFormat:
               @"SELF == max:(%@)", oldvalueArray];
    NSLog(@"%@", [oldvalueArray filteredArrayUsingPredicate:maxPred]);
    max2 = [[[oldvalueArray filteredArrayUsingPredicate:maxPred] objectAtIndex:0] intValue]*2;
    
    NSLog(@"max2 %d", max2);
    // 桁数
    int _digit = (int)log10( [[[NSNumber alloc]initWithInt:max2] doubleValue] ) + 1;
    
    float _b = (float)(max2/pow(10, _digit-1));
    max2F = ceil(_b) * pow(10, _digit-1);;
    
    if(max2==0) max2F = 0;
    
    NSLog(@"max1F %d", max1F);
    NSLog(@"max2F %d", max2F);
    
    if(max1F<0) max1F =0;
    if(max2F<0) max2F =0;
    
    if(max1F<max2F) max1F = max2F;
    
    NSNumber *max1_1 = [[NSNumber alloc]initWithInt:max1F];
    NSNumber *max2_1 = [[NSNumber alloc]initWithInt:max2F];
    NSMutableArray *maxArray = [NSMutableArray arrayWithObjects:max1_1,max2_1, nil];
    [salesGraph setMaxValAry:maxArray];
  }
  @catch (NSException *exception) {
    NSLog(@"%d", __LINE__);
    NSLog(@"main:Caught %@:%@", [exception name], [exception reason]);
  }
  
  //区切り数
	salesGraph.y_section = 4;
	salesGraph.backgroundColor = [UIColor whiteColor];
	[baseView addSubview:salesGraph];
  
  
  [dic setObject:[[NSMutableArray alloc]init] forKey:@"dataList"];
  [dic setObject:[[NSMutableArray alloc]init] forKey:@"lastdataList"];
  
  /*
   lineMonth 開始付月
   lineItem @"売上", @"商談数"
   lineTerm @"年間", @"四半期", @"前四半期"
   */
  
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
  [titleLabel setFrame:CGRectMake((baseView.frame.size.width-titleLabel.frame.size.width)/2, -10,300,40)];
  titleLabel.numberOfLines = 2;
  titleLabel.text = [NSString stringWithFormat:@"%@ %@\n",[dic objectForKey:@"lineItem"],[dic objectForKey:@"lineTerm"]];
  titleLabel.font = [UIFont systemFontOfSize:14.0];
  titleLabel.textAlignment = NSTextAlignmentCenter;
  titleLabel.backgroundColor = [UIColor clearColor];
  [baseView addSubview:titleLabel];
  
}



@end
