//
//  IOSBridge.m
//  Tuxpaint
//
//  Created by dev on 14-11-18.
//  Copyright (c) 2014年 happymobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IOSMISC.h"
#import "SDL.h"
#import "SDL_syswm.h"
#import "BaiduMobAdView.h"
#import "WXApi.h"
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "libintl.h"
#import "Flurry.h"
#import <sys/utsname.h>

static IOSMISC *myIOSMisc;
static UIView *textview;
static UITextField *textField;
static UIButton *btnOK, *btnCancel;
void setWXDelegate(id<WXApiDelegate,NSObject> dg);
char *ios_doc_dir;

void IOSFlurryCustomevent(const char *newevent, const char* oldevent)
{
    [Flurry endTimedEvent:[NSString stringWithCString:oldevent encoding:(NSASCIIStringEncoding)] withParameters:nil];
    [Flurry logEvent:[NSString stringWithCString:newevent encoding:(NSASCIIStringEncoding)]];
}

bool IOSHasNotch()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString* deviceName =
    [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSString* deviceSimlator = @"unkonwn";
    if ([deviceName containsString:@"i386"] || [deviceName containsString:@"x86_64"]) {
        deviceSimlator = [NSProcessInfo processInfo].environment[@"SIMULATOR_MODEL_IDENTIFIER"];
    }
    
    return ([deviceName containsString:@"iPhone10,3"]
            || [deviceName containsString:@"iPhone10,6"]
            || [deviceName containsString:@"iPhone11"]
            || [deviceName containsString:@"iPhone12"]
            || [deviceSimlator containsString:@"iPhone12"]);
}

int IOSDetectRotation(){
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    int rot = 0;
    if (UIDeviceOrientationLandscapeRight == orientation) rot = 1;
    return rot;
}

float IOSReturnSceenScale()
{
    #if __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000
    float scale = (float)([UIScreen mainScreen].nativeScale);
    #else
    float scale = (float)([UIScreen mainScreen].scale);
    #endif
    return scale;
}

void IOSInitMisc()
{
    ios_doc_dir = malloc(2048);
    strcpy(ios_doc_dir, [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] copy] cStringUsingEncoding:NSASCIIStringEncoding]);
}

void IOSMisc_StartAD(SDL_Window * sdlWindow, float x, float y, float w, float screen_scale)
{
    screen_scale = screen_scale * IOSReturnSceenScale();//for latest SDL2
    SDL_SysWMinfo systemWindowInfo;
    UIScreen *uiscreen = [UIScreen mainScreen];
    float fw = [uiscreen bounds].size.width;
    float fh = [uiscreen bounds].size.height;
    float scale = [uiscreen scale];
    if (fw < fh) {
        float ftmp = fw;
        fw = fh;
        fh = ftmp;
    }
    int button_size = 48;
    CGRect r = CGRectMake(fw-320-button_size, fh-43, 320+button_size, 48);
    // 48 for r_color, 56 for r_tuxarea
    CGRect rc = CGRectMake(fw/2-160, fh-(48+56)*screen_scale/scale-48, 320+button_size, 48);
    SDL_VERSION(&systemWindowInfo.version);
    if ( !SDL_GetWindowWMInfo(sdlWindow, &systemWindowInfo)) {
        // consider doing some kind of error handling here
        return;
    }
    UIWindow * appWindow = systemWindowInfo.info.uikit.window;
    //UIViewController * rootViewController = appWindow.rootViewController;
    if (! myIOSMisc) {
        myIOSMisc = [[IOSMISC alloc] initWithNibName:@"textview" bundle:nil];
        //myIOSMisc = [[IOSMISC alloc] init];
    }
    
    myIOSMisc.ADRect = r;
    myIOSMisc.ADRect_center = rc;
    myIOSMisc.rootview = appWindow.subviews[0];
    myIOSMisc.PWindow = appWindow;
    myIOSMisc.rBtn = CGRectMake(fw - button_size, fh-48, button_size, button_size);
    myIOSMisc.screen_scale = screen_scale;
    [myIOSMisc startAD];
    [WXApi registerApp:WEIXIN_APP_ID withDescription:@"嘟嘟画画"];
    //setWXDelegate(myIOSMisc);
    [Flurry startSession:@"88SDCSR5WHV283QDKRSR"];
}

