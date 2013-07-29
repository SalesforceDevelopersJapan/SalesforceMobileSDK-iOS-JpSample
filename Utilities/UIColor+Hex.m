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


#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (UIColor *)colorWithHex:(NSString *)colorCode
{
  return [UIColor colorWithHex:colorCode alpha:1.0];
}

+ (UIColor *)colorWithHex:(NSString *)colorCode alpha:(CGFloat)alpha
{
  if ([[colorCode substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"#"]) {
    colorCode = [colorCode substringWithRange:NSMakeRange(1, colorCode.length - 1)];
  }
  
  if ([colorCode length] == 3) {
    NSMutableString *_colorCode = [[NSMutableString alloc] init];
    
    for (NSInteger i = 0; i < colorCode.length; i++) {
      [_colorCode appendString:[colorCode substringWithRange:NSMakeRange(i, 1)]];
      [_colorCode appendString:[colorCode substringWithRange:NSMakeRange(i, 1)]];
    }
    
    colorCode = [_colorCode copy];
  }
  
  NSString *hexCodeStr;
  const char *hexCode;
  char *endptr;
  CGFloat red, green, blue;
  
  for (NSInteger i = 0; i < 3; i++) {
    hexCodeStr = [NSString stringWithFormat:@"+0x%@", [colorCode substringWithRange:NSMakeRange(i * 2, 2)]];
    hexCode    = [hexCodeStr cStringUsingEncoding:NSASCIIStringEncoding];
    
    switch (i) {
      case 0:
        red   = strtol(hexCode, &endptr, 16);
        break;
        
      case 1:
        green = strtol(hexCode, &endptr, 16);
        break;
        
      case 2:
        blue  = strtol(hexCode, &endptr, 16);
        
      default:
        break;
    }
  }
  
  return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:alpha];
}

@end