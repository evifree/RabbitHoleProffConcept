//
//  BookViewController.m
//  RabbitHoleReader
//
//  Created by andrew batutin on 4/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BookViewController.h"


@implementation BookViewController
@synthesize pdfBookScrollView;
@synthesize pageNumber;

- (void)dealloc
{
	[pdfBookScrollView release];
	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	[pdfBookScrollView clearAllPagesButCurrent];
}

#pragma mark View life cicle

-(void)viewDidLoad
{
	// delegate and content size setters
	pdfBookScrollView.delegate = pdfBookScrollView;
	[pdfBookScrollView setContentSize:CGSizeMake(pdfBookScrollView.frame.size.width * APP.pdfBook.maxPage, pdfBookScrollView.frame.origin.y)];
	
	[super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
	[pdfBookScrollView addPagesFrom:pageNumber];
	[super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)addPagesFrom:(NSInteger)page
{
	[pdfBookScrollView addPagesFrom:page];
}

@end
