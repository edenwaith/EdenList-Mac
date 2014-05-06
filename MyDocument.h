//
//  MyDocument.h
//  EdenList
//
//  Created by Chad Armstrong on Thu Apr 08 2004.
//  Copyright (c) 2003 - 2007 Edenwaith. All rights reserved.
//


#import <Cocoa/Cocoa.h>

#define kELTableDataType @"ELTableDataType"
#define kNotesKey	@"Notes"

@interface MyDocument : NSDocument
{
	IBOutlet	NSTextField 	*itemField;

	IBOutlet id	commentsTextView;
	IBOutlet id	table;
	IBOutlet	NSTextField		*dataTextField;
	IBOutlet	NSButton		*deleteButton;
	
	NSData		*tableData;
	
	NSMutableDictionary *data_dict;
	NSMutableArray  	*records; // rename to records
	NSString 			*recordsFile;
}

// Prototypes

// - (BOOL) readFromFile: (NSString *) fileName ofType: (NSString *) aType;

- (IBAction) addRecord: (id)sender;
- (IBAction) deleteRecord: (id)sender;
- (IBAction) deleteAllRecords: (id) sender;
- (IBAction) deselectAllRecords: (id) sender;
- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op;
- (void) tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors;
- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *) printSettings error:(NSError **)outError;
//- (void) printShowingPrintPanel: (BOOL) flag;

@end
