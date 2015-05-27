//
//  USAVSecureChatListTableViewController.m
//  CONDOR
//
//  Created by Luca on 26/3/15.
//  Copyright (c) 2015年 nwstor. All rights reserved.
//

#import "USAVSecureChatListTableViewController.h"
#import "USAVGuidedSetPermissionViewController.h"

#define DELETE_HISTORY_MESSAGE_ALERT_TAG 500

@interface USAVSecureChatListTableViewController () {
    NSInteger willDeleteRow;
}

@end

@implementation USAVSecureChatListTableViewController

- (void)viewDidAppear:(BOOL)animated {
    [self.view.window setUserInteractionEnabled:YES];
    [self.navigationController.navigationBar.topItem setTitle:NSLocalizedString(@"Secure Chat", nil)];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    //file system
    // for voice, message -- stored in /tmp/<UID>
    // for others -- stored in corresponding folder. document: /Documents/<UID>/Encrypted; multimedia: /Documents/<UID>/PhotoAlbum
    // for decrypted -- not allow copy: /Documents/<UID>/Decrypted; allow copy: /Documents/<UID>/DecryptedCopy
    // for database -- /Documents/<UID>/ChatDB
    [self fileSystemSettingUp];

    //navigation bar
    self.navigationController.navigationBarHidden = NO;
    
    self.chatArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.chatDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    self.directoryList = [[NSMutableArray alloc] initWithCapacity:0];
    self.filesInDirectory = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self getChattingDatabaseList];
    
    //hintlabel
    self.hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    self.hintLabel.center = CGPointMake(self.tableView.center.x, self.tableView.center.y - 40);
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    self.hintLabel.textColor = [UIColor colorWithWhite:0.3 alpha:0.9];
    self.hintLabel.text = NSLocalizedString(@"No Chatting Session\nClick here or \"+\" to start a new chatting", nil);
    self.hintLabel.font = [UIFont boldSystemFontOfSize:13];
    self.hintLabel.numberOfLines = 2;
    //add tap recognizer to add from phone contact
    [self.hintLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *noSessionAndStartNewRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addBtnPressed:)];
    [self.hintLabel addGestureRecognizer:noSessionAndStartNewRec];
    
    
    //tableview background
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Inner_bg_lightgray"]];
    

}

#pragma mark - file system
- (void)fileSystemSettingUp {
    
    self.fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *tempPath = NSTemporaryDirectory(); //contains "/"
    
    //documents
    self.encryptedFolder = [NSString stringWithFormat:@"%@/%zi/%@", documentsPath, [[USAVClient current] uId], @"Encrypted"];
    //album
    self.photoAlbumFolder = [NSString stringWithFormat:@"%@/%zi/%@", documentsPath, [[USAVClient current] uId], @"PhotoAlbum"];
    //decrypted cache
    self.decryptedFolder = [NSString stringWithFormat:@"%@/%zi/%@", documentsPath, [[USAVClient current] uId], @"Decrypted"];
    //decrypted copy saved
    self.decryptedCopyFolder = [NSString stringWithFormat:@"%@/%zi/%@", documentsPath, [[USAVClient current] uId], @"DecryptedCopy"];
    //temp cache (voice, message)
    self.tempFileFolder = [NSString stringWithFormat:@"%@%zi", tempPath, [[USAVClient current] uId]];
    //create temp cache folder
    if ([self createDirectory:self.tempFileFolder] == FALSE) {
        self.tempFileFolder = nil;
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FileTempPathCreateFailedKey", @"") inView:self.view];
        
        return;
    }
    //Database folder
    //message folder
    self.messageFolder = [NSString stringWithFormat:@"%@/%zi/%@", [paths objectAtIndex:0], [[USAVClient current] uId], @"messages"];
    
 
}

