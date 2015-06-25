//
//  ZSSRichTextEditorViewController.m
//  ZSSRichTextEditor
//
//  Created by Nicholas Hubbard on 11/30/13.
//  Copyright (c) 2013 Zed Said Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ZSSRichTextEditor.h"
#import "ZSSBarButtonItem.h"
#import "ZSSTextView.h"
#import "ZSSRecordView.h"
#import "JsonSerialization.h"
#import "MSColorSelectionViewController.h"
#import "UIColor+Hex.h"
#import "HRColorUtil.h"
#import "ZSSColorPicker.h"
#import "UIWebView+HackishAccessoryHiding.h"

#if DEBUG
#define DLog(format,...) NSLog(format, ##__VA_ARGS__)
#else
#define DLog(format,...)
#endif

#define HEXCOLOR(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kScreenWidth [[UIScreen mainScreen] applicationFrame].size.width

#define kActionSheetInsertImageTag 1001
#define kActionSheetInsertVideoTag 1002
#define kMaskViewTag 2001


static NSString *collectionViewIdentifier = @"UICollectionView";

@interface ZSSRichTextEditor () <UICollectionViewDelegate, UICollectionViewDataSource>
/*
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIScrollView *toolBarScroll;
@property (nonatomic, strong) UIBarButtonItem *keyboardItem;
@property (nonatomic, strong) NSMutableArray *customBarButtonItems;
@property (nonatomic, strong) NSMutableArray *customZSSBarButtonItems;
*/

@property (nonatomic, strong) UIButton *keyboardBtn;
@property (nonatomic, strong) NSMutableArray *toolbarBtns;
@property (nonatomic, strong) NSMutableArray *toolbarBtnKinds;

@property (nonatomic, strong) NSString *htmlString;

@property (nonatomic, strong) ZSSTextView *sourceView;

//@property (nonatomic) BOOL resourcesLoaded;
//@property (nonatomic, strong) NSArray *editorItemsEnabled;

@property (nonatomic, strong) UIAlertView *alertView;

@property (nonatomic, strong) NSString *selectedLinkURL;
@property (nonatomic, strong) NSString *selectedLinkTitle;
@property (nonatomic, strong) NSString *selectedImageURL;
@property (nonatomic, strong) NSString *selectedImageAlt;

@property (nonatomic, strong) UIColor *currentTextColor;
@property (nonatomic, strong) UIColor *currentBgColor;

@property (nonatomic, strong) NSString *internalHTML;
@property (nonatomic) BOOL editorLoaded;

- (NSString *)removeQuotesFromHTML:(NSString *)html;
- (NSString *)tidyHTML:(NSString *)html;
//- (void)enableToolbarItems:(BOOL)enable;
//- (BOOL)isIpad;

@end

@implementation ZSSRichTextEditor

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.sourceView.frame = self.bounds;
    self.editorView.frame = self.bounds;
    DLog(@"%@", NSStringFromCGRect(self.editorView.frame));
//    [self.editorView reload];
//    [self setContentHeight:CGRectGetHeight(self.frame)];
}

//- (id)init {
//    return [self initWithFrame:CGRectNull navigationController:nil];
//}

//- (id)initWithFrame:(CGRect)frame navigationController:(UINavigationController *)navgationController {
//    return [self initWithFrame:frame navigationController:navgationController delegate:nil];
//}

- (id)initWithNavigationController:(UINavigationController *)navgationController delegate:(id<ZSSRichTextEditorDelegate>)delegate {
    self = [super init];
    if (self) {
        self.navigationController = navgationController;
        self.delegate = delegate;
        
//        self.frame = frame;
        
        self.editorLoaded = NO;
//        self.shouldShowKeyboard = YES;
        self.formatHTML = YES;
//        self.formatHTML = NO;
        
//        self.enabledToolbarItems = [[NSArray alloc] init];
        ///init view
        
        self.actionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
//        self.actionView.backgroundColor = HEXCOLOR(0xf5f5f5);
        
        self.toolbarBtns = [NSMutableArray array];
        
        self.collectionView.frame = self.actionView.bounds;
        self.collectionView.backgroundColor = HEXCOLOR(0xf5f5f5);
        self.collectionView.showsHorizontalScrollIndicator = NO;
        [self.actionView addSubview:self.collectionView];
        
        if ([self.delegate respondsToSelector:@selector(keyboardButton)]) {
            self.keyboardBtn = [self.delegate keyboardButton];
        } else {
            self.keyboardBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            [self.keyboardBtn setImage:[UIImage imageNamed:@"ZSSkeyboard"] forState:UIControlStateNormal];
            [self.keyboardBtn setTintColor:[UIColor blueColor]];
            self.keyboardBtn.backgroundColor = [UIColor whiteColor];
        }
        [self.keyboardBtn addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventTouchUpInside];
        self.keyboardBtn.frame = CGRectMake(kScreenWidth-45, 0, 45, 44);
        [self.actionView addSubview:self.keyboardBtn];
        
        CALayer *topSeparator = [CALayer layer];
        topSeparator.frame = CGRectMake(0, 0, CGRectGetWidth(self.actionView.frame), 1);
        topSeparator.backgroundColor = HEXCOLOR(0xc1c1c1).CGColor;
        [self.actionView.layer addSublayer:topSeparator];
        
        CALayer *btmSeparator = [CALayer layer];
        btmSeparator.frame = CGRectMake(0, 43, CGRectGetWidth(self.actionView.frame), 1);
        btmSeparator.backgroundColor = HEXCOLOR(0xc1c1c1).CGColor;
        [self.actionView.layer addSublayer:btmSeparator];
        
        CALayer *btnSeparator = [CALayer layer];
        btnSeparator.frame = CGRectMake(0, 0, 1, 44);
        btnSeparator.backgroundColor = HEXCOLOR(0xc1c1c1).CGColor;
        [self.keyboardBtn.layer addSublayer:btnSeparator];
        
        self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, CGRectGetWidth(self.keyboardBtn.frame));
        
        // Source View
//        CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.sourceView = [[ZSSTextView alloc] initWithFrame:CGRectZero];
        self.sourceView.hidden = YES;
        self.sourceView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.sourceView.autocorrectionType = UITextAutocorrectionTypeNo;
        self.sourceView.font = [UIFont fontWithName:@"Courier" size:13.0];
//        self.sourceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        self.sourceView.autoresizesSubviews = YES;
        self.sourceView.delegate = self;
        [self addSubview:self.sourceView];
        
        // Editor View
        self.editorView = [[UIWebView alloc] initWithFrame:CGRectZero];
        self.editorView.delegate = self;
        self.editorView.hidesInputAccessoryView = YES;
        self.editorView.keyboardDisplayRequiresUserAction = NO;
        self.editorView.scalesPageToFit = YES;
//        self.editorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
//        self.editorView.dataDetectorTypes = UIDataDetectorTypeNone;
//        self.editorView.scrollView.bounces = NO;
        self.editorView.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
        self.editorView.scrollView.contentInset = UIEdgeInsetsZero;
        self.editorView.backgroundColor = [UIColor whiteColor];
//        self.editorView.scrollView.scrollEnabled = NO;
        [self addSubview:self.editorView];

        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"editor" ofType:@"html"];
        NSData *htmlData = [NSData dataWithContentsOfFile:filePath];
        NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
        
        NSString *source = [[NSBundle mainBundle] pathForResource:@"ZSSRichTextEditor" ofType:@"js"];
        NSString *jsString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:source] encoding:NSUTF8StringEncoding];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!--editor-->" withString:jsString];
        
        NSString *exSource = [[NSBundle mainBundle] pathForResource:@"ZSSExtend" ofType:@"js"];
        NSString *exJsString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:exSource] encoding:NSUTF8StringEncoding];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!--extend-->" withString:exJsString];
        
        [self.editorView loadHTMLString:htmlString baseURL:self.baseURL];
        
        
