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

#import <UIKit/UIKit.h>
#import "Company.h"
#import "QuantyPopOverViewController.h"
#import "Product.h"
#import "LineGrapth.h"
#import "BarGraph.h"
#import "UtilManager.h"
#import "SignBoard.h"
#import "SelectViewController.h"
#import "CompanyProfiles.h"
#import "ViewerViewController.h"
#import "MyToolBar.h"
#import "ChatterViewController.h"
#import "BuildNavButtons.h"
#import "iCarousel.h"
#import "OrderDetailScreen.h"
#import "iCarousel.h"
#import "MPFoldEnumerations.h"
#import "MPFlipEnumerations.h"
#import <QuartzCore/QuartzCore.h>
#import "MPFoldTransition.h"
#import "MPFlipTransition.h"

@class ItemBadge;

enum {
	MPTransitionModeFold,
	MPTransitionModeFlip
} typedef MPTransitionMode;

@interface OrderViewController : UIViewController <SignDelegate, CompanyProfileDelegate,SelectViewDelegate,UIPopoverControllerDelegate,QuantyPopoverDelegate,ViewerViewContorllerDelegate,ChangeFunctionDelegate, iCarouselDataSource, iCarouselDelegate, CacheFileDelegate>
{
	PublicDatas				*pData;
	UIScrollView			*scrl;
	UIPopoverController		*pop;
	QuantyPopOverViewController *qv;
	Company					*cp;
	UIButton				*metricsBtn;
	UIButton				*mapBtn;
	UIButton				*ordersBtn;
	UIButton				*chatterBtn;
	UIAlertView				*alertView;
	UIActivityIndicatorView *progress;
	NSMutableDictionary		*familyList;
	NSString				*selectedFamily;
	NSMutableArray			*productList;
	NSData					*rcvData;
	int						dispProductCount;
	NSMutableDictionary		*orderArray;
	UITapGestureRecognizer *dTap;
	UITapGestureRecognizer *sTap;
	UILongPressGestureRecognizer *lt;
	Product					*lastOpenProduct;
	int						imgLoadCount;
	int						popOverType;
	int						selectedItemOder;
	BOOL					dispChildScreen;
	UILabel					*titleLabel;
	UILabel					*productLabel;
	BarGraph				*stockGraph;
	LineGrapth				*salesGraph;
	NSTimer					*dblTapTimer;
	int						singleTapedTag;
	Product					*currentPrd;
	NSMutableDictionary		*saledArray;
	UIAlertView				*cmpltAlert;
	UtilManager				*um;
	BuildNavButtons			*btnBuilder;
	UIImage					*btnImg;

	
    //以下詳細画面用
	NSMutableDictionary		*imgArray;
	CGRect					primaryImageOrgFrame;
	CGRect					subImageOrgFrame;
	NSString				*selectedMovieURL;
	BOOL					orderDisable;
  
	//以下オーダー（確認）画面
	UIScrollView			*orderScrl;
	UIButton				*orderExec;
  
	//以下履歴画面
	UIScrollView			*historyScrl;
	NSMutableArray			*historyArray;
	int						rowCount;
	int						rcvCount;
	BOOL					rcvCmplt;
	BOOL					inWait;
	NSMutableDictionary		*totalSales;
	NSMutableDictionary		*itemSales;
  
  UIView *clearView;
  iCarousel *carousel;
  BOOL isFistChg;
  
	// 商品詳細
	OrderDetailScreen		*orderDetailScreen;
	UITapGestureRecognizer	*closeTap;
	iCarousel				*carousel2;
	NSData					*movieData;
	Product					*selPrd;
	UIButton				*pdfBtn;
	UIButton				*pdfTextBtn;
	UIButton				*playBtn;
  
  UIImageView *currentImgview;
  CGRect currentImgrect;
  
  UIScrollView *detailScrl;
  UIButton			*leftBtn;
  UIButton			*rightBtn;
  int					imgIndex;
  
  
  MPTransitionMode mode;
  NSUInteger style;
  MPFoldStyle foldStyle;
  MPFlipStyle flipStyle;
  BOOL isFold;
  int swipeIndex;
  UISwipeGestureRecognizer* rightGesture;
  UISwipeGestureRecognizer* leftGesture;
  
  NSData *clearData;
  UIView *clearImgView;
  UIImage *clearImg;
}

@property (strong, nonatomic) IBOutlet UIView *orderHeader;
@property (strong, nonatomic) IBOutlet CompanyProfiles *companyProfile;
@property (strong, nonatomic) IBOutlet UIView *orderView;
@property (strong, nonatomic) IBOutlet UILabel *ordersLabel;
@property (nonatomic,strong) UIImage *product1;
@property (strong, nonatomic) IBOutlet UIButton *orderBtn;
@property (strong, nonatomic) IBOutlet UIButton *histroyBtn;

@property (strong, nonatomic)  UIView			*orderWindow;
@property (strong, nonatomic)  SignBoard		*sign;

@property (strong, nonatomic)  UIView			*historyWindow;



- (IBAction)orderPushed:(id)sender;
- (IBAction)historyPushed:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil company:(Company*)cp;
-(BOOL)isNull:(id)tgt;
-(void)alertShow;
-(CGRect)allignCenter:(CGRect)rect1 size:(CGSize)siz;
-(id)resizeImage:(UIImage*)img Rect:(CGRect)rect;
-(id)forceResizeImage:(UIImage*)img Rect:(CGRect)rect;
-(id)searchBtn:(int)tag;
-(void)dispGraphs:(Product*)prd;


@end
