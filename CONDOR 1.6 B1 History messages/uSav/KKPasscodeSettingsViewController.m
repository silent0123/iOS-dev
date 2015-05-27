//
// Copyright 2011-2012 Kosher Penguin LLC 
// Created by Adar Porat (https://github.com/aporat) on 1/16/2012.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//		http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "KKPasscodeSettingsViewController.h"
#import "KKKeychain.h"
#import "KKPasscodeViewController.h"
#import "KKPasscodeLock.h"
#import "USAVLock.h"
#import "SGDUtilities.h"
#import <LocalAuthentication/LocalAuthentication.h> //TOUCH ID

@implementation KKPasscodeSettingsViewController


@synthesize delegate = _delegate;

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad
{
    [self.doneBtn setTitle:NSLocalizedString(@"DoneLabel", @"")];
    [self.doneBtn setTintColor:[UIColor colorWithRed:20.0/255.0 green:120.0/255.0 blue:1 alpha:1]];
    [self.doneBtn setStyle:UIBarButtonItemStyleDone];
	[super viewDidLoad];
	self.navigationItem.title = NSLocalizedString(@"Passcode Lock", @"");
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"topbar"]];
    
		
	_eraseDataSwitch = [[UISwitch alloc] init];
	[_eraseDataSwitch addTarget:self action:@selector(eraseDataSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appToBackground:) name:@"AppIntoBackground"
                                               object:nil];
    self.touchIDEnabled = [[NSUserDefaults standardUserDefaults] integerForKey:@"touchIDEnabled"];
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Inner_bg_lightgray"]];
    
}

-(void)appToBackground:(BOOL)animated
{
    [self dismissViewControllerAnimated:NO completion:nil];
     [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)viewDidUnload
{  
  _eraseDataSwitch = nil;

  [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"topbar"]];
    
	_passcodeLockOn = [[KKKeychain getStringForKey:@"passcode_on"] isEqualToString:@"YES"];
	_eraseDataOn = [[KKKeychain getStringForKey:@"erase_data_on"] isEqualToString:@"YES"];
	_eraseDataSwitch.on = _eraseDataOn;
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) || (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)doneBtnPressed:(id)sender {
    
    [SGDUtilities showSuccessMessageWithTitle:NSLocalizedString(@"Success", "") message:@"" delegate:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		_eraseDataOn = YES;
		[KKKeychain setString:@"YES" forKey:@"erase_data_on"];
	} else {
		_eraseDataOn = NO;
		[KKKeychain setString:@"NO" forKey:@"erase_data_on"];
	}
	[_eraseDataSwitch setOn:_eraseDataOn animated:YES];
}