#pragma mark - text input

#define TFC_X 200
#define TFC_Y 30
#define BUTTON_H 20
void IOSSTartTextInput(SDL_Window * sdlWindow, float x, float y, char* str)
{
    SDL_SysWMinfo systemWindowInfo;
    SDL_VERSION(&systemWindowInfo.version);
    if (! myIOSMisc) {
        myIOSMisc = [[IOSMISC alloc] initWithNibName:@"textview" bundle:nil];
        //myIOSMisc = [[IOSMISC alloc] init];
    }
    if ( !SDL_GetWindowWMInfo(sdlWindow, &systemWindowInfo)) {
        // consider doing some kind of error handling here
        return;
    }
    float scale = [[UIScreen mainScreen] scale];
    int ww, wh;
    SDL_GetWindowSize(sdlWindow, &ww, &wh);
    
    UIWindow * appWindow = systemWindowInfo.info.uikit.window;
    //if (x > (ww-TFC_X*scale)) x = ww-TFC_X*scale;
    //if (y < TFC_Y*scale) y = TFC_Y*scale;
    if (x > (ww-TFC_X)) x = ww-TFC_X;
    if (y < TFC_Y) y = TFC_Y;

    
//    //[myIOSMisc loadView];
//    myIOSMisc.textview.center = CGPointMake(x, y);
//    myIOSMisc.textview.bounds = CGRectMake(0, 0, TFC_X*2, TFC_Y*2+BUTTON_H);
//    [appWindow.subviews[0] addSubview: myIOSMisc.textview];
//    myIOSMisc.textview.hidden = NO;
//    [myIOSMisc.textField becomeFirstResponder];
    UIView *view = appWindow.subviews[0];
//    printf("%f %f %f %f", appWindow.frame.origin.x, appWindow.frame.origin.y, appWindow.frame.size.width,appWindow.frame.size.height);
//    printf("----%f %f %f %f---", view.frame.origin.x, view.frame.origin.y, view.frame.size.width,view.frame.size.height);
    //SDL_Rect r = {x, y - TFC_Y*scale, TFC_X*scale, TFC_Y*scale};
    SDL_Rect r = {x, y - TFC_Y, TFC_X, TFC_Y};
    SDL_SetTextInputRect(&r);
    SDL_EventState(SDL_TEXTINPUT, SDL_ENABLE);
    SDL_EventState(SDL_TEXTEDITING, SDL_ENABLE);
    if (!textField) {
        textview = [[UIView alloc] init];
        textview.center = CGPointMake(x*myIOSMisc.screen_scale/scale+TFC_X/2, y*myIOSMisc.screen_scale/scale-TFC_Y/2);
        textview.bounds = CGRectMake(0, 0, TFC_X, TFC_Y);
        
        textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, TFC_X, TFC_Y)];
        textField.delegate = myIOSMisc;
        /* placeholder so there is something to delete! */
        if (str) {
            textField.text = [[NSString alloc] initWithUTF8String:str];
        } else textField.text = @" ";
        /* set UITextInputTrait properties, mostly to defaults */
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.enablesReturnKeyAutomatically = NO;
        textField.keyboardAppearance = UIKeyboardAppearanceDefault;
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.returnKeyType = UIReturnKeyDefault;
        textField.secureTextEntry = NO;
        textField.backgroundColor = [UIColor whiteColor];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [textview addSubview:textField];
        
