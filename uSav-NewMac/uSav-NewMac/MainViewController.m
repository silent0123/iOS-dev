//
//  MainViewController.m
//  uSav-NewMac
//
//  Created by Luca on 23/9/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "MainViewController.h"
#import <AppKit/AppKit.h>
#import "USAVPermissionViewController.h"

//Tags in cell
#define TAG_OF_FILENAME 100
#define TAG_OF_SIZE 101
#define TAG_OF_IMAGE 102
#define TAG_OF_TIME 103
#define TAG_OF_TRASHBTN 104
#define TAG_OF_COLOR 105


@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do view setup here.
    //带有file://
    self.selectedFileURLList = [[NSMutableArray alloc] initWithCapacity:0];
    //不带file://
    self.selectedFilePathList = [[NSMutableArray alloc] initWithCapacity:0];
    self.fileManager = [NSFileManager defaultManager];
    
    self.selectedRow = -1;
    
    [self detailViewDisplay:NO];
    [self activityViewDisplay:NO withMessage:nil animate:NO];

    //register, 暂时无用
    //[self.view registerForDraggedTypes: [NSArray arrayWithObjects: NSFilenamesPboardType, nil]];
    
}

#pragma mark TableView dataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    //如果为空则隐藏detail
    if (![self.selectedFileURLList count]) {
        [self detailViewDisplay:NO];
    }
    
    return [self.selectedFileURLList count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSTableCellView *cell = [tableView makeViewWithIdentifier:@"FileCell" owner:self];
    
    
    //Connection by tags
    NSTextField *filenameTextField = [cell viewWithTag:TAG_OF_FILENAME];
    NSTextField *sizeTextField = [cell viewWithTag:TAG_OF_SIZE];
    NSTextField *timeTextField = [cell viewWithTag:TAG_OF_TIME];
    NSImageView *imageView = [cell viewWithTag:TAG_OF_IMAGE];
    NSButton *trashBtn = [cell viewWithTag:TAG_OF_TRASHBTN];
    NSTextField *colorLabel = [cell viewWithTag:TAG_OF_COLOR];
    
    //locate file
    NSString *filePath = [self.selectedFilePathList objectAtIndex:row];

    NSError *error;
    NSDictionary *attributesOfFile =  [self.fileManager attributesOfItemAtPath:filePath error:&error];
    if (error != nil) {
        NSLog(@"Error while loading attributes:%@", error);
    } else {
        //NSLog(@"File attributes: %@", attributesOfFile);
    }
    
    
    //Set Value
    filenameTextField.stringValue = [filePath lastPathComponent];
    sizeTextField.stringValue = [self convertNumberToKMString:[[attributesOfFile objectForKey:@"NSFileSize"] integerValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    timeTextField.stringValue = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:[NSDate date]]];
    
    colorLabel.backgroundColor = [NSColor whiteColor];
    [trashBtn setHidden:YES];
    
    if ([[filePath pathExtension] caseInsensitiveCompare:@"usav"] == NSOrderedSame) {
        imageView.image = [self selectImageForFileCell:[[filePath lastPathComponent] stringByReplacingOccurrencesOfString:@".usav" withString:@""] withLock:YES];
    } else {
        imageView.image = [self selectImageForFileCell:[filePath lastPathComponent] withLock:NO];
    }
    
    
    
    return cell;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    
    NSTableView *tableView = notification.object;
    NSInteger row = [tableView selectedRow];    //可以通过row，在datasource里定位，-1为选中空白行
    NSInteger column = [tableView selectedColumn];
    
    //隐藏activity
    [self activityViewDisplay:NO withMessage:nil animate:NO];
    
    if (row >= 0 && row < [self.selectedFileURLList count]) {
        
        [self detailViewDisplay:YES];
        
        NSTableCellView *cell = [tableView viewAtColumn:column row:row makeIfNecessary:NO];
        
        //Connection by tags
        //NSTextField *filenameTextField = [cell viewWithTag:TAG_OF_FILENAME];
        //NSTextField *sizeTextField = [cell viewWithTag:TAG_OF_SIZE];
        //NSTextField *timeTextField = [cell viewWithTag:TAG_OF_TIME];
        //NSImageView *imageView = [cell viewWithTag:TAG_OF_IMAGE];
        NSButton *trashBtn = [cell viewWithTag:TAG_OF_TRASHBTN];
        NSTextField *colorLabel = [cell viewWithTag:TAG_OF_COLOR];
        
        self.selectedRow = row;
        
        [trashBtn setHidden:NO];
        [colorLabel setBackgroundColor:[NSColor colorWithRed:(30.0/255.0) green:(144.0/255.0) blue:1.0 alpha:1]];
        
        //cancel selection of others
        for (NSInteger i = 0;i < [tableView numberOfRows]; i ++) {
            if (i != row) {
                NSTableCellView *cell = [tableView viewAtColumn:column row:i makeIfNecessary:NO];
                NSButton *trashBtn = [cell viewWithTag:TAG_OF_TRASHBTN];
                NSTextField *colorLabel = [cell viewWithTag:TAG_OF_COLOR];
                
                colorLabel.backgroundColor = [NSColor whiteColor];
                [trashBtn setHidden:YES];
            }
        }
        
        //detail refresh
        NSString *filePath = [self.selectedFilePathList objectAtIndex:row];
        self.sourcePath.stringValue = filePath;
        self.DetailHeaderFilename.stringValue = [filePath lastPathComponent];
        self.keyId = [[[UsavFileHeader defaultHeader] getKeyIDFromFile:self.sourcePath.stringValue] base64EncodedString];
        NSDictionary *attribute = [self.fileManager attributesOfItemAtPath:filePath error:nil];
        if ([[filePath pathExtension] caseInsensitiveCompare:@"usav"] == NSOrderedSame) {
            self.destinationPath.stringValue = [filePath stringByReplacingOccurrencesOfString:@".usav" withString:@""];
        } else {
            self.destinationPath.stringValue = [filePath stringByAppendingString:@".usav"];
        }
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale systemLocale]];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        self.modificationTime.stringValue = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:[attribute objectForKey:@"NSFileModificationDate"]]];
        
        if ([[filePath pathExtension] caseInsensitiveCompare:@"usav"] == NSOrderedSame) {
            [self.editPermissionBtn setHidden:NO];
            [self.fileHistoryBtn setHidden:NO];
            self.enc_decBtn.image = [NSImage imageNamed:@"DecryptBtn"];
            self.willEncryptFile = NO;
        } else {
            [self.editPermissionBtn setHidden:YES];
            [self.fileHistoryBtn setHidden:YES];
            self.enc_decBtn.image = [NSImage imageNamed:@"EncryptBtn"];
            self.willEncryptFile = YES;
        }
        
        //cell color refresh
        if ([[filePath pathExtension] caseInsensitiveCompare:@"usav"] == NSOrderedSame) {
            self.imageBanner.image = [self selectImageForFileBanner:[[filePath lastPathComponent] stringByReplacingOccurrencesOfString:@".usav" withString:@""] withLock:YES];
        } else {
            self.imageBanner.image = [self selectImageForFileBanner:[filePath lastPathComponent] withLock:NO];
        }
    }

        [self permissionViewDisplay:NO];
    
}

