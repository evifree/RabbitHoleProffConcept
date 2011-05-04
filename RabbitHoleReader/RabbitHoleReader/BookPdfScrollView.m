//
//  BookPdfScrollView.m
//  ZoomingPDFViewer
//
//  Created by andrew batutin on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BookPdfScrollView.h"
#import "BookViewController.h"

static float const kIBookPdfScrollViewgridSpace = 50.0f; // space between pdf views

@implementation BookPdfScrollView
@synthesize numberOfPages;
@synthesize arrayOfPdfPages;
@synthesize currentPage;
@synthesize arrayOfFill;

// memory release
-(void)dealloc
{
	[arrayOfFill release];
	[arrayOfPdfPages release];
	[super dealloc];
}

#pragma mark - init methods override

-(id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder])) 
	{
		arrayOfPdfPages = [[NSArray alloc] init];
		arrayOfFill = [[NSMutableArray alloc] init];
		self.numberOfPages = BufferLengthMedium;
		self.delegate = self;
		self.currentPage = 1;
		//[self addPagesFrom:currentPage];
	}
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])) 
	{
		arrayOfPdfPages = [[NSArray alloc] init];
		arrayOfFill = [[NSMutableArray alloc] init];
		self.numberOfPages = BufferLengthSmall;
		self.frame = frame;
		self.currentPage = 1;
		//[self addPagesFrom:currentPage];
	}
    return self;
}

// init with start page number and buffer length. Is used when the BookPdfScrollView is made programatically, but not with the IB
-(id)initWithFrame:(CGRect)frame startFromPage:(NSInteger)pageNumber withBufferLength:(BufferLength)bufferLength
{
    if ((self = [super initWithFrame:frame])) 
	{
		arrayOfPdfPages = [[NSArray alloc] init];
		arrayOfFill = [[NSMutableArray alloc] init];
		self.numberOfPages = bufferLength;
		self.currentPage = pageNumber;
		self.frame = frame;
		[self addPagesFrom:currentPage];
	}
    return self;
}

#pragma mark UIScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self predictiPageScrollDirection: scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	// calculate current page by contentOffset
	CGFloat pageWidth = scrollView.frame.size.width;
    int currentPageCalc = floor((scrollView.contentOffset.x - pageWidth / 2.0f) / pageWidth) + 1;
	
	currentVisiblePage = currentPageCalc + 1; // update currentVisiblePage

	originalTouch = scrollView.contentOffset.x; // remeber contentOffset at start of gesture
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	[self setContentOffset:CGPointMake(self.frame.size.width * (float)(currentVisiblePage), 0) animated:YES];
}

#pragma mark - BookPdfScrollViewpageWasLoadedDelegate
// the PDFScrollView is created and ready to be shown
-(void)pageWasLoaded:(PDFScrollView*)pdfPage
{
	//arrayOfPdfPages - mutable
	// update arrayOfPdfPages with the new page
	NSMutableArray* bufferArray = [[NSMutableArray alloc] initWithArray:arrayOfPdfPages];
	
	[arrayOfPdfPages release];
	
	[bufferArray addObject:pdfPage];
	arrayOfPdfPages = [[NSArray alloc] initWithArray:bufferArray];
	
	[bufferArray release];
	
	[self showThepdfView:pdfPage]; // and page to view
	
	[self checkAndRemovePages]; // check if some old pages have to be removed
}

#pragma mark - Private Methods

// predict where the page is going to move - left or right
-(void) predictiPageScrollDirection: (UIScrollView *) scrollView  
{
	float scrollDirection = originalTouch  - scrollView.contentOffset.x; // get the distance between old and new contentOffset
	
	// if the scrollDirection > 0 - user scroll from left to right to see the previous page
	if ( ( scrollDirection > 0 ) )
		nextPageToShow = currentVisiblePage - 1;
	// if user scrolls from right to left to see the next page
	else
		nextPageToShow = currentVisiblePage + 1;
	
	if ( nextPageToShow < self.numberOfPages ) 
		nextPageToShow = self.numberOfPages;
	if ( nextPageToShow >= ( [arrayOfFill count] - self.numberOfPages )) 		
		nextPageToShow = [arrayOfFill count] - self.numberOfPages;
	
	// check if user have just stated dragging 
	if ( nextPageToShowPrev != nextPageToShow )
	{
		[arrayOfFill release];
		arrayOfFill = [[NSMutableArray alloc] init];
		
		for ( int i = 0; i <= APP.pdfBook.maxPage; i++ )
		{
			[arrayOfFill addObject:[NSNumber numberWithInt:PageStateNoDraw]];
		}
		
		// we have to show very start of the document
		if ( nextPageToShow == self.numberOfPages )
		{
			for ( int i = nextPageToShow - ( self.numberOfPages - 1 ); i < (nextPageToShow + self.numberOfPages + 1 ); i++ )
			{
				[arrayOfFill replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:PageStateCanDraw]];
			}
		}
		// we have to show very end of the document
		if ( nextPageToShow == ( [arrayOfFill count] - self.numberOfPages ) ) 
		{
			for ( int i = nextPageToShow - ( self.numberOfPages ); i < (nextPageToShow + self.numberOfPages + 0); i++ )
			{
				[arrayOfFill replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:PageStateCanDraw]];
			}
		}
		
		// if we somewhere at the middle
		if ( ( nextPageToShow > self.numberOfPages ) && ( nextPageToShow < ( [arrayOfFill count] - self.numberOfPages ) ) )
		{
			for ( int i = nextPageToShow - ( self.numberOfPages ); i < (nextPageToShow + self.numberOfPages + 1); i++ )
			{
				[arrayOfFill replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:PageStateCanDraw]];
			}
		}
		
		[self loadPagesToDraw];
	}
	nextPageToShowPrev = nextPageToShow;
}

