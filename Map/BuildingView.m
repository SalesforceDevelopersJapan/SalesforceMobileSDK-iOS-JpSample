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


#import "BuildingView.h"
#import "Company.h"
#import <QuartzCore/QuartzCore.h>

@implementation BuildingView
const float cellHeight = 70;

-(id)init
{
	self = [super init];
	if ( self != nil){
		viewSize = CGSizeMake(300,400);
//		_baseView = [[UIView alloc]initWithFrame:CGRectMake(100,50, 300, 440)];
		_baseView = [[UIView alloc]initWithFrame:CGRectZero];
		_baseView.backgroundColor = [UIColor whiteColor];
		scrl = [[UIScrollView alloc]init];
		scrl.frame = CGRectMake( 0,42,0,0);
		_bd = [[building alloc]init];
		[_baseView addSubview:scrl];
		
		_coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1024, 768)];
		_coverView.backgroundColor = [UIColor clearColor];
		_coverView.tag = 65535;
//		[coverView addSubview:_baseView];
		_isCovered = true;
	}
	return self;
}

-(Company*)searchCompany:(int)floorNum
{
	for ( int i = 0; i < [_bd.includeArray count]; i++ ){
		NSDictionary *dic = [_bd.includeArray objectAtIndex:i];
		NSString *nameString = [dic objectForKey:@"name"];
		Company *tempcp = [dic objectForKey:@"cp"];
		
		if ( [nameString isEqualToString:[NSString stringWithFormat:@"%d",floorNum]]){
			return tempcp;
		}
	}
	return [[Company alloc]init];
}

-(UIView*)buildView
{
	
	//ビル名称
	bilNameView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, viewSize.width, 40)];
//	bilNameView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BuildingTitle.png"]];
	bilNameView.backgroundColor = [UIColor colorWithRed:0.58 green:0.55 blue:0.46 alpha:1.0];

	
	float y = 0;
	int floorMax = [_bd.maxFloor intValue];
//	for( int i = 0 ; i < [_bd.includeArray count]; i++ ){
	for( int i = floorMax ; i >= 1; i-- ){
		
		UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0,y, viewSize.width, cellHeight)];
		backView.backgroundColor = [UIColor colorWithRed:0.45 green:0.42 blue:0.36 alpha:1.0];
		
		Company *tempcp = [self searchCompany:i];
		NSString *nameString = [NSString stringWithFormat:@"%d",i];

		//フロア情報を載せるビュー
		UIView *floorView = [[UIView alloc]initWithFrame:CGRectMake(2,0,viewSize.width - 4 , cellHeight)];
//		floorView.backgroundColor = [UIColor whiteColor];
		floorView.backgroundColor = [UIColor colorWithRed:0.96 green:0.94 blue:0.91 alpha:1.0];

		//フロアナンバーのビュー
		UIView *floorNameView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, cellHeight)];
//		floorNameView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BuildingFloor.png"]];
		floorNameView.backgroundColor = [UIColor colorWithRed:0.45 green:0.42 blue:0.36 alpha:1.0];
		
		UIView *floorNameView2 = [[UIView alloc]initWithFrame:floorNameView.frame];
		floorNameView2.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",nameString]]];

