//
//  PuzzleCompletedView.h
//  CameraPuzzle
//
//  Created by jschwartz on 4/14/11.
//  Copyright 2011 BSSP. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PuzzleCompletedView;

@protocol PuzzleCompletedViewDelegate <NSObject>

@optional
- (void) puzzleCompletedViewWillHide:(PuzzleCompletedView *)pvc;

@end

@interface PuzzleCompletedView : UIView {

    id <PuzzleCompletedViewDelegate> delegate;
    IBOutlet UIButton *okBtn;
}

@property (nonatomic, assign) id <PuzzleCompletedViewDelegate> delegate;

- (IBAction) btnPressed:(id)sender;

- (void) show;
- (void) hide;

@end
