//
//  TACardView.h
//  TACardViewDemo
//
//  Created by 李小盆 on 15/10/10.
//  Copyright © 2015年 Zip Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TACardView;

@protocol TACardViewDataSource<NSObject>

@required
- (UIView *)cardView:(TACardView *)cardView viewAtIndex:(NSUInteger) index;
- (NSUInteger)numberOfSubcardView:(TACardView *)cardView;

@end

@protocol TACardViewDelegate

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
