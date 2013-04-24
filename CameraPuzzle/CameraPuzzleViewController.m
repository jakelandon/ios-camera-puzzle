//
//  CameraPuzzleViewController.m
//  CameraPuzzle
//
//  Created by jschwartz on 4/5/11.
//  Copyright 2011 BSSP. All rights reserved.
//

#import "CameraPuzzleViewController.h"


@implementation CameraPuzzleViewController

// video capture vars
@synthesize captureSession = _captureSession;
@synthesize previewLayer = _previewLayer;

// puzzle game vars
@synthesize puzzleView;
@synthesize puzzleSize = _puzzleSize;
@synthesize pieceMovementType = _pieceMovementType;
@synthesize puzzleImage = _puzzleImage;
@synthesize milliseconds = _milliseconds;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    
    [puzzlePieces release];
    puzzlePieces = nil;
    
    [puzzlePieceSpots release];
    puzzlePieceSpots = nil;
    
    [_puzzleImage release];
    _puzzleImage = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
   
    

    
    
    // create puzzle
    self.puzzleImage = nil;
    self.pieceMovementType = PuzzlePieceMovementTypeOneSpotHorizontalAndVertical;
    self.puzzleSize = [[NSUserDefaults standardUserDefaults] integerForKey:@"selectedPuzzleSize"] || PuzzleSize4x6;
    [self createPuzzle];
    
    
    // setup game menu view
    [self setupGameMenu];
    
    // setup game stat view
    [self setupGameStats];
    
   
    [self setupSolutionPreview];

    // if photo is selected as the source, load previous image...
    if(gameMenuView.puzzleSource == PuzzleSourcePhoto) {
       
        UIImage *savedImage = [self loadImage:kSelectedImage];
        if(savedImage != nil) {
            [self setPuzzleImage:savedImage];
        }
    }
    
    // start video capture
    [self initVideoCapture];
    
    

    
    testImageView.hidden = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark -
#pragma mark Video Capture Methods

- (void) initVideoCapture {
    //We setup the input
    
	AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput
										  deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo]
                                          error:nil];
	
    //We setupt the output
	AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
	//While a frame is processes in -captureOutput:didOutputSampleBuffer:fromConnection: delegate methods no other frames are added in the queue.
	// If you don't want this behaviour set the property to NO 
	captureOutput.alwaysDiscardsLateVideoFrames = YES; 
	
	// We specify a minimum duration for each frame (play with this settings to avoid having too many frames waiting
	// in the queue because it can cause memory issues). It is similar to the inverse of the maximum framerate.
	// In this example we set a min frame duration of 1/10 seconds so a maximum framerate of 10fps. We say that
	// we are not able to process more than 10 frames per second.
	captureOutput.minFrameDuration = CMTimeMake(1, 15);
	
	// We create a serial queue to handle the processing of our frames
	dispatch_queue_t queue;
	queue = dispatch_queue_create("cameraQueue", NULL);
	[captureOutput setSampleBufferDelegate:self queue:queue];
	dispatch_release(queue);
	// Set the video output to store frame in BGRA (It is supposed to be faster)
	
	NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
	NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]; 
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key]; 
	[captureOutput setVideoSettings:videoSettings]; 
	
	//And we create a capture session
	self.captureSession = [[AVCaptureSession alloc] init];
    
    NSString *sessionPreset = AVCaptureSessionPreset640x480;//1280x720;// 
    /*if([[[UIDevice currentDevice] model] isEqualToString:@"iPad"]) {
     sessionPreset = AVCaptureSessionPreset1280x720; 
     } else {
     sessionPreset = AVCaptureSessionPreset640x480;
     }*/
	self.captureSession.sessionPreset = sessionPreset;
    
    
	//*We add input and output
	[self.captureSession addInput:captureInput];
	[self.captureSession addOutput:captureOutput];
	
	//*We start the capture
	[self.captureSession startRunning];
	
    // set camera
    int cameraPosition = [[NSUserDefaults standardUserDefaults] integerForKey:kSelectedCameraPosition] || 1;
    [self setCamera:cameraPosition];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection 
{ 
	if([gameMenuView puzzleSource] == PuzzleSourceCamera) {
        //We create an autorelease pool because as we are not in the main_queue our code is
        // not executed in the main thread. So we have to create an autorelease pool for the thread we are in
        
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
        
        // Lock the image buffer
        CVPixelBufferLockBaseAddress(imageBuffer,0); 
        
        // Get information about the image
        uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer); 
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
        size_t width = CVPixelBufferGetWidth(imageBuffer); 
        size_t height = CVPixelBufferGetHeight(imageBuffer);  
        //*Create a CGImageRef from the CVImageBufferRef
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
        CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        
        CGImageRef newImage = CGBitmapContextCreateImage(newContext);	
        
        //*We release some components
        CGContextRelease(newContext); 
        CGColorSpaceRelease(colorSpace);
        
        //*We display the result on the custom layer. All the display stuff must be done in the main thread because
        // UIKit is no thread safe, and as we are not in the main thread (remember we didn't use the main_queue)
        // we use performSelectorOnMainThread to call our CALayer and tell it to display the CGImage.
        UIImage *image = [UIImage imageWithCGImage:newImage scale:1 orientation:UIImageOrientationRight];
        [self performSelectorOnMainThread:@selector(setPuzzleImage:) withObject:image waitUntilDone:YES];
        
        //*We relase the CGImageRef
        CGImageRelease(newImage);
        
        
        //*We unlock the  image buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
        
        [pool drain];
    }
} 

