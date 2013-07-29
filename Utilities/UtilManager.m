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


#import "UtilManager.h"
#import "Reachability.h"
#import "PublicDatas.h"


@implementation UtilManager

static NSString *const searchFileName = @"search.dat";
static NSString *const productDateFileName = @"filedate.dat";
static NSString *const movieURLFileName = @"movieUrl.dat";
static NSString *const movieFileName = @"movie.mp4";
static NSString *const syncFileName = @"sync.dat";
static int const dataCount = 20;

@synthesize searchWordList;

static UtilManager *_instance = nil;

-(id)init {
  
	if (self = [super init]) {
    self.searchWordList = nil;
  }
  
  return self;
}

+(UtilManager*)sharedInstance {
	
	if (_instance == nil) {
		_instance = [[UtilManager alloc] init];
    // インスタンス生成時にアカウントマネージャーを取得
	}
	return _instance;
}

- (void)dealloc {
}

// load
- (void)loadSearchWordList
{
  
	pData = [PublicDatas instance];
  NSString *myid = [pData getDataForKey:@"myId"];
  
	//if ( self.messageList == nil ) {
  self.searchWordList = [[NSMutableArray alloc] init];
	//}
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory
                                                       //NSDocumentDirectory
                                                       , NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *fileName = [documentsDirectory stringByAppendingPathComponent:searchFileName];
  
  NSDictionary *dictionary;
  NSFileManager *fileManager = [NSFileManager defaultManager];
  [fileManager fileExistsAtPath:fileName];
  
  @try{
    dictionary = [[NSDictionary alloc] initWithContentsOfFile:fileName];
    //dictionaryからIDをキーにして該当するsearchWordListを取得
    if ([[dictionary allKeys] containsObject:myid]) {
      //存在を確認してから検索する　なかったら、bodyText = nil;
      NSString *bodyText = [dictionary objectForKey:myid];
      
      if( bodyText != nil ){
        NSArray *items = [bodyText componentsSeparatedByString:@"###"];
        NSInteger count = [[items objectAtIndex:0] intValue];
        
        for ( NSInteger i= 0; i< count; i++ ) {
          NSString* str = [[NSString alloc] initWithFormat:@"%@", [items objectAtIndex:(i+1)] ];
          [self.searchWordList addObject:str];
        }
      }
    }
  }
  @catch (NSException *exception) {
    NSLog(@"searchWordList Loading Error!");
  }
  @finally {
  }
}


// save
- (void)saveSearchWordList
{
  pData = [PublicDatas instance];
  NSString *myid = [pData getDataForKey:@"myId"];
	
	NSInteger count = 0;
	if( searchWordList != nil ){
		count = [searchWordList count];
	}
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory
                                                       //NSDocumentDirectory
                                                       , NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *fileName = [documentsDirectory stringByAppendingPathComponent:searchFileName];
  
  NSString* bodyText = [[NSString alloc] initWithFormat:@"%d", count];
	
  //NSLog(@"%d", count);
	for ( int i= 0; i < count; i++ ) {
    if(i>=dataCount) break;
		NSString* data = (NSString*)[searchWordList objectAtIndex:i];
		bodyText = [[NSString alloc] initWithFormat:@"%@###%@", bodyText, data];
	}
	
  //ファイルからsearchWordDictionaryを呼び出して、NSDictionaryに
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  BOOL isDir;
  
  [fileManager fileExistsAtPath:fileName isDirectory: &isDir];
  NSDictionary *loaddictionary = [[NSDictionary alloc] initWithContentsOfFile:fileName];
	
  NSMutableDictionary *savedictionary = [NSMutableDictionary dictionary];
  
  NSArray *allkeys = [loaddictionary allKeys];
	
	
  if(allkeys){
    NSString *loadbody;
    for(NSString *keyID in allkeys){
      loadbody = [loaddictionary objectForKey:keyID];
      [savedictionary setObject:loadbody forKey:keyID];
    }
  }
  
  //myidとsearchWordListを新しくDictionaryに格納
  [savedictionary  setObject:bodyText forKey:myid];
	
	BOOL ok = [savedictionary writeToFile:fileName atomically:YES];
	if( ok != true ){
    NSLog(@"searchWordList Saving Error!");
	}
  
	// ファイル再読み込み
	[self loadSearchWordList];
}


