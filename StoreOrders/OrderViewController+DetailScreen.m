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



#import "OrderViewController+DetailScreen.h"
#import "OrderDefine.h"
#import "PDFSelectPopUpViewController.h"

@implementation OrderViewController (DetailScreen)
static NSString *const movieFileName = @"movie.mp4";

-(void)buildDetailWindow:(Product*)prd
{
	//小画面表示中
	dispChildScreen = YES;
	
	//PDFリスト取得
	[self retrivePDF:prd];
	
	orderDetailScreen.detailPrimaryImage.userInteractionEnabled = YES;
	selPrd = prd;
	
  // ボタン無効、透明ビューの配置
  [btnBuilder dismissMenu];
  metricsBtn.enabled = NO;
	mapBtn.enabled = NO;
	ordersBtn.enabled = NO;
	chatterBtn.enabled = NO;
  self.navigationItem.leftBarButtonItem.enabled = NO;
  
  clearView = [[UIView alloc] initWithFrame:self.view.frame];
  clearView.backgroundColor = [UIColor blackColor];
  clearView.alpha = 0.0;
  closeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closePushed)];
	closeTap.numberOfTapsRequired = 1;
	[clearView addGestureRecognizer:closeTap];
  [self.view addSubview:clearView];
  
  // 詳細画面表示クラス
  NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"OrderDetailScreen" owner:nil options:nil];
  for (id currentObject in objects) {
    if ([currentObject isKindOfClass:[OrderDetailScreen class]]) {
      orderDetailScreen = (OrderDetailScreen*)currentObject;
      break;
    }
  }
  
  [orderDetailScreen.detailWindowView setBackgroundColor:[UIColor whiteColor]];
	[orderDetailScreen.detailWindowView.layer setBorderWidth:1.0f];
	[orderDetailScreen.detailWindowView.layer setShadowColor:[[UIColor blackColor]CGColor]];
	[orderDetailScreen.detailWindowView.layer setShadowOpacity:0.5f];
  
	orderDetailScreen.detailPrimaryImage.frame = CGRectMake(20, 49, 390, 334);
	orderDetailScreen.detailSubImage1.frame = CGRectMake(422, 49, 390, 334);
  
	
	[orderDetailScreen.titleLbl setText:[pData getDataForKey:@"DEFINE_STORORDER_LABEL_INFO"]];
  
  [orderDetailScreen.detailCloseBtn setTitle:[pData getDataForKey:@"DEFINE_STORORDER_LABEL_CLOSE"] forState:UIControlStateNormal];
	[orderDetailScreen.detailCloseBtn addTarget:self action:@selector(closePushed) forControlEvents:UIControlEventTouchUpInside];
  
	[orderDetailScreen.detailmovieBtn setTitle:[pData getDataForKey:@"DEFINE_STORORDER_LABEL_MOVIE"] forState:UIControlStateNormal];
	[orderDetailScreen.detailmovieBtn setTitle:[pData getDataForKey:@"DEFINE_STORORDER_LABEL_MOVIE"] forState:UIControlStateHighlighted];
  //	[orderDetailScreen.detailmovieBtn addTarget:self action:@selector(movieBtnPushed) forControlEvents:UIControlEventTouchUpInside];
	
  
	orderDetailScreen.detailDescriptionBack.backgroundColor = [UIColor colorWithRed:0.46f green:0.78f blue:0.90f alpha:1.0f];
	
	// 角丸
  orderDetailScreen.detailDescriptionBack.layer.cornerRadius = 5;
	
	if ([um chkString:prd.movieURL] ) {
		playBtn.enabled = YES;
		selectedMovieURL = prd.movieURL;
	}
	else {
		playBtn.enabled = NO;
		selectedMovieURL = @"";
	}
	
  //ナビゲーションバー　設定
	um = [UtilManager sharedInstance];
	NSData *iData =[um navBarType];
	if ( [((NSString*)iData) isEqualToString:@"gray"] ) {
		[orderDetailScreen.detailTitleBar setBackgroundColor:[UIColor grayColor]];
		[orderDetailScreen.detailDescriptionBack setBackgroundColor:[UIColor grayColor]];
	}
	else if ( [((NSString*)iData) isEqualToString:@"black"] ) {
		[orderDetailScreen.detailTitleBar setBackgroundColor:[UIColor blackColor]];
		[orderDetailScreen.detailDescriptionBack setBackgroundColor:[UIColor blackColor]];
	}
	else {
		iData =[um navBarImage];
		if ( iData ) {
			UIImage *img = [UIImage imageWithData:iData];
			[orderDetailScreen.detailTitleBar setBackgroundColor:[UIColor colorWithPatternImage:img]];
		}
	}
  
	//画像格納用配列初期化
	imgArray = [NSMutableDictionary dictionary];
	
	//画像の初期サイズ保存
	//	primaryImageOrgFrame = CGRectMake(20, 40, 406, 430);//orderDetailScreen.detailPrimaryImage.frame;
	primaryImageOrgFrame = orderDetailScreen.detailPrimaryImage.frame;
	subImageOrgFrame = orderDetailScreen.detailSubImage1.frame;
	
	//主画像を表示
	[imgArray setObject:prd.image forKey:@"0"];
	
	sTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgTapDetect:)];
	sTap.numberOfTapsRequired = 1;
  
	
	//Description設定
	if ([um chkString:prd.description]) {
		orderDetailScreen.detailDescription.text = prd.description;
	}
	//orderDetailScreen.detailDescription.userInteractionEnabled = NO;
	
  orderDetailScreen.alpha = 0.0;
  [self.view addSubview:orderDetailScreen];
  
  // フリップ移動前処理
  [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.01];
  //orderDetailScreen.frame = CGRectMake((self.view.bounds.size.width-430)/2, (self.view.bounds.size.height-500)/2, 430, 250);
  orderDetailScreen.frame = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2, 836,560);
  orderDetailScreen.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
  [UIView setAnimationDidStopSelector:@selector(dispViewAppear:finished:context:)];
	[UIView commitAnimations];
  
	//画像取得
	[self getProductImages:prd];
	
	//サムネイルを半透明で覆う
	UIView *mask = [[UIView alloc]initWithFrame:orderDetailScreen.detailSubImage1.frame];
	[mask setBackgroundColor:[UIColor whiteColor]];
	mask.alpha = 0.3f;
	[orderDetailScreen addSubview:mask];
	[orderDetailScreen bringSubviewToFront:playBtn];
	
	//再生ボタン
	playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[playBtn setImage:[UIImage imageNamed:@"Play.png"] forState:UIControlStateNormal];
	[playBtn addTarget:self action:@selector(playPushed) forControlEvents:UIControlEventTouchUpInside];
	CGRect rect = CGRectMake(0, 0, 78, 78);
	playBtn.frame = rect;
	playBtn.center = orderDetailScreen.detailSubImage1.center;
	[orderDetailScreen addSubview:playBtn];
	
	[self dispMovieThumnail:prd];
	
  NSData *mData = [um loadProductMovieFile:prd.productId];
	if ( [mData length]){
    [mask addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playPushed)]];
  }
  
  // 詳細画像表示
  [self doInit];
  [orderDetailScreen.detailPrimaryImage addSubview:[self getLabelForIndex:[imgArray count]*1000]];
}
-(void)buildPDFButton
{
	pdfBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[pdfBtn setImage:[UIImage imageNamed:@"PDF.png"] forState:UIControlStateNormal];
	[pdfBtn addTarget:self action:@selector(pdfBtnPushed) forControlEvents:UIControlEventTouchUpInside];
	//pdfBtn.frame = CGRectMake(590,420, 38,38);
  pdfBtn.frame = CGRectMake(700,510, 38,38);
	pdfBtn.userInteractionEnabled = YES;
	
	pdfTextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[pdfTextBtn setTitle:@"PDF" forState:UIControlStateNormal];
	pdfTextBtn.titleLabel.font = [UIFont systemFontOfSize:14];
	[pdfTextBtn addTarget:self action:@selector(pdfBtnPushed) forControlEvents:UIControlEventTouchUpInside];
	[pdfTextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	//pdfTextBtn.frame = CGRectMake(634, 430, 40, 20);
  pdfTextBtn.frame = CGRectMake(744, 520, 40, 20);
	[orderDetailScreen addSubview:pdfBtn];
	[orderDetailScreen addSubview:pdfTextBtn];
}

-(void)pdfBtnPushed
{
	PDFSelectPopUpViewController *pdfSel = [[PDFSelectPopUpViewController alloc]init];
	[pdfSel setItemList:selPrd.pdfNameArray];
	pdfSel.delegate = self;
	pop = [[UIPopoverController alloc]initWithContentViewController:pdfSel];
	pop.delegate = self;
	pop.popoverContentSize = pdfSel.view.frame.size;
	[pop presentPopoverFromRect:pdfBtn.frame inView:orderDetailScreen permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}
-(void)didSelectPDF:(int)index
{
	//リクエスト作成
	//SFRestRequest *req =[SFRestRequest requestWithMethod:SFRestMethodGET path:downloadUrl queryParams:nil];
	NSString *instance = [[[[[SFRestAPI sharedInstance] coordinator] credentials] instanceUrl]absoluteString];
	NSString *fullUrl = [instance stringByAppendingString:
                       [selPrd.pdfURLArray objectAtIndex:index]];
	NSURL *myURL = [NSURL URLWithString:fullUrl];
	NSMutableURLRequest *requestDoc = [[NSMutableURLRequest alloc]initWithURL:myURL];
	
	//OAuth認証情報をヘッダーに追加
	NSString *token = [@"OAuth " stringByAppendingString:[[[[SFRestAPI sharedInstance]coordinator]credentials]accessToken]];
	[requestDoc addValue:token forHTTPHeaderField:@"Authorization"];
	
	//viewerViewController内のUIWebviewで表示
	ViewerViewController *vView = [[ViewerViewController alloc]init];
	vView.delegate = self;
	vView.disableIndicator = NO;
	[vView setReq:requestDoc];
	[pop dismissPopoverAnimated:NO];
	
	//ナビゲーションバー　設定
	[self.navigationController.navigationBar setHidden:NO];
	
	//画面遷移
	[self.navigationController pushViewController:vView animated:YES];
}
-(void)dispMovieThumnail:(Product*)prd
{
	
	//動画サムネイル取得
	movieData = [um loadProductMovieFile:prd.productId];
	if ( [movieData length]){
		UIImage *img =  [um getThmubnailImage:prd.productId];
		UIImage *resize = [self resizeImage:img Rect:subImageOrgFrame];
		
		CGImageRef cgref = [img CGImage];
		CIImage *cim = [img CIImage];
		if (cim == nil && cgref == NULL){
			
			//サムネイルが無い場合
			NSLog(@"selectedMovieURL :%@", selectedMovieURL);
			if ( ![selectedMovieURL isEqualToString:@""]){
				//動画URLが設定されている場合
				UIButton *movieBtn = [UIButton buttonWithType:UIButtonTypeCustom];
				[movieBtn setImage:[self forceResizeImage:[UIImage imageNamed:@"Movie.png"] Rect:subImageOrgFrame] forState:UIControlStateNormal];
				//movieBtn.frame = CGRectMake(0, 0, 253, 241);
        movieBtn.frame = CGRectMake(0, 0, 390, 334);
				CGPoint center = playBtn.center;
				//center.y += 10;
				movieBtn.center = center;
				playBtn.center = center;
				[movieBtn addTarget:self action:@selector(playPushed) forControlEvents:UIControlEventTouchUpInside];
				[orderDetailScreen addSubview:movieBtn];
				[orderDetailScreen bringSubviewToFront:playBtn];
        orderDetailScreen.detailSubImage1.userInteractionEnabled = YES;
        [orderDetailScreen.detailSubImage1 addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playPushed)]];
			}
			else {
				//動画URLが設定されていない場合
				UIImageView *noMovieImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"NoMovie.png"]];
				CGPoint center = playBtn.center;
				//center.y += 10;
        noMovieImg.frame = CGRectMake(0, 0, 390, 334);
				noMovieImg.center = center;
				playBtn.center = center;
				[playBtn removeFromSuperview];
				[orderDetailScreen addSubview:noMovieImg];
			}
			
			return;
		}
		
		NSLog(@"%@",prd.productId);
		orderDetailScreen.detailSubImage1.image =resize;
		orderDetailScreen.detailSubImage1.frame = [self allignCenter:subImageOrgFrame size:resize.size];
    //orderDetailScreen.detailSubImage1.userInteractionEnabled = YES;
    //[orderDetailScreen.detailSubImage1 addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playPushed)]];
    
		//ローカル保存された動画URL
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *pathName = [documentsDirectory stringByAppendingPathComponent:prd.productId];
		NSString *fileName = [pathName stringByAppendingPathComponent:movieFileName];
		selectedMovieURL = fileName;
		playBtn.enabled = YES;
		return;
	}
	
	if ( ![selectedMovieURL isEqualToString:@""]){
		//動画URLが設定されている場合
		UIButton *movieBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[movieBtn setImage:[self forceResizeImage:[UIImage imageNamed:@"Movie.png"] Rect:subImageOrgFrame] forState:UIControlStateNormal];
		//movieBtn.frame = CGRectMake(0, 0, 253, 241);
    movieBtn.frame = CGRectMake(0, 0, 390, 334);
		CGPoint center = playBtn.center;
		//center.y += 10;
		movieBtn.center = center;
		playBtn.center = center;
		[movieBtn addTarget:self action:@selector(playPushed) forControlEvents:UIControlEventTouchUpInside];
		[orderDetailScreen addSubview:movieBtn];
		[orderDetailScreen bringSubviewToFront:playBtn];
    //orderDetailScreen.detailSubImage1.userInteractionEnabled = YES;
    //[orderDetailScreen.detailSubImage1 addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playPushed)]];
    
	}
	else {
		//動画URLが設定されていない場合
		UIImageView *noMovieImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"NoMovie.png"]];
		CGPoint center = playBtn.center;
		//center.y += 10;
    noMovieImg.frame = CGRectMake(0, 0, 390, 334);
		noMovieImg.center = center;
		playBtn.center = center;
		[playBtn removeFromSuperview];
		[orderDetailScreen addSubview:noMovieImg];
	}
	
  //	else{
  //動画URLが設定されていない場合
  //    UIImageView *noMovieImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"NoMovie.png"]];
  //    CGPoint center = playBtn.center;
  //    center.y += 10;
  //    noMovieImg.center = center;
  //    playBtn.center = center;
  //    [playBtn removeFromSuperview];
  //    [orderDetailScreen addSubview:noMovieImg];
  //  }
}

