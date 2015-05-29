//
//  USAVGuidedSetPermissionViewController.m
//  uSav
//
//  Created by young dennis on 25/11/12.
//  Copyright (c) 2012 young dennis. All rights reserved.
//

#import "USAVGuidedSetPermissionViewController.h"
#import "USAVClient.h"
#import "API.h"
#import "WarningView.h"
#import "GDataXMLNode.h"
#import "SGDUtilities.h"
#import "NSString+Helper.h"


@interface USAVGuidedSetPermissionViewController ()

@property (nonatomic, strong) NSMutableArray * groupAndMember;
@property (nonatomic, strong) NSMutableArray * friends;
@property (nonatomic) NSInteger numOfObjectsInGroupAndMember;
@property (nonatomic, strong) NSString * tempGroupName;

@property (nonatomic) NSInteger numberOfSetPermissionSuccess;
@property (nonatomic) NSInteger numberOfTargetPermissions;

@property (nonatomic, strong) NSMutableArray * checkMarkForGroupAndMember;
@property (nonatomic, strong) NSMutableArray * checkMarkForFriends;

@property (nonatomic, strong) NSMutableArray * originPermissionGroups;
@property (nonatomic, strong) NSMutableArray * originPermissionFriends;

@property (nonatomic) NSInteger indexForOriginGroup;
@property (nonatomic) NSInteger indexInContacts;

@property (nonatomic, strong) NSMutableArray *addedFriendList;
@property (nonatomic, strong) NSMutableArray *addedGroupList;

@property (nonatomic) NSInteger addedFriendIndex;
@property (nonatomic) NSInteger addedGroupIndex;

@property (nonatomic) NSInteger addFriendSuccess;
@property (nonatomic) NSInteger addGroupSuccess;

@property (nonatomic) BOOL addContactListSuccess;
@property (nonatomic, strong) UIAlertView *alert;


@property (nonatomic, strong) NSString *tmpFriendName;

@end

@implementation USAVGuidedSetPermissionViewController
@synthesize emails = _emails;
@synthesize doneBtn;
@synthesize alert = _alert;
@synthesize groupAndMember = _groupAndMember;
@synthesize friends = _friends;
@synthesize indexInContacts = _indexInContacts;
@synthesize numOfObjectsInGroupAndMember = _numOfObjectsInGroupAndMember;
@synthesize tempGroupName = _tempGroupName;
@synthesize checkMarkForGroupAndMember = _checkMarkForGroupAndMember;
@synthesize checkMarkForFriends = _checkMarkForFriends;
@synthesize tbView = _tbView;
//@synthesize shareView = _shareView;
@synthesize originPermissionGroups= _originPermissionGroups;
@synthesize originPermissionFriends = _originPermissionFriends;

@synthesize indexForOriginGroup = _indexForOriginGroup;
@synthesize keyId = _keyId;

@synthesize friendTextField = _friendTextField;
//@synthesize groupTextField = _groupTextField;
@synthesize addedFriendList = _addedFriendList;
@synthesize addedGroupList = _addedGroupList;

@synthesize addedFriendIndex = _addedFriendIndex;
@synthesize addedGroupIndex = _addedGroupIndex;
@synthesize addFriendSuccess = _addFriendSuccess;
@synthesize addGroupSuccess = _addGroupSuccess;

@synthesize fileName = _fileName;
@synthesize filePath = _filePath;
@synthesize groups = _groups;
@synthesize friends2 = _friends2;

- (NSMutableArray *)emails {
    if (!_emails) {
        _emails = [NSMutableArray arrayWithCapacity:0];
    }
    return _emails;
}

- (NSMutableArray *)groups {
    if (!_groups) {
        _groups = [NSMutableArray arrayWithCapacity:0];
    }
    return _groups;
}

- (NSMutableArray *)friends2 {
    if (!_friends2) {
        _friends2 = [NSMutableArray arrayWithCapacity:0];
    }
    return _friends2;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[self.parentViewController.tableView reloadData];
}

- (IBAction)doneBtnPressed:(id)sender {
    //[self.shareView dismissViewControllerAnimated:NO completion:nil];
    [self getCheckedEmails];
    //self.shareView.emailList = [[self getCheckedEmails] copy];
    [self.delegate contactListViewControllerDidFinish:self];
    //[self.shareView.tbView reloadData];
}
- (IBAction)cancelBtnpressed:(id)sender {
    
        [self.navigationController popViewControllerAnimated:YES];
}
/*
 - (IBAction)shareBtnPressed:(id)sender {
 [self setPermissionFinal];
 }
 */
- (void)setNumOfObjectsInGroupAndMember
{
    NSInteger gLen = [self.groupAndMember count];
    NSInteger count = 0;
    for (NSInteger j = 0; j < gLen; j++) {
        NSMutableArray *group = [self.groupAndMember objectAtIndex:j];
        for(NSInteger i = 0; i < [group count]; i++) {
            count += 1;
        }
    }
    _numOfObjectsInGroupAndMember = count;
}

- (NSMutableArray *)checkMarkForGroupAndMember
{
    if (!_checkMarkForGroupAndMember) {
        _checkMarkForGroupAndMember = [NSMutableArray arrayWithCapacity:0];
    }
    return _checkMarkForGroupAndMember;
}

- (NSMutableArray *)checkMarkForFriends
{
    if (!_checkMarkForFriends) {
        _checkMarkForFriends = [NSMutableArray arrayWithCapacity:0];
    }
    return _checkMarkForFriends;
}

- (NSMutableArray *)groupAndMember
{
    if (!_groupAndMember) {
        _groupAndMember = [NSMutableArray arrayWithCapacity:0];
    }
    return _groupAndMember;
}

- (NSMutableArray *)friends
{
    if (!_friends) {
        _friends = [NSMutableArray arrayWithCapacity:0];
    }
    return _friends;
}

