//
//  birdviewhanoiViewController.m
//  birdviewhanoi
//
//  Created by Jie Yan on 10-10-11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "birdviewhanoiViewController.h"
#import <AudioToolbox/AudioServices.h>
#import <QuartzCore/QuartzCore.h>

@implementation birdviewhanoiViewController
@synthesize mainMenu;
@synthesize company;
@synthesize currentMovesLabel;
@synthesize currentLevelLabel;
@synthesize currentScoreLabel;
@synthesize newGameButton;
@synthesize continueButton;
@synthesize helpButton;
@synthesize helpView;
@synthesize helpBackButton;
@synthesize gameBackButton;
@synthesize gameResetButton;
// new design follow here
@synthesize dot1;
@synthesize mapleLeaf;
@synthesize mapleLeafLong;
@synthesize leafMenu;
@synthesize leafGameBackground;
@synthesize bubblesLayer;
@synthesize helpViewLayer;
@synthesize bubbleImage;

@synthesize leafDisk;
@synthesize numberLabel;
@synthesize mininumberLabel;
@synthesize scrollView;

#define degreesToRadian(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) {x * 180 / M_PI;


// Get the nearest pile when releasing(end touch) disk
-(int) getNearestPile:(UIImageView*)tempImageView{
	int nearestPile = 0;
	int distance = 0;
	int minDistance = 0;
	
	// loop all 3 piles
	for (i = 0; i < NUMPILES; i ++) {
		// get the distance to pile
		distance = (tempImageView.center.x - centerCoor[i][0])*(tempImageView.center.x - centerCoor[i][0])
				+ (tempImageView.center.y - centerCoor[i][1])*(tempImageView.center.y - centerCoor[i][1]);
		
		if (i == 0) { // save the pile A distance
			minDistance = distance;
			nearestPile = i;
		}
		else // compare other pile distance to pile A
		{	// if distance to other pile is nearer, save it
			if (minDistance > distance)
			{	// save the smaller distance
				minDistance = distance;
				// save the pile
				nearestPile = i;
			}
		}
	}
	
	return nearestPile;
}

// If this disk is at the top of any pile (A, B or C)
-(BOOL) isThisDiskOnTop:(NSInteger)diskSerial{
	// search from disk1 to diskSerial
	for (int iIndex = 0; iIndex < diskSerial; iIndex ++) {
		if (diskLocation[iIndex] == diskLocation[diskSerial]) {
			return NO;
		}
	}
	return YES;
}

// get the top disk number of one pile
-(NSInteger) getTopDiskOfPile:(int)pileNumber{
	// search from disk1 to current level
	for (NSInteger iIndex = 0; iIndex < currentLevel; iIndex ++) {
		// if find the first disk at pile 
		if (diskLocation[iIndex] == pileNumber) {
			return iIndex;
		}
	}
	// if no disk on this pile, return -1
	return -1;
}

- (CAAnimation*)animationForSpinning {
    
    // Create a transform to rotate in the z-axis
    float radians = degreesToRadian( 80 );
    CATransform3D transform;
    transform = CATransform3DMakeRotation(radians, 0, 0, 1.0);
    
    // Create a basic animation to animate the layer's transform
    CABasicAnimation* animation;
    animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    // Now assign the transform as the animation's value. While
    // animating, CABasicAnimation will vary the transform
    // attribute of its target, which for this transform will spin
    // the target like a wheel on its z-axis. 
    animation.toValue = [NSValue valueWithCATransform3D:transform];
	
    animation.duration = 1;  // two seconds
    animation.cumulative = YES;
    animation.repeatCount = 10000; // "forever"
    return animation;
}

- (void)newspinLayer:(CALayer*)layer {
    
    // Create a new spinning animation
    CAAnimation* spinningAnimation = [self animationForSpinning];
    
    // Assign this animation to the provided layer's opacity attribute.
    // Any subsequent change to the layer's opacity will
    // trigger the animation.
    [layer addAnimation:spinningAnimation forKey:@"opacity"];
    
    // So let's trigger it now
    layer.opacity = 0.99;
}

// Save all current value 
-(void) saveAllCurrentValue{
	// save current level, moves, score and disks locations
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setInteger:currentLevel forKey:@"savedCurrentLevel"];
	[prefs setInteger:currentMoves forKey:@"savedCurrentMoves"];
	[prefs setInteger:currentScore forKey:@"savedCurrentScore"];
	// save disks location
	[prefs setInteger:diskLocation[0] forKey:@"savedDiskLocation0"];
	[prefs setInteger:diskLocation[1] forKey:@"savedDiskLocation1"];
	[prefs setInteger:diskLocation[2] forKey:@"savedDiskLocation2"];
	[prefs setInteger:diskLocation[3] forKey:@"savedDiskLocation3"];
	[prefs setInteger:diskLocation[4] forKey:@"savedDiskLocation4"];
	[prefs setInteger:diskLocation[5] forKey:@"savedDiskLocation5"];
	[prefs setInteger:diskLocation[6] forKey:@"savedDiskLocation6"];
	[prefs setInteger:diskLocation[7] forKey:@"savedDiskLocation7"];
	[prefs setInteger:diskLocation[8] forKey:@"savedDiskLocation8"];
	[prefs setInteger:diskLocation[9] forKey:@"savedDiskLocation9"];
	[prefs setInteger:diskLocation[10] forKey:@"savedDiskLocation10"];
	[prefs setInteger:diskLocation[11] forKey:@"savedDiskLocation11"];
	[prefs synchronize];	
}

// init level all data
-(void) initLevelNew:(NSInteger)iCurrentLevel{
	// read or init values
	currentLevel = iCurrentLevel;
	[self saveAllCurrentValue];
	// update current level label to currentLevel
	[self updateLevelLabel:currentLevel];	
	// update current moves label to 0
	[self updateMovesLabel:currentMoves];
	// update current score label to currentScore
	[self updateScoreLabel:currentScore];
	// default no moving disk
	currentMoveDisk = -1;
	// default no disk from any pile
	currentFromPile = -1;
	// get subviews of leafGameBackGround
	// for (UIImageView *myView in leafGameBackGround.subview)
	// [[leafGameBackGround subviews] count]
	// [[[leafGameBackGround subviews] objectAtIndex:i] removeFromSuperView]
	//NSLog(@"will remove the view.");
	// [leafDisk removeFromSuperview];
	
	// remove all disks
	for (i=0; i<MAXLEVEL; i++)
	{
		leafDisk = [leafDiskArray objectAtIndex:i];
		[leafDisk removeFromSuperview];
	}
	
	// put disks on the view
	 for (i=currentLevel-1; i>=0; i--)
	 {
		 leafDisk = [leafDiskArray objectAtIndex:i];
		 // recover the number on leaf
		 UIImageView *tempCenterNumber = (UIImageView*)[leafDisk viewWithTag:100];
		 tempCenterNumber.alpha = 1;
		 UIImageView *tempCornerNumber = (UIImageView*)[leafDisk viewWithTag:200];
		 tempCornerNumber.alpha = 1;
		 [leafGameBackground addSubview:leafDisk];
		 leafDisk.center = diskCenters[diskLocation[i]];
	 }
}

-(void) updateLevelLabel:(NSInteger)currentLevelValue{
	// convert integer to string
	NSMutableString *levelString = [NSMutableString stringWithFormat:@"Level: %d", currentLevelValue];
	// update the string in label
	currentLevelLabel.text = levelString;
}

-(void) updateMovesLabel:(NSInteger)currentMovesValue{
	// convert integer to string
	NSMutableString *movesString = [NSMutableString stringWithFormat:@"Moves: %d", currentMovesValue];
	// update the string in label
	currentMovesLabel.text = movesString;
}
	
-(void) updateScoreLabel:(NSInteger)currentScoreValue{
	// convert integer to string
	NSMutableString *scoreString = [NSMutableString stringWithFormat:@"Score: %d", currentScoreValue];
	// update the string in label
	currentScoreLabel.text = scoreString;
}

