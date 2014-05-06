/* GeneralController */
//
//  GeneralController.h
//  EdenList
//
//  Created by Chad Armstrong on Thu May 11 2006.
//  Copyright (c) 2006 Edenwaith. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GeneralController : NSObject
{
}

- (IBAction) checkForNewVersion: (id) sender;
- (IBAction) goToProductPage : (id) sender;
- (IBAction) sendFeedback: (id) sender;

@end
