//
//  GameStatView.h
//  CameraPuzzle
//
//  Created by jschwartz on 4/15/11.
//  Copyright 2011 BSSP. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GameStatView : UIView {
    IBOutlet UILabel *moveCountTxt;
    IBOutlet UILabel *timerTxt;
    
    BOOL _shuffled;
    int _moveCount;
    int _milliseconds;
    int _seconds;
    int _minutes;
    
}

@property (nonatomic, assign, getter = isShuffled) BOOL shuffled;
@property (nonatomic, assign) int moveCount;
@property (nonatomic, assign) int milliseconds;

- (void) resetStats;
- (void) startTimer;
- (void) pauseTimer;
- (void) stopTimer;

@end