//Helpers get contact list into array
//Get groups, return false for failure
- (void) setGroups: (NSMutableArray *)groups
{
    [groups sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    //get groups list
    //for each group, add a mutable array with first item as group name
    NSInteger len = [groups count];
    for (NSInteger i = 0; i < len; i++) {
        NSMutableArray *group = [NSMutableArray arrayWithCapacity:0];
        [group addObject: [groups objectAtIndex:i]];
        [self.groupAndMember addObject:group];
      
        
        NSMutableArray *groupMark = [NSMutableArray arrayWithCapacity:0];
        [groupMark addObject:[NSNumber numberWithInt:0]];
        [self.checkMarkForGroupAndMember addObject:groupMark];
    }
}

- (NSInteger) getIndexFromGroupAndMemberFor:(NSString *)groupName
{
    NSInteger gLen = [self.groupAndMember count];
    NSInteger count = 0;
    for (NSInteger j = 0; j < gLen; j++) {
        NSMutableArray *group = [self.groupAndMember objectAtIndex:j];
        for(NSInteger i = 0; i < [group count]; i++) {
            if ([[group objectAtIndex:0] isEqualToString:groupName]) {
                return count;
            }
            count += 1;
        }
    }
    return nil;
}

- (NSInteger) getIndexFromFriendsFor:(NSString *)friendName
{
    NSInteger gLen = [self.friends count];
    for (NSInteger i = 0; i < gLen; i++) {
        if([[[self.friends objectAtIndex:i] objectForKey:@"friendEmail"] isEqualToString:friendName]) {
            return i;
        }
    }
    return nil;
}

//Get friends, return false for failure
- (void) setFriends: (NSMutableArray *)friends
{
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"friendEmail" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    [friends sortUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    //get friend list
    NSInteger len = [friends count];
    for (NSInteger i = 0; i < len; i++) {
        [self.friends addObject:[friends objectAtIndex:i]];
        
        [self.checkMarkForFriends addObject:[NSNumber numberWithInt:0]];
    }
}

- (BOOL) addMembers:(NSMutableArray *)members toGroup: (NSInteger)index
{
    if (index >= [self.groupAndMember count]) {
        return false;
    } else {
        for  (NSInteger i = 0; i < [members count]; i++) {
            [[self.groupAndMember objectAtIndex:index] addObject:[members objectAtIndex:i]];
            [[self.checkMarkForGroupAndMember objectAtIndex:index] addObject:[NSNumber numberWithInt:0]];
        }
        return true;
    }
}

- (void) addMemberInCheckedGroupTo: (NSMutableArray *) emails
{
    NSInteger i, j, len;
    
    len = [self.checkMarkForGroupAndMember count];

    for (i = 0; i < len; i++) {
        if ([[self.checkMarkForGroupAndMember objectAtIndex:i] objectAtIndex:0] == [NSNumber numberWithInt:1]) {
            NSMutableArray *group = [self.groupAndMember objectAtIndex:i];
            for (j = 1; j < [group count]; j++) {
                [self.emails addObject:[NSString stringWithFormat:@"%@", [[group objectAtIndex:j] objectForKey:@"friendEmail"]]];
            }
        }
    }
}

- (void) addGroup
{
    NSInteger i, len;
    
    len = [self.checkMarkForGroupAndMember count];
    
    for (i = 0; i < len; i++) {
        if ([[self.checkMarkForGroupAndMember objectAtIndex:i] objectAtIndex:0] == [NSNumber numberWithInt:1]) {
            NSMutableArray *group = [self.groupAndMember objectAtIndex:i];

            [self.groups addObject:[NSString stringWithFormat:@"%@", [group objectAtIndex:0]]];
            
        }
    }
}

- (void) addMemberInCheckedFriendTo: (NSMutableArray *) emails
{
    NSInteger i, len;
    len = [self.checkMarkForFriends count];
    for (i = 0; i < len; i++) {
        if ([self.checkMarkForFriends objectAtIndex:i] == [NSNumber numberWithInt:1]) {
            [self.emails addObject:[NSString stringWithFormat:@"%@",[[self.friends objectAtIndex:i] objectForKey:@"friendEmail"]]];
            [self.friends2 addObject:[NSString stringWithFormat:@"%@",[[self.friends objectAtIndex:i] objectForKey:@"friendEmail"]]];
        }
    }
}

- (BOOL)isRowForGroup:(NSInteger)rowIndex
{
    if (rowIndex > ([self numOfObjectsInGroupAndMember] - 1))
        return false;
    
    NSInteger gLen = [self.groupAndMember count];
    NSInteger count = 0;
    for (NSInteger j = 0; j < gLen; j++) {
        NSMutableArray *group = [self.groupAndMember objectAtIndex:j];
        for(NSInteger i = 0; i < [group count]; i++) {
            if (count == rowIndex) {
                if (i == 0) {
                    return true;
                }
                else {
                    return false; 
                }
            }
            count += 1;
        }
    }
    return false;
}

- (NSString *)getNameAtGroupAndMember:(NSInteger)rowIndex
{
    NSInteger gLen = [self.groupAndMember count];
    NSInteger count = 0;
    for (NSInteger j = 0; j < gLen; j++) {
        NSMutableArray *group = [self.groupAndMember objectAtIndex:j];
        for(NSInteger i = 0; i < [group count]; i++) {
            if (count == rowIndex) {
                if (i == 0)
                    return [group objectAtIndex:i];
                else
                    return [[[group objectAtIndex:i] objectForKey:@"friendEmail"] substringTo:@"@"];
            }
            count += 1;
        }
    }
}

- (NSString *)getEmailAtGroupAndMember:(long)rowIndex
{
    long groupCount = [self.groupAndMember count];
    NSInteger count = 0;
    for (NSInteger j = 0; j < groupCount; j++) {
        NSMutableArray *group = [self.groupAndMember objectAtIndex:j];
        for(NSInteger i = 0; i < [group count]; i++) {
            if (count == rowIndex) {
                if (i == 0)
                    return [group objectAtIndex:i];
                else
                {
                    return [[group objectAtIndex:i] objectForKey:@"friendEmail"];
                }
            }
            count += 1;
        }
    }
    return @"";
}

- (NSInteger)indexForGroupName:(NSString *)name
{
    NSInteger gLen = [self.groupAndMember count];
    NSInteger count = 0;
    for (NSInteger j = 0; j < gLen; j++) {
        NSMutableArray *group = [self.groupAndMember objectAtIndex:j];
        if ([name isEqualToString:[group objectAtIndex:0]])  {
            return j;
        }
    }
}

- (BOOL)isGroupExpanded:(NSInteger)indexInGroup
{
    NSMutableArray *group = [self.groupAndMember objectAtIndex:indexInGroup];
    if ([group count] > 1)
        return true;
    else
        return false;
    
}

- (NSInteger) getIndexInGroupAndMember: (NSInteger)row
{
    NSInteger gLen = [self.groupAndMember count];
    NSInteger count = 0;
    for (NSInteger j = 0; j < gLen; j++) {
        NSMutableArray *group = [self.groupAndMember objectAtIndex:j];
        for (NSInteger i = 0; i < [group count]; i++)
        {
            if (count == row)
                return j;
            count += 1;
        }
    }
}

/*
 - (id)initWithStyle:(UIViewController *)style
 {
 self = [super init];
 if (self) {
 // Custom initialization
 }
 return self;
 }
 */
- (void)removeGroupMemberAtIndex:(NSInteger)indexGroup
{
    NSMutableArray *group = [self.groupAndMember objectAtIndex:indexGroup];
    NSRange member = {1, [group count] - 1};
    [group removeObjectsInRange:member];
    
    NSMutableArray *groupCheck = [self.checkMarkForGroupAndMember objectAtIndex:indexGroup];
    [groupCheck removeObjectsInRange:member];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    // NSMutableString *path = [NSMutableString stringWithString:@"Path:/"];
    //return [NSString stringWithFormat:@"%@ %@",  NSLocalizedString(@"EditPermissionFileName", ""), self.fileName];
    return NSLocalizedString(@"Selecting", @"" );
    
    /*
     if ([self.arrayOfFoldersUpToCurrentLayer count] > 0) {
     for (NSInteger i = 0; i < [self.arrayOfFoldersUpToCurrentLayer count]; i++) {
     if (i == [self.arrayOfFoldersUpToCurrentLayer count] - 1) {
     [path appendFormat:@"%@", [[self.arrayOfFoldersUpToCurrentLayer lastObject] objectForKey:@"name"]];
     }
     else {
     [path appendString:@"../"];
     }
     }
     }
     return path;
     */
}
- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = NSLocalizedString(@"ContactListLabel", nil);
}

- (void)viewDidLoad
{

//    UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back_blue"] style:UIBarButtonItemStylePlain
//                                                                  target:self
//                                                                  action:@selector(cancelButtonPressed:)];
//    self.navigationItem.leftBarButtonItem = leftBarBtn;
    
    //[self.navigationItem setTitle:NSLocalizedString(@"ContactListLabel", @"")];
    //self.naviBtn.title = NSLocalizedString(@"DoneLabel", @"");
    [self.navigationController setNavigationBarHidden:NO];
    self.cancelBtn.image = [UIImage imageNamed:@"icon_back_blue"];
    self.doneBtn.title = NSLocalizedString(@"DoneKey", nil);
    self.tbView.delegate = self;
    self.tbView.dataSource = self;
    if ([(UIViewController *)self.delegate isKindOfClass:[USAVSecureChatListTableViewController class]]) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    self.friendTextField.delegate = self;
    //self.groupTextField.delegate = self;
    
    self.friendTextField.placeholder = NSLocalizedString(@"GuidedEditPermissionFriendText", @"");
    //self.groupTextField.placeholder = NSLocalizedString(@"GuidedEditPermissionGroupText", @"");
    
    self.fileNameTxt.text = self.fileName;
    [self listGroup];
    
    //[self listTrustedContact];
    
    //[self setNumOfObjectsInGroupAndMember];
    //[self.naviBar setTitle:NSLocalizedString(@"EditPermissionTitleBar", "")];
    [super viewDidLoad];
    
    //设置hintLabel
    self.hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    self.hintLabel.center = CGPointMake(self.tbView.center.x, self.tbView.center.y - 40);
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    self.hintLabel.textColor = [UIColor colorWithWhite:0.3 alpha:0.9];
    self.hintLabel.text = NSLocalizedString(@"No CONDOR Contact", nil);
    self.hintLabel.font = [UIFont boldSystemFontOfSize:13];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    //显示hint提示
    if (!(self.numOfObjectsInGroupAndMember + [self.friends count])) {
        
        self.tbView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        self.hintLabel.text = NSLocalizedString(@"No CONDOR Contact", nil);
        if (![[self.tbView subviews] containsObject:self.hintLabel]) {
            [self.tbView addSubview:self.hintLabel];
        }
        
    } else {
        self.tbView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        if ([[self.tbView subviews] containsObject:self.hintLabel]) {
            [self.hintLabel removeFromSuperview];
        }
        
    }
    
    // Return the number of rows in the section.
    return self.numOfObjectsInGroupAndMember + [self.friends count];
}

- (BOOL)isMarkChecked:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self numOfObjectsInGroupAndMember])
        return [self isMarkCheckedInGroupAndMember:indexPath.row];
    else
        return [self isMarkCheckedInFriends:indexPath.row - [self numOfObjectsInGroupAndMember]];
}

