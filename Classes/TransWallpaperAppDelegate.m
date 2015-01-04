//
//  TransWallpaperAppDelegate.m
//  TransWallpaper
//
//  Created by obscured on 10. 8. 9..
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "TransWallpaperAppDelegate.h"
#import "TransWallpaperViewController.h"
#import "NewTransWallpaperViewController.h"
#import "SettingViewController.h"

@implementation TransWallpaperAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize navController,settingTable;
@synthesize mode,opacity,opacityDirection;
@synthesize screens;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	
	if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"firstTime"] intValue]==0)
	{
		self.mode=1;
		self.opacity=0.5f;
		self.opacityDirection=0;
		screens=[[NSMutableArray alloc] init];
		[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:1] forKey:@"firstTime"];
	}
	else {
		mode=[[[NSUserDefaults standardUserDefaults] valueForKey:@"scrollMode"] intValue];
		opacity=[[[NSUserDefaults standardUserDefaults] valueForKey:@"opacity"] floatValue];
		opacityDirection=[[[NSUserDefaults standardUserDefaults] valueForKey:@"opacityDirection"] floatValue];

		screens=[[NSMutableArray alloc] init];

		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"/screens.dat"];
		
		NSArray *array=[NSArray arrayWithContentsOfFile:documentsDirectory];
		
		for (NSData *data in array)
		{
			[screens addObject:[UIImage imageWithData:data]];
		}
		
		[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:1] forKey:@"firstTime"];
	}
	
	if (NSClassFromString(@"AVCaptureSession")) {
		NSLog(@"new version1");
		self.viewController=[[[NewTransWallpaperViewController alloc] initWithNibName:@"NewTransWallpaperViewController"
																			   bundle:nil] autorelease];
	}
	else {
		NSLog(@"old version");
		self.viewController=[[[TransWallpaperViewController alloc] initWithNibName:@"TransWallpaperViewController"
																			   bundle:nil] autorelease];
	}

	
    // Override point for customization after application launch.
	settingTable=[[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
	navController=[[UINavigationController alloc] initWithRootViewController:settingTable];
	
	[navController.navigationBar setBarStyle:UIBarStyleBlack];
	[navController.navigationBar setTranslucent:YES];
	
    // Add the view controller's view to the window and display.
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	[self saveScreens];

}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	[self saveScreens];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

-(void)setMode:(int)aMode
{
	mode=aMode;
	[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:aMode] forKey:@"scrollMode"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setOpacity:(float)aOpacity
{
	opacity=aOpacity;
	[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:aOpacity] forKey:@"opacity"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setOpacityDirection:(int)aOD
{
	opacityDirection=aOD;
	[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:aOD] forKey:@"opacityDirection"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)saveScreens
{
	NSMutableArray *array=[[NSMutableArray alloc] initWithCapacity:[screens count]];
	
	for (UIImage *image in screens)
	{
		[array addObject:[NSData dataWithData:UIImagePNGRepresentation(image)]];
	}
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"/screens.dat"];
	[array writeToFile:documentsDirectory atomically:YES];
	
	[array release];
}

- (void)dealloc {
	[screens release];
	[settingTable release];
	[navController release];
    [viewController release];
    [window release];
    [super dealloc];
}


@end
