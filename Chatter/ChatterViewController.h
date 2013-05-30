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
#import "SFNativeRestAppDelegate.h"
#import "SFRestAPI+Blocks.h"
#import "SFRestRequest.h"
#import "SFAccountManager.h"
#import "SFIdentityData.h"
#import "UIBarButtonItem+DesignedButton.h"
#import "FileNameInputViewController.h"
#import "PreviewViewController.h"
#import "GroupListPopoverViewController.h"
#import "BuildNavButtons.h"

@class ViewerViewController;
@class MetricsViewController;
@class StoreMapViewController;
@class OrderViewController;
@class PreviewViewController;
@class PublicDatas;
@class MyToolBar;
@class UtilManager;
@class Person;
@class FeedItem;

@interface ChatterViewController : UIViewController <SFRestDelegate,UITextViewDelegate,AttachPreviewDelegate,UIPopoverControllerDelegate,GroupListPopoverDelegate,NSURLConnectionDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,FileNameInputDelegate,UIAlertViewDelegate,ChangeFunctionDelegate>
{
	PublicDatas				*pData;
	UIScrollView			*scrl;
	UIScrollView			*fileScrl;
	NSMutableArray			*feedIdArray;
	int						tagNum;
	NSMutableDictionary		*commentArray;
	NSString				*myId;
	UITextView				*postInput;
	NSMutableDictionary		*attacheArray;
	int						attachNum;
	UIPopoverController		*pop;
	NSString				*currentGroup;
	float					fileViewAddPoint;
	NSMutableData			*rcvData;
	NSMutableDictionary		*upFileArray;
	NSMutableDictionary		*myTimeLine;
	NSMutableArray			*memberList;
	Person					*myInfo;
	NSMutableDictionary		*upFileEXTArray;
	NSMutableDictionary		*upFileNameArray;
	UIButton				*fileAttachedButton;
	NSMutableDictionary		*iconArray;
	UIAlertView				*alertView;
	UIAlertView				*fileNameAlertView;
	UIActivityIndicatorView *progress;
	float					moveValue;
	UILabel					*titleLabel;
	int						lastSelectTag;
	UIImage					*btnImg;
	volatile BOOL			inWait;
	volatile float			addPoint;
	BOOL					fileNameInputInProgress;
	BOOL					postInProgress;
	UIButton				*groupBtn;
	UIButton				*metricsBtn;
	UIButton				*mapBtn;
	UIButton				*ordersBtn;
	UIButton				*chatterBtn;
	UIBarButtonItem			*backBtn;
	BOOL                    isFirst;
	int                     feedCount;
	NSMutableArray			*grpArray;
	NSMutableArray			*grpIdArray;
	NSMutableDictionary		*myFollowing;
	NSString				*currentSubscriptionId;
	UIToolbar				*toolbar;
	UIButton				*followBtn;
	UIButton				*unFollowBtn;
	UIBarButtonItem			*space;
	UIButton				*reloadBtn;
	UIBarButtonItem			*toolbarBarButtonItem;
	UILabel					*memberLabel;
	NSString				*deleteId;
	UIAlertView				*delAlert;
	UIAlertView				*delCommentAlert;
	UIAlertView				*bookmarkAlert;
	UtilManager				*um;
	BuildNavButtons			*btnBuilder;
}

@property (strong, nonatomic) IBOutlet UIView *descriptionView;
@property (strong, nonatomic) IBOutlet UIView *feedView;
@property (strong, nonatomic) IBOutlet UIView *postView;
@property (strong, nonatomic) IBOutlet UIView *MemberView;
@property (strong, nonatomic) IBOutlet UIView *fileListView;
@property (strong, nonatomic) IBOutlet UIView *fileListHeaderView;
@property (strong, nonatomic) IBOutlet UIView *memberHeaderView;
@property (strong, nonatomic) IBOutlet UIView *postHeaderView;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UIImageView *groupImageView;
@property (strong, nonatomic) IBOutlet UIButton *updateBtn;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *deleteBtn;
@property (strong, nonatomic) NSString *initialId;
@property (strong, nonatomic) NSString *initialName;
@property (strong, nonatomic) Company  *initialCompnay;
@property (strong, nonatomic) UIImage  *initialImage;
@property (nonatomic, assign) int chatterType;

-(void)getFollowers;
@end
