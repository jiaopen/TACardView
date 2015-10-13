//
//  ViewController.m
//  TACardViewDemo
//
//  Created by 李小盆 on 15/10/10.
//  Copyright © 2015年 Zip Lee. All rights reserved.
//

#import "ViewController.h"
#import "TACardView.h"
#import "UIColor+Ex.h"

@interface ViewController ()<TACardViewDelegate, TACardViewDataSource>

@property (nonatomic, weak) IBOutlet TACardView *cardView;
@property (nonatomic, strong) NSArray<UIImage*> *imageArray;

@end

@implementation ViewController

-(void)awakeFromNib
{

}

- (void)viewDidLoad {
    [super viewDidLoad];
    _cardView.delegate = self;
    _cardView.dataSource = self;
    _imageArray = @[[UIImage imageNamed:@"111.jpeg"], [UIImage imageNamed:@"222.jpeg"], [UIImage imageNamed:@"333.jpeg"], [UIImage imageNamed:@"444.jpeg"]];
}

-(UIView *)cardView:(TACardView *)cardView viewAtIndex:(NSUInteger)index {
    UIImageView* subCardview = [[UIImageView alloc] initWithImage:_imageArray[index%4]];
    subCardview.backgroundColor = [UIColor randomColor];
//    subCardview.textAlignment = NSTextAlignmentRight;
//    subCardview.font = [UIFont systemFontOfSize:200];
//    subCardview.text = [NSString stringWithFormat:@"%@", @(index)];
    subCardview.userInteractionEnabled = YES;
    return subCardview;
}

-(NSUInteger)numberOfSubcardView:(TACardView *)cardView {
    return 9;
}

@end
