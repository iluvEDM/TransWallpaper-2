//
//  SettingViewController.m
//  TransWallpaper
//
//  Created by obscured on 10. 8. 11..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingViewController.h"
#import "TransWallpaperViewController.h"
#import "TransWallpaperAppDelegate.h"
#import "HelpViewController.h"

@implementation SettingViewController

@synthesize transViewController;
@synthesize opaSlider,opaSwitch,scrollSwitch;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	appDelegate=(TransWallpaperAppDelegate*)[[UIApplication sharedApplication] delegate];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	
	self.navigationItem.title=@"Settings";
	
	UIBarButtonItem *runButton=[[UIBarButtonItem alloc] initWithTitle:
								NSLocalizedString(@"TransWallpaper",@"TransWallpaper")
																style:UIBarButtonItemStylePlain
															   target:self
															   action:@selector(backToWall)];
	self.navigationItem.leftBarButtonItem=runButton;
	self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
																						  target:self
																						  action:@selector(startEditing)] autorelease];
	[runButton release];

	UISlider *slider=[[UISlider alloc] initWithFrame:CGRectMake(130, 0, 170, 44)];
	slider.maximumValue=1;
	slider.minimumValue=0;
	slider.value=appDelegate.opacity;
	[slider addTarget:self action:@selector(opacityChanged:) forControlEvents:UIControlEventValueChanged];
	self.opaSlider=slider;
	[slider release];
	
	UISwitch *sw=[[UISwitch alloc] init];
	sw.on=appDelegate.opacityDirection;
	[sw addTarget:self action:@selector(opacityDirectionChanged:) forControlEvents:UIControlEventValueChanged];
	self.opaSwitch=sw;
	[sw release];

	sw=[[UISwitch alloc] init];
	sw.on=appDelegate.mode;
	[sw addTarget:self action:@selector(modeChanged:) forControlEvents:UIControlEventValueChanged];
	self.scrollSwitch=sw;
	[sw release];
	
}

- (void)viewWillAppear:(BOOL)animated {
	[(UITableView*)self.view reloadData];
    [super viewWillAppear:animated];
}
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case 0:
			return @"";
			break;
		case 1:
			return @"Opacity settings";
			break;
		case 2:
			return @"Scroll setting";
			break;
		case 3:
			return @"Screens";
			break;
	}
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case 0:
			return 2;
			break;
		case 1:
			return 2;
			break;
		case 2:
			return 1;
			break;
		case 3:
			return 1+[appDelegate screens].count;
			break;
	}
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
       cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

	switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
				case 0:
					cell.imageView.image=nil;
					cell.textLabel.text=NSLocalizedString(@"How to use",@"How to use");
					cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
					cell.accessoryView=nil;
					break;
				case 1:
					cell.imageView.image=nil;
					cell.textLabel.text=NSLocalizedString(@"Restore default settings",@"restore");
					cell.accessoryView=nil;
					cell.accessoryType=UITableViewCellAccessoryNone;
					break;
			}
			break;
		case 1:
			switch (indexPath.row) {
				case 0:
					cell.imageView.image=nil;
					cell.textLabel.text=@"Opacity";
					cell.accessoryView=opaSlider;
					break;
				case 1:
					cell.imageView.image=nil;
					cell.textLabel.text=@"White to transparent";
					cell.accessoryView=opaSwitch;
					break;
			}
			break;
		case 2:
			cell.imageView.image=nil;
			cell.textLabel.text=@"Wallpaper scroll";
			cell.accessoryType=UITableViewCellAccessoryNone;
			cell.accessoryView=scrollSwitch;
			break;
		case 3:
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text=NSLocalizedString(@"Add image",@"addimage");
					cell.imageView.image=nil;
					cell.accessoryView=nil;
					break;
				default:
					cell.textLabel.text=@"";
					cell.accessoryView=nil;
					cell.accessoryType=UITableViewCellAccessoryNone;
					cell.imageView.image=[[appDelegate screens] objectAtIndex:indexPath.row-1];
					break;
			}
			break;
	}
	
    // Configure the cell...
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
	
	if (indexPath.section==3 && indexPath.row>0)
		return YES;
	
	return NO;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		[[appDelegate screens] removeObjectAtIndex:indexPath.row-1];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	UIImage *image=[[appDelegate screens] objectAtIndex:fromIndexPath.row-1];
	[[appDelegate screens] removeObjectAtIndex:fromIndexPath.row-1];
	[[appDelegate screens] insertObject:image atIndex:toIndexPath.row-1];
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
	if (indexPath.section==3 && indexPath.row>0)
		return YES;
	
	return NO;
}


#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section==3  && indexPath.row>0)
		return 75;
	
	return 44;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section==1 || indexPath.section==2)
		return nil;
	
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
				case 0:
				{
					HelpViewController *helpViewController=[[HelpViewController alloc] 
															initWithNibName:@"HelpViewController"
																	 bundle:nil];
					[self.navigationController pushViewController:helpViewController animated:YES];
					[helpViewController release];
					break;
				}
				case 1:
					opaSlider.value=0.5;
					opaSwitch.on=0;
					scrollSwitch.on=1;
					[self opacityChanged:opaSlider];
					[self opacityDirectionChanged:opaSwitch];
					[self modeChanged:scrollSwitch];
					[tableView deselectRowAtIndexPath:indexPath animated:YES];
					break;
			}
			break;
		case 1:
			break;
		case 2:
			break;
		case 3:
			if (indexPath.row)
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
			else {
				UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
				imagePickerController.delegate = self;
				imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
				[self presentModalViewController:imagePickerController animated:YES];
			}
			break;
	}
	
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
	//NSValue *rectValue=[info objectForKey:UIImagePickerControllerCropRect];
	//CGRect rect=[rectValue CGRectValue];
	
	[appDelegate.screens addObject:image];
	[(UITableView*)self.view reloadData];
	
    // Dismiss the image selection, hide the picker and
    //show the image view with the picked image
	[picker dismissModalViewControllerAnimated:YES];
	[picker release];
	
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissModalViewControllerAnimated:YES];
	[picker release];
    // Dismiss the image selection and close the program
}

-(void)backToWall
{
	[transViewController showTrans];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[scrollSwitch release];
	[opaSlider release];
	[opaSwitch release];
	[transViewController release];
    [super dealloc];
}

#pragma mark -
#pragma mark Event

-(void)startEditing
{
	if (self.editing)
	{
		self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
																							  target:self
																							  action:@selector(startEditing)] autorelease];
		self.editing=NO;
	}
	else {
		self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																							  target:self
																							  action:@selector(startEditing)] autorelease];
		self.editing=YES;
	}

}

-(void)opacityChanged:(id)sender
{
	appDelegate.opacity=[(UISlider*)sender value];
}

-(void)opacityDirectionChanged:(id)sender
{
	appDelegate.opacityDirection=[(UISwitch*)sender isOn];
}

-(void)modeChanged:(id)sender
{
	appDelegate.mode=[(UISwitch*)sender isOn];
}

@end

