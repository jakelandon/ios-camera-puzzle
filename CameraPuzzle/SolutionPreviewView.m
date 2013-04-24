//
//  SolutionPreviewView.m
//  CameraPuzzle
//
//  Created by jschwartz on 4/15/11.
//  Copyright 2011 BSSP. All rights reserved.
//

#import "SolutionPreviewView.h"


@implementation SolutionPreviewView

@synthesize image;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSLog(@"solution preview");
        
        // Initialization code
    }
    return self;
}

- (void) initSolutionPreview {
    
    self.userInteractionEnabled = YES;
    
    CGRect previewFrame = self.frame;
    previewFrame.origin.x = 10;
    previewFrame.origin.y = 10;//[self superview].frame.size.height - self.frame.size.height - 10;
    self.frame = previewFrame;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void) setImage:(UIImage *)image {
    imageView.image = image;
}

#pragma mark -
#pragma mark Touch Methods

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:self];
	
	// set startDrag points
	_startDragX = touchPoint.x;
	_startDragY = touchPoint.y;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	// get touch in superview
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:[self superview]];
	
	// set current drag
	_currentDragX = self.frame.origin.x + self.frame.size.width/2 - touchPoint.x;
	_currentDragY = self.frame.origin.y + self.frame.size.height/2 - touchPoint.y;
	
	// set new frame
    CGRect newFrame = CGRectMake(touchPoint.x - _startDragX, 
                                 touchPoint.y - _startDragY, 
                                 self.frame.size.width, 
                                 self.frame.size.height);
    
    if(newFrame.origin.x < 0) 
        newFrame.origin.x = 0;
    if(newFrame.origin.x > [self superview].frame.size.width - self.frame.size.width) 
        newFrame.origin.x = [self superview].frame.size.width - self.frame.size.width;
    if(newFrame.origin.y < 0) 
        newFrame.origin.y = 0;
    if(newFrame.origin.y > [self superview].frame.size.height - self.frame.size.height) 
        newFrame.origin.y = [self superview].frame.size.height - self.frame.size.height;
    
    self.frame = newFrame;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	_currentDragX = 0;
	_currentDragY = 0;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
	_currentDragX = 0;
	_currentDragY = 0;
}


- (void) show {
    
    self.hidden = NO;
    
    [UIView beginAnimations:@"show" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(showComplete)];
    [UIView setAnimationDelegate:self];
    self.alpha = 1;
    [UIView commitAnimations];
}

- (void) showComplete {
    
}

- (void) hide {
    [UIView beginAnimations:@"hide" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(hideComplete)];
    [UIView setAnimationDelegate:self];
    self.alpha = 0;
    [UIView commitAnimations];
}

- (void) hideComplete {
    self.hidden = YES;
    
}

- (void)dealloc
{
    [super dealloc];
}

@end
