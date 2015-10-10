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

- (void)setup {
    _needLoadData = YES;
    _numberOfViewsPreview = 3;
}

-(void) loadData {

}

-(void)layoutSubviews
{
    if (self.needLoadData) {
        [self loadData];
    }
    [super layoutSubviews];
}
@end
