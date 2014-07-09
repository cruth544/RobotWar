//
//  DecadeSixTEC.m
//  RobotWar
//
//  Coded terribly by Teresa & Eric on 03/06/14.
//  Fixed wonderfully by Chad on 07/06/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "DecadeSixTEC.h"

typedef NS_ENUM(NSInteger, RobotState) {
    RobotStateDefault,
    RobotStateTurnaround,
    RobotStateFiring,
    RobotStateSearching,
    RobotStateShooting
};

static float const defaultTurn = 9;
static float const defaultAdjust = 3;


int times = 0;

@implementation DecadeSixTEC {
    RobotState _currentRobotState;
    
    CGPoint _currentPosition;
    CGFloat _currentFloat;
    CGPoint _currentGunPosition;
    CGFloat _currentGunFloat;
    CGPoint _lastKnownPosition;
    CGFloat _lastKnownPositionTimestamp;
    CGFloat _timeSinceGotHit;
    CGFloat testFloat;
    CGFloat _turnAmount;
    BOOL _didBulletHit;
    CGFloat _lastTimeEnemyHit;
    BOOL _rangeFire;
    BOOL _topLeft;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _turnAmount = defaultTurn;
        _currentRobotState = RobotStateShooting;
    }
    return self;
}


- (void)run {
    CCLOG(@"Arena Width: %f\nArena Heigth: %f", self.arenaDimensions.width, self.arenaDimensions.height);
    CCLOG(@"Position x: %f\nPosition y: %f", self.robotBoundingBox.origin.x, self.robotBoundingBox.origin.y);
    [self turnRobotRight:90];
    [self moveBack:250];
    if (self.robotBoundingBox.origin.x > self.arenaDimensions.width / 2 && self.robotBoundingBox.origin.y < self.arenaDimensions.height / 2) {
        _topLeft = NO;
        _lastTimeEnemyHit = self.currentTimestamp;
        while (true) {
            if (_currentRobotState == RobotStateShooting) {
                [self shoot];
            }
            if (self.currentTimestamp - _lastTimeEnemyHit > 6.f && self.currentTimestamp - _lastTimeEnemyHit < 30.f) {
                _turnAmount = defaultTurn;
                _currentRobotState = RobotStateSearching;

            }
            _currentPosition = [self headingDirection];
            _currentFloat = [self angleBetweenHeadingDirectionAndWorldPosition:_currentPosition];
//            _currentRobotState = RobotStateSearching;
            
            if (_currentRobotState == RobotStateSearching)
            {
                _currentGunPosition = [self gunHeadingDirection];
                _currentGunFloat = [self angleBetweenGunHeadingDirectionAndWorldPosition:_currentGunPosition];
//                CCLOG(@"currentGunFloat: %f", _currentGunFloat);
    //            CCLOG(@"turnAmount: %f", _turnAmount);
    //            CCLOG(@"timestamp: %f", self.currentTimestamp - _lastTimeEnemyHit);
    //            CCLOG(@"rangeFire: %hhd", _rangeFire);
                if (self.currentTimestamp - _lastTimeEnemyHit > 20.f && self.currentTimestamp - _timeSinceGotHit > 20.f) {
                    _rangeFire = NO;
                    _turnAmount -= defaultAdjust;
                }
                if (self.currentTimestamp - _lastTimeEnemyHit > 5.f || _rangeFire) {
                    if (_currentGunFloat > 8) {
                        [self turnGunRight:abs(_currentGunFloat) + 9];
                    }else if (_currentGunFloat < -98) {
                        [self turnGunLeft:abs(_currentGunFloat) - 81];
                    }else if (_currentGunFloat <= -90 || _currentGunFloat >= 0) {
                        _didBulletHit = !_didBulletHit;
                    }
                    if (!_didBulletHit) {
                        [self turnGunLeft:_turnAmount];
                    }else if (_didBulletHit){
                        [self turnGunRight:_turnAmount];
                    }
                }
                [self shoot];


            }
            if (_currentRobotState == RobotStateFiring)
            {
//                NSLog(@"Pew-Pew");
                if ((self.currentTimestamp - _lastKnownPositionTimestamp) > 1.f) {
                    _currentRobotState = RobotStateSearching;
                } else {
                    CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastKnownPosition];
                    if (angle >= 0) {
                        [self turnGunRight:abs(angle)];
                    } else {
                        [self turnGunLeft:abs(angle)];
                    }
                    [self shoot];
                }
                
            }

        }
    }else if (self.robotBoundingBox.origin.x < self.arenaDimensions.width / 2 && self.robotBoundingBox.origin.y > self.arenaDimensions.height / 2) {
        _topLeft = YES;
        _lastTimeEnemyHit = self.currentTimestamp;
            while (true) {
                if (_currentRobotState == RobotStateShooting) {
                    [self shoot];
                }
//                CCLOG(@"timePassed: %f", self.currentTimestamp - _lastTimeEnemyHit);
                if (self.currentTimestamp - _lastTimeEnemyHit > 6.f && self.currentTimestamp - _lastTimeEnemyHit < 30.f) {
                    _turnAmount = defaultTurn;
                    _currentRobotState = RobotStateSearching;

                }
                _currentPosition = [self headingDirection];
                _currentFloat = [self angleBetweenHeadingDirectionAndWorldPosition:_currentPosition];
//                _currentRobotState = RobotStateSearching;
//                CCLOG(@"currentFloat %f", _currentFloat);

                if (_currentRobotState == RobotStateSearching)
                {
                    _currentGunPosition = [self gunHeadingDirection];
                    _currentGunFloat = [self angleBetweenGunHeadingDirectionAndWorldPosition:_currentGunPosition];
//                    CCLOG(@"currentGunFloat: %f", _currentGunFloat);
//                    CCLOG(@"turnAmount: %f", _turnAmount);
//                    CCLOG(@"timestamp: %f", self.currentTimestamp - _lastTimeEnemyHit);
//                    CCLOG(@"rangeFire: %hhd", _rangeFire);
                    if (self.currentTimestamp - _lastTimeEnemyHit > 30.f && self.currentTimestamp - _timeSinceGotHit > 20.f) {
                        _rangeFire = NO;
                        _turnAmount = defaultAdjust;
                    }
                    if (self.currentTimestamp - _lastTimeEnemyHit > 5.f || _rangeFire) {
                        if (_currentGunFloat >= 98) {
                            [self turnGunRight:abs(_currentGunFloat) - 81];
                        }else if (_currentGunFloat <= -8) {
                            [self turnGunLeft:abs(_currentGunFloat) + 9];
                        }else if (_currentGunFloat <= 0 || _currentGunFloat >= 90) {
                            _didBulletHit = !_didBulletHit;
                        }
                        if (!_didBulletHit) {
                            [self turnGunLeft:_turnAmount];
                        }else if (_didBulletHit){
                            [self turnGunRight:_turnAmount];
                        }
                    }
                    [self shoot];
                    
                    
                }
                if (_currentRobotState == RobotStateFiring)
                {
//                    NSLog(@"Pew-Pew");
                    if ((self.currentTimestamp - _lastKnownPositionTimestamp) > 3.f) {
                        _currentRobotState = RobotStateSearching;
                    } else {
                        CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastKnownPosition];
                        if (angle >= 0) {
                            [self turnGunRight:abs(angle)];
                        } else {
                            [self turnGunLeft:abs(angle)];
                        }
                        [self shoot];
                    }
                    
                }
            }

        }
}

- (void)bulletHitEnemy:(Bullet *)bullet {
    _didBulletHit = !_didBulletHit;
//    [self cancelActiveAction];
    [self shoot];
    _lastTimeEnemyHit = self.currentTimestamp;
    if (_turnAmount > 0){
        _turnAmount -= defaultAdjust;
        _rangeFire = YES;
    }
}

- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {

    _turnAmount = defaultTurn;
    _lastKnownPosition = position;
    _lastKnownPositionTimestamp = self.currentTimestamp;
    _currentRobotState = RobotStateFiring;
}

- (void)adjustForTopLeft {
    [self turnRobotLeft:90];
    [self moveBack:19];
    [self turnGunRight:28];
}

- (void)adjustForBottomRight {
    [self turnRobotLeft:90];
    [self moveBack:19];
    [self turnGunRight:28];
}

- (void)gotHit {
    [super gotHit];
    _timeSinceGotHit = self.currentTimestamp;
}
- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle {
    [self cancelActiveAction];
    if (_topLeft) {
        [self adjustForTopLeft];
    }else{
        [self adjustForBottomRight];
    }
    
}

@end