- (BOOL)isMarkCheckedInGroupAndMember:(NSInteger)index
{
    NSInteger gLen = [self.checkMarkForGroupAndMember count];
    NSInteger count = 0;
    for (NSInteger j = 0; j < gLen; j++) {
        NSMutableArray *group = [self.checkMarkForGroupAndMember objectAtIndex:j];
        for (NSInteger i = 0; i < [group count]; i++) {
            if (count == index)
            {
                if ([group objectAtIndex:i] == [NSNumber numberWithInt:1])
                    return true;
                else
                    return false;
            }
            count += 1;
        }
    }
    return false;
}

- (BOOL)isMarkCheckedInFriends:(NSInteger)index
{
    NSInteger fLen = [self.checkMarkForFriends count];
    NSInteger count = 0;
    for (NSInteger j = 0; j < fLen; j++) {
        if (count == index) {
            if ([self.checkMarkForFriends objectAtIndex:j] == [NSNumber numberWithInt:1])
                return true;
            else
                return false;
        }
        count += 1;
    }
    return false;
}


- (void)checkMark:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self numOfObjectsInGroupAndMember])
        [self checkMarkInGroupAndMember:indexPath.row];
    else
        [self checkMarkInFriends:indexPath.row - [self numOfObjectsInGroupAndMember]];
}