- (void) swapCameras {
    // Assume the session is already running
    
    NSArray *inputs = self.captureSession.inputs;
    for ( AVCaptureDeviceInput *INPUT in inputs ) {
        AVCaptureDevice *device = INPUT.device;
        if ( [device hasMediaType : AVMediaTypeVideo] ) {
            AVCaptureDevicePosition position = device.position; 
            AVCaptureDevice *newCamera = nil; 
            AVCaptureDeviceInput *newInput = nil;
            
            if ( position == AVCaptureDevicePositionFront ) {
                // use back camera
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
                
                // store camera
                [[NSUserDefaults standardUserDefaults] setInteger:AVCaptureDevicePositionBack forKey:kSelectedCameraPosition];
                
            } else {
                // use front camera
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront]; 
            
                // store camera
                [[NSUserDefaults standardUserDefaults] setInteger:AVCaptureDevicePositionFront forKey:kSelectedCameraPosition];
            }
            
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            
            // beginConfiguration ensures that pending changes are not applied immediately
            [self.captureSession beginConfiguration];
            
            [self.captureSession removeInput:INPUT];
            [self.captureSession addInput:newInput];
            
            // Changes take effect once the outermost commitConfiguration is invoked.
            [self.captureSession commitConfiguration];
            break ;
        }
    }
}

- (void) setCamera:(int)cameraPosition {
    
    // store camera position
    [[NSUserDefaults standardUserDefaults] setInteger:cameraPosition forKey:kSelectedCameraPosition];

    NSArray *inputs = self.captureSession.inputs;
    for ( AVCaptureDeviceInput *INPUT in inputs ) {
        AVCaptureDevice *device = INPUT.device;
        if ( [device hasMediaType : AVMediaTypeVideo] ) {
            AVCaptureDevice *newCamera = nil; 
            AVCaptureDeviceInput *newInput = nil;
            
            newCamera = [self cameraWithPosition:cameraPosition];
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            
            // beginConfiguration ensures that pending changes are not applied immediately
            [self.captureSession beginConfiguration];
            
            [self.captureSession removeInput:INPUT];
            [self.captureSession addInput:newInput];
            
            // Changes take effect once the outermost commitConfiguration is invoked.
            [self.captureSession commitConfiguration];
            break ;
        }
    }
}

- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}


#pragma mark -
#pragma mark Puzzle Game Methods

