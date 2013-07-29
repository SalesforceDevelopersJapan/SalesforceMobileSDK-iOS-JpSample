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

#import "Product.h"

@implementation Product

-(id)init
{
	self = [super init];
	
	self.productId = @"";
	self.priceBookEntryId = @"";

	self.productName  = @"";
	self.productFamily = @"";
	self.description = @"";
	self.image = [[UIImage alloc]init];
	self.imgURLArray = [NSMutableArray array];
  self.imgNameArray = [NSMutableArray array];
  self.imgIdArray = [NSMutableArray array];
  self.imgDateArray = [NSMutableArray array];
	self.movieURL  = @"";
	self.newestStockCount = 0;
	self.newestStockDate = [[NSDate alloc]init];
	self.arrivalStockCount = 0;
	self.arrivalStockDate =[[NSDate alloc]init];
	self.index = 0;
	self.price = 0;
	self.sortOrder = 0;
	self.stockArray = [NSMutableArray array];
	self.stockDateArray = [ NSMutableArray array];
  self.badgeValue = @"";
	self.pdfNameArray = [NSMutableArray array];
	self.pdfURLArray = [NSMutableArray array];
  
  self.stock__c_id = @"";
  self.StockCount__c = 0;
	return  self;
}
@end
