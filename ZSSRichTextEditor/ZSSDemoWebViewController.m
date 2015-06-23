//
//  ZSSDemoWebViewController.m
//  ZSSRichTextEditor
//
//  Created by liu on 15-5-19.
//  Copyright (c) 2015年 Zed Said Studio. All rights reserved.
//

#import "ZSSDemoWebViewController.h"

@interface ZSSDemoWebViewController ()

@property (strong, nonatomic) UIWebView *webView;

@end

@implementation ZSSDemoWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
//
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    DLog(@"frame %@", NSStringFromCGRect(self.view.frame));
    DLog(@"bounds %@", NSStringFromCGRect(self.view.bounds));
    
    self.webView = [UIWebView new];
    self.webView.frame = CGRectMake(0, 0, 375, 603);
    self.webView.scrollView.contentInset = UIEdgeInsetsZero;
//    self.webView.scrollView.bounces = NO;
//    self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
//    self.automaticallyAdjustsScrollViewInsets = YES;
//    self.webView.co
    [self.view addSubview:self.webView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"htm"];
    NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:html baseURL:nil];
}
/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Notification

- (void)keyboardWillShow:(NSNotification *)notification {
    //    NSLog(@"duration %@", notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]);
    CGRect rect1 = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect rect2 = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //        UIView *win = [UIApplication sharedApplication].windows.lastObject;
    NSLog(@"y %@",  @(CGRectGetMinY(rect2) - 44));
    //        self.view.window
    [self.editorView showToolBarInView:self.view.window frame:CGRectMake(0, CGRectGetMinY(rect2) - 44, CGRectGetWidth(self.view.frame), 44)];
    
    CGRect frame = self.editorView.frame;
    frame.size.height = CGRectGetHeight(self.view.frame) - (CGRectGetHeight(rect1) + 44);
    //    [self.editorView updateConstraints:^(MASConstraintMaker *make) {
    //        make.height.equalTo(self.view).offset(-(CGRectGetHeight(rect1) + 44) - 80);
    //    }];
    self.editorView.editorView.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
    //    self.editorView.editorView.scrollView.contentInset = UIEdgeInsetsZero;
    [self.view setNeedsLayout];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self.editorView removeToolbar];
    CGRect frame = self.editorView.frame;
    frame.size.height = CGRectGetHeight(self.view.frame) - 44;
    self.editorView.frame = frame;
    //    [self.editorView updateConstraints:^(MASConstraintMaker *make) {
    //        make.height.equalTo(self.view).offset(-80);
    //    }];
    [self.view setNeedsLayout];
}
*/


@end
