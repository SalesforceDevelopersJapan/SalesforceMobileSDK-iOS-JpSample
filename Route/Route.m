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




#import "Route.h"

@implementation Route

-(id)init
{
	self = [super init];
	if ( self != nil){
    
	}
  return self;
}

// ルート情報を検索
-(void)getRouteList
{
  pData = [PublicDatas instance];
  um = [UtilManager sharedInstance];
  list = [[NSMutableArray alloc]init];;
  
  //クエリ作成
  NSString *query = @"SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate FROM RouteMst__c";
  
  [[SFRestAPI sharedInstance] performSOQLQuery:query
   //エラーハンドラ
                                     failBlock:^(NSError *e) {
                                       NSLog(@"FAILWHALE with error: %@", [e description] );
                                       UIAlertView *failAlert = [[UIAlertView alloc]
                                                        initWithTitle:nil
                                                        message:[pData getDataForKey:@"DEFINE_ROUTE_SEARCHFAILED"]
                                                        delegate:self
                                                        cancelButtonTitle:nil
                                                        otherButtonTitles:[pData getDataForKey:@"DEFINE_ROUTE_ALERTOK"], nil ];
                                       
                                       [failAlert show];
                                     }
	 //受信ハンドラ
                                 completeBlock:^(NSDictionary *results) {
                                   NSArray *records = [results objectForKey:@"records"];
                                   NSLog(@"request:didLoadResponse: #records: %d", records.count);
                                   
                                   for ( NSDictionary *obj in records ) {
                                     [list addObject:obj];
                                   }
                                 }];
  //NSLog(@"list %@",list);
}

-(NSMutableArray *)getList
{
  return list;
}

// ルート以下の情報を検索
-(void)getRouteTrnList:(NSString*)Id
{
  um = [UtilManager sharedInstance];
  trnlist = [[NSMutableArray alloc]init];;
  
  //クエリ作成
  NSString *query1 = @"SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, order__c, account__c, duplicatecheck__c, RouteMst__c, duplicatecheck_m__c ";
	NSString *query2 = [NSString stringWithFormat:@"FROM RouteTrn__c WHERE RouteMst__c = '%@'",Id];
	NSString *query = [query1 stringByAppendingString:query2];
  
  NSLog(@"%@",query);
  
  [[SFRestAPI sharedInstance] performSOQLQuery:query
   //エラーハンドラ
                                     failBlock:^(NSError *e) {
                                       NSLog(@"FAILWHALE with error: %@", [e description] );
                                       UIAlertView *failAlert = [[UIAlertView alloc]
                                                                 initWithTitle:nil
                                                                 message:[pData getDataForKey:@"DEFINE_ROUTE_SEARCHFAILED"]
                                                                 delegate:self
                                                                 cancelButtonTitle:nil
                                                                 otherButtonTitles:[pData getDataForKey:@"DEFINE_ROUTE_ALERTOK"], nil ];
                                       
                                       [failAlert show];
                                     }
	 //受信ハンドラ
                                 completeBlock:^(NSDictionary *results) {
                                   
                                   NSArray *records = [results objectForKey:@"records"];
                                   NSLog(@"request:didLoadResponse: #records: %d", records.count);
                                   
                                   for ( NSDictionary *obj in records ) {
                                     [trnlist addObject:[obj valueForKey:@"Id"]];
                                   }
                                   
                                 }];
}

-(NSMutableArray*)getTrnList
{
  return trnlist;
}

@end