- (void)uncheckMark:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self numOfObjectsInGroupAndMember])
        [self uncheckMarkInGroupAndMember:indexPath.row];
    else
        [self uncheckMarkInFriends:indexPath.row - [self numOfObjectsInGroupAndMember]];
}


- (void)checkMarkInGroupAndMember:(NSInteger)index
{
    [self checkMarkChangeInGroupAndMember:index to:[NSNumber numberWithInt:1]];
}

- (void)checkMarkInFriends:(NSInteger)index
{
    [self checkMarkChangeInFriends:index to:[NSNumber numberWithInt:1]];
}

- (void)uncheckMarkInGroupAndMember:(NSInteger)index
{
    [self checkMarkChangeInGroupAndMember:index to:[NSNumber numberWithInt:0]];
}

- (void)uncheckMarkInFriends:(NSInteger)index
{
    [self checkMarkChangeInFriends:index to:[NSNumber numberWithInt:0]];
}

- (void)checkMarkChangeInGroupAndMember:(NSInteger)index to:(NSNumber *)mark
{
    NSInteger gLen = [self.checkMarkForGroupAndMember count];
    NSInteger count = 0;
    for (NSInteger j = 0; j < gLen; j++) {
        NSMutableArray *group = [self.checkMarkForGroupAndMember objectAtIndex:j];
        for (NSInteger i = 0; i < [group count]; i++) {
            if (count == index)
            {
                [group replaceObjectAtIndex:i withObject:mark];
                return;
            }
            count += 1;
        }
    }
}

- (void)checkMarkChangeInFriends:(NSInteger)index to:(NSNumber *)mark
{
    NSInteger fLen = [self.checkMarkForFriends count];
    NSInteger count = 0;
    for (NSInteger j = 0; j < fLen; j++) {
        if (count == index)
        {
            [self.checkMarkForFriends replaceObjectAtIndex:j withObject:mark];
            return;
        }
        count += 1;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier: CellIdentifier];
    }
    
    if ([self isMarkChecked:indexPath])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.textColor = [UIColor blackColor];
    // Configure the cell...
    //cell.textLabel.text = [self getMyDataForRow:indexPath.row inSection:indexPath.section];
    [self setCell:cell inPath:indexPath];
    return cell;
}

- (void)setCell:(UITableViewCell *) cell inPath:(NSIndexPath *)indexPath
{
    [cell.imageView setHidden:NO];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:11];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    
    if (indexPath.row < self.numOfObjectsInGroupAndMember) {
        long row = indexPath.row;
        NSString* alias = [self getNameAtGroupAndMember:row];
        cell.textLabel.text = alias;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        if (![self isRowForGroup:row]) {
            NSString* email = [self getEmailAtGroupAndMember:row];
            if(alias == nil || [alias length] == 0)
            {
                alias = [email substringTo:@"@"];
            }
            cell.detailTextLabel.text = email;
            cell.imageView.image = [self setCellImageForRowGroup:indexPath.row inSection:indexPath.section];
            [cell.imageView setHidden:YES];
        } else {
            cell.detailTextLabel.text = nil;
            cell.imageView.image = [self setCellImageForRowGroup:indexPath.row inSection:indexPath.section];
        }
    } else {
        long row = indexPath.row - self.numOfObjectsInGroupAndMember;
        NSDictionary *contact = [self.friends objectAtIndex:row];
        NSString* email = [contact objectForKey:@"friendEmail"];
        NSString* alias = [contact objectForKey:@"friendAlias"];
        if(alias == nil || [alias length] == 0)
        {
            alias = [email substringTo:@"@"];
        }
        
        cell.textLabel.text = alias;
        cell.detailTextLabel.text = email;
        
        if ([[contact objectForKey:@"friendStatus"] isEqualToString:@"inactivated"]) {
            //cell.textLabel.textColor = [UIColor redColor];
            cell.imageView.image = [UIImage imageNamed:@"person24_gray.png"];
            
        } else {
            cell.imageView.image = [UIImage imageNamed:@"person.png"];
        }
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        //cell.imageView.image = [self setCellImageForRowFriend:indexPath.row inSection:indexPath.section];
    }
}


- (UIImage *) setCellImageForRowGroup:(NSInteger)row inSection:(NSInteger) section
{
    if ([self isRowForGroup:row])
        return [UIImage imageNamed:@"group3.png"];
    else
        return [UIImage imageNamed:@"person.png"];
}

- (UIImage *) setCellImageForRowFriend:(NSInteger) row inSection:(NSInteger) section
{
    //if ([[[self.friends objectAtIndex:row] objectForKey:@"status"] integerValue] == 0) {
    return [UIImage imageNamed:@"person.png"];
    /*} else {
     return [UIImage imageNamed:@"person3.png"];
     }*/
}

- (NSString *)setCellTextForRowGroup:(NSInteger) row inSection:(NSInteger) section
{
    if ([self isRowForGroup:row])
        return [NSString stringWithFormat:@"%@", [self getNameAtGroupAndMember:row]];
    else
        return [NSString stringWithFormat:@"%@", [self getNameAtGroupAndMember:row]];
}

- (NSString *)setCellTextForRowFriends:(NSInteger) row inSection:(NSInteger) section
{
    return [NSString stringWithFormat:@"%@", [[self.friends objectAtIndex:row] objectForKey:@"friendEmail"]];
}

-(void)listGroup
{
    self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarContactList", @"")
                                                  delegate:self];
    
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@", client.emailAddress, @"\n", [client getDateTimeStr], @"\n", @"\n"];
    
    NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    
    [requestElement addChild:paramElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api listGroup:encodedGetParam target:(id)self selector:@selector(listGroupResult:)];
}

