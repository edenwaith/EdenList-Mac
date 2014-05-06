//
//  MyDocument.m
//  EdenList
//
//  Created by Chad Armstrong on Thu Apr 08 2004.
//  Copyright (c) 2003 - 2007 Edenwaith. All rights reserved.
//
//  REFERENCES
//  http://www.macdevcenter.com/pub/a/mac/2001/08/10/cocoa.html?page=4
//  http://developer.apple.com/techpubs/macosx/Cocoa/Reference/ApplicationKit/ObjC_classic/Protocols/NSTableDataSource.html#//apple_ref/occ/instm/NSObject/tableView:objectValueForTableColumn:row:
//  http://cocoa.mamasam.com/COCOADEV/2002/04/1/31132.php

#import "MyDocument.h"

@implementation MyDocument


// =========================================================================
// (id) init
// -------------------------------------------------------------------------
// 
// -------------------------------------------------------------------------
// Version: 7 June 2007
// =========================================================================
- (id)init
{
    self = [super init];
    if (self)
	{
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		data_dict = [[NSMutableDictionary alloc] init];
    
    }
	
    return self;
}


// =========================================================================
// (void) dealloc
// -------------------------------------------------------------------------
// 
// -------------------------------------------------------------------------
// =========================================================================
// Created: 1 May 2007 20:28
// Version: 19 June 2007 20:50
- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] 
		removeObserver: self 
		name: NSTextDidEndEditingNotification 
		object: commentsTextView];
  
	[super dealloc];
}


// =========================================================================
// (NSString *) windowNibName
// -------------------------------------------------------------------------
// 
// -------------------------------------------------------------------------
// =========================================================================
- (NSString *)windowNibName
{
	if (records == nil)
	{
		records = [[NSMutableArray alloc] init];
	}
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}


// =========================================================================
// (void) windowControllerDidLoadNib: (NSWindowController *)
// -------------------------------------------------------------------------
// http://www.nongnu.org/gstutorial/en/ch13s02.html
// -------------------------------------------------------------------------
// Version: 19 June 2007 20:50
// =========================================================================
- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
//	NSTableColumn *column;
//	NSArray *columns = [table tableColumns];
	
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.

	[table registerForDraggedTypes: [NSArray arrayWithObject: kELTableDataType] ];
	
	// [[self window] makeFirstResponder: dataTextField];
/*	
	// This code might be able to be removed
	column = [columns objectAtIndex: 0];
	//[column setWidth: 100];
	[column setEditable: YES];
	[column setResizable:YES];
	[column setIdentifier:@"CheckBox"];
	[[column headerCell] setStringValue: @""];
	
	column = [columns objectAtIndex: 1];
	// [column setWidth: 100];
	[column setEditable: YES];
	[column setResizable:YES];
	[column setIdentifier:@"ToDo"];
	[[column headerCell] setStringValue: @"To Do"];
*/
//textDidBeginEditing:
//textDidChange:
//textDidEndEditing:
//textShouldBeginEditing:
//textShouldEndEditing:
	[[NSNotificationCenter defaultCenter] addObserver:self 
		selector:@selector(textDidChange:) 
		name:NSTextDidEndEditingNotification // NSTextDidChangeNotification 
		object:commentsTextView]; // commentsTextView

}


// =========================================================================
// (NSData *) dataRepresentationOfType: (NSString *)
// -------------------------------------------------------------------------
// writeToFile is used instead of this method
// -------------------------------------------------------------------------
// Page on saving and loading data: http://www.nongnu.org/gstutorial/en/ch13s03.html
// http://rixstep.com/2/20050827,00.shtml
// http://www.samspublishing.com/articles/article.asp?p=32078&seqNum=2&rl=1
// =========================================================================
//- (NSData *)dataRepresentationOfType:(NSString *)aType
//{
//    // Insert code here to write your document from the given data.  You can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
//    // return nil;
//
//	return [NSArchiver archivedDataWithRootObject: records];
//	// return [[records description] dataUsingEncoding: [NSString defaultCStringEncoding]];
//}