// check if we need to load the new page and load it
-(void)loadPagesToDraw
{
	// iterate throught the arrayOfFill
	for ( int i = 0; i < [arrayOfFill count] ; i++ )
	{
		
		BOOL goodToGo = YES; // flag indicating do we need to load new page or not
		
		NSNumber* pageState = [arrayOfFill objectAtIndex:i];
		// if the object in arrayOfFill says that the page could be drawn
		if ( [pageState intValue] == PageStateCanDraw )
		{
			// iterete all the subviews
			for ( PDFScrollView* view in self.subviews )
			{
				// if the view is the PDFScrollView
				if ( [view isMemberOfClass:[PDFScrollView class]] )
				{
					// if the PDFScrollView page number is equal to the arrayOfFill object index
					if ( view.pageNumer == i )
					{
						// the page should not be loaded, because it has alredy benn loaded and add like a subview
						goodToGo = NO;
					}
				}
			}
			
			// if the page have not been loaded yet 
			if (goodToGo)
			{
				NSNumber* num = [NSNumber numberWithInt:i];
				// the page is loaded in background by page number
				if ([self respondsToSelector:@selector(backgroundLoadPage:)]) // not neccary
					[self performSelectorInBackground:@selector(backgroundLoadPage:) withObject:num];
			}
		}
	}
}

// check if the page should be removed from view and arrayOfPdfPages
-(void)checkAndRemovePages
{
	NSMutableArray* arrayDelete = [[NSMutableArray alloc] init]; // array to store pages that should be deleted
	
	// go throught the arrayOfPdfPages and get all the pages that should be deleted
	for (PDFScrollView* view in arrayOfPdfPages)
	{
		NSNumber* pageState = [arrayOfFill objectAtIndex:view.pageNumer];
		// if the arrayOfFill says that the page have no right to be on that index, which is equal to the PDFScrollView page number
		if ( [pageState intValue] == PageStateNoDraw )
		{
			[view removeFromSuperview]; // page is not visible now
			[arrayDelete addObject:view]; // add page to be deleted
		}
	}
			
	NSMutableArray* bufferArray = [[NSMutableArray alloc] initWithArray:arrayOfPdfPages]; // copy of the arrayOfPdfPages to work with
	
	[arrayOfPdfPages release];
	
	[bufferArray removeObjectsInArray:arrayDelete]; // remove all the pages that should be removed
	
	arrayOfPdfPages = [[NSArray alloc] initWithArray:bufferArray]; // recreate arrayOfPdfPages with pages that can be drawn
	
	// keeping the heap clean
	[bufferArray release];
	[arrayDelete release];
	
	// cause of background loading we can have couple of objects with the same page numbers loaded in the arrayOfPdfPages, so we need to delete them
	[self removeIdenticalPages];

}