-(void) listGroupResult:(NSDictionary*)obj {
    if (obj == nil) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        /*WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
         [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
         [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
         */
        
        [self.navigationController popViewControllerAnimated:YES];
        
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        return;
        
    }
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
	if (obj != nil) {
        NSLog(@"%@ list group result: %@", [self class], obj);
        
        if (([obj objectForKey:@"groupList"] != nil) && ([[obj objectForKey:@"groupList"] count] > 0)) {
            [self setGroups:[obj objectForKey:@"groupList"]];
        }
        
        if ([[obj objectForKey:@"statusCode"] integerValue] == 0) {
            
            [self listTrustedContactStatus];
            
        } else {
            
            [self.alert dismissWithClickedButtonIndex:0 animated:YES];
            WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
            [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
            [wv show:NSLocalizedString(@"FailedToListGroupKey", @"") inView:self.view];
            
        }
    }
    else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FailedToListGroupKey", @"") inView:self.view];
    }
}

-(void)listTrustedContactStatus
{
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", @"\n"];
    
    NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    
    [requestElement addChild:paramElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api listTrustedContactStatus:encodedGetParam target:(id)self selector:@selector(listTrustedContactStatusResult:)];
}

-(void)listGroupMemberStatus:(NSString *)groupId
{
    self.alert = [SGDUtilities showLoadingMessageWithTitle:@"Loading" delegate:self];
    
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", groupId, @"\n"];
    
    NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"group" stringValue:groupId];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    [self setTempGroupName:groupId];
    
    [client.api listGroupMemberStatus:encodedGetParam target:(id)self selector:@selector(listGroupMemberStatusResult:)];
}


-(void) listGroupMemberStatusResult:(NSDictionary*)obj {
    
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
   	if ((obj != nil) && ([obj objectForKey:@"contactList"] != nil)) {
       
        NSInteger n = [[self.groupAndMember objectAtIndex:[self indexForGroupName:self.tempGroupName]] count];
        if (n < 2) {
            [self addMembers:[obj objectForKey:@"contactList"] toGroup:[self indexForGroupName:self.tempGroupName]];
        }
        [self setNumOfObjectsInGroupAndMember];
        [self.tbView reloadData];
        
        // [self.tblView reloadData];
    }
    else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FailedToListGroupMemberKey", @"") inView:self.view];
    }
}


-(void) listTrustedContactStatusResult:(NSDictionary*)obj {
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        
        return;
    }
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
	if (obj != nil) {
        NSLog(@"%@ list trust contact result: %@", [self class], obj);
        
        if ([obj objectForKey:@"contactList"]) {
            [self setFriends:[obj objectForKey:@"contactList"]];
            [self setNumOfObjectsInGroupAndMember];
            [self.tbView reloadData];

        }
        
        if ([[obj objectForKey:@"statusCode"] integerValue] == 0) {
            
            return;
            
        } else {
            
            [self.alert dismissWithClickedButtonIndex:0 animated:YES];
            WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
            [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
            [wv show:NSLocalizedString(@"FailedToListTrustContactKey", @"") inView:self.view];
            
        }

    }
    else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FailedToListTrustContactKey", @"") inView:self.view];
    }
}

-(void)listTrustedContact
{
    
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@", client.emailAddress, @"\n", [client getDateTimeStr], @"\n", @"\n"];
    
    NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    
    [requestElement addChild:paramElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api listTrustedContact:encodedGetParam target:(id)self selector:@selector(listTrustedContactResult:)];
}

#pragma mark - Table view delegate
-(void) listGroupMemberResult:(NSDictionary*)obj {
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
	if ((obj != nil) && ([obj objectForKey:@"memberList"] != nil)) {
        NSLog(@"%@ list group member result: %@", [self class], obj);
        // NSDictionary *parent = [NSDictionary dictionaryWithDictionary:[obj objectForKey:@"parent"]];
        
        [self addMembers:[obj objectForKey:@"memberList"] toGroup:[self indexForGroupName:self.tempGroupName]];
        //[self.arrayOfContacts addObjectsFromArray:[obj objectForKey:@"memberList"]];
        [self setNumOfObjectsInGroupAndMember];
        [self.tbView reloadData];
        
        // [self.tblView reloadData];
    }
    else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FailedTolistGroupMemberKey", @"") inView:self.view];
    }
}

-(void) listGroupMemberResult2:(NSDictionary*)obj {
    if (obj == nil || [[obj objectForKey:@"statusCode"] integerValue] != 0) {
        return;
    }
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
    NSMutableArray *memList = [obj objectForKey:@"memberList"];
    
	if (memList != nil) {
        
        NSLog(@"%@ list group member result: %@", [self class], obj);
        
        if ([memList count] > 0) {
            [self addMembers:[obj objectForKey:@"memberList"] toGroup:[self indexForGroupName:[self.originPermissionGroups objectAtIndex:self.indexForOriginGroup]]];
            [self setNumOfObjectsInGroupAndMember];
        }
        self.indexForOriginGroup += 1;
        if (self.indexForOriginGroup == [self.originPermissionGroups count])
        {
            //give check for groups
            //give check for friends
            [self setCheckMarkForOrigins];
            [UIView transitionWithView: self.tbView
                              duration: 0.50f
                               options: UIViewAnimationOptionTransitionCrossDissolve
                            animations: ^(void)
             {
                 [self.tbView reloadData];
             }
                            completion: ^(BOOL isFinished)
             {
                 /* TODO: Whatever you want here */
             }];
            //[self.tableView reloadData];
            return;
        }
        
        [self listGroupMemberStatus:[self.originPermissionGroups objectAtIndex:self.indexForOriginGroup]];
    }
    else {
        return;
    }
}

- (void)setCheckMarkForOrigins
{
    for (NSInteger i = 0; i < [self.originPermissionGroups count]; i++) {
        [self checkMarkInGroupAndMember:[self getIndexFromGroupAndMemberFor:[self.originPermissionGroups objectAtIndex:i]]];
    }
    
    for (NSInteger i = 0; i < [self.originPermissionFriends count]; i++) {
        [self checkMarkInFriends:[self getIndexFromFriendsFor:[self.originPermissionFriends objectAtIndex:i]]];
    }
}

