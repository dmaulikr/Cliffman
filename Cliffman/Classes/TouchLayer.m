//
//  TouchLayer.m
//  Ropeman
//
//  Created by Jcard on 8/8/14.
//  Copyright 2014 JCard. All rights reserved.
//

#import "TouchLayer.h"

/*
  This class represents a "transparent layer" is always at the exact dimensions and position of what players currently view on their device while in a level. This layer does not interact with any physics objects, but does receive touch events. This layer contains the "Menu" button and the "death" message.
  
*/

@implementation TouchLayer {
    CCSprite *pullButton;
    CCNodeColor* pullEnergyBar;
    
    BOOL pulling;
    float currentEnergy;
    double _depletionRate;
    BOOL _died;
    BOOL _collected;
    
    float energyBarWidth;
    float energyBarHeight;
}

// Creates and initializes a TouchLayer instance
+ (instancetype) createTouchLayer:(CGSize) size depletionRate:(double)levelDepletion {
    return [[TouchLayer alloc] initTouchLayer:size depletionRate:levelDepletion];
}

// Initializes a TouchLayer instance
- (instancetype)initTouchLayer:(CGSize) size depletionRate:(double)levelDepletion {
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    //self = [CCNodeColor nodeWithColor:[CCColor blueColor] width:size.width height:size.height];
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = YES;
    self.anchorPoint = ccp(0.5,0.5);
    self.position = ccp(size.width/2,size.height/2);
    [self setContentSize: size];
    
    // Create a pull button
    //CCButton *pullButton = [CCButton buttonWithTitle:@"Pull" fontName:@"Verdana-Bold" fontSize:26.0f];
    pullButton = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"pullButton.png"]];
    pullButton.positionType = CCPositionTypeNormalized;
    pullButton.position = ccp(0.0f, 0.0f); // Bottom Right of screen
    pullButton.anchorPoint = ccp(0,0);
    //[pullButton setTarget:self selector:@selector(onPullClicked:)];
    pullButton.opacity = 1;
    
    [self addChild:pullButton];
    
    _depletionRate = levelDepletion;
    
    
    
    // Create pull energy bar
    energyBarWidth = [CCDirector is_iPad] ? ENERGY_BAR_WIDTH : ENERGY_BAR_WIDTH / IPAD_TO_IPHONE_HEIGHT_RATIO;
    energyBarWidth = pullButton.contentSize.width;
    energyBarHeight = [CCDirector is_iPad] ? ENERGY_BAR_HEIGHT : ENERGY_BAR_HEIGHT / IPAD_TO_IPHONE_HEIGHT_RATIO;
    
    float borderThickness = ENERGY_BAR_HEIGHT * .10;
    
    CCNodeColor* border = [CCNodeColor nodeWithColor:[CCColor blackColor] width:energyBarWidth + 2*borderThickness height:energyBarHeight + 2*borderThickness];
    border.position = ccp(0, pullButton.contentSize.height*PULL_BUTTON_SCALE_INCREASE);
    [self addChild:border];
    
    pullEnergyBar = [CCNodeColor nodeWithColor:[CCColor brownColor] width:energyBarWidth height:energyBarHeight];
    pullEnergyBar.anchorPoint = ccp(0,0);
    pullEnergyBar.position = ccp(borderThickness, pullButton.contentSize.height*PULL_BUTTON_SCALE_INCREASE + borderThickness);
    currentEnergy = ENERGY_BAR_INITIAL_ENERGY;
    [self addChild:pullEnergyBar];
    
    
    
    // Create a pull button
    //CCButton *pullButton = [CCButton buttonWithTitle:@"Pull" fontName:@"Verdana-Bold" fontSize:26.0f];
    /*CCSprite *pullButton2 = [CCSprite spriteWithImageNamed:@"pullButtonBlue.png"];
    pullButton2.positionType = CCPositionTypeNormalized;
    pullButton2.position = ccp(0.02f, 0.3f); // Bottom Right of screen
    pullButton2.anchorPoint = ccp(0,0);
    //[pullButton setTarget:self selector:@selector(onPullClicked:)];
    [self addChild:pullButton2];
    */
    return self;
}

