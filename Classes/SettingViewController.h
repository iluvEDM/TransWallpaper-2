//
//  SettingViewController.h
//  TransWallpaper
//
//  Created by obscured on 10. 8. 11..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TransWallpaperAppDelegate,TransWallpaperViewController;

@interface SettingViewController : UITableViewController 
<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
	TransWallpaperAppDelegate *appDelegate;
	UIViewController<TransWallpaperDelegate> *transViewController;
	
	UISlider *opaSlider;
	UISwitch *opaSwitch;
	UISwitch *scrollSwitch;
}

@property (nonatomic,retain) UISwitch *scrollSwitch;
@property (nonatomic,retain) UISwitch *opaSwitch;
@property (nonatomic,retain) UISlider *opaSlider;
@property (nonatomic,retain) UIViewController<TransWallpaperDelegate> *transViewController;

-(void)opacityChanged:(id)sender;
-(void)opacityDirectionChanged:(id)sender;
-(void)modeChanged:(id)sender;

@end
