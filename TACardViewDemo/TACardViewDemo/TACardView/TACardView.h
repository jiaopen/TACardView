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

@end

@protocol TACardViewDelegate


@end


@interface TACardView : UIView

@property (nonatomic, assign)   NSUInteger numberOfViewsPreview;
@property (nonatomic, assign)   CGFloat edgeOffset;
@property (nonatomic, weak) id<TACardViewDelegate> delegate;
@property (nonatomic, weak) id<TACardViewDataSource> dataSource;

@end
