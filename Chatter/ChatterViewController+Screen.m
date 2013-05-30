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


#import "ChatterViewController+Screen.h"
#import "MyToolBar.h"
#import "PinDefine.h"

@implementation ChatterViewController (Screen)

-(void)buildButton
{
	//ツールバー
	toolbar = [[MyToolBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 120.0f, 40.0f)];
	toolbar.backgroundColor = [UIColor clearColor];
	toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	
	toolbarBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
	
	//グループ選択
	groupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	UIFont *font = [UIFont boldSystemFontOfSize:16];
	[groupBtn setTitle:[pData getDataForKey:@"DEFINE_CHATTER_BTN_SELECT"] forState:UIControlStateNormal];
	[groupBtn.titleLabel setFont:font];
	groupBtn.titleLabel.backgroundColor = [UIColor clearColor];
	[groupBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	groupBtn.frame = CGRectMake(200,0, 60,25);
	[groupBtn addTarget:self action:@selector(groupPushed) forControlEvents:UIControlEventTouchUpInside];
	
	//リロードボタン
	reloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	font = [UIFont boldSystemFontOfSize:16];
	//	[reloadBtn setTitle:@"ReLoad" forState:UIControlStateNormal];
	[reloadBtn setBackgroundImage:[UIImage imageNamed:@"reloadicon.png"] forState:UIControlStateNormal];
	[reloadBtn.titleLabel setFont:font];
	reloadBtn.titleLabel.backgroundColor = [UIColor clearColor];
	[reloadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	reloadBtn.frame = CGRectMake(200,0, 25,25);
	[reloadBtn addTarget:self action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
	
	//Followボタン
	followBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  //	[followBtn setTitle:@"Follow" forState:UIControlStateNormal];
	[followBtn setBackgroundImage:[UIImage imageNamed:@"plusIcon.png"] forState:UIControlStateNormal];
	[followBtn.titleLabel setFont:font];
	followBtn.titleLabel.backgroundColor = [UIColor clearColor];
	[followBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	followBtn.frame = CGRectMake(200,0, 25,25);
	[followBtn addTarget:self action:@selector(follow) forControlEvents:UIControlEventTouchUpInside];
	
	//unFollowボタン
	unFollowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  //	[unFollowBtn setTitle:@"unFollow" forState:UIControlStateNormal];
	[unFollowBtn setBackgroundImage:[UIImage imageNamed:@"minusIcon.png"] forState:UIControlStateNormal];
	[unFollowBtn.titleLabel setFont:font];
	unFollowBtn.titleLabel.backgroundColor = [UIColor clearColor];
	[unFollowBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	unFollowBtn.frame = CGRectMake(200,0, 25,25);
	[unFollowBtn addTarget:self action:@selector(unFollow) forControlEvents:UIControlEventTouchUpInside];
 	
	//画面（機能）切り替えボタン
//	metricsBtn = [btnBuilder buildMetricsBtn];
//	mapBtn = [btnBuilder buildMapBtn];
//	ordersBtn = [btnBuilder buildOrdersBtn];
//	chatterBtn = [btnBuilder buildChatterBtn];
	metricsBtn = [btnBuilder buildMenuBtn];
  
	space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

-(void)buildToolBar
{
	[self buildButton];
	
	if ( self.chatterType == ENUM_CHATTERCLIENT ){
		if ( [currentSubscriptionId isEqualToString:@""]){
			//取引先・取引先責任者をフォローしていない状態
			toolbar.items = [NSArray arrayWithObjects:space,
                       [[UIBarButtonItem alloc]initWithCustomView:followBtn],
                       [[UIBarButtonItem alloc]initWithCustomView:reloadBtn], nil];
		}
		else {
			//取引先・取引先責任者をフォローしている状態
			toolbar.items = [NSArray arrayWithObjects:space,
                       [[UIBarButtonItem alloc]initWithCustomView:unFollowBtn],
                       [[UIBarButtonItem alloc]initWithCustomView:reloadBtn], nil];
		}
	}
	else if ( self.chatterType == ENUM_CHATTEROTHER) {
		if ( [currentSubscriptionId isEqualToString:@""]){
			//取引先・取引先責任者をフォローしていない状態
			toolbar.items = [NSArray arrayWithObjects:
/*							 space,
                       [[UIBarButtonItem alloc]initWithCustomView:mapBtn],
                       [[UIBarButtonItem alloc]initWithCustomView:ordersBtn],
                       [[UIBarButtonItem alloc]initWithCustomView:chatterBtn],*/
					   [[UIBarButtonItem alloc]initWithCustomView:reloadBtn],
                       [[UIBarButtonItem alloc]initWithCustomView:followBtn],
							 [[UIBarButtonItem alloc]initWithCustomView:metricsBtn],
							 nil];
		}
		else {
			//取引先・取引先責任者をフォローしている状態
			toolbar.items = [NSArray arrayWithObjects:
/*							 space,
							 [[UIBarButtonItem alloc]initWithCustomView:mapBtn],
			 [[UIBarButtonItem alloc]initWithCustomView:ordersBtn],
			 [[UIBarButtonItem alloc]initWithCustomView:chatterBtn],*/
							 [[UIBarButtonItem alloc]initWithCustomView:reloadBtn],
							 [[UIBarButtonItem alloc]initWithCustomView:unFollowBtn],
							 [[UIBarButtonItem alloc]initWithCustomView:metricsBtn],
							 nil];
      
		}
		metricsBtn.tag = 0;
		mapBtn.tag = 1;
		ordersBtn.tag = 2;
		chatterBtn.tag = 3;
	}
  
	//ツールバーをナビバーに設置
	self.navigationItem.rightBarButtonItem = toolbarBarButtonItem;
}



@end
