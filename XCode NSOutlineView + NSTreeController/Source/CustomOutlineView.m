//
//  CustomColumnSizingTableView.m
//  TableView_Custom_ColumnWidths
//
//  Created by Thomas Tempelmann on 09.02.17.
//  Copyright © 2017 Thomas Tempelmann. All rights reserved.
//

#import "CustomOutlineView.h"

@implementation CustomOutlineView

/*
- (void)sizeToFit
{
	NSView *container = self.superview;
	NSLog(@"! %f, %@", container.frame.size.width, container);
	[super sizeToFit];
	NSLog(@". %f, %@", container.frame.size.width, container);
}
*/

-(void)interpretKeyEvents:(NSArray<NSEvent *> *)eventArray
{
	NSLog(@"interpretKeyEvents:");
}

-(void)insertText:(id)insertString
{
	NSLog(@"insertText: %@", insertString);
}

-(BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
	NSLog(@"performKeyEquivalent: %@", theEvent.characters);
	return [super performKeyEquivalent:theEvent];
}

-(void)keyDown:(NSEvent *)theEvent
{
	NSLog(@"keyDown: %@", theEvent.characters);
/*
	if ([theEvent.characters containsString:@"a"]) {
		[super keyDown:theEvent];
	}
*/
}

- (void)tile
{
    //NSLog(@"tile");
	[super tile];

/*
	self.columnAutoresizingStyle = NSTableViewLastColumnOnlyAutoresizingStyle;
	NSSize spacing = self.intercellSpacing;
	CGFloat avail = self.superview.frame.size.width;
	CGFloat cw0 = (int) (avail / 3);
	CGFloat cw1 = avail - cw0;
	self.tableColumns[0].width = cw0 - spacing.width;
	self.tableColumns[1].width = cw1 - spacing.width;
*/
}

- (void)draggingExited: (id < NSDraggingInfo >)sender
{
    NSLog(@"draggingExited");
	[super draggingExited:sender];
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
    NSLog(@"concludeDragOperation");
	[super concludeDragOperation:sender];
}

- (void)textDidBeginEditing:(NSNotification *)notification
{
	NSLog(@"textDidBeginEditing");
	return;
}

-(BOOL)textShouldBeginEditing:(NSText *)textObject
{
	NSLog(@"textShouldBeginEditing");
	return YES;
}

@end