-(void)playPushed
{
	//リクエスト作成
	NSURL *myURL = [NSURL URLWithString:selectedMovieURL];
	NSMutableURLRequest *requestDoc = [[NSMutableURLRequest alloc]initWithURL:myURL];
	
	//viewerViewController内のUIWebviewで表示
	ViewerViewController *vView = [[ViewerViewController alloc]init];
	vView.delegate = self;
	vView.disableIndicator = YES;
	[vView setReq:requestDoc];
	
	//ナビゲーションバー　設定
	[self.navigationController.navigationBar setHidden:NO];
  
	[pop dismissPopoverAnimated:NO];
	
	//画面遷移
	[self.navigationController pushViewController:vView animated:YES];
}


// フリップ移動
- (void)dispViewAppear:(NSString *)animationID finished:(NSNumber *) finished context:(void *) context
{
  
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDuration:0.6];
  clearView.alpha = 0.3;
  //orderDetailScreen.frame = CGRectMake(170, 30, 697*1.2,467*1.2);
  orderDetailScreen.frame = CGRectMake((self.view.bounds.size.width-836)/2, 30, 836,560);
  //orderDetailScreen.center = self.view.center;
  orderDetailScreen.alpha = 1.0f;
  [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:orderDetailScreen cache:YES];
  [UIView commitAnimations];
}

