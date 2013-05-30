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

#import "UIBarButtonItem+DesignedButton.h"
#import "UtilManager.h"

@implementation UIBarButtonItem (DesignedButton)

- (UIBarButtonItem *)designedBackBarButtonItemWithTitle:(NSString *)title type:(int)kind target:(id)target action:(SEL)selector
{
	
    // 通常時の画像と押された時の画像を用意する
	UIImage *image;
	UIImage *highlightedImage;
	UtilManager *um = [UtilManager sharedInstance];

	if ( kind == 1 ){
		UIImage *img = [UIImage imageNamed:@"BackIcon.png"];
		image = img;
		highlightedImage = img;
	}
	else {
//		NSData *iData =[[NSUserDefaults standardUserDefaults]objectForKey:@"backBtnImage"];
		NSData *iData =[um backBtnImage];
		if ( iData ) {
			UIImage *img = [UIImage imageWithData:iData];
			image = img;
			highlightedImage = img;
			NSLog(@"%f:%f",img.size.width,img.size.height);
		}
	}

	
/*
    else {
		image = [UIImage imageNamed:@"backButton.png"];
		highlightedImage = [UIImage imageNamed:@"backButton.png"];
    }
*/
	
	
	// 左右 17px 固定で引き伸ばして利用する
 //   image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 17.f, 0, 17.f)];
 //   highlightedImage = [highlightedImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 17.f, 0, 17.f)];
	
    // 表示する文字に応じてボタンサイズを変更する
    UIFont *font = [UIFont boldSystemFontOfSize:12.f];
    CGSize textSize = [title sizeWithFont:font];
	
	CGSize buttonSize;
	if ( image.size.height >= 40 ){
		double asp = image.size.width / image.size.height;
		buttonSize.height = 40;
		buttonSize.width = buttonSize.height * asp;
	}
	else {
		buttonSize = CGSizeMake(textSize.width + 24.f, image.size.height);
	}
	
//	CGSize buttonSize = CGSizeMake(textSize.width + 24.f, image.size.height);
	
	
    // ボタンを用意する
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, buttonSize.width, buttonSize.height)];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
	
	
    // ラベルを用意する
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(4.f, 0.f, buttonSize.width, buttonSize.height)];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    label.font = font;
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    label.shadowOffset = CGSizeMake(0.f, 1.f);
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    [button addSubview:label];
    
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

@end