// If touch one of top disk: aLocation is the touch point location; aDisk is the diskImage
-(BOOL) touchInsideDisk:(UIImageView*)aDisk:(CGPoint)aLocation
{
	NSInteger xCenter = aDisk.center.x;
	NSInteger yCenter = aDisk.center.y;
	NSInteger xLoc = aLocation.x;
	NSInteger yLoc = aLocation.y;

	if (((xCenter - xLoc)*(xCenter - xLoc)+(yCenter - yLoc)*(yCenter - yLoc)) <=
		(miniWidth * miniWidth * 144))
	{
		return YES;
	}
	else {
		return NO;
	}
}

// get the minimum moves of any level
NSInteger getMinimumMoves(NSInteger iLevelNumber)
{
	NSInteger tempMoves = 1;
	for (NSInteger iIndex = 0; iIndex < iLevelNumber; iIndex ++) {
		tempMoves = tempMoves * 2;
	}
	return tempMoves - 1;
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// for the replay alert
	if (actionSheet.tag == 11) {
		// the user clicked the OK buttons
		if (buttonIndex == 0)
		{
			// Put all disks to pile A is diskLocation[i] = 0
			i = 0;
			do {
				diskLocation[i] = 0;
				i ++;
			} while (i < MAXLEVEL);
			currentMoves = 0; // no move at start
			[self initLevelNew:currentLevel];
		}
		else
		{
			NSLog(@"cancel");
		}		
	}
	else { // tag = 10 for the new game alert
		// the user clicked the OK buttons
		if (buttonIndex == 0)
		{
			NSLog(@"OK.");
			// fade out the 3 leaves menu
			[self fadeOut:leafMenu withDuration:3 andWait:0];
			// play game
			[self drawLeafAndPlay:actionSheet.tag];			
		}
		else
		{
			NSLog(@"cancel");
		}				
	}
}

// animate the leafdisk
- (void) animateLeafDisk:(UIImageView*)theView{	
	CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	pathAnimation.calculationMode = kCAAnimationPaced;
	pathAnimation.fillMode = kCAFillModeForwards;
	pathAnimation.removedOnCompletion = YES;
	pathAnimation.duration = 7.0; //4.0;
	pathAnimation.repeatCount = 1;
	
	// create a random number
	NSInteger myrand = rand()%129;
	NSLog(@"the random number is %d.", myrand);
//	NSInteger mydirect = myrand%4; // get 4 direction

	NSInteger mydirect = myrand%((currentLevel == 0)?1:currentLevel); // get 4 direction

	// draw a path
	CGPoint startPoint = CGPointMake(centerCoor[1][0], centerCoor[1][1]);
	CGPoint middlePoint1, middlePoint2, endPoint;
	NSInteger myAngle, myAngleRadian;
	if (currentLevel != 0) {
		myAngle = 360/currentLevel;
	}else {
		myAngle = 360;
	}

	myAngleRadian = degreesToRadian(myAngle);
	middlePoint1.x = 290*miniWidth/5 + 100*miniWidth/5*cos(myAngleRadian*mydirect);
	middlePoint1.y = 90*miniWidth/5 + 100*miniWidth/5*sin(myAngleRadian*mydirect);
	middlePoint2.x = 190*miniWidth/5 + 200*miniWidth/5*cos(myAngleRadian*mydirect);
	middlePoint2.y = 190*miniWidth/5 + 200*miniWidth/5*sin(myAngleRadian*mydirect);
	endPoint.x =	30*miniWidth/5 + myrand;
	endPoint.y =	- myrand;

/*	switch (mydirect) {
		case 0:
			middlePoint1.x = 190 + myrand;
			middlePoint1.y = 280 + myrand;
			middlePoint2.x = 200 - myrand;
			middlePoint2.y = 200 - myrand;
			endPoint.x =	30 + myrand;
			endPoint.y =	80 - myrand;
			break;
			
		case 1:
			middlePoint1.x = 190 + myrand;
			middlePoint1.y = 280 + myrand;
			middlePoint2.x = 200 + myrand;
			middlePoint2.y = 200 + myrand;
			endPoint.x =	30 + myrand;
			endPoint.y =	80 + myrand;
			break;
			
		case 2:
			middlePoint1.x = 190 - myrand;
			middlePoint1.y = 280 - myrand;
			middlePoint2.x = 200 + myrand;
			middlePoint2.y = 200 - myrand;
			endPoint.x =	30 - myrand;
			endPoint.y =	80 + myrand;
			break;
			
		case 3:
			middlePoint1.x = 190 - myrand;
			middlePoint1.y = 280 - myrand;
			middlePoint2.x = 200 - myrand;
			middlePoint2.y = 200 - myrand;
			endPoint.x =	30 - myrand;
			endPoint.y =	80 - myrand;
			break;
			
		default:
			break;
	}*/
	CGMutablePathRef curvedPath = CGPathCreateMutable();
	CGPathMoveToPoint(curvedPath, NULL, startPoint.x, startPoint.y);
	CGPathAddCurveToPoint(curvedPath, NULL, middlePoint1.x, middlePoint1.y, middlePoint2.x, middlePoint2.y, endPoint.x, endPoint.y);
	pathAnimation.path = curvedPath;
	CGPathRelease(curvedPath);
	

	[theView.layer addAnimation:pathAnimation forKey:@"moveTheLeafDisk"];
}

- (void)loadInitLevelNew:(NSNumber*)number
{
	NSInteger tempLevel = [number integerValue];
	UIImageView* tempImageView;

	for (i = 0; i < tempLevel - 1; i ++) {
		tempImageView = [leafDiskArray objectAtIndex:tempLevel-2];
	}
		
	[self fadeIn:bubblesLayer withDuration:2 andWait:0];
	[self initLevelNew:tempLevel];
}

- (void)passLevelAnimation:(NSInteger)level
{
	// fadeout bubbbles
	[self fadeOut:bubblesLayer withDuration:2 andWait:0];

	// get the location of disk(i+1)
	UIImageView* tempImageView;
	
	for (i = 0; i < level; i ++) {
		tempImageView = [leafDiskArray objectAtIndex:i];
		// hide numbers on leaf
		UIImageView *tempCenterNumber = (UIImageView*)[tempImageView viewWithTag:100];
		tempCenterNumber.alpha = 0;
		UIImageView *tempCornerNumber = (UIImageView*)[tempImageView viewWithTag:200];
		tempCornerNumber.alpha = 0;
		// animate the finished leaf
		[self animateLeafDisk:tempImageView];		
	}
	
	if (level == MAXLEVEL) 
	{	// start from level 1
		// todo: add special animation to this
		level = 1;
	}
	else
	{
		// go to next level
		level = level + 1;
	}
/*	// init the new level
	// Put all disks to pile A is diskLocation[i] = 0
	i = 0;
	do {
		diskLocation[i] = 0;
		i ++;
	} while (i < MAXLEVEL);*/
	currentMoves = 0; // no move at start
	// do animation of pass level
	NSLog(@"now level is %d.", level);

	// call method to hide the leafdisk after animation finished
	NSNumber *newLevel = [NSNumber numberWithInt:level];
	[self performSelector:@selector(loadInitLevelNew:) withObject:newLevel afterDelay:6.9];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint location = [touch locationInView:leafGameBackground];

	// search all the disks to see if touch any on top disk
	for (NSInteger iIndex = 0; iIndex < currentLevel; iIndex ++) 
	{
		// only look up on top disk
		if([self isThisDiskOnTop:iIndex] == YES)
		{	// if no disk is moving
			if (currentMoveDisk == -1)
			{
				// get the location of disk(iIndex+1)
				leafDisk = [leafDiskArray objectAtIndex:iIndex];

				// if touch inside this disk
				BOOL insideDisk = [self touchInsideDisk:leafDisk:location];
				if(insideDisk == YES)
				{	// move the disk center below touch finger 
					leafDisk.center = location;
					// get current moving disk number
					currentMoveDisk = iIndex;
					// get current from pile
					currentFromPile = diskLocation[iIndex];
				}
			}
			else // one disk is moving
			{
				// only move current moving disk
				if (currentMoveDisk == iIndex) 
				{
					// get the location of disk(iIndex+1)
					leafDisk = [leafDiskArray objectAtIndex:iIndex];
					// if touch inside this disk
					BOOL insideDisk = [self touchInsideDisk:leafDisk:location];

					if(insideDisk == YES)
					{	// move the disk center below touch finger 
						leafDisk.center = location;
					}
				}
			}
		}
	}
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
		[self touchesBegan:touches withEvent:event];
}

