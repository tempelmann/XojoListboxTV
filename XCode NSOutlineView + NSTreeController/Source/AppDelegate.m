//
//  AppDelegate.m
//  TableView_Custom_ColumnWidths
//
//  Created by Thomas Tempelmann on 09.02.17.
//  Copyright © 2017 Thomas Tempelmann. All rights reserved.
//

#import "AppDelegate.h"
#import "CustomOutlineView.h"
#import "ImageAndTextCell.h"

static int callCount = 0;

@interface DataNode : NSObject {}
	@property (retain) NSMutableArray *children;
	@property (retain) NSString *firstCol;
	@property (retain) NSString *secondCol;
@end

@implementation DataNode

- (instancetype)init {
	self.children = [NSMutableArray array];
	return self;
}

- (BOOL) isLeaf
{
	return self.children.count == 0;
}

@end

@interface AppDelegate () <NSTableViewDataSource, NSTableViewDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSOutlineView *table;
@property (assign) IBOutlet NSTableColumn *firstCol;
@property (assign) IBOutlet NSTableColumn *secondCol;
@property (assign) IBOutlet NSButton *callsButton;
@property (assign) IBOutlet NSTextField *infoLabel;

@property (nonatomic, retain) DataNode *dataRoot;
@property (nonatomic, retain) NSTreeController *treeController;
@property (nonatomic, retain) NSMutableArray *contents;
@property (nonatomic, retain) ImageAndTextCell *cell;

@end

@implementation AppDelegate

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender
{
	return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self.table registerForDraggedTypes: @[NSStringPboardType, @"private.dragrow", @"public.file-url"]];
	[self.table setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];

	// intercept keydown events, see
	// http://stackoverflow.com/questions/17663866/best-way-to-intercept-keydown-actions-in-an-nstextfieldcell
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionToTakeOnKeyPress:)
		name:NSControlTextDidChangeNotification object:self.table]; 

	// Test for putting NSColor into prefs:
	NSColor *aColor = [NSColor colorWithCalibratedRed:1 green:0.5 blue:0.2 alpha:0.8];
	NSData *theData=[NSArchiver archivedDataWithRootObject:aColor];
	[[NSUserDefaults standardUserDefaults] setObject:theData forKey:@"Test Color"];

	self.contents = [NSMutableArray array];

	self.treeController = [[NSTreeController alloc] init];

	[self.treeController setLeafKeyPath:@"isLeaf"];
	[self.treeController setChildrenKeyPath:@"children"];
	[self.treeController setPreservesSelection:YES];
	[self.treeController setSelectsInsertedObjects:YES];

	[self.treeController bind:@"contentArray" toObject:self withKeyPath:@"contents" options:@{NSRaisesForNotApplicableKeysBindingOption:@YES, NSConditionallySetsEditableBindingOption:@YES}];

	[self.table bind:@"content" toObject:self.treeController withKeyPath:@"arrangedObjects" options:@{NSAlwaysPresentsApplicationModalAlertsBindingOption:@YES}];
	[self.table bind:@"selectionIndexPaths" toObject:self.treeController withKeyPath:@"selectionIndexPaths" options:@{}];
	[self.table bind:@"sortDescriptors" toObject:self.treeController withKeyPath:@"sortDescriptors" options:@{}];


	DataNode *node = [[DataNode alloc] init];
	self.dataRoot = node; // @[ @[@"a", @"b", @"c"], @[@"d", @"e", @"f"] ];
	for (int i1 = 1; i1 <= 25; ++i1) {
		DataNode *node2 = [[DataNode alloc] init];
		node2.firstCol = [NSString stringWithFormat:@"%d", i1];
		node2.secondCol = [NSString stringWithFormat:@"2-%d", i1];
		[node.children addObject:node2];
		for (int i2 = 1; i2 <= i1; ++i2) {
			DataNode *node3 = [[DataNode alloc] init];
			node3.firstCol = [NSString stringWithFormat:@"%d", i2];
			node3.secondCol = [NSString stringWithFormat:@"3-%d", i1];
			[node2.children addObject:node3];
			for (int i3 = 1; i3 <= 3; ++i3) {
				DataNode *node4 = [[DataNode alloc] init];
				node4.firstCol = [NSString stringWithFormat:@"%d", i3];
				node4.secondCol = [NSString stringWithFormat:@"4-%d", i1];
				[node3.children addObject:node4];
			}
		}
	}
	
	for (DataNode *node in self.dataRoot.children) {
		NSIndexPath *loc = [NSIndexPath indexPathWithIndex:self.contents.count]; // appends to end of list
		[self.treeController insertObject:node atArrangedObjectIndexPath:loc];
	}
	
	NSTextFieldCell *cell = [[ImageAndTextCell alloc] initFromCell:self.table.tableColumns[1].dataCell];
	self.table.tableColumns[1].dataCell = cell;
	
	[self.table reloadData];
}

-(IBAction)showCallCount:(id)sender {
	self.infoLabel.stringValue = [NSString stringWithFormat:@"%d (%d rows)", callCount, (int)self.table.numberOfRows];
	callCount = 0;
}

- (void)actionToTakeOnKeyPress:(id)sender
{
	NSEvent *ev = [NSApp currentEvent];
	NSLog(@"keyDown: %@", ev.characters);
}


/*
 * OutlineView delegates
 */

-(NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	if (tableColumn == nil || [tableColumn.identifier isEqualToString:@"firstCol"]) {
		return nil;
	}
	if (self.cell == nil) {
		//self.cell = [[ImageAndTextCell alloc] init];
	}
	return self.cell;
}

-(BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	NSLog(@"shouldEditTableColumn:");
	return YES;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	NSLog(@"shouldEditTableColumn:");
	return YES;
}


-(BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor
{
	NSLog(@"control:textShouldBeginEditing:");
	return YES;
}

-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	return 0;	// never called (due to using NSTreeController)
}

-(id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
	return nil;	// never called (due to using NSTreeController)
}

-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	return NO;	// never called (due to using NSTreeController)
}

-(id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	DataNode *node = [item representedObject]; //item ? item : self.dataRoot;
	return [node valueForKey:tableColumn.identifier];
}

/*
-(BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard
{
	[pasteboard setString:@"pb content" forType:NSPasteboardTypeString];
	return YES;
}

-(BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index
{
	return YES;
}

-(NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index
{
	return -1;
}
*/

@end
