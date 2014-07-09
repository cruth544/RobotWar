//
//  WetDaddyBot.m
//  RobotWar
//
//  Created by Frank Navarro-Velasco on 7/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "WetDaddyBot.h"

typedef NS_ENUM(NSInteger, MoveDirection) {
    MoveDirectionBackwards,
    MoveDirectionFowards
};

typedef NS_ENUM(NSInteger, RobotState) {
    RobotStateSearching,
    RobotStateTurnaround,
    RobotStateRunAway,
    RobotStateTakeAim,
    RobotStateFiring,
    RobotStateLetLoose
    
};

@implementation WetDaddyBot {
    RobotState _currentRobotState;
    MoveDirection _currentRobotDirection;
    
    CGPoint _lastKnownPosition;
    CGFloat _lastKnownPositionTimestamp;
    CGFloat _movePoints;
    CGPoint _headingTowards;
    CGRect _currentPosition;
    CGSize _arenaDimension;
    CGFloat _lastTimeHit;
    CGFloat _lastTimeGunROtated;
    BOOL _gunRotatingRight;
    BOOL _firstTimeRotated;
    
}

-(void) run {
    
    while (TRUE) {
        
        if((self.currentTimestamp - _lastTimeHit) > 3.f){
            _currentRobotState = RobotStateSearching;
        }
        
        switch (_currentRobotState) {
            
            case RobotStateSearching:{
            
                if(_currentRobotState != RobotStateLetLoose) {
                    [self moveThisMany:20];
                
                    [self turnGunThisMany:10];
                
                    [self shoot];
                }
                
            }
                break;
            
            case RobotStateTakeAim: {
                
                if ((self.currentTimestamp - _lastKnownPositionTimestamp) > 1.f) {
                    _currentRobotState = RobotStateSearching;
                } else {
                    CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastKnownPosition];
                    if (angle >= 0) {
                        [self turnGunRight:abs(angle)];
                    } else {
                        [self turnGunLeft:abs(angle)];
                    }
                    
                    _currentRobotState = RobotStateFiring;
                }
                
            }
                break;
                
            case RobotStateFiring: {
                [self shoot];
                _currentRobotState = RobotStateTakeAim;
            }
                break;
        }
    }
}

-(void) gotHit {
    if ( _currentRobotState != RobotStateFiring && _currentRobotState != RobotStateRunAway && _currentRobotState != RobotStateTurnaround){
        [self cancelActiveAction];
        
        _currentRobotState = RobotStateRunAway;
        
        _headingTowards = [self headingDirection];
        _currentPosition = [self robotBoundingBox];
        _arenaDimension = [self arenaDimensions];
        
        if (_currentRobotDirection == MoveDirectionFowards){
            if (abs(_headingTowards.x) > abs(_headingTowards.y)) {
                if ( _headingTowards.x > 0) {
                    _movePoints = abs(_currentPosition.origin.x - _arenaDimension.width);
                    [self moveThisMany:_movePoints+1];
                } else if ( _headingTowards.x < 0){
                    _movePoints = _currentPosition.origin.x;
                    [self moveThisMany:_movePoints+1];
                } else {
                    [self moveThisMany:1];
                }
            } else if (abs(_headingTowards.x) < abs(_headingTowards.y)) {
                if (_headingTowards.y < 0){
                    _movePoints = _currentPosition.origin.y;
                    [self moveThisMany:_movePoints+1];
                } else if (_headingTowards.y > 0) {
                    _movePoints = abs(_currentPosition.origin.y - _arenaDimension.height);
                    [self moveThisMany:_movePoints+1];
                } else {
                    [self moveThisMany:1];
                }
            }
        } else {
            
            if (abs(_headingTowards.x) > abs(_headingTowards.y)) {
                if ( _headingTowards.x < 0) {
                    _movePoints = abs(_currentPosition.origin.x - _arenaDimension.width);
                    [self moveThisMany:_movePoints+1];
                } else if ( _headingTowards.x > 0){
                    _movePoints = _currentPosition.origin.x;
                    [self moveThisMany:_movePoints+1];
                } else {
                    [self moveThisMany:1];
                }
            } else if (abs(_headingTowards.x) < abs(_headingTowards.y)) {
                if (_headingTowards.y > 0){
                    _movePoints = _currentPosition.origin.y;
                    [self moveThisMany:_movePoints+1];
                } else if (_headingTowards.y < 0) {
                    _movePoints = abs(_currentPosition.origin.y - _arenaDimension.height);
                    [self moveThisMany:_movePoints+1];
                } else {
                    [self moveThisMany:1];
                }
            }
            
        }
        
        _currentRobotState = RobotStateSearching;
    }
}

-(void) bulletHitEnemy:(Bullet *)bullet {
    
    if (_currentRobotState != RobotStateTurnaround && _currentRobotState != RobotStateRunAway) {
        
        [self cancelActiveAction];
        
        _currentRobotState = RobotStateLetLoose;
        _lastTimeHit = self.currentTimestamp;
        
        [self shoot];
    }
    
}

