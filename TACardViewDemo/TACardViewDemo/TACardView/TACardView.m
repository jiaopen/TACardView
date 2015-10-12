//
//  TACardView.m
//  TACardViewDemo
//
//  Created by 李小盆 on 15/10/10.
//  Copyright © 2015年 Zip Lee. All rights reserved.
//

#import "TACardView.h"

@interface TACardView ()

@property (nonatomic, assign)   BOOL needLoadData;
@property (nonatomic, assign)   NSUInteger numberOfViews;
@property (nonatomic, strong)   UIView* containerView;

@end

@implementation TACardView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)removeAllSubcardViews {
    [_containerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
}

- (void)setup {
    _needLoadData = YES;
    _numberOfViewsPreview = 3;
    _edgeOffset = 10;
    _containerView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:_containerView];
}

-(void) loadData {
    for (NSUInteger i = 0; i<_numberOfViewsPreview; i++) {
        if ([_dataSource respondsToSelector:@selector(cardView:viewAtIndex:)]) {
            UIView* subcard = [_dataSource cardView:self viewAtIndex:i];
            subcard.frame = CGRectMake(0 + _edgeOffset * i, 0 + _edgeOffset * 3 * i, self.frame.size.width - _edgeOffset * 2 * i, self.frame.size.height - _edgeOffset * 2 * i);
            [_containerView addSubview:subcard];
            [_containerView sendSubviewToBack:subcard];
        }
    }
}

-(void)layoutSubviews
{
    if (_needLoadData) {
        [self loadData];
    }
    _needLoadData = NO;
    [super layoutSubviews];
}
@end
