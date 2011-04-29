//
//  PdfFileCoreWrapper.h
//  ZoomingPDFViewer
//
//  Created by andrew batutin on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDFScrollView.h"
#import "BookPdfScrollView.h"

@interface PdfFileCoreWrapper : NSObject 
{
	CGPDFDocumentRef pdfRef; // pdf dociment representation
	NSInteger maxPage; // max number of pages in book;
}

@property (nonatomic, readwrite) NSInteger maxPage; // max number of pages in book;
@property (nonatomic, assign) CGPDFDocumentRef pdfRef;

+(PdfFileCoreWrapper*)sharedInstance;

@end