//        btnOK = [[UIButton alloc] initWithFrame:CGRectMake(TFC_X, TFC_Y*2, TFC_X, BUTTON_H)];
//        btnOK.backgroundColor = [UIColor greenColor];
        //btnOK.titleLabel =
        //btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, TFC_Y*2, TFC_X, BUTTON_H)];
        //btnCancel.backgroundColor = [UIColor redColor];
        [textview addSubview:btnCancel];
        [textview addSubview:btnOK];
        [appWindow.subviews[0] addSubview: textview];
    }
    if (str) {
        textField.text = [[NSString alloc] initWithUTF8String:str];
    } else textField.text = @" ";
    //textview.center = CGPointMake(x/scale+TFC_X/2, y/scale-TFC_Y/2);
    //textview.center = CGPointMake(x*myIOSMisc.screen_scale/scale+TFC_X/2, y*myIOSMisc.screen_scale/scale-TFC_Y/2);
    textview.center = CGPointMake(x+TFC_X/2, y-TFC_Y/2);
    textview.bounds = CGRectMake(0, 0, TFC_X, TFC_Y);
    textview.hidden = NO;
    /* add the UITextField (hidden) to our view */
    [textField becomeFirstResponder];
    //appWindow.frame = CGRectMake(0, 0, appWindow.frame.size.width, appWindow.frame.size.height);
}
static int SDL_SendKeyboardText(const char *text)
{
    int posted;
    
    /* Don't post text events for unprintable characters */
    if ((unsigned char)*text < ' ' || *text == 127) {
        return 0;
    }
    
    /* Post the event, if desired */
    posted = 0;
    if (SDL_GetEventState(SDL_TEXTINPUT) == SDL_ENABLE) {
        SDL_Event event;
        event.text.type = SDL_TEXTINPUT;
        event.text.windowID = 0;
        SDL_utf8strlcpy(event.text.text, text, SDL_arraysize(event.text.text));
        posted = (SDL_PushEvent(&event) > 0);
    }
    return (posted);
}
static int SDL_SendKeyboardKey(Uint8 state, SDL_Scancode scancode, SDL_Keycode sym)
{
    int posted;
    Uint16 modstate = 0;
    Uint32 type;
    Uint8 repeat = 0;
    
    if (!scancode) {
        return 0;
    }
#ifdef DEBUG_KEYBOARD
    printf("The '%s' key has been %s\n", SDL_GetScancodeName(scancode),
           state == SDL_PRESSED ? "pressed" : "released");
#endif
    
    /* Figure out what type of event this is */
    switch (state) {
        case SDL_PRESSED:
            type = SDL_KEYDOWN;
            break;
        case SDL_RELEASED:
            type = SDL_KEYUP;
            break;
        default:
            /* Invalid state -- bail */
            return 0;
    }
    
    /* Post the event, if desired */
    posted = 0;
    if (SDL_GetEventState(type) == SDL_ENABLE) {
        SDL_Event event;
        event.key.type = type;
        event.key.state = state;
        event.key.repeat = repeat;
        event.key.keysym.scancode = scancode;
        event.key.keysym.sym = sym;
        event.key.keysym.mod = modstate;
        event.key.windowID =  0;
        posted = (SDL_PushEvent(&event) > 0);
    }
    return (posted);
}
void IOSStopTextInput(SDL_Window * sdlWindow, float x, float y)
{
        //[myIOSMisc.textField resignFirstResponder];
        //myIOSMisc.textview.hidden = YES;
    if (!textField) {
        return;
    }
    SDL_SendKeyboardText([textField.text UTF8String]);
    SDL_SendKeyboardKey(SDL_PRESSED, SDL_SCANCODE_RETURN, SDLK_RETURN);
    SDL_SendKeyboardKey(SDL_RELEASED, SDL_SCANCODE_RETURN, SDLK_RETURN);
    [textField resignFirstResponder];
    textview.hidden = YES;
    //SDL_EventState(SDL_TEXTINPUT, SDL_DISABLE);
    //SDL_EventState(SDL_TEXTEDITING, SDL_DISABLE);
    textField.text = @"";
}
enum {
    WXSESSION = 1,
    WXTIMELINE
};


