//
//  MyTextView.m
//  NSOutlineView Testing
//
//  Created by Thomas Tempelmann on 20.03.17.
//  Copyright © 2017 Thomas Tempelmann. All rights reserved.
//

#import "MyTextView.h"

@implementation MyTextView

-(void)keyDown:(NSEvent *)theEvent
{
	NSLog(@"MyTextView keyDown: %@", theEvent.characters);
	static bool b = false;
	b = !b;
	if (b) {
		[super keyDown:theEvent];
	}
}

/*
-(void)interpretKeyEvents:(NSArray<NSEvent *> *)eventArray
{
	NSLog(@"MyTextView interpretKeyEvents");
	[super interpretKeyEvents:eventArray];
}

-(BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
	NSLog(@"MyTextView performKeyEquivalent");
	return [super performKeyEquivalent:theEvent];
}
*/

@end