-(void)listGroupMember:(NSString *)groupId
{
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", groupId, @"\n"];
    
    NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"group" stringValue:groupId];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    [self setTempGroupName:groupId];
    [client.api listGroupMember:encodedGetParam target:(id)self selector:@selector(listGroupMemberResult:)];
}

-(void)listGroupMember2:(NSString *)groupId
{
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", groupId, @"\n"];
    
    NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"group" stringValue:groupId];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    //[self setTempGroupName:groupId];
    [client.api listGroupMember:encodedGetParam target:(id)self selector:@selector(listGroupMemberResult2:)];
}


- (void)setPermissionMono:(NSString *)keyId for:(NSString *)name isUser:(NSInteger)isUser withPermission:(NSInteger)permission
{
    
    USAVClient *client = [USAVClient current];
    NSString * subParameters = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",[[NSString alloc] initWithFormat:@"%zi",isUser], @"\n", keyId, @"\n",
                                name, @"\n", [[NSString alloc] initWithFormat:@"%zi", permission]];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n",
                              subParameters, @"\n"];
    
    NSLog(@"stringToSign: %@", stringToSign);
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"keyId" stringValue:self.keyId];
    [paramsElement addChild:paramElement];
    
    paramElement = [GDataXMLNode elementWithName:@"name" stringValue:name];
    [paramsElement addChild:paramElement];
    
    paramElement = [GDataXMLNode elementWithName:@"isUser" stringValue:[[NSString alloc] initWithFormat:@"%zi", isUser]];
    [paramsElement addChild:paramElement];
    
    paramElement = [GDataXMLNode elementWithName:@"permission" stringValue:[[NSString alloc] initWithFormat:@"%zi",permission]];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api setFriendListPermision:encodedGetParam target:(id)self selector:@selector(setPermissionCallBack:)];
    
}

- (void)getPermissionList:(NSString *)keyId
{
    
    USAVClient *client = [USAVClient current];
    NSString * subParameters = [NSString stringWithFormat:@"%@", keyId];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n",
                              subParameters, @"\n"];
    
    NSLog(@"stringToSign: %@", stringToSign);
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"keyId" stringValue:self.keyId];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api listFriendListPermision:encodedGetParam target:(id)self selector:@selector(getPermissionListCallBack:)];
}

- (void)getPermissionListCallBack:(NSDictionary*)obj
{
    //if failed show editPermission failed
    
    //else if success number < target number
    //accumulate success number
    //else if success number == target number
    //show success message then dissmiss the view
    
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        return;
    }
    
    if ((obj != nil) && ([[obj objectForKey:@"statusCode"] integerValue] == 0)) {
        NSArray *permissionList = [obj objectForKey:@"permissionList"];
        if (!permissionList)
        {
            return;
        }
        
        NSMutableArray *permissionForGroups = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *permissionForFriends = [NSMutableArray arrayWithCapacity:0];
        
        for (NSInteger i = 0; i < [permissionList count]; i++) {
            NSDictionary *unit = [permissionList objectAtIndex:i];
            if ([[unit objectForKey:@"permission"] integerValue] == 1) {
                if ([[unit objectForKey:@"isUser"] integerValue]== 0) {
                    [permissionForGroups addObject:[unit objectForKey:@"name"]];
                } else {
                    [permissionForFriends addObject:[unit objectForKey:@"name"]];
                }
            }
        }
        
        self.originPermissionGroups = permissionForGroups;
        self.originPermissionFriends = permissionForFriends;
        self.indexForOriginGroup = 0;
        
        [self setOriginPermission];
        /*WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
         [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
         [wv show:NSLocalizedString(@"FailedTolistGroupMemberKey", @"") inView:self.view];
         */
    }
    else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FailedTolistGroupMemberKey", @"") inView:self.view];
    }
}

- (void)setOriginPermission{
    
    NSInteger len = [self.originPermissionGroups count];
    if (len > 0) {
        [self listGroupMemberStatus:[self.originPermissionGroups objectAtIndex:self.indexForOriginGroup]];
    } else {
        [self setCheckMarkForOrigins];
        [UIView transitionWithView: self.tbView
                          duration: 0.50f
                           options: UIViewAnimationOptionTransitionCrossDissolve
                        animations: ^(void)
         {
             [self.tbView reloadData];
         }
                        completion: ^(BOOL isFinished)
         {
             /* TODO: Whatever you want here */
         }];
        //[self.tableView reloadData];
    }
}
/*
 - (IBAction)doneBtnPressed:(id)sender {
 [self setPermissionFinal];
 }
 */
- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSArray*)getCheckedEmails
{
    [self addMemberInCheckedGroupTo:self.emails];
    [self addMemberInCheckedFriendTo:self.emails];
    [self addGroup];
    return self.emails;
}