-(void)retriveMovie:(Product*)prd
{
	NSURL *url = [NSURL URLWithString:prd.movieURL];
  NSLog(@"url ..%@",url);
  // HTTPリクエストオブジェクトを生成
  NSURLRequest *_request = [NSURLRequest
                            requestWithURL:url];
  
  // NSOperationQueueオブジェクトを生成
  NSOperationQueue *queue = [NSOperationQueue mainQueue];
  
  // HTTP非同期通信を行う
  [NSURLConnection sendAsynchronousRequest:_request queue:queue completionHandler:
   // 完了時のハンドラ
   ^(NSURLResponse *res, NSData *data, NSError *error) {
		 @try {
			 // 取得したデータ
			 if(data){
				 
				 //動画登録
				 [um saveProductMovieFile:prd.productId data:data];
				 
				 //サムネイル表示
				 [self dispMovieThumnail:prd];
			 }
			 if(error){
				 NSLog(@"error %@", error);
				 UIAlertView *failAlert = [[UIAlertView alloc]
                                   initWithTitle:nil
                                   message:[pData getDataForKey:@"DEFINE_TOP_ALERT_IMAREADERRMSG"]
                                   delegate:self
                                   cancelButtonTitle:nil
                                   otherButtonTitles:[pData getDataForKey:@"DEFINE_TOP_ALERTOK"], nil ];
				 
				 [failAlert show];
			 }
		 }
		 @catch (NSException *exception) {
			 NSLog(@"main:Caught %@:%@", [exception name], [exception reason]);
		 }
		 @finally {
		 }
	 }];
}

