//
//  MaskView.m
//  WDDesign
//
//  Created by liu on 15-3-17.
//
//

#import "ZSSMaskView.h"

@implementation ZSSMaskView

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

+ (ZSSMaskView *)showInView:(UIView *)view dissmissBlock:(MaskDismissBlock)dismissBlock  {
    return [ZSSMaskView showInView:view animate:YES dissmissBlock:dismissBlock];
}

+ (ZSSMaskView *)showInView:(UIView *)view animate:(BOOL)animate dissmissBlock:(MaskDismissBlock)dismissBlock {
    ZSSMaskView *maskView = [ZSSMaskView new];
    maskView.dismissBlock = dismissBlock;
    [maskView addToView:view animte:animate];
    return maskView;
}

@end
