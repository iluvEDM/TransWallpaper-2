#import "CaptureSessionManager.h"

UIImage* imageFromSampleBuffer(CMSampleBufferRef nextBuffer) {
	
	CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(nextBuffer);
//	printf("total size:%u\n",CMSampleBufferGetTotalSampleSize(nextBuffer));
	// Lock the base address of the pixel buffer.
	//CVPixelBufferLockBaseAddress(imageBuffer,0);
	
	// Get the number of bytes per row for the pixel buffer.
	size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
	// Get the pixel buffer width and height.
	size_t width = CVPixelBufferGetWidth(imageBuffer);
	size_t height = CVPixelBufferGetHeight(imageBuffer);
//	printf("b:%d w:%d h:%d\n",bytesPerRow,width,height);
	
	// Create a device-dependent RGB color space.
	static CGColorSpaceRef colorSpace = NULL;
	if (colorSpace == NULL) {
		colorSpace = CGColorSpaceCreateDeviceRGB();
		if (colorSpace == NULL) {
			// Handle the error appropriately.
			return nil;
		}
	}
	
	// Get the base address of the pixel buffer.
	void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
	// Get the data size for contiguous planes of the pixel buffer.
	size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
	
	// Create a Quartz direct-access data provider that uses data we supply.
	CGDataProviderRef dataProvider =
	CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
	// Create a bitmap image from data supplied by the data provider.
	CGImageRef cgImage =
	CGImageCreate(width, height, 8, 32, bytesPerRow,
				  colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,
				  dataProvider, NULL, true, kCGRenderingIntentDefault);
	CGDataProviderRelease(dataProvider);
	
	// Create and return an image object to represent the Quartz image.
	UIImage *image = [UIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
	
	CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
	
	return image;
}

@implementation CaptureSessionManager

@synthesize captureSession;
@synthesize previewLayer;
@synthesize stillImageOutput,stillImage;

#pragma mark Capture Session Configuration

- (id)init {
	if ((self = [super init])) {
		AVCaptureSession *session=[[AVCaptureSession alloc] init];
		[session setSessionPreset:AVCaptureSessionPresetHigh];
		[self setCaptureSession:session];
		
		 NSLog(@"capture");
	}
	return self;
}

- (void)addVideoPreviewLayer {
	[self setPreviewLayer:[[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]] autorelease]];
	[[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
  
}

- (void)addVideoInput {
	AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];	
	if (videoDevice) {
		NSError *error;
		AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
		if (!error) {
			if ([[self captureSession] canAddInput:videoIn])
				[[self captureSession] addInput:videoIn];
			else
				NSLog(@"Couldn't add video input");		
		}
		else
			NSLog(@"Couldn't create video input");
	}
	else
		NSLog(@"Couldn't create video capture device");
}

- (void)addStillImageOutput
{
	[self setStillImageOutput:[[[AVCaptureStillImageOutput alloc] init] autorelease]];
	NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
	[[self stillImageOutput] setOutputSettings:outputSettings];
	
	AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in [[self stillImageOutput] connections]) {
		for (AVCaptureInputPort *port in [connection inputPorts]) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) {
			break;
		}
	}
	
	[[self captureSession] addOutput:[self stillImageOutput]];
}

- (void)captureStillImage
{
	AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in [[self stillImageOutput] connections]) {
		for (AVCaptureInputPort *port in [connection inputPorts]) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) {
			break;
		}
	}
	
	NSLog(@"about to request a capture from: %@", [self stillImageOutput]);
	[[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:videoConnection
														 completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
															 CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
															 if (exifAttachments) {
																 NSLog(@"attachements: %@", exifAttachments);
															 } else {
																 NSLog(@"no attachments");
															 }
															 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
															 UIImage *image = [[UIImage alloc] initWithData:imageData];
															 [self setStillImage:image];
															 [image release];
															 [[NSNotificationCenter defaultCenter] postNotificationName:kImageCapturedSuccessfully object:nil];
														 }];
}

- (void)dealloc {

	[[self captureSession] stopRunning];

	[previewLayer release], previewLayer = nil;
	[captureSession release], captureSession = nil;
	
	self.stillImage=nil;
	self.stillImageOutput=nil;
	
	[super dealloc];
}

#pragma mark SampleBufferDelegate


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
	
//	CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer( sampleBuffer );
	
//	[self processPixelBuffer:pixelBuffer];
	if (takePicture) {
		takePicture=NO;
		
		
//		if ([connection isVideoOrientationSupported])
//		{
//			[connection setVideoOrientation:[UIDevice currentDevice].orientation];
//		}
		
		//
		
		CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
		
		// Lock the image buffer
		CVPixelBufferLockBaseAddress(imageBuffer, 0);
		
		// Get information of the image
		uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0); 
		size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
		size_t width = CVPixelBufferGetWidth(imageBuffer); 
		size_t height = CVPixelBufferGetHeight(imageBuffer); 
		
		// Create Colorspace 
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
		CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace,
														kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst); 
		CGImageRef newImage = CGBitmapContextCreateImage(newContext);
		
		// Copy image data 
		/*
		 CFDataRef dataref = CGDataProviderCopyData(CGImageGetDataProvider(newImage)); 
		 memcpy(mImageData, dataref, 640 * 480 * sizeof(char) * 4); 
		 CFRelease(dataref);
		 */
		
//		NSLog(@"%d %d",[[UIDevice currentDevice] orientation],[[UIDevice currentDevice] orientation]==UIImageOrientationUp);

		UIImage *image=nil;
		
		switch ([[UIDevice currentDevice] orientation]) {
			case 1:
			case 5:
			default:
				image=[UIImage imageWithCGImage:newImage scale:1.0f orientation:UIImageOrientationRight];
				break;
			case 2:
				image=[UIImage imageWithCGImage:newImage scale:1.0f orientation:UIImageOrientationLeft];
				break;
			case 3:
				image=[UIImage imageWithCGImage:newImage scale:1.0f orientation:UIImageOrientationUp];
				break;
			case 4:
				image=[UIImage imageWithCGImage:newImage scale:1.0f orientation:UIImageOrientationDown];
				break;
		}
		
//		UIImage *image = [UIImage imageWithCGImage:newImage scale:1.0f orientation:[UIDevice currentDevice].orientation];

		//		UIImage *image = [UIImage imageWithCGImage:newImage];
		
		// Release it 
		CGContextRelease(newContext); 
		CGColorSpaceRelease(colorSpace);
		CGImageRelease(newImage);
		
		// Unlock the image buffer 
		CVPixelBufferUnlockBaseAddress(imageBuffer,0); 
		// CVBufferRelease(imageBuffer); 
		
		//
		
		
//		self.stillImage=imageFromSampleBuffer(sampleBuffer);
		self.stillImage=image;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kImageCapturedSuccessfully object:nil];
	}
	
}

- (void) addVideoDataOutput {
	
	AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
	[videoOut setAlwaysDiscardsLateVideoFrames:YES];
	[videoOut setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]]; // BGRA is necessary for manual preview
	dispatch_queue_t my_queue = dispatch_queue_create("com.purplerobo.transwall.picture", NULL);
	[videoOut setSampleBufferDelegate:self queue:my_queue];
	//	[videoOut setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
	if ([self.captureSession canAddOutput:videoOut])
		[self.captureSession addOutput:videoOut];
	else
		NSLog(@"Couldn't add video output");
	[videoOut release];
}

-(void)takePicture {
	takePicture=YES;
}


@end
