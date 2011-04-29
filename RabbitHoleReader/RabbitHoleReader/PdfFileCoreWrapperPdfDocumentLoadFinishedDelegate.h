//
//  PdfFileCoreWrapperPdfDocumentLoadFinishedDelegate.h
//  RabbitHoleReader
//
//  Created by andrew batutin on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PdfFileCoreWrapperPdfDocumentLoadFinishedDelegate <NSObject>

-(void)bookPdfScrollViewPdfDocumentLoadFinished:(NSArray*)arrayPdfDocument;

@end
