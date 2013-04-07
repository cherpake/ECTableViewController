//
//  PPTableViewController.m
//  Test
//
//  Created by Evgeny Cherpak on 4/7/13.
//  Copyright (c) 2013 Evgeny Cherpak. All rights reserved.
//

#import "ECTableViewController.h"
#import "ECBalloonView.h"

@interface ECTableViewController ()

@property (nonatomic, strong) UILongPressGestureRecognizer* longPressGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer* tapGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer* swipeGestureRecognizer;

@property (nonatomic, strong) ECBalloonView* tooltipView;
@property (nonatomic, strong) NSIndexPath* tooltipIndexPath;

@end

@implementation ECTableViewController

- (UITableViewCell*)cellByLocation:(CGPoint)point
{
    for (UITableViewCell* cell in self.tableView.visibleCells) {
        if (CGRectContainsPoint(cell.frame, point)) {
            return cell;
        }
    }
    
    return nil;
}

- (void)longPressGestureRecognizer:(UILongPressGestureRecognizer*)sender
{
    CGPoint location = [sender locationInView:self.view];
    UITableViewCell* cell = [self cellByLocation:location];
    NSString *text = cell.textLabel.text;
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//    
//    if ( [self.tooltipIndexPath compare:indexPath] == NSOrderedSame && [self.tooltipView.text isEqualToString:text] ) {
//        // we have nothing to do here...
//    } else {
        if ( self.tooltipView ) {
            [self.tooltipView removeFromSuperview];
        }
        
        if ( cell ) {
            CGSize tooltipSize = [ECBalloonView sizeInView:self.tableView withText:text];
            
            ECArrowDirection arrowDirection;
            if ( cell.frame.origin.y - tooltipSize.height > self.tableView.contentOffset.y ) {
                location.y = cell.frame.origin.y - tooltipSize.height;
                arrowDirection = ECArrowDirectionDown;
            } else {
                location.y = cell.frame.origin.y + cell.frame.size.height;
                arrowDirection = ECArrowDirectionUp;
            }
            
            self.tooltipView = [[ECBalloonView alloc] initWithPoint:location andText:text andArrowDirection:arrowDirection];
            [self.view addSubview:self.tooltipView];
            
            [self.tableView setScrollEnabled:NO];
//        }
    }
}

- (void)tapGestureRecognizer:(UITapGestureRecognizer*)sender
{
    if ( self.tooltipView ) {
        [self resetTooltip];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
    self.tapGestureRecognizer.numberOfTapsRequired = 1;
    self.tapGestureRecognizer.delegate = self;
    self.tapGestureRecognizer.cancelsTouchesInView = NO;

    [self.view addGestureRecognizer:self.tapGestureRecognizer];

    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizer:)];
    self.longPressGestureRecognizer.delegate = self;
    [self.longPressGestureRecognizer requireGestureRecognizerToFail:self.tapGestureRecognizer];

    [self.view addGestureRecognizer:self.longPressGestureRecognizer];
}

- (void)resetTooltip
{
    [self.tooltipView removeFromSuperview];
    self.tooltipView = nil;
    
    [self.tableView setScrollEnabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self resetTooltip];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ( self.tooltipView ) {
        if ( gestureRecognizer == self.tapGestureRecognizer || gestureRecognizer == self.longPressGestureRecognizer )
            return YES;
        else
            return NO;
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
