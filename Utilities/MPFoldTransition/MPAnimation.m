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


#import "MPAnimation.h"
#import <QuartzCore/QuartzCore.h>

@implementation MPAnimation

// Generates an image from the view (view must be opaque)
+ (UIImage *)renderImageFromView:(UIView *)view
{
	return [self renderImageFromView:view withRect:view.bounds];
}

// Generates an image from the (opaque) view where frame is a rectangle in the view's coordinate space.
// Pass in bounds to render the entire view, or another rect to render a subset of the view
+ (UIImage *)renderImageFromView:(UIView *)view withRect:(CGRect)frame
{
    // Create a new context of the desired size to render the image
	UIGraphicsBeginImageContextWithOptions(frame.size, YES, 0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Translate it, to the desired position
	CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y);
    
    // Render the view as image
    [view.layer renderInContext:context];
    
    // Fetch the image   
    UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Cleanup
    UIGraphicsEndImageContext();
    
    return renderedImage;
}

// Generates an image from the view with transparent margins.
// (CGRect)frame is a rectangle in the view's coordinate space- pass in bounds to render the entire view, or another rect to render a subset of the view
// (UIEdgeInsets)insets defines the size of the transparent margins to create
+ (UIImage *)renderImageFromView:(UIView *)view withRect:(CGRect)frame transparentInsets:(UIEdgeInsets)insets
{
	CGSize imageSizeWithBorder = CGSizeMake(frame.size.width + insets.left + insets.right, frame.size.height + insets.top + insets.bottom);
    // Create a new context of the desired size to render the image
	UIGraphicsBeginImageContextWithOptions(imageSizeWithBorder, UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsetsZero), 0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Clip the context to the portion of the view we will draw
	CGContextClipToRect(context, (CGRect){{insets.left, insets.top}, frame.size});
	// Translate it, to the desired position
     CGContextTranslateCTM(context, -frame.origin.x + insets.left, -frame.origin.y + insets.top);
    
    // Render the view as image
    [view.layer renderInContext:context];
    
    // Fetch the image   
    UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Cleanup
    UIGraphicsEndImageContext();
    
    return renderedImage;
}

// Generates a copy of the image with a 1 point transparent margin around it
+ (UIImage *)renderImageForAntialiasing:(UIImage *)image
{
	return [self renderImageForAntialiasing:image withInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
}

// Generates a copy of the image with transparent margins of size defined by the insets parameter
+ (UIImage *)renderImageForAntialiasing:(UIImage *)image withInsets:(UIEdgeInsets)insets
{
	CGSize imageSizeWithBorder = CGSizeMake([image size].width + insets.left + insets.right, [image size].height + insets.top + insets.bottom);
	
	// Create a new context of the desired size to render the image
	UIGraphicsBeginImageContextWithOptions(imageSizeWithBorder, UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsetsZero), 0);
	
	// The image starts off filled with clear pixels, so we don't need to explicitly fill them here	
	[image drawInRect:(CGRect){{insets.left, insets.top}, [image size]}];
	
    // Fetch the image   
    UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return renderedImage;
}


@end
