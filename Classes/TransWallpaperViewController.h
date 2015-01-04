//
//  TransWallpaperViewController.h
//  TransWallpaper
//
//  Created by obscured on 10. 8. 9..
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TransWallpaperAppDelegate;

@interface TransWallpaperViewController : UIViewController 
<UIScrollViewDelegate,TransWallpaperDelegate>
{
	TransWallpaperAppDelegate *appDelegate;
	UIImagePickerController *picker;
	BOOL settingViewAppeared;
	UIPageControl *pageControl;
}

@property (nonatomic,retain) UIPageControl *pageControl;
@property (nonatomic,retain) UIImagePickerController *picker;

-(UIImage*)makeBackgroundTransparentImage:(UIImage*)image;
-(UIImage*)makeTransparentImage:(UIImage*)image;

@end