- (void) createPuzzle {

    // reset puzzle pieces
    if(puzzlePieces != nil) {
        
        for(PuzzlePiece *p in puzzlePieces) {
            [p removeFromSuperview];
        }
        
        [puzzlePieces release];
        puzzlePieces = nil;
    }
    puzzlePieces = [[NSMutableArray alloc] init];
 
    // reset puzzle piece spots
    if([puzzlePieceSpots count] > 0) {
		[puzzlePieceSpots release];
		puzzlePieceSpots = nil;
	}
	puzzlePieceSpots = [[NSMutableArray alloc] init];
    
    float puzzleWidth = puzzleView.frame.size.width;
    float puzzleHeight = puzzleView.frame.size.height;
    
    
    int numPiecesPerRow = (int)_puzzleDimensions.width;
	int numPiecesPerColumn = (int)_puzzleDimensions.height;
	
	float pieceStartX = 0.0;
	float pieceStartY = 0.0;
	float pieceSpacer = 0.0;
	
	float pieceX = pieceStartX;
	float pieceY = pieceStartY;
	
	float pieceWidth = (puzzleWidth - ((numPiecesPerRow-1) * pieceSpacer)) / numPiecesPerRow;
	float pieceHeight = (puzzleHeight - ((numPiecesPerColumn-1) * pieceSpacer)) / numPiecesPerColumn;
	
	for(int i = 0; i < numPiecesPerRow; i++) {
		pieceX = pieceStartX = (i * (pieceWidth + pieceSpacer));
		pieceY = pieceStartY;
		
		for(int n = 0; n < numPiecesPerColumn; n++) {
            
			// create puzzle piece
			CGRect pieceRect = CGRectMake(pieceX, 
                                          pieceY, 
                                          pieceWidth, 
                                          pieceHeight);
			[puzzlePieceSpots addObject:[NSValue valueWithCGRect:pieceRect]];
			

            PuzzlePiece *piece = [[PuzzlePiece alloc] initWithFrame:CGRectMake(pieceX, 
                                                                               pieceY, 
                                                                               pieceWidth, 
                                                                               pieceHeight)];
			piece.delegate = self;
			piece.index = [puzzlePieces count];
			piece.xIndex = i;
            piece.yIndex = n;
            [puzzlePieces addObject:piece];
			[puzzleView addSubview:piece];
			[piece release];
			
            
            //NSLog(@"puzzle piece: %f, %f, %f, %f", pieceX, pieceY, pieceWidth, pieceHeight);
			
			// increase pieceX 
			pieceY += pieceHeight + pieceSpacer;
		}
	}
    
    /*if(![puzzleTimer isValid]) {
        puzzleTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0
                                                       target:self
                                                     selector:@selector(handlePuzzleTimer:) 
                                                     userInfo:nil
                                                      repeats:YES];
    }*/
    [NSThread detachNewThreadSelector:@selector(startRunLoop) toTarget:self withObject:nil];
}

- (void) startRunLoop {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    [NSThread sleepForTimeInterval:0.1];
    
    [self performSelectorOnMainThread:@selector(runLoop) withObject:nil waitUntilDone:YES];
    
    [pool release];
}

- (void) runLoop {
    
    [NSTimer scheduledTimerWithTimeInterval:1/10.0 
                                     target:self selector:@selector(handlePuzzleTimer:) userInfo:nil repeats:YES];
}




- (void) shufflePuzzle {
    
    // reset stats
    [gameStatView resetStats];
    gameStatView.shuffled = YES;
    

    NSMutableArray *tempPuzzleSpots = [NSMutableArray arrayWithArray:puzzlePieceSpots];
	
	// parse through again and reassign positions
	for(int i = 0; i < [puzzlePieces count]; i++) {
        
		// get random frame
		int randomFrame = random() % [tempPuzzleSpots count];
		
		if(randomFrame > [tempPuzzleSpots count] - 1) {
			randomFrame = [tempPuzzleSpots count] - 1;
		}
		
		CGRect newFrame = [[tempPuzzleSpots objectAtIndex:randomFrame] CGRectValue];
		
		// remove frame from puzzleSpots
		[tempPuzzleSpots removeObjectAtIndex:randomFrame];
		
		// move puzzle piece to random frame
		PuzzlePiece *p = [puzzlePieces objectAtIndex:i];
		[p moveToRect:newFrame animated:YES];
	}
}

