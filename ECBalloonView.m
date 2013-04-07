//
//  BalloonView.m
//  Test
//
//  Created by Evgeny Cherpak on 4/7/13.
//  Copyright (c) 2013 Evgeny Cherpak. All rights reserved.
//

#import "ECBalloonView.h"
#import <QuartzCore/QuartzCore.h>

#define kMinWidth 120.0
#define kMinHeight 12.0

#define kFontSize 12.0

#define kVerticalPadding 10.0
#define kHorizontalPadding 10.0

#define kArrowWidth 20.0
#define kArrowHeight 10.0

#define kFont [UIFont systemFontOfSize:kFontSize]
//#define kFont [UIFont boldSystemFontOfSize:kFontSize]

@interface ECBalloonView()

@property (nonatomic, assign) CGPoint originPoint;
@property (nonatomic, copy, readwrite) NSString* text;
@property (nonatomic, assign) ECArrowDirection arrowDirection;

@end

@implementation ECBalloonView

- (id)initWithPoint:(CGPoint)point andText:(NSString*)text andArrowDirection:(ECArrowDirection)arrowDirection
{
    if (self = [super initWithFrame:CGRectZero]) {
        self.originPoint = point;
        self.text = text;
        self.arrowDirection = arrowDirection;
        
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

+ (CGSize)sizeInView:(UIView*)view withText:(NSString*)text
{
    // here we need to calculate our new frame, based on the size of the superview
    CGRect superFrame = CGRectInset(view.bounds, kVerticalPadding, kHorizontalPadding);
    
    CGSize maxTextSize = CGSizeMake(superFrame.size.width - kVerticalPadding, superFrame.size.height - kHorizontalPadding);
    
    CGSize textSize = [text sizeWithFont:kFont constrainedToSize:maxTextSize lineBreakMode:NSLineBreakByWordWrapping];
    CGSize frameSize = CGSizeMake(MAX(textSize.width, kMinWidth) + kVerticalPadding, MAX(textSize.height, kMinHeight) + kHorizontalPadding);
    
    frameSize.height += kArrowHeight;
    
    return frameSize;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if ( newSuperview ) {
        CGSize size = [ECBalloonView sizeInView:newSuperview withText:self.text];
        
        CGFloat x = (newSuperview.bounds.size.width - size.width) / 2.0;
        CGRect frame = CGRectMake(x, self.originPoint.y, size.width, size.height);

        self.frame = frame;
        
        CALayer *layer = self.layer;

        layer.shadowOffset = CGSizeMake(0, 3);
        layer.shadowRadius = 8.0;
        layer.shadowColor = [UIColor blackColor].CGColor;
        layer.shadowOpacity = 0.8;        
    }
    
    [super willMoveToSuperview:newSuperview];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGRect r = self.bounds;
    CGFloat cornerRadius = 8.0;
    CGMutablePathRef p = CGPathCreateMutable();
    
    CGFloat maxY = CGRectGetMaxY( r );
    
    if ( self.arrowDirection == ECArrowDirectionUp ) {
        r.origin.y += kArrowHeight;
    } else {
        maxY -= kArrowHeight;
    }
    
    CGFloat minX = CGRectGetMinX( r );
	CGFloat maxX = CGRectGetMaxX( r );
    CGFloat minY = CGRectGetMinY( r );
    
    CGFloat arrowX;
    if ( self.originPoint.x <= minX + cornerRadius + kArrowWidth )
        arrowX = minX + cornerRadius + kArrowWidth;
    else if ( self.originPoint.x >= maxX - cornerRadius - kArrowWidth )
        arrowX = maxX - cornerRadius - kArrowWidth;
    else
        arrowX = self.originPoint.x - kArrowWidth / 2.0;
    
    CGPathMoveToPoint(p, NULL, arrowX - kArrowWidth / 2.0, minY);
    
    if ( self.arrowDirection == ECArrowDirectionUp ) {
        CGPathAddLineToPoint(p, NULL, arrowX, minY - kArrowHeight);
        CGPathAddLineToPoint(p, NULL, arrowX + kArrowWidth / 2.0, minY);
        
        CGContextSetFillColorWithColor(c, [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0].CGColor);
    }
    
    static const CGFloat F_PI = (CGFloat)M_PI;
    CGPathAddArc(p, NULL, maxX - cornerRadius, minY + cornerRadius, cornerRadius, 3.0f*F_PI/2.0f, 0.0f, 0);
    CGPathAddArc(p, NULL, maxX - cornerRadius, maxY - cornerRadius, cornerRadius, 0.0f, F_PI/2.0f, 0);
    
    CGPathAddArc(p, NULL, minX + cornerRadius, maxY - cornerRadius, cornerRadius, F_PI/2.0f, F_PI, 0);
    CGPathAddArc(p, NULL, minX + cornerRadius, minY + cornerRadius, cornerRadius, F_PI, 3.0f*F_PI/2.0f, 0);
    
    if ( self.arrowDirection == ECArrowDirectionDown ) {
        CGPathMoveToPoint(p, NULL, arrowX - kArrowWidth / 2.0, maxY);
        
        CGPathAddLineToPoint(p, NULL, arrowX, maxY + kArrowHeight);
        CGPathAddLineToPoint(p, NULL, arrowX + kArrowWidth / 2.0, maxY);
        
        CGContextSetFillColorWithColor(c, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor);
    }
    
    CGContextAddPath(c, p);
    CFRelease(p);
    CGContextClip(c);
    CGContextFillRect(c, self.bounds);
    
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };

    CGFloat components[8] = { 0.4, 0.4, 0.4, 1.0,  // Start color
        0.0, 0.0, 0.0, 1.0 }; // End color

    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);

    CGRect currentBounds = self.bounds;
    CGPoint startPoint = CGPointMake(CGRectGetMidX(currentBounds), minY);
    CGPoint endPoint = CGPointMake(CGRectGetMidX(currentBounds), maxY);
    CGContextDrawLinearGradient(c, glossGradient, startPoint, endPoint, 0);

    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);

    CGContextSetFillColorWithColor(c, [UIColor whiteColor].CGColor);

    CGRect textRect = CGRectInset(rect, kVerticalPadding / 2.0, kHorizontalPadding / 2.0);
    if ( self.arrowDirection == ECArrowDirectionUp ) {
        textRect.origin.y += kArrowHeight;
    }
    [self.text drawInRect:textRect withFont:kFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
}

@end
