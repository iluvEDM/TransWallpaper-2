#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>

#define kImageCapturedSuccessfully @"imageCapturedSuccessfully"

@interface CaptureSessionManager : NSObject
<AVCaptureVideoDataOutputSampleBufferDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
	AVCaptureVideoPreviewLayer *previewLayer;
	AVCaptureSession *captureSession;	
	AVCaptureStillImageOutput *stillImageOutput;
	
	UIImage *stillImage;
	BOOL takePicture;
}

@property (retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (retain) AVCaptureSession *captureSession;
@property (retain) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic,retain) UIImage *stillImage;

- (void)addVideoPreviewLayer;
- (void)addVideoInput;
- (void)addStillImageOutput;
- (void)captureStillImage;
- (void) addVideoDataOutput;
-(void)takePicture;

@end
