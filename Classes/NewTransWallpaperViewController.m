//
//  TransWallpaperViewController.m
//  TransWallpaper
//
//  Created by obscured on 10. 8. 9..
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "NewTransWallpaperViewController.h"
#import "SettingViewController.h"
#import "TransWallpaperAppDelegate.h"
#import "CaptureSessionManager.h"

// Transform values for full screen support:
//#define CAMERA_TRANSFORM_X 1
//#define CAMERA_TRANSFORM_Y 1.12412
#define CAMERA_TRANSFORM_X 1.25
#define CAMERA_TRANSFORM_Y 1.25

// iPhone screen dimensions:
#define SCREEN_WIDTH  320
#define SCREEN_HEIGTH 480

static inline UInt32 calcAlpha(UInt32 color,float opa,BOOL opaDir)
{
	Byte r=(color >> 16) & 0xff;
	Byte g=(color >> 8) & 0xff;
	Byte b=color & 0xff;
	float a;
	Byte alpha;
	
	if (opaDir)
	{
		a=1-((r+g+b)/3.0/255) * 2 +opa-0.65;
		
		if (a>=1)
			alpha=0xff;
		else if (a<0)
			alpha=0;
		else 
			alpha=(Byte)(a * 255);
	}
	else {
		a=((r+g+b)/3.0/255) * 2 +opa-0.5;
		
		if (a>=1)
			alpha=0xff;
		else if (a<0)
			alpha=0;
		else 
			alpha=(Byte)(a * 255);
	}
	
	return (alpha << 24) | (r << 16) | (g<<8) | b;
}


@implementation NewTransWallpaperViewController


@synthesize picker,pageControl;//,session;
//@synthesize cameraImageView,
@synthesize overlayView,scrollView;
@synthesize captureManager;
@synthesize buttonArray,scrollButtonArray;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

// Implement loadView to create a view hierarchy programmatically, without using a nib.
//- (void)loadView {
//	UIView *v=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGTH)];
//	v.backgroundColor=[UIColor clearColor];
//	self.view=v;
//	[v release];
//}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	appDelegate=(TransWallpaperAppDelegate*)[[UIApplication sharedApplication] delegate];
	appDelegate.settingTable.transViewController=self;
	
    // Show the picker:
