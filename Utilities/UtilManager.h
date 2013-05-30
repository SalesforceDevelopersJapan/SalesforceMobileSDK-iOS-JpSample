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
#import <QuartzCore/QuartzCore.h>
#import "SFIdentityData.h"
#import "SFAccountManager.h"
#import <MediaPlayer/MediaPlayer.h>

@class PublicDatas;

@interface UtilManager : NSObject{
  NSMutableArray* searchWordList;
  PublicDatas				*pData;
  SFAccountManager *sm;
}

@property(nonatomic, strong)NSMutableArray* searchWordList;

+(UtilManager*)sharedInstance;

- (void)addSearchWordList:(NSString*)str;
- (void)saveSearchWordList;
- (void)loadSearchWordList;
- (void)deleteSearchWordListByWord:(NSString*)str;
-(BOOL)chkString:(id)tgt;
-(BOOL)isInclude:(NSString*)str1 cmp:(NSString*)cmp;
-(NSString*)conv2Tz:(NSString*)src;

//@property (strong, nonatomic) PublicDatas *pData;
//@property (strong, nonatomic) SFAccountManager *sm;

-(void)makeViewRound:(UIView*)view corners:(int)corners size:(CGSize*)size;

-(id)resizeImage:(UIImage*)img Rect:(CGRect)rect;
-(id)forceResizeImage:(UIImage*)img Rect:(CGRect)rect;


-(id)backType;
-(id)backImage;
-(id)selectGroup;
-(id)navBarType;
-(id)navBarImage;
-(id)badge1;
-(id)badge2;
-(id)badge3;
-(id)badge4;
-(id)badge5;
-(id)badge6;
-(id)currentLoacationBtnImage;
-(id)listBtnImage;
-(id)panelBackImage;
-(id)salesUpImage;
-(id)salesFlatImage;
-(id)salesDownImage;
-(id)carBtnImage;
-(id)walkBtnImage;
-(double)lat;
-(double)lon;
-(float)zoom;
-(id)logoType;
-(id)logoImage;
-(id)tabBarType;
-(id)btn1Type;
-(id)btn2Type;
-(id)btn3Type;
-(id)btn4Type;
-(id)btn5Type;
-(id)btn6Type;
-(id)btn1Image;
-(id)btn2Image;
-(id)btn3Image;
-(id)btn4Image;
-(id)btn5Image;
-(id)btn6Image;
-(id)btn1DefaultImage;
-(id)btn2DefaultImage;
-(id)btn3DefaultImage;
-(id)btn4DefaultImage;
-(id)btn5DefaultImage;
-(id)btn6DefaultImage;
-(id)currentLoacationBtnType;
-(id)listBtnType;
-(id)panelBackType;
-(id)salesUpType;
-(id)salesFlatType;
-(id)salesDownType;
-(id)backBtnImage;

-(NSString*) makeId:(NSString*)str;
-(UIButton*)makeImageButton:(UIImage*)image withAction:(SEL)action;
-(UIImage*)convViewToImage:(UIView*)vw;
-(id)wordSetting;
-(void)applyUserSetting;

- (void) makeDir:(NSString*)dir;
- (NSMutableArray*) getProductIDs;
- (void) saveProductFile:(NSString*)dir name:(NSString*)name data:(NSData*)data;
- (BOOL) existProductFile:(NSString*)dir name:(NSString*)name;
- (NSData*) loadProductFile:(NSString*)dir name:(NSString*)name;
- (NSArray*) getProductFiles:(NSString*)dir;
- (NSDate*) getCreatedTime:(NSString*)dir name:(NSString*)name;
- (NSDate*)getLastModifiedDate:(NSString*)src;
- (BOOL) compareFileDate:(NSString*)dir name:(NSString*)name date:(NSString*)date;
- (BOOL) compareCacheDate:(NSString*)date;
-(id)getResizeProductFile:(NSString*)dir name:(NSString*)name img:(UIImage*)img rect:(CGRect)rect;

- (void) saveMovieURL:(NSString*)dir url:(NSString*)url;
- (NSString*) loadProductMovieFileURL:(NSString*)dir;
- (BOOL) existProductMovieFile:(NSString*)dir;
- (void) saveProductMovieFile:(NSString*)dir data:(NSData*)data;
- (NSDictionary*) getProductMovieData:(NSString*)dir;
- (NSData*) loadProductMovieFile:(NSString*)dir;
- (BOOL) compareMovieDate:(NSString*)dir DBdate:(NSString*)date;
- (UIImage*)getThmubnailImage:(NSString*)dir;

- (void) doneSyncFile;
- (BOOL) isDoneSync;

@end