// calculate the touch release location to the pile center distance
// current release location
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if((currentMoveDisk >= 0) && (currentMoveDisk < MAXLEVEL))
	{
		// get the location of disk(i+1)
		UIImageView* tempImageView = [leafDiskArray objectAtIndex:currentMoveDisk];
		// get which pile near the disk
		int nearestPile = [self getNearestPile:tempImageView];
		// get the top disk number of this pile
		NSInteger topDisk = [self getTopDiskOfPile:nearestPile];
		// only put small disk to big disk or there is no disk on the pile
		if((topDisk == -1) || (currentMoveDisk <= topDisk))
		{
			// move the disk to nearest pile
			tempImageView.center = diskCenters[nearestPile];
			// save the disk to new locaion
			diskLocation[currentMoveDisk] = nearestPile;
			// increase the currentMoves only if move succeed
			if(currentFromPile != nearestPile)currentMoves = currentMoves + 1;
			// update the moves number
			[self updateMovesLabel:currentMoves];
			// no disk is moving now
			currentMoveDisk = -1;
			// save current level, moves, score and disks locations
			[self saveAllCurrentValue];
			
			// to see if finished this level after moved this disk
			// default value for level finish is YES
			BOOL levelFinished = YES;
			if(currentLevel == 0)levelFinished = NO;

			// Search from top to bottom. If any disk is not at pile B, 
			// this level is not finish yet.
			for (NSInteger iIndex = 0; iIndex < currentLevel; iIndex ++) {
				// if the disk is not at pile B
				if (diskLocation[iIndex] != 1){
					// not finish yet
					levelFinished = NO;
					// stop search
					break;
				}
			}
			// if finish this level, display some info and go to next level
			if(levelFinished == YES){
				// to see if use the minimum moves to pass this level
				NSInteger minimunMoves = getMinimumMoves(currentLevel);
				// calculate current score
				currentScore = currentScore + 10000 + minimunMoves - currentMoves;
				// before animation need update some data
				
				if (currentLevel == MAXLEVEL) 
				{
					currentLevel = 1;
				}
				else
				{
					// go to next level
					currentLevel = currentLevel + 1;
				}
				currentMoves = 0; // no move at start
				
				 // Put all disks to pile A is diskLocation[i] = 0
				 i = 0;
				 do {
				 diskLocation[i] = 0;
				 i ++;
				 } while (i < MAXLEVEL);
				// save all data
				
				[self saveAllCurrentValue];
				NSInteger tempLevel;
				if (currentLevel == 1) 
				{
					tempLevel = MAXLEVEL;
				}
				else
				{
					// go to next level
					tempLevel = currentLevel  - 1;
				}
				

				[self passLevelAnimation:tempLevel];
/*
				if (currentLevel == MAXLEVEL) 
				{	// start from level 1
					// todo: add special animation to this
					currentLevel = 1;
				}
				else
				{
					// go to next level
					currentLevel = currentLevel + 1;
				}
				// init the new level
				// Put all disks to pile A is diskLocation[i] = 0
				i = 0;
				do {
					diskLocation[i] = 0;
					i ++;
				} while (i < MAXLEVEL);
				currentMoves = 0; // no move at start
				// do animation of pass level
				[self initLevelNew:currentLevel];*/
				
				
				// play sound to tell user the level finished
				//Get the filename of the finish sound file:
				NSString *pathFinish = [NSString stringWithFormat:@"%@%@",
										[[NSBundle mainBundle] resourcePath],
										@"/windsilence.wav"];
				
				//declare a system sound id
				SystemSoundID soundIDFinish;
				
				//Get a URL for the sound file
				NSURL *filePathFinish = [NSURL fileURLWithPath:pathFinish isDirectory:NO];
				
				//Use audio sevices to create the sound
				AudioServicesCreateSystemSoundID((CFURLRef)filePathFinish, &soundIDFinish);
				
				//Use audio services to play the sound
				AudioServicesPlaySystemSound(soundIDFinish);
				
/*				if(currentMoves <= minimunMoves)// if use minimum moves, display "Perfect" message
				{
					// tell user this level finished
					UIAlertView* levelFinshAlertView = [[UIAlertView alloc] initWithTitle:@"Perfect!" message:@"You find the best way." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
					levelFinshAlertView.tag = 10;
					[levelFinshAlertView show];
					[levelFinshAlertView release];
				}
				else// if use more than minimum moves, display "Congratulations" message
				{
					// tell user this level finished
					UIAlertView* levelFinshAlertView = [[UIAlertView alloc] initWithTitle:@"Congratulations!" message:@"You pass this level." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
					levelFinshAlertView.tag = 10;
					[levelFinshAlertView show];
					[levelFinshAlertView release];
				}*/
			}
		}
		else { // there is some smaller disk on the pile
			// move disk to original pile
			tempImageView.center = diskCenters[currentFromPile];
			// no disk is moving now
			currentMoveDisk = -1;
		}
	/*	// play sound for every move
		//Get the filename of the move sound file:
		NSString *pathMove = [NSString stringWithFormat:@"%@%@",
							  [[NSBundle mainBundle] resourcePath],
							  @"/diskmove.wav"];
		
		//declare a system sound id
		SystemSoundID soundIDMove;
		
		//Get a URL for the sound file
		NSURL *filePathMove = [NSURL fileURLWithPath:pathMove isDirectory:NO];
		
		//Use audio sevices to create the sound
		AudioServicesCreateSystemSoundID((CFURLRef)filePathMove, &soundIDMove);
		
		//Use audio services to play the sound
		AudioServicesPlaySystemSound(soundIDMove);*/
	}
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// after pressed reset button in game view
-(void)gameResetButtonAction:(id)sender{
	NSLog(@"pressed game replay button.");
	UIAlertView *resetAlert = [[UIAlertView alloc] initWithTitle:@"Do you want to replay current level?" message:@"The Moves will be reset to ZERO." delegate:self
											   cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
	resetAlert.tag = 11;
	[resetAlert show];
	[resetAlert release];	
}

// after pressed back button in game view
-(void)gameBackButtonAction:(id)sender{
	// remove leafGameBackground
//	[leafGameBackground removeFromSuperview];
	leafGameBackground.alpha = 0;
	// fade in leafMenu
	[self fadeIn:leafMenu withDuration:3 andWait:0];
}

// Add 3 bubbles to bubble layer with characters A, B, C
- (void) addBubbblesToBubblesLayer:(UIView *)theBubbleLayer withTheIndex:(NSInteger)indexOfCharacters
{
	bubbleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble.png"]];
	[bubbleImage setFrame:CGRectMake(0, 0, BUBBLESIZE*miniWidth/5, BUBBLESIZE*miniWidth/5)];
	bubbleImage.center = CGPointMake(centerCoor[indexOfCharacters][0], centerCoor[indexOfCharacters][1]);
	[[chArray objectAtIndex:indexOfCharacters] setFrame:CGRectMake(0, 0, BUBBLESIZE*miniWidth/5, BUBBLESIZE*miniWidth/5)];
	[bubbleImage addSubview:[chArray objectAtIndex:indexOfCharacters]];
	[self newspinLayer:bubbleImage.layer];
	[theBubbleLayer addSubview:bubbleImage];
}

- (void) drawLeafAndPlay:(NSInteger)buttonPressed
{
	currentLevel = 1;
	// press new game button, start from level 1
	if (buttonPressed == 1) {
		// Put all disks to pile A is diskLocation[i] = 0
		i = 0;
		do {
			diskLocation[i] = 0;
			i ++;
		} while (i < MAXLEVEL);
		currentMoves = 0; // no move at start
		currentScore = 0;
		[self initLevelNew:currentLevel];
	}
	else {// read from saved file
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		currentLevel = [prefs integerForKey:@"savedCurrentLevel"];
		currentMoves = [prefs integerForKey:@"savedCurrentMoves"];
		currentScore = [prefs integerForKey:@"savedCurrentScore"];
		if(currentLevel == 0)currentLevel = 1;
		diskLocation[0] = [prefs integerForKey:@"savedDiskLocation0"];
		diskLocation[1] = [prefs integerForKey:@"savedDiskLocation1"];
		diskLocation[2] = [prefs integerForKey:@"savedDiskLocation2"];
		diskLocation[3] = [prefs integerForKey:@"savedDiskLocation3"];
		diskLocation[4] = [prefs integerForKey:@"savedDiskLocation4"];
		diskLocation[5] = [prefs integerForKey:@"savedDiskLocation5"];
		diskLocation[6] = [prefs integerForKey:@"savedDiskLocation6"];
		diskLocation[7] = [prefs integerForKey:@"savedDiskLocation7"];
		diskLocation[8] = [prefs integerForKey:@"savedDiskLocation8"];
		diskLocation[9] = [prefs integerForKey:@"savedDiskLocation9"];
		diskLocation[10] = [prefs integerForKey:@"savedDiskLocation10"];
		diskLocation[11] = [prefs integerForKey:@"savedDiskLocation11"];
		[self initLevelNew:currentLevel];
	}
	
	// fade in the play layer
	[self fadeIn:leafGameBackground withDuration:3 andWait:0];
}


- (void) drawBackground:(NSInteger)backgroundalpha
{
	// create leafGameBackground subview and add everything to it
	leafGameBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
	leafGameBackground.alpha = backgroundalpha;
	[mainMenu addSubview:leafGameBackground];
	
	// set 3 piles center x, y coordinates // fonts Arial Courier New Georgia Helvetica Marker Felt Times New Roman Trebuchet MS
	centerCoor[0][0] = miniWidth * 13;  // ipod  5*48=240, ipad 12*48=576
	centerCoor[0][1] = miniHeight * 6; // ipod 15*22=330, ipad 32*22=704
	centerCoor[1][0] = miniWidth * 13;  // ipod  5*32=160, ipad 12*32=384
	centerCoor[1][1] = miniHeight * 16; // ipod 15*13=195, ipad 32*13=416
	centerCoor[2][0] = miniWidth * 36;  // ipod  5*16=80,  ipad 12*16=192
	centerCoor[2][1] = miniHeight * 11; // ipod 15*22=330, ipad 32*22=704

	// add level label
	currentLevelLabel = [[UILabel alloc] initWithFrame:CGRectMake(miniWidth*50, miniHeight*3, miniWidth*16, 24*miniWidth/5)];
	currentLevelLabel.textAlignment = UITextAlignmentLeft;
	currentLevelLabel.textColor = [UIColor yellowColor];
	currentLevelLabel.shadowColor = [UIColor blackColor];
	currentLevelLabel.shadowOffset = CGSizeMake(1,1);
	(currentLevelLabel).font =  [UIFont  fontWithName:@"Zapfino" size:12.0*miniWidth/5];
	currentLevelLabel.backgroundColor = [UIColor clearColor];
	currentLevelLabel.transform = CGAffineTransformRotate(currentLevelLabel.transform, degreesToRadian(90));
	if(DEVELOP_MODE == 1)[self updateLevelLabel:11];	
	[leafGameBackground addSubview:currentLevelLabel];
	
	// add moves label
	currentMovesLabel = [[UILabel alloc] initWithFrame:CGRectMake(miniWidth*36, miniHeight*6, miniWidth*34, 24*miniWidth/5)];
	currentMovesLabel.textAlignment = UITextAlignmentLeft;
	currentMovesLabel.textColor = [UIColor yellowColor];
	currentMovesLabel.shadowColor = [UIColor blackColor];
	currentMovesLabel.shadowOffset = CGSizeMake(1,1);
	(currentMovesLabel).font =  [UIFont  fontWithName:@"Zapfino" size:12.0*miniWidth/5];
	currentMovesLabel.backgroundColor = [UIColor clearColor];
	currentMovesLabel.transform = CGAffineTransformRotate(currentMovesLabel.transform, degreesToRadian(90));
	if(DEVELOP_MODE == 1)[self updateMovesLabel:123456];	
	[leafGameBackground addSubview:currentMovesLabel];
	
	// add score label
	currentScore = 0;
	currentScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(miniWidth*31, miniHeight*6, miniWidth*34, 24*miniWidth/5)];
	currentScoreLabel.text = @"0";
	currentScoreLabel.textAlignment = UITextAlignmentLeft;
	currentScoreLabel.textColor = [UIColor yellowColor];
	currentScoreLabel.shadowColor = [UIColor blackColor];
	currentScoreLabel.shadowOffset = CGSizeMake(1,1);
	(currentScoreLabel).font =  [UIFont  fontWithName:@"Zapfino" size:12.0*miniWidth/5];
	currentScoreLabel.backgroundColor = [UIColor clearColor];
	currentScoreLabel.transform = CGAffineTransformRotate(currentScoreLabel.transform, degreesToRadian(90));
	if(DEVELOP_MODE == 1)[self updateScoreLabel:654321];	
	[leafGameBackground addSubview:currentScoreLabel];
	
	// add bubbles layer to leafGameBackground layer
	bubblesLayer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
	[leafGameBackground addSubview:bubblesLayer];
	[bubblesLayer release];
	// add 3 bubbles to the layer and spin
	// use array
	NSArray *characterArray = [NSArray arrayWithObjects:
							   [UIImage imageNamed:@"characterA.png"],
							   [UIImage imageNamed:@"characterB.png"],
							   [UIImage imageNamed:@"characterC.png"],
							   nil];
	
	chArray = [[NSMutableArray alloc] init];
	for (i=0; i<NUMPILES; i++) {
		[chArray addObject:[[UIImageView alloc] initWithImage:[characterArray objectAtIndex:i]]];
		[self addBubbblesToBubblesLayer:bubblesLayer withTheIndex:i];
	}
	
	// add gamereplay image
	gameResetButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain ];
