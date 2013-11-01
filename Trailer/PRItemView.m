//
//  PRItemView.m
//  Trailer
//
//  Created by Paul Tsochantaris on 01/11/2013.
//  Copyright (c) 2013 HouseTrip. All rights reserved.
//

#import "PRItemView.h"

@interface PRItemView ()
{
	NSString *_title;
	NSInteger _commentsTotal, _commentsNew;
	NSDictionary *_titleAttributes, *_titleBoldAttributes, *_commentCountAttributes, *_commentAlertAttributes;
}
@end

@implementation PRItemView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

		NSMutableParagraphStyle *p = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		p.alignment = NSCenterTextAlignment;

		_titleAttributes = @{
							 NSFontAttributeName:[NSFont systemFontOfSize:12.0],
							 NSForegroundColorAttributeName:[NSColor blackColor]
							 };
		_titleBoldAttributes = @{
								 NSFontAttributeName:[NSFont systemFontOfSize:12.0],
								 NSForegroundColorAttributeName:[NSColor blueColor],
								 NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)
								  };
		_commentCountAttributes = @{
								 NSFontAttributeName:[NSFont boldSystemFontOfSize:9.0],
								 NSForegroundColorAttributeName:[NSColor whiteColor],
								 NSParagraphStyleAttributeName:p,
								 };
		_commentAlertAttributes = @{
								 NSFontAttributeName:[NSFont boldSystemFontOfSize:9.0],
								 NSForegroundColorAttributeName:[NSColor whiteColor],
								 NSParagraphStyleAttributeName:p,
								 };
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	CGContextRef context = (CGContextRef) [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.0);

	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	formatter.numberStyle = NSNumberFormatterDecimalStyle;

	CGFloat badgeSize = 18.0;

	//////////////////// New count

	if(_commentsNew)
	{
		[[NSColor redColor] set];

		CGRect countRect = CGRectMake((27.0-badgeSize)*0.5, (self.bounds.size.height-badgeSize)*0.5, badgeSize, badgeSize);
		CGContextFillEllipseInRect(context, countRect);

		countRect = CGRectOffset(countRect, 0, -2.0);
		NSString *countString = [formatter stringFromNumber:@(_commentsNew)];
		[countString drawInRect:countRect withAttributes:_commentAlertAttributes];
	}

	//////////////////// PR count

	if(_commentsTotal)
	{
		[[NSColor lightGrayColor] set];

		CGRect countRect = CGRectMake(23.0+(25.0-badgeSize)*0.5, (self.bounds.size.height-badgeSize)*0.5, badgeSize, badgeSize);
		CGContextFillEllipseInRect(context, countRect);

		countRect = CGRectOffset(countRect, 0, -2.0);
		NSString *countString = [formatter stringFromNumber:@(_commentsTotal)];
		[countString drawInRect:countRect withAttributes:_commentCountAttributes];
	}

	//////////////////// Title

	CGFloat L = 50;
	if([[self enclosingMenuItem] isHighlighted])
	{
		[_title drawInRect:CGRectMake(L, -4.0, self.bounds.size.width-L, self.bounds.size.height) withAttributes:_titleBoldAttributes];
	}
	else
	{
		[_title drawInRect:CGRectMake(L, -4.0, self.bounds.size.width-L, self.bounds.size.height) withAttributes:_titleAttributes];
	}
}

- (void)setPullRequest:(PullRequest *)pullRequest
{
	_commentsTotal = [PRComment countCommentsForPullRequestUrl:pullRequest.url inMoc:[AppDelegate shared].managedObjectContext];
	_commentsNew = [pullRequest unreadCommentCount];
	_title = pullRequest.title;
	CGRect titleSize = [_title boundingRectWithSize:CGSizeMake(450, FLT_MAX)
											options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
										 attributes:_titleAttributes];
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 500, titleSize.size.height+10.0);
}

-(void)mouseUp:(NSEvent *)theEvent
{
}

- (void)mouseDown:(NSEvent*) event
{
    NSMenu *menu = self.enclosingMenuItem.menu;
    [menu cancelTracking];
    [menu performActionForItemAtIndex:[menu indexOfItem:self.enclosingMenuItem]];
}

-(BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

@end
