//
//  PuzzleCompletedView.m
//  CameraPuzzle
//
//  Created by jschwartz on 4/14/11.
//  Copyright 2011 BSSP. All rights reserved.
//

#import "PuzzleCompletedView.h"


@implementation PuzzleCompletedView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.alpha = 0;
        self.hidden = YES;
    }
    return self;
}

- (void) show {
    self.hidden = NO;
    
    [UIView beginAnimations:@"showGameMenu" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelay:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(showComplete)];
    
    self.alpha = 1;
    
    [UIView commitAnimations];
}

- (void) showComplete {
}

- (void) hide {
    
    [[self delegate] puzzleCompletedViewWillHide:self];
    
    [UIView beginAnimations:@"hideGameMenu" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hideComplete)];
    
    self.alpha = 0;
    
    [UIView commitAnimations];
}

- (void) hideComplete {
    self.hidden = YES;
    
    [self removeFromSuperview];
}


- (IBAction) btnPressed:(id)sender {
    
    if([sender isEqual:okBtn]) {
        [self hide];
    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    delegate = nil;
    [super dealloc];
}

@end
