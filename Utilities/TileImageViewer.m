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


#import "TileImageViewer.h"

@implementation TileImageViewer
//@synthesize imgArray,
//			index;

const float MAX_X = 940;
const float MAX_Y = 650;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

//	float orgX = ( 1024 - MAX_X ) / 2;
//	float orgY = ( 768 - MAX_Y ) / 2;
	
	UIView *base = [[UIView alloc]initWithFrame:CGRectMake( 0, 0, 1024, 700)];
	pictureFrame = [[UIView alloc]initWithFrame:CGRectMake( 0, 0, 1024, 700)];
	[base setBackgroundColor:[UIColor clearColor]];
	[pictureFrame setBackgroundColor:[UIColor whiteColor]];

	imgV = [[UIImageView alloc]init];
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(detectTap)];
	UISwipeGestureRecognizer *swipeGestureR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(detectSwipRight)];
	UISwipeGestureRecognizer *swipeGestureL = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(detectSwipLeft)];
	swipeGestureL.direction = UISwipeGestureRecognizerDirectionLeft;
	swipeGestureR.direction = UISwipeGestureRecognizerDirectionRight;
	swipeGestureL.delegate = self;
	swipeGestureR.delegate = self;
	tapGesture.delegate = self;
	imgV.userInteractionEnabled = YES;
	base.userInteractionEnabled = YES;
	[imgV addGestureRecognizer:swipeGestureR];
	[imgV addGestureRecognizer:swipeGestureL];
	[base addGestureRecognizer:tapGesture];
	[base addSubview:pictureFrame];
	[base addSubview:imgV];
	[self addSubview:base];
	self.frame = base.frame;
	self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	CGRect Rct = CGRectMake(0, 0, MAX_X, MAX_Y);
	UIImage *img = [self.imgArray objectAtIndex:_index];
	UIImage *resize = [self resizeImage:img Rect:Rct];
	Rct.origin.x = ( 1024 - resize.size.width ) / 2;
	Rct.origin.y = ( 700 - resize.size.height) / 2;
	Rct.size.width = resize.size.width;
	Rct.size.height = resize.size.height;
	imgV.frame = Rct;
	imgV.image = img;

	Rct.origin.x -= 10;
	Rct.origin.y -= 10;
	Rct.size.height += 20;
	Rct.size.width += 20;
	pictureFrame.frame = Rct;
	
}
-(void)detectTap
{
	if ([self.delegate respondsToSelector:@selector(didDetectTap)]){
		[self.delegate didDetectTap];
	}
}

-(void)detectSwipLeft
{
	if ( ++_index >= [_imgArray count]){
		_index = [_imgArray count] - 1;
	}
	CGRect Rct = CGRectMake(0, 0, MAX_X, MAX_Y);
	UIImage *img = [self.imgArray objectAtIndex:_index];
	UIImage *resize = [self resizeImage:img Rect:Rct];
	Rct.origin.x = ( 1024 - resize.size.width ) / 2;
	Rct.origin.y = ( 700 - resize.size.height) / 2;
	Rct.size.width = resize.size.width;
	Rct.size.height = resize.size.height;
	imgV.frame = Rct;
	imgV.image = img;
	[self drawRect:self.frame];
}
-(void)detectSwipRight
{
	if ( --_index < 0 ){
		_index = 0;
	}
	CGRect Rct = CGRectMake(0, 0, MAX_X, MAX_Y);
	UIImage *img = [self.imgArray objectAtIndex:_index];
	UIImage *resize = [self resizeImage:img Rect:Rct];
	Rct.origin.x = ( 1024 - resize.size.width ) / 2;
	Rct.origin.y = ( 700 - resize.size.height) / 2;
	Rct.size.width = resize.size.width;
	Rct.size.height = resize.size.height;
	imgV.frame = Rct;
	imgV.image = img;
	[self drawRect:self.frame];
}




//UIImage:imgがRectより大きい場合リサイズする
-(id)resizeImage:(UIImage*)img Rect:(CGRect)Rect
{
	if (( img.size.height > Rect.size.height) || ( img.size.width > Rect.size.width)) {
		NSLog(@"%f : %f",img.size.width,img.size.height);
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
@end