//    [super viewDidLoad];

	self.buttonArray=[NSMutableArray array];
	self.scrollButtonArray=[NSMutableArray array];
	
	deviceScale=(int)[[UIScreen mainScreen] scale];
	
	for (int i=0;i<IconsLast;i++) {

		UIImage *image;
		NSString *filename;
		
		switch (i) {
			case 0:
				filename=@"a00";
				break;
			case 1:
				filename=@"a01";
				break;
			case 2:
				filename=@"a02";
				break;
			case 3:
				filename=@"a03";
				break;
			case 4:
				filename=@"a04";
				break;
			case 5:
                filename=@"a05";
                break;
			default:
				
				break;
		}
		
		if (deviceScale==1) {
			image=[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",filename]];
			
			CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
			CGContextRef tempcontext=CGBitmapContextCreate(icons[i], 35, 35, 8, 35*4, colorSpace,kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			CGContextDrawImage(tempcontext, CGRectMake(0, 0, 35, 35),[image CGImage]);
			CGContextRelease(tempcontext);
			
//			if (i==4)
//				for (int x=0;x<90;x++)
//					NSLog(@"%d %08x",i,icons[i][x]);
		}
		else {
			image=[UIImage imageNamed:[NSString stringWithFormat:@"%@_hd.png",filename]];
			
			CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
			CGContextRef tempcontext=CGBitmapContextCreate(icons[i], 70, 70, 8, 70*4, colorSpace,kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			CGContextDrawImage(tempcontext, CGRectMake(0, 0, 70, 70),[image CGImage]);
			CGContextRelease(tempcontext);
		}
		
	}
	

}


- (void) viewDidAppear:(BOOL)animated {
	
	[super viewDidAppear:YES];

	if (settingViewAppeared)
	{
		[self presentModalViewController:[appDelegate navController] animated:YES];
	}
	else
	{
		if ([appDelegate screens].count==0)
		{
			settingViewAppeared=YES;
			[self presentModalViewController:[appDelegate navController] animated:YES];
		}
		else {
			
			[[UIApplication sharedApplication] setStatusBarHidden:YES];
			
//			//	[overlay addSubview:[[[UIImageView alloc] initWithImage:image] autorelease]]; 
//			// Create a new image picker instance:
//			UIImagePickerController *imagepicker = [[UIImagePickerController alloc] init];
//			self.picker=imagepicker;
//			[imagepicker release];
//			
//			// Set the image picker source:
//			picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//			
//			// Hide the controls:
//			picker.showsCameraControls = NO;
//			picker.navigationBarHidden = YES;
//			
//			//	picker.wantsFullScreenLayout=NO;
//			// Make camera view full screen:
//			picker.wantsFullScreenLayout = YES;
//			picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, CAMERA_TRANSFORM_X, CAMERA_TRANSFORM_Y);
			
			if (overlayView!=nil)
				[overlayView removeFromSuperview];
			
//			if (captureManager!=nil) 
//				[[captureManager captureSession] stopRunning];
//			if (cameraImageView!=nil)
//				[cameraImageView removeFromSuperview];
			
			[self setupCaptureSession];
			
			[buttonArray removeAllObjects];
			[scrollButtonArray removeAllObjects];
            CGRect screenBounds = [[UIScreen mainScreen] bounds];
            int width = screenBounds.size.width;
            int height = screenBounds.size.height;
			UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];

//            NSString *str = NSStringFromCGSize(screenBounds.size);
//            NSLog(str);
			if (!appDelegate.mode)
			{
				UIScrollView *aScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
				self.scrollView=aScrollView;
				[aScrollView release];
				scrollView.contentSize=CGSizeMake(width*appDelegate.screens.count, height);
				scrollView.pagingEnabled=YES;
				scrollView.showsHorizontalScrollIndicator=NO;
				
				int i=0;
				
				for (UIImage *image in appDelegate.screens)
				{
					UIImage *image2=[self makeTransparentImage:image page:i];
					UIImageView *imageView=[[UIImageView alloc] initWithImage:image2];
					imageView.center=CGPointMake(width/2+width*i,height/2);
					[scrollView addSubview:imageView];
					[imageView release];
					
					i++;
				}
				[overlay addSubview:scrollView];
				scrollView.delegate=self;
			}
			else {
				UIScrollView *aScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
				self.scrollView=aScrollView;
				[aScrollView release];
				scrollView.contentSize=CGSizeMake(width*appDelegate.screens.count, height);
//                scrollView.contentSize=CGSizeMake(width*3, height);
				scrollView.pagingEnabled=YES;
				scrollView.showsHorizontalScrollIndicator=NO;
				
				if (appDelegate.screens.count>0)
				{
					UIImage *srcImage=[UIImage imageWithCGImage:((UIImage*)[appDelegate.screens objectAtIndex:0]).CGImage];
					
					UIImage *backImage=[self makeBackgroundTransparentImage:srcImage];
					[overlay addSubview:[[[UIImageView alloc] initWithImage:backImage] autorelease]];
				}			
				int i=0;
                
				for (UIImage *image in appDelegate.screens)
				{
					UIImage *image2=[self makeTransparentImage:image page:i];
					UIImageView *imageView=[[UIImageView alloc] initWithImage:image2];
					imageView.center=CGPointMake(width/2+width*i,height/2);
					[scrollView addSubview:imageView];
					[imageView release];
					
					i++;

				}
//                UIImage *testImage ;
//                testImage = [self printIconRGB];
//                UIImageView *imageView=[[UIImageView alloc] initWithImage: testImage];
//                imageView.center=CGPointMake(width/2,height/2);

//                [scrollView addSubview:imageView];
//                [overlay addSubview:imageView];
//                [imageView release];
				[overlay addSubview:scrollView];

                
				scrollView.delegate=self;
				
				UIPageControl *pc=[[UIPageControl alloc] initWithFrame:CGRectZero];
				self.pageControl=pc;
				[pc release];
                double deltarate = 104.0000/568.0000;
                int delta = 0;
                if(height<=568){
                    delta = height-104;
                }else{
                    delta = height-80;
                }
                NSLog(@"%f",height*deltarate);
				pageControl.center=CGPointMake(width/2, delta);
				pageControl.numberOfPages=scrollView.contentSize.width/width;
				pageControl.currentPage=0;
				
				[overlay addSubview:pageControl];
				
			}
			
			// Insert the overlay:
			self.overlayView=overlay;
			[self.view addSubview:overlay];
			
			[overlay release];
			//	CGRect frame = picker.view.frame;
			//    frame.origin.y += 30;
			//    frame.size.height -= 30;
			//    picker.view.frame = frame;
			
			UIButton *optionButton=[UIButton buttonWithType:UIButtonTypeInfoLight];
			[optionButton addTarget:self action:@selector(settingPressed:) forControlEvents:UIControlEventTouchUpInside];
			[optionButton setCenter:CGPointMake(300, 20)];
			
			[overlay addSubview:optionButton];
			
			[self performSelector:@selector(fadeOutButton:) withObject:optionButton afterDelay:4.0f];

			for (UIButton *b in buttonArray) {
				[b addTarget:self action:@selector(iconPressed:) forControlEvents:UIControlEventTouchUpInside];
				[overlay addSubview:b];
			}
			for (UIButton *b in scrollButtonArray) {
				[b addTarget:self action:@selector(iconPressed:) forControlEvents:UIControlEventTouchUpInside];
				[scrollView addSubview:b];
			}
			
//			UIButton *button2=[UIButton buttonWithType:UIButtonTypeInfoLight];
//			button2.tag=0;
//			[button2 addTarget:self action:@selector(iconPressed:) forControlEvents:UIControlEventTouchUpInside];
//			[button2 setCenter:CGPointMake(160, 240)];
//			[scrollView addSubview:button2];
			
			
//			[self presentModalViewController:picker animated:YES];
			
		}
		
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.buttonArray=nil;
	self.scrollButtonArray=nil;
} 

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	self.captureManager=nil;
//	if ([session isRunning]) {
//		[session stopRunning];
//		[session removeInput:[[session inputs] objectAtIndex:0]];
//		[[[session outputs] objectAtIndex:0] setSampleBufferDelegate:nil queue:[[[session outputs] objectAtIndex:0] sampleBufferCallbackQueue]];	
//		[session removeOutput:[[session outputs] objectAtIndex:0]];
//	}
}


#pragma mark -
#pragma mark capture session

- (void)setupCaptureSession 
{
	CaptureSessionManager *c=[[CaptureSessionManager alloc] init];
	self.captureManager=c;
	[c release];
	
	[[self captureManager] addVideoInput];
	
	[[self captureManager] addVideoPreviewLayer];
	CGRect layerRect = [[[self view] layer] bounds];
	[[[self captureManager] previewLayer] setBounds:layerRect];
	[[[self captureManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),
																  CGRectGetMidY(layerRect))];
	CALayer *l=[[[[self view] layer] sublayers] objectAtIndex:0];
	[l removeFromSuperlayer];
	[[[self view] layer] addSublayer:[[self captureManager] previewLayer]];

	[[captureManager captureSession] startRunning];

	[[self captureManager] addVideoDataOutput];
//	[[self captureManager] addStillImageOutput];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveImageToPhotoAlbum) name:kImageCapturedSuccessfully object:nil];

//	NSLog(@"%d",[[[self.view layer] sublayers] count]);
	
}

#pragma mark -
#pragma mark scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
	pageControl.currentPage=(aScrollView.contentOffset.x+160)/320;
}



