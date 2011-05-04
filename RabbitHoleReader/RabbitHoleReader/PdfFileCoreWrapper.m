//
//  PdfFileCoreWrapper.m
//  ZoomingPDFViewer
//
//  Created by andrew batutin on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PdfFileCoreWrapper.h"

// const
static NSString* const kPdfFileCoreWrapperFileName = @"alice-in-wonderland-book.pdf";
// Singleton instance
static PdfFileCoreWrapper *sharedInstance = nil;

@implementation PdfFileCoreWrapper
@synthesize pdfRef;
@synthesize maxPage;

-(void)dealloc
{
	CGPDFDocumentRelease(pdfRef);
	[super dealloc];
}

#pragma mark Public methods

+(PdfFileCoreWrapper*)sharedInstance
{
	@synchronized( self )
	{
		if( sharedInstance == nil )
			sharedInstance = [[self alloc] init];
	}
	return sharedInstance;
}

- (id)init
{
	if( (self=[super init]) )
	{
		// Open the PDF document
		NSURL *pdfURL = [[NSBundle mainBundle] URLForResource:kPdfFileCoreWrapperFileName withExtension:nil];
		pdfRef = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);	

		maxPage = CGPDFDocumentGetNumberOfPages(pdfRef);
	}
	
	return self;
}


@end
