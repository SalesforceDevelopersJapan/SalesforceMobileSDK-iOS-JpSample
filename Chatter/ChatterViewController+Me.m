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


#import "ChatterViewController+Me.h"
#import "ChatterViewController+Util.h"
#import "ChatterViewController+Group.h"
#import "UtilManager.h"
#import "Person.h"

@implementation ChatterViewController (Me)

//自身のUserIDを取得
-(void)getMyId
{
	//リクエスト作成
	NSString *path = @"v27.0/chatter/users/me";
	SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodGET path:path queryParams:nil];
	
	//GET実行
	[[SFRestAPI sharedInstance] sendRESTRequest:req failBlock:^(NSError *e) {
		NSLog(@"FAILWHALE with error: %@", [e description] );
	}
   
                                completeBlock:^(id jsonResponse){
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  NSLog(@"%@",dict);
                                  myInfo = [[Person alloc]init];
                                  myInfo.userId = [dict objectForKey:@"id"];
                                  myInfo.company = [dict objectForKey:@"companyName"];
                                  myInfo.description = [dict objectForKey:@"aboutMe"];
                                  //		NSLog(@"dict::%@",dict);
                                  
                                  
                                  @try {
                                    if ( [currentGroup length] == 0 ){
                                      //グループ初期選択
                                      [self selectDefaultGroup];
                                    }
                                  }
                                  @catch (NSException *exception)
                                  {
                                    NSLog(@"name  :%@",exception.name);
                                    NSLog(@"reason:%@",exception.reason);
                                  }
                                  
                                  if ( myInfo.company == ( NSString *)[NSNull null]){
                                    myInfo.company = @"";
                                  }
                                  if (([currentGroup isEqualToString:@"Follow"]) ||
                                      ([currentGroup isEqualToString:@"toMe"]) ||
                                      ([currentGroup isEqualToString:@"bookMark"]) ||
                                      ([currentGroup isEqualToString:@"AllOfCompany"]) ||
                                      ([currentGroup length] == 0 )) {
									  self.descriptionLabel.text = [pData getDataForKey:@"DEFINE_CHATTER_LABEL_ABOUTME"];
                                    NSString *tmpDesc = [self stringReplacement:myInfo.description];
                                    if (![self isNull:tmpDesc]) {
                                      self.descriptionTextView.text = tmpDesc;
                                    }
                                    else {
                                      self.descriptionTextView.text = @"";
                                    }
                                    return;
                                  }
                                }];
}

//自分のアカウントの写真を取得
-(void)getMyImage
{
	// トークンを取得
  NSString *access_token = [[[[SFRestAPI sharedInstance]coordinator]credentials]accessToken];
  NSLog(@"access_token %@", access_token);
  
  // 認証したユーザー情報にアクセス
  SFAccountManager *sm = [SFAccountManager sharedInstance];
	
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
   ^(NSURLResponse *res, NSData *data, NSError *error)
   {
     @try
     {
       // 取得したデータ
       if ( data ) {
				 
         // 画像として画面に表示
         UIImage *img = [UIImage imageWithData:data];
				 
         //取得画像にUIImageViewの縦横比をあわせる
         float asp = img.size.height / img.size.width;
         CGRect rect = self.groupImageView.frame;
         rect.size.height = rect.size.width * asp;
         self.groupImageView.frame = rect;
         self.groupImageView.image = img;
         
         um = [UtilManager sharedInstance];
         CGSize size = CGSizeMake(5.0, 5.0);
         [um makeViewRound: self.groupImageView corners:UIRectCornerAllCorners size:&size];
         
         //Description Label位置調整
         rect= self.descriptionLabel.frame;
         rect.origin.y = self.groupImageView.frame.origin.y + self.groupImageView.frame.size.height+20;
         self.descriptionLabel.frame = rect;
         
         //Description設定
         if([self.descriptionTextView.text isEqual: @""]){
           NSString *desc = [self.initialCompnay.name stringByAppendingString:[pData getDataForKey:@"DEFINE_CHATTER_LABEL_ABOUTCAHT"]];
           self.descriptionTextView.text = [self stringReplacement:desc];
         }
         rect = self.descriptionTextView.frame;
         rect.origin.y = self.descriptionLabel.frame.origin.y + self.descriptionLabel.frame.size.height + 10;
         self.descriptionTextView.frame = rect;
         
         
       }
       if(error){
         NSLog(@"error %@", error);
       }
     }
		 
     @catch (NSException *exception)
     {
       NSLog(@"main:Caught %@:%@", [exception name], [exception reason]);
     }
     @finally {
     }
   }
   ];
}


@end
