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

@property (strong, nonatomic) ZSSRichTextEditor *editor;

@end

@implementation ZSSDemoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Standard";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.editor = [[ZSSRichTextEditor alloc] initWithFrame:self.view.bounds navigationController:self.navigationController delegate:nil];
    [self.view addSubview:self.editor];
    
    // Export HTML
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(exportHTML)];
	
    // HTML Content to set in the editor
    NSString *html = @"<!-- This is an HTML comment -->"
    "<p>This is a test of the <strong>ZSSRichTextEditor</strong> by <a title=\"Zed Said\" href=\"http://www.zedsaid.com\">Zed Said Studio</a></p>";
    
    // Set the base URL if you would like to use relative links, such as to images.
    self.editor.baseURL = [NSURL URLWithString:@"http://www.zedsaid.com"];
    
    // Set the HTML contents of the editor
    [self.editor setHTML:html];
    
}


- (void)showInsertURLAlternatePicker {
    
    [self.editor dismissAlertView];
    
//    ZSSDemoPickerViewController *picker = [[ZSSDemoPickerViewController alloc] init];
//    picker.demoView = self;
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
//    nav.navigationBar.translucent = NO;
//    [self presentViewController:nav animated:YES completion:nil];
    
}


- (void)showInsertImageAlternatePicker {
    
    [self.editor dismissAlertView];
}


- (void)exportHTML {
    
    NSLog(@"%@", [self.editor getHTML]);
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
