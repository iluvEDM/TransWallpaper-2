//
//  TransWallpaperViewController.m
//  TransWallpaper
//
//  Created by obscured on 10. 8. 9..
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "TransWallpaperViewController.h"
#import "SettingViewController.h"
#import "TransWallpaperAppDelegate.h"

// Transform values for full screen support:
//#define CAMERA_TRANSFORM_X 1
//#define CAMERA_TRANSFORM_Y 1.12412
#define CAMERA_TRANSFORM_X 1.25
#define CAMERA_TRANSFORM_Y 1.25

// iPhone screen dimensions:
#define SCREEN_WIDTH  320
#define SCREEN_HEIGTH 480
#define NSCREEN_WIDTH 320
#define NSCREEN_HEIGTH

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


@implementation TransWallpaperViewController


@synthesize picker,pageControl;
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
- (void)loadView {
	UIView *v=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGTH)];
	v.backgroundColor=[UIColor blackColor];
	self.view=v;
	[v release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	appDelegate=(TransWallpaperAppDelegate*)[[UIApplication sharedApplication] delegate];
	appDelegate.settingTable.transViewController=self;
	
    // Show the picker:
    [super viewDidLoad];
}


- (void) viewDidAppear:(BOOL)animated {
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
			
			
			//	[overlay addSubview:[[[UIImageView alloc] initWithImage:image] autorelease]]; 
			// Create a new image picker instance:
			UIImagePickerController *imagepicker = [[UIImagePickerController alloc] init];
			self.picker=imagepicker;
			[imagepicker release];
			
			// Set the image picker source:
			picker.sourceType = UIImagePickerControllerSourceTypeCamera;
			
			// Hide the controls:
			picker.showsCameraControls = NO;
			picker.navigationBarHidden = YES;
			
			//	picker.wantsFullScreenLayout=NO;
			// Make camera view full screen:
			picker.wantsFullScreenLayout = YES;
			picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, CAMERA_TRANSFORM_X, CAMERA_TRANSFORM_Y);
			
			UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGTH)];
            CGRect screenBounds = [[UIScreen mainScreen] bounds];
            int width = screenBounds.size.width;
            int height = screenBounds.size.height;
			
			if (!appDelegate.mode)
			{
				UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGTH)];
				scrollView.contentSize=CGSizeMake(SCREEN_WIDTH*appDelegate.screens.count, SCREEN_HEIGTH);
				scrollView.pagingEnabled=YES;
				scrollView.showsHorizontalScrollIndicator=NO;
				
				int i=0;
				
				for (UIImage *image in appDelegate.screens)
				{
					UIImage *image2=[self makeTransparentImage:image];
					UIImageView *imageView=[[UIImageView alloc] initWithImage:image2];
					imageView.center=CGPointMake(width/2+width*i,height/2);
					[scrollView addSubview:imageView];
					[imageView release];
					
					i++;
				}
				[overlay addSubview:scrollView];
				scrollView.delegate=self;
				[scrollView release];
			}
			else {


				UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGTH)];
				scrollView.contentSize=CGSizeMake(SCREEN_WIDTH*appDelegate.screens.count, SCREEN_HEIGTH);
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
					UIImage *image2=[self makeTransparentImage:image];
					UIImageView *imageView=[[UIImageView alloc] initWithImage:image2];
					imageView.center=CGPointMake(width/2+width*i,height/2);
					[scrollView addSubview:imageView];
					[imageView release];
					
					i++;
				}
				
				[overlay addSubview:scrollView];
				scrollView.delegate=self;
				[scrollView release];
				
				UIPageControl *pc=[[UIPageControl alloc] initWithFrame:CGRectZero];
				self.pageControl=pc;
				[pc release];
				
				pageControl.center=CGPointMake(width/2, height/2+165);
				pageControl.numberOfPages=scrollView.contentSize.width/width;
				pageControl.currentPage=0;
				
				[overlay addSubview:pageControl];
				
			}
			
			// Insert the overlay:
			picker.cameraOverlayView = overlay;
			
			[overlay release];
			//	CGRect frame = picker.view.frame;
			//    frame.origin.y += 30;
			//    frame.size.height -= 30;
			//    picker.view.frame = frame;
			
			UIButton *optionButton=[UIButton buttonWithType:UIButtonTypeInfoLight];
			[optionButton addTarget:self action:@selector(settingPressed:) forControlEvents:UIControlEventTouchUpInside];
			[optionButton setCenter:CGPointMake(300, 20)];
			
			[overlay addSubview:optionButton];
			
			[self performSelector:@selector(fadeOutButton:) withObject:optionButton afterDelay:4.0f];
			
			[self presentModalViewController:picker animated:YES];
			
		}

	}
    [super viewDidAppear:YES];
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
} 

#pragma mark -
#pragma mark scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	pageControl.currentPage=(scrollView.contentOffset.x+160)/320;
}


-(UIImage*)makeTransparentImage:(UIImage*)image
{
 
    NSLog(@"MTI");
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    int width = screenBounds.size.width;
    int height = screenBounds.size.height;
	UIImage *dstImage;
	UInt32 *src=(UInt32*)malloc(height*width*4);
    UInt32 *dst=(UInt32*)malloc(height*width*4);

	CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
	CGContextRef tempcontext=CGBitmapContextCreate(src, width, height, 8, width*4, colorSpace,kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colorSpace);
	CGContextDrawImage(tempcontext, CGRectMake(0, 0, width, height),[image CGImage]);

	if (appDelegate.mode)
	{
		memset(src, 0, 20*width*4);
		for (int i=20;i<380;i++)
			for (int j=0;j<width;j++)
			{
				src[j+i*width]=calcAlpha(src[j+i*width], appDelegate.opacity,appDelegate.opacityDirection);
			}
		memset(&(src[380*width]), 0, 100*width*4);
	}
	else {
		for (int i=0;i<height;i++)
			for (int j=0;j<width;j++)
			{
				src[j+i*width]=calcAlpha(src[j+i*width], appDelegate.opacity,appDelegate.opacityDirection);
			}
	}

	
	CGImageRef imRef = CGBitmapContextCreateImage(tempcontext);
    dstImage=[UIImage imageWithCGImage:imRef];
	
	CGContextRelease(tempcontext);
	CGImageRelease(imRef);
	free(src);
	free(dst);
	
	return dstImage;
}
								
-(UIImage*)makeBackgroundTransparentImage:(UIImage*)image;
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    int width = screenBounds.size.width;
    int height = screenBounds.size.height;
    

    
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
	
	memset(&(src[20*width]), 0, 360*width*4);
	
	memset_pattern4(&(src[380*320]), &blank ,20*320*4);
	
	for (int i=height-80;i<height;i++)
		for (int j=0;j<width;j++)
		{
			src[j+i*width]=calcAlpha(src[j+i*width], appDelegate.opacity,appDelegate.opacityDirection);
		}
	
	CGImageRef imRef = CGBitmapContextCreateImage(tempcontext);
    dstImage=[UIImage imageWithCGImage:imRef];
	
	CGContextRelease(tempcontext);
	CGImageRelease(imRef);
	free(src);
	free(dst);
	
	return dstImage;
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
	
	//[self presentModalViewController:[appDelegate navController] animated:YES];
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
	
    [super dealloc];
}


@end