#pragma mark - ButtonPressed
- (IBAction)newFileBtnPressed: (id)sender {
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseDirectories = NO;
    openPanel.canChooseFiles = YES;
    openPanel.title = @"New File";
    openPanel.allowsMultipleSelection = YES;
    BOOL alertDisplayed = NO;
    NSMutableArray *selectedTemp;
    NSMutableIndexSet *deleteSet = [[NSMutableIndexSet alloc] init];
    
    if ([openPanel runModal] == NSOKButton) {
        
        [selectedTemp removeAllObjects];
        selectedTemp = [[NSMutableArray alloc] initWithArray:openPanel.URLs];
        
        
        //筛选已经被选择过的文件
        for (NSInteger i = 0; i < [openPanel.URLs count]; i ++) {
            if ([self.selectedFileURLList containsObject:[openPanel.URLs objectAtIndex:i]]) {
                //用set记录删除位置
                [deleteSet addIndex:i];
                continue;
            }
            if (([[NSString stringWithFormat:@"%@",[openPanel.URLs objectAtIndex:i]] rangeOfString:@"%20"].location != NSNotFound)) {
                //提示只显示一次
                if (!alertDisplayed) {
                    alertDisplayed = YES;
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert addButtonWithTitle:@"OK"];
                    [alert setMessageText:@"Warning: Filename can not contain whitespace."];
                    [alert setAlertStyle:NSWarningAlertStyle];
                    [alert runModal];
                }
                [deleteSet addIndex:i];
            }
        }
        
        //一次性删除
        [selectedTemp removeObjectsAtIndexes:deleteSet];
        
        //存放当前选择的文件
        [self.selectedFileURLList addObjectsFromArray:selectedTemp];
        
        for (NSInteger i = 0; i < [selectedTemp count]; i ++) {
            [self.selectedFilePathList addObject:[[NSString stringWithFormat:@"%@", [selectedTemp objectAtIndex:i]] stringByReplacingOccurrencesOfString:@"file://" withString:@""]];
        }
    
    }
    
    
    
    [self.fileTable reloadData];
    
    if ([selectedTemp count]) {
        //自动选中本次选择的第一个
        NSIndexSet *selectedRowSet = [[NSIndexSet alloc] initWithIndex:([self.selectedFileURLList count] - [selectedTemp count])];
        [self.fileTable selectRowIndexes:selectedRowSet byExtendingSelection:NO];
    }
    
}