- (void) solvePuzzle {
    for(PuzzlePiece *piece in puzzlePieces) {
        [piece moveToRect:piece.originalFrame animated:YES];
    }
}

- (BOOL) checkPuzzleForCompletion {
	
   
	BOOL isComplete = YES;
	
	for(PuzzlePiece *p in puzzlePieces) {
        float dx = p.originalCenter.x - p.currentCenter.x;//p.originalFrame.origin.x - p.currentFrame.origin.x;
        float dy = p.originalCenter.y - p.currentCenter.y;//p.originalFrame.origin.y - p.currentFrame.origin.y;
        float dist = sqrt(dx*dx+dy*dy);
        if(dist > 5.0) {
            isComplete = NO;
        }
	}
    
	if(isComplete) {
        // create puzzle completed view
        PuzzleCompletedView *puzzleCompletedView = [[[[NSBundle mainBundle] loadNibNamed:@"PuzzleCompletedView" owner:nil options:nil] objectAtIndex:0] retain];
        puzzleCompletedView.hidden = YES;
        puzzleCompletedView.alpha = 0;
        puzzleCompletedView.delegate = self;
        [self.view addSubview:puzzleCompletedView];
        [puzzleCompletedView show];
        [puzzleCompletedView release];
	}
    
	return isComplete;
}

- (void) updateTime {
    self.milliseconds++;
}

- (void) setPuzzleSize:(PuzzleSize)newPuzzleSize {
    
    // save setting
    [[NSUserDefaults standardUserDefaults] setInteger:newPuzzleSize forKey:@"selectedPuzzleSize"];
    
    // set puzzle size
   _puzzleSize = newPuzzleSize;
    
	switch (self.puzzleSize) {
		case PuzzleSize2x3:
			_puzzleDimensions = CGSizeMake(2, 3);
			break;
		case PuzzleSize4x6:
			_puzzleDimensions = CGSizeMake(4, 6);
			break;
		case PuzzleSize8x12:
			_puzzleDimensions = CGSizeMake(6, 9);//8, 12);
			break;
		default:
			break;
	}
}


- (void) setPuzzleImage:(UIImage *)puzzleImage {
 
    // remove and release old puzzle image
    if(_puzzleImage != nil) {
        [_puzzleImage release];
        _puzzleImage = nil;
    }
    
    // rotate puzzle image properly
    if([puzzleImage imageOrientation] == 1) {
        _puzzleImage = [[puzzleImage rotate:UIImageOrientationDown] copy];
    } else if([puzzleImage imageOrientation] != 0) {
        _puzzleImage = [[puzzleImage rotate:UIImageOrientationRight] copy];
    
    } else {
        _puzzleImage = [puzzleImage copy];
    }
    
    // set preview image
    if (!solutionPreviewView.hidden) {
        solutionPreviewView.image = puzzleImage;
    }
    
    if(gameMenuView.puzzleSource == PuzzleSourcePhoto) {
        [self saveImage:puzzleImage withName:kSelectedImage];
    }
    
    
    // cut image up and divide it amongst the pieces
    int numPiecesPerRow = (int)_puzzleDimensions.width;
	int numPiecesPerColumn = (int)_puzzleDimensions.height;
	
	float pieceWidth = _puzzleImage.size.width / (float)numPiecesPerRow;
	float pieceHeight = _puzzleImage.size.height / (float)numPiecesPerColumn;
	 
    for(PuzzlePiece *piece in puzzlePieces) {

        float pieceX = (float)piece.xIndex * pieceWidth;
        float pieceY = (float)piece.yIndex * pieceHeight;
        
        CGRect imageRect = CGRectMake(pieceX, pieceY, pieceWidth, pieceHeight);
        CGImageRef imageRef = CGImageCreateWithImageInRect(_puzzleImage.CGImage, imageRect);
        UIImage *cutImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        
        [piece setImage:cutImage];
    }
}
                              
                              
                              - (void)saveImage:(UIImage *)image withName:(NSString *)name {
                                  
                                  //save image
                                  NSData *data = UIImageJPEGRepresentation(image, 1.0);
                                  NSFileManager *fileManager = [NSFileManager defaultManager];
                                  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                                  NSString *documentsDirectory = [paths objectAtIndex:0];
                                  NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:name];
                                  [fileManager createFileAtPath:fullPath contents:data attributes:nil];
                                  
                              }
                              
                              - (UIImage *)loadImage:(NSString *)name {
                                  
                                  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                                  NSString *documentsDirectory = [paths objectAtIndex:0];
                                  NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:name];    
                                  UIImage *res = [UIImage imageWithContentsOfFile:fullPath];
                                  
                                  return res;
                              }