- (void)getChattingDatabaseList {
    
    //chat array
    //{"account": xxx} -- chatting with who
    //{"lastFile": xxx} -- last file path
    //{"databasePath": xx} -- database path in MessageFolder
    //{"hasUnread": x} -- 0 has no unread file; 1 has unread file
    
    //database
    // ----- index type content time isPath name read -----
    
    [self.chatArray removeAllObjects];
    [self.directoryList removeAllObjects];
    [self.filesInDirectory removeAllObjects];
    
    NSInteger findReceivedFromKeyOwner = -1;
    
    //establish directory list and sort (time decrement)
    for (NSInteger i = 0; i < [[self.fileManager contentsOfDirectoryAtPath:self.messageFolder error:nil] count]; i ++) {
        [self.directoryList addObject:[self.messageFolder stringByAppendingPathComponent:[[self.fileManager contentsOfDirectoryAtPath:self.messageFolder error:nil] objectAtIndex:i]]];
        //sort directory list
        self.directoryList = [[self sortByTimeDecrement:self.directoryList atPath:self.messageFolder] mutableCopy];
        
    }
    
    //establish database
    for (NSInteger i = 0; i < [self.directoryList count]; i ++) {
        
        self.filesInDirectory = [[self.fileManager contentsOfDirectoryAtPath:[self.directoryList objectAtIndex:i] error:nil] mutableCopy];
        //sort file list (time increment)
        self.filesInDirectory = [[self sortByTimeIncrement:self.filesInDirectory atPath:[self.directoryList objectAtIndex:i]] mutableCopy];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[
                                    self.directoryList objectAtIndex:i] lastPathComponent], @"account", //account name
                                    [[self.filesInDirectory lastObject] length] ? [self.filesInDirectory lastObject] : @" ", @"lastFile",    //last file in account folder
                                    [self.directoryList objectAtIndex:i], @"databasePath",   //account name as database name
                                    @"0", @"hasUnread", //reserved
                                    nil];
        [self.chatArray addObject:dic];
        
        //find the receivedFile keyowner
        if (self.receivedFromKeyOwner != nil && [[dic objectForKey:@"account"] isEqualToString:self.receivedFromKeyOwner]) {
            findReceivedFromKeyOwner = i;
        }
        
    }
    
    NSLog(@"chatting Database: %@", self.chatArray);
    
    //if receivedFrom a keyowner != self or nil
    //redirect
    if (findReceivedFromKeyOwner != -1) {
        NSIndexPath *receivedFromKeyOnwerIndexPath = [NSIndexPath indexPathForRow:findReceivedFromKeyOwner inSection:0];
        [self tableView:self.tableView didSelectRowAtIndexPath:receivedFromKeyOnwerIndexPath];
        
        self.receivedFromKeyOwner = nil;
    }

}