- (void)update:(CCTime)delta {
    HelloWorldScene *scene = (HelloWorldScene*)_parent;
    if (pulling && currentEnergy > 0 && [scene pull]) {
        currentEnergy -= (1 / _depletionRate);
        currentEnergy = currentEnergy < 0 ? 0 : currentEnergy;
        
        [pullEnergyBar setContentSize:CGSizeMake((currentEnergy / ENERGY_BAR_INITIAL_ENERGY)*energyBarWidth, energyBarHeight)];
        pullButton.scale = PULL_BUTTON_SCALE_INCREASE;
    }
    else {
        pullButton.scale = 1;
    }
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onReturnClicked:(id)sender
{
    [WorldSelectScene returnToSelection];
}

- (void)onRetryClicked:(id)sender
{
    [[WorldSelectScene sharedWorldSelectScene] resetScene];
}

- (void)onNextClicked:(id)sender
{
    [[WorldSelectScene sharedWorldSelectScene] nextScene];
}

- (void)startMakingMenu: (BOOL)died collected:(int)collected {
    CCNodeColor *blackCover = [CCNodeColor nodeWithColor:[CCColor blackColor] width:self.contentSize.width height:self.contentSize.height];
    blackCover.opacity = 0;
    [self addChild:blackCover z:2];
    CCActionFadeTo *fade = [CCActionFadeTo actionWithDuration:1.5f opacity:0.5];
    CCActionCallFunc *createMenu = [CCActionCallFunc actionWithTarget:self selector:NSSelectorFromString(@"createMenu")];
    CCActionSequence *sequence = [CCActionSequence actionWithArray:@[fade, createMenu]];
    [self runAction:sequence];
    
    _died = died;
    _collected = collected;
    
}

- (void)createMenu {
    CCColor *brown = [CCColor colorWithRed:0.54f green:0.39f blue:0.13f];
    
    // Return button
    CCSprite* menu = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"popupMenu.png"]];
    //CCNodeColor *menu = [CCNodeColor nodeWithColor:borderColor width:width height:height];
    menu.anchorPoint = ccp(0.5, 0.5);
    menu.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    [self addChild:menu];
    CCButton *returnButton = [CCButton buttonWithTitle:@" "];
    float boxWidth = [CCDirector is_iPad] ? MENU_SCREEN_BOX_WIDTH : MENU_SCREEN_BOX_WIDTH / IPAD_TO_IPHONE_HEIGHT_RATIO;
    [returnButton setPreferredSize:CGSizeMake(boxWidth, boxWidth)];
    returnButton.position = ccp(self.contentSize.width/2 - menu.contentSize.width/2, self.contentSize.height/2 + menu.contentSize.height/2);
    returnButton.anchorPoint = ccp(0,1);
    [returnButton setTarget:self selector:@selector(onReturnClicked:)];
    [self addChild:returnButton];
    
    // Helmet count
    float font_size = [CCDirector is_iPad] ? MENU_SCREEN_COUNT_FONT_SIZE : MENU_SCREEN_COUNT_FONT_SIZE / IPAD_TO_IPHONE_HEIGHT_RATIO;
    NSString *countString = [NSString stringWithFormat:@"%d / %d",_collected, [[WorldSelectScene sharedWorldSelectScene] maxHelmets]];
    CCLabelTTF *count = [CCLabelTTF labelWithString:countString fontName:@"UnZialish" fontSize:font_size dimensions:CGSizeMake(boxWidth * 0.50, boxWidth * 0.4)];
    [count setHorizontalAlignment:CCTextAlignmentCenter];
    [count setVerticalAlignment:CCVerticalTextAlignmentCenter];
    count.adjustsFontSizeToFit = YES;
    count.color = brown;
    count.position = ccp(self.contentSize.width/2 - menu.contentSize.width/2 + boxWidth*0.45, self.contentSize.height/2 - menu.contentSize.height/2 + boxWidth *.025);
    count.anchorPoint = ccp(0, 0);
    [self addChild:count];
    
    if (_died) {
        // Death message
        NSString *deathString = @"Were you expecting fluffy \npillows?";
        font_size = [CCDirector is_iPad] ? MENU_SCREEN_MESSAGE_FONT_SIZE : MENU_SCREEN_MESSAGE_FONT_SIZE / IPAD_TO_IPHONE_HEIGHT_RATIO;
        CCLabelTTF *death = [CCLabelTTF labelWithString:deathString fontName:@"UnZialish" fontSize:font_size dimensions:CGSizeMake(boxWidth * 1.8, boxWidth * 0.6)];
        [death setHorizontalAlignment:CCTextAlignmentCenter];
        [death setVerticalAlignment:CCVerticalTextAlignmentTop];
        death.adjustsFontSizeToFit = YES;
        death.color = brown;
        death.position = ccp(self.contentSize.width/2 + menu.contentSize.width/2 - boxWidth, self.contentSize.height/2 + menu.contentSize.height/2 - boxWidth *.05);
        death.anchorPoint = ccp(0.5, 1);
        
        CCSprite* deadImage = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"deadPlayer.png"]];
        deadImage.position = ccp(self.contentSize.width/2 + menu.contentSize.width/2 - boxWidth, self.contentSize.height/2 + menu.contentSize.height/2 - boxWidth *.6);
        deadImage.anchorPoint = ccp(0.5, 1);
        
        [self addChild:death];
        [self addChild:deadImage];
        
        // Retry button
        //float width = self.contentSize.width*.75;
        //float height = self.contentSize.height*.75;
        CCSprite* retry = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"retryArrow.png"]];
        retry.anchorPoint = ccp(0.5, 0);
        retry.position = ccp(self.contentSize.width/2 + menu.contentSize.width/2 - boxWidth, self.contentSize.height/2 - menu.contentSize.height/2 + boxWidth *.1);
        CCButton *retryButton = [CCButton buttonWithTitle:@" "];
        [retryButton setPreferredSize:CGSizeMake(retry.contentSize.width, boxWidth*1.1)];
        retryButton.position = ccp(self.contentSize.width/2 + menu.contentSize.width/2 - boxWidth, self.contentSize.height/2 - menu.contentSize.height/2 + boxWidth *.5);
        retryButton.anchorPoint = ccp(0.5,0.5);
        [retryButton setTarget:self selector:@selector(onRetryClicked:)];
        CCLabelTTF *retryText = [CCLabelTTF labelWithString:@"Replay" fontName:@"UnZialish" fontSize:font_size dimensions:CGSizeMake(retry.contentSize.width, boxWidth * .2)];
        [retryText setHorizontalAlignment:CCTextAlignmentCenter];
        [retryText setVerticalAlignment:CCVerticalTextAlignmentCenter];
        retryText.adjustsFontSizeToFit = YES;
        retryText.color = brown;
        retryText.position = ccp(retry.position.x, self.contentSize.height/2 - menu.contentSize.height/2 + boxWidth *.8);
        retryText.anchorPoint = ccp(0.5, 0);
        [self addChild:retryText];
        [self addChild:retry];
        [self addChild:retryButton];
    }
    else {
        // Win message
        NSString *winString = [[WorldSelectScene sharedWorldSelectScene] atLastLevel] ? @"World Complete!" : @"Good work!\nOnto the next level";
        font_size = [CCDirector is_iPad] ? MENU_SCREEN_MESSAGE_FONT_SIZE : MENU_SCREEN_MESSAGE_FONT_SIZE / IPAD_TO_IPHONE_HEIGHT_RATIO;
        CCLabelTTF *win = [CCLabelTTF labelWithString:winString fontName:@"UnZialish" fontSize:font_size dimensions:CGSizeMake(boxWidth * 1.8, boxWidth * 0.6)];
        [win setHorizontalAlignment:CCTextAlignmentCenter];
        [win setVerticalAlignment:CCVerticalTextAlignmentTop];
        win.adjustsFontSizeToFit = YES;
        win.color = brown;
        win.position = ccp(self.contentSize.width/2 + menu.contentSize.width/2 - boxWidth, self.contentSize.height/2 + menu.contentSize.height/2 - boxWidth *.05);
        win.anchorPoint = ccp(0.5, 1);
        
        CCSprite* winImage = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"winPlayer.png"]];
        winImage.position = ccp(self.contentSize.width/2 + menu.contentSize.width/2 - boxWidth, self.contentSize.height/2 + menu.contentSize.height/2 - boxWidth *.55);
        winImage.anchorPoint = ccp(0.5, 1);
        
        [self addChild:win];
        [self addChild:winImage];
        
        // Retry button
        //float width = self.contentSize.width*.75;
        //float height = self.contentSize.height*.75;
        CCSprite* retry = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"retryArrow.png"]];
        CCSprite* next = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"nextarrow.png"]];
        retry.anchorPoint = ccp(0.5, 0);
        retry.position = ccp(self.contentSize.width/2 + menu.contentSize.width/2 - 1.6*boxWidth, self.contentSize.height/2 - menu.contentSize.height/2 + boxWidth *.1);
        CCButton *retryButton = [CCButton buttonWithTitle:@" "];
        [retryButton setPreferredSize:CGSizeMake(retry.contentSize.width, boxWidth*1.1)];
        retryButton.position = ccp(self.contentSize.width/2 + menu.contentSize.width/2 - 1.5*boxWidth, self.contentSize.height/2 - menu.contentSize.height/2 + boxWidth *.5);
        retryButton.anchorPoint = ccp(0.5,0.5);
        [retryButton setTarget:self selector:@selector(onRetryClicked:)];
        CCLabelTTF *retryText = [CCLabelTTF labelWithString:@"Replay" fontName:@"UnZialish" fontSize:font_size dimensions:CGSizeMake(next.contentSize.width*.9, boxWidth * .2)];
        [retryText setHorizontalAlignment:CCTextAlignmentCenter];
        [retryText setVerticalAlignment:CCVerticalTextAlignmentCenter];
        retryText.adjustsFontSizeToFit = YES;
        retryText.color = brown;
        retryText.position = ccp(retry.position.x, self.contentSize.height/2 - menu.contentSize.height/2 + boxWidth *.8);
        retryText.anchorPoint = ccp(0.5, 0);
        [self addChild:retryText];
        [self addChild:retry];
        [self addChild:retryButton];
        
        // Next button
        next.anchorPoint = ccp(0.5, 0);
        next.position = ccp(self.contentSize.width/2 + menu.contentSize.width/2 - 0.6*boxWidth, self.contentSize.height/2 - menu.contentSize.height/2 + boxWidth *.27);
        CCButton *nextButton = [CCButton buttonWithTitle:@" "];
        [nextButton setPreferredSize:CGSizeMake(next.contentSize.width*1.85, boxWidth*1.1)];
        nextButton.position = next.position;
        nextButton.anchorPoint = ccp(0.5,0.25);
        [nextButton setTarget:self selector:@selector(onNextClicked:)];
        NSString* nextTextString = [[WorldSelectScene sharedWorldSelectScene] atLastLevel] ? @"Level Selection" : @"Next Level";
        CCLabelTTF *nextText = [CCLabelTTF labelWithString:nextTextString fontName:@"UnZialish" fontSize:font_size dimensions:CGSizeMake(next.contentSize.width*1.85, boxWidth * .3)];
        next.flipX = [[WorldSelectScene sharedWorldSelectScene] atLastLevel];
        [nextText setHorizontalAlignment:CCTextAlignmentCenter];
        [nextText setVerticalAlignment:CCVerticalTextAlignmentBottom];
        nextText.adjustsFontSizeToFit = YES;
        nextText.color = brown;
        nextText.position = ccp(next.position.x, self.contentSize.height/2 - menu.contentSize.height/2 + boxWidth *.8);
        nextText.anchorPoint = ccp(0.5, 0);
        [self addChild:nextText];
        [self addChild:next];
        [self addChild:nextButton];

    
    }
    
}

/*
 Touch events are all handled by the parent: LevelScene
 */

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLoc = [touch locationInNode:self];
    
    if (touchLoc.x <= pullButton.contentSize.width && touchLoc.y <= pullButton.contentSize.height) {
        pulling = YES;
    }
    else {
        //CCLOG(@"Touched TouchLayer at %@", NSStringFromCGPoint([touch locationInNode:_parent]));
        [_parent touchBegan:touch withEvent:event];
    }
}

-(void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLoc = [touch locationInNode:self];
    
    if (pulling) {
        if (touchLoc.x > 1.5*pullButton.contentSize.width || touchLoc.y > 1.5*pullButton.contentSize.height) {
            pulling = NO;
        }
    }
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLoc = [touch locationInNode:self];
    
    if (touchLoc.x <= pullButton.contentSize.width && touchLoc.y <= pullButton.contentSize.height) {
        
    }
    pulling = NO;
}

-(void) touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLoc = [touch locationInNode:self];
    
    if (touchLoc.x <= pullButton.contentSize.width && touchLoc.y <= pullButton.contentSize.height) {
    }
    pulling = NO;
}

@end
