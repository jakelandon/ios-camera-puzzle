//
//  GameMenuView.h
//  CameraPuzzle
//
//  Created by jschwartz on 4/14/11.
//  Copyright 2011 BSSP. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameMenuView;

@protocol GameMenuViewDelegate <NSObject>

@optional
- (void) gameMenuViewWillShow:(GameMenuView *)gmv;
- (void) gameMenuViewDidShow:(GameMenuView *)gmv;
- (void) gameMenuViewWillHide:(GameMenuView *)gmv;
- (void) gameMenuViewDidHide:(GameMenuView *)gmv;

- (void) solveBtnWasPressed;
- (void) shuffleBtnWasPressed;
- (void) swapCameraBtnWasPressed;
- (void) selectImageBtnWasPressed;
- (void) previewSwitchWasToggled:(BOOL)showPreview;
- (void) difficultyWasSelected:(int)newDifficulty;
- (void) puzzleSourceWasSelected:(int)newPuzzleSource;


@end

typedef enum {
    PuzzleSourceCamera,
    PuzzleSourcePhoto
} PuzzleSource;

#define kSelectedPuzzleSource @"selectedPuzzleSource"
#define kSelectedPuzzleSize @"selectedPuzzleSize"
#define kSelectedCameraPosition @"selectedCameraPosition"
#define kPreviewBoxOn @"isPreviewBoxToggled"
#define kSelectedImage @"selectedImage"

@interface GameMenuView : UIView {
    id <GameMenuViewDelegate> delegate;
    
    IBOutlet UIButton *swapCameraBtn;
    IBOutlet UIButton *selectImageBtn;
    IBOutlet UIButton *solveBtn;
    IBOutlet UIButton *shuffleBtn;
    IBOutlet UISegmentedControl *sourceSelector;
    IBOutlet UISegmentedControl *difficultySelector;
    IBOutlet UISwitch *previewSwitch;
    
    PuzzleSource puzzleSource;
}

@property (nonatomic, assign) id <GameMenuViewDelegate> delegate;
@property (nonatomic, assign) IBOutlet UISwitch *previewSwitch;
@property (nonatomic, assign) PuzzleSource puzzleSource;

- (void) setup;
- (void) show;
- (void) hide;

- (IBAction) btnPressed:(id)sender;
- (IBAction) segmentSelected:(UISegmentedControl *)selector;
- (IBAction) switchToggled:(UISwitch *)theSwitch;

@end