-(BOOL)createDirectory:(NSString *)fullTargetPath
{
    NSError *nserror = nil;
    BOOL rc;
    
    if ([self.fileManager fileExistsAtPath:fullTargetPath] == YES) {
        return TRUE;
    }
    else {
        rc = [self.fileManager createDirectoryAtPath:fullTargetPath withIntermediateDirectories:YES attributes:nil error:&nserror];
        if (rc == YES) {
            return TRUE;
        }
        else {
            NSLog(@"Create Folder Error: %@", nserror);
            // directory doesn't exist and failed to create
            //NSLog(@"%@ NSError:%@ path:%@", [self class], [nserror localizedDescription], fullTargetPath);
            return FALSE;
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    //显示hint提示
    if (![self.chatArray count]) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        self.hintLabel.text = NSLocalizedString(@"No Chatting Session\nClick here or \"+\" to start a new chatting", nil);
        if (![[self.tableView subviews] containsObject:self.hintLabel]) {
            [self.tableView addSubview:self.hintLabel];
        }
        
    } else {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        if ([[self.tableView subviews] containsObject:self.hintLabel]) {
            [self.hintLabel removeFromSuperview];
        }
        
    }
    
    // Return the number of rows in the section.
    return [self.chatArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    USAVSecureChatListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SecureChatListCell" forIndexPath:indexPath];
    
    NSInteger *row = indexPath.row;
    
    //Load single data
    NSDictionary *chatDic = [self.chatArray objectAtIndex:row];
    
    cell.headerImage.frame = CGRectMake(12, 8, 40, 40);
    cell.headerImage.layer.masksToBounds = YES;
    cell.headerImage.layer.cornerRadius = 4;
    cell.backgroundColor = [UIColor clearColor];
    cell.accountLabel.text = ([[chatDic objectForKey:@"account"]  isEqualToString:@"Draft"] ? NSLocalizedString(@"Draft", nil) : [chatDic objectForKey:@"account"]);
    
    NSString *lastFileString = @"";
    if ([chatDic objectForKey:@"lastFile"] != nil) {
        if ([[[[chatDic objectForKey:@"lastFile"] stringByDeletingPathExtension] pathExtension] isEqualToString:@"usavm"]) {
            lastFileString = NSLocalizedString(@"Text Message", nil);
        } else if ([[[[chatDic objectForKey:@"lastFile"] stringByDeletingPathExtension] pathExtension] isEqualToString:@"m4a"]) {
            lastFileString = NSLocalizedString(@"Voice Message", nil);
        }
    } else {
        lastFileString = NSLocalizedString(@"", nil);
    }
    cell.detailLabel.text = lastFileString;
    [cell.unreadMessageImageView setHidden:![[chatDic objectForKey:@"hasUnread"] boolValue]];
    

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //if in same day, display hours:minutes
    if ([[self.fileManager attributesOfItemAtPath:[[self.directoryList objectAtIndex:indexPath.row] stringByAppendingPathComponent:[chatDic objectForKey:@"lastFile"]] error:nil] objectForKey:NSFileCreationDate] != nil) {
        if ([self isDateIsInToday:[[self.fileManager attributesOfItemAtPath:[[self.directoryList objectAtIndex:indexPath.row] stringByAppendingPathComponent:[chatDic objectForKey:@"lastFile"]] error:nil] objectForKey:NSFileCreationDate]]) {
            [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
            [dateFormatter setDateFormat:@"HH:mm"];
        } else {
            //if not, display year-month-day
            [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        }
    }

    
    NSString *dateString = [dateFormatter stringFromDate:[[self.fileManager attributesOfItemAtPath:[[self.directoryList objectAtIndex:indexPath.row] stringByAppendingPathComponent:[chatDic objectForKey:@"lastFile"]] error:nil] objectForKey:NSFileCreationDate]];
    cell.timeLabel.text = dateString;
    
    return cell;
}

- (BOOL)isDateIsInToday: (NSDate *)date1{
    
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date1];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    if([today day] == [otherDay day] &&
       [today month] == [otherDay month] &&
       [today year] == [otherDay year] &&
       [today era] == [otherDay era]) {
        //do stuff
        return YES;
    } else {
        return NO;
    }
}


#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger *row = indexPath.row;
    
    self.chatDatabaseFolder = [[self.chatArray objectAtIndex:row] objectForKey:@"databasePath"];
    self.chatDic = [self.chatArray objectAtIndex:row];
    
    [self performSegueWithIdentifier:@"SecureChatSessionSegue" sender:self];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        willDeleteRow = indexPath.row;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete warning", nil) message:NSLocalizedString(@"Delete this session and its chatting history?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CancelKey", nil) otherButtonTitles:NSLocalizedString(@"OkKey", nil), nil];
        alert.tag = DELETE_HISTORY_MESSAGE_ALERT_TAG;
        alert.delegate = self;
        [alert show];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == DELETE_HISTORY_MESSAGE_ALERT_TAG) {
        if (buttonIndex == 0) {
            
            return;
            
        } else {
            [self.fileManager removeItemAtPath:[[self.chatArray objectAtIndex:willDeleteRow] objectForKey:@"databasePath"] error:nil];
            [self.chatArray removeObjectAtIndex:willDeleteRow];
            
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"SecureChatSessionSegue"]) {
        USAVSecureChatViewController *secureChatViewController = segue.destinationViewController;
        //pass necessory array to chat page
        secureChatViewController.messageFolder = self.chatDatabaseFolder;
        secureChatViewController.sendTo = [[self.chatDic objectForKey:@"account"] isEqualToString:@"Draft"] ? NSLocalizedString(@"Draft", nil) : [self.chatDic objectForKey:@"account"];
        secureChatViewController.chatListDelegate = self;
        
    }
    if ([segue.identifier isEqualToString:@"SecureChatSelectContactSegue"]) {
        USAVGuidedSetPermissionViewController *usavContact = (USAVGuidedSetPermissionViewController *)segue.destinationViewController;
        usavContact.delegate = self;
    }
    
}

#pragma mark - contact list selected
- (void)contactListViewControllerDidFinish:(USAVGuidedSetPermissionViewController *)controller {
    //pop first
    [controller.navigationController popViewControllerAnimated:YES];
    
    if ([controller.friends2 count] > 0) {
        //create or find the contact's folder in message folder
        NSString *selectedEmail = [controller.friends2 firstObject];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *currentPath = [paths objectAtIndex:0];
        NSString *messagePathForSelectedEmail = [NSString stringWithFormat:@"%@/%zi/%@/%@", currentPath, [[USAVClient current] uId], @"messages", selectedEmail];
        [self createDirectory:messagePathForSelectedEmail];
        [self getChattingDatabaseList];
        [self.tableView reloadData];
        
        //select and jump to chatting view
        NSIndexPath *indexPathForSelectedEmail = [NSIndexPath indexPathForRow:[self findRowForAccount:selectedEmail] inSection:0];
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPathForSelectedEmail];
    }

}

