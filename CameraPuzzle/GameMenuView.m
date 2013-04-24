//
//  GameMenuView.m
//  CameraPuzzle
//
//  Created by jschwartz on 4/14/11.
//  Copyright 2011 BSSP. All rights reserved.
//

#import "GameMenuView.h"


@implementation GameMenuView

@synthesize delegate;
@synthesize previewSwitch;
@synthesize puzzleSource;

- (void)dealloc
{
    delegate = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        
        
        swapCameraBtn.hidden = NO;
        selectImageBtn.hidden = YES;
        
        sourceSelector.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kSelectedPuzzleSource];
        difficultySelector.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kSelectedPuzzleSize] || 1;
        
        CGRect newGameMenuFrame = self.frame;
        newGameMenuFrame.origin.y = [self superview].frame.size.height;
        self.frame = newGameMenuFrame;
        
    }
    return self;
}

- (void) setup {
    
    // hide menu
    self.hidden = YES;
    CGRect newGameMenuFrame = self.frame;
    newGameMenuFrame.origin.y = [self superview].frame.size.height;
    self.frame = newGameMenuFrame;
   
    
    swapCameraBtn.hidden = NO;
    selectImageBtn.hidden = YES;
    
    sourceSelector.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kSelectedPuzzleSource] || 0;
    difficultySelector.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kSelectedPuzzleSize] || 1;
}

- (IBAction) btnPressed:(id)sender {
    if([sender isEqual:solveBtn]) {
        [[self delegate] solveBtnWasPressed];
        return;
    }
    if([sender isEqual:shuffleBtn]) {
        [[self delegate] shuffleBtnWasPressed];
        return;
    }
    if([sender isEqual:swapCameraBtn]) {
        [[self delegate] swapCameraBtnWasPressed];
        return;
    }
    if([sender isEqual:selectImageBtn]) {
        [[self delegate] selectImageBtnWasPressed];
        return;
    }    
}

- (IBAction) segmentSelected:(UISegmentedControl *)selector {
    if([selector isEqual:difficultySelector]) {
        [[self delegate] difficultyWasSelected:selector.selectedSegmentIndex];
        return;
    }
    if([selector isEqual:sourceSelector]) {
        self.puzzleSource = selector.selectedSegmentIndex;
        [[self delegate] puzzleSourceWasSelected:selector.selectedSegmentIndex];
        return;
    }
}

- (IBAction) switchToggled:(UISwitch *)theSwitch {
    if([theSwitch isEqual:previewSwitch]) {
        [[self delegate] previewSwitchWasToggled:theSwitch.on];
        return;
    }
}

//==============================================================================
#pragma mark -
#pragma mark Show / Hide Methods
//==============================================================================

- (void) show {
    self.hidden = NO;
    
    [[self delegate] gameMenuViewWillShow:self];
    
    [UIView beginAnimations:@"showGameMenu" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelay:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(showComplete)];
    
    CGRect newGameMenuFrame = self.frame;
    newGameMenuFrame.origin.y = [self superview].frame.size.height - self.frame.size.height;
    self.frame = newGameMenuFrame;
    
    [UIView commitAnimations];
}

- (void) showComplete {
    [[self delegate] gameMenuViewDidShow:self];
}

- (void) hide {
    
    [[self delegate] gameMenuViewWillHide:self];
    
    [UIView beginAnimations:@"hideGameMenu" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hideComplete)];
    
    CGRect newGameMenuFrame = self.frame;
    newGameMenuFrame.origin.y = [self superview].frame.size.height;
    self.frame = newGameMenuFrame;
    
    [UIView commitAnimations];
}

- (void) hideComplete {
    self.hidden = YES;
    [[self delegate] gameMenuViewDidHide:self];
}


//==============================================================================
#pragma mark -
#pragma mark Setters / Getters
//==============================================================================

- (void) setPuzzleSource:(PuzzleSource)newPuzzleSource {
    puzzleSource = newPuzzleSource;
    
    switch (puzzleSource) {
        case 0:
            swapCameraBtn.hidden = NO;
            selectImageBtn.hidden = YES;
            break;
        case 1:
            swapCameraBtn.hidden = YES;
            selectImageBtn.hidden = NO;
            break;
            
        default:
            break;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:puzzleSource forKey:@"selectedPuzzleSource"];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


@end