-(void)getProductImages:(Product*)prd
{
  // OrderViewController.mでmain.jpgを配列の最後に必ず入れているため
	int loopMax;
	if ( [prd.imgURLArray count] >=3 ) {
		loopMax = 2;
	}
	else {
		loopMax = [prd.imgURLArray count]-1;
	}
	
	[pData setData:prd.productId forKey:@"productId"];
  [pData setData:prd.imgNameArray forKey:@"imgNameArray"];
  [pData setData:prd.imgURLArray forKey:@"imgURLArray"];
  [pData setData:prd.imgIdArray forKey:@"imgIdArray"];
  [pData setData:prd.imgDateArray forKey:@"imgDateArray"];
  
	//サムネイル表示。Index=0は、main画像が使ってるためindex=1以降を使用
	for ( int i = 0; i < loopMax; i++){
		NSString *url = [prd.imgURLArray objectAtIndex:i];
		if ( i == loopMax - 1) {
			[self getProductImage:url index:i + 1 last:YES];
		}
		else {
			[self getProductImage:url index:i + 1 last:NO];
		}
	}
	
  [pData setData:@"" forKey:@"productId"];
  [pData setData:@"" forKey:@"imgNameArray"];
  [pData setData:@"" forKey:@"imgURLArray"];
  [pData setData:@"" forKey:@"imgDateArray"];
  [pData setData:@"" forKey:@"imgIdArray"];
  
	// アラートを閉じる
	if(alertView.visible) {
		[alertView dismissWithClickedButtonIndex:0 animated:NO];
	}
}
//サムネイル画像上でのタップ検出
-(void)imgTapDetect:(id)sender
{
  //	UILongPressGestureRecognizer *recognizer = (UILongPressGestureRecognizer*)sender;
  //	NSLog(@"tap:%d",recognizer.view.tag);
  //	UIImage *img = [imgArray objectForKey:[NSString stringWithFormat:@"%d",recognizer.view.tag]];
  //	UIImage *resize = [self resizeImage:img Rect:primaryImageOrgFrame];
  //	orderDetailScreen.detailPrimaryImage.frame = [self allignCenter:orderDetailScreen.detailPrimaryImage.frame size:resize.size];
	//	orderDetailScreen.detailPrimaryImage.image = resize;
}


