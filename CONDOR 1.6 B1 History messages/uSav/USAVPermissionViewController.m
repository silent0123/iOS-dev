//
//  MyTableViewController.m
//  TableViewTest
//
//  Created by NWHKOSX49 on 5/12/12.
//  Copyright (c) 2012 nwStor. All rights reserved.
//

#import "USAVPermissionViewController.h"
#import "USAVClient.h"
#import "API.h"
#import "WarningView.h"
#import "GDataXMLNode.h"
#import "SGDUtilities.h"

@interface USAVPermissionViewController ()

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
@property (nonatomic, strong) UIAlertView *alert;
@end

@implementation USAVPermissionViewController

@synthesize groupAndMember = _groupAndMember;
@synthesize friends = _friends;
@synthesize indexInContacts = _indexInContacts;
@synthesize numOfObjectsInGroupAndMember = _numOfObjectsInGroupAndMember;
@synthesize tempGroupName = _tempGroupName;
@synthesize checkMarkForGroupAndMember = _checkMarkForGroupAndMember;
@synthesize checkMarkForFriends = _checkMarkForFriends;
@synthesize keyId = _keyId;
@synthesize tableView = _tableView;

@synthesize originPermissionGroups= _originPermissionGroups;
@synthesize originPermissionFriends = _originPermissionFriends;

@synthesize indexForOriginGroup = _indexForOriginGroup;
@synthesize naviBar = _naviBar;
@synthesize alert = _alert;

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

- (BOOL) isRowForGroup:(NSInteger)rowIndex
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

- (NSString *) getNameAtGroupAndMember:(NSInteger)rowIndex
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
                    return [[group objectAtIndex:i] objectForKey:@"friendEmail"];
            }
            count += 1;
        }
    }
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
    return 24;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    // NSMutableString *path = [NSMutableString stringWithString:@"Path:/"];
    return [NSString stringWithFormat:@"%@ %@",  NSLocalizedString(@"EditPermissionFileName", ""), self.filename];
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

- (void)viewDidLoad
{
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.CancelBtn setTitle:NSLocalizedString(@"CancelKey", @"")];
    [self.DoneBtn setTitle:NSLocalizedString(@"DoneLabel", @"")];
    [self listGroup];
    
    //[self listTrustedContact];
    
    //[self setNumOfObjectsInGroupAndMember];
    [self.naviBar setTitle:NSLocalizedString(@"EditPermissionTitleBar", "")];
    [super viewDidLoad];
    
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
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
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
    cell.imageView.image = nil;
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
    if (indexPath.row < self.numOfObjectsInGroupAndMember) {
        cell.textLabel.text = [self setCellTextForRowGroup:indexPath.row inSection:indexPath.section];
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        //cell.imageView.image = [self setCellImageForRowGroup:indexPath.row inSection:indexPath.section];
        if (![self isRowForGroup:indexPath.row]) {
            //cell.textLabel.textColor = [UIColor redColor];
        }else {
            cell.imageView.image = [self setCellImageForRowGroup:indexPath.row inSection:indexPath.section];
        }
    } else {
        NSInteger row;
        row = indexPath.row - self.numOfObjectsInGroupAndMember;
        cell.textLabel.text = [self setCellTextForRowFriends:indexPath.row - self.numOfObjectsInGroupAndMember inSection:indexPath.section];
        
        if ([[[self.friends objectAtIndex:row] objectForKey:@"friendStatus"] isEqualToString:@"inactivated"]) {
            //cell.textLabel.textColor = [UIColor redColor];
            cell.imageView.image = [UIImage imageNamed:@"person24_gray.png"];
            
        } else {
            cell.imageView.image = [UIImage imageNamed:@"person.png"];
        }
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        //cell.imageView.image = [self setCellImageForRowFriend:indexPath.row inSection:indexPath.section];
    }
}
//cell.imageView.image = [UIImage imageNamed:@"person3.png"];

- (UIImage *) setCellImageForRowGroup:(NSInteger) row inSection:(NSInteger) section
{
    if ([self isRowForGroup:row])
        return [UIImage imageNamed:@"group3.png"];
    else
        return [UIImage imageNamed:@"person3.png"];
}

- (UIImage *) setCellImageForRowFriend:(NSInteger) row inSection:(NSInteger) section
{
    //if ([[[self.friends objectAtIndex:row] objectForKey:@"status"] integerValue] == 0) {
    return [UIImage imageNamed:@"person3.png"];
    /*} else {
     return [UIImage imageNamed:@"person3.png"];
     }*/
}

