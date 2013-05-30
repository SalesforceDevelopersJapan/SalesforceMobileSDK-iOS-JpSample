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


#import "BuildNavButtons.h"
#import "MetricsViewController.h"
#import "StoreMapViewController.h"
#import "ChatterViewController.h"
#import "OrderViewController.h"
#import "UtilManager.h"

@implementation BuildNavButtons

-(id)initWithCompany:(Company*)cpny
{
	self = [super init];
	if ( self ){
		_cp = cpny;
	}
	return self;
}
-(UIButton*)buildMenuBtn
{
	UIFont *font = [UIFont boldSystemFontOfSize:20];
	menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//	[menuBtn setTitle:@"+" forState:UIControlStateNormal];
	[menuBtn setBackgroundImage:[UIImage imageNamed:@"MenuOpen.png"] forState:UIControlStateNormal];
	[menuBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	menuBtn.frame = CGRectMake(0,0, 40,25);
	[menuBtn.titleLabel setFont:font];
	[menuBtn addTarget:self action:@selector(openMenu:) forControlEvents:UIControlEventTouchUpInside];
	menuBtn.tag = 100;

	CGSize size = CGSizeMake(5.0, 5.0);
	UtilManager *um = [[UtilManager alloc]init];
	[um makeViewRound: menuBtn corners:(UIRectCornerTopLeft | UIRectCornerTopRight) size:&size];

	return menuBtn;
}

//メニューオープン
-(void)openMenu:(id)sender
{
	NSLog(@"%@",[sender superview]);
	
	float menuPanelSize_Width = 260;
	float menuPanelSize_height = 190;

	UIView *parent1 = [sender superview];
	UIView *parent2 = [parent1 superview];
	UIView *parent3 = [parent2 superview];

	//既にメニュー表示中の場合は消去する
	if ( YES == [self eraseMenu:sender parent:parent3]){
		((UIButton*)sender).backgroundColor = [UIColor clearColor];
//		[(UIButton*)sender setTitle:@"+" forState:UIControlStateNormal];
		[menuBtn setBackgroundImage:[UIImage imageNamed:@"MenuOpen.png"] forState:UIControlStateNormal];
		return;
	}
	
	//表示位置を求める
	float right = ((UIButton*)sender).frame.origin.x + ((UIButton*)sender).frame.size.width +
		parent1.frame.origin.x + parent2.frame.origin.x +parent3.frame.origin.x;
	float up = ((UIButton*)sender).frame.origin.y + ((UIButton*)sender).frame.size.height+
		parent1.frame.origin.y + parent2.frame.origin.y +parent3.frame.origin.y;
	float menuPanelOrigin_x = right - menuPanelSize_Width;
	float menuPanelOrigin_y = up;
	
	menuPanel = [[UIView alloc]initWithFrame:CGRectMake(menuPanelOrigin_x,menuPanelOrigin_y, menuPanelSize_Width, menuPanelSize_height)];
	menuPanel.backgroundColor = [UIColor colorWithRed:0.12 green:0.15 blue:0.20 alpha:1.0];
	menuPanel.tag = 65535;	
	
	CGSize size = CGSizeMake(5.0, 5.0);
	UtilManager *um = [[UtilManager alloc]init];
	[um makeViewRound: menuPanel corners:(UIRectCornerBottomLeft|UIRectCornerBottomRight|UIRectCornerTopLeft) size:&size];
	
  pData = [PublicDatas instance];
	//ボタン追加
	[menuPanel addSubview:[self buildMetricsBtnForMenuPanel]];
	[menuPanel addSubview:[self buildMapBtnForMenuPanel]];
	[menuPanel addSubview:[self buildOrdersBtnForMenuPanel]];
	[menuPanel addSubview:[self buildChatterBtnForMenuPanel]];

  NSLog(@"fileRenew %@", [pData getDataForKey:@"fileRenew"]);
  NSLog(@"CacheFileDelegate : %@", _cacheDelegate);
  
  if([[pData getDataForKey:@"fileRenew"] isEqual:@"YES"] && _cacheDelegate!=nil){
    [menuPanel addSubview:[self buildFileRenewBtnForMenuPanel]];
  }else{
    [menuPanel addSubview:[self buildDummy1BtnForMenuPanel]];
  }
	[menuPanel addSubview:[self buildDummy2BtnForMenuPanel]];

	//ラベル追加
	UIFont *font = [UIFont boldSystemFontOfSize:12];
	UILabel *lbl1 = [[UILabel alloc]init];
	UILabel *lbl2 = [[UILabel alloc]init];
	UILabel *lbl3 = [[UILabel alloc]init];
	UILabel *lbl4 = [[UILabel alloc]init];

	pData = [PublicDatas instance];
	
	[lbl1 setText:[pData getDataForKey:@"DEFINE_MENU_METRICS"]];
	[lbl1 setFont:font];
	[lbl1 setTextColor:[UIColor whiteColor]];
	[lbl1 setBackgroundColor:[UIColor clearColor]];
	[lbl1 sizeToFit];
	[lbl1 setCenter:CGPointMake(50, 90)];

	[lbl2 setText:[pData getDataForKey:@"DEFINE_MENU_STOREMAP"]];
	[lbl2 setFont:font];
	[lbl2 setTextColor:[UIColor whiteColor]];
	[lbl2 setBackgroundColor:[UIColor clearColor]];
	[lbl2 sizeToFit];
	[lbl2 setCenter:CGPointMake(130, 90)];

	[lbl3 setText:[pData getDataForKey:@"DEFINE_MENU_ORDERS"]];
	[lbl3 setFont:font];
	[lbl3 setTextColor:[UIColor whiteColor]];
	[lbl3 setBackgroundColor:[UIColor clearColor]];
	[lbl3 sizeToFit];
	[lbl3 setCenter:CGPointMake(210, 90)];

	[lbl4 setText:[pData getDataForKey:@"DEFINE_MENU_CHATTER"]];
	[lbl4 setFont:font];
	[lbl4 setTextColor:[UIColor whiteColor]];
	[lbl4 setBackgroundColor:[UIColor clearColor]];
	[lbl4 sizeToFit];
	[lbl4 setCenter:CGPointMake(50, 180)];
	
	[menuPanel addSubview:lbl1];
	[menuPanel addSubview:lbl2];
	[menuPanel addSubview:lbl3];
	[menuPanel addSubview:lbl4];

	[menuPanel setUserInteractionEnabled:YES];
	
	[parent3 addSubview:menuPanel];
	[(UIButton*)sender setBackgroundColor:[UIColor colorWithRed:0.12 green:0.15 blue:0.20 alpha:1.0]];
//	[(UIButton*)sender setTitle:@"×" forState:UIControlStateNormal];
	[menuBtn setBackgroundImage:[UIImage imageNamed:@"MenuClose.png"] forState:UIControlStateNormal];

}

-(BOOL)eraseMenu:(id)sender parent:(id)parent
{
	
	//既に表示中の場合はメニューを消す
	for ( UIView *view in [parent subviews])
	{
		if ( view.tag == 65535){
			[view removeFromSuperview];
			return YES;
		}
	}
	return  NO;
}


-(UIButton*)buildMetricsBtnForMenuPanel
{
	UIButton *metricsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[metricsBtn setBackgroundImage:[UIImage imageNamed:@"StoreMetricsIcon.png"] forState:UIControlStateNormal];
	metricsBtn.frame = CGRectMake(20,20, 60,60);
	metricsBtn.backgroundColor = [UIColor grayColor];
	[metricsBtn addTarget:self action:@selector(didSelectFunction:) forControlEvents:UIControlEventTouchUpInside];
	metricsBtn.tag = 0;

	CGSize size = CGSizeMake(5.0, 5.0);
	UtilManager *um = [[UtilManager alloc]init];
	[um makeViewRound: metricsBtn corners:UIRectCornerAllCorners size:&size];
	
	return metricsBtn;
}
-(UIButton*)buildMapBtnForMenuPanel
{
	UIButton *mapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[mapBtn setBackgroundImage:[UIImage imageNamed:@"StoreMapIcon.png"] forState:UIControlStateNormal];
	mapBtn.frame = CGRectMake(100,20, 60,60);
	mapBtn.backgroundColor = [UIColor grayColor];
	[mapBtn addTarget:self action:@selector(didSelectFunction:) forControlEvents:UIControlEventTouchUpInside];
	mapBtn.tag = 1;

	CGSize size = CGSizeMake(5.0, 5.0);
	UtilManager *um = [[UtilManager alloc]init];
	[um makeViewRound: mapBtn corners:UIRectCornerAllCorners size:&size];
	
	return mapBtn;
}
-(UIButton*)buildOrdersBtnForMenuPanel
{
	UIButton *ordersBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[ordersBtn setBackgroundImage:[UIImage imageNamed:@"StoreOrderIcon.png"] forState:UIControlStateNormal];
	ordersBtn.frame = CGRectMake(180,20, 60,60);
	ordersBtn.backgroundColor = [UIColor grayColor];
	[ordersBtn addTarget:self action:@selector(didSelectFunction:) forControlEvents:UIControlEventTouchUpInside];
	ordersBtn.tag = 2;

	CGSize size = CGSizeMake(5.0, 5.0);
	UtilManager *um = [[UtilManager alloc]init];
	[um makeViewRound: ordersBtn corners:UIRectCornerAllCorners size:&size];

	return ordersBtn;
}

-(UIButton*)buildChatterBtnForMenuPanel
{
	UIButton *chatterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[chatterBtn setBackgroundImage:[UIImage imageNamed:@"StoreChatterIcon.png"] forState:UIControlStateNormal];
	chatterBtn.frame = CGRectMake(20,110, 60,60);
	chatterBtn.backgroundColor = [UIColor grayColor];
	[chatterBtn addTarget:self action:@selector(didSelectFunction:) forControlEvents:UIControlEventTouchUpInside];
	chatterBtn.tag = 3;

	CGSize size = CGSizeMake(5.0, 5.0);
	UtilManager *um = [[UtilManager alloc]init];
	[um makeViewRound: chatterBtn corners:UIRectCornerAllCorners size:&size];
	
	return chatterBtn;
}

-(UIButton*)buildFileRenewBtnForMenuPanel
{
  UIButton *dummyfbtn = [UIButton buttonWithType:UIButtonTypeCustom];
	dummyfbtn.frame = CGRectMake(100,110, 60,60);
	[dummyfbtn setBackgroundImage:[UIImage imageNamed:@"DummyFileButton.png"] forState:UIControlStateNormal];
  [dummyfbtn addTarget:self action:@selector(cacheFileUpdate:) forControlEvents:UIControlEventTouchUpInside];
  
	CGSize size = CGSizeMake(5.0, 5.0);
	UtilManager *um = [[UtilManager alloc]init];
	[um makeViewRound: dummyfbtn corners:UIRectCornerAllCorners size:&size];
  
	return dummyfbtn;
}

-(UIButton*)buildDummy1BtnForMenuPanel
{
	UIButton *dummy1btn = [UIButton buttonWithType:UIButtonTypeCustom];
	dummy1btn.frame = CGRectMake(100,110, 60,60);
	[dummy1btn setBackgroundImage:[UIImage imageNamed:@"DummyButton.png"] forState:UIControlStateNormal];

	CGSize size = CGSizeMake(5.0, 5.0);
	UtilManager *um = [[UtilManager alloc]init];
	[um makeViewRound: dummy1btn corners:UIRectCornerAllCorners size:&size];
		
	return dummy1btn;
}
-(UIButton*)buildDummy2BtnForMenuPanel
{
	UIButton *dummy2btn = [UIButton buttonWithType:UIButtonTypeCustom];
	dummy2btn.frame = CGRectMake(180,110, 60,60);
	[dummy2btn setBackgroundImage:[UIImage imageNamed:@"DummyButton.png"] forState:UIControlStateNormal];

	CGSize size = CGSizeMake(5.0, 5.0);
	UtilManager *um = [[UtilManager alloc]init];
	[um makeViewRound: dummy2btn corners:UIRectCornerAllCorners size:&size];
	
	return dummy2btn;
}


-(UIButton*)buildMetricsBtn
{
	UIButton *metricsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[metricsBtn setBackgroundImage:[UIImage imageNamed:@"StoreMetricsIcon.png"] forState:UIControlStateNormal];
	metricsBtn.frame = CGRectMake(0,0, 25,25);
	[metricsBtn addTarget:self action:@selector(didSelectFunction:) forControlEvents:UIControlEventTouchUpInside];
	metricsBtn.tag = 0;
	
	return metricsBtn;
}
-(UIButton*)buildMapBtn
{
	UIButton *mapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[mapBtn setBackgroundImage:[UIImage imageNamed:@"StoreMapIcon.png"] forState:UIControlStateNormal];
	mapBtn.frame = CGRectMake(0,0, 25,25);
	[mapBtn addTarget:self action:@selector(didSelectFunction:) forControlEvents:UIControlEventTouchUpInside];
	mapBtn.tag = 1;
	
	return mapBtn;
}
-(UIButton*)buildOrdersBtn
{
	UIButton *ordersBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[ordersBtn setBackgroundImage:[UIImage imageNamed:@"StoreOrderIcon.png"] forState:UIControlStateNormal];
	ordersBtn.frame = CGRectMake(0,0, 25,25);
	[ordersBtn addTarget:self action:@selector(didSelectFunction:) forControlEvents:UIControlEventTouchUpInside];
	ordersBtn.tag = 2;
	
	return ordersBtn;
}

-(UIButton*)buildChatterBtn
{
	UIButton *chatterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[chatterBtn setBackgroundImage:[UIImage imageNamed:@"StoreChatterIcon.png"] forState:UIControlStateNormal];
	chatterBtn.frame = CGRectMake(0,0, 25,25);
	[chatterBtn addTarget:self action:@selector(didSelectFunction:) forControlEvents:UIControlEventTouchUpInside];
	chatterBtn.tag = 3;
	
	return chatterBtn;
}



-(UIBarButtonItem*)buildBackBtn
{
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc]designedBackBarButtonItemWithTitle:@"" type:1  target:self action:@selector(back)];
	return backButton;
}
-(UIBarButtonItem*)buildBackStepBtn
{
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc]designedBackBarButtonItemWithTitle:@"" type:1  target:self action:@selector(backStep)];
	return backButton;
}
-(UIBarButtonItem*)buildHomeBtn
{
	UIBarButtonItem *HomeButton = [[UIBarButtonItem alloc]designedBackBarButtonItemWithTitle:@"" type:0  target:self action:@selector(back)];
	return HomeButton;
}
-(UIBarButtonItem*)buildHomeStepBtn
{
	UIBarButtonItem *HomeButton = [[UIBarButtonItem alloc]designedBackBarButtonItemWithTitle:@"" type:0  target:self action:@selector(homeStep)];
	return HomeButton;
}