-(void) hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)hitAngle {
    
    if (_currentRobotState != RobotStateTurnaround && _currentRobotState != RobotStateFiring && (hitDirection == RobotWallHitDirectionFront || hitDirection == RobotWallHitDirectionRear)){
        
        [self cancelActiveAction];
        
        _currentRobotState = RobotStateTurnaround;
        
        
        if (_currentRobotDirection == MoveDirectionFowards){
            [self moveBack:10];
        } else {
            [self moveAhead:10];
        }
        
        [self turnThisMany:abs((abs(hitAngle)-90))];
        
        _currentRobotState = RobotStateSearching;
    }
    
}

-(void) scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
    
    if (_currentRobotState != RobotStateFiring && _currentRobotState != RobotStateTakeAim && _currentRobotState != RobotStateRunAway) {
        [self cancelActiveAction];
    }
    
    _currentPosition = [self robotBoundingBox];
    _headingTowards = [self headingDirection];
    _arenaDimension = [self arenaDimensions];
    
    //******************************************************************************************************************
    //Changes movement of the robot
    if (abs(_headingTowards.y) > abs(_headingTowards.y)) {
        if (_headingTowards.y > 0) {
            if (_currentPosition.origin.y < position.y && _currentRobotDirection == MoveDirectionFowards) {
            _currentRobotDirection = MoveDirectionBackwards;
            } else if (_currentPosition.origin.y > position.y && _currentRobotDirection == MoveDirectionBackwards){
                _currentRobotDirection = MoveDirectionFowards;
            }
        } else if (_headingTowards.y < 0){
            if (_currentPosition.origin.y > position.y && _currentRobotDirection == MoveDirectionFowards) {
                _currentRobotDirection = MoveDirectionBackwards;
            } else if (_currentPosition.origin.y < position.y && _currentRobotDirection == MoveDirectionBackwards){
                _currentRobotDirection = MoveDirectionFowards;
            }
        }
    } else {
        if (_headingTowards.y > 0) {
            if (_currentPosition.origin.y < position.y && _currentRobotDirection == MoveDirectionFowards) {
                _currentRobotDirection = MoveDirectionBackwards;
            } else if (_currentPosition.origin.y > position.y && _currentRobotDirection == MoveDirectionBackwards){
                _currentRobotDirection = MoveDirectionFowards;
            }
        } else if (_headingTowards.y < 0){
            if (_currentPosition.origin.y > position.y && _currentRobotDirection == MoveDirectionFowards) {
                _currentRobotDirection = MoveDirectionBackwards;
            } else if (_currentPosition.origin.y < position.y && _currentRobotDirection == MoveDirectionBackwards){
                _currentRobotDirection = MoveDirectionFowards;
            }
        }
    }
    //******************************************************************************************************************
    
    _lastKnownPosition = position;
    _lastKnownPositionTimestamp = self.currentTimestamp;
    _currentRobotState = RobotStateTakeAim;
}

-(void) moveThisMany: (CGFloat) points {
    
    if (_currentRobotDirection == MoveDirectionBackwards) {
        [self moveBack:points];
    } else if (_currentRobotDirection == MoveDirectionFowards) {
        [self moveAhead:points];
    }
}

-(void) turnThisMany: (CGFloat) points {
    if (_currentRobotDirection == MoveDirectionBackwards) {
        [self turnRobotLeft:points];
    } else if (_currentRobotDirection == MoveDirectionFowards) {
        [self turnRobotRight:points];
    }
}

-(void) turnGunThisMany: (CGFloat) points {
    CGPoint gunDirection = [self gunHeadingDirection];
    
    _headingTowards = [self headingDirection];
    
    if (!_firstTimeRotated){
        _gunRotatingRight = !_gunRotatingRight;
        _firstTimeRotated = !_firstTimeRotated;
    } else {
        if ((self.currentTimestamp - _lastTimeGunROtated) > 1.f)
        {
            if (abs(_headingTowards.x) > abs(_headingTowards.y)){
                if (_headingTowards.x<0){
                    if (gunDirection.y <= 0 ){
                        _gunRotatingRight = !_gunRotatingRight;
                        _lastTimeGunROtated = self.currentTimestamp;
                    }
                }else {
                    if (gunDirection.y >= 0 ){
                        _gunRotatingRight = !_gunRotatingRight;
                        _lastTimeGunROtated = self.currentTimestamp;
                    }
                }
            } else {
                if (_headingTowards.y>0){
                    if (gunDirection.x <= 0){
                        _gunRotatingRight = !_gunRotatingRight;
                        _lastTimeGunROtated = self.currentTimestamp;
                    }
                } else {
                    if (gunDirection.x >= 0){
                        _gunRotatingRight = !_gunRotatingRight;
                        _lastTimeGunROtated = self.currentTimestamp;
                    }
                }
            }
        }
    }
    
    if (_gunRotatingRight) {
        [self turnGunRight:points];
    }else {
        [self turnGunLeft:points];
    }
}

@end