/*
		if (!([nameString isEqualToString:@""] || [nameString isEqual:[NSNull null]])) {
			UILabel *flrNameLbl = [[UILabel alloc]initWithFrame:floorNameView.frame];
			font = [UIFont boldSystemFontOfSize:20];
			flrNameLbl.backgroundColor = [UIColor clearColor];
			
			//階数の画像を適用
			[flrNameLbl setText:nameString];
			[flrNameLbl setFont:font];
			[flrNameLbl setTextAlignment:NSTextAlignmentCenter];
			[flrNameLbl setTextColor:[UIColor whiteColor]];
			[floorNameView addSubview:flrNameLbl];
		}
*/
		//社名
		UILabel *cpNameLbl = [[UILabel alloc]initWithFrame:CGRectMake(floorNameView.frame.size.width+2,
																	  cellHeight/2 - 10,
																	  (floorView.frame.size.width  -
																	   floorNameView.frame.size.width) - 4 ,20)];
		UIFont *font = [UIFont systemFontOfSize:14];
		cpNameLbl.font = font;
		
		cpNameLbl.backgroundColor = [ UIColor clearColor];
		if ( ![tempcp isEqual:[NSNull null]] ) {
			cpNameLbl.text = tempcp.name;
		}
		else {
			cpNameLbl.text = @"";
		}
		
		cpNameLbl.textColor = [UIColor colorWithRed:0.42 green:0.67 blue:0.64 alpha:1.0];
		
		//タップ検出させる
		floorView.userInteractionEnabled = YES;
		UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTaped:)];
		[floorView addGestureRecognizer:tapGesture];
		if ( [tempcp.company_id isEqualToString:@""]){
			floorView.tag = 65534;
		}
		else {
			floorView.tag = i;
		}
		[floorView addSubview:floorNameView];
		[floorView addSubview:floorNameView2];
		[floorView addSubview:cpNameLbl];
		[backView addSubview:floorView];
		
		[scrl addSubview:backView];
		y += floorView.frame.size.height + 2;
		
	}
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTaped:)];
	[_coverView addGestureRecognizer:tapGesture];

	scrl.contentSize = CGSizeMake(scrl.frame.size.width, y);
//	return coverView;
	_baseView.layer.shadowOpacity = 0.5f;
	_baseView.layer.shadowOffset = CGSizeMake(10,10);
	
	return _baseView;
}
-(void)buildfinish
{
	UIFont *font = [UIFont boldSystemFontOfSize:20];
	[_baseView addSubview:bilNameView];
//	_baseView.backgroundColor = [UIColor colorWithRed:0.45 green:0.42 blue:0.36 alpha:1.0];
	_baseView.backgroundColor = [UIColor colorWithRed:0.71 green:0.66 blue:0.57 alpha:1.0];

	if (!( [_bd.name isEqualToString:@""] || [_bd.name isEqual:[NSNull null]])){
		UILabel *bilNameLbl = [[UILabel alloc]initWithFrame:CGRectMake( 0, 0, viewSize.width - 4, 38)];
		bilNameLbl.backgroundColor = [UIColor clearColor];
		[bilNameLbl setText:_bd.name];
		[bilNameLbl setFont:font];
		bilNameLbl.textAlignment = NSTextAlignmentCenter;
		[bilNameLbl setTextColor:[UIColor whiteColor]];
		[bilNameView addSubview:bilNameLbl];
	}

	
	scrl.frame = CGRectMake( 0,42,300,400);
	[_baseView addSubview:scrl];
}

-(void)setCoverAlpha
{
	[_coverView setBackgroundColor:[UIColor blackColor]];
	[_coverView setAlpha:0.3];
}


-(void)cellTaped:(UITapGestureRecognizer*)sender
{
	
	UITapGestureRecognizer *recognizer = (UITapGestureRecognizer*)sender;

	int tag = recognizer.view.tag;

	if ( tag == 65535 ) {
		[_coverView removeFromSuperview];
		[_baseView removeFromSuperview];
		_isCovered = false;
		return;
	}
	if ( tag == 65534 ) {
		return;
	}
	
//	NSDictionary *dic = [_bd.includeArray objectAtIndex:tag];
	
	Company *tempcp = [self searchCompany:tag];
//	[_baseView removeFromSuperview];
//	[_coverView removeFromSuperview];
	
	//デリゲートで画面遷移させる
	if ([self.delegate respondsToSelector:@selector(didTapFloor:)]){
		[self.delegate didTapFloor:tempcp];
	}

}
-(void)dismissView
{
	[_baseView removeFromSuperview];
	[_coverView removeFromSuperview];
	_isCovered = false;
}
@end