-(void)getProductImage:(NSString*)url index:(int)index last:(bool)last
{
	if([url isEqual: @"sizeover"]) {
		return;
	}
  
  NSString *productId = [pData getDataForKey:@"productId"];
  NSMutableArray *imgNameArray = [pData getDataForKey:@"imgNameArray"];
  NSMutableArray *imgURLArray = [pData getDataForKey:@"imgURLArray"];
  NSMutableArray *imgIdArray = [pData getDataForKey:@"imgIdArray"];
  //NSMutableArray *imgDateArray = [pData getDataForKey:@"imgDateArray"];
  
  NSLog(@" imgURLArray : %@", imgURLArray);
  NSLog(@" imgNameArray : %@", imgNameArray);
  NSLog(@" imgIdArray : %@", imgIdArray);
  
  // 画像データ
  NSData *rData;
  NSError *err;
  //  UIImage *resize;
  
  // 配列の中から該当するindexを取得
  NSUInteger indexURL = [imgURLArray indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
    return [[imgURLArray objectAtIndex:idx] isEqualToString:url];
  }];
  NSString *imgName = [imgNameArray objectAtIndex:indexURL];
  
  // キャッシュがあればキャッシュを読む
  BOOL isExist = [um existProductFile:productId name:imgName];
  if(isExist){
    rData = [um loadProductFile:productId name:imgName];
  }else{
    //リクエスト作成
    NSString *instance = [[[[[SFRestAPI sharedInstance] coordinator] credentials] instanceUrl]absoluteString];
    NSString *fullUrl = [instance stringByAppendingString:url];
    NSURL *myURL = [NSURL URLWithString:fullUrl];
    NSMutableURLRequest *requestDoc = [[NSMutableURLRequest alloc]initWithURL:myURL];
    
    //OAuth認証情報をヘッダーに追加
    NSString *token = [@"OAuth " stringByAppendingString:[[[[SFRestAPI sharedInstance]coordinator]credentials]	accessToken]];
    [requestDoc addValue:token forHTTPHeaderField:@"Authorization"];
    
    NSURLResponse *resp;
    rData = [NSURLConnection sendSynchronousRequest:requestDoc returningResponse:&resp error:&err];
    // 画像をキャッシュに保存
		[um saveProductFile:productId name:imgName data:rData];
  }
	
	if ( !err || !isExist){
		UIImage *img = [[UIImage alloc]initWithData:rData];
		//画像を配列に保存
		
		NSData* pidata = UIImageJPEGRepresentation(img, 1.0);
		int bytesize = pidata.length;
		
		//画像サイズが閾値より大きい場合は読み込まない
		if ( MAXLOADINGSIZE <=  bytesize) {
			return;
		}
		
		//画像を配列に保存
		[imgArray setObject:img forKey:[NSString stringWithFormat:@"%d",index]];
		
    NSLog(@" imgArray  count %d  index %d", [imgArray count], index);
    NSLog(@"imgName : %@", imgName);
    NSLog(@"url : %@", url);
    
		sTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgTapDetect:)];
		sTap.numberOfTapsRequired = 1;
	}
	else {
		
		// アラートを閉じる
		if(alertView.visible){
			[alertView dismissWithClickedButtonIndex:0 animated:NO];
		}
	}
}