- (IBAction)cellTrashBtnPressed:(id)sender {
    
    [self.selectedFileURLList removeObjectAtIndex:self.selectedRow];
    [self.selectedFilePathList removeObjectAtIndex:self.selectedRow];
    [self detailViewDisplay:NO];
    
    self.selectedRow = -1;
    [self.fileTable reloadData];
}

- (IBAction)destinationBtnPressed:(id)sender {
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseDirectories = YES;
    openPanel.canChooseFiles = NO;
    openPanel.title = @"Save At";
    openPanel.allowsMultipleSelection = NO;
    
    if ([openPanel runModal] == NSOKButton) {
        
        //destinationPath Contains filename
        self.destinationURL = [[NSString stringWithFormat:@"%@",openPanel.URL] stringByAppendingString:[self.destinationPath.stringValue lastPathComponent]];
        self.destinationPath.stringValue = [self.destinationURL stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        
    }
}

- (IBAction)enc_decBtnPressed:(id)sender {
    
    if (self.willEncryptFile) {
        //Encryption Mode
        
        [self activityViewDisplay:YES withMessage:@"Generating File" animate:YES];
        
        //监听加密结果
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(encryptionSucceedNotificationReceived:) name:@"EncryptionResult" object:nil];
        [[USAVFileHandler currentHandler] EncryptFileAtSourcePath:self.sourcePath.stringValue toDestinationPath:self.destinationPath.stringValue delegate:self];
        
    
    } else {
        //Decryption Mode
        
        [self activityViewDisplay:YES withMessage:@"Decryption Will Coming in Next Version" animate:NO];
        
        [self performSelector:@selector(hideActivityDisplay) withObject:nil afterDelay:2];
    
    }
    
}

- (IBAction)logoutButtonPressed:(id)sender {
    
    if ([USAVClient current].userHasLogin) {
        [self logoutCurrentAccount];
    }
   
    
}

- (IBAction)editPermissionBtnPressed:(id)sender {
    [self permissionViewDisplay:YES];
}

- (IBAction)fileHistoryBtnPressed:(id)sender {
}

#pragma mark - 加密完成 Encryption Complete
- (void)encryptionSucceedNotificationReceived: (NSNotification *)notification {
    
    NSLog(@"Encryption Result: %@", notification);
    //移除notification observer，否则会重复监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"EncryptionResult" object:nil];
    //显示Activity提示
    [self activityViewDisplay:YES withMessage:[notification object] animate:NO];
    
    //文件选择转换为加密后的文件
    [self.selectedFilePathList removeObjectAtIndex:self.selectedRow];
    [self.selectedFileURLList removeObjectAtIndex:self.selectedRow];
    [self.selectedFilePathList insertObject:self.destinationPath.stringValue atIndex:self.selectedRow];
    [self.selectedFileURLList insertObject:[NSURL URLWithString:self.destinationPath.stringValue] atIndex:self.selectedRow];
    [self.fileTable reloadData];
    NSIndexSet *selectedRowSet = [[NSIndexSet alloc] initWithIndex:self.selectedRow];
    [self.fileTable selectRowIndexes:selectedRowSet byExtendingSelection:NO];
    
}




