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


#import "SFNativeRestAppDelegate.h"
#import "SFRestAPI+Blocks.h"
#import "SFRestRequest.h"
#import "SFAccountManager.h"
#import "SFIdentityData.h"
#import "UtilManager.h"
#import "ImageSelectorViewController.h"
#import "WordSelectPopoverViewController.h"

@interface SettingViewController : UIViewController <UIImagePickerControllerDelegate ,UIPopoverControllerDelegate,
UINavigationControllerDelegate,ImageSelectDelegate, UIPopoverControllerDelegate,WordSelectPopoverDelegate,SFRestDelegate>
{
	int tag;
	int currentNaviSetting;
	int oldNaviSetting;
	int currentBackGroundSetting;
	int oldBackGroundSetting;
	UtilManager *um;
	PublicDatas *pData;
	UILabel *titleLabel;
	UIAlertView *alertView;
	UIActivityIndicatorView *progress;
  int i;
}


@property (strong, nonatomic) IBOutlet UIImageView *logoImage;

- (IBAction)btn1Selected:(id)sender;
- (IBAction)btn2Selected:(id)sender;
- (IBAction)btn3Selected:(id)sender;
- (IBAction)btn4Selected:(id)sender;
- (IBAction)btn5Selected:(id)sender;
- (IBAction)btn6Selected:(id)sender;

@property (strong, nonatomic) UIPopoverController *pop;
@property (strong, nonatomic) IBOutlet UISegmentedControl *btn1Segment;
@property (strong, nonatomic) IBOutlet UISegmentedControl *btn2Segment;
@property (strong, nonatomic) IBOutlet UISegmentedControl *btn3Segment;
@property (strong, nonatomic) IBOutlet UISegmentedControl *btn4Segment;
@property (strong, nonatomic) IBOutlet UISegmentedControl *btn5Segment;
@property (strong, nonatomic) IBOutlet UISegmentedControl *btn6Segment;
@property (strong, nonatomic) IBOutlet UIImageView *btn1Image;
@property (strong, nonatomic) IBOutlet UIImageView *btn2Image;
@property (strong, nonatomic) IBOutlet UIImageView *btn3Image;
@property (strong, nonatomic) IBOutlet UIImageView *btn4Image;
@property (strong, nonatomic) IBOutlet UIImageView *btn5Image;
@property (strong, nonatomic) IBOutlet UIImageView *btn6Image;
@property (strong, nonatomic) IBOutlet UISegmentedControl *backSegment;
@property (strong, nonatomic) IBOutlet UISegmentedControl *logoSegment;
@property (strong, nonatomic) IBOutlet UISegmentedControl *tab1Segment;
@property (strong, nonatomic) IBOutlet UISegmentedControl *tab2Segment;
@property (strong, nonatomic) IBOutlet UISegmentedControl *tabBarSegment;
@property (strong, nonatomic) IBOutlet UISegmentedControl *navBarSegment;
@property (strong, nonatomic) IBOutlet UISegmentedControl *textSegment;

@property (strong, nonatomic) IBOutlet UILabel *backGroundLabel;

@property (strong, nonatomic) IBOutlet UILabel *navBarLabel;
@property (strong, nonatomic) IBOutlet UILabel *btn1Label;
@property (strong, nonatomic) IBOutlet UILabel *btn2Label;
@property (strong, nonatomic) IBOutlet UILabel *btn3Label;
@property (strong, nonatomic) IBOutlet UILabel *btn4label;
@property (strong, nonatomic) IBOutlet UILabel *btn5Label;
@property (strong, nonatomic) IBOutlet UILabel *btn6label;
@property (strong, nonatomic) IBOutlet UILabel *logoLabel;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) IBOutlet UILabel *syncLabel;

- (IBAction)backSlected:(id)sender;
- (IBAction)logoSelected:(id)sender;
- (IBAction)navBarSelected:(id)sender;
- (IBAction)textSelected:(id)sender;

-(id)resizeImage:(UIImage*)img Rect:(CGRect)rect;

@property (strong, nonatomic) IBOutlet UIButton *syncBtn;
- (IBAction)pushSyncBtn:(id)sender;


@end
