//
//  BalloonView.h
//  Test
//
//  Created by Evgeny Cherpak on 4/7/13.
//  Copyright (c) 2013 Evgeny Cherpak. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, ECArrowDirection) {
    ECArrowDirectionUp = 1UL << 0,
    ECArrowDirectionDown = 1UL << 1
};

@interface ECBalloonView : UIView

@property (nonatomic, copy, readonly) NSString* text;

- (id)initWithPoint:(CGPoint)point andText:(NSString*)text andArrowDirection:(ECArrowDirection)arrowDirection;

//

+ (CGSize)sizeInView:(UIView*)view withText:(NSString*)text;

@end
