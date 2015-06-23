//
//  ZSSCustomButtonsViewController.m
//  ZSSRichTextEditor
//
//  Created by Nicholas Hubbard on 8/14/14.
//  Copyright (c) 2014 Zed Said Studio. All rights reserved.
//

#import "ZSSDemoCustomButtonsViewController.h"
#import "ZSSBarButtonItem.h"

@interface ZSSDemoCustomButtonsViewController ()

@property (strong, nonatomic) ZSSRichTextEditor *editor;

@end

@implementation ZSSDemoCustomButtonsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.editor = [[ZSSRichTextEditor alloc] initWithFrame:self.view.bounds];
    
    self.title = @"Custom Buttons";
    
    // HTML Content to set in the editor
    NSString *html = @"<p>This editor is using <strong>custom buttons</strong>.</p>";
    
    // Set the HTML contents of the editor
    [self.editor setHTML:html];
    
    // Don't allow editor toolbar buttons (you can if you want)
//    self.editor.enabledToolbarItems = @[ZSSRichTextEditorToolbarNone];
    
    // Create the custom buttons
    UIButton *myButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50, 28.0f)];
    [myButton setTitle:@"Test" forState:UIControlStateNormal];
    [myButton addTarget:self
                 action:@selector(didTapCustomToolbarButton:)
       forControlEvents:UIControlEventTouchUpInside];
    [self.editor addCustomToolbarItemWithButton:myButton];
    
    // Custom image button
    ZSSBarButtonItem *item = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSinsertkeyword.png"] style:UIBarButtonItemStylePlain target:self action:@selector(didTapCustomToolbarButton:)];
    [self.editor addCustomToolbarItem:item];
    
}


- (void)didTapCustomToolbarButton:(UIButton *)button {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Custom Button!"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                              otherButtonTitles:nil];
    [alertView show];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
