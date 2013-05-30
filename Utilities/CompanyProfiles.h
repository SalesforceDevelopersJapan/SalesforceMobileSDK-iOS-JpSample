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
#import "QuartzCore/QuartzCore.h"
#import "SFNativeRestAppDelegate.h"
#import "Company.h"

@class PublicDatas;

@protocol CompanyProfileDelegate <NSObject>
-(void)didSelectTileImage:(NSMutableArray*)array index:(int)index;
-(void)detectMyPosition:(CLLocationCoordinate2D)pos;
-(void)didAddressTaped;
-(void)logoImageFound:(UIImage*)img;
@end

@interface CompanyProfiles : UIView <UIAlertViewDelegate,CLLocationManagerDelegate>
{
	PublicDatas				*pData;
	Company					*cp;
	CLLocationManager		*locationManager;
	CLLocationCoordinate2D	myPos;
	BOOL					positionDetected;
	UIAlertView				*alertView;
	NSString				*checkInID;
	NSMutableData			*rcvData;
	NSMutableArray			*imgArray;
	int						imgCnt;
	NSString				*adrs1;
	NSString				*adrs2;
	BOOL					isCheckIN;
	UIAlertView				*lAlertView;
	UIActivityIndicatorView *progress;
	NSMutableArray			*ObjArray;
	NSMutableArray			*imgCache;
	BOOL					logoFound;
}

@property(strong, nonatomic) IBOutlet UIView *childView;
@property(strong, nonatomic) IBOutlet UILabel *companyNameLabel;
@property(strong, nonatomic) IBOutlet UILabel *addressLabel2;
@property(strong, nonatomic) IBOutlet UILabel *phoneLabel2;
@property(strong, nonatomic) IBOutlet UIImageView *logoImage;
@property (strong, nonatomic) IBOutlet UIButton *chkOutBtn;
@property (strong, nonatomic) IBOutlet UIButton *chkInBtn;
@property (nonatomic,strong) id<CompanyProfileDelegate>delegate;

-(void)setAddressLabel:(NSString *)text;
-(void)setPhoneLabel:(NSString *)text;
-(void)setNameLabel:(NSString *)text;
-(void)setStreetLabel:(NSString*)text;
-(void)setInfo:(Company*)cpny;
- (IBAction)ChkInPushed:(id)sender;
- (IBAction)chkOutPushed:(id)sender;
-(void)retriveImage;
-(void)setUpCheckInOut;

@end 
