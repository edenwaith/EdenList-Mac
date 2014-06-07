//
//  MyDocument.h
//  EdenList
//
//  Created by Chad Armstrong on Thu Apr 08 2004.
//  Copyright (c) 2003 - 2014 Edenwaith. All rights reserved.
//


#import <Cocoa/Cocoa.h>

#define kELTableDataType @"ELTableDataType"
#define kVersionKey		 @"Version"
#define kRecordsKey		 @"Records"
#define kNotesKey		 @"Notes"
#define kCommentsKey	 @"Comments"
#define kToDoKey		 @"ToDo"
#define kCheckBoxKey	 @"CheckBox"

@interface MyDocument : NSDocument
{
	IBOutlet	NSTableView		*table;	// Set to NSTableView
	IBOutlet	NSTextView		*commentsTextView; // Set to NSTextView
	IBOutlet	NSTextField 	*itemField; // is itemField or dataTextField not used?
	IBOutlet	NSTextField		*dataTextField;
	IBOutlet	NSButton		*deleteButton;
	
	NSData						*tableData;
	
	NSMutableDictionary			*dataDict;	// What is this used for?
	NSMutableArray				*records;
	NSString					*recordsFile;
}

- (IBAction) addRecord: (id)sender;
- (IBAction) deleteRecord: (id)sender;
- (IBAction) deleteAllRecords: (id) sender;
- (IBAction) deselectAllRecords: (id) sender;

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op;
- (void) tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors;
- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *) printSettings error:(NSError **)outError;

@end