- (void) handlePuzzleTimer:(NSTimer *)timer {
    self.milliseconds++;
}

- (void) setMilliseconds:(int)milliseconds {
    _milliseconds = milliseconds;
    
    //NSLog(@"milliseconds: %i", _milliseconds);
    
    int tmpMinutes = floor(_milliseconds / 600);
    int tmpSeconds = floor((_milliseconds - (600 * tmpMinutes)) / 10);
    int tmpMilliseconds = _milliseconds - (600 * tmpMinutes) - 10 * tmpSeconds;
    
    NSString *formattedMinutes;
    NSString *formattedSeconds;
    NSString *formattedMilliseconds;
    
    if(tmpMinutes < 10) {
        formattedMinutes = [NSString stringWithFormat:@"0%i", tmpMinutes];
    } else {
        formattedMinutes = [NSString stringWithFormat:@"%i", tmpMinutes];
    }
    
    if(tmpSeconds < 10) {
        formattedSeconds = [NSString stringWithFormat:@"0%i", tmpSeconds];
    } else {
        formattedSeconds = [NSString stringWithFormat:@"%i", tmpSeconds];
    }
    
    if(tmpMilliseconds < 10) {
        formattedMilliseconds = [NSString stringWithFormat:@"0%i", tmpMilliseconds];
    } else {
        formattedMilliseconds = [NSString stringWithFormat:@"%i", tmpMilliseconds];
    }
    
    // update timer label
   // timerLabel.text = [NSString stringWithFormat:@"%@:%@:%@", formattedMinutes, formattedSeconds, formattedMilliseconds];
}

//==============================================================================
#pragma mark -
#pragma mark Puzzle Completed View Delegate Methods
//==============================================================================

- (void) puzzleCompletedViewWillHide:(PuzzleCompletedView *)pvc {
    [gameStatView resetStats];
}

//==============================================================================
#pragma mark -
#pragma mark Puzzle Piece Delegate Methods
//==============================================================================

- (void) puzzlePieceWasPressed:(PuzzlePiece *)piece {
    
	// put selected piece on top
	for(int i = 0; i < [puzzlePieces count]; i++) {
		PuzzlePiece *p = [puzzlePieces objectAtIndex:i];
		if(![p isEqual:piece]) {
			[puzzleView sendSubviewToBack:p];
		}
	}
}

