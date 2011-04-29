//
//  BookPdfScrollView.h
//  ZoomingPDFViewer
//
//  Created by andrew batutin on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

// this class contains the number of PDFScrollView
#import <Foundation/Foundation.h>
#import "PDFScrollView.h"
#import "PdfFileCoreWrapperPdfDocumentLoadFinishedDelegate.h"

// Enum for page state
typedef enum
{
	PageStateCanDraw = 0, // The page could be drawn
	PageStateNoDraw = 1, // The page can't be drawn
	
}PageState;

// Enum for buffer size
typedef enum
{
	BufferLengthBig = 3, // 7 pages are loading at once
	BufferLengthMedium = 2, // 5 pages are loading at once
	BufferLengthSmall = 1, // 3 pages are loading at once
	
}BufferLength;

@protocol BookPdfScrollViewPagesLoadedDelegate <NSObject>

-(void)pageWasLoaded:(PDFScrollView*)pdfPage;

@end

@interface BookPdfScrollView : UIScrollView <UIScrollViewDelegate, BookPdfScrollViewPagesLoadedDelegate>
{
	NSArray* arrayOfPdfPages; // this array contains the PDFScrollView reference
	BufferLength numberOfPages; // number of pages to be shown on the view
	NSInteger currentPage; // current page to show
	NSInteger currentVisiblePage;
	CGFloat originalTouch;
	NSMutableArray* arrayOfFill; // determinate if the cell have page to draw or not
	NSInteger nextPageToShow;
	NSInteger nextPageToShowPrev;
}

@property (nonatomic, readwrite) NSInteger currentPage;
@property (nonatomic, readwrite) BufferLength numberOfPages;
@property (nonatomic, retain) NSArray* arrayOfPdfPages;
@property (nonatomic, retain) NSMutableArray* arrayOfFill;

-(id)initWithFrame:(CGRect)frame startFromPage:(NSInteger)pageNumber withBufferLength:(BufferLength)bufferLength;
-(void)loadPagesToDraw;
-(void)checkAndRemovePages;
-(void)removeIdenticalPages;
-(void)showThepdfView:(PDFScrollView*)pdfPage;
-(void)fillTheBookCashWithPageNumber:(NSInteger)pageNumber;
-(void)addPagesFrom:(NSInteger)page;
-(void)backgroundLoadPage:(NSNumber*)pageNumber;
-(void) predictiPageScrollDirection: (UIScrollView *) scrollView;
-(void)clearAllPagesButCurrent;
-(void)clearAllPages;

@end