- (void)setPermissionFinal
{
    //self.numberOfTargetPermissions = 0;
    //self.numberOfSetPermissionSuccess = 0;
    //loop over every checkMark
    
    self.numberOfTargetPermissions = 0;
    self.numberOfSetPermissionSuccess = 0;
    NSInteger lenGroupAndMember = [self numOfObjectsInGroupAndMember];
    for (NSInteger i = 0; i < lenGroupAndMember; i++)
    {
        if ([self isRowForGroup:i]) {
            //if ([self isMarkChecke                                                                                                    ·10seGroupAndMember:i]) {
            self.numberOfTargetPermissions += 1;
            //}
        }
    }
    
    NSInteger lenFriends = [self.friends count];
    for (NSInteger i = 0; i <lenFriends; i++)
    {
        //if ([self isMarkCheckedInFriends:i]) {
        self.numberOfTargetPermissions += 1;
        // }
    }
    
    if (!lenGroupAndMember && !lenFriends) {
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:@"Send via email"];
        [controller setMessageBody:@"Attached is a secure file." isHTML:YES];
        [controller addAttachmentData:[NSData dataWithContentsOfFile:self.filePath]
                             mimeType:@"application/octet-stream"
                             fileName:self.fileNameTxt.text];
        if (controller) {
            [self presentViewController:controller animated:YES completion:nil];
        }
        
        return;
    } else {
        self.alert = [SGDUtilities showLoadingMessageWithTitle:@""
                                                      delegate:self];
    }
    
    for (NSInteger i = 0; i < [self.addedFriendList count]; i++) {
        self.numberOfTargetPermissions += 1;
    }
    
    for (NSInteger i = 0; i < [self.addedGroupList count]; i++) {
        self.numberOfTargetPermissions += 1;
    }
    
    for (NSInteger i = 0; i < lenGroupAndMember; i++)
    {
        if ([self isRowForGroup:i]) {
            if ([self isMarkCheckedInGroupAndMember:i]) {
                [self setPermissionMono:self.keyId for:[self getNameAtGroupAndMember:i] isUser:0 withPermission:1];
            } else {
                [self setPermissionMono:self.keyId for:[self getNameAtGroupAndMember:i] isUser:0 withPermission:0];
            }
        }
    }
    
    for (NSInteger i = 0; i <lenFriends; i++)
    {
        if ([self isMarkCheckedInFriends:i]) {
            [self setPermissionMono:self.keyId for:[[self.friends objectAtIndex:i] objectForKey:@"friendEmail"] isUser:1 withPermission:1];
        } else {
            [self setPermissionMono:self.keyId for:[[self.friends objectAtIndex:i] objectForKey:@"friendEmail"] isUser:1 withPermission:0];
        }
    }
    
    for (NSInteger i = 0; i < [self.addedFriendList count]; i++) {
        [self setPermissionMono:self.keyId for:[self.addedFriendList objectAtIndex:i] isUser:1 withPermission:1];
        
    }
    
    for (NSInteger i = 0; i < [self.addedGroupList count]; i++) {
        [self setPermissionMono:self.keyId for:[self.addedGroupList objectAtIndex:i] isUser:0 withPermission:1];
    }
}

- (void)setPermissionCallBack:(NSDictionary*)obj
{
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    
    if (obj == nil) {
        //[self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"SetPermissionFalied", @"") inView:self.view];
        self.numberOfSetPermissionSuccess = 0;
        return;
    }
    
    
    //if failed show editPermission failed
    
    //else if success number < target number
    //accumulate success number
    //else if success number == target number
    //show success message then dissmiss the view
    if ((obj != nil) && ([[obj objectForKey:@"rawStringStatus"] integerValue] == 0)) {
        self.numberOfSetPermissionSuccess += 1;
        if (self.numberOfSetPermissionSuccess == self.numberOfTargetPermissions) {
            /*
             UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EditPermissionSuccessKey", "")
             message:NSLocalizedString(@"EditPermissionSuccessMsg", "")
             delegate:nil
             cancelButtonTitle:@"OK"
             otherButtonTitles:nil];
             [message show];
             */
            //[self.alert dismissWithClickedButtonIndex:0 animated:YES];
            MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            [controller setSubject:@"Send via email"];
            [controller setToRecipients:[self getCheckedEmails]];
            [controller setMessageBody:@"Attached is a secure file." isHTML:YES];
            [controller addAttachmentData:[NSData dataWithContentsOfFile:self.filePath]
                                 mimeType:@"application/octet-stream"
                                 fileName:self.fileNameTxt.text];
            if (controller) {
                [self presentViewController:controller animated:YES completion:nil];
            }
        }
        
    } else {
        /*
         WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
         [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
         [wv show:NSLocalizedString(@"FailedTolistGroupMemberKey", @"") inView:self.view];
         */
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    //friend
    if ([self isRowForGroup:indexPath.row] || indexPath.row >= self.numOfObjectsInGroupAndMember) {
        
        if ([self isMarkChecked:indexPath])
        {
            [self uncheckMark:indexPath];
        } else {
            [self checkMark:indexPath];
        }
    }
    
    //group
    NSString *groupName;
    if ([self isRowForGroup:indexPath.row])
    {
        //not support group chatting
        if ([(UIViewController *)self.delegate isKindOfClass:[USAVSecureChatListTableViewController class]]) {
            WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
            [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
            [wv show:NSLocalizedString(@"Group chat is not supported in this version", @"") inView:self.view];
            return;
        }
        
        groupName = [self getNameAtGroupAndMember:indexPath.row];
        
        NSInteger indexGroup = [self getIndexInGroupAndMember:indexPath.row];
        //if group is not expanded
        if (![self isGroupExpanded:indexGroup])
        {
            [self listGroupMemberStatus:groupName];
        }
        else //if group is expanded
        {
            [self removeGroupMemberAtIndex:indexGroup];
            [self setNumOfObjectsInGroupAndMember];
            [self.tbView reloadData];
        }
    } else {
        
        //if is chatting selection, just select one and return
        if ([(UIViewController *)self.delegate isKindOfClass:[USAVSecureChatListTableViewController class]]) {
            [self doneBtnPressed:nil];
            return;
        }
        
        [self.tbView reloadData];
    }
    

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

-(void)addFriendList
{
    [self addContactBuildRequest:[self.addedFriendList objectAtIndex:0]];
}

-(void)addGroupList
{
    [self addGroupBuildRequest:[self.addedGroupList objectAtIndex:0]];
}

-(void)addFriendAndGroup
{
    if ([self.addedGroupList count] == 0)
    {
        [self addFriendList];
    } else {
        [self addGroupList];
    }
}

-(void) addGroupResult:(NSDictionary*)obj {
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        return;
    }
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        NSLog(@"ContactView addGroupResult: %@", obj);
        
        NSInteger rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        /*
         if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
         NSLog(@"ContactView addGroupResult: %@", obj);
         
         NSInteger rc = [[obj objectForKey:@"statusCode"] integerValue];  // if statusCode doesn't exist, we assume rc is 0
         */
        switch (rc) {
            case GROUP_EXIST:
            case SUCCESS:
            {
                //[self.arrayOfGroups addObject:self.addItemTextField.text];
                //[self.tblView reloadData];
                //self.addItemTextField.text = @"";
                self.addGroupSuccess += 1;
                self.addedGroupIndex += 1;
                if (self.addedGroupIndex == [self.addedGroupList count]) {
                    if ([self.addedFriendList count] == 0 || self.addFriendSuccess) {
                        self.addGroupSuccess = true;
                        [self editPermission];
                    } else {
                        [self addContactBuildRequest:[self.addedFriendList objectAtIndex:self.addedFriendIndex]];
                    }
                } else {
                    [self addGroupBuildRequest:[self.addedGroupList objectAtIndex:self.addedGroupIndex]];
                }
                return;
            }
                break;
            case INVALID_GROUP_NAME:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:[NSString stringWithFormat:@"%@  %@", NSLocalizedString(@"GroupNameInvalidKey", @""),[self.addedFriendList objectAtIndex:self.addedFriendIndex]] inView:self.view];
                self.addGroupSuccess = false;
                return;
            }
                break;
                
                /*
                 case GROUP_EXIST:
                 {
                 WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                 [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                 [wv show:NSLocalizedString(@"GroupNameAlreadyExistKey", @"") inView:self.view];
                 return;
                 }
                 break;*/
                
            default:
                break;
        }
    }
    
    if ([obj objectForKey:@"httpErrorCode"] != nil)
        NSLog(@"ContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
    
    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
    [wv show:NSLocalizedString(@"GroupNameUnknownErrorKey", @"") inView:self.view];
}

