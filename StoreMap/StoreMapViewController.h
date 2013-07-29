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
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "GoogleMaps/GoogleMaps.h"
#import "UIBarButtonItem+DesignedButton.h"
#import "PinDefine.h"
#import "MapViewController.h"
#import "SMCalloutView.h"
#import "BuildNavButtons.h"
#import "MemoViewController.h"

@class CompanyProfiles;
@class PublicDatas;
@class MetricsViewController;
@class OrderViewController;
@class ChatterViewController;
@class Company;
@class UtilManager;

@interface StoreMapViewController : UIViewController <GMSMapViewDelegate,CLLocationManagerDelegate,ChangeFunctionDelegate,MemoViewControllerDelegate>
{
	PublicDatas				*pData;
	Company					*cp;
	GMSMapView				*map;
	UILabel					*titleLabel;
	UIButton				*byWalkBtn;
	UIButton				*byCarBtn;
	UIImage					*carImg;
	UIImage					*walkImg;
	UIButton				*byWalkTextBtn;
	UIButton				*byCarTextBtn;
	CLLocationManager		*locationManager;
	UIImage					*panelBackImg;
	CLLocationCoordinate2D	myPos;
	NSMutableData			*rcvData;
	UIImage					*currentLocationImg;
	UIAlertView				*alertView;
	UIAlertView				*routeAlertView;
	UIActivityIndicatorView *progress;
	EnumMoveMethod			moveMethod;
	GMSPolylineOptions		*options;
	GMSMutablePath			*path;
	UIButton				*groupBtn;
	UIButton				*metricsBtn;
	UIButton				*mapBtn;
	UIButton				*ordersBtn;
	UIButton				*chatterBtn;
	UtilManager				*um;
	BuildNavButtons			*btnBuilder;
  MemoViewController *memoVC;
  BOOL firstGPS;
}
@property (strong, nonatomic) SMCalloutView *calloutView;
@property (strong, nonatomic) UIView *emptyCalloutView;

@property (strong, nonatomic) IBOutlet UIView *mapBase;
@property (strong, nonatomic) IBOutlet CompanyProfiles *companyProfile;
@property (nonatomic, assign) NSInteger selectedTab;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil company:(Company*)cpny;

@end