// add
- (void)addSearchWordList:(NSString*)str
{
  //[searchWordList addObject:str];
  
  NSMutableArray *tmpList = [[NSMutableArray alloc] init];
  
  for(int i=0; i<[searchWordList count]; i++){
    if(![str isEqualToString:[searchWordList objectAtIndex:i]]){
      [tmpList addObject:[searchWordList objectAtIndex:i]];
    }
  }
  [tmpList addObject:str];
  self.searchWordList = tmpList;
  [self saveSearchWordList];
}

// delete
- (void)deleteSearchWordListByWord:(NSString*)str
{
  if([self.searchWordList containsObject:str]){
    //NSLog(@"%d", [self.searchWordList indexOfObject:str]);
    [self.searchWordList removeObjectAtIndex:[self.searchWordList indexOfObject:str]];
    [self saveSearchWordList];
  }
}

//NSString null チェック
-(BOOL)chkString:(id)tgt
{
  @try{
    NSString *str = (NSString*)tgt;
    if (str!= nil && ![str isEqual:[NSNull null]]){
      return YES;
    }
    return NO;
  }@catch (NSException *exception) {
    NSLog(@"main:Caught %@:%@", [exception name], [exception reason]);
    return NO;
  }
}

// Null replace
// 受け取ったオブジェクトがNSString以外なら空のNSStringを返す
-(NSString*)chkNullString:(id)tgt
{
	NSString *cls = NSStringFromClass([tgt class]);
	NSString *ret = @"";
  
  @try{
    if ( ![cls isEqualToString:@"__NSCFString"]) {
      return ret;
    }
    else {
      return tgt;
    }
  }@catch (NSException *exception) {
    NSLog(@"main:Caught %@:%@", [exception name], [exception reason]);
    return ret;
  }
}

//タイムゾーン変換処理
-(NSString*)conv2Tz:(NSString*)src
{
	NSString *srcDate = [src substringToIndex:10];
	NSString *srcTime = [src substringWithRange:NSMakeRange(11,8)];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-ddHH:mm:ssZZZZ"];
	NSDate *pubDate = [formatter dateFromString:[[srcDate stringByAppendingString:srcTime]stringByAppendingString:@"+0000"]];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Tokyo"]];
	[dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
	NSString * ret = [dateFormatter stringFromDate:pubDate];
	return ret;
}

// ビューを角丸にするメソッド
-(void)makeViewRound:(UIView*)view corners:(int)corners size:(CGSize*)size
{
  CALayer *capa = view.layer;
  
  //Round
  CGRect bounds = capa.bounds;
  bounds.size.height += 0.0f;
  UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                                 byRoundingCorners:(corners)
                                                       cornerRadii:*size];
  
  CAShapeLayer *maskLayer = [CAShapeLayer layer];
  maskLayer.frame = bounds;
  maskLayer.path = maskPath.CGPath;
  
  [capa addSublayer:maskLayer];
  capa.mask = maskLayer;
}