- (NSString *)setCellTextForRowGroup:(NSInteger) row inSection:(NSInteger) section
{
    if ([self isRowForGroup:row])
        return [NSString stringWithFormat:@"%@", [self getNameAtGroupAndMember:row]];
    else
        return [NSString stringWithFormat:@"  - %@", [self getNameAtGroupAndMember:row]];
}

- (NSString *)setCellTextForRowFriends:(NSInteger) row inSection:(NSInteger) section
{
    return [NSString stringWithFormat:@"%@", [[self.friends objectAtIndex:row] objectForKey:@"friendEmail"]];
}

-(void)listGroup
{
    self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"ProcessBarPermissionList", @"")
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


-(void) listTrustedContactResult:(NSDictionary*)obj {
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    
    if (obj == nil) {
        /*[self.alert dismissWithClickedButtonIndex:0 animated:YES];
         WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
         [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
         [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
         return;
         */
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"EditPermissionFailedKey", @"") inView:self.view];
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
        // NSDictionary *parent = [NSDictionary dictionaryWithDictionary:[obj objectForKey:@"parent"]];
        if ([obj objectForKey:@"friendList"]) {
            [self setFriends:[obj objectForKey:@"friendList"]];
            [self setNumOfObjectsInGroupAndMember];
            [self getPermissionList: self.keyId];
            //[self.tableView reloadData];
        }
    }
    else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FailedToListTrustContactKey", @"") inView:self.view];
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

-(void) listTrustedContactStatusResult:(NSDictionary*)obj {
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    
    if (obj == nil) {
        /*[self.alert dismissWithClickedButtonIndex:0 animated:YES];
         WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
         [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
         [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
         return;*/
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"EditPermissionFailedKey", @"") inView:self.view];
        return;
    }
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
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
        // NSDictionary *parent = [NSDictionary dictionaryWithDictionary:[obj objectForKey:@"parent"]];
        if ([obj objectForKey:@"contactList"]) {
            [self setFriends:[obj objectForKey:@"contactList"]];
            [self setNumOfObjectsInGroupAndMember];
            [self getPermissionList: self.keyId];
            //[self.tableView reloadData];
        }
    }
    else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FailedToListTrustContactKey", @"") inView:self.view];
    }
}

-(void)listGroupMemberStatus:(NSString *)groupId
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
    
    [client.api listGroupMemberStatus:encodedGetParam target:(id)self selector:@selector(listGroupMemberStatusResult:)];
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
        
        [self setNumOfObjectsInGroupAndMember];
        [self setCheckMarkForOrigins];
        [self.tableView reloadData];
        
        // [self.tblView reloadData];
    }
    else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FailedTolistGroupMemberKey", @"") inView:self.view];
        [self setCheckMarkForOrigins];
        [self.tableView reloadData];
    }
}

-(void) listGroupMemberStatusResult:(NSDictionary*)obj {
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    if ((obj != nil) && ([obj objectForKey:@"contactList"] != nil)) {
        NSLog(@"%@ list group member result: %@", [self class], obj);
        // NSDictionary *parent = [NSDictionary dictionaryWithDictionary:[obj objectForKey:@"parent"]];
        
        [self addMembers:[obj objectForKey:@"contactList"] toGroup:[self indexForGroupName:self.tempGroupName]];
        //[self.arrayOfContacts addObjectsFromArray:[obj objectForKey:@"memberList"]];
        [self setNumOfObjectsInGroupAndMember];
        [self setCheckMarkForOrigins];
        
        [self.tableView reloadData];
        
        // [self.tblView reloadData];
    }
    else {
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FailedTolistGroupMemberKey", @"") inView:self.view];
        [self setCheckMarkForOrigins];
        
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
            [UIView transitionWithView: self.tableView
                              duration: 0.50f
                               options: UIViewAnimationOptionTransitionCrossDissolve
                            animations: ^(void)
             {
                 [self.tableView reloadData];
             }
                            completion: ^(BOOL isFinished)
             {
                 /* TODO: Whatever you want here */
             }];
            //[self.tableView reloadData];
            return;
        }
        
        [self listGroupMember2:[self.originPermissionGroups objectAtIndex:self.indexForOriginGroup]];
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
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    
    //if failed show editPermission failed
    
    //else if success number < target number
    //accumulate success number
    //else if success number == target number
    //show success message then dissmiss the view
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
        //[self.navigationController dismissViewControllerAnimated:YES completion:NULL];
        [self.navigationController popViewControllerAnimated:YES];
        //[self.navigationController popViewControllerAnimated:YES];
        /*
         WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
         [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
         [wv show:NSLocalizedString(@"PermissionDenied", @"") inView:self.view];*/
        //[ dismissViewControllerAnimated:YES completion:nil];
        //[self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setOriginPermission{
    
    NSInteger len = [self.originPermissionGroups count];
    if (len > 0) {
        [self listGroupMemberStatus:[self.originPermissionGroups objectAtIndex:self.indexForOriginGroup]];
    } else {
        [self setCheckMarkForOrigins];
        [UIView transitionWithView: self.tableView
                          duration: 0.50f
                           options: UIViewAnimationOptionTransitionCrossDissolve
                        animations: ^(void)
         {
             [self.tableView reloadData];
         }
                        completion: ^(BOOL isFinished)
         {
             /* TODO: Whatever you want here */
         }];
        //[self.tableView reloadData];
    }
}

