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
#import "SFRestAPI+Blocks.h"
#import "UtilManager.h"
#import "PublicDatas.h"

@class GraphData;
@class CircleGraph;
@class BarGraph;
@class LineGrapth;

@interface GraphDataManager : NSObject<SFRestDelegate>
{
  BOOL inWait;
  UtilManager *um;
}

@property(nonatomic, strong) NSMutableArray* familyList;
@property(nonatomic, strong) NSString *familyName;
@property(nonatomic, strong) NSString *startDate;
@property(nonatomic, strong) NSString*endDate;
@property(nonatomic, strong) NSMutableArray *dataList;

+(GraphDataManager*)sharedInstance;

-(void) requestFamilyList;
-(NSMutableArray*)getFamilyList;

-(void)requestDataList:(NSString *)familyStr startDate:(NSString *)startStr endDate:(NSString*)endStr;
-(NSMutableArray*)getDataList;

-(NSMutableDictionary*)getDictionaryForTag:(NSString*)tag;
-(void)saveDictionaryFroTag:(NSString *)tag Dictionary:(NSMutableDictionary *)dic;

-(void)loadGraphSetting;

-(NSMutableDictionary*)getPlainGraphData:(NSString*)tag;

-(void)adddLoadingView:(UIView*)baseView;

// ファミリー、期間別に売り上げ金額を取得してViewに表示
-(void)requestDataList:(NSString *)familyStr startDate:(NSString *)startStr endDate:(NSString*)endStr UIView:(UIView*)view tag:(NSString*)tag;

// 棒グラフ描画
-(void) performBarGraph:(NSString*)tag UIView:(UIView*)baseView;

// 折れ線グラフ実行
-(void) performLineGraph:(NSString*)tag UIView:(UIView*)baseView;

@end