UIImage* GetImage(SDL_Surface *surface, int sw, int sh)
{
    GLint backingWidth, backingHeight;
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    
    
    NSInteger x = (sw - surface->w)/2, y = sh - surface->h, width = surface->w, height = surface->h;
    
    NSInteger dataLength = width * height * 4;
    
    GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
    
    
    
    // Read pixel data from the framebuffer
    
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    
    glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    
    
    // Create a CGImage with the pixel data
    
    // If your OpenGL ES content is opaque, use kCGImageAlphaNoneSkipLast to ignore the alpha channel
    
    // otherwise, use kCGImageAlphaPremultipliedLast
    
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGImageRef iref = CGImageCreate(width, height, 8, 32, width * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast,ref, NULL, true, kCGRenderingIntentDefault);
    
    
    
    // OpenGL ES measures data in PIXELS
    
    // Create a graphics context with the target size measured in POINTS
    
    NSInteger widthInPoints, heightInPoints;
    
    if (NULL != UIGraphicsBeginImageContextWithOptions) {
        
        // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
        
        // Set the scale parameter to your OpenGL ES view's contentScaleFactor
        
        // so that you get a high-resolution snapshot when its value is greater than 1.0
        
        CGFloat scale =1;
        
        widthInPoints = width / scale;
        
        heightInPoints = height / scale;
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, scale);
        
    }
    
    else {
        
        // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
        
        widthInPoints = width;
        
        heightInPoints = height;
        
        UIGraphicsBeginImageContext(CGSizeMake(widthInPoints, heightInPoints));
        
    }
    
    
    
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    
    
    
    // UIKit coordinate system is upside down to GL/Quartz coordinate system
    
    // Flip the CGImage by rendering it to the flipped bitmap context
    
    // The size of the destination area is measured in POINTS
    
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, widthInPoints, heightInPoints), iref);
    
    
    
    // Retrieve the UIImage from the current context
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    
    
    UIGraphicsEndImageContext();
    
    
    
    // Clean up
    
    free(data);
    
    CFRelease(ref);
    
    CFRelease(colorspace);
    
    CGImageRelease(iref);
    return image;
}

void IOSSharingWeixin(SDL_Surface* surf, int type, int sw, int sh)
{
    
    UIImage* image = GetImage(surf, sw, sh);
    //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:[UIImage imageWithImage:image scaledToFillToSize:CGSizeMake(30, 30)]];
    
    WXImageObject *ext = [WXImageObject object];
    ext.imageData = UIImagePNGRepresentation(image);
    
    //    UIImage* image = [UIImage imageNamed:@"res5thumb.png"];
    //    ext.imageData = UIImagePNGRepresentation(image);
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    if (type == WXSESSION) {
        req.scene = WXSceneSession;
    } else if (type == WXTIMELINE){
        req.scene = WXSceneTimeline;
    }
    
    BOOL Ret = [WXApi sendReq:req];
    NSLog(@"ret:%d\n", Ret);
    //[image release];
}


void IOSSharing(SDL_Surface *surface, int type, int sw, int sh)
{
    myIOSMisc.shareSurf = surface;
    myIOSMisc.screenDim = CGRectMake(0, 0, sw, sh);
    UIActionSheet  *actionSheetRecomm = [UIActionSheet alloc];
    actionSheetRecomm = [[UIActionSheet alloc] initWithTitle:[NSString stringWithUTF8String:gettext("share to friends")] delegate:myIOSMisc
                                           cancelButtonTitle:[NSString stringWithUTF8String:gettext("Cancel")] destructiveButtonTitle:nil
#ifdef TUX_LANG_ZH_CN
                                           otherButtonTitles: [NSString stringWithUTF8String:gettext("WeChat Session")],[NSString stringWithUTF8String:gettext("WeChat Timeline")],[NSString stringWithUTF8String:gettext("Sina Weibo")], [NSString stringWithUTF8String:gettext("Tencent Weibo")], [NSString stringWithUTF8String:gettext("Twitter")],[NSString stringWithUTF8String:gettext("Facebook")], [NSString stringWithUTF8String:gettext("Flickr")], nil ];
#else
                                            otherButtonTitles: [NSString stringWithUTF8String:gettext("Twitter")],[NSString stringWithUTF8String:gettext("Facebook")], [NSString stringWithUTF8String:gettext("Flickr")], [NSString stringWithUTF8String:gettext("WeChat Session")],[NSString stringWithUTF8String:gettext("WeChat Timeline")], [NSString stringWithUTF8String:gettext("Sina Weibo")], [NSString stringWithUTF8String:gettext("Tencent Weibo")], nil ];