//UIImage:imgがRectより大きい場合リサイズする
-(id)resizeImage:(UIImage*)img Rect:(CGRect)rect
{
	if (( img.size.height > rect.size.height) || ( img.size.width > rect.size.width)) {
		//NSLog(@"%f : %f",img.size.width,img.size.height);
		float asp = (float)img.size.width / (float)img.size.height;
		CGRect r = CGRectMake(0,0,0,0);
		if ( img.size.width > img.size.height) {
			r.size.width = rect.size.width;
			r.size.height = r.size.width / asp;
		}
		else {
			r.size.height = rect.size.height;
			r.size.width = r.size.height * asp;
		}
		
		UIGraphicsBeginImageContext(r.size);
    // 角丸処理
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0,0,r.size.width,r.size.height)
                                cornerRadius:10.0] addClip];
		[img drawInRect:CGRectMake(0,0,r.size.width,r.size.height)];
		img = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
  // 角丸処理
  else{
    UIGraphicsBeginImageContextWithOptions(img.size, NO, 1.0);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0,0,img.size.width,img.size.height)
                                cornerRadius:10.0] addClip];
    // Draw your image
    [img drawInRect:CGRectMake(0,0,img.size.width,img.size.height)];
    
    // Get the image, here setting the UIImageView image
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
  }
	return img;
}


//強制リサイズする。角丸め無し
-(id)forceResizeImage:(UIImage*)img Rect:(CGRect)rect
{
	//NSLog(@"%f : %f",img.size.width,img.size.height);
	UIGraphicsBeginImageContext(rect.size);
	[img drawInRect:CGRectMake(0,0,rect.size.width,rect.size.height)];
	img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return img;
}



-(id)backType{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"backType"]];
}
-(id)backImage{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"backImage"]];
}
-(id)selectGroup{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"selectGroup"]];
}
-(id)navBarType{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"navBarType"]];
}
-(id)navBarImage{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"navBarImage"]];
}
-(id)badge1{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"Badge1"]];
}
-(id)badge2{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"Badge2"]];
}
-(id)badge3{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"Badge3"]];
}
-(id)badge4{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"Badge4"]];
}
-(id)badge5{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"Badge5"]];
}
-(id)badge6{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"Badge6"]];
}
-(id)currentLoacationBtnImage{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"currentLoacationBtnImage"]];
}
-(id)listBtnImage{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"listBtnImage"]];
}
-(id)panelBackImage{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"panelBackImage"]];
}
-(id)salesUpImage{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"SalesUpImage"]];
}
-(id)salesFlatImage{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"SalesFlatImage"]];
}
-(id)salesDownImage{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"SalesDownImage"]];
}
-(id)carBtnImage{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"carBtnImage"]];
}
-(id)walkBtnImage{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"walkBtnImage"]];
}
-(double)lat{
	return [[NSUserDefaults  standardUserDefaults]doubleForKey:[self makeId:@"lat"]];
}
-(double)lon{
	return [[NSUserDefaults  standardUserDefaults]doubleForKey:[self makeId:@"lon"]];
}
-(float)zoom{
	return [[NSUserDefaults  standardUserDefaults]floatForKey:[self makeId:@"zoom"]];
}
-(id)logoType{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"logoType"]];
}
-(id)logoImage{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"logoImage"]];
}
-(id)tabBarType{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"tabBarType"]];
}
-(id)btn1Type{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"btn1Type"]];
}
-(id)btn2Type{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"btn2Type"]];
}
-(id)btn3Type{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"btn3Type"]];
}
-(id)btn4Type{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"btn4Type"]];
}
-(id)btn5Type{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"btn5Type"]];
}
-(id)btn6Type{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"btn6Type"]];
}
-(id)btn1Image{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"btn1Image"]];
}
-(id)btn2Image{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"btn2Image"]];
}
-(id)btn3Image{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"btn3Image"]];
}
-(id)btn4Image{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"btn4Image"]];
}
-(id)btn5Image{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"btn5Image"]];
}
-(id)btn6Image{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"btn6Image"]];
}
-(id)btn1DefaultImage{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"btn1DefaultImage"]];
}
-(id)btn2DefaultImage{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"btn2DefaultImage"]];
}
-(id)btn3DefaultImage{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"btn3DefaultImage"]];
}
-(id)btn4DefaultImage{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"btn4DefaultImage"]];
}
-(id)btn5DefaultImage{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"btn5DefaultImage"]];
}
-(id)btn6DefaultImage{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"btn6DefaultImage"]];
}
-(id)currentLoacationBtnType{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"currentLoacationBtnType"]];
}
-(id)listBtnType{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"listBtnType"]];
}
-(id)panelBackType{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"panelBackType"]];
}
-(id)salesUpType{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"SalesUpType"]];
}
-(id)salesFlatType{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"SalesUpType"]];
}
-(id)salesDownType{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"SalesUpType"]];
}
-(id)backBtnImage{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"backBtnImage"]];
}

