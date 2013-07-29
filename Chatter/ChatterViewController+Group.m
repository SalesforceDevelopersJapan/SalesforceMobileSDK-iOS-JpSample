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



#import "ChatterViewController+Group.h"
#import "ChatterViewController+Util.h"
#import "UtilManager.h"
#import "Person.h"
#import "PinDefine.h"

@implementation ChatterViewController (Group)


//グループの説明を取得する
-(void)getGroupDedcription
{
  
	if (([currentGroup isEqualToString:@"Follow"]) ||
      ([currentGroup isEqualToString:@"toMe"]) ||
      ([currentGroup isEqualToString:@"bookMark"]) ||
      ([currentGroup isEqualToString:@"AllOfCompany"])){
//		self.descriptionLabel.text = @"About Me";
		self.descriptionLabel.text = [pData getDataForKey:@"DEFINE_CHATTER_LABEL_ABOUTME"];
		if (![self isNull:myInfo.description]) {
			self.descriptionTextView.text = [self stringReplacement:myInfo.description];
		}
		return;
	}
	
	
	NSString *path = [NSString stringWithFormat:@"v27.0/chatter/groups/%@",currentGroup];
	SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodGET path:path queryParams:nil];
	
	[[SFRestAPI sharedInstance] sendRESTRequest:req failBlock:^(NSError *e) {
		NSLog(@"FAILWHALE with error: %@", [e description] );
		self.descriptionTextView.text= @"";
	}
                                completeBlock:^(id jsonResponse){
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  
                                  NSString *description = [dict objectForKey:@"description"];
                                  if (![self isNull:description]) {
                                    self.descriptionTextView.text = [self stringReplacement:description];
                                  }
                                  else {
                                    self.descriptionTextView.text= @"";
                                  }
                                  
								  self.descriptionLabel.text = [pData getDataForKey:@"DEFINE_CHATTER_LABEL_DESCRIPTION"];
                                
                                  //グループ名取得
                                  [titleLabel setText:[[dict objectForKey:@"name"]stringByAppendingString:@" - Chatter"]];
                                  [titleLabel sizeToFit];
                                  
                                  //画像取得
                                  NSDictionary *photo = [dict objectForKey:@"photo"];
                                  NSString *fullEmailPhotoUrl = [photo objectForKey:@"fullEmailPhotoUrl"];
                                  NSURL *url = [NSURL URLWithString:fullEmailPhotoUrl];
                                  NSData *data = [NSData dataWithContentsOfURL:url];
                                  UIImage *image = [[UIImage alloc] initWithData:data];
                                  
                                  
                                  //ロゴ表示
                                  UIImage *resize = [self resizeImage:image Rect:self.groupImageView.frame];
                                  
                                  float asp = resize.size.height / resize.size.width;
                                  CGRect rect = self.groupImageView.frame;
                                  
                                  rect.size.height = rect.size.width * asp;
                                  self.groupImageView.frame = rect;
                                  self.groupImageView.image = resize;
                                  
                                  um = [UtilManager sharedInstance];
                                  CGSize size = CGSizeMake(5.0, 5.0);
                                  [um makeViewRound:self.groupImageView corners:UIRectCornerAllCorners size:&size];
                                  
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
                                  
                                  
                                }];
}

-(void)memberBtnPushed:(id)sender
{
  [pop dismissPopoverAnimated:YES];
  
	UIButton *wrkBtn = (UIButton*)sender;
	//使用フォント
	UIFont *font = [UIFont systemFontOfSize:14.0];
  
	Person *pr = [memberList objectAtIndex:wrkBtn.tag];
	UIView *baseView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 170, 70)];
	baseView.backgroundColor = [UIColor blackColor];
	
	UIImageView *img = [[UIImageView alloc]initWithImage:pr.img];
	img.frame = CGRectMake(5, 5, 50, 50);
  
	UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(60, 20, 100 , 20)];
	[name setText:pr.name];
	[name setFont:font];
	[name setTextColor:[UIColor whiteColor]];
	[name setBackgroundColor:[UIColor clearColor]];
	[name sizeToFit];
	
	[baseView addSubview:img];
	[baseView addSubview:name];
	
	PreviewViewController *pv = [[PreviewViewController alloc]init];
	[pv setContents:baseView];
	
	pop = [[UIPopoverController alloc]initWithContentViewController:pv];
	[pop presentPopoverFromRect:wrkBtn.frame inView:[wrkBtn superview] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
  
}


//グループ初期選択
-(void)selectDefaultGroup
{
  
	//前回選択したグループを選択する
	um = [UtilManager sharedInstance];
	currentGroup =[um selectGroup];
	if ([currentGroup length] && self.chatterType == ENUM_CHATTERME ) {
		[self didSelectGroup:currentGroup];
		return;
	}
	
	//
	//前回選択が取得出来なければ、会社名を含むグループを自動選択
	//
	
	//リクエスト作成
	NSString *path = @"v27.0/chatter/users/me/groups";
	SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodGET path:path queryParams:nil];
	
	//GET実行
	[[SFRestAPI sharedInstance] sendRESTRequest:req failBlock:^(NSError *e) {
		NSLog(@"FAILWHALE with error: %@", [e description] );
		// アラートを閉じる
		if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
	}
                                completeBlock:^(id jsonResponse){
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  //NSLog(@"dict::%@",dict);
                                  NSMutableArray *groups = [dict objectForKey:@"groups"];
                                  BOOL defaultFound = NO;
                                  for ( int i = 0; i < [groups count]; i++){
                                    
                                    //グループを取得
                                    NSMutableDictionary *grp = [groups objectAtIndex:i];
                                    
                                    //グループ名
                                    NSString *name = [grp objectForKey:@"name"];
                                    
                                    //グループID
                                    NSString *gId = [grp objectForKey:@"id"];
                                    
                                    //前回選択が無ければ、会社名を含むグループがあればそれを初期選択する
                                    @try{
                                      if (([name length])&&([myInfo.company length ])){
                                        NSRange range = [name rangeOfString:myInfo.company];
                                        if (range.location != NSNotFound) {
                                          currentGroup = gId;
                                          [self didSelectGroup:currentGroup];
                                          defaultFound = YES;
                                          break;
                                        }
                                      }
                                    }
                                    @catch (NSException *exception)
                                    {
                                      //NSLog(@"name  :%@",exception.name);
                                      //NSLog(@"reason:%@",exception.reason);
                                    }
                                  }
                                  
                                  //デフォルトグループ無し
                                  if ( defaultFound == NO) {
                                    // アラートを閉じる
                                    if(alertView.visible) [alertView dismissWithClickedButtonIndex:0 animated:NO];
                                  }
                                }];
}


@end