// if the objects have the same page number - we remove one of them
-(void)removeIdenticalPages 
{
	// implemetn isEqual method
	NSMutableArray* arrayDeleteDuplicate = [[NSMutableArray alloc] init]; // array to store pages that should be deleted
	
	if ( [arrayOfPdfPages count] > 1 ) // to compare objects we need at least 2 objects
	{
	// TODO - i fill that this identical objects search could be done in more NS API way 
	// itereate arrayOfPdfPages from first to the penultimate object
		for ( int i = 0; i < [arrayOfPdfPages count]-1; i++ )
		{
			PDFScrollView* pdfPagePrev = [arrayOfPdfPages objectAtIndex:i]; // object to be compared
			// iterete arrayOfPdfPages from 'i' to the penultimate object to be sure that pdfPagePrev was compared with the all other objects
			for ( int j = i; j < [arrayOfPdfPages count]-1; j++ )
			{
				PDFScrollView* pdfPage = [arrayOfPdfPages objectAtIndex:j+1]; // object to compare with
				// if the pages of the objects are the same - then pdfPagePrev object is doomed to be deleted
				if ( pdfPage.pageNumer == pdfPagePrev.pageNumer )
				{
					[arrayDeleteDuplicate addObject:pdfPagePrev]; // add page to be deleted
				}
			}
		}
	}
	
	NSMutableArray* bufferArray = [[NSMutableArray alloc] initWithArray:arrayOfPdfPages]; // copy of the arrayOfPdfPages to work with
	
	[arrayOfPdfPages release];
	
	[bufferArray removeObjectsInArray:arrayDeleteDuplicate]; // remove all the pages that should be removed
	
	arrayOfPdfPages = [[NSArray alloc] initWithArray:bufferArray]; // recreate arrayOfPdfPages with pages that can be drawn
	
	// keeping the heap clean
	[bufferArray release];
	[arrayDeleteDuplicate release];
}

// sdd PDFScrollView to the view and place it in right position
-(void)showThepdfView:(PDFScrollView*)pdfPage
{
	[self addSubview:pdfPage]; 
	
	CGFloat baseX = self.frame.size.width * (pdfPage.pageNumer - 1); // get the base x point to move PDFScrollView
		
	CGRect viewFrame = CGRectMake( baseX, self.frame.origin.y, self.frame.size.width, self.frame.size.height ); // create a frame to be set in PDFScrollView
	[pdfPage setFrame:viewFrame]; // set the position of the frame
	
}

// create PDFScrollView with page on it and tell about it main thread 
-(void)fillTheBookCashWithPageNumber:(NSInteger)pageNumber
{
	 PDFScrollView *viewWithPdf = [[PDFScrollView alloc] initWithFrame:[self frame] andWithPageNumber:pageNumber andPdfFileReference:APP.pdfBook.pdfRef];
	 
	 if ([self respondsToSelector:@selector(pageWasLoaded:)]) 
		 [self performSelectorOnMainThread:@selector(pageWasLoaded:) withObject:viewWithPdf waitUntilDone:YES]; // send the PDFScrollView to main thread to be drawn
	 
	 [viewWithPdf release]; // looks like when you are sending object to the MainThread the object's copy is made, so you have to do release 
}

// wrapper for background selector call
-(void)backgroundLoadPage:(NSNumber*)pageNumber
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self fillTheBookCashWithPageNumber:[pageNumber integerValue]]; // create pd page by pageNumber
	[pool release];
}

// remove all pages
-(void)clearAllPages
{
	[arrayOfFill release];
	arrayOfFill = [[NSMutableArray alloc] init];
	
	for ( int i = 0; i <= APP.pdfBook.maxPage; i++ )
	{
		[arrayOfFill addObject:[NSNumber numberWithInt:PageStateNoDraw]];
	}
	
	[self checkAndRemovePages]; // check if some old pages have to be removed
}

// remove all pages exept currentVisiblePage
-(void)clearAllPagesButCurrent
{
	CGFloat pageWidth = self.frame.size.width;
    int currentPageCalc = floor((self.contentOffset.x - pageWidth / 2.0f) / pageWidth) + 1;
	currentVisiblePage = currentPageCalc + 1; // update currentVisiblePage

	[arrayOfFill release];
	arrayOfFill = [[NSMutableArray alloc] init];
	
	for ( int i = 0; i <= APP.pdfBook.maxPage; i++ )
	{
		[arrayOfFill addObject:[NSNumber numberWithInt:PageStateNoDraw]];
	}
	
	[arrayOfFill replaceObjectAtIndex:currentVisiblePage withObject:[NSNumber numberWithInt:PageStateCanDraw]];
	
	[self checkAndRemovePages]; // check if some old pages have to be removed
}

#pragma mark - Public methods

-(void)addPagesFrom:(NSInteger)page
{
	currentVisiblePage = page;
	
	for ( int i = 0; i <= APP.pdfBook.maxPage; i++ )
	 {
		 [arrayOfFill addObject:[NSNumber numberWithInt:PageStateNoDraw]];
	 }
	
	 self.currentPage = page;
	 for ( int i = 0; i < self.numberOfPages; i++ )
	 {
		[arrayOfFill replaceObjectAtIndex:self.currentPage++ withObject:[NSNumber numberWithInt:PageStateCanDraw]];
	 }
	
	[self predictiPageScrollDirection:self];
	
	[self setContentOffset:CGPointMake(self.frame.size.width * (float)(page), 0) animated:YES];
}

@end