-(void) addGroupBuildRequest:(NSString *)groupName {
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", groupName, @"\n"];
    
    NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"group" stringValue:groupName];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api addGroup:encodedGetParam target:(id)self selector:@selector(addGroupResult:)];
}

- (void)editPermission
{
    [self setPermissionFinal];
}

-(void) addContactResult:(NSDictionary*)obj {
    if (obj == nil) {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
        
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        return;
    }
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        NSLog(@"ContactView addGroupResult: %@", obj);
        
        NSInteger rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case FRIEND_EXIST:
            case SUCCESS:
            {
                // DY: use this if we want to use the USAVAddContactView to prompt for more than one text field
                /*
                 [delegate addContactViewSaveCmd:self.contactNameTextField.text alias:(NSString *)self.aliasNameTextField.text email:self.emailAddressTextField.text target:self];
                 */
                // [self.arrayOfContacts addObject:self.addItemTextField.text];
                /* NSDictionary *friendDict = [NSDictionary
                 dictionaryWithObjectsAndKeys:self.addItemTextField.text,
                 @"friend", @"", @"alias", @"", @"email", nil];*/
                //[self.arrayOfContacts addObject:friendDict];
                //[self.tblView reloadData];
                //self.addItemTextField.text = @"";
                self.addFriendSuccess += 1;
                self.addedFriendIndex += 1;
                if (self.addedFriendIndex == [self.addedFriendList count]) {
                    if ([self.addedGroupList count] == 0 || self.addGroupSuccess) {
                        [self.emails addObject:[self.tmpFriendName copy]];
                        
                        self.addFriendSuccess = true;
                        [self editPermission];
                    } else {
                        [self addGroupBuildRequest:[self.addedGroupList objectAtIndex:self.addedGroupIndex]];
                    }
                } else {
                    [self addContactBuildRequest:[self.addedFriendList objectAtIndex:self.addedFriendIndex]];
                    //[self.emails addObject:[self.tmpFriendName copy]];
                }
                return;
            }
                break;
                
            case ACC_NOT_FOUND:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:[NSString stringWithFormat:@"%@  %@",NSLocalizedString(@"ContactNameNotFoundKey", @""),[self.addedFriendList objectAtIndex:self.addedFriendIndex]] inView:self.view];
                self.addFriendSuccess = false;
                return;
            }
                break;
                
            case INVALID_FD_ALIAS:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"AliasNameInvalidKey", @"") inView:self.view];
                return;
            }
                
                break;
            case INVALID_EMAIL:
            {
                WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                [wv show:NSLocalizedString(@"EmailNameInvalidKey", @"") inView:self.view];
                return;
            }
                
                break;
                /*case FRIEND_EXIST:
                 {
                 WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
                 [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
                 [wv show:NSLocalizedString(@"FriendNameAlreadyExistKey", @"") inView:self.view];
                 return;
                 }
                 break;*/
            default:
                break;
        }
    }
    
    if ([obj objectForKey:@"httpErrorCode"] != nil)
        NSLog(@"AddContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
    
    WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
    [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
    [wv show:NSLocalizedString(@"AddTrustContactUnknownErrorKey", @"") inView:self.view];
}

-(void)addContactBuildRequest:(NSString *)friendName {
    
    self.tmpFriendName = [friendName copy];
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", @"\n", @"\n", friendName, @"\n"];
    NSLog(@"stringToSign: %@", stringToSign);
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"alias" stringValue:@""];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"email" stringValue:@""];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"friendId" stringValue:friendName];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    [client.api addTrustContact:encodedGetParam target:(id)self selector:@selector(addContactResult:)];
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            //NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
        {
            UINavigationController *ctr = [self parentViewController];
            [self dismissViewControllerAnimated:YES completion:nil];
            [ctr popToRootViewControllerAnimated:NO];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Result" message:@"Email Sent Successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
            return;
        case MFMailComposeResultFailed:
            //NSLog(@"Result: failed");
            break;
        default:
            //NSLog(@"Result: not sent");
            break;
    }
    // [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)emailFile:(NSString *)fullPath
{
    
    NSArray *components = [NSArray arrayWithArray:[fullPath componentsSeparatedByString:@"/"]];
    NSString *filenameComponent = [components lastObject];
    
    NSLog(@"EmailFile: fullPath:%@ filenameComponent:%@", fullPath, filenameComponent);
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:NSLocalizedString(@"SendByEmail", @"")];
    [controller setMessageBody:NSLocalizedString(@"Attached is a secure file.", @"") isHTML:YES];
    [controller addAttachmentData:[NSData dataWithContentsOfFile:fullPath]
                         mimeType:@"application/octet-stream"
                         fileName:filenameComponent];
    if (controller) {
        //[self presentModalViewController:controller animated:YES];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)viewDidUnload {
    //[self setDoneBtn:nil];
    //[self setNavigationBar:nil];
    //[self setNaviBar:nil];
    
    [self setFileNameTxt:nil];
    
    
    [self setFriendTextField:nil];
    
    [self setTbView:nil];
    [self setFileNameTxt:nil];
    [super viewDidUnload];
}


@end