- (void)eraseDataSwitchChanged:(id)sender 
{
	if (_eraseDataSwitch.on) {
		NSString* title = [NSString stringWithFormat:NSLocalizedString(@"All data in this app will be erased after %zi failed passcode attempts.", @""), [[KKPasscodeLock sharedLock] attemptsAllowed]];
		
		UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:NSLocalizedString(@"Enable", @"") otherButtonTitles:nil];
        
		[sheet showInView:self.view];
	} else {
		_eraseDataOn = NO;
		[KKKeychain setString:@"NO" forKey:@"erase_data_on"];
	}		 
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{/*
	if ([[KKPasscodeLock sharedLock] eraseOption]) {
		return 4;
	}
	*/
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"topbar"]];
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if (section == 2) {
		return [NSString stringWithFormat:NSLocalizedString(@"Erase all content in the app after %zi failed passcode attempts.", @""), [[KKPasscodeLock sharedLock] attemptsAllowed]];;
	} else {
		return @"";
	}
}
*/

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	static NSString *CellIdentifier = @"KKPasscodeSettingsCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
	}
  
    cell.accessoryView = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    //cell.textLabel.textAlignment = UITextAlignmentLeft;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.backgroundColor = [UIColor clearColor];

	
	if (indexPath.section == 0) {
		//cell.textLabel.textAlignment = UITextAlignmentCenter;
		if (_passcodeLockOn) {
			cell.textLabel.text = NSLocalizedString(@"Turn Passcode Off", @"");
		} else {
			cell.textLabel.text = NSLocalizedString(@"Turn Passcode On", @"");
		}
	} else if (indexPath.section == 1) {
		cell.textLabel.text = NSLocalizedString(@"Change Passcode", @"");
		//cell.textLabel.textAlignment = UITextAlignmentCenter;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
		if (!_passcodeLockOn) {
			cell.textLabel.textColor = [UIColor grayColor];
		}
	} /*else if (indexPath.section == 2) {
		cell.textLabel.text = NSLocalizedString(@"Erase Data", @"");
		cell.accessoryView = _eraseDataSwitch;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		if (_passcodeLockOn) {
			cell.textLabel.textColor = [UIColor blackColor];
			_eraseDataSwitch.enabled = YES;
		} else {
			cell.textLabel.textColor = [UIColor grayColor];
			_eraseDataSwitch.enabled = NO;
		}
	} */else if (indexPath.section == 2) {
        //cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.text = NSLocalizedString(@"PasscodeLock", "");
        cell.detailTextLabel.text = [[USAVLock defaultLock] getLockTimeStr];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        //cell.detailTextLabel.text = NSLocalizedString(@"Off", "");
/*
        if (!_passcodeLockOn) {
			cell.textLabel.textColor = [UIColor grayColor];
		}*/
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_next_black"] highlightedImage:[UIImage imageNamed:@"icon_next_blue"]];
    } else if (indexPath.section == 3) {
        
        //Touch ID
        if (!self.touchIDSwitch) {
            self.touchIDSwitch = [[UISwitch alloc] init];
            [self.touchIDSwitch addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
            self.touchIDSwitch.onTintColor = [UIColor colorWithWhite:0.2 alpha:1];
        }
        
        if (!self.touchIDEnabled) {
            [self.touchIDSwitch setOn:NO];
        } else {
            [self.touchIDSwitch setOn:YES];
        }
        
        cell.accessoryView = self.touchIDSwitch;
        cell.textLabel.text = NSLocalizedString(@"Use Touch ID", nil);
        if ([self canEvaluatePolicy]) {
            cell.userInteractionEnabled = YES;
            cell.textLabel.textColor = [UIColor blackColor];
        } else {
            cell.userInteractionEnabled = NO;
            cell.textLabel.textColor = [UIColor grayColor];
            self.touchIDEnabled = 0;
            [self.touchIDSwitch setOn:NO];
        }
    }
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	if (indexPath.section == 0) {
		KKPasscodeViewController* vc = [[KKPasscodeViewController alloc] initWithNibName:nil 
																																							 bundle:nil];
		vc.delegate = self;
		
		if (_passcodeLockOn) {
			vc.mode = KKPasscodeModeDisabled;
		} else {
			vc.mode = KKPasscodeModeSet;
		}
		
		UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
		 
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			nav.modalPresentationStyle = UIModalPresentationFormSheet;
			nav.navigationBar.barStyle = UIBarStyleBlack;
			nav.navigationBar.opaque = NO;
		} else {
            [self customizedNavigationBar:self.navigationController.navigationBar WithTintColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"topbar"]]];
		}
		[self presentViewController:nav animated:YES completion:nil];

		//[self.navigationController presentModalViewController:nav animated:YES];
		
	} else if (indexPath.section == 1 && _passcodeLockOn) {
		KKPasscodeViewController *vc = [[KKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
		vc.delegate = self;
		
		vc.mode = KKPasscodeModeChange;							
		
		UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
		
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			nav.modalPresentationStyle = UIModalPresentationFormSheet;
			nav.navigationBar.barStyle = UIBarStyleBlack;
			nav.navigationBar.opaque = NO;
		} else {
            [self customizedNavigationBar:self.navigationController.navigationBar WithTintColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"topbar"]]];
		}
        
		[self presentViewController:nav animated:YES completion:nil];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
	} else if (indexPath.section == 2) {
        [self performSegueWithIdentifier:@"TimeSelect" sender:self];
    }
}

- (void)didSettingsChanged:(KKPasscodeViewController*)viewController 
{
	_passcodeLockOn = [[KKKeychain getStringForKey:@"passcode_on"] isEqualToString:@"YES"];
	//_eraseDataOn = [[KKKeychain getStringForKey:@"erase_data_on"] isEqualToString:@"YES"];
	//_eraseDataSwitch.on = _eraseDataOn;
    
    //如果之前没有设置过超时时间，则设置为Always
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"timeout"] integerValue] == 2147483647){
        NSLog(@"time has been set from default to always");
        [[USAVLock defaultLock] setTimeOut:0];
    }
    
	[self.tableView reloadData];
	
	if ([_delegate respondsToSelector:@selector(didSettingsChanged:)]) {
		[_delegate performSelector:@selector(didSettingsChanged:) withObject:self];
	}
	
}

#pragma mark - Biometrics Auth - Touch ID
//Touch ID
- (void) switchChanged {
    
    if (self.touchIDSwitch.isOn) {
        self.touchIDEnabled = 1;
    } else {
        self.touchIDEnabled = 0;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.touchIDEnabled forKey:@"touchIDEnabled"];
    
}



- (BOOL)canEvaluatePolicy
{
    LAContext *context = [[LAContext alloc] init];
    NSError *error;
    BOOL success;
    
    // test if we can evaluate the policy, this test will tell us if Touch ID is available and enrolled
    success = [context canEvaluatePolicy: LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    if (success) {
        return YES;
    } else {
        return NO;
    }
    
    
}

#pragma mark - NavigationBar颜色修改
- (void)customizedNavigationBar: (UINavigationBar *)navigationBar WithTintColor: (UIColor *)tintColor {
    
    [navigationBar setBarTintColor:tintColor];
}


@end

