//
//  MaskView.h
//  WDDesign
//
//  Created by liu on 15-3-17.
//
//

#import <UIKit/UIKit.h>

typedef void(^MaskDismissBlock)();

//color
#define HEXCOLOR(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define HEXACOLOR(rgbValue, al) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:al]

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

@interface MaskView : UIView

@property (strong, nonatomic) MaskDismissBlock dismissBlock;

- (void)addToView:(UIView *)view animte:(BOOL)animate;

- (void)removeViewWithAnimate:(BOOL)animate;

+ (MaskView *)showInView:(UIView *)view dissmissBlock:(MaskDismissBlock)dismissBlock;

+ (MaskView *)showInView:(UIView *)view animate:(BOOL)animate dissmissBlock:(MaskDismissBlock)dismissBlock;

@end
