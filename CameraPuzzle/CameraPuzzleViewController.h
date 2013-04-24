//
//  PuzzleViewController.h
//  CameraPuzzle
//
//  Created by jschwartz on 4/5/11.
//  Copyright 2011 BSSP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

#import "PuzzlePiece.h"
#import "WBImage.h"

#import "GameMenuView.h"
#import "GameStatView.h"
#import "PuzzleCompletedView.h"
#import "SolutionPreviewView.h"

typedef enum {
	PuzzleSize2x3,
	PuzzleSize4x6,
	PuzzleSize8x12
	//PuzzleSize16x24,
} PuzzleSize;

@interface CameraPuzzleViewController : UIViewController <PuzzlePieceDelegate, GameMenuViewDelegate, PuzzleCompletedViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate> {
    
    // video capture vars
    AVCaptureSession *_captureSession;
    AVCaptureVideoPreviewLayer *_previewLayer;
    
    // puzzle game vars
    IBOutlet UIView *puzzleView;
    NSMutableArray *puzzlePieces; // array of all puzzle pieces
    NSMutableArray *puzzlePieceSpots; // array of all puzzle piece origins
    PuzzleSize _puzzleSize;
    PuzzlePieceMovementType _pieceMovementType;
    PuzzlePiece *currentPiece;
    CGSize _puzzleDimensions;
    UIImage *_puzzleImage;
    NSTimer *puzzleTimer;
    
    // solution view vars
    SolutionPreviewView *solutionPreviewView;
    
    // testing
    IBOutlet UIImageView *testImageView;
    
    // game overlay view
    GameMenuView *gameMenuView;
    UITapGestureRecognizer *tapRecognizer;
    
    // game stat view
    GameStatView *gameStatView;
}

// video capture / methods
@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *previewLayer;

- (void) initVideoCapture;
- (void) swapCameras;
- (void) setCamera:(int)cameraPosition;
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition)position;


// puzzle game vars / methods
@property (nonatomic, assign) IBOutlet UIView *puzzleView;
@property (nonatomic, assign) PuzzleSize puzzleSize;
@property (nonatomic, assign) PuzzlePieceMovementType pieceMovementType;
@property (nonatomic, retain) UIImage *puzzleImage;
@property (nonatomic, assign) int milliseconds;

- (void) createPuzzle;
- (void) shufflePuzzle;
- (void) solvePuzzle;
- (BOOL) checkPuzzleForCompletion;
- (void) updateTime;

- (void)saveImage:(UIImage *)image withName:(NSString *)name;
- (UIImage *)loadImage:(NSString *)name;

// solution view vars / methods
@property (nonatomic, assign) IBOutlet UIImageView *solutionPreview;

// game overlay view methods
- (void) setupGameMenu;
- (void) setupGameStats;
- (void) setupSolutionPreview;
- (IBAction) btnPressed:(id)sender;
- (IBAction) segmentedControlChanged:(UISegmentedControl *)sender;
- (IBAction) switchToggled:(UISwitch *)sender;

@end
