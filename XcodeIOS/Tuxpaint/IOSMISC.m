//
//  IOSMISC.m
//  Tuxpaint
//
//  Created by dev on 14-11-18.
//  Copyright (c) 2014年 happymobile. All rights reserved.
//
@import CoreLocation;
#import "IOSMISC.h"
#import "BaiduMobAdView.h"
#import "CJSONDeserializer.h"
#import "SDL.h"
#import <UIKit/UIActivityViewController.h>
void IOSStopTextInput(SDL_Window * sdlWindow, float x, float y);
UIImage* GetImage(SDL_Surface *surface, int sw, int sh);
@implementation IOSMISC
@synthesize ADRect = ADRect_;
@synthesize ADRect_center = ADRect_center_;
@synthesize rBtn = rBtn_;
@synthesize PView = Pview_;
@synthesize rootview = rootview_;
@synthesize PWindow = PWindow_;
@synthesize screen_scale = screen_scale_;
@synthesize textview = textview_;
@synthesize btnOK = btnOK_;
@synthesize textField = textFiled_;
@synthesize shareSurf = shareSurf_;
@synthesize screenDim = screenDim_;

#pragma mark - activity source
- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return [[UIImage alloc] init];
}
- (id)activityViewController:(UIActivityViewController *)activityViewController
         itemForActivityType:(NSString *)activityType
{
    UIImage *image = GetImage(shareSurf_, screenDim_.size.width, screenDim_.size.height);
    image_ = image;
    return image;
}


- (UIImage *)activityViewController:(UIActivityViewController *)activityViewController
      thumbnailImageForActivityType:(NSString *)activityType
                      suggestedSize:(CGSize)size
{
    return [UIImage imageWithImage:image_ scaledToFillToSize:size];
}
#pragma mark - sharing
void IOSSharingWeixin(SDL_Surface* surf, int type, int sw, int sh);
enum {
    WXSESSION = 1,
    WXTIMELINE
};
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self] applicationActivities:nil];
    switch (buttonIndex) {
#ifdef TUX_LANG_ZH_CN
        case 0:
#else
        case 3:
#endif
            IOSSharingWeixin(shareSurf_, WXSESSION, screenDim_.size.width, screenDim_.size.height);
            break;
#ifdef TUX_LANG_ZH_CN
        case 1:
#else
        case 4:
#endif
            IOSSharingWeixin(shareSurf_, WXTIMELINE, screenDim_.size.width, screenDim_.size.height);
            break;
        case 7:
            //cancel button
            break;
        default:
            [PWindow_.rootViewController presentViewController:activityViewController animated:YES completion:nil];
            
            /*if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                //iPhone, present activity view controller as is
                [PWindow_.rootViewController presentViewController:activityViewController animated:YES completion:nil];
            }
            else
            {
                //iPad, present the view controller inside a popover
                if (![self.activityPopover isPopoverVisible]) {
                    self.activityPopover = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
                    [self.activityPopover presentPopoverFromRect:[self.shareImageButton frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                }
                else
                {
                    //Dismiss if the button is tapped while pop over is visible
                    [self.activityPopover dismissPopoverAnimated:YES];
                }
            }*/

            break;
    }
}
#pragma mark - advertisement
- (NSString*) appSpec
{
    //注意：该计费名为测试用途，不会产生计费，请测试广告展示无误以后，替换为您的应用计费名，然后提交AppStore.
    return @"debug";
}

- (NSString *)publisherId
{
    return  @"debug"; //@"your_own_app_id";
}