-(void)dismissMenu
{
	menuBtn.backgroundColor = [UIColor clearColor];
	[menuBtn setBackgroundImage:[UIImage imageNamed:@"MenuOpen.png"] forState:UIControlStateNormal];
	[menuPanel removeFromSuperview];
}

-(void)back
{
	int backPos;
	
	[menuPanel removeFromSuperview];
	
	//戻り先を共有データを取得
	pData = [PublicDatas instance];
	NSString *ret = [pData getDataForKey:@"ReturnScreen"];
	if ( [ret isEqualToString:@"ROOT"] ) {
		backPos = 0;				//開始画面に戻る
	}
	else {
		backPos = 1;				//地図に戻る
	}
	if ([self.delegate respondsToSelector:@selector(didPushback:)]){
		[self.delegate didPushback:backPos];
	}
}
-(void)backStep
{
	if ([self.delegate respondsToSelector:@selector(didPushbackStep)]){
		[self.delegate didPushbackStep];
	}
}
-(void)homeStep
{
	if ([self.delegate respondsToSelector:@selector(didPushHomeStep)]){
		[self.delegate didPushHomeStep];
	}
}

// キャッシュファイル更新
-(void)cacheFileUpdate:(id)sender
{
  if ([self.cacheDelegate respondsToSelector:@selector(didCacheFileUpdate)]){
		[self.cacheDelegate didCacheFileUpdate];
	}
}