- (void) puzzlePieceIsBeingMoved:(PuzzlePiece *)piece {
	
	
	//CGRect 
	float pieceWidth = piece.currentFrame.size.width;
	float pieceHeight = piece.currentFrame.size.height;
	
	CGRect newPieceRect = piece.frame;
    CGPoint newPieceCenter = piece.center;
	
    float movedDist = sqrt(piece.currentDragX*piece.currentDragX+piece.currentDragY*piece.currentDragY);

	// limit movement if necessary
	switch (self.pieceMovementType) {
            
            // if can drag piece anywhere
		case PuzzlePieceMovementTypeAnywhere:
			break;
            
		case PuzzlePieceMovementTypeOneSpotHorizontalAndVertical:	
			
            // if dragging left or right
            if(movedDist > 10) {
                
                if(abs(piece.currentDragX) > abs(piece.currentDragY)) {
                     newPieceCenter.y = piece.currentCenter.y;
                    
                    if(newPieceCenter.x < piece.currentCenter.x - pieceWidth) {
                        newPieceCenter.x = piece.currentCenter.x - pieceWidth;
                    }
                    if(newPieceCenter.x > piece.currentCenter.x + pieceWidth) {
                        newPieceCenter.x = piece.currentCenter.x + pieceWidth;
                    }
                } 
                // if dragging up or down
                else if(abs(piece.currentDragX) < abs(piece.currentDragY)) {
                    newPieceCenter.x = piece.currentCenter.x;
                    if(newPieceCenter.y < piece.currentCenter.y - pieceHeight) {
                        newPieceCenter.y = piece.currentCenter.y - pieceHeight;
                    }
                    if(newPieceCenter.y > piece.currentCenter.y + pieceHeight) {
                        newPieceCenter.y = piece.currentCenter.y + pieceHeight;
                    }
                }
            }
            
            piece.center = newPieceCenter;
            
			// if dragging left or right
			/*if(abs(piece.currentDragX) > abs(piece.currentDragY)) {
				newPieceRect.origin.y = piece.currentFrame.origin.y;
				
				if(newPieceRect.origin.x < piece.currentFrame.origin.x - pieceWidth) {
					newPieceRect.origin.x = piece.currentFrame.origin.x - pieceWidth;
				}
				if(newPieceRect.origin.x > piece.currentFrame.origin.x + pieceWidth) {
					newPieceRect.origin.x = piece.currentFrame.origin.x + pieceWidth;
				}
			} 
			// if dragging up or down
			else if(abs(piece.currentDragX) < abs(piece.currentDragY)) {
				newPieceRect.origin.x = piece.currentFrame.origin.x;
				if(newPieceRect.origin.y < piece.currentFrame.origin.y - pieceHeight) {
					newPieceRect.origin.y = piece.currentFrame.origin.y - pieceHeight;
				}
				if(newPieceRect.origin.y > piece.currentFrame.origin.y + pieceHeight) {
					newPieceRect.origin.y = piece.currentFrame.origin.y + pieceHeight;
				}
			}
			// set frame of rect
			piece.frame = newPieceRect;
             */
			
			break;
		default:
			break;
	}
}

- (void) puzzlePieceWasReleased:(PuzzlePiece *)piece {
	
	currentPiece = nil;
	
	// create placeholder frame for selected piece
	CGRect newPieceFrame = piece.currentFrame;
	CGPoint newPieceCenter = piece.currentCenter;
    //float newPieceScale = piece.scale;
	//float newPieceRotation = piece.rotation;
	// check to see if we should switch with another piece
    
	for(PuzzlePiece *p in puzzlePieces) {
		
		if(![p isEqual:piece]) {
			
			float dx = piece.center.x - p.center.x;
			float dy = piece.center.y - p.center.y;
			float dist = sqrt(dx*dx+dy*dy);
			if(dist < piece.frame.size.width/2) {
				// swap places
				newPieceFrame = p.frame;
                newPieceCenter = p.center;
				//newPieceScale = p.scale;
				//newPieceRotation = p.rotation;
				//[p moveToRect:piece.currentFrame animated:YES];		
                [p moveToPoint:piece.currentCenter animated:YES];
               
                // increase moveCount
                gameStatView.moveCount++;
                
				break;
			}
		}
	}
	
	// move selected piece
	//[piece setScale:newPieceScale];
	//[piece setRotation:newPieceRotation];
	//[piece moveToRect:newPieceFrame  animated:YES];
	[piece moveToPoint:newPieceCenter animated:YES];
    
	// check for complete
    if(gameStatView.moveCount > 0 && gameStatView.shuffled) {
        [self checkPuzzleForCompletion];
    }
}

