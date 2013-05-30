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


#import "ItemBadge.h"

@implementation ItemBadge


- (NSArray*)gradientArrayWithHue:(float)hue_
                      saturation:(float)saturation
                      brightness:(float)brightness
{
  UIColor *halationTop = [UIColor colorWithHue:hue_
                                    saturation:saturation * 0.2
                                    brightness:brightness
                                         alpha:1];
  UIColor *halationBottom = [UIColor colorWithHue:hue_
                                       saturation:saturation * 0.8
                                       brightness:brightness * 0.8
                                            alpha:1];
  UIColor *normalTop = [UIColor colorWithHue:hue_
                                  saturation:saturation
                                  brightness:brightness * 0.8
                                       alpha:1];
  UIColor *normalBottom = [UIColor colorWithHue:hue_
                                     saturation:saturation
                                     brightness:brightness
                                          alpha:1];
  
  NSMutableArray *colors = [NSArray arrayWithObjects:
                            (__bridge id)[halationTop CGColor],
                            (__bridge  id)[halationBottom CGColor],
                            (__bridge id)[normalTop CGColor],
                            (__bridge id)[normalBottom CGColor], nil];
  
  return colors;
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    internalButton = [CAGradientLayer layer];
    internalButton.frame = self.bounds;
    internalButton.borderWidth = 2;
    internalButton.borderColor = [UIColor whiteColor].CGColor;
    internalButton.shadowOffset = CGSizeMake(0, 0);
    internalButton.shadowOpacity = 0.8;
    internalButton.cornerRadius = self.bounds.size.height / 2.0;
    NSMutableArray *locations = [NSArray arrayWithObjects:
                                 [NSNumber numberWithFloat:0.0],
                                 [NSNumber numberWithFloat:0.5],
                                 [NSNumber numberWithFloat:0.5],
                                 [NSNumber numberWithFloat:1.0],nil];
    [internalButton setLocations:locations];
    [internalButton setColors:[self gradientArrayWithHue:_hue saturation:1 brightness:1]];
    [self.layer addSublayer:internalButton];
    _textLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _textLabel.font = [UIFont boldSystemFontOfSize:18];
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.shadowColor = [UIColor grayColor];
    _textLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_textLabel];
  }
  return self;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
