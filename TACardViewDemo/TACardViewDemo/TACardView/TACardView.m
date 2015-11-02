//
//  TACardView.m
//  TACardViewDemo
//
//  Created by 李小盆 on 15/10/10.
//  Copyright © 2015年 Zip Lee. All rights reserved.
//

#import "TACardView.h"
#import "TAPanGestureRecognizer.h"

@interface TACardView ()<UICollisionBehaviorDelegate>

@property (nonatomic, assign)   BOOL needLoadData;
@property (nonatomic, assign)   NSUInteger numberOfSubcardViews;
@property (nonatomic, strong)   UIView* containerView;
@property (nonatomic, strong)   NSMutableArray<NSNumber *>* previewIndexArray;
@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;
@property (strong, nonatomic) UISnapBehavior *snapBehavior;
@property (strong, nonatomic) UIAttachmentBehavior *attachmentBehavior;
@property (strong, nonatomic) UIAttachmentBehavior *anchorViewAttachmentBehavior;
@property (strong, nonatomic) UIView *anchorContainerView;
@property (strong, nonatomic) UIView *anchorView;
@property (nonatomic) BOOL isAttachViewVisible;
@property (assign, nonatomic) NSInteger currentIndex;

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
    _anchorContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    [self addSubview:_anchorContainerView];
    _previewIndexArray = [NSMutableArray array];
    _needLoadData = YES;
    _numberOfViewsPreview = 3;
    _edgeOffset = 8;
    _containerView = [[UIView alloc] initWithFrame:self.bounds];
    _dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    [self addSubview:_containerView];
}

-(void) loadData {
    if ([_dataSource respondsToSelector:@selector(numberOfSubcardView:)]) {
        _numberOfSubcardViews = [_dataSource numberOfSubcardView:self];
    }
    
    [_previewIndexArray removeAllObjects];
    for (NSUInteger i = 0; i<MIN(_numberOfViewsPreview, _numberOfSubcardViews); i++) {
        if ([_dataSource respondsToSelector:@selector(cardView:viewAtIndex:)]) {
            UIView* subcard = [_dataSource cardView:self viewAtIndex:(i + _currentIndex) % _numberOfSubcardViews];
            subcard.frame = CGRectMake(0 + _edgeOffset * i, 0 + _edgeOffset * 3 * i, self.frame.size.width - _edgeOffset * 2 * i, self.frame.size.height - _edgeOffset * 2 * i);
            [_containerView addSubview:subcard];
            [_containerView sendSubviewToBack:subcard];
            [_previewIndexArray addObject:@((i + _currentIndex) % _numberOfSubcardViews)];
            if (i == 0) {
                [subcard addGestureRecognizer:[[TAPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];
            }
        }
    }
}

- (void)handlePan:(TAPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self];
    CGPoint location = [recognizer locationInView:self];
    UIView *currentCard = recognizer.view;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self createAttachViewForCover:currentCard atLocation:location shouldAttachAnchorViewToPoint:YES];
        if ([_delegate respondsToSelector:@selector(cardView:willSildeCardView:)]) {
            [_delegate cardView:self willSildeCardView:currentCard];
        }
    }else if (recognizer.state == UIGestureRecognizerStateChanged) {
        _anchorViewAttachmentBehavior.anchorPoint = location;
        if ([_delegate respondsToSelector:@selector(cardView:sildingCardView:)]) {
            [_delegate cardView:self sildingCardView:currentCard];
        }
    }else if (recognizer.state == UIGestureRecognizerStateEnded ||
        recognizer.state == UIGestureRecognizerStateCancelled) {
        CGPoint velocity = [recognizer velocityInView:self];
        CGFloat velocityMagnitude = sqrtf(powf(velocity.x, 2) + powf(velocity.y, 2));
        CGFloat translationMagnitude = sqrtf(translation.x * translation.x +
                                             translation.y * translation.y);
        CGVector directionVector = CGVectorMake(translation.x / translationMagnitude * 2000, translation.y / translationMagnitude * 2000);
        
        if ((ABS(translation.x) > ABS(translation.y) ? ABS(translation.x) : ABS(translation.y) > 0.2 * self.bounds.size.width || velocityMagnitude > 750)) {
            [_dynamicAnimator removeBehavior:_anchorViewAttachmentBehavior];
            
            UICollisionBehavior *collisionBehavior = [self collisionBehaviorThatBoundsView:_anchorView inRect:[self defaultCollisionRect]];
            collisionBehavior.collisionDelegate = self;
            [_dynamicAnimator addBehavior:collisionBehavior];
            
            UIPushBehavior *pushBehavior = [self pushBehaviorToPushView:_anchorView direction:directionVector];
            [_dynamicAnimator addBehavior:pushBehavior];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self loadNextSubcardView];
            });
            [_anchorView removeFromSuperview];
            _anchorView = nil;
            
             _currentIndex = (_previewIndexArray.lastObject.unsignedIntegerValue) % _numberOfSubcardViews;

            if ([_delegate respondsToSelector:@selector(cardView:endSildeCardView:)]) {
                [_delegate cardView:self endSildeCardView:currentCard];
            }
        } else {
            [_dynamicAnimator removeBehavior:_attachmentBehavior];
            [_dynamicAnimator removeBehavior:_anchorViewAttachmentBehavior];
            
            [_anchorView removeFromSuperview];
            _snapBehavior = [self snapBehaviorFromSnapView:currentCard toPoint:CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2)];
            [_dynamicAnimator addBehavior:_snapBehavior];
            
            if ([_delegate respondsToSelector:@selector(cardView:cancelSildeCardView:)]) {
                [_delegate cardView:self cancelSildeCardView:currentCard];
            }
        }
        
       
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _containerView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if (_needLoadData) {
        [self loadData];
    }
    _needLoadData = NO;
}

