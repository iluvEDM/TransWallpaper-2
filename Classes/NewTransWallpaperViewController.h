//
//  TransWallpaperViewController.h
//  TransWallpaper
//
//  Created by obscured on 10. 8. 9..
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <AudioToolbox/AudioToolbox.h>

#define IconsLast 6

@class TransWallpaperAppDelegate;
@class CaptureSessionManager;

@interface NewTransWallpaperViewController : UIViewController 
<UIScrollViewDelegate,TransWallpaperDelegate>
{
	TransWallpaperAppDelegate *appDelegate;
//	UIImagePickerController *picker;
	BOOL settingViewAppeared;
	UIPageControl *pageControl;
	
//	AVCaptureSession *session;
//	UIImageView *cameraImageView;
	UIView *overlayView;
	
	UIScrollView *scrollView;
	
	UInt32 icons[IconsLast][70*70];
	int deviceScale;
	
	NSMutableArray *buttonArray;
	NSMutableArray *scrollButtonArray;
}

@property (nonatomic,retain) UIScrollView *scrollView;
@property (nonatomic,retain) UIPageControl *pageControl;
@property (nonatomic,retain) UIImagePickerController *picker;
//@property (nonatomic,retain) AVCaptureSession *session;
//@property (nonatomic,retain) UIImageView *cameraImageView;
@property (nonatomic,retain) UIView *overlayView;
@property (retain) CaptureSessionManager *captureManager;
@property (nonatomic,retain) NSMutableArray *buttonArray;
@property (nonatomic,retain) NSMutableArray *scrollButtonArray;

-(UIImage*)makeBackgroundTransparentImage:(UIImage*)image;
-(UIImage*)makeTransparentImage:(UIImage*)image page:(int)p;
-(void)showTrans;
//- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer ;
- (void)setupCaptureSession ;
-(void)takePicture;
-(void)iconPressed:(id)sender;
-(UIImage*)printIconRGB;
-(void)findIconButtons:(UIImage*)image page:(int)p;


@end

