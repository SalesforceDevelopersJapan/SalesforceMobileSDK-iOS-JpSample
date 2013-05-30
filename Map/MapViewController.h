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



#import "PublicDatas.h"
#import "Company.h"
#import <CoreLocation/CoreLocation.h>
#import "GoogleMaps/GoogleMaps.h"
#import <MapKit/MapKit.h>
#import "UtilManager.h"
#import "PublicDatas.h"
#import "wordPopOverViewController.h"
#import "SearchPopoverViewController.h"
#import "SMCalloutView.h"
#import "BuildingView.h"
#import "ModeSelectViewController.h"

@interface MapViewController : UIViewController < CLLocationManagerDelegate,SFRestDelegate,GMSMapViewDelegate,UISearchBarDelegate,UIPopoverControllerDelegate,SearchPopoverDelegate,wordPopoverDelegate,BuildingViewDelegate,ModeSelectPopoverDelegate>
{
	PublicDatas *pData;
	Company *comp;
	GMSMapView *map;
	NSMutableData *rcvData;
	GMSPolylineOptions *options;
	GMSMutablePath *path;
	CLLocationManager *locationManager;
	CLLocationCoordinate2D myPos;
	NSMutableArray *companyList;
	NSMutableArray *sortedList;
	NSMutableArray *selectedList;
	BOOL moveCurrentPos;
	UILabel *salesDownLbl;
	UILabel *salesUpLbl;
	UILabel *salesFlatLbl;
	UIButton *salesUpBtn;
	UIButton *salesDownBtn;
	UIButton *salesFlatBtn;
	UIButton *buildingBtn;
	int selectMode;
	UIPopoverController *pop;
	GMSMarkerOptions *lastSerachLocation;
	
	UIImage *currentLocationImg;
	UIImage *listBtnImg;
	UIImage *salesUpImg;
	UIImage *salesDownImg;
	UIImage *salesFlatImg;
	UIImage *buildingImg;
	UIImage *panelBackImg;
	NSString *searchText;
	SFRestRequest *requestArround;
	SFRestRequest *requestbuilding;
	SFRestRequest *requestFloor;
	SFRestRequest *requestCpName;
	
	CLLocationCoordinate2D searchPos;
	NSMutableArray *buildingList;
	NSMutableArray *aryForZoom;
	
	UIButton *salesUpTextBtn;
	UIButton *salesDownTextBtn;
	UIButton *salesFlatTextBtn;
	UIButton *buildingTextBtn;
  	BuildingView *bdView;
	UIAlertView*    alertView;
	UIActivityIndicatorView *progress;
	CGPoint finalPoint;
	
	
	BOOL isFirst;
	BOOL isImgBackJob;
	NSString *searchWord;
  
	UtilManager *um;
	
	double	latmax;
	double	latmin;
	double	lngmax;
	double	lngmin;
  
	BOOL	searchFlg;
	int		dispType;
	UIView *selectPanel;
	BOOL	isLstBtnDisp;
	UILabel *label;
}

@property (strong, nonatomic) IBOutlet UIView *mapView;
@property (strong, nonatomic) UISearchBar *sBar;
@property (strong, nonatomic) SMCalloutView *calloutView;
@property (strong, nonatomic) UIView *emptyCalloutView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil company:(Company*)cp;



@end
