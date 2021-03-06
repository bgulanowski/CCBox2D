//
//  CCShape.h
//  CCBox2D
//
//  Created by Brent Gulanowski on 12-07-12.
//  Copyright (c) 2013 Lichen Labs. All rights reserved.
//

#import <Cocos2DKit/Cocos2DKit.h>


@class CCBodySprite;

// CCShape represents a fixture definition, which includes a shape

@interface CCShape : NSObject<NSCoding>

@property (nonatomic, assign) id userData;

@property (nonatomic, assign) Float32 density;
@property (nonatomic, assign) Float32 friction;
@property (nonatomic, assign) Float32 restitution;
@property (nonatomic, assign) UInt16 collisionCategory;
@property (nonatomic, assign) UInt16 collisionMask;
@property (nonatomic, assign) SInt16 collisionGroup;
@property (nonatomic, assign, getter = isSensor) BOOL sensor;

@property (nonatomic, readonly) CGRect boundingBox;

- (void)addFixtureToBody:(CCBodySprite *)body userData:(id)userData;
- (void)addFixtureToBody:(CCBodySprite *)body;
- (void)removeFixtureFromBody:(CCBodySprite *)body;

- (NSString *)shapeDescription;

+ (CCShape *)boxWithRect:(CGRect)rect;
+ (CCShape *)circleWithCenter:(CGPoint)center radius:(Float32)radius;
+ (CCShape *)polygonWithVertices:(CCArray *)shapeVertices;
+ (CCShape *)chainWithVertices:(CGPoint *)chainVertices count:(NSUInteger)count;

@end
