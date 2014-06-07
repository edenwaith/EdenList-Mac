//
//  MyDocument.m
//  EdenList
//
//  Created by Chad Armstrong on Thu Apr 08 2004.
//  Copyright (c) 2003 - 2014 Edenwaith. All rights reserved.
//
//  TABLE VIEW REFERENCES
//  http://www.macdevcenter.com/pub/a/mac/2001/08/10/cocoa.html?page=4
//  http://www.nongnu.org/gstutorial/en/ch13s02.html
//  http://www.nongnu.org/gstutorial/en/ch13s03.html
//  http://rixstep.com/2/20050827,00.shtml
//  http://cocoatravels.blogspot.com/2005_11_01_archive.html


#import "MyDocument.h"

@implementation MyDocument


// =========================================================================
// (id) init
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
		dataDict = [[NSMutableDictionary alloc] init];
    
    }
	
    return self;
}


// =========================================================================
// (void) dealloc
// -------------------------------------------------------------------------
// Created: 1 May 2007 20:28
// Version: 19 June 2007 20:50
// =========================================================================
- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] 
		removeObserver: self 
		name: NSTextDidEndEditingNotification 
		object: commentsTextView];
	[dataDict release];
	
	[super dealloc];
}


// =========================================================================
// (NSString *) windowNibName
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
// Version: 19 June 2007 20:50
// =========================================================================
- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{	
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.

	[table registerForDraggedTypes: [NSArray arrayWithObject: kELTableDataType] ];

	[[NSNotificationCenter defaultCenter] addObserver:self 
		selector:@selector(textDidChange:) 
		name:NSTextDidEndEditingNotification 
		object:commentsTextView];
}


#pragma mark -
#pragma mark Read + Write to file 

// =========================================================================
// (BOOL) writeToFile: (NSString *) ofType: (NSString *)
// -------------------------------------------------------------------------
// Created: 6 June 2007
// Version: 6 June 2014 22:15
// =========================================================================
- (BOOL) writeToFile: (NSString *) fileName ofType:(NSString *)aType
{
	dataDict = [[NSMutableDictionary dictionary] retain];

	[dataDict setObject: [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersionString"] forKey: kVersionKey];
	[dataDict setObject: records forKey: kRecordsKey];
	
	return [dataDict writeToFile:fileName atomically:YES];
}


// =========================================================================
// (BOOL) readFromFile: (NSString *) ofType: (NSString *)
// -------------------------------------------------------------------------
// Created: 6 June 2007
// Version: 6 June 2014 22:16
// =========================================================================
- (BOOL) readFromFile: (NSString *) fileName ofType: (NSString *) aType
{
	if ([aType isEqualToString: @"DocumentType"])
	{
		records = [[NSMutableArray alloc] init];
		
		dataDict = [[NSMutableDictionary dictionaryWithContentsOfFile:fileName] retain];
		
		if (dataDict != nil)
		{
			id versionString = [dataDict objectForKey: kVersionKey];
			id recordsData = [dataDict objectForKey: kRecordsKey];
			
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


#pragma mark -
#pragma mark Manage records

// =========================================================================
// (NSDictionary *) createRecord
// -------------------------------------------------------------------------
// Created: 21 April 2007 0:06
// Version: 12 May 2010 9:43
// =========================================================================
- (NSDictionary *) createRecord
{
	NSMutableDictionary *record = [[NSMutableDictionary alloc] init];
    
	[record setObject:[NSNumber numberWithInt: 0] forKey:kCheckBoxKey];
    [record setObject:[itemField stringValue] forKey:kToDoKey];
	[record setObject:@"" forKey: kNotesKey];
    
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
	else if ([table numberOfSelectedRows] == [records count])
	{
		[self deleteAllRecords:sender];
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
// Version: 6 June 2014 21:37
// =========================================================================
- (IBAction) deleteAllRecords: (id) sender
{
    int status = -1;
    
    NSBeep();
    status = NSRunAlertPanel(NSLocalizedString(@"AlertTitle", nil), NSLocalizedString(@"DeleteAllMsg", nil), NSLocalizedString(@"OK", nil), NSLocalizedString(@"Cancel", nil), nil);
    
    if (status == NSAlertDefaultReturn)
    {
		[records removeAllObjects];    
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
// =========================================================================
- (int)numberOfRowsInTableView:(NSTableView*)table
{
    // returns the number of records
    return [records count];
}


// =========================================================================
// (void) tableView:objectValueForTableColumn:row
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
// (void) tableView:setObjectValue:forTableColumn:row:
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
				theValue = [theRecord valueForKey: kCommentsKey];
			}
			
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
// (NSDragOperation)tableView:validateDrop:proposedRow:proposedDropOperation:
// -------------------------------------------------------------------------
// Created: 8 July 2009 7:24
// Version: 8 July 2009 7:24
// =========================================================================
- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op
{
    // Add code here to validate the drop
    return NSDragOperationEvery;
}


// =========================================================================
// - (BOOL)tableView:writeRowsWithIndexes:toPasteboard:
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
}


// =========================================================================
// (BOOL)tableView:acceptDrop:row:dropOperation:
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
		//	Note: this code will not work for non-contiguous selection of table rows
		
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
		[self updateChangeCount:NSChangeDone];
		[table reloadData];
	
	}
	
	return YES;
}


// =========================================================================
// (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
// -------------------------------------------------------------------------
// This needs to be added to be able to sort a table
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


#pragma mark -
#pragma mark - NSTextView Delegate Method

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
		
		NSMutableDictionary *theRecord = [records objectAtIndex:rowIndex];
		NSString *obj = [[NSString alloc] initWithString: [commentsTextView string]];
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
	
    NSTableView *printableView = table; // [window contentView];
	[printableView setUsesAlternatingRowBackgroundColors: NO];
	
    // Construct the print operation and setup Print panel
    NSPrintOperation *printJob = [ NSPrintOperation
								  printOperationWithView: printableView 
								  printInfo: printInfo];
	
    return printJob;
}

@end
