//
//  TransWallpaperAppDelegate.h
//  TransWallpaper
//
//  Created by obscured on 10. 8. 9..
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingViewController;

@interface TransWallpaperAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UIViewController<TransWallpaperDelegate> *viewController;
	UINavigationController *navController;
	SettingViewController *settingTable;
	NSMutableArray *screens;
	
	int mode;
	float opacity;
	int opacityDirection;
}

@property (nonatomic) int mode;
@property (nonatomic) float opacity;
@property (nonatomic) int opacityDirection;
@property (nonatomic,retain) UINavigationController *navController;
@property (nonatomic,retain) SettingViewController *settingTable;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIViewController<TransWallpaperDelegate> *viewController;
@property (nonatomic,retain) NSMutableArray *screens;

-(void)saveScreens;

@end

