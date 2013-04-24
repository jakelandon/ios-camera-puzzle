//
//  SolutionPreviewView.h
//  CameraPuzzle
//
//  Created by jschwartz on 4/15/11.
//  Copyright 2011 BSSP. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SolutionPreviewView : UIView {
    IBOutlet UIImageView *imageView;
    
    UIImage *image;
    float _startDragX;
	float _startDragY;
	float _currentDragX;
	float _currentDragY;
}

@property (nonatomic, assign) UIImage *image;

- (void) initSolutionPreview;
- (void) show;
- (void) hide;

@end