-(UIImage*)printIconRGB{
    int Width = 70;
    int Height = 70;
    UIImage *image;
    NSString *filename=@"a05";
    image=[UIImage imageNamed:[NSString stringWithFormat:@"%@_hd.png",filename]];

    UInt32 *pixelData=(UInt32*)malloc(Height*Width*4);
    // fill the pixels with a lovely opaque blue gradient:
//    for (size_t i=0; i < Area; ++i) {
//        pixelData[i] = icons[0][i];
//    }
    
    // create the bitmap context:
    int BitsPerComponent = 8;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef gtx = CGBitmapContextCreate(pixelData, Width, Height, BitsPerComponent, Width*4, colorSpace, kCGImageAlphaPremultipliedLast| kCGBitmapByteOrder32Big);
    CGContextDrawImage(gtx, CGRectMake(0, 0, Width, Height),[image CGImage]);
    
    
    // create the image:
    CGImageRef toCGImage = CGBitmapContextCreateImage(gtx);
    UIImage * uiimage = [UIImage imageWithCGImage:toCGImage];
    
    CGContextRelease(gtx);
    CGImageRelease(toCGImage);
    free(pixelData);

    // remember to cleanup your resources! :)
    
    return uiimage;
}

-(void)findIconButtons:(UIImage*) image page: (int)p {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    int width = screenBounds.size.width;
    int height = screenBounds.size.height;
    int iWidth = image.size.width;
    int iHeight = image.size.height;
    
    UInt32 *src=(UInt32*)malloc(iHeight*iWidth*4*4);
    
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    CGContextRef tempcontext=CGBitmapContextCreate(src, iWidth , iHeight, 8, iWidth*4, colorSpace,kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(tempcontext, CGRectMake(0, 0, iWidth, iHeight ),[image CGImage]);
    
    if (appDelegate.mode)
    {

        for (int i=40;i<iHeight-160;i++)
		
            for (int j=0;j<iWidth;j++)
            {
                int temp=j+i*iWidth;
                int k=0;
                int l=0;
                int m=0;
                for (;k<IconsLast;k++) {
                    
                    if (src[temp]==icons[k][0]) {
                        for (l=0;l<35*deviceScale;l++) {
                            for (m=0;m<35*deviceScale;m++) {
                                if (src[ (i+l) * iWidth + j+m] != icons[k][l*35*deviceScale + m]) {
                                    break;
                                }
                            }
                            if (m<35*deviceScale)
                                break;
                        }
                        if (l>=35*deviceScale) {
                            UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
                            [button setFrame:CGRectMake(p*width+(j/2)-20, (i/2)-20, 60, 60)];
                            [button setTag:10+k];
                            NSLog(@"this icon is : %d", k);
                            [scrollButtonArray addObject:button];
                        }
                    }
                }
                
                src[j+i*iWidth]=calcAlpha(src[j+i*iWidth], appDelegate.opacity,appDelegate.opacityDirection);
            }
//        memset(&(src[(height*2-100)*width*2]), 0, 100*width*2*4);
    }
    else {
        NSLog(@"notmode");
        for (int i=0;i<height-100;i++)
            for (int j=0;j<width;j++)
            {
                src[j+i*width]=calcAlpha(src[j+i*width], appDelegate.opacity,appDelegate.opacityDirection);
            }
    }
    
    
    CGContextRelease(tempcontext);

    
}

-(UIImage*)makeTransparentImage:(UIImage*)image page:(int)p
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    int width = screenBounds.size.width;
    int height = screenBounds.size.height;
    NSLog(@"%d",height);
    
    
    
//	if (image.size.width==640) {
		UIImage *dstImage;
		UInt32 *src=(UInt32*)malloc(height*width*4*4);
		UInt32 *dst=(UInt32*)malloc(height*width*4);
    
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    CGContextRef tempcontext=CGBitmapContextCreate(src,width*2 , height*2, 8, width*2*4, colorSpace,kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(tempcontext, CGRectMake(0, 0, image.size.width, image.size.height),[image CGImage]);

    
    
		
//		CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
//		CGContextRef tempcontext=CGBitmapContextCreate(src, width, height, 8, width*4, colorSpace,kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
//		CGColorSpaceRelease(colorSpace);
//		CGContextDrawImage(tempcontext, CGRectMake(0, 0, width, height),[image CGImage]);
    

    

//    deviceScale = 1;
		if (appDelegate.mode)
		{
			memset(src, 0, 20*width*2*4);
			for (int i=40;i<height*2-160;i++)
				for (int j=0;j<width*2;j++)
				{
					int temp=j+i*width*2;
					int k=0;
					int l=0;
					int m=0;
					for (;k<IconsLast;k++) {
						  
						if (src[temp]==icons[k][0]) {

                            
							for (l=0;l<35*deviceScale;l++) {
								for (m=0;m<35*deviceScale;m++) {
									if (src[ (i+l) * width*2 + j+m] != icons[k][l*35*deviceScale + m]) {
//                                        int tmp =src[ (i+l) * width + j+m];
//                                        int tmp2 = icons[k][l*35*deviceScale + m];
//                                        NSLog(@"diff %x,%x",tmp,tmp2);
//                                        src[ (i+l) * width + j+m]=0xff507032;
                                        //                                            NSLog(@"icon[%d][%d]",k,l*35*deviceScale + m);
                                        
										break;
                                    }
								}
								
                                if (m<35*deviceScale)
									break;
								
							}
							
							if (l>=35*deviceScale) {
								UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
								[button setFrame:CGRectMake(p*width+(j/2)-20, (i/2)-20, 60, 60)];
								[button setTag:10+k];
                                NSLog(@"this icon is : %d", k);
								[scrollButtonArray addObject:button];
							}
						}
					}
					
					src[j+i*width]=calcAlpha(src[j+i*width], appDelegate.opacity,appDelegate.opacityDirection);
				}
			memset(&(src[(height*2-100)*width*2]), 0, 100*width*2*4);
		}
		else {
            NSLog(@"notmode");
			for (int i=0;i<height-100;i++)
				for (int j=0;j<width;j++)
				{
					src[j+i*width]=calcAlpha(src[j+i*width], appDelegate.opacity,appDelegate.opacityDirection);
				}
		}
    
    
        CGContextRelease(tempcontext);
    
        CGContextRef tempcontext2=CGBitmapContextCreate(dst, width, height, 8, width*4, colorSpace,kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGContextDrawImage(tempcontext2, CGRectMake(0, 0, width, height),[image CGImage]);

    memset(dst, 0, 20*width*4);
    for (int i=20;i<height-100;i++)
        for (int j=0;j<width;j++)
        {
            dst[j+i*width]=calcAlpha(dst[j+i*width], appDelegate.opacity,appDelegate.opacityDirection);
        }
    memset(&(src[(height-100)*width]), 0, 100*width*4);
    
		CGImageRef imRef = CGBitmapContextCreateImage(tempcontext2);
		dstImage=[UIImage imageWithCGImage:imRef];
		
        CGColorSpaceRelease(colorSpace);
		CGContextRelease(tempcontext2);
		CGImageRelease(imRef);
		free(src);
		free(dst);
		
		return dstImage;
		
//	}
//	else {
//		UIImage *dstImage;
//		UInt32 *src=(UInt32*)malloc(960*640*4);
//		UInt32 *dst=(UInt32*)malloc(960*640*4);
//		
//		CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
//		CGContextRef tempcontext=CGBitmapContextCreate(src, 640, 960, 8, 640*4, colorSpace,kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
//		CGColorSpaceRelease(colorSpace);
//		CGContextDrawImage(tempcontext, CGRectMake(0, 0, 640, 960),[image CGImage]);
//		
//		if (appDelegate.mode)
//		{
//			memset(src, 0, 20*2*640*4);
//			for (int i=20*2;i<380*2;i++)
//				for (int j=0;j<320*2;j++)
//				{
//					int temp=j+i*320*2;
//						int k=0;
//						int l=0;
//						int m=0;
//						for (;k<IconsLast;k++) {
//							
//							if (src[temp]==icons[k][0]) {
//								for (l=0;l<35*deviceScale;l++) {
//									for (m=0;m<35*deviceScale;m++) {
//										
//										if (src[ (i+l) * 320*2 + j+m] != icons[k][l*35*deviceScale + m]) {
//											break;
//										}
//										
//									}
//									
//									if (m<35*deviceScale)
//										break;
//									
//								}
//								
//								if (l>=35*deviceScale) {
//									UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
//									[button setFrame:CGRectMake(p*320+j/2-20, i /2-20, 60, 60)];
//									[button setTag:10+k];
//									[scrollButtonArray addObject:button];
//								}
//							}
//						}
//					
//					
//					src[j+i*320*2]=calcAlpha(src[j+i*320*2], appDelegate.opacity,appDelegate.opacityDirection);
//				}
//			memset(&(src[380*2*320*2]), 0, 100*2*320*2*4);
////		}
////		else {
////			for (int i=0;i<480*2;i++)
////				for (int j=0;j<320*2;j++)
////				{
////					src[j+i*320*2]=calcAlpha(src[j+i*320*2], appDelegate.opacity,appDelegate.opacityDirection);
////				}
////		}
		
//		CGImageRef imRef = CGBitmapContextCreateImage(tempcontext);
//		dstImage=[UIImage imageWithCGImage:imRef scale:2 orientation:UIImageOrientationUp];
//		
//		CGContextRelease(tempcontext);
//		CGImageRelease(imRef);
//		free(src);
//		free(dst);
//		
//		return dstImage;
//		
//	}

}



-(UIImage*)makeBackgroundTransparentImage:(UIImage*)image;
{
	
	NSLog(@"image size = %f",image.scale);
	NSLog(@"image cgsize = %@",NSStringFromCGSize(image.size));
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    int width = screenBounds.size.width;
    int height = screenBounds.size.height;
//	if (image.size.width==640) {
        NSLog(@"mbt1");
		UIImage *dstImage;
		UInt32 *src=(UInt32*)malloc(height*width*4);
		UInt32 *dst=(UInt32*)malloc(height*width*4);
		UInt32 blank;
		
		blank=calcAlpha(0, appDelegate.opacity, appDelegate.opacityDirection);
		
		CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
		CGContextRef tempcontext=CGBitmapContextCreate(src, width, height, 8, width*4, colorSpace,kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
		CGColorSpaceRelease(colorSpace);
		CGContextDrawImage(tempcontext, CGRectMake(0, 0, width, height),[image CGImage]);
		
		for (int i=0;i<20;i++)
			for (int j=0;j<width;j++)
			{
				src[j+i*width]=calcAlpha(src[j+i*width], appDelegate.opacity,appDelegate.opacityDirection);
			}
		
        //20 부터 len 길이 만큼 투명화
		memset(&(src[20*width]), 0, (height-120)*width*4);
		
//		memset_pattern4(&(src[(height-120)*width]), &blank ,20*width*4);
		
		for (int i=height-80;i<height;i++)
			for (int j=0;j<width;j++)
			{
				int temp=j+i*width;
				if (i<height) {
					int k=0;
					int l=0;
					int m=0;
					for (;k<IconsLast;k++) {
						
						if (src[temp]==icons[k][0]) {
							for (l=0;l<35*deviceScale;l++) {
								for (m=0;m<35*deviceScale;m++) {
									
									if (src[ (i+l) * width + j+m] != icons[k][l*35*deviceScale + m]) {
                                        int tmp =src[ (i+l) * width + j+m];
                                        int tmp2 = icons[k][l*35*deviceScale + m];
//                                        NSLog(@"%x,%x",tmp,tmp2);
//                                            NSLog(@"back icon[%d][%d]",k,l*35*deviceScale + m);
										break;
                                    }else{
                                        int tmp =src[ (i+l) * width + j+m];
                                        int tmp2 = icons[k][l*35*deviceScale + m];
//                                        NSLog(@"correct %x,%x",tmp,tmp2);
//                                        NSLog(@"back correct icon[%d][%d]",k,l*35*deviceScale + m);
                                        src[ (i+l) * width + j+m]=0xff501432;
                                    }
									
								}
								
								if (m<35*deviceScale)
									break;
								
								
							}
							
							if (l>=35*deviceScale) {
								NSLog(@"find! %d",k);
								UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
								[button setFrame:CGRectMake(j-20, i -20, 60, 60)];
								[button setTag:10+k];
								[buttonArray addObject:button];
							}								
						}
						
					}
				}
				
//				src[temp]=calcAlpha(src[temp], appDelegate.opacity,appDelegate.opacityDirection);
			}
		
		CGImageRef imRef = CGBitmapContextCreateImage(tempcontext);
		dstImage=[UIImage imageWithCGImage:imRef];
		
		CGContextRelease(tempcontext);
		CGImageRelease(imRef);
		free(src);
		free(dst);
		
		return dstImage;
		
//	}
//	else {
//        NSLog(@"mbt2");
//		UIImage *dstImage;
//		UInt32 *src=(UInt32*)malloc(480*2*320*2*4);
//		UInt32 *dst=(UInt32*)malloc(480*2*320*2*4);
//		UInt32 blank;
//		
//		blank=calcAlpha(0, appDelegate.opacity, appDelegate.opacityDirection);
//		
//		CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
//		CGContextRef tempcontext=CGBitmapContextCreate(src, 320*2, 480*2, 8, 320*2*4, colorSpace,kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
//		CGColorSpaceRelease(colorSpace);
//		CGContextDrawImage(tempcontext, CGRectMake(0, 0, 320*2, 480*2),[image CGImage]);
//		
//		for (int i=0;i<20*2;i++)
//			for (int j=0;j<320*2;j++)
//			{
//				src[j+i*320*2]=calcAlpha(src[j+i*320*2], appDelegate.opacity,appDelegate.opacityDirection);
//			}
//		
//		memset(&(src[20*2*320*2]), 0, 360*2*320*2*4);
//		
//		memset_pattern4(&(src[380*2*320*2]), &blank ,20*2*320*2*4);
//		
//		for (int i=400*2;i<480*2;i++)
//			for (int j=0;j<320*2;j++)
//			{
//				int temp=j+i*320*2;
//				if (i<450*2) {
//					int k=0;
//					int l=0;
//					int m=0;
//					for (;k<IconsLast;k++) {
//						
//						if (src[temp]==icons[k][0]) {
//							for (l=0;l<35*deviceScale;l++) {
//								for (m=0;m<35*deviceScale;m++) {
//									
//									if (src[ (i+l) * 320*2 + j+m] != icons[k][l*35*deviceScale + m]) {
//										break;
//									}
//									
//								}
//								
//								if (m<35*deviceScale)
//									break;
//								
//							}
//							
//							if (l>=35*deviceScale) {
//								NSLog(@"find! %d",k);
//								UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
//								[button setFrame:CGRectMake(j/2-20, i /2-20, 60, 60)];
//								[button setTag:10+k];
//								[buttonArray addObject:button];
//							}
//						}
//						
//					}
//				}
//				
//				
//				src[temp]=calcAlpha(src[temp], appDelegate.opacity,appDelegate.opacityDirection);
//			}
		
//		CGImageRef imRef = CGBitmapContextCreateImage(tempcontext);
//		dstImage=[UIImage imageWithCGImage:imRef];
//		dstImage=[UIImage imageWithCGImage:imRef scale:2 orientation:UIImageOrientationUp];
//		
//		CGContextRelease(tempcontext);
//		CGImageRelease(imRef);
//		free(src);
//		free(dst);
//		
//		return dstImage;
//	}
	
}

-(void)iconPressed:(UIButton*)sender {

	NSString *stringURL=nil;
	
	switch (sender.tag) {
		case 10:
			stringURL = @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewGrouping?id=25204&mt=8";
			break;
		case 11:
			stringURL = @"http://itunes.apple.com/us/store";
			break;
		case 12:
			stringURL = @"mailto:";
			break;
		case 13:
			stringURL = @"sms:";
			break;	
		case 14:
			stringURL = @"http://www.google.com";
			break;
		case 15:
            NSLog(@"camera");
//            [self takePicture];
            [self doCameraStart];
            break;
		default:
			
			break;
	}

	if (stringURL!=nil) {
		NSURL *url = [NSURL URLWithString:stringURL];
		[[UIApplication sharedApplication] openURL:url];
	}

//	NSString *stringURL = @"tel:";
//	float latitude = 35.4634;
//	float longitude = 9.43425;
//	int zoom = 13;
//	NSString *title = @"title";
//	NSString *stringURL = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@@%1.6f,%1.6f&z=%d", title, latitude, longitude, zoom];
//	NSString *stringURL = [NSString stringWithFormat:@"http://maps.google.com/maps?q="];
}

-(void)takePicture {
	
//	[[self captureManager] captureStillImage];
	[[self captureManager] takePicture];
	
}

- (void)saveImageToPhotoAlbum
{
	UIImageWriteToSavedPhotosAlbum([[self captureManager] stillImage], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
	
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
	//Get the filename of the sound file:
	NSString *path = [NSString stringWithFormat:@"%@%@", 
					  [[NSBundle mainBundle] resourcePath],
					  @"/alarm.wav"];
	//declare a system sound id
	SystemSoundID soundID;
	//Get a URL for the sound file
	NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
	//Use audio sevices to create the sound
	AudioServicesCreateSystemSoundID((CFURLRef)filePath, &soundID);
	//Use audio services to play the sound
	AudioServicesPlaySystemSound(soundID);
	
	if (error != NULL) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image couldn't be saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
}


-(void)settingPressed:(id)sender
{
	UIButton *button=(UIButton*)sender;
	
	if (button.alpha>0.5)
	{
		settingViewAppeared=YES;
		[self dismissModalViewControllerAnimated:YES];
	}
	else {
		button.alpha=1;
		[self performSelector:@selector(fadeOutButton:) withObject:button afterDelay:4.0f];
	}
	
	[self presentModalViewController:[appDelegate navController] animated:YES];
}

-(void)fadeOutButton:(id)sender
{
	UIButton *button=(UIButton*)sender;
	
	[UIView beginAnimations:@"fadeOutButton" context:nil];
	[UIView setAnimationDuration:0.5];
	
	[button setAlpha:0.05];
	
	[UIView commitAnimations];
}

-(void)showTrans
{
	if ([appDelegate screens].count)
	{
		settingViewAppeared=NO;
		[self dismissModalViewControllerAnimated:YES];
	}
	else {
		UIAlertView *alert=[[[UIAlertView alloc] initWithTitle:@"Alert"
													   message:@"Fake screens aren't set yet.\nPlease add some screens." 
													  delegate:nil
											 cancelButtonTitle:@"OK"
											 otherButtonTitles:nil] autorelease];
		[alert show];
	}
}


- (void)dealloc {
	[picker release];
	[pageControl release];
//	self.session=nil;
//	self.cameraImageView=nil;
	self.captureManager=nil;
	self.overlayView=nil;
	self.scrollView=nil;
	
    [super dealloc];
}


@end
