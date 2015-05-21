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
#import <MediaPlayer/MPMediaQuery.h>
#import <MediaPlayer/MPMoviePlayerController.h>



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
    ZSSBarButtonItem *item0 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSinsertkeyword.png"] style:UIBarButtonItemStylePlain target:self action:@selector(didTapTest:)];
    [self addCustomToolbarItem:item0];
    
    ZSSBarButtonItem *item1 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSinsertkeyword.png"] style:UIBarButtonItemStylePlain target:self action:@selector(didTapInsertImage:)];
    [self addCustomToolbarItem:item1];
    
    ZSSBarButtonItem *item2 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSinsertkeyword.png"] style:UIBarButtonItemStylePlain target:self action:@selector(didTapInsertMP3:)];
    [self addCustomToolbarItem:item2];
    
    ZSSBarButtonItem *item3 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSinsertkeyword.png"] style:UIBarButtonItemStylePlain target:self action:@selector(didTapInsertVideo:)];
    [self addCustomToolbarItem:item3];
    
    // Choose which toolbar items to show
    self.enabledToolbarItems = @[ZSSRichTextEditorToolbarViewSource];
    
    // Set the HTML contents of the editor
    [self setHTML:html];
    
    
}

- (void)didTapTest:(id)sender {
//    [self debug:@"test"];
//    [self.editorView e]
    [self.editorView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"zss_extend.showRange();"]];
//    zss_extend.showRange
//    zss_editor.backuprange();
}

- (void)didTapInsertImage:(id)sender {
    [self selectImage];
}

- (void)didTapInsertMP3:(id)sender {
//    [self backupRange];
//    [self restoreRange];
//    [self insertMP3:@"http://m1.music.126.net/AvO6aqtdT-UshoytHXs3xg==/6656443395518310.mp3"];
    [self showRecordView];
}

- (void)didTapInsertVideo:(id)sender {
//    NSArray *array1 = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
//    NSArray *array2 = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
//    NSArray *array3 = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    [self selectVideo];
    /*
    [self backupRange];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    picker.delegate = self;
//    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = @[(NSString *)kUTTypeMovie];
    picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
//    [picker setAllowsEditing:YES];
    picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    [self presentViewController:picker animated:YES completion:nil];
    */
//    [self insertVideo:@"file:///Users/liu/Desktop/mp4_files/1430026336.686622.mp4"];
}

#pragma mark UIActionSheetDelegate
/*
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kInsertImageTag) {
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
    } else if (actionSheet.tag == kInsertVideoTag) {
        
    }
}
*/
#pragma mark UIImagePickerControllerDelegate
/*
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //extracting image from the picker and saving it
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage] || [mediaType isEqualToString:ALAssetTypePhoto]) {
        NSString *fileName = [NSString stringWithFormat:@"%f.%@", [[NSDate date] timeIntervalSince1970], @"jpg"];
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        NSData *webData = UIImageJPEGRepresentation(image, 1);
        [webData writeToFile:filePath atomically:YES];
        
        NSURL *url = [NSURL fileURLWithPath:filePath];
        [self restoreRange];
        [self insertImage:url.absoluteString alt:@""];
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *url = info[UIImagePickerControllerMediaURL];
        NSLog(@"video url %@", url.absoluteString);
        [self restoreRange];
        [self insertVideo:url.absoluteString];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
*/
/*
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}
*/

@end