//	gameResetButton.frame = CGRectMake(20, 320, 40, 40);
	gameResetButton.frame = CGRectMake(20*miniWidth/5, 320*miniHeight/15, 40*miniWidth/5, 40*miniWidth/5);
	[gameResetButton setBackgroundImage:[UIImage imageNamed:@"gamereplay.png"] forState:UIControlStateNormal];
	gameResetButton.tag = 2;
	[gameResetButton addTarget:self action:@selector(gameResetButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[gameResetButton release];
	[leafGameBackground addSubview:gameResetButton];			
	
	// add gameback image
	gameBackButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain ];
//	gameBackButton.frame = CGRectMake(20, 400, 40, 40);
	gameBackButton.frame = CGRectMake(20*miniWidth/5, 400*miniHeight/15, 40*miniWidth/5, 40*miniWidth/5);
	[gameBackButton setBackgroundImage:[UIImage imageNamed:@"gameback.png"] forState:UIControlStateNormal];
	gameBackButton.tag = 1;
	[gameBackButton addTarget:self action:@selector(gameBackButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[gameBackButton release];
	[leafGameBackground addSubview:gameBackButton];
	/*
	gameBackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	gameBackButton.frame = CGRectMake(20, 320, 40, 40);
	[gameBackButton setTitle:@"back" forState:UIControlStateNormal];
	[gameBackButton addTarget:self action:@selector(gameBackButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[leafGameBackground addSubview:gameBackButton];
*/
	
	
	// add array of 12 leaf disks
	i = 0;
	do {
		diskCenters[i] = CGPointMake(centerCoor[i][0], centerCoor[i][1]);
		i ++;
	} while (i < 3);
	
	leafDiskArray = [[NSMutableArray alloc] init];
	NSMutableString *levelString;
	NSInteger newValue;
	// set the location of corner number
	if ((hardwareName == 0) || (hardwareName == 1)) // for ipod
	{
		cornerNumberLocation[0][0] = 87;
		cornerNumberLocation[0][1] = 75;
		cornerNumberLocation[1][0] = 70;
		cornerNumberLocation[1][1] = 93;
		cornerNumberLocation[2][0] = 45;
		cornerNumberLocation[2][1] = 98;
		cornerNumberLocation[3][0] = 18;
		cornerNumberLocation[3][1] = 93;
		cornerNumberLocation[4][0] = 3;
		cornerNumberLocation[4][1] = 75;
		cornerNumberLocation[5][0] = 0;
		cornerNumberLocation[5][1] = 52;
		cornerNumberLocation[6][0] = 3;
		cornerNumberLocation[6][1] = 29;
		cornerNumberLocation[7][0] = 18;
		cornerNumberLocation[7][1] = 12;
		cornerNumberLocation[8][0] = 45;
		cornerNumberLocation[8][1] = 3;
		cornerNumberLocation[9][0] = 70;
		cornerNumberLocation[9][1] = 6;
		cornerNumberLocation[10][0] = 87;
		cornerNumberLocation[10][1] = 23;
		cornerNumberLocation[11][0] = 95;
		cornerNumberLocation[11][1] = 47;		
	}
	else 
	{
		cornerNumberLocation[0][0] = 209;
		cornerNumberLocation[0][1] = 180;
		cornerNumberLocation[1][0] = 168;
		cornerNumberLocation[1][1] = 223;
		cornerNumberLocation[2][0] = 108;
		cornerNumberLocation[2][1] = 235;
		cornerNumberLocation[3][0] = 43;
		cornerNumberLocation[3][1] = 223;
		cornerNumberLocation[4][0] = 7;
		cornerNumberLocation[4][1] = 180;
		cornerNumberLocation[5][0] = 0;
		cornerNumberLocation[5][1] = 125;
		cornerNumberLocation[6][0] = 7;
		cornerNumberLocation[6][1] = 70;
		cornerNumberLocation[7][0] = 43;
		cornerNumberLocation[7][1] = 26;
		cornerNumberLocation[8][0] = 108;
		cornerNumberLocation[8][1] = 7;
		cornerNumberLocation[9][0] = 168;
		cornerNumberLocation[9][1] = 14;
		cornerNumberLocation[10][0] = 209;
		cornerNumberLocation[10][1] = 55;
		cornerNumberLocation[11][0] = 228;
		cornerNumberLocation[11][1] = 113;
	}
	
	// add 12 number to leaves
	for (i=0; i<12; i++) 
	{	// add leaf image
		mapleLeafLong = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"leaflong.png"]];
		if ((hardwareName == 0) || (hardwareName == 1)) // for ipod
			[mapleLeafLong setFrame:CGRectMake(37,23,46,75)];
		else { // for ipad
//			[mapleLeafLong setFrame:CGRectMake(98,70,98,170)];
			[mapleLeafLong setFrame:CGRectMake(94,62,98,170)];
		}
		newValue = 315 + 30*i;
		mapleLeafLong.transform = CGAffineTransformRotate(mapleLeafLong.transform, degreesToRadian(newValue));
		// add number in center
		numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(30*miniWidth/5, 30*miniWidth/5, CENTERNUMBERSIZE*miniWidth/5, CENTERNUMBERSIZE*miniWidth/5)];
		numberLabel.textAlignment = UITextAlignmentCenter;
		numberLabel.textColor = [UIColor yellowColor];
		numberLabel.shadowColor = [UIColor blackColor];
		numberLabel.shadowOffset = CGSizeMake(1,1);
		(numberLabel).font =  [UIFont  fontWithName:@"Arial" size:36.0*miniWidth/5];
		numberLabel.backgroundColor = [UIColor clearColor];
		levelString = [NSMutableString stringWithFormat:@"%d", i+1];
		numberLabel.text = levelString;
		numberLabel.tag = 100;
		numberLabel.transform = CGAffineTransformRotate(numberLabel.transform, degreesToRadian(90));
		// add number in corner
		mininumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(cornerNumberLocation[i][0], cornerNumberLocation[i][1], CORNERNUMBERSIZE*miniWidth/5, CORNERNUMBERSIZE*miniWidth/5)];
		mininumberLabel.textAlignment = UITextAlignmentLeft;
		mininumberLabel.textColor = [UIColor yellowColor];
		mininumberLabel.shadowColor = [UIColor blackColor];
		mininumberLabel.shadowOffset = CGSizeMake(1,1);
		(mininumberLabel).font =  [UIFont  fontWithName:@"Arial" size:24.0*miniWidth/5];
		mininumberLabel.backgroundColor = [UIColor clearColor];
		levelString = [NSMutableString stringWithFormat:@"%d", i+1];
		mininumberLabel.text = levelString;
		mininumberLabel.tag = 200;
		mininumberLabel.transform = CGAffineTransformRotate(mininumberLabel.transform, degreesToRadian(90));
		// add leaf, center number, corner number to leaf view
		leafDisk = [[UIView alloc] initWithFrame:CGRectMake(0, 0, LEAFDISKSIZE*miniWidth/5, LEAFDISKSIZE*miniWidth/5)];
		[leafDisk addSubview:mapleLeafLong];
		[leafDisk addSubview:numberLabel];
		[leafDisk addSubview:mininumberLabel];
		// add leaf view to array
		[leafDiskArray addObject:leafDisk];
	}
}