- (NSUInteger)_style
{
	switch (mode) {
		case MPTransitionModeFold:
			return foldStyle;
			
		case MPTransitionModeFlip:
			return flipStyle;
	}
}

- (void)setStyle:(NSUInteger)_style
{
	switch (mode) {
		case MPTransitionModeFold:
			foldStyle = _style;
			break;
			
		case MPTransitionModeFlip:
			flipStyle = _style;
			break;
	}
}

- (UIView *)getLabelForIndex:(NSUInteger)index
{
	UIView *container = [[UIView alloc] initWithFrame:orderDetailScreen.detailPrimaryImage.bounds];
  
	container.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[container setBackgroundColor:[UIColor whiteColor]];
	
  int num = [imgArray count];
  int idx = index % num;
  
  //UIView *iv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 291, 241)];
  //UIView *iv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 390, 334)];
  UIView *iv = [[UILabel alloc] initWithFrame:CGRectInset(container.bounds, 15, 15)];
  iv.backgroundColor = [UIColor whiteColor];
  //UIImage *tmpimg = [ self resizeImage:[imgArray objectForKey:[NSString stringWithFormat:@"%d",idx]] Rect:CGRectMake(0,0,291,241)];
  //UIImage *tmpimg = [ self resizeImage:[imgArray objectForKey:[NSString stringWithFormat:@"%d",idx]] Rect:CGRectMake(0, 0, 390, 334)];
  UIImage *tmpimg = [ self resizeImage:[imgArray objectForKey:[NSString stringWithFormat:@"%d",idx]] Rect:iv.frame];
  UIImageView *tmpiv = [[UIImageView alloc]initWithImage:tmpimg];
  tmpiv.center = container.center;
  
  // スワイプ
  tmpiv.userInteractionEnabled = YES;
  rightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)];
  rightGesture.direction = UISwipeGestureRecognizerDirectionRight;
  [tmpiv addGestureRecognizer:rightGesture];
  [iv addGestureRecognizer:rightGesture];
  [container addGestureRecognizer:rightGesture];
  
  leftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];
  leftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
  [tmpiv addGestureRecognizer:leftGesture];
  [iv addGestureRecognizer:leftGesture];
  [container addGestureRecognizer:leftGesture];
  
  [container addSubview:tmpiv];
  
	container.tag = index;
	[container.layer setBorderColor:[[UIColor colorWithWhite:0.85 alpha:1] CGColor]];
	[container.layer setBorderWidth:2];
	
	return container;
}

