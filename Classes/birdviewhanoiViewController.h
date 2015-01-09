//
//  birdviewhanoiViewController.h
//  birdviewhanoi
//
//  Created by Jie Yan on 10-10-11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DEVELOP_MODE 0 // 0 - release mode; 1 - develop mode

#define NUMPILES 3 // Only 3 piles A, B, C
#define MAXLEVEL 12 // free version only play 5 disks 
#define DISKSIZE 70 // the touch radius of disk 
#define BUBBLESIZE 65 // the size of bubbles
#define LEAFDISKSIZE 120 // the size of leaf disk
#define CENTERNUMBERSIZE 60 // the size of center number
#define CORNERNUMBERSIZE 30 // the size of corner number


@interface birdviewhanoiViewController : UIViewController {
	UIImageView *mainMenu; // Main Menu image
	UIImageView *company; // company logo
	// Labels
	UILabel *currentMovesLabel;
	UILabel *currentLevelLabel;
	UILabel *currentScoreLabel;
	// Buttons
	UIButton *newGameButton;
	UIButton *continueButton;
	UIButton *helpButton;
	UIImageView *helpView;
	UIButton *helpBackButton;
	UIButton *gameBackButton;
	UIButton *gameResetButton;

	
	// Data value
	int centerCoor[NUMPILES][2]; // save the center coordinates(x, y) of each pile
	CGPoint diskCenters[NUMPILES]; // the center coord of each pile 
	NSInteger currentLevel;
	NSInteger currentMoves;
	NSInteger currentScore;
	NSInteger i;
	NSInteger currentMoveDisk; // The disk that is moving, from 0 to 4; -1 = no disk is moving
	int currentFromPile; // The pile that the disk is move from, from 0 to 2
	int diskLocation[MAXLEVEL]; // 0 = A; 1 = B; 2 = C # save maximum 5 disks at which pile
	int cornerNumberLocation[MAXLEVEL][2]; // save the corner number location
	int screenWidth;
    int screenHeight;
	int miniWidth;
	int miniHeight;
	int hardwareName; // 0 = iPod 360x480; 1 = iPhone4 720x960; 2 = iPad 768x1024
	
	// new design follow here
	UIImageView *dot1;
	UIImageView *mapleLeaf;
	UIImageView *mapleLeafLong;
	UIView	*leafMenu;
	UIView	*leafGameBackground;
	UIView	*bubblesLayer;
	UIImageView *bubbleImage;
	UIView	*helpViewLayer;

	NSMutableArray *chArray;
	NSMutableArray *leafDiskArray;

	UIImageView *leafDisk;
	UILabel *numberLabel;
	UILabel *mininumberLabel;
	
	UIScrollView *scrollView;
}

@property (nonatomic, retain) IBOutlet UIImageView *mainMenu;
@property (nonatomic, retain) IBOutlet UIImageView *company;
@property (nonatomic, retain) IBOutlet UILabel *currentMovesLabel;
@property (nonatomic, retain) IBOutlet UILabel *currentLevelLabel;
@property (nonatomic, retain) IBOutlet UILabel *currentScoreLabel;
@property (nonatomic, retain) IBOutlet UIButton *newGameButton;
@property (nonatomic, retain) IBOutlet UIButton *continueButton;
@property (nonatomic, retain) IBOutlet UIButton *helpButton;
@property (nonatomic, retain) IBOutlet UIImageView *helpView;
@property (nonatomic, retain) IBOutlet UIButton *helpBackButton;
@property (nonatomic, retain) IBOutlet UIButton *gameBackButton;
@property (nonatomic, retain) IBOutlet UIButton *gameResetButton;

// new design follow here
@property (nonatomic, retain) IBOutlet UIImageView *dot1;
@property (nonatomic, retain) IBOutlet UIImageView *mapleLeaf;
@property (nonatomic, retain) IBOutlet UIImageView *mapleLeafLong;
@property (nonatomic, retain) IBOutlet UIView *leafMenu;
@property (nonatomic, retain) IBOutlet UIView *leafGameBackground;
@property (nonatomic, retain) IBOutlet UIView *bubblesLayer;
@property (nonatomic, retain) IBOutlet UIView *helpViewLayer;
@property (nonatomic, retain) IBOutlet UIImageView *bubbleImage;

@property (nonatomic, retain) IBOutlet UIImageView *leafDisk;
@property (nonatomic, retain) IBOutlet UILabel *numberLabel;
@property (nonatomic, retain) IBOutlet UILabel *mininumberLabel;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

-(int) getNearestPile:(UIImageView*)tempImageView;
-(BOOL) isThisDiskOnTop:(NSInteger)diskSerial;
-(NSInteger) getTopDiskOfPile:(int)pileNumber;
-(void) saveAllCurrentValue;
-(void) initLevelNew:(NSInteger)iCurrentLevel;
-(void) updateLevelLabel:(NSInteger)currentLevelValue;
-(void) updateMovesLabel:(NSInteger)currentMovesValue;
-(void) updateScoreLabel:(NSInteger)currentScoreValue;
-(BOOL) touchInsideDisk:(UIImageView*)aDisk:(CGPoint)aLocation;
-(void) drawLeafAndPlay:(NSInteger)buttonPressed;			

-(void)fadeOut:(UIView*)viewToDissolve withDuration:(NSTimeInterval)duration 
	   andWait:(NSTimeInterval)wait;
-(void)fadeIn:(UIView*)viewToFadeIn withDuration:(NSTimeInterval)duration 
	  andWait:(NSTimeInterval)wait;

@end