-(id)wordSetting{
	return [[NSUserDefaults  standardUserDefaults]objectForKey:[self makeId:@"settingFile"]];
}


-(void)applyUserSetting
{
	
	pData = [PublicDatas instance];
	
	//デフォルトのテキストリソース設定
	// ファイル読み込み
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Default.txt" ofType:nil];
	NSError *error;
	// 改行で分割
	NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
	NSArray *items = [content componentsSeparatedByString:@"\n"];
	for(NSString *str in items){
		// = で分割
		NSArray *tmp = [str componentsSeparatedByString:@"="];
		if([tmp count]<2) continue;
    
    // ¥nで改行
    NSString *textVal = [[tmp objectAtIndex:1] stringByReplacingOccurrencesOfString:@"¥n" withString:@"\n"];
		[pData setData:textVal forKey:[tmp objectAtIndex:0]];
		//NSLog(@"str : %@ :%@", [tmp objectAtIndex:0], [tmp objectAtIndex:1]);
	}
	
	NSString *settingFile = [self wordSetting];
	
	//ユーザー設定用のテキストリソース読み込み
	NSArray *sharePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *dir = [sharePaths objectAtIndex:0];
	path = [dir stringByAppendingPathComponent:settingFile];
	
	
	//ファイルが存在するかチェック
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:path] == NO ) {
		
		//ファイルが存在しない場合
		// 確認アラート
		UIAlertView *errAlert =
		[[UIAlertView alloc]
		 initWithTitle:[pData getDataForKey:@"DEFINE_APP_ALERT_NOTEXIST"]
		 message:[pData getDataForKey:@"DEFINE_APP_ALERT_NOTEXIST_MSG"]
		 delegate:nil
		 cancelButtonTitle:nil
		 otherButtonTitles:[pData getDataForKey:@"DEFINE_APP_ALERT_NOTEXIST_OK"], nil
		 ];
		[errAlert show];
	}
	
	//ユーザー設定ファイルが指定されているか？
	if (([settingFile isEqualToString:@""]) || ([settingFile isEqual:[NSNull null]]) || ([settingFile isEqual:nil])){
		
		//ファイルが指定されてない場合
		return;
	}
	
	// 改行で分割
	content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
	items = [content componentsSeparatedByString:@"\n"];
	for(NSString *str in items){
		// = で分割
		NSArray *tmp = [str componentsSeparatedByString:@"="];
		if([tmp count]<2) continue;

    // ¥nで改行
    NSString *textVal = [[tmp objectAtIndex:1] stringByReplacingOccurrencesOfString:@"¥n" withString:@"\n"];
		[pData setData:textVal forKey:[tmp objectAtIndex:0]];
		//NSLog(@"str : %@ :%@", [tmp objectAtIndex:0], [tmp objectAtIndex:1]);
	}
}

// キーに自分のIDをつける
-(NSString*) makeId:(NSString*)str
{
	return [NSString stringWithFormat:@"%@_%@", str, sm.idData.userId];
}


-(UIButton*)makeImageButton:(UIImage*)image withAction:(SEL)action
{
  UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [button setBackgroundImage:image forState:UIControlStateNormal];
  [button addTarget:nil action:action
   forControlEvents:UIControlEventTouchUpInside];
  
  return button;
}