//==============================================================================
#pragma mark -
#pragma mark Game Menu View Methods
//==============================================================================

- (void) setupGameMenu {
    
    gameMenuView = [[[NSBundle mainBundle] loadNibNamed:@"GameMenuView" owner:nil options:nil] objectAtIndex:0];
    gameMenuView.delegate = self;
    [self.view addSubview:gameMenuView];
    [gameMenuView setup];
  

        
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapRecognizer.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapRecognizer];
    [tapRecognizer release];
  
    
   
}

- (void) solveBtnWasPressed {
    [self solvePuzzle];
}

- (void) shuffleBtnWasPressed {
    [self shufflePuzzle];
}

- (void) swapCameraBtnWasPressed {
    [self swapCameras];
}

- (void) selectImageBtnWasPressed {
   
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentModalViewController:imagePicker animated:YES];
    [imagePicker release];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    
    NSLog(@"image orientation: %i", [image imageOrientation]);
    
    [self setPuzzleImage:image];
    
    [picker dismissModalViewControllerAnimated:YES];
}
     

- (void) difficultyWasSelected:(int)newDifficulty {
    switch (newDifficulty) {
        case 0:
            [self setPuzzleSize:PuzzleSize2x3];
            break;
        case 1:
            [self setPuzzleSize:PuzzleSize4x6];
            break;
        case 2:
            [self setPuzzleSize:PuzzleSize8x12];
            break;
        default:
            [self setPuzzleSize:PuzzleSize4x6];
            break;
    }
    
    [self createPuzzle];
}

- (void) puzzleSourceWasSelected:(int)newPuzzleSource {
    [[NSUserDefaults standardUserDefaults] setInteger:newPuzzleSource forKey:@"puzzleSource"];
}

- (void) previewSwitchWasToggled:(BOOL)showPreview {
    if(showPreview) {
        [solutionPreviewView show];
    } else {
        [solutionPreviewView hide];
    }
}


- (void) gameMenuViewDidShow:(GameMenuView *)gmv {
}

- (void) gameMenuViewWillShow:(GameMenuView *)gmv {
    /*[UIView beginAnimations:@"hideGameMenuBtn" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelay:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(showComplete)];
    
    CGRect newGameMenuBtnFrame = gameMenuBtn.frame;
    newGameMenuBtnFrame.origin.y = self.view.frame.size.height;
    gameMenuBtn.frame = newGameMenuBtnFrame;
    
    [UIView commitAnimations];*/
}
- (void) gameMenuViewWillHide:(GameMenuView *)gmv {
   /* [UIView beginAnimations:@"showGameMenuBtn" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelay:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(showComplete)];
    
    CGRect newGameMenuBtnFrame = gameMenuBtn.frame;
    newGameMenuBtnFrame.origin.y = self.view.frame.size.height - gameMenuBtn.frame.size.height;
    gameMenuBtn.frame = newGameMenuBtnFrame;
    
    [UIView commitAnimations];*/
}

- (void) gameMenuViewDidHide:(GameMenuView *)gmv {
}

- (void) handleTap:(UITapGestureRecognizer *)recognizer {
    
    if(gameMenuView.hidden) {
        [gameMenuView show];
    } else {
        [gameMenuView hide];
    }
}

- (IBAction) btnPressed:(id)sender {
}


- (void) setupGameStats {
    
    gameStatView = [[[NSBundle mainBundle] loadNibNamed:@"GameStatView" owner:nil options:nil] objectAtIndex:0];
    //gameMenuView.delegate = self;
    [self.view addSubview:gameStatView];
    [gameStatView resetStats];
}

- (void) setupSolutionPreview {
    solutionPreviewView = [[[NSBundle mainBundle] loadNibNamed:@"SolutionPreviewView" owner:nil options:nil] objectAtIndex:0];
    [self.view addSubview:solutionPreviewView];
    solutionPreviewView.hidden = !gameMenuView.previewSwitch.on;
    [solutionPreviewView initSolutionPreview];

}


@end
