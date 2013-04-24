//
//  GameStatView.m
//  CameraPuzzle
//
//  Created by jschwartz on 4/15/11.
//  Copyright 2011 BSSP. All rights reserved.
//

#import "GameStatView.h"


@implementation GameStatView

@synthesize shuffled = _shuffled;
@synthesize moveCount = _moveCount;
@synthesize milliseconds = _milliseconds;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setMoveCount:(int)moveCount {
    _moveCount = moveCount;
    moveCountTxt.text = [NSString stringWithFormat:@"Moves: %i", _moveCount];
}

- (void) setMilliseconds:(int)milliseconds {
    _milliseconds = milliseconds;
    
    timerTxt.text = [NSString stringWithFormat:@"00:00:00"];
}

- (void) resetStats {
    self.moveCount = 0;
    self.milliseconds = 0;
    self.shuffled = NO;
}

- (void) startTimer {
    
}
- (void) pauseTimer {
    
}
- (void) stopTimer {
    
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
    [super dealloc];
}

@end