- (IBAction)doneBtnPressed:(id)sender {
    [self setPermissionFinal];
}

- (IBAction)cancelPressed:(id)sender {
    //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setPermissionFinal
{
    //self.numberOfTargetPermissions = 0;
    //self.numberOfSetPermissionSuccess = 0;
    //loop over every checkMark
    NSInteger lenGroupAndMember = [self numOfObjectsInGroupAndMember];
    for (NSInteger i = 0; i < lenGroupAndMember; i++)
    {
        if ([self isRowForGroup:i]) {
            //if ([self isMarkCheckedInGroupAndMember:i]) {
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
        //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    } else {
        self.alert = [SGDUtilities showLoadingMessageWithTitle:NSLocalizedString(@"FileEditPermissionKey", @"")
                                                      delegate:self];
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
}

- (void)setPermissionCallBack:(NSDictionary*)obj
{
    if (obj == nil) {
        /*[self.alert dismissWithClickedButtonIndex:0 animated:YES];
         WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
         [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
         [wv show:NSLocalizedString(@"Timeout", @"") inView:self.view];
         self.numberOfSetPermissionSuccess = 0;
         return;*/
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"EditPermissionFailedKey", @"") inView:self.view];
        return;
    }
    
    if ((obj != nil) && ([[obj objectForKey:@"rawStringStatus"] integerValue] == 0)) {
        self.numberOfSetPermissionSuccess += 1;
        //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        if (self.numberOfSetPermissionSuccess == self.numberOfTargetPermissions) {
            /*WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
             [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
             [wv show:NSLocalizedString(@"FailedTolistGroupMemberKey", @"") inView:self.view];
             */
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EditPermissionSuccessKey", "")
                                                              message:NSLocalizedString(@"EditPermissionSuccessMsg", "")
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [message show];
            //[self dismissViewControllerAnimated:YES completion:nil];
            //[self.alert dismissWithClickedButtonIndex:0 animated:YES];
        }
    } else {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        WarningView *wv = [[WarningView alloc] initWithFrame:CGRectMake(0, 0, 280, 64) withFontSize:0];
        [wv setCenter:CGPointMake(MSG_POSITION_X, MSG_POSITION_Y)];
        [wv show:NSLocalizedString(@"FailedTolistGroupMemberKey", @"") inView:self.view];
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
    
    if ([self isRowForGroup:indexPath.row] || indexPath.row >= self.numOfObjectsInGroupAndMember) {
        if ([self isMarkChecked:indexPath])
        {
            [self uncheckMark:indexPath];
        } else {
            [self checkMark:indexPath];
        }
    }
    
    NSString *groupName;
    if ([self isRowForGroup:indexPath.row])
    {    groupName = [self getNameAtGroupAndMember:indexPath.row];
        
        NSInteger indexGroup = [self getIndexInGroupAndMember:indexPath.row];
        //if group is not expanded
        if (![self isGroupExpanded:indexGroup])
        {
            [self listGroupMemberStatus:groupName];
            /*if ((groupName != nil) && [groupName isEqualToString:@"friend"]) {
             NSMutableArray *members = [NSMutableArray arrayWithCapacity:0];
             [members addObject:@"Test1"];
             [members addObject:@"Test2"];
             [self addMembers:members toGroup:[self indexForGroupName:groupName]];
             
             [self setNumOfObjectsInGroupAndMember];
             [self.tableView reloadData];
             }
             */
        } else //if group is expanded
        {
            [self removeGroupMemberAtIndex:indexGroup];
            [self setNumOfObjectsInGroupAndMember];
            [self.tableView reloadData];
        }
    } else {
        [self.tableView reloadData];
    }
}

- (void)viewDidUnload {
    //[self setDoneBtn:nil];
    //[self setNavigationBar:nil];
    [self setTableView:nil];
    [self setNaviBar:nil];
    [super viewDidUnload];
}

@end