//        [self setFooterHeight:44];
//        [self setContentHeight:CGRectGetHeight(frame)];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        self.toolbarBtnKinds = [NSMutableArray array];
        
        if ([self.delegate respondsToSelector:@selector(actionViewBtns)]) {
            [self.toolbarBtns addObjectsFromArray:[self.delegate actionViewBtns]];
        } else {
            [self.toolbarBtnKinds addObjectsFromArray:@[
                                                        ZSSRichTextEditorToolbarBold,
                                                        ZSSRichTextEditorToolbarItalic,
                                                        ZSSRichTextEditorToolbarSubscript,
                                                        ZSSRichTextEditorToolbarSuperscript,
                                                        ZSSRichTextEditorToolbarStrikeThrough,
                                                        ZSSRichTextEditorToolbarUnderline,
                                                        ZSSRichTextEditorToolbarRemoveFormat,
                                                        ZSSRichTextEditorToolbarJustifyLeft,
                                                        ZSSRichTextEditorToolbarJustifyCenter,
                                                        ZSSRichTextEditorToolbarJustifyRight]];
            
            for (int i = 0; i < self.toolbarBtnKinds.count; i++) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
                btn.frame = CGRectMake(0, 0, kScreenWidth/7.0, 44);
                btn.tag = i;
                NSString *kind = self.toolbarBtnKinds[i];
                if ([kind isEqualToString:ZSSRichTextEditorToolbarBold]) {
                    [btn setImage:[UIImage imageNamed:@"ZSSbold"] forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(setBold) forControlEvents:UIControlEventTouchUpInside];
                }
                if ([kind isEqualToString:ZSSRichTextEditorToolbarItalic]) {
                    [btn setImage:[UIImage imageNamed:@"ZSSitalic"] forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(setItalic) forControlEvents:UIControlEventTouchUpInside];
                }
                if ([kind isEqualToString:ZSSRichTextEditorToolbarSubscript]) {
                    [btn setImage:[UIImage imageNamed:@"ZSSsubscript"] forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(setSubscript) forControlEvents:UIControlEventTouchUpInside];
                }
                if ([kind isEqualToString:ZSSRichTextEditorToolbarSuperscript]) {
                    [btn setImage:[UIImage imageNamed:@"ZSSsuperscript"] forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(setSuperscript) forControlEvents:UIControlEventTouchUpInside];
                }
                if ([kind isEqualToString:ZSSRichTextEditorToolbarStrikeThrough]) {
                    [btn setImage:[UIImage imageNamed:@"ZSSstrikethrough"] forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(setStrikethrough) forControlEvents:UIControlEventTouchUpInside];
                }
                if ([kind isEqualToString:ZSSRichTextEditorToolbarUnderline]) {
                    [btn setImage:[UIImage imageNamed:@"ZSSunderline"] forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(setUnderline) forControlEvents:UIControlEventTouchUpInside];
//                    [btn addTarget:self action:@selector(testAction:) forControlEvents:UIControlEventTouchUpInside];
                }
                if ([kind isEqualToString:ZSSRichTextEditorToolbarRemoveFormat]) {
                    [btn setImage:[UIImage imageNamed:@"ZSSclearstyle"] forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(removeFormat) forControlEvents:UIControlEventTouchUpInside];
                }
                if ([kind isEqualToString:ZSSRichTextEditorToolbarJustifyLeft]) {
                    [btn setImage:[UIImage imageNamed:@"ZSSleftjustify"] forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(alignLeft) forControlEvents:UIControlEventTouchUpInside];
                }
                if ([kind isEqualToString:ZSSRichTextEditorToolbarJustifyCenter]) {
                    [btn setImage:[UIImage imageNamed:@"ZSScenterjustify"] forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(alignCenter) forControlEvents:UIControlEventTouchUpInside];
                }
                if ([kind isEqualToString:ZSSRichTextEditorToolbarJustifyRight]) {
                    [btn setImage:[UIImage imageNamed:@"ZSSrightjustify"] forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(alignRight) forControlEvents:UIControlEventTouchUpInside];
                }
                if ([kind isEqualToString:ZSSRichTextEditorToolbarJustifyFull]) {
                    [btn setImage:[UIImage imageNamed:@"ZSSforcejustify"] forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(alignRight) forControlEvents:UIControlEventTouchUpInside];
                }
                [self.toolbarBtns addObject:btn];
            }
        }
        
    }
    return self;
}

- (void)setPlaceholderText {
    NSString *js = [NSString stringWithFormat:@"zss_editor.setPlaceholder(\"%@\");", self.placeholder];
    [self.editorView stringByEvaluatingJavaScriptFromString:js];
}

- (void)setFooterHeight:(float)footerHeight {
    NSString *js = [NSString stringWithFormat:@"zss_editor.setFooterHeight(\"%f\");", footerHeight];
    [self.editorView stringByEvaluatingJavaScriptFromString:js];
}