#endif
    
    [actionSheetRecomm setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [actionSheetRecomm setTag:0];
    [actionSheetRecomm showInView:myIOSMisc.rootview];
    
}
void SurfaceSave(SDL_Surface *surface, const char *name)
{
    GLint backingWidth, backingHeight;
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    
    
    NSInteger x = (1024 - surface->w)/2, y = 768 - surface->h, width = surface->w, height = surface->h;
    
    NSInteger dataLength = width * height * 4;
    
    GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
    
    
    
    // Read pixel data from the framebuffer
    
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    
    glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    
    
    // Create a CGImage with the pixel data
    
    // If your OpenGL ES content is opaque, use kCGImageAlphaNoneSkipLast to ignore the alpha channel
    
    // otherwise, use kCGImageAlphaPremultipliedLast
    
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGImageRef iref = CGImageCreate(width, height, 8, 32, width * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast,ref, NULL, true, kCGRenderingIntentDefault);
    
    
    
    // OpenGL ES measures data in PIXELS
    
    // Create a graphics context with the target size measured in POINTS
    
    NSInteger widthInPoints, heightInPoints;
    
    if (NULL != UIGraphicsBeginImageContextWithOptions) {
        
        // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
        
        // Set the scale parameter to your OpenGL ES view's contentScaleFactor
        
        // so that you get a high-resolution snapshot when its value is greater than 1.0
        
        CGFloat scale =1;
        
        widthInPoints = width / scale;
        
        heightInPoints = height / scale;
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, scale);
        
    }
    
    else {
        
        // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
        
        widthInPoints = width;
        
        heightInPoints = height;
        
        UIGraphicsBeginImageContext(CGSizeMake(widthInPoints, heightInPoints));
        
    }
    
    
    
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    
    
    
    // UIKit coordinate system is upside down to GL/Quartz coordinate system
    
    // Flip the CGImage by rendering it to the flipped bitmap context
    
    // The size of the destination area is measured in POINTS
    
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, widthInPoints, heightInPoints), iref);
    
    
    
    // Retrieve the UIImage from the current context
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    
    
    UIGraphicsEndImageContext();
    
    
    
    // Clean up
    
    free(data);
    
    CFRelease(ref);
    
    CFRelease(colorspace);
    
    CGImageRelease(iref);
    
    
    
    NSString *string_name = [[[NSString alloc] initWithCString:(const char*)name encoding:NSASCIIStringEncoding] autorelease];
    [UIImagePNGRepresentation(image) writeToFile:string_name atomically:YES];
    
}

void SurfaceSaveToPHOTO(SDL_Surface *surface, int sw, int sh)
{
    GLint backingWidth, backingHeight;
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    NSInteger x, y, width, height;
    if ((sw > surface->w) || (sh > surface->h)) {
        x = (sw - surface->w)/2;
        y = (sh - surface->h)/2;
        width = surface->w;
        height = surface->h;
    } else {
        x = y = 0;
        width = surface->w;
        height = surface->h;
    }
    width *= myIOSMisc.screen_scale;
    height *= myIOSMisc.screen_scale;
    
    NSInteger dataLength = width * height * 4;
    
    GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
    
    
    
    // Read pixel data from the framebuffer
    
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    
    glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    
    
    // Create a CGImage with the pixel data
    
    // If your OpenGL ES content is opaque, use kCGImageAlphaNoneSkipLast to ignore the alpha channel
    
    // otherwise, use kCGImageAlphaPremultipliedLast
    
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGImageRef iref = CGImageCreate(width, height, 8, 32, width * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast,ref, NULL, true, kCGRenderingIntentDefault);
    
    
    
    // OpenGL ES measures data in PIXELS
    
    // Create a graphics context with the target size measured in POINTS
    
    NSInteger widthInPoints, heightInPoints;
    
    if (NULL != UIGraphicsBeginImageContextWithOptions) {
        
        // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
        
        // Set the scale parameter to your OpenGL ES view's contentScaleFactor
        
        // so that you get a high-resolution snapshot when its value is greater than 1.0
        
        CGFloat scale =1;
        
        widthInPoints = width / scale;
        
        heightInPoints = height / scale;
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, scale);
        
    }
    
    else {
        
        // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
        
        widthInPoints = width;
        
        heightInPoints = height;
        
        UIGraphicsBeginImageContext(CGSizeMake(widthInPoints, heightInPoints));
        
    }
    
    
    
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    
    
    
    // UIKit coordinate system is upside down to GL/Quartz coordinate system
    
    // Flip the CGImage by rendering it to the flipped bitmap context
    
    // The size of the destination area is measured in POINTS
    
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, widthInPoints, heightInPoints), iref);
    
    
    
    // Retrieve the UIImage from the current context
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    
    
    UIGraphicsEndImageContext();
    
    
    
    // Clean up
    
    free(data);
    
    CFRelease(ref);
    
    CFRelease(colorspace);
    
    CGImageRelease(iref);
    
    
    
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