-(void)swipeUp:(id)sender
{
  swipeIndex++;
  [self imageChanged:swipeIndex];
}

-(void)swipeDown:(id)sender
{
  swipeIndex--;
  [self imageChanged:swipeIndex];
}

- (void)imageChanged:(int)val {
	UIView *previousView = [[orderDetailScreen.detailPrimaryImage subviews] objectAtIndex:0];
	UIView *nextView = [self getLabelForIndex:val];
	BOOL forwards = nextView.tag > previousView.tag;
  
  [MPFoldTransition transitionFromView:previousView
                                toView:nextView
                              duration:[MPFoldTransition defaultDuration]
                                 style:forwards?  foldStyle	: MPFoldStyleFlipFoldBit(foldStyle)
                      transitionAction:MPTransitionActionAddRemove
                            completion:^(BOOL finished) {}
   
   ];
  
}

- (void)doInit
{
	mode = MPTransitionModeFold;
	foldStyle = MPFoldStyleCubic;
	flipStyle = MPFlipStyleDefault;
  swipeIndex = [imgArray count] * 1000;
}

// 詳細画面を戻す
-(void)closePushed
{
  // フリップ移動
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:0.8];
  clearView.alpha = 0.0;
  orderDetailScreen.alpha = 0.0;
  //orderDetailScreen.frame = CGRectMake((self.view.bounds.size.width-430)/2, (self.view.bounds.size.height-500)/2, 430, 250);
  orderDetailScreen.frame = CGRectMake((self.view.bounds.size.width-836)/2, (self.view.bounds.size.height-560)/2, 836,560);
  orderDetailScreen.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
  [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:orderDetailScreen cache:YES];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(clearViewDisappear:finished:context:)];
  [UIView commitAnimations];
  
}

// 詳細画面を削除
- (void)clearViewDisappear:(NSString *)animationID finished:(NSNumber *) finished context:(void *) context
{
	imgArray = nil;
	dispChildScreen = NO;
  
  [orderDetailScreen removeFromSuperview];
  [clearView removeFromSuperview];
  metricsBtn.enabled = YES;
	mapBtn.enabled = YES;
	ordersBtn.enabled = YES;
	chatterBtn.enabled = YES;
  self.navigationItem.leftBarButtonItem.enabled = YES;
}

//PDFのURL取得
-(void)retrivePDF:(Product*)prd;
{
	pdfBtn.enabled = NO;
	NSString *query = [NSString stringWithFormat:@"SELECT Name,Body,BodyLength,ContentType FROM Attachment WHERE ParentId='%@' ORDER BY CreatedDate DESC",prd.productId];
	SFRestRequest *req = [[SFRestAPI sharedInstance] requestForQuery:query];
	[[SFRestAPI sharedInstance] sendRESTRequest:req
                                    failBlock:^(NSError *e) {
                                      NSLog(@"FAILWHALE with error: %@", [e description] );
                                      //エラーアラート
                                      alertView = [[UIAlertView alloc]
                                                   initWithTitle:[pData getDataForKey:@""]
                                                   message:[pData getDataForKey:@""]
                                                   delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:[pData getDataForKey:@""], nil ];
                                      [alertView show];
                                    }
                                completeBlock:^(id jsonResponse){
                                  NSDictionary *dict = (NSDictionary *)jsonResponse;
                                  NSLog(@"%@",dict);
                                  
                                  //アラート表示
                                  //									  [self alertShow];
                                  //									  [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
                                  NSArray *records = [dict objectForKey:@"records"];
                                  
                                  //保存用配列を初期化
                                  prd.pdfNameArray = [NSMutableArray array];
                                  prd.pdfURLArray = [NSMutableArray array];
                                  
                                  for ( int i = 0; i< [records count]; i++ ){
                                    NSDictionary *rec = [records objectAtIndex:i];
                                    NSString *type = [rec objectForKey:@"ContentType"];
                                    if ( [type isEqualToString:@"application/pdf"] ){
                                      NSString *url = [rec objectForKey:@"Body"];
                                      NSString *name = [rec objectForKey:@"Name"];
                                      [prd.pdfURLArray addObject:url];
                                      [prd.pdfNameArray addObject:name];
                                      pdfBtn.enabled = YES;
                                      [self buildPDFButton];
                                    }
                                  }
                                }
	 ];
}





@end
