#import "ImageAndTextCell.h"
#import "MyTextView.h"
#import <AppKit/NSCell.h>

@interface ImageAndTextCell()
	@property (readwrite, assign) NSImage *myImage;
	@property (nonatomic, retain) MyTextView *fieldEditor;
@end

@implementation ImageAndTextCell

- (id)initFromCell:(NSCell *)cell {
	// Use NSArchiver to copy the NSCell's properties into our subclass
	NSMutableData *data = [NSMutableData data];
	NSKeyedArchiver *arch = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[cell encodeWithCoder:arch];
	[arch finishEncoding];
	NSKeyedUnarchiver *ua = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	self = [self initWithCoder:ua];

	self.myImage = [NSImage imageNamed:@"NSAscendingSortIndicator"];

    return self;
}

- (id)copyWithZone:(NSZone *)zone {
	ImageAndTextCell *cell = (ImageAndTextCell *)[super copyWithZone:zone];
    // The image ivar will be directly copied; we need to retain or copy it.
    cell.myImage = self.myImage;
	cell.fieldEditor = self.fieldEditor;
    return cell;
}

- (NSTextView *)fieldEditorForView:(NSView *)aControlView
{
    if (!self.fieldEditor) {
        self.fieldEditor = [[MyTextView alloc] init];
        self.fieldEditor.fieldEditor = YES;
    }
    return self.fieldEditor;    
}

-(NSText *)setUpFieldEditorAttributes:(NSTextView *)textObj
{
	NSTableView *table = (NSTableView*) self.controlView;
	NSLog(@"setUpFieldEditorAttributes: at row %d col %d", (int)table.editedRow, (int)table.editedColumn);
	return [super setUpFieldEditorAttributes:textObj];
}

- (NSRect)imageRectForBounds:(NSRect)cellFrame {
    NSRect result;
    if (self.myImage) {
        result.size = [self.myImage size];
        result.origin = cellFrame.origin;
        result.origin.x += 3;
        result.origin.y += ceil((cellFrame.size.height - result.size.height) / 2);
    } else {
        result = NSZeroRect;
    }
    return result;
}

// We could manually implement expansionFrameWithFrame:inView: and drawWithExpansionFrame:inView: or just properly implement titleRectForBounds to get expansion tooltips to automatically work for us
- (NSRect)titleRectForBounds:(NSRect)cellFrame {
    NSRect result;
    if (self.myImage) {
        CGFloat imageWidth = [self.myImage size].width;
        result = cellFrame;
        result.origin.x += (3 + imageWidth);
        result.size.width -= (3 + imageWidth);
    } else {
        result = [super titleRectForBounds:cellFrame];
    }
    return result;
}

-(void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent
// never gets called
{
	NSLog(@"editWithFrame:");
    NSRect textFrame, imageFrame;
    NSDivideRect (aRect, &imageFrame, &textFrame, 3 + [self.myImage size].width, NSMinXEdge);
    [super editWithFrame: textFrame inView: controlView editor:textObj delegate:anObject event: theEvent];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength {
	NSLog(@"selectWithFrame:");
    NSRect textFrame, imageFrame;
    NSDivideRect (aRect, &imageFrame, &textFrame, 3 + [self.myImage size].width, NSMinXEdge);
    [super selectWithFrame: textFrame inView: controlView editor:textObj delegate:anObject start:selStart length:selLength];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    if (self.myImage) {
        NSRect imageFrame;
        NSSize imageSize = [self.myImage size];
        NSDivideRect(cellFrame, &imageFrame, &cellFrame, 3 + imageSize.width, NSMinXEdge);
        if ([self drawsBackground]) {
            [[self backgroundColor] set];
            NSRectFill(imageFrame);
        }
        imageFrame.origin.x += 3;
        imageFrame.size = imageSize;

        #if 0
			if ([controlView isFlipped]) {
				imageFrame.origin.y += ceil((cellFrame.size.height + imageFrame.size.height) / 2);
			} else {
				imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);
			}
			[self.myImage compositeToPoint:imageFrame.origin operation:NSCompositeSourceOver];
		#else
			imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);
			[self.myImage drawInRect:imageFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 respectFlipped:controlView.isFlipped hints:nil];
		#endif
    }
    [super drawWithFrame:cellFrame inView:controlView];
}

- (NSSize)cellSize {
    NSSize cellSize = [super cellSize];
    if (self.myImage) {
        cellSize.width += [self.myImage size].width;
    }
    cellSize.width += 3;
    return cellSize;
}

- (NSCellHitResult)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView {
    NSPoint point = [controlView convertPoint:[event locationInWindow] fromView:nil];
    // If we have an image, we need to see if the user clicked on the image portion.
    if (self.myImage) {
        // This code closely mimics drawWithFrame:inView:
        NSSize imageSize = [self.myImage size];
        NSRect imageFrame;
        NSDivideRect(cellFrame, &imageFrame, &cellFrame, 3 + imageSize.width, NSMinXEdge);
        
        imageFrame.origin.x += 3;
        imageFrame.size = imageSize;
        // If the point is in the image rect, then it is a content hit
        if (NSMouseInRect(point, imageFrame, [controlView isFlipped])) {
            // We consider this just a content area. It is not trackable, nor it it editable text. If it was, we would or in the additional items.
            // By returning the correct parts, we allow NSTableView to correctly begin an edit when the text portion is clicked on.
            return NSCellHitContentArea;
        }        
    }
    // At this point, the cellFrame has been modified to exclude the portion for the image. Let the superclass handle the hit testing at this point.
    return [super hitTestForEvent:event inRect:cellFrame ofView:controlView];    
}

@end