- (void)setContentHeight:(float)contentHeight {
    NSString *js = [NSString stringWithFormat:@"zss_editor.contentHeight = %f;", contentHeight];
    [self.editorView stringByEvaluatingJavaScriptFromString:js];
}


#pragma mark - Toolbar Item
/*
- (NSArray *)itemsForToolbar {
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    // None
    if(_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarNone])
    {
        return items;
    }
    
    // Bold
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarBold]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *bold = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSbold.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setBold)];
        bold.label = @"bold";
        [items addObject:bold];
    }
    
    // Italic
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarItalic]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *italic = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSitalic.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setItalic)];
        italic.label = @"italic";
        [items addObject:italic];
    }
    
    // Subscript
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarSubscript]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *subscript = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSsubscript.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setSubscript)];
        subscript.label = @"subscript";
        [items addObject:subscript];
    }
    
    // Superscript
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarSuperscript]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *superscript = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSsuperscript.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setSuperscript)];
        superscript.label = @"superscript";
        [items addObject:superscript];
    }
    
    // Strike Through
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarStrikeThrough]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *strikeThrough = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSstrikethrough.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setStrikethrough)];
        strikeThrough.label = @"strikeThrough";
        [items addObject:strikeThrough];
    }
    
    // Underline
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarUnderline]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *underline = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSunderline.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setUnderline)];
        underline.label = @"underline";
        [items addObject:underline];
    }
    
    // Remove Format
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarRemoveFormat]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *removeFormat = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSclearstyle.png"] style:UIBarButtonItemStylePlain target:self action:@selector(removeFormat)];
        removeFormat.label = @"removeFormat";
        [items addObject:removeFormat];
    }
    
    // Undo
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarUndo]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *undoButton = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSundo.png"] style:UIBarButtonItemStylePlain target:self action:@selector(undo:)];
        undoButton.label = @"undo";
        [items addObject:undoButton];
    }
    
    // Redo
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarRedo]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *redoButton = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSredo.png"] style:UIBarButtonItemStylePlain target:self action:@selector(redo:)];
        redoButton.label = @"redo";
        [items addObject:redoButton];
    }
    
    // Align Left
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarJustifyLeft]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *alignLeft = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSleftjustify.png"] style:UIBarButtonItemStylePlain target:self action:@selector(alignLeft)];
        alignLeft.label = @"justifyLeft";
        [items addObject:alignLeft];
    }
    
    // Align Center
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarJustifyCenter]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *alignCenter = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSScenterjustify.png"] style:UIBarButtonItemStylePlain target:self action:@selector(alignCenter)];
        alignCenter.label = @"justifyCenter";
        [items addObject:alignCenter];
    }
    
    // Align Right
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarJustifyRight]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *alignRight = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSrightjustify.png"] style:UIBarButtonItemStylePlain target:self action:@selector(alignRight)];
        alignRight.label = @"justifyRight";
        [items addObject:alignRight];
    }
    
    // Align Justify
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarJustifyFull]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *alignFull = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSforcejustify.png"] style:UIBarButtonItemStylePlain target:self action:@selector(alignFull)];
        alignFull.label = @"justifyFull";
        [items addObject:alignFull];
    }
    
    // Paragraph
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarParagraph]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *paragraph = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSparagraph.png"] style:UIBarButtonItemStylePlain target:self action:@selector(paragraph)];
        paragraph.label = @"p";
        [items addObject:paragraph];
    }
    
    // Header 1
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarH1]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *h1 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh1.png"] style:UIBarButtonItemStylePlain target:self action:@selector(heading1)];
        h1.label = @"h1";
        [items addObject:h1];
    }
    
    // Header 2
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarH2]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *h2 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh2.png"] style:UIBarButtonItemStylePlain target:self action:@selector(heading2)];
        h2.label = @"h2";
        [items addObject:h2];
    }
    
    // Header 3
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarH3]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *h3 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh3.png"] style:UIBarButtonItemStylePlain target:self action:@selector(heading3)];
        h3.label = @"h3";
        [items addObject:h3];
    }
    
    // Heading 4
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarH4]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *h4 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh4.png"] style:UIBarButtonItemStylePlain target:self action:@selector(heading4)];
        h4.label = @"h4";
        [items addObject:h4];
    }
    
    // Header 5
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarH5]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *h5 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh5.png"] style:UIBarButtonItemStylePlain target:self action:@selector(heading5)];
        h5.label = @"h5";
        [items addObject:h5];
    }
    
    // Heading 6
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarH6]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *h6 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh6.png"] style:UIBarButtonItemStylePlain target:self action:@selector(heading6)];
        h6.label = @"h6";
        [items addObject:h6];
    }
    
    // Text Color
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarTextColor]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *textColor = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSStextcolor.png"] style:UIBarButtonItemStylePlain target:self action:@selector(textColor)];
        textColor.label = @"textColor";
        [items addObject:textColor];
    }
    
    // Background Color
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarBackgroundColor]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *bgColor = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSbgcolor.png"] style:UIBarButtonItemStylePlain target:self action:@selector(bgColor)];
        bgColor.label = @"backgroundColor";
        [items addObject:bgColor];
    }
    
    // Unordered List
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarUnorderedList]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *ul = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSunorderedlist.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setUnorderedList)];
        ul.label = @"unorderedList";
        [items addObject:ul];
    }
    
    // Ordered List
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarOrderedList]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *ol = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSorderedlist.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setOrderedList)];
        ol.label = @"orderedList";
        [items addObject:ol];
    }
    
    // Horizontal Rule
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarHorizontalRule]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *hr = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSShorizontalrule.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setHR)];
        hr.label = @"horizontalRule";
        [items addObject:hr];
    }
    
    // Indent
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarIndent]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *indent = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSindent.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setIndent)];
        indent.label = @"indent";
        [items addObject:indent];
    }
    
    // Outdent
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarOutdent]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *outdent = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSoutdent.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setOutdent)];
        outdent.label = @"outdent";
        [items addObject:outdent];
    }
    
    // Image
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarInsertImage]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *insertImage = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSimage.png"] style:UIBarButtonItemStylePlain target:self action:@selector(selectImage)];
        insertImage.label = @"image";
        [items addObject:insertImage];
    }
    
    // Insert Link
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarInsertLink]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *insertLink = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSlink.png"] style:UIBarButtonItemStylePlain target:self action:@selector(insertLink)];
        insertLink.label = @"link";
        [items addObject:insertLink];
    }
    
    // Remove Link
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarRemoveLink]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *removeLink = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSunlink.png"] style:UIBarButtonItemStylePlain target:self action:@selector(removeLink)];
        removeLink.label = @"removeLink";
        [items addObject:removeLink];
    }
    
    // Quick Link
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarQuickLink]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *quickLink = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSquicklink.png"] style:UIBarButtonItemStylePlain target:self action:@selector(quickLink)];
        quickLink.label = @"quickLink";
        [items addObject:quickLink];
    }
    
    // Show Source
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarViewSource]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *showSource = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSviewsource.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showHTMLSource:)];
        showSource.label = @"source";
        [items addObject:showSource];
    }
    
    return [NSArray arrayWithArray:items];
    
}
*/
/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
*/