//機能（画面）選択
-(void)didSelectFunction:(id)sender
{
	UIButton *wrkBtn = (UIButton*)sender;
	int tab = wrkBtn.tag;

	MetricsViewController *metVC;
	OrderViewController *orderVC;
	StoreMapViewController *mapVC;
	ChatterViewController *chatter;

	UIView *parent = [sender superview];
	NSLog(@"%@",parent.description);
	
	//既にメニュー表示中の場合は消去する
	if ( YES == [self eraseMenu:[sender superview] parent:[[sender superview]superview]]){
		menuBtn.backgroundColor = [UIColor clearColor];
//		[menuBtn setTitle:@"+" forState:UIControlStateNormal];
		[menuBtn setBackgroundImage:[UIImage imageNamed:@"MenuOpen.png"] forState:UIControlStateNormal];
	}
	
	switch (tab) {
		case 0:
			metVC = [[MetricsViewController alloc]initWithNibName:@"Metrics" bundle:[NSBundle mainBundle] company:_cp ];
			if ([self.delegate respondsToSelector:@selector(didPushChangeFunction:)]){
				[self.delegate didPushChangeFunction:metVC];
			}

			break;
			
		case 1:
			mapVC = [[StoreMapViewController alloc]initWithNibName:@"StoreMapViewController" bundle:[NSBundle mainBundle] company:_cp ];
			if ([self.delegate respondsToSelector:@selector(didPushChangeFunction:)]){
				[self.delegate didPushChangeFunction:mapVC];
			}
			break;
			
		case 2:
			orderVC = [[OrderViewController alloc]initWithNibName:@"Order" bundle:[NSBundle mainBundle] company:_cp ];
			if ([self.delegate respondsToSelector:@selector(didPushChangeFunction:)]){
				[self.delegate didPushChangeFunction:orderVC];
			}
			break;
			
		case 3:
			//Chatter表示
			chatter = [[ChatterViewController alloc]init];
			[chatter setInitialId:_cp.company_id];
			[chatter setInitialCompnay:_cp];
			[chatter setChatterType:2];				//取引先のチャター
			if ([self.delegate respondsToSelector:@selector(didPushChangeFunction:)]){
				[self.delegate didPushChangeFunction:chatter];
			}
			
			//ナビゲーションバー　設定
//			[self.navigationController.navigationBar setHidden:NO];
			break;
			
		default:
			break;
	}
 

}


@end
