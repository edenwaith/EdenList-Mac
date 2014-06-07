//
//  GeneralController.m
//  EdenList
//
//  Created by Chad Armstrong on Thu May 11 2006.
//  Copyright (c) 2003 - 2014 Edenwaith. All rights reserved.
//

#import "GeneralController.h"

@implementation GeneralController

// =========================================================================
// (IBAction) checkForNewVersion : (id)sender
// -------------------------------------------------------------------------
// Check to see if a newer version of the application exists
// -------------------------------------------------------------------------
// Created: 16 May 2006
// Version: 16 May 2006
// =========================================================================
- (IBAction) checkForNewVersion: (id) sender
{
	NSString *applicationName = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleName"];
	NSString *currentVersionNumber = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSDictionary *productVersionDict = [NSDictionary dictionaryWithContentsOfURL: [NSURL URLWithString:@"http://www.edenwaith.com/xml/version.xml"]];
    NSString *latestVersionNumber = [productVersionDict valueForKey:@"EdenList"];
    int button = 0;

    if ( latestVersionNumber == nil )
    {
        NSBeep();
		NSRunAlertPanel(NSLocalizedString(@"UpdateFailureTitle", nil), NSLocalizedString(@"UpdateFailureMsg", nil), NSLocalizedString(@"OK", nil), nil, nil, applicationName);
    }
    else if ( [latestVersionNumber isEqualTo: currentVersionNumber] )
    {
        NSRunAlertPanel(NSLocalizedString(@"SoftwareUpToDate", nil), NSLocalizedString(@"RecentVersionMsg", nil), NSLocalizedString(@"OK", nil), nil, nil, applicationName);
    }
    else
    {
        button = NSRunAlertPanel(NSLocalizedString(@"NewVersionAvailableTitle", nil), NSLocalizedString(@"NewVersionAvailableMsg", nil), NSLocalizedString(@"Download", nil), NSLocalizedString(@"Cancel", nil), NSLocalizedString(@"MoreInfo", nil), latestVersionNumber, applicationName);
        
        if (NSOKButton == button) // Download
        {
            [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://www.edenwaith.com/downloads/edenlist.php"]];
        }
        else if (NSAlertOtherReturn == button) // More Info
        {
            [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://www.edenwaith.com/products/edenlist/index.php"]];
        }
    }
}


// =========================================================================
// (IBAction) goToProductPage : (id)sender
// -------------------------------------------------------------------------
// Go to the product's web page
// -------------------------------------------------------------------------
// Created: 16 May 2006
// Version: 16 May 2006
// =========================================================================
- (IBAction) goToProductPage : (id) sender
{
	[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://www.edenwaith.com/products/edenlist/"]];
}


// =========================================================================
// (IBAction) sendFeedback : (id)sender
// -------------------------------------------------------------------------
// Send a support e-mail
// -------------------------------------------------------------------------
// Created: 16 May 2006
// Version: 16 May 2006
// =========================================================================
- (IBAction) sendFeedback: (id) sender
{
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"mailto:support@edenwaith.com?subject=EdenList%20Feedback"]];
}

@end
