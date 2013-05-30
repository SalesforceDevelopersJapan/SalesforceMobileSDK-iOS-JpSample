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
#import "UtilManager.h"
#import "Company.h"

@interface SalesforceProjectViewController : UIViewController <UIImagePickerControllerDelegate, UIPopoverControllerDelegate,SFRestDelegate,UINavigationControllerDelegate>
{
	PublicDatas			*pData;
	Company				*cpy;
	int					tag;
	UIPopoverController *pop;
    NSMutableArray		*messageList;
    int					MessageIndex;
    UIButton			*leftBtn;
    UIButton			*rightBtn;
    UtilManager			*um;
    BOOL				isBadgeFlg;
    UIAlertView			*alertView;
    BOOL isNeedSync;
  UIImage *leftGrayImg;
  UIImage *rightGrayImg;
  UIImage *leftBlueImg;
  UIImage *rightBlueImg;
}

@property (strong, nonatomic) IBOutlet UIButton *map;
@property (strong, nonatomic) UIBarButtonItem *custmerBtn;
@property (strong, nonatomic) IBOutlet UIImageView *companyLogo;
@property (strong, nonatomic) IBOutlet UIButton *metrics;
@property (strong, nonatomic) IBOutlet UIButton *order;
@property (strong, nonatomic) IBOutlet UIButton *promo;
@property (strong, nonatomic) IBOutlet UIButton *chatter;
@property (strong, nonatomic) IBOutlet UIButton *btn6;
@property (strong, nonatomic) IBOutlet UIButton *badge1;
@property (strong, nonatomic) IBOutlet UIButton *badge2;
@property (strong, nonatomic) IBOutlet UIButton *badge3;
@property (strong, nonatomic) IBOutlet UIButton *badge4;
@property (strong, nonatomic) IBOutlet UIButton *badge5;
@property (strong, nonatomic) IBOutlet UIButton *badge6;
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *companyLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *departmentLabel;
@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;
@property (strong, nonatomic) IBOutlet UILabel *faxLabel;
@property (strong, nonatomic) IBOutlet UILabel *emailLabel;
@property (strong, nonatomic) IBOutlet UIView *messageView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UILabel *messageLabel;

- (IBAction)mapPushed:(id)sender;
- (IBAction)metricsPushed:(id)sender;
- (IBAction)orderPushed:(id)sender;
- (IBAction)promotionPushed:(id)sender;
- (IBAction)chatterPushed:(id)sender;

- (IBAction)badge1Pushed:(id)sender;
- (IBAction)badge2Pushed:(id)sender;
- (IBAction)badge3Pushed:(id)sender;
- (IBAction)badge4Pushed:(id)sender;
- (IBAction)badge5Pushed:(id)sender;
- (IBAction)badge6Pushed:(id)sender;

- (IBAction)badge1LongPressed:(id)sender;
- (IBAction)badge2LongPressed:(id)sender;
- (IBAction)badge3LongPressed:(id)sender;
- (IBAction)badge4LongPressed:(id)sender;
- (IBAction)badge5LongPressed:(id)sender;
- (IBAction)badge6LongPressed:(id)sender;

- (IBAction)badge1DoublePushed:(id)sender;
- (IBAction)badge2DoublePushed:(id)sender;
- (IBAction)badge3DoublePushed:(id)sender;
- (IBAction)badge4DoublePushed:(id)sender;
- (IBAction)badge5DoublePushed:(id)sender;
- (IBAction)badge6DoublePushed:(id)sender;

@end