// button pressed animation: remove leaves and buttons
-(void)removeButtonAction:(id)sender {
	// read if already has saved data
	NSInteger templevel;
	UIButton *theButton = (UIButton *)sender;
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	templevel = [prefs integerForKey:@"savedCurrentScore"];
	if ((templevel >= 1)&&(theButton.tag == 1)) 
	{
		NSLog(@"new game but has data. savedCurrentScore = %d.", templevel);
		// ask if user want to erase old data
		UIAlertView *resetAlert = [[UIAlertView alloc] initWithTitle:@"You have saved score. Do you want to erase it?" message:@"If you press OK, all the score will be lost." delegate:self
												   cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
		resetAlert.tag = theButton.tag; // send 1 or 2 to alert window
		[resetAlert show];
		[resetAlert release];
		
	}
	else 
	{
		NSLog(@"game button is %d, savedCurrentScore = %d.", theButton.tag, templevel);
		// fade out the 3 leaves menu
		[self fadeOut:leafMenu withDuration:3 andWait:0];
		// play game
		[self drawLeafAndPlay:theButton.tag];
	}
}

// after pressed back button in help view
-(void)helpBackButtonAction:(id)sender{
	// Change the help layer to transparent
	helpViewLayer.alpha = 0;
	// fade in leafMenu
	[self fadeIn:leafMenu withDuration:3 andWait:0];
}

- (void) dohelpthing
{
	// create helpViewLayer subview and add textview and a button to it
	helpViewLayer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
	helpViewLayer.alpha = 0;
	[mainMenu addSubview:helpViewLayer];
	[helpViewLayer release];
	
	// add helpBackButton image
	helpBackButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain ];
//	helpBackButton.frame = CGRectMake(20, 400, 40, 40);
	helpBackButton.frame = CGRectMake(20*miniWidth/5, 400*miniHeight/15, 40*miniWidth/5, 40*miniWidth/5);
	[helpBackButton setBackgroundImage:[UIImage imageNamed:@"gameback.png"] forState:UIControlStateNormal];
	helpBackButton.tag = 1;
	[helpBackButton addTarget:self action:@selector(helpBackButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[helpBackButton release];
	[helpViewLayer addSubview:helpBackButton];			

	// add webview
	UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320*miniWidth/5, 320*miniWidth/5)];
	webView.backgroundColor = [UIColor redColor];
	webView.scalesPageToFit = YES;

	NSString *html = @"<html><head><style type=\"text/css\"> body {font-family:helvetica;; font-size: 40;  color:rgb(0, 0, 0);}</style></head>\
    <center><h1>BirdView Hanoi v2.3</h1> \
    <h4>12 levels total</h4> <h4>copyright 2010-2011 Safety By Watching Inc.</h4> \
	<h4>ALL RIGHTS RESERVED.</h4> \
	<a href=\"http://www.safetybywatching.com\">www.safetybywatching.com</a> \
	<h2>HELP</h2> <h3>GOAL</h3></center><p>Move all the maple leaves from bubble A to bubble B.</p> \
	<center><h3>RULES</h3></center><p> 1. Only one leaf may be moved at a time.</p> \
	<p> 2. Only leaf with small number can be placed on top of leaf with big number.</p> \
	<center><h3> Minimum moves to pass each level</h3> \
	<pre><p>  Level       Minimum Moves </br> \
	1                1</br> \
	2                3</br> \
	3                7</br> \
	4               15</br> \
	5               31</br> \
	6               63</br> \
	7              127</br> \
	8              255</br> \
	9              511</br> \
	10            1023</br> \
	11            2047</br> \
	12            4095</br> \
	<h3> Why birdview hanoi?</h3></center> \
	<p>This tower of hanoi game is the first and only one that use birdview since November 2010. The answer is \
	birdview make it easy to finish every level by minimum moves. You can read the instruction on the website:</p> \
	<a href=\"http://www.safetybywatching.com\">www.safetybywatching.com</a> \
	<center><h2>CREDITS</h2> \
	<p> -- Producer -- </p> \
	<p> ZHENGYOU LIU </p> \
	<p> -- Designer -- </p> \
	<p> NAN JIANG </p> \
	<p> JIE YAN </p> \
	<p> -- Programmer -- </p> \
	<p> JIE YAN </p> \
	<p> -- Tester -- </p> \
	<p> XIAOHAN YAN </p> \
	<p> -- Music -- </p> \
	<p> Title: The autumn of maple </p> \
	<p> Author: JIE YAN </p> \
	<p> -- Background -- </p> \
	<p> The picture of background and start up animation are based on Qzone skin. </p> \
	</center> \
	<p> The qzone are trademarks of Tencent Holdings Limited. </p> \
	</html>";
	
	
	[webView loadHTMLString:html baseURL:[NSURL URLWithString:@"http://www.safetybywatching.com/hanoi.html"]];
	webView.transform = CGAffineTransformRotate(webView.transform, degreesToRadian(90));

	scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 40*miniHeight/15, 320*miniWidth/5, 320*miniWidth/5)];
	scrollView.contentSize = CGSizeMake(scrollView.frame.size.width + 700*miniWidth/5, scrollView.frame.size.height);
	scrollView.showsHorizontalScrollIndicator = YES;
	scrollView.showsVerticalScrollIndicator = NO;
	scrollView.alpha = 0.8;
	scrollView.backgroundColor = [UIColor whiteColor];

	
	[scrollView addSubview:webView];

	[helpViewLayer addSubview:scrollView];
	if (DEVELOP_MODE == 1)
		[self fadeIn:helpViewLayer withDuration:0 andWait:0];

	
}

