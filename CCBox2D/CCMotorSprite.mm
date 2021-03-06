/*
 
 CCBox2D for iPhone: https://github.com/axcho/CCBox2D
 
 Copyright (c) 2011 axcho and Fugazo, Inc.
 
 This software is provided 'as-is', without any express or implied
 warranty. In no event will the authors be held liable for any damages
 arising from the use of this software.
 
 Permission is granted to anyone to use this software for any purpose,
 including commercial applications, and to alter it and redistribute it
 freely, subject to the following restrictions:
 
 1. The origin of this software must not be misrepresented; you must not
 claim that you wrote the original software. If you use this software
 in a product, an acknowledgment in the product documentation would be
 appreciated but is not required.
 2. Altered source versions must be plainly marked as such, and must not be
 misrepresented as being the original software.
 3. This notice may not be removed or altered from any source distribution.
 
 */

#import "CCMotorSprite.h"
#import "CCBodySprite.h"
#import "CCBox2DPrivate.h"

@implementation CCMotorSprite {
	b2RevoluteJoint *_revoluteJoint;
}

@synthesize running = _running;
@synthesize limited = _limited;
@synthesize speed = _motorSpeed;
@synthesize power = _maxTorque;
@synthesize minRotation = _minRotation;
@synthesize maxRotation = _maxRotation;

-(b2Joint *) joint
{
	return (b2Joint *)_revoluteJoint;
}

-(void) setRunning:(BOOL)newRunning
{
	_running = newRunning;
	
	// if the revolute joint exists
	if (_revoluteJoint)
	{
		// set the revolute joint motor
		_revoluteJoint->EnableMotor(_running);
	}
}

-(void) setLimited:(BOOL)newLimited
{
	_limited = newLimited;
	
	// if the revolute joint exists
	if (_revoluteJoint)
	{
		// set the revolute joint limited
		_revoluteJoint->EnableLimit(_limited);
	}
}

-(void) setSpeed:(float)newSpeed
{
	_motorSpeed = newSpeed;
	
	// if the revolute joint exists
	if (_revoluteJoint)
	{
		// set the revolute joint speed
		_revoluteJoint->SetMotorSpeed(CC_DEGREES_TO_RADIANS(-_motorSpeed));
	}
}

-(void) setPower:(float)newPower
{
	_maxTorque = newPower;
	
	// if the revolute joint exists
	if (_revoluteJoint)
	{
		// set the revolute joint power
		_revoluteJoint->SetMaxMotorTorque(_maxTorque * GTKG_RATIO);
	}
}

-(void) setMinRotation:(float)newMinRotation
{
	_minRotation = newMinRotation;
	
	// if the revolute joint exists
	if (_revoluteJoint)
	{
		// set the revolute joint limits
		_revoluteJoint->SetLimits(CC_DEGREES_TO_RADIANS(-_maxRotation), CC_DEGREES_TO_RADIANS(-_minRotation));
	}
}

-(void) setMaxRotation:(float)newMaxRotation
{
	_maxRotation = newMaxRotation;
	
	// if the revolute joint exists
	if (_revoluteJoint)
	{
		// set the revolute joint limits
		_revoluteJoint->SetLimits(CC_DEGREES_TO_RADIANS(-_maxRotation), CC_DEGREES_TO_RADIANS(-_minRotation));
	}
}

-(void) setBody:(CCBodySprite *)sprite1 andBody:(CCBodySprite *)sprite2
{
	[self setBody:sprite1 andBody:sprite2 atAnchor:ccp((sprite1.position.x + sprite2.position.x) / 2, (sprite1.position.y + sprite2.position.y) / 2)];
}

-(void) setBody:(CCBodySprite *)sprite1 andBody:(CCBodySprite *)sprite2 atAnchor:(CGPoint)anchor
{
	_body1 = sprite1;
	_body2 = sprite2;
	_anchor = anchor;
	
	// if both sprites exist
	if (_body1 && _body2)
	{
		// notify them that they are attached to this joint
		[_body1 addedToJoint:self];
		[_body2 addedToJoint:self];
	}
}

-(void) destroyJoint
{
	// if the revolute joint exists
	if (_revoluteJoint)
	{
		// destroy the joint
		_revoluteJoint->GetBodyA()->GetWorld()->DestroyJoint(_revoluteJoint);
		_revoluteJoint = NULL;
	}
}

-(void) createJoint
{
	// if the physics manager exists
	if (_world)
	{
		// if the world and bodies exist
		if (_world.world && _body1.body && _body2.body)
		{
			// if the revolute joint exists
			if (_revoluteJoint)
			{
				// destroy it first
				[self destroyJoint];
			}
			
			// set up the data for the joint
			b2RevoluteJointDef jointData;
            CGPoint anchor = _anchor;
            
            if([parent_ isKindOfClass:[CCBodySprite class]])
                anchor = CGPointApplyAffineTransform(_anchor, CGAffineTransformInvert([(CCBodySprite *)parent_ worldTransform]));

			jointData.Initialize(_body1.body, _body2.body, b2Vec2(anchor.x * InvPTMRatio, anchor.y * InvPTMRatio));
			jointData.enableMotor = _running;
			jointData.enableLimit = _limited;
			jointData.motorSpeed = CC_DEGREES_TO_RADIANS(-_motorSpeed);
			jointData.maxMotorTorque = _maxTorque * GTKG_RATIO;
			jointData.lowerAngle = CC_DEGREES_TO_RADIANS(-_maxRotation);
			jointData.upperAngle = CC_DEGREES_TO_RADIANS(-_minRotation);
			jointData.collideConnected = false;
			
			// create the joint
			_revoluteJoint = (b2RevoluteJoint *)(_world.world->CreateJoint(&jointData));
			
			// give it a reference to this sprite
			_revoluteJoint->SetUserData(self);
			
			// update every frame
			[self scheduleUpdate];
		}
	}
}

-(id) init
{
	if ((self = [super init]))
	{
		_fixed = NO;
		_running = NO;
		_limited = NO;
		_motorSpeed = 0;
		_maxTorque = 0;
		_minRotation = 0;
		_maxRotation = 0;
		_anchor = CGPointZero;
		_revoluteJoint = NULL;
		_body1 = nil;
		_body2 = nil;
		_world = nil;
	}
	return self;
}

-(void) update:(ccTime)delta
{
	// if revolute joint exists
	if (_revoluteJoint)
	{
        
        b2Vec2 newAnchor = _revoluteJoint->GetAnchorA();
        CGPoint anchor = CGPointMake(newAnchor.x * PTMRatio, newAnchor.y * PTMRatio);

        if([parent_ isKindOfClass:[CCBodySprite class]])
            anchor = CGPointApplyAffineTransform(anchor, [(CCBodySprite *)parent_ worldTransform]);
		
        _anchor = anchor;
		
		if (!_fixed)
		{
			// adjust the angle to zmatch too
			[self setRotation:CC_RADIANS_TO_DEGREES(-_revoluteJoint->GetJointAngle())];
		}
	}
}

@end
