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

#ifndef SalesForcePrj_orderDefine_h
#define SalesForcePrj_orderDefine_h

static const int	MAXLOADINGSIZE = ( 1024 * 1024 );
#define NAME_WIDTH ( 450 )
#define NAME2_WIDTH ( 300 )
#define PRICE_WIDTH ( 150 )
#define QUANTITY_WIDTH ( 150 )
#define SUM_WIDTH ( 150 )
#define STATUS_WIDTH ( 150 )
#define ROW_HEIGHT ( 30 )
#define DATE_WIDTH ( 150 )
#define TOTAL_WIDTH ( NAME_WIDTH + /*PRICE_WIDTH +*/ QUANTITY_WIDTH + /*SUM_WIDTH +*/ STATUS_WIDTH )
#define TOTAL2_WIDTH ( NAME2_WIDTH + /*PRICE_WIDTH +*/ DATE_WIDTH + QUANTITY_WIDTH + /*SUM_WIDTH +*/ STATUS_WIDTH )

typedef enum {
	ENUM_FAMILYSELECT,
	ENUM_SORTORDER,
} selectType;


#endif
