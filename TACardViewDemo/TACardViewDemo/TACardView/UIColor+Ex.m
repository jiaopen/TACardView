//
//  UIColor+Ex.m
//  TACardViewDemo
//
//  Created by 李小盆 on 15/10/12.
//  Copyright © 2015年 Zip Lee. All rights reserved.
//

#import "UIColor+Ex.h"

@implementation UIColor (Ex)

+(UIColor *) randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

@end
