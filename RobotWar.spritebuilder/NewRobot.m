//
//  NewRobot.m
//  RobotWar
//
//  Created by Chad Rutherford on 7/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NewRobot.h"
#import "Helpers.h"

typedef NS_ENUM(NSInteger, RobotState) {
    robotMove,
    robotGotHit,
    robotShooting,
    robotMoveAndShoot,
    robotHitWall,
    robotIdle
};

//typedef NS_ENUM(NSInteger, RobotWallHitDirection) {
//    RobotWallHitDirectionNone,
//    RobotWallHitDirectionFront,
//    RobotWallHitDirectionLeft,
//    RobotWallHitDirectionRear,
//    RobotWallHitDirectionRight
//};


@implementation NewRobot {
    RobotState _currentState;
    float _timeSinceEnemyHit;
    int _retreatDistance;
    CGPoint _lastKnownEnemyPosition;
    CGFloat _turnAmount;
    CGFloat _lastTimeEnemyHit;
    BOOL _didBulletHit;
    CGPoint _currentGunPosition;
    CGFloat _currentGunFloat;
    BOOL _turnGunLeft;
    BOOL _topLeft;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _currentState = robotIdle;
        _turnAmount = 90;
    }
    return self;
}

- (void)run {
    [self turnRobotRight:90];
    [self moveBack:250];
    while (true) {
        switch (_currentState) {
            case robotMove:
                [self cancelActiveAction];
                [self moveAhead:200];
                [self turnRobotRight:180];
                [self turnGunRight:180];
                [self cancelActiveAction];
                _currentState = robotIdle;
                break;
            case robotShooting:
                _currentGunPosition = [self gunHeadingDirection];
                _currentGunFloat = [self angleBetweenGunHeadingDirectionAndWorldPosition:_currentGunPosition];
                CCLOG(@"currentGunFloat: %f", _currentGunFloat);
                [self binarySearchShooting];
                [self shoot];

                break;
            case robotGotHit:
                
                break;
            case robotHitWall:
                
                break;
            case robotMoveAndShoot:
                [self cancelActiveAction];
                // Calculate the angle between the turret and the enemy
                //    float angleBetweenTurretAndEnemy = [self angleBetweenGunHeadingDirectionAndWorldPosition:position];
                [self moveBack:50];
                
                CGPoint directionVector = ccp(_lastKnownEnemyPosition.x - self.robotBoundingBox.origin.x - 50, _lastKnownEnemyPosition.y - self.robotBoundingBox.origin.y);
                CGPoint currentHeading = [self gunHeadingDirection];
                CGFloat angle = roundf(radToDeg(ccpAngleSigned(directionVector, currentHeading)));
                
                CCLOG(@"%f", angle);
                if (_lastKnownEnemyPosition.x <= self.robotBoundingBox.origin.x) {
                    [self turnGunLeft:abs(angle)];
                }else{
                    [self turnGunRight:abs(angle)];
                }
                [self shoot];
                _currentState = robotIdle;
                break;
            case robotIdle:
                
                break;
//            case robotHitWall:
//                [self cancelActiveAction];
//                
//                switch (hitDirection) {
//                    case RobotWallHitDirectionFront:
//                        [self moveBack:200];
//                        //            CCLOG(@"changed direction front wall hit");
//                        break;
//                    case RobotWallHitDirectionRear:
//                        [self moveAhead:200];
//                        //            CCLOG(@"changed direction back wall hit");
//                        break;
//                    default:
//                        break;
        
                break;
        }
    }
}
- (void)binarySearchShooting {
    CCLOG(@"BinaryShooting gunFloat: %f", _currentGunFloat);
    if (!_turnGunLeft && _currentGunFloat > -94 && _currentGunFloat < -4) {
        [self turnGunRight:_turnAmount];
    }else{
        [self turnGunLeft:_turnAmount];
    }
    if (_currentGunFloat <= -94 || _currentGunFloat >= -4) {
        _turnAmount /= 2;
        _turnGunLeft = !_turnGunLeft;
    }
    CCLOG(@"BinaryShooting afterward: %f", _currentGunFloat);\
}

//
//
//- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
//    _lastKnownEnemyPosition = position;
//    _currentState = robotMoveAndShoot;
//}
//
- (void)bulletHitEnemy:(Bullet *)bullet {
    [self cancelActiveAction];
}

- (void)adjustForTopLeft {
    [self turnRobotLeft:90];
    [self moveBack:20];
    [self turnGunRight:45];
}

- (void)adjustForBottomRight {
    [self turnRobotLeft:90];
    [self moveBack:19];
//    [self turnGunRight:45];
    _currentState = robotShooting;
    [self turnGunLeft:4];
}


- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle {
    [self cancelActiveAction];
    if (_topLeft) {
        [self adjustForTopLeft];
    }else{
        [self adjustForBottomRight];
    }
}
//
//- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle {
//    hitDirection = _robotHitDirection;
//}
//
@end