-(BOOL) enableLocation
{
    //启用location会有一次alert提示
    //return NO;
    CLLocationManager *manager = [[CLLocationManager alloc] init];
    if ([manager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [manager requestWhenInUseAuthorization];
    }
    manager = nil;
    return YES;
}


-(void) willDisplayAd:(BaiduMobAdView*) adview
{
    //在广告即将展示时，产生一个动画，把广告条加载到视图中
    sharedAdView.hidden = NO;
    CGRect f = sharedAdView.frame;
    f.origin.x = -320;
    sharedAdView.frame = f;
    [UIView beginAnimations:nil context:nil];
    f.origin.x = 0;
    sharedAdView.frame = f;
    [UIView commitAnimations];
    NSLog(@"delegate: will display ad");
    [self postAD];
    
}

-(void) failedDisplayAd:(BaiduMobFailReason) reason;
{
    NSLog(@"delegate: failedDisplayAd %d", reason);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark GADRequest generation

- (GADRequest *)request {
    GADRequest *request = [GADRequest request];
    
    // Make the request for a test ad. Put in an identifier for the simulator as well as any devices
    // you want to receive test ads.
    /*request.testDevices = @[
                            // TODO: Add your device/simulator test identifiers here. Your device identifier is printed to
                            // the console when the app is launched.
                            GAD_SIMULATOR_ID,
                            @"728619fcf307ab31e90d5a8cffb4bcd6",
                            @"e9a8b6f68a516a03d861c7829d3d719b"
                            ];*/
    GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[ kGADSimulatorID ];
    return request;
}

#pragma mark GADBannerViewDelegate implementation

- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"Received ad successfully");
    [self postAD];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
}
-(IBAction)ADCloseClicked:(id)sender
{
    if (products.count) {
        SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:products[0]];
        payment.quantity = 1;
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    
}
-(void) HideAD
{
    if (Pview_) {
        Pview_.hidden = YES;
    }
}
- (void)paymentQueue:(SKPaymentQueue *)queue
 updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
                // Call the appropriate custom method for the transaction state.
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"SKPaymentTransactionStatePurchasing");
                break;
            case SKPaymentTransactionStateDeferred:
                NSLog(@"SKPaymentTransactionStateDeferred");
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"SKPaymentTransactionStateFailed");
                break;
            case SKPaymentTransactionStatePurchased:
            {
                bNoAD = YES;
#ifdef USE_ICLOUD_STORAGE
                NSUbiquitousKeyValueStore *storage = [NSUbiquitousKeyValueStore defaultStore];
#else
                NSUserDefaults *storage = [NSUserDefaults standardUserDefaults];
#endif
                [storage setBool:YES forKey:UD_NOAD_KEY];
                [storage synchronize];
                [self HideAD];
                NSLog(@"SKPaymentTransactionStatePurchased");
                break;
            }
            case SKPaymentTransactionStateRestored:
                NSLog(@"SKPaymentTransactionStateRestored");
                break;
            default:
                // For debugging
                NSLog(@"Unexpected transaction state %@", @(transaction.transactionState));
                break;
        }
    }
}
-(void)postAD
{
//    if(! btn){
//        btn = [[UIButton alloc] init];
//        btn.backgroundColor = [UIColor whiteColor];
//        [btn setBackgroundImage:[UIImage imageNamed:@"close.jpg"] forState:UIControlStateNormal];
//        btn.frame = CGRectMake(320, 0, rBtn_.size.width, rBtn_.size.height);
//        [btn addTarget:self action:@selector(ADCloseClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [Pview_ addSubview:btn];
//    }
}

-(void) startAD
{
//    // Use predefined GADAdSize constants to define the GADBannerView.
//    admobView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:ADRect_.origin];
//    // Note: Edit SampleConstants.h to provide a definition for kSampleAdUnitID before compiling.
//    if (![[admob_id valueForKey:@"default"] isKindOfClass:[NSString class]] || [[admob_id valueForKey:@"default"] isEqualToString:@""]) {
//        admobView.adUnitID = DEFAULT_ADMOB_ID;
//    } else {
//        admobView.adUnitID = [admob_id valueForKey:@"default"];
//    }
//    
//    admobView.delegate = self;
//    admobView.rootViewController = PWindow_.rootViewController;
//    //[self.PView addSubview:admobView];
//    [PWindow_.subviews[0] addSubview:admobView];
//    [admobView loadRequest:[self request]];
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    bscale_x = 1;
    bcenter_ad = 0;
#ifndef TUX_LANG_ZH_CN
    ad_type = ADMOB;
#else
    ad_type = BAIDU;
#endif
#ifdef USE_ICLOUD_STORAGE
    NSUbiquitousKeyValueStore *storage = [NSUbiquitousKeyValueStore defaultStore];
#else
    NSUserDefaults *storage = [NSUserDefaults standardUserDefaults];
#endif
    bNoAD = NO;
    //bNoAD = [storage boolForKey:UD_NOAD_KEY];
//    if (!bNoAD) {
//        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[[NSSet alloc]initWithObjects:@"com.happymobile.Tuxpaint.noad3", nil]];
//        productsRequest.delegate = self;
//        [productsRequest start];
//    }
    //it get other config from server, so we still need the following
    [self loadADURL];
}
-(void) startADInternal
{
    //return;
    if (bNoAD) {
        return;
    }
    Pview_ = [[UIView alloc] init];
    if (bcenter_ad) {
        Pview_.frame = ADRect_center_;
    } else Pview_.frame =  ADRect_;
    float scale_f;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        scale_f = 1;
        bscale_x = 0;
    } else scale_f = 1*56*screen_scale_/[[UIScreen mainScreen] scale]/48;
    Pview_.transform = CGAffineTransformScale(CGAffineTransformIdentity, bscale_x?scale_f:1, scale_f);
    if (ad_type == ADMOB) {
        // Use predefined GADAdSize constants to define the GADBannerView.
        admobView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:CGPointMake(0, 0)];
        // Note: Edit SampleConstants.h to provide a definition for kSampleAdUnitID before compiling.
        if (![[admob_id valueForKey:@"default"] isKindOfClass:[NSString class]] || [[admob_id valueForKey:@"default"] isEqualToString:@""]) {
            admobView.adUnitID = DEFAULT_ADMOB_ID;
        } else {
            admobView.adUnitID = [admob_id valueForKey:@"default"];
        }
        //admobView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
        admobView.delegate = self;
        admobView.rootViewController = PWindow_.rootViewController;
        //[self.PView addSubview:admobView];
        [rootview_ addSubview:Pview_];
        [Pview_ addSubview:admobView];
