//
//  ZSSRichTextEditorViewController.h
//  ZSSRichTextEditor
//
//  Created by Nicholas Hubbard on 11/30/13.
//  Copyright (c) 2013 Zed Said Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRColorPickerViewController.h"

/**
 *  The types of toolbar items that can be added
 */
static NSString * const ZSSRichTextEditorToolbarBold = @"com.zedsaid.toolbaritem.bold";
static NSString * const ZSSRichTextEditorToolbarItalic = @"com.zedsaid.toolbaritem.italic";
static NSString * const ZSSRichTextEditorToolbarSubscript = @"com.zedsaid.toolbaritem.subscript";
static NSString * const ZSSRichTextEditorToolbarSuperscript = @"com.zedsaid.toolbaritem.superscript";
static NSString * const ZSSRichTextEditorToolbarStrikeThrough = @"com.zedsaid.toolbaritem.strikeThrough";
static NSString * const ZSSRichTextEditorToolbarUnderline = @"com.zedsaid.toolbaritem.underline";
static NSString * const ZSSRichTextEditorToolbarRemoveFormat = @"com.zedsaid.toolbaritem.removeFormat";
static NSString * const ZSSRichTextEditorToolbarJustifyLeft = @"com.zedsaid.toolbaritem.justifyLeft";
static NSString * const ZSSRichTextEditorToolbarJustifyCenter = @"com.zedsaid.toolbaritem.justifyCenter";
static NSString * const ZSSRichTextEditorToolbarJustifyRight = @"com.zedsaid.toolbaritem.justifyRight";
static NSString * const ZSSRichTextEditorToolbarJustifyFull = @"com.zedsaid.toolbaritem.justifyFull";
static NSString * const ZSSRichTextEditorToolbarH1 = @"com.zedsaid.toolbaritem.h1";
static NSString * const ZSSRichTextEditorToolbarH2 = @"com.zedsaid.toolbaritem.h2";
static NSString * const ZSSRichTextEditorToolbarH3 = @"com.zedsaid.toolbaritem.h3";
static NSString * const ZSSRichTextEditorToolbarH4 = @"com.zedsaid.toolbaritem.h4";
static NSString * const ZSSRichTextEditorToolbarH5 = @"com.zedsaid.toolbaritem.h5";
static NSString * const ZSSRichTextEditorToolbarH6 = @"com.zedsaid.toolbaritem.h6";
static NSString * const ZSSRichTextEditorToolbarTextColor = @"com.zedsaid.toolbaritem.textColor";
static NSString * const ZSSRichTextEditorToolbarBackgroundColor = @"com.zedsaid.toolbaritem.backgroundColor";
static NSString * const ZSSRichTextEditorToolbarUnorderedList = @"com.zedsaid.toolbaritem.unorderedList";
static NSString * const ZSSRichTextEditorToolbarOrderedList = @"com.zedsaid.toolbaritem.orderedList";
static NSString * const ZSSRichTextEditorToolbarHorizontalRule = @"com.zedsaid.toolbaritem.horizontalRule";
static NSString * const ZSSRichTextEditorToolbarIndent = @"com.zedsaid.toolbaritem.indent";
static NSString * const ZSSRichTextEditorToolbarOutdent = @"com.zedsaid.toolbaritem.outdent";
static NSString * const ZSSRichTextEditorToolbarInsertImage = @"com.zedsaid.toolbaritem.insertImage";
static NSString * const ZSSRichTextEditorToolbarInsertLink = @"com.zedsaid.toolbaritem.insertLink";
static NSString * const ZSSRichTextEditorToolbarRemoveLink = @"com.zedsaid.toolbaritem.removeLink";
static NSString * const ZSSRichTextEditorToolbarQuickLink = @"com.zedsaid.toolbaritem.quickLink";
static NSString * const ZSSRichTextEditorToolbarUndo = @"com.zedsaid.toolbaritem.undo";
static NSString * const ZSSRichTextEditorToolbarRedo = @"com.zedsaid.toolbaritem.redo";
static NSString * const ZSSRichTextEditorToolbarViewSource = @"com.zedsaid.toolbaritem.viewSource";
static NSString * const ZSSRichTextEditorToolbarParagraph = @"com.zedsaid.toolbaritem.paragraph";
static NSString * const ZSSRichTextEditorToolbarAll = @"com.zedsaid.toolbaritem.all";
static NSString * const ZSSRichTextEditorToolbarNone = @"com.zedsaid.toolbaritem.none";

@class ZSSBarButtonItem;

@protocol ZSSRichTextEditorDelegate <NSObject>

@optional
- (UIButton *)keyboardButton;

@end

/**
 *  The viewController used with ZSSRichTextEditor
 */
@interface ZSSRichTextEditor : UIView <UIWebViewDelegate, HRColorPickerViewControllerDelegate, UITextViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, weak)   id<ZSSRichTextEditorDelegate> delegate;

@property (nonatomic, strong) UIWebView *editorView;

@property (nonatomic, strong) UIView *toolbarHolder;

/**
 *  The base URL to use for the webView
 */
@property (nonatomic, strong) NSURL *baseURL;