#pragma mark - drag and drop
/*
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {

    
    NSLog(@"in");
    
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSColorPboardType] ) {
        if (sourceDragMask & NSDragOperationGeneric) {
            return NSDragOperationGeneric;
        }
    }
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        if (sourceDragMask & NSDragOperationLink) {
            return NSDragOperationLink;
        } else if (sourceDragMask & NSDragOperationCopy) {
            return NSDragOperationCopy;
        }
    }
    
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    
    NSPasteboard *pboard;
    
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        
        NSLog(@"path: %@", [pboard propertyListForType:NSFilenamesPboardType]);

    }
    return YES;
}
*/


#pragma mark - Data Convert
- (NSString *)convertNumberToKMString:(NSInteger)num {
    
    if (num > (1024 * 1024)) {
        float m = (float)num / (1024.0 * 1024.0);
        return ([NSString stringWithFormat:@"%.2fM", m]);
    }
    else if (num > 1024) {
        float k = (float)num / 1024.0;
        return ([NSString stringWithFormat:@"%.2fK", k]);
    }
    else
        return [NSString stringWithFormat:@"%zi", num];
    
}

#pragma mark - Image detection
- (NSImage *)selectImageForFileCell: (NSString *)filename withLock: (BOOL)locked {
    
    NSString *ext = [filename pathExtension];
    
    if (locked) {
        if ([ext caseInsensitiveCompare:@"doc"] == NSOrderedSame) {
            return [NSImage imageNamed:@"70x70_docL"];
        }
        else if ([ext caseInsensitiveCompare:@"docx"] == NSOrderedSame) {
            return [NSImage imageNamed:@"70x70_docL"];
        }
        else if (([ext caseInsensitiveCompare:@"png"] == NSOrderedSame) ||
                 ([ext caseInsensitiveCompare:@"jpg"] == NSOrderedSame)) {
            return [NSImage imageNamed:@"70x70_imgL"];
        }
        else if (([ext caseInsensitiveCompare:@"mov"] == NSOrderedSame) ||
                 ([ext caseInsensitiveCompare:@"mp4"] == NSOrderedSame) ||
                 ([ext caseInsensitiveCompare:@"mpv"] == NSOrderedSame) ||
                 ([ext caseInsensitiveCompare:@"3gp"] == NSOrderedSame) ||
                 ([ext caseInsensitiveCompare:@"m4v"] == NSOrderedSame)) {
            return [NSImage imageNamed:@"70x70_imgL"];
        }
        else if ([ext caseInsensitiveCompare:@"pdf"] == NSOrderedSame) {
            return [NSImage imageNamed:@"70x70_pdfL"];
        }
        else if ([ext caseInsensitiveCompare:@"ppt"] == NSOrderedSame) {
            return [NSImage imageNamed:@"70x70_pptL"];
        }
        else if ([ext caseInsensitiveCompare:@"pptx"] == NSOrderedSame) {
            return [NSImage imageNamed:@"70x70_pptL"];
        }
        else if ([ext caseInsensitiveCompare:@"txt"] == NSOrderedSame) {
            return [NSImage imageNamed:@"70x70_txtL"];
        }
        else if ([ext caseInsensitiveCompare:@ "xls"] == NSOrderedSame) {
            return [NSImage imageNamed:@"70x70_xlsL"];
        }
        else if ([ext caseInsensitiveCompare:@ "xlsx"] == NSOrderedSame) {
            return [NSImage imageNamed:@"70x70_xlsL"];
        }
        else if ([ext caseInsensitiveCompare:@"zip"] == NSOrderedSame) {
            return [NSImage imageNamed:@"70x70_zipL"];
        }
        else {
            return [NSImage imageNamed:@"70x70_genL"];
        }
    } else {
        if ([ext caseInsensitiveCompare:@"doc"] == NSOrderedSame) {
            return [NSImage imageNamed:@"70x70_doc"];
        }
        else if ([ext caseInsensitiveCompare:@"docx"] == NSOrderedSame) {
            return [NSImage imageNamed:@"70x70_doc"];
        }
        else if (([ext caseInsensitiveCompare:@"png"] == NSOrderedSame) ||
                 ([ext caseInsensitiveCompare:@"jpg"] == NSOrderedSame)) {
            return [NSImage imageNamed:@"70x70_img"];
        }
        else if (([ext caseInsensitiveCompare:@"mov"] == NSOrderedSame) ||
                 ([ext caseInsensitiveCompare:@"mp4"] == NSOrderedSame) ||
                 ([ext caseInsensitiveCompare:@"mpv"] == NSOrderedSame) ||
                 ([ext caseInsensitiveCompare:@"3gp"] == NSOrderedSame) ||
                 ([ext caseInsensitiveCompare:@"m4v"] == NSOrderedSame)) {
            return [NSImage imageNamed:@"70x70_img"];
        }
        else if ([ext caseInsensitiveCompare:@"pdf"] == NSOrderedSame) {
            return [NSImage imageNamed:@"70x70_pdf"];
        }
        else if ([ext caseInsensitiveCompare:@"ppt"] == NSOrderedSame) {
            return [NSImage imageNamed:@"70x70_ppt"];
        }
        else if ([ext caseInsensitiveCompare:@"pptx"] == NSOrderedSame) {
            return [NSImage imageNamed:@"70x70_ppt"];
        }
        else if ([ext caseInsensitiveCompare:@"txt"] == NSOrderedSame) {
            return [NSImage imageNamed:@"70x70_txt"];
        }
        else if ([ext caseInsensitiveCompare:@ "xls"] == NSOrderedSame) {
            return [NSImage imageNamed:@"70x70_xls"];
        }
        else if ([ext caseInsensitiveCompare:@ "xlsx"] == NSOrderedSame) {
            return [NSImage imageNamed:@"70x70_xls"];
        }
        else if ([ext caseInsensitiveCompare:@"zip"] == NSOrderedSame) {
            return [NSImage imageNamed:@"70x70_zip"];
        }
        else {
            return [NSImage imageNamed:@"70x70_gen"];
        }
    }
}

