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

#import <Foundation/Foundation.h>
#import "SFNativeRestAppDelegate.h"
#import "SFRestAPI+Blocks.h"
#import <CoreLocation/CoreLocation.h>

@class PublicDatas;

@protocol CompanyDelegate <NSObject>
-(void)didCompanyInfoReceived:cp;
-(void)didInvalidCompanyInfoReceived;
@end
#define BUILDING ((int)8)
#define SALES_UP ((int)4)
#define SALES_FLAT ((int)2)
#define SALES_DOWN ((int)1)

@interface Company : NSObject <SFRestDelegate>
{
	BOOL inWait;
}
@property (nonatomic, assign) int salesStatus;
@property (nonatomic, assign) int currentSales;
@property (nonatomic, assign) int oldSales;
@property (nonatomic, assign) int sortKey1;
@property (nonatomic, assign) int sortKey2;
@property(strong,nonatomic)	NSString *company_id;
@property(strong,nonatomic)	NSString *name;
@property(strong,nonatomic)	NSString *Address1;
@property(strong,nonatomic)	NSString *Address2;
@property(strong,nonatomic)	NSString *phone1;
@property(strong,nonatomic)	NSString *phone2;
@property CLLocationCoordinate2D position;
@property(strong,nonatomic)	UIImage *image;
@property(strong,nonatomic)	PublicDatas *pData;
@property(strong,nonatomic) id<CompanyDelegate>delegate;
@property(nonatomic, assign) double yearSales;
@property(nonatomic, assign) int employee;
@property(nonatomic, assign) int visitCount;
@property(nonatomic, assign) int opportunityCount;

-(id)init;
-(void)getCompanyInfoFromId;

@end
