//
//  PuzzlePiece.h
//  CameraPuzzle
//
//  Created by jschwartz on 4/5/11.
//  Copyright 2011 BSSP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class PuzzlePiece;

@protocol PuzzlePieceDelegate

- (void) puzzlePieceWasPressed:(PuzzlePiece *)piece;
- (void) puzzlePieceIsBeingMoved:(PuzzlePiece *)piece;
- (void) puzzlePieceWasReleased:(PuzzlePiece *)piece;

@end

typedef enum {
	PuzzlePieceMovementTypeOneSpotHorizontalAndVertical,
	PuzzlePieceMovementTypeAnywhere
} PuzzlePieceMovementType;

@interface PuzzlePiece : UIView {
    
    // data vars
	id <PuzzlePieceDelegate> delegate;
	CGRect _originalFrame;
	CGRect _currentFrame;
    CGPoint _originalCenter;
    CGPoint _currentCenter;
	int _index;
    int _xIndex;
    int _yIndex;
	int _depth;
	PuzzlePieceMovementType _movementType;

    // 
	float _scale;
	float _scaleV;
	float _rotation;
	float _rotationV;
	
	float _startDragX;
	float _startDragY;
	float _currentDragX;
	float _currentDragY;
	UIImage *_image;

    
}

@property (nonatomic, assign) id <PuzzlePieceDelegate> delegate;
@property (nonatomic, assign) int index;
@property (nonatomic, assign) int xIndex;
@property (nonatomic, assign) int yIndex;

@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, assign) CGRect currentFrame;
@property (nonatomic, assign) CGPoint originalCenter;
@property (nonatomic, assign) CGPoint currentCenter;
@property (nonatomic, assign) float scale;
@property (nonatomic, assign) float rotation;
@property (nonatomic, assign) PuzzlePieceMovementType movementType;
@property (nonatomic, copy) UIImage *image;

@property (nonatomic, assign) float currentDragX;
@property (nonatomic, assign) float currentDragY;

// methods
- (void) moveToRect:(CGRect)rect animated:(BOOL)animated;
- (void) moveToPoint:(CGPoint)point animated:(BOOL)animated;
- (void) setImage:(UIImage *)image;
- (void) update;

@end
