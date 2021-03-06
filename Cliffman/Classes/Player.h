//
//  Player.h
//  Ropeman
//
//  Created by Jcard on 8/7/14.
//  Copyright 2014 JCard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCAnimation.h"
#import "Constants.h"
#import "Spear.h"
#import "CCAnimationCache.h"

// -----------------------------------------------------------------------
// Types of effects applied to the spheres
typedef NS_ENUM(NSInteger, PlayerState)
{
    Starting,
    Throwing,
    Rising,
    Hanging,
    Falling,
    Dying,
    Won
};

@interface Player : CCSprite {
    
}

@property (assign) PlayerState state;
@property NSLock *jointLock;

+ (Player*)createPlayer: (CGPoint)position shoot:(BOOL)shoot;

- (void)throwSpear: (CGPoint)target;
- (BOOL)pull;

- (void) killPlayer;
- (void) levelWon;

@end