//        #define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
//        // Rotate 90 degrees to hide it off screen
//        CGAffineTransform rotationTransform = CGAffineTransformIdentity;
//        rotationTransform = CGAffineTransformRotate(rotationTransform, DEGREES_TO_RADIANS(90));
//        admobView.transform = rotationTransform;
        [admobView loadRequest:[self request]];
    }else {
        
        /*//使用嵌入广告的方法实例。
        sharedAdView = [[BaiduMobAdView alloc] init];
        //sharedAdView.AdUnitTag = @"myAdPlaceId1";
        //此处为广告位id，可以不进行设置，如需设置，在百度移动联盟上设置广告位id，然后将得到的id填写到此处。
        sharedAdView.AdType = BaiduMobAdViewTypeBanner;
        sharedAdView.frame = ADRect_;
        sharedAdView.delegate = self;
        [Pview_ addSubview:sharedAdView];
        [sharedAdView start];*/
    }
    //[self postAD];
}

#pragma mark - LoadURL

- (void) loadADURL {
    responseData            = [[NSMutableData alloc]init];
    NSString  *URLString    = API_Get_Advertisement;
    NSString* userAgent     = USER_AGENT;
    NSURL* url = [NSURL URLWithString:URLString];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url] ;
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    MyConnection            = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark - Connections

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"error: %@",error);
    [self startADInternal];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [connection cancel];
    
    NSError *error = nil;
    NSDictionary *resultDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:responseData error:&error];
 
    if (([resultDict isKindOfClass:[NSDictionary class]])) {
        NSLog(@"resultDict = %@",resultDict);
        [[NSUserDefaults standardUserDefaults] setValue:[resultDict valueForKey:@"ad_network"] forKey:@"currentAD"];
        if ([[resultDict valueForKey:@"center_ad"] isEqualToString:@"YES"]) {
            bcenter_ad = 1;
        } else if ([[resultDict valueForKey:@"center_ad"] isEqualToString:@"NO"]) bcenter_ad = 0;
        if ([[resultDict valueForKey:@"ad_network"] isEqualToString:@"baidu"]) {
            ad_type = BAIDU;
        } else ad_type = ADMOB;
        if ([[resultDict valueForKey:@"scale_x"] isEqualToString:@"NO"]) bscale_x = 0;
        else if ([[resultDict valueForKey:@"scale_x"] isEqualToString:@"YES"]) bscale_x = 1;
             
        admob_id = [[resultDict valueForKey:@"admob_id"] copy];
        //NSLog(@"%@", COMMON.ADMOB_ID);
        //[[NSUserDefaults standardUserDefaults] setValue:@"mobwin" forKey:@"currentAD"];
    }
    [self startADInternal];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{

//    UIView *view = PWindow_.subviews[0];
//    printf("aaaaaa%f %f %f %f\n", PWindow_.frame.origin.x, PWindow_.frame.origin.y, PWindow_.frame.size.width,PWindow_.frame.size.height);
//    printf("----%f %f %f %f---aaaaa\n", view.frame.origin.x, view.frame.origin.y, view.frame.size.width,view.frame.size.height);
    IOSStopTextInput(NULL, 0, 0);
    return YES;
}
#pragma mark - weixin
-(void) onReq:(BaseReq*)req
{
    /*if([req isKindOfClass:[GetMessageFromWXReq class]])
    {
        // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
        NSString *strTitle = [NSString stringWithFormat:@"微信请求App提供内容"];
        NSString *strMsg = @"微信请求App提供内容，App要调用sendResp:GetMessageFromWXResp返回给微信";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag = 1000;
        [alert show];
    }
    else if([req isKindOfClass:[ShowMessageFromWXReq class]])
    {
        ShowMessageFromWXReq* temp = (ShowMessageFromWXReq*)req;
        WXMediaMessage *msg = temp.message;
        
        //显示微信传过来的内容
        WXAppExtendObject *obj = msg.mediaObject;
        
        NSString *strTitle = [NSString stringWithFormat:@"微信请求App显示内容"];
        NSString *strMsg = [NSString stringWithFormat:@"标题：%@ \n内容：%@ \n附带信息：%@ \n缩略图:%u bytes\n\n", msg.title, msg.description, obj.extInfo, msg.thumbData.length];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];

    }
    else if([req isKindOfClass:[LaunchFromWXReq class]])
    {
        //从微信启动App
        NSString *strTitle = [NSString stringWithFormat:@"从微信启动"];
        NSString *strMsg = @"这是从微信启动的消息";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }*/
}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        //NSString *strTitle = [NSString stringWithFormat:@"发送媒体消息结果"];
        NSString *strMsg = [NSString stringWithFormat:@"result errcode:%d", resp.errCode];
        NSLog(@"%@", strMsg);
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];*/
    }
}
#pragma mark - skproducts
- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response
{
    products = response.products;

}

