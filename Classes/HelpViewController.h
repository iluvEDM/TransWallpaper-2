//
//  HelpViewController.h
//  TransWallpaper
//
//  Created by obscured on 10. 8. 11..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HelpViewController : UIViewController {
	IBOutlet UIScrollView *scrollView;
}

@property (nonatomic,retain) UIScrollView *scrollView;

-(IBAction)savePressed:(id)sender;

@end
