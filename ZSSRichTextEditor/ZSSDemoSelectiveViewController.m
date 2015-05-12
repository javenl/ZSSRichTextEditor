//
//  ZSSSelectiveViewController.m
//  ZSSRichTextEditor
//
//  Created by Nicholas Hubbard on 8/14/14.
//  Copyright (c) 2014 Zed Said Studio. All rights reserved.
//

#import "ZSSDemoSelectiveViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ZSSBarButtonItem.h"

@interface ZSSDemoSelectiveViewController ()

@end

@implementation ZSSDemoSelectiveViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Selective";
    
    // HTML Content to set in the editor
    NSString *html = @"<p>Example showing just a few toolbar buttons.</p>";
    
    // Custom image button
    ZSSBarButtonItem *item0 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSinsertkeyword.png"] style:UIBarButtonItemStylePlain target:self action:@selector(didTapCustomToolbarButton0:)];
    [self addCustomToolbarItem:item0];
    
    ZSSBarButtonItem *item1 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSinsertkeyword.png"] style:UIBarButtonItemStylePlain target:self action:@selector(didTapCustomToolbarButton1:)];
    [self addCustomToolbarItem:item1];
    
    // Choose which toolbar items to show
    self.enabledToolbarItems = @[ZSSRichTextEditorToolbarViewSource];
    
    // Set the HTML contents of the editor
    [self setHTML:html];
    
    
}

- (void)didTapCustomToolbarButton0:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选择", nil];
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

- (void)didTapCustomToolbarButton1:(id)sender {
    
//    zss_editor.backuprange();
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self backupRange];
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        [picker setAllowsEditing:YES];
        [self presentViewController:picker animated:YES completion:nil];
    } else if (buttonIndex == 1) {
        [self backupRange];
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        picker.delegate = self;
//        [picker setAllowsEditing:YES];
        [self presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //extracting image from the picker and saving it
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *) kUTTypeImage] || [mediaType isEqualToString:ALAssetTypePhoto]) {
        NSString *fileName = [NSString stringWithFormat:@"%f.%@", [[NSDate date] timeIntervalSince1970], @"jpg"];
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        NSData *webData = UIImageJPEGRepresentation(image, 1);
        [webData writeToFile:filePath atomically:YES];
        
        NSURL *url = [NSURL fileURLWithPath:filePath];
        [self restoreRange];
        [self insertImage:url.absoluteString alt:@""];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
