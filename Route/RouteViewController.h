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


#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "GoogleMaps/GoogleMaps.h"
#import "SMCalloutView.h"
#import "PublicDatas.h"
#import "Company.h"
#import "UtilManager.h"
#import "RouteSelectPopoverViewController.h"
#import "PinDefine.h"
#import "Route.h"


@interface RouteViewController : UIViewController < CLLocationManagerDelegate,GMSMapViewDelegate,RouteSelectPopoverDelegate,SFRestDelegate,UIPopoverControllerDelegate>
{
	Company					*comp;
	GMSMapView				*map;
	NSMutableData			*rcvData;
	GMSPolylineOptions		*options;
	GMSMutablePath			*path;
	CLLocationManager		*locationManager;
	CLLocationCoordinate2D	myPos;
	NSMutableArray			*companyList;
	NSMutableArray			*routeList;
	int						queryedWaypt;
	BOOL					moveCurrentPos;
	PublicDatas				*pData;
	UIButton				*byWalkBtn;
	UIButton				*byCarBtn;
	UIButton				*byTrainBtn;
	int						selectMode;
	UIPopoverController		*pop;
	GMSMarkerOptions		*lastSerachLocation;
	
	UIImage					*currentLocationImg;
	UIImage					*listBtnImg;
	UIImage					*salesUpImg;
	UIImage					*salesDownImg;
	UIImage					*salesFlatImg;
	UIImage					*panelBackImg;
	UIImage					*carImg;
	UIImage					*walkImg;
	NSString				*searchText;
	CLLocationCoordinate2D	searchPos;
	
	UIButton				*byWalkTextBtn;
	UIButton				*byCarTextBtn;
	UIButton				*ByTrainTextBtn;
	
	UIAlertView				*alertView;
	UIAlertView				*routeAlertView;
	UIActivityIndicatorView *progress;
	EnumMoveMethod			moveMethod;
	BOOL					isFirst;
    BOOL					byJobFlg;
    BOOL					isImgBackJob;
	int						rcvAnsNum;
	NSMutableArray			*selectedRoute;
	BOOL					lastSearchFromCurrentPos;
	UILabel					*titleLabel;
	BOOL					isReturn;
	GMSCameraPosition		*returnPos;
	int						retryCount;
    Route					*rt;
	UtilManager				*um;
	BOOL					drawProgress;
}

@property (strong, nonatomic) IBOutlet UIView *mapView;
@property (strong, nonatomic) UISearchBar *sBar;
@property (strong, nonatomic) SMCalloutView *calloutView;
@property (strong, nonatomic) UIView *emptyCalloutView;



@end
