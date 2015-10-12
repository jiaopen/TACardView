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
@property (nonatomic, assign)   NSUInteger numberOfSubcardViews;
@property (nonatomic, strong)   UIView* containerView;
@property (nonatomic, strong)   NSMutableArray<NSNumber *>* previewIndexArray;

@end

IB_DESIGNABLE @implementation TACardView

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
    _previewIndexArray = [NSMutableArray array];
    _needLoadData = YES;
    _numberOfViewsPreview = 3;
    _edgeOffset = 10;
    _containerView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:_containerView];
}

-(void) loadData {
    if ([_dataSource respondsToSelector:@selector(numberOfSubcardView:)]) {
        _numberOfSubcardViews = [_dataSource numberOfSubcardView:self];
    }
    
    [_previewIndexArray removeAllObjects];
    for (NSUInteger i = 0; i<_numberOfViewsPreview; i++) {
        if ([_dataSource respondsToSelector:@selector(cardView:viewAtIndex:)]) {
            UIView* subcard = [_dataSource cardView:self viewAtIndex:i];
            subcard.frame = CGRectMake(0 + _edgeOffset * i, 0 + _edgeOffset * 3 * i, self.frame.size.width - _edgeOffset * 2 * i, self.frame.size.height - _edgeOffset * 2 * i);
            [_containerView addSubview:subcard];
            [_containerView sendSubviewToBack:subcard];
            [_previewIndexArray addObject:@(i)];
            if (i == 0) {
                [subcard addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)]];
            }
        }
    }
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    [self loadNextSubcardView];
}

-(void)layoutSubviews
{
    if (_needLoadData) {
        [self loadData];
    }
    _needLoadData = NO;
    [super layoutSubviews];
}

-(void) loadNextSubcardView {
    if (_containerView.subviews.count > 0) {
        [_containerView.subviews.lastObject removeFromSuperview];
        if (_containerView.subviews.count > 0) {
            [_containerView.subviews.lastObject addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)]];
        }
    }
    if (_previewIndexArray.count > 0) {
        [_previewIndexArray removeObjectAtIndex:0];
    }
    [UIView animateWithDuration:0.5 animations:^{
        [_containerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSUInteger i = _containerView.subviews.count - idx - 1;
            obj.frame = CGRectMake(0 + _edgeOffset * i, 0 + _edgeOffset * 3 * i, self.frame.size.width - _edgeOffset * 2 * i, self.frame.size.height - _edgeOffset * 2 * i);
        }];
    }];
    if ([_dataSource respondsToSelector:@selector(cardView:viewAtIndex:)]) {
        NSUInteger nextIndex = _previewIndexArray.lastObject.unsignedIntegerValue + 1;
        UIView* subcard = [_dataSource cardView:self viewAtIndex: nextIndex];
        NSUInteger i = _numberOfViewsPreview - 1;
        subcard.frame = CGRectMake(0 + _edgeOffset * i, 0 + _edgeOffset * 3 * i, self.frame.size.width - _edgeOffset * 2 * i, self.frame.size.height - _edgeOffset * 2 * i);

        [_containerView addSubview:subcard];
        [_containerView sendSubviewToBack:subcard];
        [_previewIndexArray addObject:@(nextIndex)];
    }
}
@end
