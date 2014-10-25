//
//  JVCHorizontalStreamView.m
//  CloudSEE_II
//
//  Created by Yanghu on 10/23/14.
//  Copyright (c) 2014 Yanghu. All rights reserved.
//

#import "JVCHorizontalStreamView.h"

@implementation JVCHorizontalStreamView

@synthesize horStreamDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)showHorizonStreamView:(UIButton *)btn  andSelectindex:(NSInteger)index {
    self = [super init];
    if (self) {
        
        // Initialization code  25 165; 269 96
        UIImage *tInputImage = [UIImage imageNamed:@"HorizontalScreenStreambg.png"];
        
        UIImage *btnSelectImage = [UIImage imageNamed:@"HorizontalScreenStreambgSelect.png"];
        
        [btn.superview.superview addSubview:self];
        
        self.frame = CGRectMake([UIScreen mainScreen].bounds.size.height - tInputImage.size.width-30, btn.superview.superview.frame.size.height -tInputImage.size.height-49, tInputImage.size.width, 0);
        
        UIImageView *imageBG = [[UIImageView alloc] initWithImage:tInputImage];
        imageBG.frame = CGRectMake(0,0, tInputImage.size.width, tInputImage.size.height);
        [self addSubview:imageBG];
        [imageBG release];
        
        CGFloat height = (tInputImage.size.height - 10)/3;
        
        NSArray *arrayTitle = [NSArray arrayWithObjects:NSLocalizedString(@"HD", nil),NSLocalizedString(@"SD", nil),NSLocalizedString(@"Fluent", nil), nil];
        
        if (index>=[arrayTitle count]) {
            
            index=[arrayTitle count];
        }
        for (int i = 0; i<[arrayTitle count]; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:[arrayTitle objectAtIndex:i ] forState:UIControlStateNormal];
            btn.frame = CGRectMake((imageBG.frame.size.width - btnSelectImage.size.width)/2.0, i*height+1, btnSelectImage.size.width, btnSelectImage.size.height);
            if (i == index) {
                [btn setBackgroundImage:btnSelectImage forState:UIControlStateNormal];
            }
            
            [btn addTarget:self action:@selector(selectStream:) forControlEvents:UIControlEventTouchUpInside];
            
            
            [btn setBackgroundImage:btnSelectImage forState:UIControlStateHighlighted];
            btn.tag = i+1;
            
            [self addSubview:btn];
        }
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.frame = CGRectMake([UIScreen mainScreen].bounds.size.height - tInputImage.size.width-30, btn.superview.superview.frame.size.height -tInputImage.size.height-49, tInputImage.size.width, tInputImage.size.height);
        [UIView commitAnimations];
        
    }
    return self;
}

- (void)selectStream:(UIButton *)btn
{
    if (horStreamDelegate !=nil &&[horStreamDelegate respondsToSelector:@selector(horizontalStreamViewCallBack:)]) {
        [horStreamDelegate horizontalStreamViewCallBack:btn];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end