// after press help button, open help view with a back button
-(void)helpButtonAction:(id)sender{
	// fade out the 3 leaves menu
	[self fadeOut:leafMenu withDuration:3 andWait:0];
	// fade in the help layer
	[self fadeIn:helpViewLayer withDuration:3 andWait:0];
}

-(void)fadeOut:(UIView*)viewToDissolve withDuration:(NSTimeInterval)duration 
	   andWait:(NSTimeInterval)wait
{
	[UIView beginAnimations: @"Fade Out" context:nil];
	[UIView setAnimationDelay:wait];
	[UIView setAnimationDuration:duration];
	viewToDissolve.alpha = 0.0;
	[UIView commitAnimations];
}

-(void)fadeIn:(UIView*)viewToFadeIn withDuration:(NSTimeInterval)duration 
	  andWait:(NSTimeInterval)wait
{
	[UIView beginAnimations: @"Fade In" context:nil];
	[UIView setAnimationDelay:wait];
	[UIView setAnimationDuration:duration];
	viewToFadeIn.alpha = 1;
	[UIView commitAnimations];
}

// fade in company logo, then call fade out company logo
-(void)fadeInCompany:(UIView*)viewToFadeIn withDuration:(NSTimeInterval)duration 
	  andWait:(NSTimeInterval)wait
{
	[UIView beginAnimations: @"Fade In Company" context:nil];
	[UIView setAnimationDelay:wait];
	[UIView setAnimationDuration:duration];
	viewToFadeIn.alpha = 1;
	[UIView commitAnimations];
	[self performSelector:@selector(fadeOutCompany:) withObject:viewToFadeIn afterDelay:13.0];
}

// fade out company logo, then call 3 leaves
- (void)fadeOutCompany:(UIView*)viewToDissolve
{
	[UIView beginAnimations: @"Fade Out Company" context:nil];
	[UIView setAnimationDelay:0];
	[UIView setAnimationDuration:3];
	viewToDissolve.alpha = 0.0;
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(popUpMainMenu:finished:context:)];
	[UIView commitAnimations];
}

- (void) animateDotAlongCircle:(NSString *)dotfilename
						dotSize:(NSInteger)iSize
					  atCenterX:(NSInteger)xLocation 
					  atCenterY:(NSInteger)yLocation
					  theRadius:(NSInteger)rRadius
						atSpeed:(float)rSpeed
{
	//Prepare the animation - we use keyframe animation for animations of this complexity
	CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	//Set some variables on the animation
	pathAnimation.calculationMode = kCAAnimationPaced;
	//We want the animation to persist - not so important in this case - but kept for clarity
	//If we animated something from left to right - and we wanted it to stay in the new position, 
	//then we would need these parameters
	pathAnimation.fillMode = kCAFillModeForwards;
	pathAnimation.removedOnCompletion = NO;
	pathAnimation.duration = rSpeed; //4.0;
	//Lets loop continuously for the demonstration
	pathAnimation.repeatCount = 10000;
	
	// draw a circle
	CGRect mybound=CGRectMake(xLocation-rRadius, yLocation-rRadius, rRadius*2, rRadius*2);
	CGMutablePathRef curvedPath = CGPathCreateMutable();
	CGPathAddEllipseInRect(curvedPath, NULL, mybound);
	//Now we have the path, we tell the animation we want to use this path - then we release the path
	pathAnimation.path = curvedPath;
	CGPathRelease(curvedPath);
	
	dot1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dotfilename]];
	[dot1 setFrame:CGRectMake(0,0,iSize,iSize)];
	[mainMenu addSubview:dot1];
	[self fadeOut:dot1 withDuration:0 andWait:0];
	[self fadeIn:dot1 withDuration:7 andWait:0];

	//Add the animation to the circleView - once you add the animation to the layer, the animation starts
	[dot1.layer addAnimation:pathAnimation forKey:@"moveTheSquare"];
}

// animate the 3 leaves to 3 locations
- (void) animateLeafToScreen:(NSString*)dotfilename location:(NSInteger)location{	
	//Prepare the animation - we use keyframe animation for animations of this complexity
	CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	//Set some variables on the animation
	pathAnimation.calculationMode = kCAAnimationPaced;
	//We want the animation to persist - not so important in this case - but kept for clarity
	//If we animated something from left to right - and we wanted it to stay in the new position, 
	//then we would need these parameters
	pathAnimation.fillMode = kCAFillModeForwards;
	pathAnimation.removedOnCompletion = NO;
	pathAnimation.duration = 4.0; //4.0;
	//Lets loop continuously for the demonstration
	pathAnimation.repeatCount = 1;
	
	// draw a path
//	CGPoint startPoint = CGPointMake(200.0f, 600.0f);
//	CGPoint endPoint = CGPointMake(60.0f, location*100.0f);
	CGPoint startPoint = CGPointMake(200.0f*miniWidth/5, 600.0f*miniWidth/5);
	CGPoint endPoint = CGPointMake(60.0f*miniWidth/5, location*100.0f*miniWidth/5);
	CGMutablePathRef curvedPath = CGPathCreateMutable();
	CGPathMoveToPoint(curvedPath, NULL, startPoint.x, startPoint.y);
//	CGPathAddCurveToPoint(curvedPath, NULL, 100, 300, 0, 250, endPoint.x, endPoint.y);
	CGPathAddCurveToPoint(curvedPath, NULL, 100*miniWidth/5, 300*miniWidth/5, 0, 250*miniWidth/5, endPoint.x, endPoint.y);
	pathAnimation.path = curvedPath;
	CGPathRelease(curvedPath);
	
	mapleLeaf = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dotfilename]];
//	[mapleLeaf setFrame:CGRectMake(0,0,100,100)];
	[mapleLeaf setFrame:CGRectMake(0,0,100*miniWidth/5,100*miniWidth/5)];
	[leafMenu addSubview:mapleLeaf];
	[mapleLeaf release];
	
	//Add the animation to the circleView - once you add the animation to the layer, the animation starts
	[mapleLeaf.layer addAnimation:pathAnimation forKey:@"moveTheMapleLeaf"];
	// wrap with NSNumber
	NSNumber *newLocation = [NSNumber numberWithInt:location];
	[self performSelector:@selector(AddButtonToLeaf:) withObject:newLocation afterDelay:5.0];
}