- (NSImage *)selectImageForFileBanner: (NSString *)filename withLock: (BOOL)locked {
    
    NSString *ext = [filename pathExtension];
    
    if (locked) {
        if ([ext caseInsensitiveCompare:@"doc"] == NSOrderedSame) {
            return [NSImage imageNamed:@"DocBanner_usav"];
        }
        else if ([ext caseInsensitiveCompare:@"docx"] == NSOrderedSame) {
            return [NSImage imageNamed:@"DocBanner_usav"];
        }
        else if (([ext caseInsensitiveCompare:@"png"] == NSOrderedSame) ||
                 ([ext caseInsensitiveCompare:@"jpg"] == NSOrderedSame)) {
            return [NSImage imageNamed:@"MediaBanner_usav"];
        }
        else if (([ext caseInsensitiveCompare:@"mov"] == NSOrderedSame) ||
                 ([ext caseInsensitiveCompare:@"mp4"] == NSOrderedSame) ||
                 ([ext caseInsensitiveCompare:@"mpv"] == NSOrderedSame) ||
                 ([ext caseInsensitiveCompare:@"3gp"] == NSOrderedSame) ||
                 ([ext caseInsensitiveCompare:@"m4v"] == NSOrderedSame)) {
            return [NSImage imageNamed:@"MediaBanner_usav"];
        }
        else if ([ext caseInsensitiveCompare:@"pdf"] == NSOrderedSame) {
            return [NSImage imageNamed:@"PdfBanner_usav"];
        }
        else if ([ext caseInsensitiveCompare:@"ppt"] == NSOrderedSame) {
            return [NSImage imageNamed:@"PptBanner_usav"];
        }
        else if ([ext caseInsensitiveCompare:@"pptx"] == NSOrderedSame) {
            return [NSImage imageNamed:@"PptBanner_usav"];
        }
        else if ([ext caseInsensitiveCompare:@"txt"] == NSOrderedSame) {
            return [NSImage imageNamed:@"MessageBanner_usav"];
        }
        else if ([ext caseInsensitiveCompare:@ "xls"] == NSOrderedSame) {
            return [NSImage imageNamed:@"XlsBanner_usav"];
        }
        else if ([ext caseInsensitiveCompare:@ "xlsx"] == NSOrderedSame) {
            return [NSImage imageNamed:@"XlsBanner_usav"];
        }
        else if ([ext caseInsensitiveCompare:@"zip"] == NSOrderedSame) {
            return [NSImage imageNamed:@"OtherBanner_usav"];
        }
        else {
            return [NSImage imageNamed:@"OtherBanner_usav"];
        }
    } else {
        if ([ext caseInsensitiveCompare:@"doc"] == NSOrderedSame) {
            return [NSImage imageNamed:@"DocBanner"];
        }
        else if ([ext caseInsensitiveCompare:@"docx"] == NSOrderedSame) {
            return [NSImage imageNamed:@"DocBanner"];
        }
        else if (([ext caseInsensitiveCompare:@"png"] == NSOrderedSame) ||
                 ([ext caseInsensitiveCompare:@"jpg"] == NSOrderedSame)) {
            return [NSImage imageNamed:@"MediaBanner"];
        }
        else if (([ext caseInsensitiveCompare:@"mov"] == NSOrderedSame) ||
                 ([ext caseInsensitiveCompare:@"mp4"] == NSOrderedSame) ||
                 ([ext caseInsensitiveCompare:@"mpv"] == NSOrderedSame) ||
                 ([ext caseInsensitiveCompare:@"3gp"] == NSOrderedSame) ||
                 ([ext caseInsensitiveCompare:@"m4v"] == NSOrderedSame)) {
            return [NSImage imageNamed:@"MediaBanner"];
        }
        else if ([ext caseInsensitiveCompare:@"pdf"] == NSOrderedSame) {
            return [NSImage imageNamed:@"PdfBanner"];
        }
        else if ([ext caseInsensitiveCompare:@"ppt"] == NSOrderedSame) {
            return [NSImage imageNamed:@"PptBanner"];
        }
        else if ([ext caseInsensitiveCompare:@"pptx"] == NSOrderedSame) {
            return [NSImage imageNamed:@"PptBanner"];
        }
        else if ([ext caseInsensitiveCompare:@"txt"] == NSOrderedSame) {
            return [NSImage imageNamed:@"MessageBanner"];
        }
        else if ([ext caseInsensitiveCompare:@ "xls"] == NSOrderedSame) {
            return [NSImage imageNamed:@"XlsBanner"];
        }
        else if ([ext caseInsensitiveCompare:@ "xlsx"] == NSOrderedSame) {
            return [NSImage imageNamed:@"XlsBanner"];
        }
        else if ([ext caseInsensitiveCompare:@"zip"] == NSOrderedSame) {
            return [NSImage imageNamed:@"OtherBanner"];
        }
        else {
            return [NSImage imageNamed:@"OtherBanner"];
        }
    }
}