/**
 *  If the HTML should be formatted to be pretty
 */
@property (nonatomic) BOOL formatHTML;

/**
 *  If the keyboard should be shown when the editor loads
 */
@property (nonatomic) BOOL shouldShowKeyboard;

/**
 *  The placeholder text to use if there is no editor content
 */
@property (nonatomic, strong) NSString *placeholder;

/**
 *  Toolbar items to include
 */
@property (nonatomic, strong) NSArray *enabledToolbarItems;

/**
 *  Color to tint the toolbar items
 */
@property (nonatomic, strong) UIColor *toolbarItemTintColor;

/**
 *  Color to tint selected items
 */
@property (nonatomic, strong) UIColor *toolbarItemSelectedTintColor;


@property (nonatomic, strong) UINavigationController *navigationController;

@property (nonatomic, strong) NSString *tmpDir;

- (id)initWithFrame:(CGRect)frame navigationController:(UINavigationController *)navgationController delegate:(id<ZSSRichTextEditorDelegate>)delegate;

/**
 *  Sets the HTML for the entire editor
 *
 *  @param html  HTML string to set for the editor
 *
 */
- (void)setHTML:(NSString *)html;

/**
 *  Returns the HTML from the Rich Text Editor
 *
 */
- (NSString *)getHTML;

/**
 *  Returns the plain text from the Rich Text Editor
 *
 */
- (NSString *)getText;

/**
 *  Inserts HTML at the caret position
 *
 *  @param html  HTML string to insert
 *
 */
- (void)insertHTML:(NSString *)html;

/**
 *  Manually focuses on the text editor
 */
- (void)focusTextEditor;

/**
 *  Manually dismisses on the text editor
 */
- (void)blurTextEditor;

/**
 *  Shows the insert image dialog with optinal inputs
 *
 *  @param url The URL for the image
 *  @param alt The alt for the image
 */
- (void)showInsertImageDialogWithLink:(NSString *)url alt:(NSString *)alt;

/**
 *  Inserts an image
 *
 *  @param url The URL for the image
 *  @param alt The alt attribute for the image
 */
- (void)insertImage:(NSString *)url alt:(NSString *)alt;

/**
 *  Shows the insert link dialog with optional inputs
 *
 *  @param url   The URL for the link
 *  @param title The tile for the link
 */
- (void)showInsertLinkDialogWithLink:(NSString *)url title:(NSString *)title;

/**
 *  Inserts a link
 *
 *  @param url The URL for the link
 *  @param title The title for the link
 */
- (void)insertLink:(NSString *)url title:(NSString *)title;

/**
 *  Gets called when the insert URL picker button is tapped in an alertView
 *
 *  @warning The default implementation of this method is blank and does nothing
 */
- (void)showInsertURLAlternatePicker;

/**
 *  Gets called when the insert Image picker button is tapped in an alertView
 *
 *  @warning The default implementation of this method is blank and does nothing
 */
- (void)showInsertImageAlternatePicker;

/**
 *  Dismisses the current AlertView
 */
- (void)dismissAlertView;

/**
 *  Add a custom UIBarButtonItem by using a UIButton
 */
- (void)addCustomToolbarItemWithButton:(UIButton*)button;

/**
 *  Add a custom ZSSBarButtonItem
 */
- (void)addCustomToolbarItem:(ZSSBarButtonItem *)item;

/**
 *  Scroll event callback with position
 */
- (void)editorDidScrollWithPosition:(NSInteger)position;

- (void)backupRange;

- (void)restoreRange;

- (void)debug:(NSString *)msg;

#pragma mark -

- (void)insertMP3:(NSString *)url;

- (void)insertVideo:(NSString *)url;

- (void)selectVideo;

- (void)selectImage;

- (void)showRecordView;

- (void)shootVideo;

- (void)takePhoto;

- (void)selectImageFromAlbum;

- (void)removeFormat;

- (void)alignLeft;

- (void)alignCenter;

- (void)alignRight;

- (void)alignFull;

- (void)setBold;

- (void)setItalic;

- (void)setSubscript;

- (void)setUnderline;

- (void)setSuperscript;

- (void)setStrikethrough;

- (void)setUnorderedList;

- (void)setOrderedList;

- (void)setHR;

- (void)setIndent;

- (void)setOutdent;

- (void)heading1;

- (void)heading2;

- (void)heading3;

- (void)heading4;

- (void)heading5;

- (void)heading6;

- (void)paragraph;

- (void)textColor;

- (void)bgColor;

- (void)setSelectedColor:(UIColor*)color tag:(int)tag;

- (void)undo:(ZSSBarButtonItem *)barButtonItem;

- (void)redo:(ZSSBarButtonItem *)barButtonItem;

- (void)showToolBarInView:(UIView *)view frame:(CGRect)frame;

- (void)removeToolbar;

- (void)showHTMLSource:(ZSSBarButtonItem *)barButtonItem;

- (NSArray *)getLocalPaths;

- (void)enableToolbarItems:(BOOL)enable;

//+ (NSArray *)localPathsInHtml:(NSString *)html;

//+ (NSString *)getRawTextInHtml:(NSString *)html;

@end
