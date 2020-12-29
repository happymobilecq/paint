//
//  IOSMISC.h
//  Tuxpaint
//
//  Created by dev on 14-11-18.
//  Copyright (c) 2014年 happymobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>
#import <UIKit/UIKit.h>
#import "BaiduMobAdDelegateProtocol.h"
#import <GoogleMobileAds/GADBannerView.h>
#import "WXApi.h"
struct SDL_Surface;
#ifdef TUX_LANG_ZH_CN
#define API_Get_Advertisement                       @"http://www.crazymsn.net/ads/cn/"
#else
#define API_Get_Advertisement                       @"http://www.crazymsn.net/ads/en/"
#endif
#define USER_AGENT                                  @"TuxPaintonly"
#define DEFAULT_ADMOB_ID  @"ca-app-pub-8449785999705199/8271544755"
#define WEIXIN_APP_ID @"wx785fe69e7c644fd8"
#define UD_NOAD_KEY @"ud_no_ad"
typedef enum {
    ADMOB = 1,
    BAIDU
} ADType;

@interface IOSMISC : UIViewController<BaiduMobAdViewDelegate, GADBannerViewDelegate, NSURLConnectionDelegate, UITextFieldDelegate, WXApiDelegate, UIActionSheetDelegate, UIActivityItemSource, SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    UIImage* image_;
    BaiduMobAdView* sharedAdView;
    GADBannerView*  admobView;
    UIButton *btn;
    NSMutableData       *responseData;
    NSURLConnection     *MyConnection;
    ADType ad_type;
    NSDictionary *admob_id;
    NSDictionary *baidu_id;
    int bscale_x;
    int bcenter_ad;
    NSArray *products;
    BOOL bNoAD;
}
-(IBAction)ADCloseClicked:(id)sender;
-(void)startAD;
-(void)postAD;
-(void)startADInternal;
-(void)loadADURL;
-(void)HideAD;
@property (nonatomic) CGRect ADRect;
@property (nonatomic) CGRect ADRect_center;
@property (nonatomic) CGRect rBtn;
@property (nonatomic) float screen_scale;
@property (atomic, retain)UIView *PView;
@property (atomic, retain)UIView *rootview;
@property (atomic, retain)UIWindow *PWindow;
@property (atomic, retain)IBOutlet UITextField *textField;
@property (atomic, retain)IBOutlet UIView      *textview;
@property (atomic, retain)IBOutlet UIButton    *btnOK;
@property (nonatomic) struct SDL_Surface* shareSurf;
@property (nonatomic) CGRect screenDim;
@end


@interface UIImage (Resize)

+ (UIImage *)imageWithImage:(UIImage *)image
          scaledToFitToSize:(CGSize)newSize;

+ (UIImage *)imageWithImage:(UIImage *)image
         scaledToFillToSize:(CGSize)newSize;

@end
