//
//  MaskView.m
//  WDDesign
//
//  Created by liu on 15-3-17.
//
//

#import "MaskView.h"

@implementation MaskView

- (id)init {
    self = [super init];
    if (self) {
        self.backgroundColor = HEXACOLOR(0x000000, 0.5);
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMask:)]];
    }
    return self;
}

- (void)didTapMask:(id)sender {
    [self removeViewWithAnimate:YES];
    if (self.dismissBlock) {
        self.dismissBlock();
    }
}

- (void)addToView:(UIView *)view animte:(BOOL)animate {
    [view addSubview:self];
    self.frame = view.bounds;
    if (animate) {
        self.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 1;
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)removeViewWithAnimate:(BOOL)animate {
    if (animate) {
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    } else {
        [self removeFromSuperview];
    }
}

+ (MaskView *)showInView:(UIView *)view dissmissBlock:(MaskDismissBlock)dismissBlock  {
    return [MaskView showInView:view animate:YES dissmissBlock:dismissBlock];
}

+ (MaskView *)showInView:(UIView *)view animate:(BOOL)animate dissmissBlock:(MaskDismissBlock)dismissBlock {
    MaskView *maskView = [MaskView new];
    maskView.dismissBlock = dismissBlock;
    [maskView addToView:view animte:animate];
    return maskView;
}

@end
