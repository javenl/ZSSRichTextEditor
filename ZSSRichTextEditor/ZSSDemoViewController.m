//
//  ZSSDemoViewController.m
//  ZSSRichTextEditor
//
//  Created by Nicholas Hubbard on 11/29/13.
//  Copyright (c) 2013 Zed Said Studio. All rights reserved.
//

#import "ZSSDemoViewController.h"
#import "ZSSDemoPickerViewController.h"

@interface ZSSDemoViewController ()

@property (strong, nonatomic) ZSSRichTextEditor *editorView;

@end

@implementation ZSSDemoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Standard";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.editorView = [[ZSSRichTextEditor alloc] initWithNavigationController:self.navigationController delegate:nil];
    self.editorView.frame = self.view.bounds;
    [self.view addSubview:self.editorView];
    
//    [self.editorView setContentHeight:self.view.bounds.size.height];
//    [self.editorView setFooterHeight:200];
    
    // Export HTML
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(exportHTML)];
	
    // HTML Content to set in the editor
//    NSString *html = @"<!-- This is an HTML comment -->"
//    "<p>This is a test of the <strong>ZSSRichTextEditor</strong> by <a title=\"Zed Said\" href=\"http://www.zedsaid.com\">Zed Said Studio</a></p>";
    
    NSString *html = @"qwrqw<blockquote style=\"border-left:5px solid #eeeeee; margin:0; padding-left:20px;\">f34</blockquote><div>wqer</div><div>wqer</div>";
    
    NSLog(@"html %@", html);
    
//    wqerjlkqw&lt;div&gt;qwr&lt;/div&gt;&lt;blockquote style=&quot;border-left: 5px solid #eeeeee; margin:0; padding-left:20px;&quot;&gt;qwer&lt;/blockquote&gt;&lt;div&gt;qwreqwer&lt;/div&gt;
    
//    qwrqw&lt;blockquote style=&quot;border-left: 5px solid #eeeeee; margin:0; padding-left:20px;&quot;&gt;f34&lt;/blockquote&gt;&lt;div&gt;wqer&lt;/div&gt;&lt;div&gt;wqer&lt;/div&gt;
    
    // Set the base URL if you would like to use relative links, such as to images.
    self.editorView.baseURL = [NSURL URLWithString:@"http://www.zedsaid.com"];
    
    // Set the HTML contents of the editor
    [self.editorView setHTML:html];
    
}

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


- (void)showInsertURLAlternatePicker {
    
    [self.editorView dismissAlertView];
    
//    ZSSDemoPickerViewController *picker = [[ZSSDemoPickerViewController alloc] init];
//    picker.demoView = self;
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
//    nav.navigationBar.translucent = NO;
//    [self presentViewController:nav animated:YES completion:nil];
    
}


- (void)showInsertImageAlternatePicker {
    
    [self.editorView dismissAlertView];
}


- (void)exportHTML {
    
    NSLog(@"%@", [self.editorView getHTML]);
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notification

- (void)keyboardWillShow:(NSNotification *)notification {
    
//    CGRect rect2 = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    
//    [self.editorView setContentHeight:CGRectGetHeight(self.view.bounds)-CGRectGetHeight(rect2)];
    /*
    //    NSLog(@"duration %@", notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]);
    CGRect rect1 = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect rect2 = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //        UIView *win = [UIApplication sharedApplication].windows.lastObject;
    DLog(@"y %@",  @(CGRectGetMinY(rect2) - 44));
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
    */
}

- (void)keyboardWillHide:(NSNotification *)notification {
    /*
    [self.editorView removeToolbar];
    CGRect frame = self.editorView.frame;
    frame.size.height = CGRectGetHeight(self.view.frame) - 44;
    self.editorView.frame = frame;
//    [self.editorView updateConstraints:^(MASConstraintMaker *make) {
//        make.height.equalTo(self.view).offset(-80);
//    }];
    [self.view setNeedsLayout];
    */
}

@end
