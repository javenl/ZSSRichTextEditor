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
    
    self.webView = [UIWebView new];
    self.webView.frame = self.view.frame;
    [self.view addSubview:self.webView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test_mp3" ofType:@"htm"];
    NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:html baseURL:nil];
}



@end