- (NSInteger)findRowForAccount: (NSString *)account {
    for (NSInteger i = 0; i < [self.chatArray count]; i ++) {
        if ([[[self.chatArray objectAtIndex:i] objectForKey:@"account"] isEqualToString:account]) {
            return i;
        }
    }
    return -1;
}

- (IBAction)backBtnPressed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    [self.fileViewControllerDelegate showDashBoard];
}

- (IBAction)addBtnPressed:(id)sender {
    [self performSegueWithIdentifier:@"SecureChatSelectContactSegue" sender:self];
}

#pragma mark - sort by time decrement
- (NSArray *)sortByTimeDecrement: (NSArray *)array atPath: (NSString *)path {
    
    NSMutableDictionary *filesAndProperties = [[NSMutableDictionary alloc] initWithCapacity:[array count]];
    NSMutableArray *fileListForReturn = [[NSMutableArray alloc] initWithCapacity:0];
    
    //时间逆序
    for(NSString *name in array)
    {
        NSError *error;
        //for testing use
        if ([name length] == 0) {
            break;
        }
        
        NSDictionary* properties = [self.fileManager
                                    attributesOfItemAtPath:name
                                    error:&error];
        NSDate* modDate = [properties objectForKey:NSFileModificationDate];
        
        
        if(error == nil)
        {
            [filesAndProperties setValue:modDate forKey:name];
        } else {
            NSLog(@"sorting error:%@", error);
        }
    }
    
    NSMutableArray *tempArrayToReverse = [[NSMutableArray alloc] initWithCapacity:0];
    [tempArrayToReverse addObjectsFromArray:[filesAndProperties keysSortedByValueUsingSelector:@selector(compare:)]];
    
    for (NSInteger i = [tempArrayToReverse count]; i > 0; i --) {
        //倒着放回去
        [fileListForReturn addObject:[tempArrayToReverse objectAtIndex:i - 1]];
    }
    
    return fileListForReturn;
    
}

#pragma mark - sort by time increment
- (NSArray *)sortByTimeIncrement: (NSArray *)array atPath: (NSString *)path {
    
    NSMutableDictionary *filesAndProperties = [[NSMutableDictionary alloc] initWithCapacity:[array count]];
    NSMutableArray *fileListForReturn = [[NSMutableArray alloc] initWithCapacity:0];
    
    //时间逆序
    for(NSString *name in array)
    {
        NSError *error;
        //for testing use
        if ([name length] == 0) {
            break;
        }
        
        NSDictionary* properties = [self.fileManager
                                    attributesOfItemAtPath:[path stringByAppendingPathComponent:name]
                                    error:&error];
        NSDate* modDate = [properties objectForKey:NSFileCreationDate];
        
        
        if(error == nil)
        {
            [filesAndProperties setValue:modDate forKey:name];
        } else {
            NSLog(@"sorting error:%@", error);
        }
    }
    
    NSMutableArray *tempArrayToReverse = [[NSMutableArray alloc] initWithCapacity:0];
    [tempArrayToReverse addObjectsFromArray:[filesAndProperties keysSortedByValueUsingSelector:@selector(compare:)]];
    
    return tempArrayToReverse;
    
}

@end