-(UIImage*)convViewToImage:(UIView*)vw
{
	UIGraphicsBeginImageContext(vw.frame.size);
  [vw.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	return image;
}

// ディレクトリ作成
- (void) makeDir:(NSString*)dir
{
  
  // キャッシュディレクトリ内にディレクトリを生成
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *pathName = [documentsDirectory stringByAppendingPathComponent:dir];
  NSError* error = nil;
  
  //NSLog(@"pathName : %@", pathName);
  
  // 文字列型の変数 path で指定したディレクトリを作成
  [[NSFileManager defaultManager] createDirectoryAtPath:pathName withIntermediateDirectories:YES attributes:nil error:&error];
}

// キャッシュディレクトリ以下の商品IDのリストを返却
- (NSMutableArray*) getProductIDs
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSFileManager *fm = [NSFileManager defaultManager];
  NSError *error;
  
  NSArray *array = [fm contentsOfDirectoryAtPath:documentsDirectory error:&error];
  //NSLog(@" files : %@", array);
  
  NSMutableArray *marray = [[NSMutableArray alloc] init];
  // 明らかに関係ないものを除く
  for(NSString *file in array){
    if(![self isInclude:file cmp:@".dat"] && ![self isInclude:file cmp:@"com."]
       && ![self isInclude:file cmp:@".com"] && ![self isInclude:file cmp:@".DS_Store"]){
      [marray addObject:file];
    }
  }
  //NSLog(@" files : %@", marray);
  
  if(!error){
    return marray;
  }else{
    return nil;
  }
}

//str1がstr2を含む場合はYESを返す
-(BOOL)isInclude:(NSString*)str1 cmp:(NSString*)cmp
{
	NSRange result = [str1 rangeOfString:cmp];
	if (result.location == NSNotFound){
		return NO;
	}
	return  YES;
}

// sync済みかをファイルを残して記録
- (void) doneSyncFile
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *fileName = [documentsDirectory stringByAppendingPathComponent:syncFileName];
  
  // 現在の時間を記録
  NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
  [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ssZZZZ"];
  NSString* dateString = [outputFormatter stringFromDate:[NSDate date]];
  BOOL boo = [dateString writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
  if( boo != true ){
    NSLog(@"sync file  Saving Error!");
	}
  
}

// sync済みかをファイルが存在するかチェック
- (BOOL) isDoneSync
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *fileName = [documentsDirectory stringByAppendingPathComponent:syncFileName];
  //NSLog(@"exit sync file : %@", fileName);
  NSFileManager *fm = [NSFileManager defaultManager];
  return [fm fileExistsAtPath:fileName];
}