#pragma mark - View Controll
- (void)detailViewDisplay: (BOOL)show {
    
    [self.detailView setHidden:!show];
    [self.hintLabel setHidden:show];
}

- (void)permissionViewDisplay: (BOOL)show {
    
    //[self.detailView setHidden:show];
    if (show) {
        self.permissionController = [[USAVPermissionViewController alloc] initWithKeyId:self.keyId];
        self.permissionController.view.frame = [self.detailBackground frame];
        [self.detailView addSubview:self.permissionController.view];
        
    } else {
        [self.permissionController.view removeFromSuperview];
    }
    
}

#pragma mark Activity display
- (void)activityViewDisplay: (BOOL)show withMessage: (NSString *)message animate: (BOOL)animate {
    
    [self.activityView setHidden:!show];
    
    if (show) {
        self.activityLabel.stringValue = message;
    }
    
    if (animate) {
        [self.activityCircle setHidden:!animate];
        [self.activityCircle startAnimation:nil];
    } else {
        [self.activityCircle stopAnimation:nil];
        [self.activityCircle setHidden:!animate];
    }
    
}

- (void)hideActivityDisplay {
    
    [self activityViewDisplay:NO withMessage:nil animate:NO];
    
}

#pragma mark Log out

- (void)logoutCurrentAccount {
    
    [USAVClient current].userHasLogin = NO;
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"emailAddress"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"password"];
    
    self.loginViewController = [[USAVLoginViewController alloc] initWithNibName:@"USAVLoginViewController" bundle:nil];
    //没有登陆则进入登陆页面
    [self.view.window.contentView addSubview:self.loginViewController.view];
    self.loginViewController.view.frame = [self.view.window.contentView bounds];
    
    //移除当前页面的状态，防止登陆后出现之前的界面
    [self.view removeFromSuperview];
}


@end