#pragma mark - Editor Interaction

- (void)dismissKeyboard {
    [self endEditing:YES];
}

- (void)focusTextEditor {
//    self.editorView.keyboardDisplayRequiresUserAction = NO;
//    NSString *js = @"var editor = $('#zss_editor_content'); editor.focus();";
    NSString *js = [NSString stringWithFormat:@"zss_editor.focusEditor();"];
    [self.editorView stringByEvaluatingJavaScriptFromString:js];
}

- (void)blurTextEditor {
    NSString *js = [NSString stringWithFormat:@"zss_editor.blurEditor();"];
    [self.editorView stringByEvaluatingJavaScriptFromString:js];
}

- (void)setHTML:(NSString *)html {
    self.internalHTML = html;
    if (self.editorLoaded) {
        [self updateHTML];
    }
}

- (void)updateHTML {
    NSString *html = self.internalHTML;
    self.sourceView.text = html;
    NSString *cleanedHTML = [self removeQuotesFromHTML:self.sourceView.text];
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.setHTML(\"%@\");", cleanedHTML];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (NSString *)getHTML {
    NSString *html = [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.getHTML();"];
    html = [self removeQuotesFromHTML:html];
    html = [self tidyHTML:html];
    return html;
}

- (void)insertHTML:(NSString *)html {
    NSString *cleanedHTML = [self removeQuotesFromHTML:html];
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertHTML(\"%@\");", cleanedHTML];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (NSString *)getText {
    return [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.getText();"];
}

- (void)showHTMLSource {
    if (self.sourceView.hidden) {
        self.sourceView.text = [self getHTML];
        self.sourceView.hidden = NO;
//        barButtonItem.tintColor = [UIColor blackColor];
        self.editorView.hidden = YES;
//        [self enableToolbarItems:NO];
    } else {
        [self setHTML:self.sourceView.text];
//        barButtonItem.tintColor = [self barButtonItemDefaultColor];
        self.sourceView.hidden = YES;
        self.editorView.hidden = NO;
//        [self enableToolbarItems:YES];
    }
}

- (void)testAction:(UIButton *)sender {
    UICollectionViewLayoutAttributes *attributes = [self.flowLayout initialLayoutAttributesForAppearingItemAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
//    self.collectionView.contentOffset.x
    DLog(@"btn frame %@", NSStringFromCGRect(attributes.frame));
    CGRect real = attributes.frame;
    real.origin.x = attributes.frame.origin.x - self.collectionView.contentOffset.x;
    DLog(@"real frame %@", NSStringFromCGRect(real));
}

- (void)removeFormat {
    NSString *trigger = @"zss_editor.removeFormating();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)alignLeft {
    NSString *trigger = @"zss_editor.setJustifyLeft();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    
//    [self.flowLayout initialLayoutAttributesForAppearingItemAtIndexPath:]
//    initialLayoutAttributesForAppearingItemAtIndexPath
}

- (void)alignCenter {
    NSString *trigger = @"zss_editor.setJustifyCenter();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)alignRight {
    NSString *trigger = @"zss_editor.setJustifyRight();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)alignFull {
    NSString *trigger = @"zss_editor.setJustifyFull();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setBold {
    NSString *trigger = @"zss_editor.setBold();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setItalic {
    NSString *trigger = @"zss_editor.setItalic();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setSubscript {
    NSString *trigger = @"zss_editor.setSubscript();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setUnderline {
    NSString *trigger = @"zss_editor.setUnderline();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setSuperscript {
    NSString *trigger = @"zss_editor.setSuperscript();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setStrikethrough {
    NSString *trigger = @"zss_editor.setStrikeThrough();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setUnorderedList {
    NSString *trigger = @"zss_editor.setUnorderedList();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setOrderedList {
    NSString *trigger = @"zss_editor.setOrderedList();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setHR {
    NSString *trigger = @"zss_editor.setHorizontalRule();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setIndent {
    NSString *trigger = @"zss_editor.setIndent();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setOutdent {
    NSString *trigger = @"zss_editor.setOutdent();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)heading1 {
    NSString *trigger = @"zss_editor.setHeading('h1');";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)heading2 {
    NSString *trigger = @"zss_editor.setHeading('h2');";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)heading3 {
    NSString *trigger = @"zss_editor.setHeading('h3');";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)heading4 {
    NSString *trigger = @"zss_editor.setHeading('h4');";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)heading5 {
    NSString *trigger = @"zss_editor.setHeading('h5');";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)heading6 {
    NSString *trigger = @"zss_editor.setHeading('h6');";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)paragraph {
    NSString *trigger = @"zss_editor.setParagraph();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)textColor {
    // Save the selection location
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.prepareInsert();"];
    ZSSColorPicker *colorPicker = [[ZSSColorPicker alloc] initWithColor:self.currentTextColor];
    colorPicker.delegate = self;
    colorPicker.view.tag = 1;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:colorPicker];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
//    [self.navigationController pushViewController:colorPicker animated:YES];
    /*
    MSColorSelectionViewController *colorPicker = [[MSColorSelectionViewController alloc] init];
    colorPicker.delegate = self;
    colorPicker.view.tag = 1;
    if (self.currentTextColor) {
        colorPicker.color = self.currentTextColor;
    } else {
        colorPicker.color = [UIColor blackColor];
    }
    [self.navigationController pushViewController:colorPicker animated:YES];
    */
    // Call the picker
//    HRColorPickerViewController *colorPicker = [HRColorPickerViewController cancelableFullColorPickerViewControllerWithColor:[UIColor whiteColor]];
//    colorPicker.delegate = self;
//    colorPicker.tag = 1;
//    colorPicker.title = NSLocalizedString(@"Text Color", nil);
//    [self.navigationController pushViewController:colorPicker animated:YES];
    
}

- (void)bgColor {
    // Save the selection location
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.prepareInsert();"];
    
    ZSSColorPicker *colorPicker = [[ZSSColorPicker alloc] initWithColor:self
                                   .currentBgColor];
    colorPicker.delegate = self;
    colorPicker.view.tag = 2;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:colorPicker];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
//    [self.navigationController pushViewController:colorPicker animated:YES];
    
    // Call the picker
//    HRColorPickerViewController *colorPicker = [HRColorPickerViewController cancelableFullColorPickerViewControllerWithColor:[UIColor whiteColor]];
//    colorPicker.delegate = self;
//    colorPicker.tag = 2;
//    colorPicker.title = NSLocalizedString(@"BG Color", nil);
//    [self.navigationController pushViewController:colorPicker animated:YES];
}

- (void)undo:(ZSSBarButtonItem *)barButtonItem {
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.undo();"];
}

- (void)redo:(ZSSBarButtonItem *)barButtonItem {
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.redo();"];
}
/*
- (void)insertLink {
    
    // Save the selection location
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.prepareInsert();"];
    
    // Show the dialog for inserting or editing a link
    [self showInsertLinkDialogWithLink:self.selectedLinkURL title:self.selectedLinkTitle];
    
}


- (void)showInsertLinkDialogWithLink:(NSString *)url title:(NSString *)title {
    
    // Insert Button Title
    NSString *insertButtonTitle = !self.selectedLinkURL ? NSLocalizedString(@"Insert", nil) : NSLocalizedString(@"Update", nil);
    
    // Picker Button
    UIButton *am = [UIButton buttonWithType:UIButtonTypeCustom];
    am.frame = CGRectMake(0, 0, 25, 25);
    [am setImage:[UIImage imageNamed:@"ZSSpicker.png"] forState:UIControlStateNormal];
    [am addTarget:self action:@selector(showInsertURLAlternatePicker) forControlEvents:UIControlEventTouchUpInside];
    
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Insert Link", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"URL (required)", nil);
            if (url) {
                textField.text = url;
            }
            textField.rightView = am;
            textField.rightViewMode = UITextFieldViewModeAlways;
            textField.clearButtonMode = UITextFieldViewModeAlways;
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"Title", nil);
            textField.clearButtonMode = UITextFieldViewModeAlways;
            textField.secureTextEntry = NO;
            if (title) {
                textField.text = title;
            }
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self focusTextEditor];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:insertButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            UITextField *linkURL = [alertController.textFields objectAtIndex:0];
            UITextField *title = [alertController.textFields objectAtIndex:1];
            if (!self.selectedLinkURL) {
                [self insertLink:linkURL.text title:title.text];
                DLog(@"insert link");
            } else {
                [self updateLink:linkURL.text title:title.text];
            }
            [self focusTextEditor];
        }]];
        [self.navigationController presentViewController:alertController animated:YES completion:NULL];
        
    } else {
        
        self.alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Insert Link", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:insertButtonTitle, nil];
        self.alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        self.alertView.tag = 2;
        UITextField *linkURL = [self.alertView textFieldAtIndex:0];
        linkURL.placeholder = NSLocalizedString(@"URL (required)", nil);
        if (url) {
            linkURL.text = url;
        }
        
        linkURL.rightView = am;
        linkURL.rightViewMode = UITextFieldViewModeAlways;
        
        UITextField *alt = [self.alertView textFieldAtIndex:1];
        alt.secureTextEntry = NO;
        alt.placeholder = NSLocalizedString(@"Title", nil);
        if (title) {
            alt.text = title;
        }
        
        [self.alertView show];
    }
}
*/

- (void)insertLink:(NSString *)url title:(NSString *)title {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertLink(\"%@\", \"%@\");", url, title];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)updateLink:(NSString *)url title:(NSString *)title {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.updateLink(\"%@\", \"%@\");", url, title];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)dismissAlertView {
    [self.alertView dismissWithClickedButtonIndex:self.alertView.cancelButtonIndex animated:YES];
}

- (void)removeLink {
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.unlink();"];
}//end

- (void)quickLink {
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.quickLink();"];
}

- (void)selectImage {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选择", nil];
    actionSheet.tag = kActionSheetInsertImageTag;
    [actionSheet showInView:self];
}

- (void)takePhoto {
    [self backupRange];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    [picker setAllowsEditing:YES];
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

- (void)selectImageFromAlbum {
    [self backupRange];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

- (void)selectVideo {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍摄",@"从相册选择", nil];
    actionSheet.tag = kActionSheetInsertVideoTag;
    [actionSheet showInView:self];
}

- (void)selectVideoFromAlbum {
    [self backupRange];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = @[(NSString *)kUTTypeMovie];
    picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

- (void)shootVideo {
    [self backupRange];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//        picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    }
    picker.mediaTypes = @[(NSString *)kUTTypeMovie];
    picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

- (void)showRecordView {
    [self backupRange];
    
    [self endEditing:YES];
    
//    UIView *maskView = [[UIView alloc] initWithFrame:self.view.window.frame];
//    maskView.tag = kMaskViewTag;
//    maskView.backgroundColor = HEXACOLOR(0x000000, 0.6);
//    [maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMask)]];
//    [self.view.window addSubview:maskView];
    
    [ZSSRecordView showInView:self.window finish:^(NSString *path) {
        [self insertMP3:[NSURL fileURLWithPath:path].absoluteString];
    }];
//    recordView.center = CGPointMake(self.view.window.center.x, CGRectGetHeight(self.view.window.frame) - CGRectGetHeight(recordView.frame));
//    [maskView addSubview:recordView];
    
    /*
    [recordView setCompletion:^(BOOL finish, NSString *path) {
//        [recordView removeFromSuperview];
        [maskView removeFromSuperview];
        if (finish) {
//            NSLog(@"mp3 path");
            [self insertMP3:[NSURL fileURLWithPath:path].absoluteString];
        }
    }];
    */
}

/*
- (void)didTapMask {
    UIView *maskView = [self.view.window viewWithTag:kMaskViewTag];
    [maskView removeFromSuperview];
}
*/

- (void)insertImage {
    // Save the selection location
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.prepareInsert();"];
    [self showInsertImageDialogWithLink:self.selectedImageURL alt:self.selectedImageAlt];
}

- (void)showInsertImageDialogWithLink:(NSString *)url alt:(NSString *)alt {
    // Insert Button Title
    NSString *insertButtonTitle = !self.selectedImageURL ? NSLocalizedString(@"Insert", nil) : NSLocalizedString(@"Update", nil);
    
    // Picker Button
    UIButton *am = [UIButton buttonWithType:UIButtonTypeCustom];
    am.frame = CGRectMake(0, 0, 25, 25);
    [am setImage:[UIImage imageNamed:@"ZSSpicker.png"] forState:UIControlStateNormal];
    [am addTarget:self action:@selector(showInsertImageAlternatePicker) forControlEvents:UIControlEventTouchUpInside];
    
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Insert Image", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"URL (required)", nil);
            if (url) {
                textField.text = url;
            }
            textField.rightView = am;
            textField.rightViewMode = UITextFieldViewModeAlways;
            textField.clearButtonMode = UITextFieldViewModeAlways;
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"Alt", nil);
            textField.clearButtonMode = UITextFieldViewModeAlways;
            textField.secureTextEntry = NO;
            if (alt) {
                textField.text = alt;
            }
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self focusTextEditor];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:insertButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UITextField *imageURL = [alertController.textFields objectAtIndex:0];
            UITextField *alt = [alertController.textFields objectAtIndex:1];
            if (!self.selectedImageURL) {
                [self insertImage:imageURL.text alt:alt.text];
            } else {
                [self updateImage:imageURL.text alt:alt.text];
            }
            [self focusTextEditor];
        }]];
        [self.navigationController presentViewController:alertController animated:YES completion:NULL];
        
    } else {
        
        self.alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Insert Image", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:insertButtonTitle, nil];
        self.alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        self.alertView.tag = 1;
        UITextField *imageURL = [self.alertView textFieldAtIndex:0];
        imageURL.placeholder = NSLocalizedString(@"URL (required)", nil);
        if (url) {
            imageURL.text = url;
        }
        
        imageURL.rightView = am;
        imageURL.rightViewMode = UITextFieldViewModeAlways;
        imageURL.clearButtonMode = UITextFieldViewModeAlways;
        
        UITextField *alt1 = [self.alertView textFieldAtIndex:1];
        alt1.secureTextEntry = NO;
        alt1.placeholder = NSLocalizedString(@"Alt", nil);
        alt1.clearButtonMode = UITextFieldViewModeAlways;
        if (alt) {
            alt1.text = alt;
        }
        
        [self.alertView show];
    }
}

- (void)insertMP3:(NSString *)url {
//    [self restoreRange];
//    [self backupRange];
    NSString *trigger = [NSString stringWithFormat:@"zss_extend.insertMP3(\"%@\");", url];
    DLog(@"insertMP3 url %@", url);
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)insertVideo:(NSString *)url {
//    [self restoreRange];
    NSString *trigger = [NSString stringWithFormat:@"zss_extend.insertVideo(\"%@\");", url];
    DLog(@"url %@", url);
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)insertImage:(NSString *)url alt:(NSString *)alt {
//    [self restoreRange];
    NSString *trigger = [NSString stringWithFormat:@"zss_extend.insertImage(\"%@\", \"%@\");", url, alt];
//    NSLog(@"url %@", url);
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)updateImage:(NSString *)url alt:(NSString *)alt {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.updateImage(\"%@\", \"%@\");", url, alt];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

/*
- (void)updateToolBarWithButtonName:(NSString *)name {
    
    // Items that are enabled
    NSArray *itemNames = [name componentsSeparatedByString:@","];
    
    // Special case for link
    NSMutableArray *itemsModified = [[NSMutableArray alloc] init];
    for (NSString *linkItem in itemNames) {
        NSString *updatedItem = linkItem;
        if ([linkItem hasPrefix:@"link:"]) {
            updatedItem = @"link";
            self.selectedLinkURL = [linkItem stringByReplacingOccurrencesOfString:@"link:" withString:@""];
        } else if ([linkItem hasPrefix:@"link-title:"]) {
            self.selectedLinkTitle = [self stringByDecodingURLFormat:[linkItem stringByReplacingOccurrencesOfString:@"link-title:" withString:@""]];
        } else if ([linkItem hasPrefix:@"image:"]) {
            updatedItem = @"image";
            self.selectedImageURL = [linkItem stringByReplacingOccurrencesOfString:@"image:" withString:@""];
        } else if ([linkItem hasPrefix:@"image-alt:"]) {
            self.selectedImageAlt = [self stringByDecodingURLFormat:[linkItem stringByReplacingOccurrencesOfString:@"image-alt:" withString:@""]];
        } else {
            self.selectedImageURL = nil;
            self.selectedImageAlt = nil;
            self.selectedLinkURL = nil;
            self.selectedLinkTitle = nil;
        }
        [itemsModified addObject:updatedItem];
    }
    itemNames = [NSArray arrayWithArray:itemsModified];
    
    self.editorItemsEnabled = itemNames;
    
    // Highlight items
    NSArray *items = self.toolbar.items;
    for (ZSSBarButtonItem *item in items) {
        if ([itemNames containsObject:item.label]) {
            item.tintColor = [self barButtonItemSelectedDefaultColor];
        } else {
            item.tintColor = [self barButtonItemDefaultColor];
        }
    }//end
    
}
*/
- (void)backupRange {
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.backuprange();"];
}

- (void)restoreRange {
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.restorerange();"];
}

- (void)debug:(NSString *)msg {
    [self.editorView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"zss_editor.debug('%@');", msg]];
}

- (NSArray *)getLocalPaths {
    NSString *json = [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_extend.getAllImageLinks();"];
    NSArray *links = [NSMutableArray arrayWithArray:[json toJsonArray]];
    NSMutableArray *loaclPaths = [NSMutableArray array];
    [links enumerateObjectsUsingBlock:^(NSString *link, NSUInteger idx, BOOL *stop) {
        if ([link hasPrefix:@"file://"]) {
            [loaclPaths addObject:link];
        }
    }];
    return loaclPaths;
}
/*
+ (NSArray *)localPathsInHtml:(NSString *)html {
    ZSSRichTextEditor *editor = [[ZSSRichTextEditor alloc] init];
    [editor setHTML:html];
    [editor updateHTML];
    return [editor getLocalPaths];
}

+ (NSString *)getRawTextInHtml:(NSString *)html {
    ZSSRichTextEditor *editor = [[ZSSRichTextEditor alloc] init];
    [editor setHTML:html];
    [editor updateHTML];
    return [editor getText];
}
*/

#pragma mark - UITextView Delegate

- (void)textViewDidChange:(UITextView *)textView {
    CGRect line = [textView caretRectForPosition:textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height - ( textView.contentOffset.y + textView.bounds.size.height - textView.contentInset.bottom - textView.contentInset.top );
    if ( overflow > 0 ) {
        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
        // Scroll caret to visible area
        CGPoint offset = textView.contentOffset;
        offset.y += overflow + 7; // leave 7 pixels margin
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [UIView animateWithDuration:.2 animations:^{
            [textView setContentOffset:offset];
        }];
    }
}


#pragma mark - UIWebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = [[request URL] absoluteString];
//    NSLog(@"web request");
//    NSLog(@"urlString %@", urlString);
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        return NO;
    } else if ([urlString rangeOfString:@"callback://0/"].location != NSNotFound) {
        
        // We recieved the callback
        NSString *styleString = [urlString stringByReplacingOccurrencesOfString:@"callback://0/" withString:@""];
//        [self updateToolBarWithButtonName:styleString];
        
        if ([self.delegate respondsToSelector:@selector(selectionChangeWithStyle:)]) {
            [self.delegate selectionChangeWithStyle:styleString];
        }
        NSArray *styles = [styleString componentsSeparatedByString:@","];
        self.currentBgColor = nil;
        self.currentTextColor = nil;
        for (NSString *style in styles) {
            if ([style rangeOfString:@"backgroundColor"].location != NSNotFound) {
                NSString *str = [style stringByReplacingOccurrencesOfString:@"backgroundColor:" withString:@""];
//                unsigned long red = strtoul([str UTF8String],0,16);
//                NSLog(@"%@", @(red));
                self.currentBgColor = [UIColor colorWithHexString:str];
            }
            if ([style rangeOfString:@"textColor"].location != NSNotFound) {
                NSString *str = [style stringByReplacingOccurrencesOfString:@"textColor:" withString:@""];
                self.currentTextColor = [UIColor colorWithHexString:str];
//                unsigned long red = strtoul([str UTF8String],0,16);
//                NSLog(@"%@", @(red));
            }
        }
//        self.currentTextColor;
//        self.currentBgColor;
        
        
    } else if ([urlString rangeOfString:@"debug://"].location != NSNotFound) {
        
        // We recieved the callback
        NSString *debug = [urlString stringByReplacingOccurrencesOfString:@"debug://" withString:@""];
        debug = [debug stringByReplacingPercentEscapesUsingEncoding:NSStringEncodingConversionAllowLossy];
        DLog(@"%@", debug);
        
    } else if ([urlString rangeOfString:@"scroll://"].location != NSNotFound) {
        
        NSInteger position = [[urlString stringByReplacingOccurrencesOfString:@"scroll://" withString:@""] integerValue];
        [self editorDidScrollWithPosition:position];
        
    }
    
    return YES;
    
}//end


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //[self setPlaceholderText];
    if (!self.editorLoaded) {
        if (!self.internalHTML) {
            self.internalHTML = @"";
        }
        
        [self updateHTML];
        if (self.shouldShowKeyboard) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self focusTextEditor];
            });
        }
        self.editorLoaded = YES;
    }
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kActionSheetInsertImageTag) {
        if (buttonIndex == 0) {
            [self takePhoto];
        } else if (buttonIndex == 1) {
            [self selectImageFromAlbum];
        }
    } else if (actionSheet.tag == kActionSheetInsertVideoTag) {
        if (buttonIndex == 0) {
            [self shootVideo];
        } else if (buttonIndex == 1) {
            [self selectVideoFromAlbum];
        }
    }
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //extracting image from the picker and saving it
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *) kUTTypeImage] || [mediaType isEqualToString:ALAssetTypePhoto]) {
        NSString *fileName = [NSString stringWithFormat:@"%f.%@", [[NSDate date] timeIntervalSince1970], @"jpg"];
        NSString *filePath = [self.tmpDir stringByAppendingPathComponent:fileName];
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        NSData *webData = UIImageJPEGRepresentation(image, 0.5);
        [webData writeToFile:filePath atomically:YES];
        
        NSURL *url = [NSURL fileURLWithPath:filePath];
        [self restoreRange];
        [self insertImage:url.absoluteString alt:@""];
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *url = info[UIImagePickerControllerMediaURL];
        DLog(@"video url %@", url.absoluteString);
        [self restoreRange];
        [self insertVideo:url.absoluteString];
        
        /*
         //获取缩略图
         MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:url];
         UIImage *thumbnail = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
         */
        /*
         // 将视频保存到相册中
         ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
         [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:url
         completionBlock:^(NSURL *assetURL, NSError *error) {
         if (!error) {
         NSLog(@"captured video saved with no error.");
         }else{
         NSLog(@"error occured while saving the video:%@", error);
         }
         }];
         */
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
/*
#pragma mark - HRColorPickerDelegate

- (void)setSelectedColor:(UIColor*)color tag:(int)tag {
    
    NSString *hex = [NSString stringWithFormat:@"#%06x",HexColorFromUIColor(color)];
    NSString *trigger;
    if (tag == 1) {
        trigger = [NSString stringWithFormat:@"zss_editor.setTextColor(\"%@\");", hex];
    } else if (tag == 2) {
        trigger = [NSString stringWithFormat:@"zss_editor.setBackgroundColor(\"%@\");", hex];
    }
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    
}
*/
/*
#pragma mark - MSColorPickerDelegate

- (void)colorViewController:(MSColorSelectionViewController *)colorViewCntroller didChangeColor:(UIColor *)color {
    NSString *hex = [NSString stringWithFormat:@"#%06x",HexColorFromUIColor(color)];
    NSString *trigger;
    if (colorViewCntroller.view.tag == 1) {
        trigger = [NSString stringWithFormat:@"zss_editor.setTextColor(\"%@\");", hex];
    } else if (colorViewCntroller.view.tag == 2) {
        trigger = [NSString stringWithFormat:@"zss_editor.setBackgroundColor(\"%@\");", hex];
    }
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}
*/
#pragma mark - ZSSColorPickerDelegate

- (void)colorPicker:(ZSSColorPicker *)colorPicker didPickerColor:(UIColor *)color {
    NSString *hex = [NSString stringWithFormat:@"#%06x",HexColorFromUIColor(color)];
    NSString *trigger;
    if (colorPicker.view.tag == 1) {
        trigger = [NSString stringWithFormat:@"zss_editor.setTextColor(\"%@\");", hex];
    } else if (colorPicker.view.tag == 2) {
        trigger = [NSString stringWithFormat:@"zss_editor.setBackgroundColor(\"%@\");", hex];
    }
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}


#pragma mark - Callbacks

// Blank implementation
- (void)editorDidScrollWithPosition:(NSInteger)position {
    
}

#pragma mark - AlertView

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    
    if (alertView.tag == 1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        UITextField *textField2 = [alertView textFieldAtIndex:1];
        if ([textField.text length] == 0 || [textField2.text length] == 0) {
            return NO;
        }
    } else if (alertView.tag == 2) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        if ([textField.text length] == 0) {
            return NO;
        }
    }
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            UITextField *imageURL = [alertView textFieldAtIndex:0];
            UITextField *alt = [alertView textFieldAtIndex:1];
            if (!self.selectedImageURL) {
                [self insertImage:imageURL.text alt:alt.text];
            } else {
                [self updateImage:imageURL.text alt:alt.text];
            }
        }
    } else if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            UITextField *linkURL = [alertView textFieldAtIndex:0];
            UITextField *title = [alertView textFieldAtIndex:1];
            if (!self.selectedLinkURL) {
                [self insertLink:linkURL.text title:title.text];
            } else {
                [self updateLink:linkURL.text title:title.text];
            }
        }
    }
}