// ディレクトリを指定してデータを保存
- (void) saveProductFile:(NSString*)dir name:(NSString*)name data:(NSData*)data
{
  // キャッシュディレクトリ内にディレクトリを生成
  [self makeDir:dir];
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *pathName = [documentsDirectory stringByAppendingPathComponent:dir];
  
  //NSLog(@"save image : %@ : %@", dir , name);
  
  BOOL ok = [data writeToFile:[pathName stringByAppendingPathComponent:name] atomically:YES];
	if( ok != true ){
    NSLog(@"File Saving Error!");
	}
  
  // 現在の時間を記録
  NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
  [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ssZZZZ"];
  NSString* dateString = [outputFormatter stringFromDate:[NSDate date]];
  
  NSString *fileName = [documentsDirectory stringByAppendingPathComponent:productDateFileName];
  BOOL boo = [dateString writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
  if( boo != true ){
    NSLog(@"product data file  Saving Error!");
	}
  
}

// デバッグ用メソッド
-(void)getTimeFromDateFile
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *fileName = [documentsDirectory stringByAppendingPathComponent:productDateFileName];
  
  NSString *str =  [[NSString alloc] initWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
  
  NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
  [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ssZZZZ"];
  NSDate *inputDate = [outputFormatter dateFromString:str];
  
  // 日本時間へのフォーマッター
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Tokyo"]];
  [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
  
  NSString* dateString = [dateFormatter stringFromDate:inputDate];
  NSLog(@"dateString : %@ ", dateString);
}

//ファイルが存在するかチェック
- (BOOL) existProductFile:(NSString*)dir name:(NSString*)name
{
  [self makeDir:dir];
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *pathName = [documentsDirectory stringByAppendingPathComponent:dir];
  NSString *fileName = [pathName stringByAppendingPathComponent:name];
  
  //NSLog(@"exit chk file : %@", fileName);
  NSFileManager *fm = [NSFileManager defaultManager];
  return [fm fileExistsAtPath:fileName];
}


//ファイルをロード
- (NSData*) loadProductFile:(NSString*)dir name:(NSString*)name
{
  [self makeDir:dir];
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *pathName = [documentsDirectory stringByAppendingPathComponent:dir];
  NSString *fileName = [pathName stringByAppendingPathComponent:name];
  
  //NSLog(@" loade file : %@", fileName);
  
  NSData *data = [NSData dataWithContentsOfFile:fileName];
  
  return data;
}

//UIImage:imgがRectより大きい場合リサイズする
// リサイズした画像はキャッシュに保存する
-(id)getResizeProductFile:(NSString*)dir name:(NSString*)name img:(UIImage*)img rect:(CGRect)rect
{
  // リサイズ画像名
  NSString *resizeImageName = [NSString stringWithFormat:@"%@_%f_%f", name, rect.size.width, rect.size.height];
  
  // ファイルがある
  if([self existProductFile:dir name:resizeImageName]){
    // 保存時間を比較
    NSDate *orgDate = [self getCreatedTime:dir name:name];
    NSDate *resizeDate = [self getCreatedTime:dir name:resizeImageName];
    
    NSTimeInterval since = [orgDate timeIntervalSinceDate:resizeDate];
    //NSLog(@"name %@", name);
    //NSLog(@"resize %@", resizeImageName);
    //NSLog(@"since %f", since);
    // リサイズ画像の方が新しい
    if(since<=0){
      NSData *rData = [self loadProductFile:dir name:resizeImageName];
      return [[UIImage alloc]initWithData:rData];
    }
  }
  // ファイルがない場合
  // リサイズの必要があればリサイズして保存
  if (( img.size.height > rect.size.height) || ( img.size.width > rect.size.width)) {
    //NSLog(@"%f : %f",img.size.width,img.size.height);
    float asp = (float)img.size.width / (float)img.size.height;
    CGRect r = CGRectMake(0,0,0,0);
    if ( img.size.width > img.size.height) {
      r.size.width = rect.size.width;
      r.size.height = r.size.width / asp;
    }
    else {
      r.size.height = rect.size.height;
      r.size.width = r.size.height * asp;
    }
    
    UIGraphicsBeginImageContext(r.size);
    [img drawInRect:CGRectMake(0,0,r.size.width,r.size.height)];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // リサイズ後のデータを保存
    NSData* jpegData = [[NSData alloc] initWithData: UIImageJPEGRepresentation( img, 1.0 )];
    [self saveProductFile:dir name:resizeImageName data:jpegData];
  }
  return img;
}

// 商品別ファイル一覧
- (NSArray*) getProductFiles:(NSString*)dir
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *pathName = [documentsDirectory stringByAppendingPathComponent:dir];
  
  NSFileManager *fm = [NSFileManager defaultManager];
  NSError *error;
  
  NSArray *array = [fm contentsOfDirectoryAtPath:pathName error:&error];
  //NSLog(@" files : %@", array);
  
  if(!error)
  {
    return array;
  }else{
    return nil;
  }
}

// ファイル保存日時取得
- (NSDate*) getCreatedTime:(NSString*)dir name:(NSString*)name
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *pathName = [documentsDirectory stringByAppendingPathComponent:dir];
  NSString *fileName = [pathName stringByAppendingPathComponent:name];
  
  NSFileManager *fm = [NSFileManager defaultManager];
  NSError *error;
  
  NSDictionary *att = [fm attributesOfItemAtPath:fileName error:&error];
  return [att objectForKey:@"NSFileModificationDate"];
  
}

// SOQLで帰った日付をNSDateにして返す
- (NSDate*)getLastModifiedDate:(NSString*)src
{
	NSString *srcDate = [src substringToIndex:10];
	NSString *srcTime = [src substringWithRange:NSMakeRange(11,8)];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-ddHH:mm:ssZZZZ"];
	NSDate *pubDate = [formatter dateFromString:[[srcDate stringByAppendingString:srcTime]stringByAppendingString:@"+0000"]];
	
	return pubDate;
}

// ファイル生成日時とdateを比較 (YESの場合に更新ファイルを取得）
- (BOOL) compareFileDate:(NSString*)dir name:(NSString*)name date:(NSString*)date
{
  // ファイルが存在しなければYES
  if(![self existProductFile:dir name:name]) return YES;
  
  // ファイル生成日時
  NSDate *date1 = [self getCreatedTime:dir name:name];
  // SOQLで帰った日付
  NSDate *date2 = [self getLastModifiedDate:date];
  
  //NSLog(@"date1 : %@", date1);
  //NSLog(@"date2 : %@", date2);
  
  NSTimeInterval since = [date1 timeIntervalSinceDate:date2];
  //NSLog(@"since %f", since);
  // DBのdateの方が新しければYES
  if(since<0){
    return YES;
  }else{
    return NO;
  }
}

// ファイル保存最終日時とdateを比較  (YESの場合に更新ファイルを取得）
- (BOOL) compareCacheDate:(NSString*)date
{
  
  // ファイル生成最終日時
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *fileName = [documentsDirectory stringByAppendingPathComponent:productDateFileName];
  NSString *str =  [[NSString alloc] initWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
  NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
  [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ssZZZZ"];
  NSDate *date1 = [outputFormatter dateFromString:str];
  
  // SOQLで取得した日付
  NSDate *date2 = [self getLastModifiedDate:date];
  
  //NSLog(@"date1 : %@", date1);
  //NSLog(@"date2 : %@", date2);
  
  NSTimeInterval since = [date1 timeIntervalSinceDate:date2];
  //NSLog(@"since %f", since);
  
  // dateの方が新しければYES
  if(since<0){
    return YES;
  }else{
    return NO;
  }
}


// 動画ファイルのURLを記録
- (void) saveMovieURL:(NSString*)dir url:(NSString*)url
{
  // キャッシュディレクトリ内にディレクトリを生成
  [self makeDir:dir];
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *pathName = [documentsDirectory stringByAppendingPathComponent:dir];
  NSString *fileName = [pathName stringByAppendingPathComponent:movieURLFileName];
  BOOL boo = [url writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
  if( boo != true ){
    NSLog(@"movie url  file  Saving Error!");
	}
}

// 動画ファイルのURLを取得
- (NSString*) loadProductMovieFileURL:(NSString*)dir
{
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *pathName = [documentsDirectory stringByAppendingPathComponent:dir];
  NSString *fileName = [pathName stringByAppendingPathComponent:movieURLFileName];
  
  //NSLog(@" loade url file : %@", fileName);
  NSString *urlStr = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
  
  return urlStr;
}

// 動画ファイルが存在するかチェック
- (BOOL) existProductMovieFile:(NSString*)dir
{
  [self makeDir:dir];
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *pathName = [documentsDirectory stringByAppendingPathComponent:dir];
  NSString *fileName = [pathName stringByAppendingPathComponent:movieFileName];
  
  //NSLog(@"exit chk file : %@", fileName);
  NSFileManager *fm = [NSFileManager defaultManager];
  return [fm fileExistsAtPath:fileName];
}

// ディレクトリを指定して動画を保存
- (void) saveProductMovieFile:(NSString*)dir data:(NSData*)data
{
  // キャッシュディレクトリ内にディレクトリを生成
  [self makeDir:dir];
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *pathName = [documentsDirectory stringByAppendingPathComponent:dir];
  
  //NSLog(@"save image : %@ : %@", dir , name);
  
  BOOL ok = [data writeToFile:[pathName stringByAppendingPathComponent:movieFileName] atomically:YES];
	if( ok != true ){
    NSLog(@"File Saving Error!");
	}
}

// ディレクトリを指定して動画ファイルの属性を返却
- (NSDictionary*) getProductMovieData:(NSString*)dir
{
  // キャッシュディレクトリ内にディレクトリを生成
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *pathName = [documentsDirectory stringByAppendingPathComponent:dir];
  NSString *fileName = [pathName stringByAppendingPathComponent:movieFileName];
  
  NSFileManager *fm = [NSFileManager defaultManager];
  NSError *error;
  NSDictionary *att = [fm attributesOfItemAtPath:fileName error:&error];
  //NSLog(@"attr : %@", att);
  return att;
}

// 動画ファイルの属性を返却
- (NSDate*) getMovieFileCreatedTime:(NSString*)dir
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *pathName = [documentsDirectory stringByAppendingPathComponent:dir];
  NSString *fileName = [pathName stringByAppendingPathComponent:movieFileName];
  
  NSFileManager *fm = [NSFileManager defaultManager];
  NSError *error;
  
  NSDictionary *att = [fm attributesOfItemAtPath:fileName error:&error];
  return [att objectForKey:@"NSFileModificationDate"];
  
}

// 動画ファイル保存最終日時とSOQLのdateを比較  (YESの場合に更新ファイルを取得）
- (BOOL) compareMovieDate:(NSString*)dir DBdate:(NSString*)date
{
  // ファイルが存在しなければYES
  if(![self existProductMovieFile:dir]) return YES;
  
  // ファイル生成最終日時
  NSDate *date1 = [self getMovieFileCreatedTime:dir];
  
  // SOQLで取得した日付
  NSDate *date2 = [self getLastModifiedDate:date];
  
  //NSLog(@"date1 : %@", date1);
  //NSLog(@"date2 : %@", date2);
  
  NSTimeInterval since = [date1 timeIntervalSinceDate:date2];
  //NSLog(@"since %f", since);
  
  // DB のdateの方が新しければYES
  if(since<0){
    return YES;
  }else{
    return NO;
  }
}

//動画ファイルをロード
- (NSData*) loadProductMovieFile:(NSString*)dir
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *pathName = [documentsDirectory stringByAppendingPathComponent:dir];
  NSString *fileName = [pathName stringByAppendingPathComponent:movieFileName];
  
  //NSLog(@" loade file : %@", fileName);
  
  NSData *data = [NSData dataWithContentsOfFile:fileName];
  
  return data;
}

- (UIImage*)getThmubnailImage:(NSString*)dir
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *pathName = [documentsDirectory stringByAppendingPathComponent:dir];
  NSString *fileName = [pathName stringByAppendingPathComponent:movieFileName];
  
  NSURL *url = [NSURL fileURLWithPath:fileName];
  MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:url];
  player.shouldAutoplay = NO;
  UIImage *image = [player thumbnailImageAtTime:10.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
  return image;
}

-(NSInteger)getCurrentSecond
{
  NSDate *now = [NSDate date];
  
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSUInteger flags;
  NSDateComponents *comps;
  
  flags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
  comps = [calendar components:flags fromDate:now];
  
  //NSInteger hour = comps.hour;
  //NSInteger minute = comps.minute;
  NSInteger second = comps.second;
  //NSLog(@"%d", second);
  return second;
}

@end