// Add button to 3 leaves
- (void) AddButtonToLeaf:(NSNumber*)newlocation{
	switch ([newlocation integerValue]) {
		case 1://display menu item "new game"
			newGameButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain ];
//			newGameButton.frame = CGRectMake(20, 60, 80, 80);
			newGameButton.frame = CGRectMake(20*miniWidth/5, 60*miniWidth/5, 80*miniWidth/5, 80*miniWidth/5);
			[newGameButton setBackgroundImage:[UIImage imageNamed:@"newgame.png"] forState:UIControlStateNormal];
			newGameButton.tag = 1;
			[newGameButton addTarget:self action:@selector(removeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
			
			[newGameButton release];
			[leafMenu addSubview:newGameButton];			
			break;

		case 2://display menu item "saved game"
			continueButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain ];
//			continueButton.frame = CGRectMake(20, 160, 80, 80);
			continueButton.frame = CGRectMake(20*miniWidth/5, 160*miniWidth/5, 80*miniWidth/5, 80*miniWidth/5);
			[continueButton setBackgroundImage:[UIImage imageNamed:@"savedgame.png"] forState:UIControlStateNormal];
			continueButton.tag = 2;
			[continueButton addTarget:self action:@selector(removeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
			[continueButton release];
			[leafMenu addSubview:continueButton];			
			break;

		case 3://display menu item "help"
			helpButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain ];
//			helpButton.frame = CGRectMake(20, 260, 80, 80);
			helpButton.frame = CGRectMake(20*miniWidth/5, 260*miniWidth/5, 80*miniWidth/5, 80*miniWidth/5);
			[helpButton setBackgroundImage:[UIImage imageNamed:@"helpcredit.png"] forState:UIControlStateNormal];
			helpButton.tag = 3;
			[helpButton addTarget:self action:@selector(helpButtonAction:) forControlEvents:UIControlEventTouchUpInside];
			[helpButton release];
			[leafMenu addSubview:helpButton];			
			break;
			
		default:
			break;
	}
}

- (void)popUpMainMenu:(NSString*)animationID finished:(BOOL)finished context:(void*)context{
	// remove leaf and company logo subview from super view - mainmenu view. Do not need them anymore.
	[mapleLeaf removeFromSuperview];
	[company removeFromSuperview];

	// create leaf menu subview and add 3 leaves to it
	leafMenu = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
	[mainMenu addSubview:leafMenu];
	[leafMenu release];
	
	// load leaf image
	[self animateLeafToScreen:@"leaf.png" location: 1];
	[self animateLeafToScreen:@"leaf.png" location: 2];
	[self animateLeafToScreen:@"leaf.png" location: 3];
}

// animate maple leaf along path in and out
- (void) animateLeafAlongPath:(CALayer *)inLayer 
{
	//Prepare the animation - we use keyframe animation for animations of this complexity
	CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	pathAnimation.calculationMode = kCAAnimationPaced;
	pathAnimation.fillMode = kCAFillModeForwards;
	pathAnimation.removedOnCompletion = NO;
	pathAnimation.duration = 11.0; //4.0;
	pathAnimation.repeatCount = 1;
	
	NSInteger myint1 = 1600;
	NSInteger myint2 = 3020;
	NSInteger myint3 = 100;
	NSInteger myint4 = 250;
	NSInteger myint5 = 2020;
	NSInteger myint6 = 50;
	NSInteger myint7 = 400;
	NSInteger myint8 = 200;
	NSInteger myint9 = 300;

	
/*	if ((hardwareName == 0) || (hardwareName == 1)) // for ipod
	{
		CGPoint startPoint = CGPointMake(1600.0f, 3020.0f);
		CGPoint middlePoint = CGPointMake(100.0f, 250.0f);
		CGPoint endPoint = CGPointMake(-100.0f, -2020.0f);
		CGMutablePathRef curvedPath = CGPathCreateMutable();
		CGPathMoveToPoint(curvedPath, NULL, startPoint.x, startPoint.y);
		CGPathAddCurveToPoint(curvedPath, NULL, 50, 400, 50, 200, middlePoint.x, middlePoint.y);
		CGPathAddCurveToPoint(curvedPath, NULL, 100, 300, 0, 250, endPoint.x, endPoint.y);
		
	}
	else {*/
		CGPoint startPoint = CGPointMake(myint1*miniWidth/5, myint2*miniWidth/5);
		CGPoint middlePoint = CGPointMake(myint3*miniWidth/5, myint4*miniWidth/5);
		CGPoint endPoint = CGPointMake(-myint3*miniWidth/5, -myint5*miniWidth/5);
		CGMutablePathRef curvedPath = CGPathCreateMutable();
		CGPathMoveToPoint(curvedPath, NULL, startPoint.x, startPoint.y);
		CGPathAddCurveToPoint(curvedPath, NULL, myint6*miniWidth/5, myint7*miniWidth/5, myint6*miniWidth/5, myint8*miniWidth/5, middlePoint.x, middlePoint.y);
		CGPathAddCurveToPoint(curvedPath, NULL, myint3*miniWidth/5, myint9*miniWidth/5, 0, myint4*miniWidth/5, endPoint.x, endPoint.y);		
//	}



	pathAnimation.path = curvedPath;
	CGPathRelease(curvedPath);
	
	[inLayer addAnimation:pathAnimation forKey:@"moveTheLeaf"];
}

// spin method 1 start +++
// rotate the view of image
// setAnimationCurve: UIViewAnimationCurveEaseInOut
// UIViewAnimationCurveEaseIn
// UIViewAnimationCurveEaseOut
// UIViewAnimationCurveLinear
// 
- (void)rotateImage:(UIImageView *)image duration:(NSTimeInterval)duration curve:(int)curve degrees:(CGFloat)degrees
{
	// Setup the animation
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:duration];
	[UIView setAnimationCurve:curve];
	[UIView setAnimationDelay:8];
	[UIView setAnimationBeginsFromCurrentState:YES];
	
	// The transform matrix
	CGAffineTransform transform = CGAffineTransformMakeRotation(degreesToRadian(degrees));
	image.transform = transform;
	// Commit the changes
	[self.view addSubview:image];

	[UIView commitAnimations];	
}
// spin method 1 end ---

// spin method 2 start +++
// rotate the one layer includes several images
- (void)spinLayer:(CALayer *)inLayer duration:(CFTimeInterval)inDuration direction:(int)direction
{
	CABasicAnimation* rotationAnimation;
	// Rotate about the z axis
	rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	
	// Rotate 360 degrees, in direction specified
	rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0 * direction];
	
	// Perform the rotation over this many seconds
	rotationAnimation.duration = inDuration;
	
	// Set the pacing of the animation
	rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	// Add animation to the layer and make it so
	[inLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

// spin method 2 end ---

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	// get the screen bounds, support ipad and HD ipod/iphone
	CGSize s = [[UIScreen mainScreen] bounds].size;
    screenWidth = s.width; // ipod is 320/640, ipad is 768
    screenHeight = s.height; // ipod is 480/960, ipad is 1024
	miniWidth = screenWidth/64; // ipod is 5/10, ipad is 12
	miniHeight = screenHeight/32; // ipod is 15/30, ipad is 24
	if (((screenWidth == 320) && (screenHeight == 480)) || ((screenWidth == 480) && (screenHeight == 320))) {
		hardwareName =0;
	}
	else if (((screenWidth == 640) && (screenHeight == 960)) || ((screenWidth == 960) && (screenHeight == 640))){
		hardwareName = 1;
	}
	else if (((screenWidth == 768) && (screenHeight == 1024)) || ((screenWidth == 1024) && (screenHeight == 768))){
		hardwareName = 2;
	}

	NSLog(@"new screenWidth is %d, screenHeight = %d.", screenWidth, screenHeight);
	NSLog(@"miniWidth is %d, miniHeight = %d. hardwareName = %d.", miniWidth, miniHeight, hardwareName);

	// play start up music
	//Get the filename of the sound file:
	NSString *pathFinish = [NSString stringWithFormat:@"%@%@",
							[[NSBundle mainBundle] resourcePath],
							@"/maple.wav"];
	
	//declare a system sound id
	SystemSoundID soundIDFinish;
	
	//Get a URL for the sound file
	NSURL *filePathFinish = [NSURL fileURLWithPath:pathFinish isDirectory:NO];
	
	//Use audio sevices to create the sound
	AudioServicesCreateSystemSoundID((CFURLRef)filePathFinish, &soundIDFinish);
	
	//Use audio services to play the sound
	AudioServicesPlaySystemSound(soundIDFinish);

	
	// create the root window content view, full screen
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];

	// background image view
	mainMenu = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backall.png"]];
	[mainMenu setFrame:CGRectMake(0,0,screenWidth, screenHeight)];
	mainMenu.alpha = 0.0;
	[mainMenu setUserInteractionEnabled:YES];
	// add the background to root view
	[self.view addSubview:mainMenu];
	// fade in the 
	[self fadeIn:mainMenu withDuration:7 andWait:0];