#pragma mark - Asset Picker

- (void)showInsertURLAlternatePicker {
    // Blank method. User should implement this in their subclass
}


- (void)showInsertImageAlternatePicker {
    // Blank method. User should implement this in their subclass
}

- (BOOL)findFirstResponderInView:(UIView *)view {
    if (view.isFirstResponder) {
        return YES;
    } else {
        for (UIView *subview in view.subviews) {
            if ([self findFirstResponderInView:subview]) {
                return YES;
            }
//            if (subview.isFirstResponder) {
//                NSLog(@"%@", subview);
//                return YES;
//            } else {
//                return <#expression#>
//            }
        }
    }
    return NO;
}

- (BOOL)isFirstResponder {
    return [self findFirstResponderInView:self.editorView];
}

#pragma mark - Keyboard Notification

- (void)keyboardWillShow:(NSNotification *)notification {
    
    [self isFirstResponder];
    
//    CGRect rect1 = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect rect2 = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat during = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showToolBarInView:self.window frame:CGRectMake(0, CGRectGetMinY(rect2) - 44, kScreenWidth, 44) during:during];
    });
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self removeToolbar];
}

#pragma mark - Utilities

- (NSString *)stringByDecodingURLFormat:(NSString *)string {
    NSString *result = [string stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

- (NSString *)removeQuotesFromHTML:(NSString *)html {
    html = [html stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    html = [html stringByReplacingOccurrencesOfString:@"“" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"”" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"\r"  withString:@"\\r"];
    html = [html stringByReplacingOccurrencesOfString:@"\n"  withString:@"\\n"];
    return html;
}//end


- (NSString *)tidyHTML:(NSString *)html {
    html = [html stringByReplacingOccurrencesOfString:@"<br>" withString:@"<br />"];
    html = [html stringByReplacingOccurrencesOfString:@"<hr>" withString:@"<hr />"];
    if (self.formatHTML) {
        html = [self.editorView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"style_html(\"%@\");", html]];
    }
    return html;
}//end

/*
- (UIColor *)barButtonItemDefaultColor {
    if (self.toolbarItemTintColor) {
        return self.toolbarItemTintColor;
    }
    return [UIColor colorWithRed:0.0f/255.0f green:122.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
}


- (UIColor *)barButtonItemSelectedDefaultColor {
    if (self.toolbarItemSelectedTintColor) {
        return self.toolbarItemSelectedTintColor;
    }
    return [UIColor blackColor];
}
*/
- (void)showToolBarInView:(UIView *)view frame:(CGRect)frame {
    [self showToolBarInView:view frame:frame during:0.35];
}

- (void)showToolBarInView:(UIView *)view frame:(CGRect)frame during:(CGFloat)during {
    DLog(@"during %@", @(during));
    
    [view addSubview:self.actionView];
    
    CGRect rect = frame;
    rect.origin.y = CGRectGetMaxY(view.frame);
    self.actionView.frame = rect;
    DLog(@"rect1 %@", NSStringFromCGRect(rect));
    
    [UIView animateWithDuration:during animations:^{
        self.actionView.frame = frame;
        DLog(@"rect2 %@", NSStringFromCGRect(frame));
    }];
}

- (void)removeToolbar {
    [self.actionView removeFromSuperview];
}

#pragma mark - CollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.toolbarBtns.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionViewIdentifier forIndexPath:indexPath];
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    [cell.contentView addSubview:self.toolbarBtns[indexPath.row]];
    //    cell.backgroundColor = HEXCOLOR(0x2be7e9);
    
//    UICollectionViewLayoutAttributes *atrbs = [self.flowLayout initialLayoutAttributesForAppearingItemAtIndexPath:indexPath];
//    atrbs.frame
//    DLog(@"frame %@", NSStringFromCGRect(atrbs.frame));
    return cell;
}

#pragma mark - CollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    /*
    [self.browser reloadData];
    [self.browser setCurrentPhotoIndex:indexPath.row];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:self.browser];
    [nc.navigationBar setBarTintColor:[UIColor whiteColor]];
    [nc.navigationBar setTitleTextAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:20],
                                               NSForegroundColorAttributeName : [UIColor whiteColor]
                                               }];
    [nc.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    [nc.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
    */
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark - Properties

- (NSString *)tmpDir {
    if (!_tmpDir) {
        _tmpDir = NSTemporaryDirectory();
    }
    return _tmpDir;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        CGFloat width = kScreenWidth/7.0;
        CGFloat height = 44;
        flowLayout.itemSize = CGSizeMake(width, height);
//        flowLayout.headerReferenceSize = CGSizeMake(kScreenWidth, 10);
//        flowLayout.footerReferenceSize = CGSizeMake(kScreenWidth, 10);
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
//        flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        _flowLayout = flowLayout;
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:collectionViewIdentifier];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.showsVerticalScrollIndicator = NO;
        _collectionView = collectionView;
    }
    return _collectionView;
}


@end
