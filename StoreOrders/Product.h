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

@interface Product : NSObject
@property (nonatomic,strong) NSString *productId;
@property (nonatomic,strong) NSString *priceBookEntryId;
@property (nonatomic,strong) NSString *productName;
@property (nonatomic,strong) NSString *productFamily;
@property (nonatomic,strong) NSString *description;
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) NSMutableArray *imgURLArray;
@property (nonatomic,strong) NSMutableArray *imgNameArray;
@property (nonatomic,strong) NSMutableArray *imgIdArray;
@property (nonatomic,strong) NSMutableArray *imgDateArray;
@property (nonatomic,strong) NSString *movieURL;
@property (nonatomic, assign) int newestStockCount;
@property (nonatomic,strong) NSDate *newestStockDate;
@property (nonatomic, assign) int arrivalStockCount;
@property (nonatomic,strong) NSDate *arrivalStockDate;
@property (nonatomic, assign) int index;
@property (nonatomic, assign) int price;
@property (nonatomic, assign) int sortOrder;
@property (nonatomic,strong) NSMutableArray *stockArray;
@property (nonatomic,strong) NSMutableArray *stockDateArray;
@property (nonatomic,strong) NSString *badgeValue;
@property (nonatomic,strong) NSMutableArray *pdfURLArray;
@property (nonatomic,strong) NSMutableArray *pdfNameArray;
@end
