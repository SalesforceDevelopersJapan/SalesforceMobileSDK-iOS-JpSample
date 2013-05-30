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


#import "ChatterViewController+Preview.h"

@implementation ChatterViewController (Preview)

//添付ファイルのプレビュー
-(void)previewAttach :(id)sender
{
	UIButton *wrkBtn = (UIButton*)sender;
	NSString *tag = [NSString stringWithFormat:@"%d",wrkBtn.tag];
  
	NSData *attachData = [upFileArray objectForKey:tag];
  
	if( [attachData length]){
		UIImage *img = [UIImage imageWithData:attachData];
		UIImageView *iv = [[UIImageView alloc]init];
    
		CGRect rect;
		if (( img.size.width >= 200 ) || ( img.size.height >= 200)) {
			float asp = (float)img.size.width / (float)img.size.height;
			if ( img.size.height >= img.size.width ) {
				rect.size.height = 200;
				rect.size.width = 200 * asp;
			}
			else {
				rect.size.width = 200;
				rect.size.height = 200 / asp;
			}
		}
		else {
			rect.size = img.size;
		}
		rect.origin.x = 0;
		rect.origin.y = 0;
		iv.frame = rect;
		iv.image = img;
   
		[btnBuilder dismissMenu];
		PreviewViewController *pv = [[PreviewViewController alloc]init];
		pv.delegate = self;
		[pv setWithCancelBtn:YES];
		[pv setContents:iv];
		
		pop = [[UIPopoverController alloc]initWithContentViewController:pv];
		[pop presentPopoverFromRect:wrkBtn.frame inView:[wrkBtn superview] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
}






@end
