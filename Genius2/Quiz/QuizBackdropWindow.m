//  Genius
//
//  This code is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 2.5 License.
//  http://creativecommons.org/licenses/by-nc-sa/2.5/

#import "QuizBackdropWindow.h"


@implementation QuizBackdropWindow

- (id)init
{
	NSRect screenRect = [[NSScreen mainScreen] frame];
	self = [super initWithContentRect:screenRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];	[self setLevel:(NSModalPanelWindowLevel-1)];
	[self setBackgroundColor:[NSColor blackColor]];
	[self setAlphaValue:0.5];
	[self setOpaque:NO];
	[self setHasShadow:NO];
	[self setIgnoresMouseEvents:YES];
	
	NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(_handleAppWillResignActive:) name:NSApplicationWillResignActiveNotification object:nil];
	[nc addObserver:self selector:@selector(_handleAppWillBecomeActive:) name:NSApplicationWillBecomeActiveNotification object:nil];
	
	return self;
}

- (void) dealloc
{
	NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	
	[super dealloc];
}


- (void) _handleAppWillResignActive:(NSNotification *)notification
{
	[self orderOut:nil];
}

- (void) _handleAppWillBecomeActive:(NSNotification *)notification
{
	[self orderFront:nil];
}

@end