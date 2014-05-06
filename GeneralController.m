//
//  GeneralController.m
//  EdenList
//
//  Created by Chad Armstrong on Thu May 11 2006.
//  Copyright (c) 2003 - 2007 Edenwaith. All rights reserved.
//

#import "GeneralController.h"

@implementation GeneralController

// =========================================================================
// (IBAction) checkForNewVersion : (id)sender
// -------------------------------------------------------------------------
// Created: 16 May 2006
// Version: 16 May 2006
// -------------------------------------------------------------------------
// 
// =========================================================================
- (IBAction) checkForNewVersion: (id) sender
{
	NSString *currentVersionNumber = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSDictionary *productVersionDict = [NSDictionary dictionaryWithContentsOfURL: [NSURL URLWithString:@"http://www.edenwaith.com/version.xml"]];
    NSString *latestVersionNumber = [productVersionDict valueForKey:@"EdenList"];
    int button = 0;

    if ( latestVersionNumber == nil )
    {
        NSBeep();
        NSRunAlertPanel(@"Could not check for update", @"A problem arose while attempting to check for a new version of EdenList.  Edenwaith.com may be temporarily unavailable or your network may be down.", @"OK", nil, nil);
    }
    else if ( [latestVersionNumber isEqualTo: currentVersionNumber] )
    {
        NSRunAlertPanel(@"Software is Up-To-Date", @"You have the most recent version of EdenList.", @"OK", nil, nil);
    }
    else
    {
		NSLog(@"currentVersionNumber: %@", currentVersionNumber);
        button = NSRunAlertPanel(@"New Version is Available", @"Version %@ of EdenList is available.", @"Download", @"Cancel", @"More Info", latestVersionNumber);
        
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
// Created: 16 May 2006
// Version: 16 May 2006
// -------------------------------------------------------------------------
// 
// =========================================================================
- (IBAction) goToProductPage : (id) sender
{
	[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://www.edenwaith.com/products/edenlist/"]];
}


// =========================================================================
// (IBAction) sendFeedback : (id)sender
// -------------------------------------------------------------------------
// Created: 16 May 2006
// Version: 16 May 2006
// -------------------------------------------------------------------------
// 
// =========================================================================
- (IBAction) sendFeedback: (id) sender
{
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"mailto:support@edenwaith.com?subject=EdenList%20Feedback"]];
}

@end