@end





@implementation UIImage (Resize)

+ (UIImage *)imageWithImage:(UIImage *)image
               scaledToSize:(CGSize)newSize
                     inRect:(CGRect)rect
{
    //Determine whether the screen is retina
    if ([[UIScreen mainScreen] scale] == 2.0) {
        UIGraphicsBeginImageContextWithOptions(newSize, YES, 2.0);
    }
    else
    {
        UIGraphicsBeginImageContext(newSize);
    }
    
    //Draw image in provided rect
    [image drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //Pop this context
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageWithImage:(UIImage *)image
          scaledToFitToSize:(CGSize)newSize
{
    //Only scale images down
    if (image.size.width < newSize.width && image.size.height < newSize.height) {
        return [image copy];
    }
    
    //Determine the scale factors
    CGFloat widthScale = newSize.width/image.size.width;
    CGFloat heightScale = newSize.height/image.size.height;
    
    CGFloat scaleFactor;
    
    //The smaller scale factor will scale more (0 < scaleFactor < 1) leaving the other dimension inside the newSize rect
    widthScale < heightScale ? (scaleFactor = widthScale) : (scaleFactor = heightScale);
    CGSize scaledSize = CGSizeMake(image.size.width * scaleFactor, image.size.height * scaleFactor);
    
    //Scale the image
    return [UIImage imageWithImage:image scaledToSize:scaledSize inRect:CGRectMake(0.0, 0.0, scaledSize.width, scaledSize.height)];
}

+ (UIImage *)imageWithImage:(UIImage *)image
         scaledToFillToSize:(CGSize)newSize
{
    //Only scale images down
    if (image.size.width < newSize.width && image.size.height < newSize.height) {
        return [image copy];
    }
    
    //Determine the scale factors
    CGFloat widthScale = newSize.width/image.size.width;
    CGFloat heightScale = newSize.height/image.size.height;
    
    CGFloat scaleFactor;
    
    //The larger scale factor will scale less (0 < scaleFactor < 1) leaving the other dimension hanging outside the newSize rect
    widthScale > heightScale ? (scaleFactor = widthScale) : (scaleFactor = heightScale);
    CGSize scaledSize = CGSizeMake(image.size.width * scaleFactor, image.size.height * scaleFactor);
    
    //Create origin point so that the center of the image falls into the drawing context rect (the origin will have negative component).
    CGPoint imageDrawOrigin = CGPointMake(0, 0);
    widthScale > heightScale ?  (imageDrawOrigin.y = (newSize.height - scaledSize.height) * 0.5) :
    (imageDrawOrigin.x = (newSize.width - scaledSize.width) * 0.5);
    
    
    //Create rect where the image will draw
    CGRect imageDrawRect = CGRectMake(imageDrawOrigin.x, imageDrawOrigin.y, scaledSize.width, scaledSize.height);
    
    //The imageDrawRect is larger than the newSize rect, where the imageDraw origin is located defines what part of
    //the image will fall into the newSize rect.
    return [UIImage imageWithImage:image scaledToSize:newSize inRect:imageDrawRect];
}

@end