-(void) loadNextSubcardView {
    if (_containerView.subviews.count > 0) {
        [_containerView.subviews.lastObject removeFromSuperview];
        if (_containerView.subviews.count > 0) {
            [_containerView.subviews.lastObject addGestureRecognizer:[[TAPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];
        }
    }
    if (_previewIndexArray.count > 0) {
        [_previewIndexArray removeObjectAtIndex:0];
    }
    [UIView animateWithDuration:0.2 animations:^{
        [_containerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSUInteger i = _containerView.subviews.count - idx - 1;
            obj.frame = CGRectMake(0 + _edgeOffset * i, 0 + _edgeOffset * 3 * i, self.frame.size.width - _edgeOffset * 2 * i, self.frame.size.height - _edgeOffset * 2 * i);
        }];
    }];
    if ([_dataSource respondsToSelector:@selector(cardView:viewAtIndex:)] && _previewIndexArray.count > 0) {
        NSUInteger nextIndex = (_previewIndexArray.lastObject.unsignedIntegerValue + 1) %  (_isCyclicDisplay ? _numberOfSubcardViews : 1);
        if (nextIndex < _numberOfSubcardViews) {
            UIView* subcard = [_dataSource cardView:self viewAtIndex: nextIndex];
            NSUInteger i = MIN(_numberOfViewsPreview, _numberOfSubcardViews) - 1;
            subcard.frame = CGRectMake(0 + _edgeOffset * i, 0 + _edgeOffset * 3 * i, self.frame.size.width - _edgeOffset * 2 * i, self.frame.size.height - _edgeOffset * 2 * i);

            [_containerView addSubview:subcard];
            [_containerView sendSubviewToBack:subcard];
            [_previewIndexArray addObject:@(nextIndex)];
        }
    }
}


- (void)createAttachViewForCover:(UIView *)view
                      atLocation:(CGPoint)location
   shouldAttachAnchorViewToPoint:(BOOL)shouldAttachToPoint {
    [_dynamicAnimator removeBehavior:_snapBehavior];
    _snapBehavior = nil;
    
    _anchorView = [[UIView alloc] initWithFrame:CGRectMake(location.x - 500,location.y - 500, 1000, 1000)];
    [_anchorView setBackgroundColor:[UIColor blueColor]];
    [_anchorView setHidden:!_isAttachViewVisible];
    [_anchorContainerView addSubview:_anchorView];
    UIAttachmentBehavior *attachToView = [self attachmentBehaviorFromView:view
                                     toView:_anchorView];
    [_dynamicAnimator addBehavior:attachToView];
    _attachmentBehavior = attachToView;
    
    if (shouldAttachToPoint) {
        UIAttachmentBehavior *attachToPoint = [self attachmentBehaviorFromView:_anchorView toPoint:location];
        [_dynamicAnimator addBehavior:attachToPoint];
        _anchorViewAttachmentBehavior = attachToPoint;
    }
}

- (UIAttachmentBehavior *)attachmentBehaviorFromView:(UIView *)view toView:(UIView *)attachView {
    if (!view) {
        return nil;
    }
    CGPoint attachPoint = attachView.center;
    CGPoint p = [self convertPoint:view.center toView:self];
    UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc] initWithItem:view offsetFromCenter:UIOffsetMake(-(p.x - attachPoint.x),-(p.y - attachPoint.y)) attachedToItem:attachView offsetFromCenter:UIOffsetMake(0, 0)];
    attachment.length = 0;
    return attachment;
}

