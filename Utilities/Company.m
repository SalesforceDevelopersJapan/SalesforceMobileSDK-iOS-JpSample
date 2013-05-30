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

#import "Company.h"
#import "PublicDatas.h"

@implementation Company

-(id)init
{
	self = [super init];
	if ( self != nil){
		_company_id = @"";
		_name = @"";
		_Address1 = @"";
		_Address2 = @"";
		_phone1 = @"";
		_phone2 = @"";
		//_yearSales = 0;
    _yearSales = (double)0;
		_employee = 0;
		_visitCount = 0;
		_opportunityCount = 0;
	}
   return self;
}

//取引先IDで基本情報を検索
-(void)getCompanyInfoFromId
{
	//クエリ作成
	NSString *query1 = @"SELECT Account__r.Id, Account__r.Name, Account__r.Phone, Account__r.BillingState, Account__r.BillingCity, Account__r.BillingStreet, LatNum__c, LngNum__c,  Account__r.status__c ";
	NSString *query2 = [NSString stringWithFormat:@"FROM LatLngObj__c WHERE Account__r.Id='%@'",self.company_id];
	NSString *query = [query1 stringByAppendingString:query2];
	
	
	NSLog(@"%@",query);
	inWait = YES;
	
	[[SFRestAPI sharedInstance] performSOQLQuery:query
	 //エラーハンドラ
									   failBlock:^(NSError *e) {
										   NSLog(@"FAILWHALE with error: %@", [e description] );
										   inWait = NO;
									   }
	 //受信ハンドラ
								   completeBlock:^(NSDictionary *results) {
									   
									   NSLog(@"%@",results);
									   
									   //受信データから各項目を抽出
									   //		 NSString *tsize = [results objectForKey:@"totalSize"];
									   //		 if ( ![tsize isEqualToString:@"0"]){
									   
									   NSArray *records = [results objectForKey:@"records"];
									   NSDictionary *dict = [records objectAtIndex:0];
									   NSDictionary *dic = [dict objectForKey:@"Account__r"];
									   NSString *billingCity = [dic objectForKey:@"BillingCity"];
									   NSString *billingStreet = [dic objectForKey:@"BillingStreet"];
									   NSString *billingState = [dic objectForKey:@"BillingState"];
									   NSString *aname = [dic objectForKey:@"Name"];
									   NSString *phone = [dic objectForKey:@"Phone"];
									   NSString *address = [billingState stringByAppendingString:billingCity];
									   double lat = [[dict objectForKey:@"LatNum__c"]floatValue];
									   double lng = [[dict objectForKey:@"LngNum__c"]doubleValue];
									   self.Address1 = address;
									   self.Address2 = billingStreet;
									   self.phone1 = phone;
									   self.name = aname;
									   self.position = CLLocationCoordinate2DMake(lat, lng);
									   NSString *status = [dic objectForKey:@"status__c"];
									   
									   if (status != nil && ![status isEqual:[NSNull null]]) {
										   if([status isEqual:@"SalesUp"]){
											   self.salesStatus = SALES_UP;
										   }else if([status isEqual:@"SalesDown"]){
											   self.salesStatus = SALES_DOWN;
										   }else{
											   self.salesStatus = SALES_FLAT;
										   }
									   }else{
										   self.salesStatus = SALES_FLAT;
									   }
									   
									   inWait = NO;
									   
									   //受信完了を通知
									   if ([self.delegate respondsToSelector:@selector(didCompanyInfoReceived:)]){
										   [self.delegate didCompanyInfoReceived:self];
									   }
									   //		 }
									   //		 else {
									   //
									   //			 //異常データの場合
									   //			 if ([self.delegate respondsToSelector:@selector(didInvalidCompanyInfoReceived)]){
									   //				 [self.delegate didInvalidCompanyInfoReceived];
									   //			 }
									   //		 }
								   }];
	
	//受信完了まで待つ
	while (inWait == YES){
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
	}
}



@end