/*	// load main menu image
	if (hardwareName == 0) {
		mainMenu = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu.png"]];
	}
	else if (hardwareName == 1)
	{
		mainMenu = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu@2x.png"]];
	}
	else
	{
		mainMenu = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu@2a.png"]];
	}*/


	if (DEVELOP_MODE == 1)
	{
		[self drawBackground:1];
		[self initLevelNew:12];
//		[self dohelpthing];
	}
	else {
		if ((hardwareName == 0) || (hardwareName == 1)) // for ipod
		{
			[self animateDotAlongCircle:@"dot-2.png" dotSize:30 atCenterX:20 atCenterY:20 theRadius:3 atSpeed:2.8];
			[self animateDotAlongCircle:@"dot-2.png" dotSize:40 atCenterX:70 atCenterY:100 theRadius:3 atSpeed:3.2];
			[self animateDotAlongCircle:@"dot-2.png" dotSize:50 atCenterX:0 atCenterY:120 theRadius:3 atSpeed:3.1];
			[self animateDotAlongCircle:@"dot-2.png" dotSize:55 atCenterX:40 atCenterY:180 theRadius:3 atSpeed:3.3];
			[self animateDotAlongCircle:@"dot-2.png" dotSize:25 atCenterX:40 atCenterY:210 theRadius:3 atSpeed:3.2];
		
			[self animateDotAlongCircle:@"dot-11.png" dotSize:50 atCenterX:220 atCenterY:50 theRadius:2 atSpeed:3.2];
			[self animateDotAlongCircle:@"dot-11.png" dotSize:30 atCenterX:90 atCenterY:150 theRadius:3 atSpeed:2.9];
			[self animateDotAlongCircle:@"dot-11.png" dotSize:60 atCenterX:160 atCenterY:250 theRadius:3 atSpeed:3.0];
			[self animateDotAlongCircle:@"dot-11.png" dotSize:50 atCenterX:160 atCenterY:350 theRadius:3 atSpeed:3.2];
		
			[self animateDotAlongCircle:@"dot-2.png" dotSize:55 atCenterX:70 atCenterY:300 theRadius:3 atSpeed:2.9];
			[self animateDotAlongCircle:@"purple3.png" dotSize:35 atCenterX:70 atCenterY:400 theRadius:3 atSpeed:3.1];
		}
		else // for ipad
		{
			[self animateDotAlongCircle:@"dot-2.png" dotSize:(6*miniWidth) atCenterX:(4*miniWidth) atCenterY:(4*miniWidth) theRadius:(miniWidth*3/5) atSpeed:2.8];
			[self animateDotAlongCircle:@"dot-2.png" dotSize:(8*miniWidth) atCenterX:(14*miniWidth) atCenterY:(20*miniWidth) theRadius:(miniWidth*3/5) atSpeed:3.2];
			[self animateDotAlongCircle:@"dot-2.png" dotSize:(10*miniWidth) atCenterX:0 atCenterY:(24*miniWidth) theRadius:(miniWidth*3/5) atSpeed:3.1];
			[self animateDotAlongCircle:@"dot-2.png" dotSize:(10*miniWidth) atCenterX:(8*miniWidth) atCenterY:(36*miniWidth) theRadius:(miniWidth*3/5) atSpeed:3.3];
			[self animateDotAlongCircle:@"dot-2.png" dotSize:(5*miniWidth) atCenterX:(8*miniWidth) atCenterY:(42*miniWidth) theRadius:(miniWidth*3/5) atSpeed:3.2];
			
			[self animateDotAlongCircle:@"dot-11.png" dotSize:(10*miniWidth) atCenterX:(44*miniWidth) atCenterY:(10*miniWidth) theRadius:(miniWidth*2/5) atSpeed:3.2];
			[self animateDotAlongCircle:@"dot-11.png" dotSize:(6*miniWidth) atCenterX:(18*miniWidth) atCenterY:(30*miniWidth) theRadius:(miniWidth*3/5) atSpeed:2.9];
			[self animateDotAlongCircle:@"dot-11.png" dotSize:(12*miniWidth) atCenterX:(32*miniWidth) atCenterY:(50*miniWidth) theRadius:(miniWidth*3/5) atSpeed:3.0];
			[self animateDotAlongCircle:@"dot-11.png" dotSize:(10*miniWidth) atCenterX:(32*miniWidth) atCenterY:(70*miniWidth) theRadius:(miniWidth*3/5) atSpeed:3.2];
			
			[self animateDotAlongCircle:@"dot-2.png" dotSize:(11*miniWidth) atCenterX:(14*miniWidth) atCenterY:(60*miniWidth) theRadius:(miniWidth*3/5) atSpeed:2.9];
			[self animateDotAlongCircle:@"purple3.png" dotSize:(7*miniWidth) atCenterX:(14*miniWidth) atCenterY:(80*miniWidth) theRadius:(miniWidth*3/5) atSpeed:3.1];
			
		}
		
		// Add maple leaf image view to mainmenu image view
		mapleLeaf = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"leaf.png"]];
		if ((hardwareName == 0) || (hardwareName == 1)) // for ipod
			[mapleLeaf setFrame:CGRectMake(0,0,38,50)];	
		else {
			[mapleLeaf setFrame:CGRectMake(0,0,90,120)];	
		}

		[mainMenu addSubview:mapleLeaf];
		[mapleLeaf release];
		
		// rotate the maple leaf
		[self newspinLayer:mapleLeaf.layer]; // call spin method 3
		// move the leaf in and out
		[self animateLeafAlongPath:mapleLeaf.layer];
		
		// fade in/out the company logo
		company = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"company.png"]];
		[company setFrame:CGRectMake(screenWidth/2 - screenHeight/4, 0, screenHeight/2, screenHeight)];
		company.alpha = 0.0;
		[mainMenu addSubview:company];
		[company release];
		[self fadeInCompany:company withDuration:3 andWait:10];
		[self dohelpthing];
		[self drawBackground:0];		
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	NSLog(@"has memory warning**************");
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[mainMenu release];
	[company release];
	// new design follow here
	[dot1 release];
	[mapleLeaf release];
	[mapleLeafLong release];
	[leafMenu release];
	[leafGameBackground release];
	[bubblesLayer release];
	[helpViewLayer release];
	[bubbleImage release];

	[leafDisk release];
	[numberLabel release]; 
	[mininumberLabel release]; 
	[chArray release];
	[leafDiskArray release];
	[scrollView release];

	[currentMovesLabel release];
	[currentLevelLabel release];
	[currentScoreLabel release];
	[newGameButton release];
	[continueButton release];
	[helpButton release];
	[helpView release];
	[helpBackButton release];
	[gameBackButton release];
	[gameResetButton release];
    [super dealloc];
}

/*
 <p> Here is the method(Warning:If you prefer to play the game by yourself, DO NOT read the following instruction.): </p> \
 <p>1. If you play odd levels, such as level 1, 3, 5, 7... etc, always move leaf 1 anti-clockwise, \
 i.e. move leaf 1 from bubble A to bubble B, then move another leaf that can move, then move leaf 1 \
 from bubble B to bubble C, then move another leaf that can move, then move leaf 1 from bubble C \
 to bubble A, move another leaf that can move, and so on.</p> \
 <p>2. If you play even levels, such as level 2, 4, 6, 8... etc, always move leaf 1 clockwise, \
 i.e. move leaf 1 from bubble A to bubble C, then move another leaf that can move, then move leaf 1 \
 from bubble C to bubble B, then move another leaf that can move, then move leaf 1 from bubble B \
 to bubble A, move another leaf that can move, and so on.</p> \
 
 
 */
@end
