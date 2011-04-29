//
//  RabbitHoleReaderAppDelegate.m
//  RabbitHoleReader
//
//  Created by andrew batutin on 4/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RabbitHoleReaderAppDelegate.h"


@implementation RabbitHoleReaderAppDelegate

@synthesize pdfBook;

@synthesize window=_window;

@synthesize tabBarController=_tabBarController;

- (void)dealloc
{
	[pdfBook release];
	[_window release];
	[_tabBarController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Override point for customization after application launch.
	// Add the tab bar controller's current view as a subview of the window
	self.window.rootViewController = self.tabBarController;
	[self.window makeKeyAndVisible];
	
	if ([self respondsToSelector:@selector(backgroundLoadPdfDocument)]) 
		[self performSelectorInBackground:@selector(backgroundLoadPdfDocument) withObject:nil];
	
	//create a view with pdf page 

    return YES;
}

-(void)backgroundLoadPdfDocument
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	pdfBook = [PdfFileCoreWrapper sharedInstance]; // create pdf document object
	[self performSelectorOnMainThread:@selector(pdfLoadComplete) withObject:nil waitUntilDone:YES];
	[pool release];
}

-(void)pdfLoadComplete
{
	DEBUG_LOG(@"pdf loaded");
}

@end
