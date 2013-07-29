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


#import "ChatterViewController+Util.h"

@implementation ChatterViewController (Util)



// ローディングアラートの表示
-(void)alertShow
{
	[NSTimer scheduledTimerWithTimeInterval:30.0f
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

-(void)alertClose
{
  if(!alertView.visible) return;
  
  [alertView dismissWithClickedButtonIndex:0 animated:NO];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
	//スクロール領域を元に戻す
	CGPoint pt = CGPointMake( scrl.contentOffset.x , scrl.contentOffset.y - moveValue );
	[scrl setContentOffset:pt animated:YES];
	CGSize area = CGSizeMake( scrl.contentSize.width, scrl.contentSize.height - moveValue);
	scrl.contentSize = area;
  
  NSString *isKeyboard = @"NO";
  pData  = [PublicDatas instance];
  [pData  setData:isKeyboard forKey:@"isKeyboard"];
}

// キーボードを閉じる
-(void) keyboardWillShow:(NSNotification*)notification
{
  NSString *isKeyboard = @"YES";
  pData = [PublicDatas instance];
  [pData setData:isKeyboard forKey:@"isKeyboard"];
}


-(NSString*)stringReplacement:(NSString*)src
{
  if(src == nil || [src isEqual:[NSNull null]]){
    return src;
  }
  @try {
    src = [src stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    src = [src stringByReplacingOccurrencesOfString:@"&#39" withString:@"'"];
    src = [src stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    src = [src stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    src = [src stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
  }
  @catch (NSException *exception) {
    //NSLog(@"name  :%@",exception.name);
    //NSLog(@"reason:%@",exception.reason);
  }
	
	return src;
}

//オブジェクトがNULLであるかチェック
-(BOOL)isNull:(id)tgt
{
	if ((( tgt == [NSNull null] ) || ([tgt isEqual:[NSNull null]] ) || ( tgt ==  nil ))){
		return YES;
	}
	return NO;
}

-(void)clearSubView:(UIView*)tgt
{
	//取得済みFeedをクリア
	for (UIView *view in [tgt subviews]) {
		[view removeFromSuperview];
	}
}

//タイムゾーン変換処理
-(NSString*)conv2Tz:(NSString*)src
{
	NSString *srcDate = [src substringToIndex:10];
	NSString *srcTime = [src substringWithRange:NSMakeRange(11,8)];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-ddHH:mm:ssZZZZ"];
	NSDate *pubDate = [formatter dateFromString:[[srcDate stringByAppendingString:srcTime]stringByAppendingString:@"+0000"]];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Tokyo"]];
	[dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
	NSString * ret = [dateFormatter stringFromDate:pubDate];
	return ret;
}

//UIImage:imgがRectより大きい場合リサイズする
-(id)resizeImage:(UIImage*)img Rect:(CGRect)Rect
{
	if (( img.size.height > Rect.size.height) || ( img.size.width > Rect.size.width)) {
		//NSLog(@"%f : %f",img.size.width,img.size.height);
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

//TextViewデリゲート
-(BOOL)textViewShouldEndEditing:(UITextView*)textView
{
	return YES;
}

-(BOOL)textViewShouldBeginEditing:(UITextView*)textView
{
  
	//スクロール位置を保存
	float pos = [textView superview].frame.origin.y - scrl.contentOffset.y ;
	moveValue = 0;
	if ( pos > 11) {
		moveValue = pos - 11;
	}
	
	//スクロール領域を広げる
	CGSize area = CGSizeMake( scrl.contentSize.width, scrl.contentSize.height + moveValue);
	scrl.contentSize = area;
	
	//キーボードに隠れないようスクロールする
	CGPoint pt = CGPointMake( scrl.contentOffset.x , scrl.contentOffset.y + moveValue );
	[scrl setContentOffset:pt animated:YES];
	
	return YES;
}
-(void)textViewDidChange:(UITextView *)textView
{
	NSString *tag = [NSString stringWithFormat:@"%d",textView.tag];
	
  //コメント内容を保存
	[commentArray setObject:textView.text forKey:tag];
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
	NSHTTPURLResponse *httpurlResponse = (NSHTTPURLResponse *)response;
  NSLog(@"response -> %d", [httpurlResponse statusCode]);
	[rcvData setLength:0];
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
	NSLog(@"receive data");
	[rcvData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	NSLog(@"Connection failed! Error - %@ %@",
        [error localizedDescription],
        [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"Succeeded! Received %d bytes of data",[rcvData length]);
	NSLog(@"%@", [[NSString alloc]initWithData:rcvData
                                    encoding:NSUTF8StringEncoding]);
}

@end
