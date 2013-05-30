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


#import "CircleGraph.h"
#import "GraphData.h"


@implementation CircleGraph
static inline float radians(double degrees) { return degrees * M_PI / 180.0; }

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
	[self setBackgroundColor:[UIColor whiteColor]];
    return self;
}

- (void)drawRect:(CGRect)rect
{
  //self.backgroundColor = [UIColor grayColor];
  
	UIColor *col[26] = {
		[UIColor colorWithRed:0.04 green:0.47 blue:0.71 alpha:1.0],
		[UIColor colorWithRed:0.12 green:0.32 blue:0.58 alpha:1.0],
		[UIColor colorWithRed:0.22 green:0.67 blue:0.33 alpha:1.0],
		[UIColor colorWithRed:0.50 green:0.66 blue:0.04 alpha:1.0],
		[UIColor colorWithRed:0.78 green:0.58 blue:0.11 alpha:1.0],
		[UIColor colorWithRed:0.02 green:0.74 blue:0.73 alpha:1.0],
		[UIColor colorWithRed:0.07 green:0.64 blue:0.94 alpha:1.0],
		[UIColor orangeColor],
		[UIColor lightGrayColor],
		[UIColor darkGrayColor],

    [UIColor blackColor], //	黒
    [UIColor blueColor], // 	青
    [UIColor brownColor], // 	茶
//    [UIColor clearColor], // 	透明
    [UIColor cyanColor], // 	シアン
    [UIColor darkGrayColor], // 	濃い灰
    [UIColor grayColor], // 	灰
    [UIColor greenColor], // 	緑
//    [UIColor lightGrayColor], // 	薄い灰
    [UIColor magentaColor], // 	マゼンダ
//    [UIColor orangeColor], // 	オレンジ
    [UIColor purpleColor], // 	パープル
    [UIColor redColor], // 	赤
//    [UIColor whiteColor], // 	白
    [UIColor yellowColor], // 	黄
    [UIColor lightTextColor], // 	灰色
    [UIColor darkTextColor], // 	黒
    [UIColor groupTableViewBackgroundColor], // 	灰色のストライプ
    [UIColor viewFlipsideBackgroundColor], // 	灰色の斑
    [UIColor scrollViewTexturedBackgroundColor] // 	布みたいな模様
    
	};
    
	//データの要素数
	int num = [self.data count];

	//データ抽出
	float dat[num];
	NSMutableArray *name = [NSMutableArray array];
	for ( int i = 0; i < num; i++ ) {
		GraphData *gd = [self.data objectAtIndex:i];
		dat[i] = gd.value;
		[name addObject:gd.name];
	}
	
	
	
	// 中心座標の取得
  CGFloat x = CGRectGetWidth(self.bounds) / 2.0; //+40.0;
  CGFloat y = CGRectGetHeight(self.bounds) / 2.0 -30.0;
  CGFloat xx,
			yy;
	
    // 半径
    CGFloat radius = 100.0;
    
    // 描画開始位置
    CGFloat start = -90.0;

	//合計と各項目割合を算出
	CGFloat total = 0.0f;
	for( int i = 0; i < num; i++) {
		total += dat[i];
	}
	for( int i = 0; i < num; i++) {
		dat[i] = dat[i] * 360.0f / total;
	}
	
    CGContextRef context = UIGraphicsGetCurrentContext();

    // 影の描画
    CGContextSetFillColor(context, CGColorGetComponents([[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0] CGColor]));
    CGContextMoveToPoint(context, x, y);
    CGContextAddArc(context, x + 2.0, y + 2.0, radius,  radians(0.0), radians(360.0), 0.0);
    CGContextClosePath(context);
    CGContextFillPath(context);

	
    // 円グラフの描画
	CGFloat sum = 0.0f;
	for( int i = 0 ; i < num; i++) {
		CGContextSetFillColor(context, CGColorGetComponents([col[i]CGColor]));
		CGContextMoveToPoint(context, x, y);
		CGContextAddArc(context, x, y, radius,  radians(start+sum), radians(start + sum+ dat[i]), 0.0);
		CGContextClosePath(context);
		CGContextFillPath(context);
		CGContextStrokePath(context);
		

			//区切り線描画
		CGContextSetRGBStrokeColor(context,  1.0 ,1.0 ,1.0 ,1.0);
		CGContextSetLineWidth(context, 3);
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, x, y);
		xx = -cos(radians(-start+sum))*radius+x;
		yy = -sin(radians(-start+sum))*radius+y;
		CGContextAddLineToPoint(context, xx,yy);
		CGContextStrokePath(context);

		CGContextBeginPath(context);
		CGContextMoveToPoint(context, x, y);
		xx = -cos(radians(-start+sum+dat[i]))*radius+x;
		yy = -sin(radians(-start+sum+dat[i]))*radius+y;
		CGContextAddLineToPoint(context, xx,yy);
		CGContextStrokePath(context);
		

	/*
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, x, y);
		xx = -cos(start+sum+dat[i])*radius+x;
		yy = -sin(start+sum+dat[i])*radius+y;
		CGContextAddLineToPoint(context, xx,yy);
		CGContextStrokePath(context);
*/
		
		sum += dat[i];
	}
	
	//ラベル描画
  /*
	y = 30;
	for( int i = 0 ; i < num; i++) {
		UIView *colView = [[UIView alloc]initWithFrame:CGRectMake(5, y*(i+1) + (5*i), 20 ,20)];
		colView.backgroundColor = col[i];
		[self addSubview:colView];
		
		UILabel *nameLbl = [[UILabel alloc]initWithFrame:CGRectMake(30, y*(i+1) + (5*i), 70, 20)];
		nameLbl.backgroundColor = [UIColor clearColor];
		nameLbl.textColor = [UIColor blackColor];
		nameLbl.text = [name objectAtIndex:i];
		nameLbl.font = [UIFont systemFontOfSize:16];
		[self addSubview:nameLbl];
	}
  */
  //グラフサイズ
	int graphSizeX = 280;
	int graphSizeY = 220;
	
	//原点位置
	int orgX = (self.bounds.size.width - graphSizeX) / 2;
  //int orgX = self.bounds.size.width /2;
	int orgY = self.bounds.size.height - (self.bounds.size.height -graphSizeY -5);
  
  //データ色、名称表示
	for ( int i = 0; i < [name count]; i++) {
    
		//表示基準位置
		x = orgX + ( graphSizeX / 3 ) * (i % 3);
		y = ( i / 3 ) * 20 + orgY+ 15;
		UIView *colView = [[UIView alloc]initWithFrame:CGRectMake(x,y+2,16, 16)];
		colView.backgroundColor = col[i];
		[self addSubview:colView];
    
		UILabel *nameL = [[UILabel alloc]initWithFrame:CGRectMake(x+18, y+2, (graphSizeX / 3) - 18, 16 )];
		nameL.textAlignment = NSTextAlignmentLeft;
		nameL.font = [UIFont systemFontOfSize:10.0];
		nameL.text = [name objectAtIndex:i];
		[self addSubview:nameL];
	}
}

@end
