//
//  PuzzlePiece.m
//  CameraPuzzle
//
//  Created by jschwartz on 4/5/11.
//  Copyright 2011 BSSP. All rights reserved.
//

#import "PuzzlePiece.h"


@implementation PuzzlePiece

@synthesize delegate;
@synthesize currentFrame = _currentFrame;
@synthesize originalFrame = _originalFrame;
@synthesize currentCenter = _currentCenter;
@synthesize originalCenter = _originalCenter;
@synthesize index = _index;
@synthesize xIndex = _xIndex;
@synthesize yIndex = _yIndex;
@synthesize scale = _scale;
@synthesize rotation = _rotation;
@synthesize movementType = _movementType;
@synthesize image = _image;
@synthesize currentDragX = _currentDragX;
@synthesize currentDragY = _currentDragY;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        
        self.currentFrame = frame;
		self.originalFrame = frame;
		self.image = nil;

        self.currentCenter = self.center;
        self.originalCenter = self.center;
    }
    return self;
}


- (void)dealloc
{
    delegate = nil;
	
	[_image release];
	_image = nil;
	
    
    [super dealloc];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext(); 
    CGContextClearRect(context, rect);
    
    
       
    // if image is not nil, draw image
	CGContextTranslateCTM(context, 0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
    
	if(self.image) {
		CGRect imageRect = CGRectMake(0,0,rect.size.width,rect.size.height);
		CGContextDrawImage(context, imageRect, _image.CGImage);
	}
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBStrokeColor(context, 255.0, 255.0, 255.0, 0.5);
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0);
    
    CGContextFillRect(context, rect); // a square at the bot
    CGContextStrokeRect(context, rect);


}



- (UIImage *) image { return _image; }
- (void) setImage:(UIImage *)newImage {
	
	if(_image != nil) {
        [_image release];
        _image = nil;
    }
    _image = [newImage copy];
    
	[self setNeedsDisplay];
}

#pragma mark -
#pragma mark Touch Methods

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:self];
	
	// set startDrag points
	_startDragX = touchPoint.x;
	_startDragY = touchPoint.y;
    
    self.scale = 1.2;
    
	// call delegate method
	[[self delegate] puzzlePieceWasPressed:self];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	// get touch in superview
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:[self superview]];
	
	// set current drag
	/*_currentDragX = self.currentFrame.origin.x + self.currentFrame.size.width/2 - touchPoint.x;
	_currentDragY = self.currentFrame.origin.y + self.currentFrame.size.height/2 - touchPoint.y;
	
	// set new frame
	self.frame = CGRectMake(touchPoint.x - _startDragX, touchPoint.y - _startDragY, self.frame.size.width, self.frame.size.height);
	*/
    
    _currentDragX = self.currentCenter.x - touchPoint.x;
	_currentDragY = self.currentCenter.y - touchPoint.y;
	
    // set new frame
    //self.frame = CGRectMake(touchPoint.x - _startDragX, touchPoint.y - _startDragY, self.frame.size.width, self.frame.size.height);
    CGRect newFrame = CGRectMake(touchPoint.x - _startDragX, touchPoint.y - _startDragY, self.frame.size.width, self.frame.size.height);
	self.center = CGPointMake(newFrame.origin.x + newFrame.size.width/2, newFrame.origin.y + newFrame.size.height/2);
    
	// call delegate method
	[[self delegate] puzzlePieceIsBeingMoved:self];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
    self.scale = 1;
    
	_currentDragX = 0;
	_currentDragY = 0;
	
	// call delegate method
	[[self delegate] puzzlePieceWasReleased:self];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
	_currentDragX = 0;
	_currentDragY = 0;
	
	// call delegate method
	[[self delegate] puzzlePieceWasReleased:self];
}

- (void) setScale:(float)scale {
    _scale = scale;
    
    [UIView beginAnimations:@"setScale" context:nil];
    [UIView setAnimationDuration:0.2];

    self.transform = CGAffineTransformMakeScale(_scale, _scale);

    [UIView commitAnimations];
    
}


#pragma mark -
#pragma mark Movement Methods

- (void) moveToRect:(CGRect)rect animated:(BOOL)animated {
	
    // reset current drag
	_currentDragX = 0;
	_currentDragY = 0;
	
	// set current frame
	self.currentFrame = rect;
    self.currentCenter = CGPointMake(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2);
	
	// animate
	[UIView beginAnimations:@"moveToRect" context:nil];
	[UIView setAnimationDuration:0.25];
	[UIView setAnimationDelegate:self];
	
	self.frame = rect;
	//CGAffineTransformConcat(CGAffineTransformMakeScale(_scale, _scale), CGAffineTransformMakeRotation(_rotation));
	
	if(animated) [UIView commitAnimations];
}

- (void) moveToPoint:(CGPoint)point animated:(BOOL)animated {
    // reset current drag
	_currentDragX = 0;
	_currentDragY = 0;
	
	// set current frame
	//self.currentFrame = rect;
    self.currentCenter = point;
	
	// animate
	[UIView beginAnimations:@"moveToRect" context:nil];
	[UIView setAnimationDuration:0.25];
	[UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(moveToPointComplete)];
	
	self.center = point;
	//CGAffineTransformConcat(CGAffineTransformMakeScale(_scale, _scale), CGAffineTransformMakeRotation(_rotation));
	
	if(animated) [UIView commitAnimations];
}

- (void) moveToPointComplete {
    self.scale = 1;
}

@end
