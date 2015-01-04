//
//  HelpViewController.m
//  TransWallpaper
//
//  Created by obscured on 10. 8. 11..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HelpViewController.h"


@implementation HelpViewController

@synthesize scrollView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
         Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title=@"How to use";
	
	scrollView.contentSize=CGSizeMake(320, 1080);
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[scrollView release];
	
    [super dealloc];
}

-(IBAction)savePressed:(id)sender
{
	UIImageWriteToSavedPhotosAlbum([UIImage imageNamed:@"blackBG.PNG"], self, @selector(image:didFinishSavingWithError:contextInfo:), nil); 
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
	UIAlertView *alert=[[[UIAlertView alloc] initWithTitle:@"Saved"
												   message:@"Black wallpaper is saved."// \nExit and save images." 
												  delegate:nil
										 cancelButtonTitle:@"OK"
										 otherButtonTitles:nil] autorelease];
	[alert show];
}

@end