// =========================================================================
// (BOOL) loadDataRepresentation:
// -------------------------------------------------------------------------
// readFromFile is used instead of this method.
// -------------------------------------------------------------------------
// =========================================================================
//- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
//{
//    // Insert code here to read your document from the given data.  You can also choose to override -loadFileWrapperRepresentation:ofType: or -readFromFile:ofType: instead.
//    // return YES;
//	NSLog(@"Type: %@", aType);
//   	NSLog(@"Version: %@", [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersionString"]);
//	
//	if ([aType isEqualToString: @"DocumentType"])
//	{
//		
//		records = [[NSMutableArray alloc] init];
//        [records setArray: [NSUnarchiver unarchiveObjectWithData: data]];
//		[table reloadData];
//        return YES;
//	}
//	else
//	{
//		return NO; 
//	}
//
//}


// =========================================================================
// (BOOL) writeToFile: (NSString *) ofType: (NSString *)
// -------------------------------------------------------------------------
// 
// -------------------------------------------------------------------------
// Created: 6 June 2007
// Version: 12 May 2010 22:00
// =========================================================================
- (BOOL) writeToFile: (NSString *) fileName ofType:(NSString *)aType
{
	data_dict = [[NSMutableDictionary dictionary] retain];
//	[data_dict setObject:[NSArchiver archivedDataWithRootObject: [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersionString"]] forKey:@"Version"];
//	[data_dict setObject:[NSArchiver archivedDataWithRootObject: records] forKey:@"Records"];

	[data_dict setObject: [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersionString"] forKey: @"Version"];
	[data_dict setObject: records forKey: @"Records"];
	
	return [data_dict writeToFile:fileName atomically:YES];
}


// =========================================================================
// (BOOL) readFromFile: (NSString *) ofType: (NSString *)
// -------------------------------------------------------------------------
// 
// -------------------------------------------------------------------------
// Created: 6 June 2007
// Version: 11 May 2010 22:20
// =========================================================================
- (BOOL) readFromFile: (NSString *) fileName ofType: (NSString *) aType
{
	if ([aType isEqualToString: @"DocumentType"])
	{
		records = [[NSMutableArray alloc] init];
		
		data_dict = [[NSMutableDictionary dictionaryWithContentsOfFile:fileName] retain];
		
		if (data_dict)
		{
//			NSData *versionString = [data_dict objectForKey:@"Version"];
//			NSData *recordsData = [data_dict objectForKey:@"Records"];

			id versionString = [data_dict objectForKey: @"Version"];
			id recordsData = [data_dict objectForKey:@"Records"];
			
			// Read in from older (pre 1.0) versions of EdenList files
			if (versionString != nil && [versionString isKindOfClass: [NSData class]])
			{
				[records setArray: [NSUnarchiver unarchiveObjectWithData: recordsData]];
				[table reloadData];
			}
			else if (versionString != nil && [versionString isKindOfClass: [NSString class]]) // newer files
			{
				[records setArray: recordsData];
				[table reloadData];
			}
			else
			{
				NSLog(@"Error: Cannot determine file version.");
			}

		}
		else	// Older versions of EdenList formats
		{
			NSLog(@"Error: Cannot read file");

			[records setArray: [NSUnarchiver unarchiveObjectWithFile:fileName]];
			[table reloadData];
		}
		
		[table reloadData];
        return YES;
	}
	else
	{
		return NO; 
	}
	
}



// =========================================================================
// (NSDictionary *) createRecord
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
// Created: 21 April 2007 0:06
// Version: 12 May 2010 9:43
// =========================================================================
- (NSDictionary *) createRecord
{
	NSMutableDictionary *record = [[NSMutableDictionary alloc] init];
    
	[record setObject:[NSNumber numberWithInt: 0] forKey:@"CheckBox"];
    [record setObject:[itemField stringValue] forKey:@"ToDo"];
	[record setObject:@"" forKey: kNotesKey];
	
//	[record setObject:@"" forKey:@"Comments"];
    
    [record autorelease];
    return record;
}


// =========================================================================
// (IBAction) addRecord:(id)sender
// -------------------------------------------------------------------------
// Created: 19 May 2006 21:00
// Version: 6 May 2007 23:00
// =========================================================================
- (IBAction) addRecord:(id)sender
{
    int aRow = [table selectedRow];
    
    if (aRow < 0)
    {
		[records addObject: [self createRecord]];
    }
    else
    {		
        [records insertObject:[self createRecord] atIndex:aRow+1];
    }
    
    [itemField setStringValue: @""];
    
	[self updateChangeCount:NSChangeDone];
    [table reloadData]; // this needs to be BEFORE scrollRowToVisible
    
    if (aRow < 0)
    {
        [table scrollRowToVisible: [records count]-1];
    }
    else
    {
        [table scrollRowToVisible: aRow];
    }
    
}


// =========================================================================
// (IBAction) deleteRecord:(id)sender
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
// Created: 19 May 2006 21:00
// Version: 6 May 2007 23:00
// =========================================================================
- (IBAction) deleteRecord:(id)sender
{
    // int status;
    NSEnumerator *enumerator;
    NSNumber *index;
    NSMutableArray *tempArray  = [[NSMutableArray alloc] init];
    id tempObject;
 
    if ( [table numberOfSelectedRows] <= 0 )
    {
        NSBeep();    
    }
    else 
    {
        enumerator = [table selectedRowEnumerator];
        
        while ( (index = [enumerator nextObject]) ) 
        {
            tempObject = [records objectAtIndex:[index intValue]];
            [tempArray addObject:tempObject];
        }
 
        [records removeObjectsInArray:tempArray];
        [tempArray release];
        
		[self updateChangeCount:NSChangeDone];
        [table reloadData];
   }

}


// =========================================================================
// (IBAction) deleteAllRecords: (id) sender
// -------------------------------------------------------------------------
// Created: 19 May 2006 21:00
// Version: 6 May 2007 23:00
// =========================================================================
- (IBAction) deleteAllRecords: (id) sender
{
    int num = [records count];
    int i = 0;
    int status;
    
    NSBeep();
    status = NSRunAlertPanel(NSLocalizedString(@"AlertTitle", nil), NSLocalizedString(@"DeleteAllMsg", nil), NSLocalizedString(@"OK", nil), NSLocalizedString(@"Cancel", nil), nil);
    
    if (status == NSAlertDefaultReturn)
    {
    
        for (i = num - 1; i >= 0; i--)
        {
            [records removeObjectAtIndex:i];
        }
    
    }

	[self updateChangeCount:NSChangeDone];
    [table reloadData];
}


// =========================================================================
// (IBAction) deselectAllRecords: (id) sender
// -------------------------------------------------------------------------
// Created: 28 August 2007 20:16
// Version: 28 August 2007 20:16
// =========================================================================
- (IBAction) deselectAllRecords: (id) sender
{
    [table deselectAll:self];
}


#pragma mark -
#pragma mark Table Methods
// ******************************************
// TABLE DATA SOURCE
// ******************************************

// =========================================================================
// (int)numberOfRowsInTableView:(NSTableView*)table
// -------------------------------------------------------------------------
// =========================================================================
- (int)numberOfRowsInTableView:(NSTableView*)table
{
    // returns the number of records
    return [records count];
}


// =========================================================================
// (void) tableView: 
// -------------------------------------------------------------------------
// this message is called for each row of the table
// =========================================================================
- (id)tableView:(NSTableView*)table objectValueForTableColumn:(NSTableColumn*)col row:(int)rowIndex
{
    id theRecord, theValue;
    
	NSParameterAssert(rowIndex >= 0 && rowIndex < [records count]);
    theRecord = [records objectAtIndex:rowIndex];
    theValue = [theRecord objectForKey:[col identifier]];
    
    return theValue;
}


// =========================================================================
// (void) tableView: 
// -------------------------------------------------------------------------
// Version: 6 May 2007 23:00
// =========================================================================
- (void) tableView: (NSTableView *)aTableView setObjectValue: (id)object forTableColumn:(NSTableColumn *)col row:(int) rowIndex
{
    id theRecord;
 
    NSParameterAssert(rowIndex >= 0 && rowIndex < [records count]);
    theRecord = [records objectAtIndex:rowIndex];
    [theRecord setObject:object forKey:[col identifier]];
	[self updateChangeCount:NSChangeDone];
    return;
}


// =========================================================================
// (void) tableViewSelectionDidChange: (NSNotification *) aNotification
// -------------------------------------------------------------------------
// This method is called when the selection (or highlighting) of table rows
// changes.  This is useful in reacting, such as enabling or disabling buttons
// -------------------------------------------------------------------------
// Created: 30 April 2007 22:03
// Version: 12 May 2010 21:43
// =========================================================================
- (void) tableViewSelectionDidChange: (NSNotification *) aNotification
{
	NSRange theEnd = NSMakeRange(0, [[commentsTextView string] length]);
	
    if ([table numberOfSelectedRows] > 0)
    {
		[deleteButton setEnabled: YES];
		
		if ([table numberOfSelectedRows] == 1)
		{
			// id theValue;
			NSDictionary *theRecord = [records objectAtIndex:[table selectedRow]];
			id theValue = [theRecord valueForKey: kNotesKey];
			
			if (theValue == nil)
			{
				// Older versions had a Comments key instead of Notes
				theValue = [theRecord valueForKey: @"Comments"];
			}

			// NSLog(@"i: %d theValue: %@", [table selectedRow], theValue);
			// NSLog(@"theObject's value: %@", [theObject identifier]);
			
			if (theValue != nil)
			{
				[commentsTextView replaceCharactersInRange: theEnd withString: theValue];
			}
			else
			{
				[commentsTextView replaceCharactersInRange: theEnd withString: @""];
			}
			theEnd.location = 0;
			[commentsTextView scrollRangeToVisible: theEnd];
		}
		else
		{
			[commentsTextView replaceCharactersInRange: theEnd withString: @""];
			theEnd.location = 0;
			[commentsTextView scrollRangeToVisible: theEnd];
		}
    }
    else
    {
        [deleteButton setEnabled: NO];
		[commentsTextView replaceCharactersInRange: theEnd withString: @""];
    }
}


// =========================================================================
// (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op
// -------------------------------------------------------------------------
// http://developer.apple.com/documentation/Cocoa/Conceptual/DragandDrop/UsingDragAndDrop.html#//apple_ref/doc/uid/20000726-BABFIDAB
// -------------------------------------------------------------------------
// Created: 8 July 2009 7:24
// Version: 8 July 2009 7:24
// =========================================================================
- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op
{
    // Add code here to validate the drop
    return NSDragOperationEvery;
	
/*
 NSDragOperation	result = NSDragOperationNone;
 
 // Add code here to validate the drop, return NSDragOperationNone is not allowed
 
 if (tv == mProfileList) {
 
 NSPasteboard* pboard = [info draggingPasteboard];
 if (pboard != NULL) {
 NSData* rowData = [pboard dataForType: kProfileTableEntryDataType];
 if (rowData != NULL) {
 result = NSDragOperationEvery;
 }
 }
 
 }
 
 return result; 
 */
}


// =========================================================================
// - (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
// -------------------------------------------------------------------------
// 
// -------------------------------------------------------------------------
// Created: 8 July 2009 7:32
// Version: 8 July 2009 7:32
// =========================================================================
- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
	
	 // Copy the row numbers to the pasteboard.
	 NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
	 [pboard declareTypes:[NSArray arrayWithObject:kELTableDataType] owner:self];
	 [pboard setData:data forType: kELTableDataType];
	 return YES; 
	 
	
/*	
	BOOL	result = NO;
	NSData*	data = NULL;
	
	if (tv == mProfileList) {
		
		data = [NSKeyedArchiver archivedDataWithRootObject: rowIndexes];
		if (data != NULL) {
			
			[pboard declareTypes: [NSArray arrayWithObject: kProfileTableEntryDataType] owner: self];
			[pboard setData: data forType: kProfileTableEntryDataType];
			
			result = YES;
		}
	}
	
	return result;
 */
	
}


// =========================================================================
// (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation
// -------------------------------------------------------------------------
// 
// -------------------------------------------------------------------------
// Created: 8 July 2009 7:34
// Version: 8 July 2009 7:34
// =========================================================================
- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation
{
    NSPasteboard* pboard = [info draggingPasteboard];
    NSData* rowData = [pboard dataForType: kELTableDataType];
    NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
//    int dragRow = [rowIndexes firstIndex];
	
	int		insertionRow;
	int		newIndex;
	int		firstDragRowIndex;
	NSArray	*draggedItems;
	draggedItems = [records objectsAtIndexes: rowIndexes];
	
	if (draggedItems != NULL) 
	{
		
		[records removeObjectsAtIndexes: rowIndexes];
		
		//	the row number for insertion is before we removed the dragged items, if the insertion is below the removal
		//	we need to adjust the insertion row. We also need to honor the drag operation
		
		//	ddwr - this code will not work for non-contiguous selection of table rows
		
		insertionRow = row;
		firstDragRowIndex = [rowIndexes firstIndex];
		if (insertionRow >  firstDragRowIndex) {
			insertionRow -= [draggedItems count];
		}
		
		if (operation == NSTableViewDropOn) {
			insertionRow++;
		}
		
		NSMutableIndexSet *insertionIndexSet = [[[NSMutableIndexSet alloc] init] autorelease];
		
		//	insert them back in the reverse order so they keep the order that they were selected
		for (newIndex = [draggedItems count] - 1; newIndex >= 0; newIndex--) {
			
			if (insertionRow >= (int) [records count]) {
				[records addObject: [draggedItems objectAtIndex: newIndex]];
			} else {
				[records insertObject: [draggedItems objectAtIndex: newIndex] atIndex: insertionRow];
			}
			
			[insertionIndexSet addIndex: insertionRow];
		}
		
		[table deselectAll:self];
//		[table selectRowIndexes:insertionIndexSet byExtendingSelection:YES];	// select row(s) at new location
		[self updateChangeCount:NSChangeDone];
		[table reloadData];
	
	}
    // Move the specified row to its new location...
	
	return YES;

}


// =========================================================================
// (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
// -------------------------------------------------------------------------
// This needs to be added to be able to sort a table
// http://cocoatravels.blogspot.com/2005_11_01_archive.html
// -------------------------------------------------------------------------
// Created: 9 September 2007 16:42
// Version: 9 September 2007 16:42
// =========================================================================
- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors 
{
	 NSArray *newDescriptors = [aTableView sortDescriptors];
	 [records sortUsingDescriptors:newDescriptors];
	 [self updateChangeCount:NSChangeDone];
	 [aTableView reloadData];
}

// =========================================================================
// (void) textDidChange: (NSNotification *) aNotification
// -------------------------------------------------------------------------
// 
// -------------------------------------------------------------------------
// Created: May 2007
// Version: 12 May 2010 21:42
// =========================================================================
- (void)textDidChange:(NSNotification *)aNotification
{
	int numberOfRows = [table numberOfSelectedRows];
	
	if (numberOfRows == 1)
	{
		int rowIndex = [table selectedRow];
		
//		NSParameterAssert(rowIndex >= 0 && rowIndex < [records count]);
		
		NSMutableDictionary *theRecord = [records objectAtIndex:rowIndex];
		NSString *obj = [[NSString alloc] initWithString: [commentsTextView string]];
		// [theRecord setObject:obj forKey:@"Comments"];
		[theRecord setObject:obj forKey: kNotesKey];
		
		[records replaceObjectAtIndex:rowIndex withObject:theRecord];

	}
}


#pragma mark -
#pragma mark Printing
// =========================================================================
// (NSPrintOperation *)printOperationWithSettings:(NSDictionary *) printSettings error:(NSError **)outError
// -------------------------------------------------------------------------
// 
// -------------------------------------------------------------------------
// Created: 8 July 2009 23:00
// Version: 12 July 2009 22:20
// =========================================================================
- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *) printSettings error:(NSError **)outError
{
    NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];
	
    // Get the window from the first window controller (presumably	the document has only one window)
//    NSWindow *window = [[[self windowControllers] objectAtIndex: 0] window];
    NSTableView *printableView = table; // [window contentView];
	[printableView setUsesAlternatingRowBackgroundColors: NO];
	
    // Construct the print operation and setup Print panel
    NSPrintOperation *printJob = [ NSPrintOperation
								  printOperationWithView: printableView 
								  printInfo: printInfo];
	
    return printJob;
}

//- (void) printShowingPrintPanel: (BOOL) flag
//{
//	NSPrintInfo *printInfo = [self printInfo];
//	NSPrintOperation *printOp;
//	printOp = [NSPrintOperation printOperationWithView: [table contentView] printInfo: printInfo];
//	[printOp setShowPanels: flag];
//	[printOp runOperation];
//}

@end