- (UIAttachmentBehavior *)attachmentBehaviorFromView:(UIView *)view toPoint:(CGPoint)point {
    if (!view) {
        return nil;
    }
    
    CGPoint p = view.center;
    UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc]initWithItem:view offsetFromCenter:UIOffsetMake(-(p.x - point.x), -(p.y - point.y)) attachedToAnchor:point];
    attachmentBehavior.damping = 100;
    attachmentBehavior.length = 0;
    return attachmentBehavior;
}

- (UISnapBehavior *)snapBehaviorFromSnapView:(UIView *)view toPoint:(CGPoint)point {
    if (!view) {
        return nil;
    }
    UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:view snapToPoint:point];
    snapBehavior.damping = 0.75f;
    return snapBehavior;
}

- (UICollisionBehavior *)collisionBehaviorThatBoundsView:(UIView *)view inRect:(CGRect)rect {
    if (!view) {
        return nil;
    }
    UICollisionBehavior *collisionBehavior =
    [[UICollisionBehavior alloc] initWithItems:@[ view ]];
    UIBezierPath *collisionBound = [UIBezierPath bezierPathWithRect:rect];
    [collisionBehavior addBoundaryWithIdentifier:@"c" forPath:collisionBound];
    collisionBehavior.collisionMode = UICollisionBehaviorModeBoundaries;
    return collisionBehavior;
}

- (CGRect)defaultCollisionRect {
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    CGFloat collisionSizeScale = 6;
    CGSize collisionSize = CGSizeMake(viewSize.width * collisionSizeScale,
                                      viewSize.height * collisionSizeScale);
    CGRect collisionRect =
    CGRectMake(-collisionSize.width / 2 + viewSize.width / 2,
               -collisionSize.height / 2 + viewSize.height / 2,
               collisionSize.width, collisionSize.height);
    return collisionRect;
}

- (UIPushBehavior *)pushBehaviorToPushView:(UIView *)view direction:(CGVector)direction {
    if (!view) {
        return nil;
    }
    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[view] mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.pushDirection = direction;
    return pushBehavior;
}

#pragma mark - UICollisionBehaviorDelegate

- (void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier {
    NSMutableSet *viewsToRemove = [[NSMutableSet alloc] init];
    
    for (id aBehavior in _dynamicAnimator.behaviors) {
        if ([aBehavior isKindOfClass:[UIAttachmentBehavior class]]) {
            NSArray *items = ((UIAttachmentBehavior *)aBehavior).items;
            if ([items containsObject:item]) {
                [_dynamicAnimator removeBehavior:aBehavior];
                [viewsToRemove addObjectsFromArray:items];
            }
        }
        if ([aBehavior isKindOfClass:[UIPushBehavior class]]) {
            NSArray *items = ((UIPushBehavior *)aBehavior).items;
            if ([((UIPushBehavior *)aBehavior).items containsObject:item]) {
                if ([items containsObject:item]) {
                    [_dynamicAnimator removeBehavior:aBehavior];
                    [viewsToRemove addObjectsFromArray:items];
                }
            }
        }
        if ([aBehavior isKindOfClass:[UICollisionBehavior class]]) {
            NSArray *items = ((UICollisionBehavior *)aBehavior).items;
            if ([((UICollisionBehavior *)aBehavior).items
                 containsObject:item]) {
                if ([items containsObject:item]) {
                    [_dynamicAnimator removeBehavior:aBehavior];
                    [viewsToRemove addObjectsFromArray:items];
                }
            }
        }
    }
}
@end
