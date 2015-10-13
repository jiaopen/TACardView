//
//  TACardView.h
//  TACardViewDemo
//
//  Created by 李小盆 on 15/10/10.
//  Copyright © 2015年 Zip Lee. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, ZLSwipeableViewDirection) {
    ZLSwipeableViewDirectionNone = 0,
    ZLSwipeableViewDirectionLeft = (1 << 0),
    ZLSwipeableViewDirectionRight = (1 << 1),
    ZLSwipeableViewDirectionHorizontal = ZLSwipeableViewDirectionLeft |
    ZLSwipeableViewDirectionRight,
    ZLSwipeableViewDirectionUp = (1 << 2),
    ZLSwipeableViewDirectionDown = (1 << 3),
    ZLSwipeableViewDirectionVertical = ZLSwipeableViewDirectionUp |
    ZLSwipeableViewDirectionDown,
    ZLSwipeableViewDirectionAll = ZLSwipeableViewDirectionHorizontal |
    ZLSwipeableViewDirectionVertical,
};

@class TACardView;

@protocol TACardViewDataSource<NSObject>

@required
- (UIView *)cardView:(TACardView *)cardView viewAtIndex:(NSUInteger) index;
- (NSUInteger)numberOfSubcardView:(TACardView *)cardView;

@end

@protocol TACardViewDelegate<NSObject>

@optional
- (void)cardView:(TACardView *)cardView willSildeCardView:(UIView *)view;
- (void)cardView:(TACardView *)cardView sildingCardView:(UIView *)view;
- (void)cardView:(TACardView *)cardView endSildeCardView:(UIView *)view;

@end


IB_DESIGNABLE @interface TACardView : UIView

@property (nonatomic, assign)   NSUInteger numberOfViewsPreview;
@property (nonatomic, assign)  IBInspectable CGFloat edgeOffset;
@property (nonatomic, weak) id<TACardViewDelegate> delegate;
@property (nonatomic, weak) id<TACardViewDataSource> dataSource;

@end
