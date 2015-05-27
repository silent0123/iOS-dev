//
//  PermissionTableViewController.m
//  uSav-newUI
//
//  Created by Luca on 19/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "PermissionTableViewController.h"

@implementation PermissionTableViewController{
    UITextField *textFiled;
    BOOL firstTime;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Edit Permission", nil);
    
    //初始化permissionList
    _CellData = [[NSMutableArray alloc] initWithCapacity:0];
    //初始化被编辑的PermissionList
    _editingPemissionList = [[NSMutableArray alloc] initWithCapacity:0];
    _addPermissionList = [[NSMutableArray alloc] initWithCapacity:0];
    
    
    //获取最新Permission
    [self getPermissionList:_segueTransKeyId];
    
    firstTime = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    self.tableView.scrollEnabled = YES;
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 0 || section == 3 || section == 4) {
        return 1;
    } else if (section == 1){
        return 2;
    } else if (section == 2){
        //统计permission为1的项显示
        NSLog(@"%@",_CellData);
        NSInteger numOfOnes = 0;
        for (NSInteger i = 0; i < [_CellData count]; i ++) {
            if ([[[_CellData objectAtIndex:i] objectForKey:@"permission"] integerValue] == 1) {
                numOfOnes ++;
            }
        }
        return numOfOnes;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return NSLocalizedString(@"new permission", nil);
            break;
        case 1:
            return @"";
            break;
        case 2:
            if ([_CellData count]!= 0) {
                return [NSString stringWithFormat:@"%zi Permitted", [_CellData count]];
            }
        default:
            return @"";
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        return 50;
    } else {
        return 44;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return NSLocalizedString(@"Select to delete permitted contact(s)", nil);
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    //创建CELL
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PermissionCell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (cell == nil) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PermissionCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    
    //CELL的主体
    switch (section) {
        case 0:
            //首次进入，创建一个输入框
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            if (firstTime) {
                textFiled = [[UITextField alloc] initWithFrame:CGRectMake(cell.frame.origin.x+16, cell.frame.origin.y + 1, cell.frame.size.width - 16, cell.frame.size.height)];
                [textFiled setPlaceholder:@"Email"];
                textFiled.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
                textFiled.clearsContextBeforeDrawing = YES;  //把周围的context清理，否则可能会出错
                textFiled.clearButtonMode = 5;
                textFiled.autocorrectionType = NO;
                textFiled.returnKeyType = UIReturnKeyJoin;
                textFiled.keyboardType = UIKeyboardTypeEmailAddress;
                [textFiled setValue:[UIFont systemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
                textFiled.font = [UIFont systemFontOfSize:14];
                textFiled.delegate = self;  //非常重要
                
                firstTime = NO; //创建完毕，以后不用再进来了
                [cell addSubview:textFiled];
            }
            break;
        //select from
        case 1:
            if (row == 0) {
                cell.textLabel.text = NSLocalizedString(@"Add from phone address book",nil);
            } else {
                cell.textLabel.text = NSLocalizedString(@"Add from uSav contact list",nil);
            }
            break;
        //permission List
        case 2:
            cell.userInteractionEnabled = YES;
            cell.textLabel.text = [[_CellData objectAtIndex:indexPath.row] objectForKey:@"name"];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            cell.backgroundColor = [UIColor whiteColor];
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            if ([_editingPemissionList containsObject:indexPath]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            break;
        //编辑List按钮
        case 3:
            cell.textLabel.text = NSLocalizedString(@"Delete From List", nil);
            cell.textLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
            cell.accessoryType = UITableViewCellAccessoryNone;
            if ([_editingPemissionList count] > 0) {
                cell.backgroundColor = [ColorFromHex getColorFromHex:@"#E8251E"];
                cell.userInteractionEnabled = YES;
            } else {
                cell.backgroundColor = [ColorFromHex getColorFromHex:@"#929292"];
                cell.userInteractionEnabled = NO;
            }
            break;
        //完成
        default:
            cell.textLabel.text = NSLocalizedString(@"Done", nil);
            cell.backgroundColor = [ColorFromHex getColorFromHex:@"#1E90FF"];
            cell.textLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
    }
    return cell;
}


#pragma mark 选中方法(delegate)
//属于delegate，不用写在datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    //调用这个方法来获得被选中的实例
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    switch (section) {
        //select from
        case 1:
            if (row == 0) {
                [self performSegueWithIdentifier:@"SelectFromAddressBookSegue" sender:self];
            } else if (row == 1) {
                [self performSegueWithIdentifier:@"SelectFromUsavContactSegue" sender:self];
            }
            break;
        //Permission List
        //select row with check mark
        case 2:
            if ([_editingPemissionList containsObject:indexPath]){
                [_editingPemissionList removeObject:indexPath];
            } else {
                [_editingPemissionList addObject:indexPath];    //表示这行已经被选中了
            }
            
            [self.tableView reloadData];
            break;
        case 3:
            //发送Edit请求, 删除
            for (NSInteger i = 0; i < [_editingPemissionList count]; i ++) {
                //先取出来
                NSDictionary *deleteContactDic = [_CellData objectAtIndex:[[_editingPemissionList objectAtIndex:i] row]];
                //从CellData里删除相应的项
                [_CellData removeObjectAtIndex:[[_editingPemissionList objectAtIndex:i] row]];
                //修改Permission标志为删除, 这里新建了一个临时变量
                NSDictionary *newDeleteContactDic = [[NSDictionary alloc] initWithObjectsAndKeys: @"0", @"permission", [deleteContactDic objectForKey:@"name"], @"name", [deleteContactDic objectForKey:@"isUser"], @"isUser", nil];
                //加在最顶上
                [_CellData insertObject:newDeleteContactDic atIndex:0];
            }
            [self.tableView reloadData];
            [_editingPemissionList removeAllObjects];
            //break; 这里不break，直接更新
        default: {
            //发送Edit请求, 最新的List都是在_CellData --- 最终
            
            //如果与之前相同，则不更新
            if ([_CellData isEqualToArray:_previousCellData]) {
                NSLog(@"本次不需要更新");
                [self.navigationController popToRootViewControllerAnimated:YES];
                break;
            } else {
                NSLog(@"最终需要更新的CellData: %@", _CellData);
                
                NSMutableArray *groupArray = [[NSMutableArray alloc] initWithCapacity:0];
                NSMutableArray *contactArray = [[NSMutableArray alloc] initWithCapacity:0];
                for (NSInteger i = 0; i < [_CellData count]; i ++) {
                    if ([[[_CellData objectAtIndex:i] objectForKey:@"isUser"] integerValue] == 0) {
                        //是分组
                        [groupArray addObject:[_CellData objectAtIndex:i]];
                    } else {
                        [contactArray addObject:[_CellData objectAtIndex:i]];
                    }
                }
                //注意，这里的Array是个字典，包括了name，isUser和Permission，最后一个用来表示增加还是删除，API需要
                [self setContactPermissionForKey:_segueTransKeyId group:groupArray andFriends:contactArray];
            }

            
            break;
        }
    }
    
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark 滑动隐藏键盘
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [textFiled resignFirstResponder];
}

#pragma mark 点击return键添加用户
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([self isValidEmail:textFiled.text]) {
        //封装为字典，类型为添加
        NSDictionary *newContactDic = [[NSDictionary alloc] initWithObjectsAndKeys: @"1", @"permission", textField.text, @"name", @"1", @"isUser", nil];
        [_CellData addObject:newContactDic];
        firstTime = NO;
        textFiled.text = @"";   //清空方便下次输入
        [self.tableView reloadData];
        
    } else {
        [self showAlert:@"Invalid Email Address" andContent:nil];
    }
    
    
    return YES;
}

#pragma mark Email有效性判断
- (BOOL)isValidEmail: (NSString *) email
{
    if ([email length] < 5 || [email length] > 100) {
        return false;
    }
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:email options:0 range:NSMakeRange(0, [email length])];
    
    
    if (rangeOfFirstMatch.location == NSNotFound || rangeOfFirstMatch.length != [email length]) {
        return false;
    }
    return true;
}

#pragma mark - Prepare for segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"SelectFromAddressBookSegue"]) {
        THContactPickerViewController *addressBookController = segue.destinationViewController;
        addressBookController.passDelegate = self;
        
    } else if ([segue.identifier isEqualToString:@"SelectFromUsavContactSegue"]) {
        
    }
    
}

#pragma mark - 实现传参Delegate
- (void)passValue:(NSArray *)value {
    
    //将选择好的添加到CellData
    [_addPermissionList addObjectsFromArray:value];
    
    //对每一个选择的循环
    for (NSInteger i = 0; i < [_addPermissionList count]; i ++) {
        
        BOOL isExists = NO;
        
        THContact *contactToBeAdd = [_addPermissionList objectAtIndex:i];
        
        //封装为字典，类型为添加
        NSDictionary *addPermissionDic = [[NSDictionary alloc] initWithObjectsAndKeys: @"1", @"permission", contactToBeAdd.email, @"name", @"1", @"isUser", nil];
        //检查现有的循环,不存在，才加入，避免重复
        for (NSInteger i = 0 ; i < [_CellData count]; i ++) {
            if ([[[_CellData objectAtIndex:i] objectForKey:@"name"] isEqualToString:contactToBeAdd.email]) {
                isExists = YES;
                break;
            } else {
                isExists = NO;
            }
        }
        
        //一次循环结束，如果没有相同的，则加入cellData
        if (!isExists) {
            [_CellData addObject:addPermissionDic];
        }
    }
    
    //这里弹出来之前，在那边做了判断，如果是本类作为delegate，则提前停止动画，免得出现不可以交互的情况
    [self.navigationController popToViewController:self animated:YES];
    [self.tableView reloadData];
    
}


#pragma mark - 获取permissionList
- (void)getPermissionList:(NSString *)keyId
{
    USAVClient *client = [USAVClient current];
    NSString * subParameters = [NSString stringWithFormat:@"%@", keyId];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n",
                              subParameters, @"\n"];
    
    //NSLog(@"stringToSign: %@", stringToSign);
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    //NSLog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"keyId" stringValue:_segueTransKeyId];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    ////NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [self showLoadingAlertAt:self.view.window.subviews[0]];
    [client.api listFriendListPermision:encodedGetParam target:(id)self selector:@selector(getPermissionListCallBack:)];
}

#pragma mark 获取permissionList CallBack
- (void)getPermissionListCallBack:(NSDictionary*)obj
{
    
    if ((obj != nil) && ([[obj objectForKey:@"statusCode"] integerValue] == 0)) {
        NSArray *permissionList = [obj objectForKey:@"permissionList"];
        if (!permissionList)
        {
            return;
        }
        
        NSMutableArray *permissionForGroups = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *permissionForFriends = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < [permissionList count]; i++) {
            
            NSDictionary *unit = [permissionList objectAtIndex:i];
            
            if ([[unit objectForKey:@"permission"] integerValue] == 1) {
                if ([[unit objectForKey:@"isUser"] integerValue]== 0) {
                    //如果是分组，则将这个分组的所有信息放到数组中
                    [permissionForGroups addObject:unit];

                } else {
                    //如果是普通Contact，则将这个Contact放进另外一个数组中
                    [permissionForFriends addObject:unit];
                    
                }
            }
        }
        
        
        //方便显示，_CellData放的是Unit
        [_CellData addObjectsFromArray:permissionForGroups];
        [_CellData addObjectsFromArray:permissionForFriends];
        //将现有的list存放在下面的数组中，最后提交的时候与其进行判断，来确定是否需要更改
        _previousCellData = [[NSMutableArray alloc] initWithArray:_CellData];
        firstTime = NO; //这里刷新过一次table了，firstTime为NO，否则textField会被新的覆盖
        [self.tableView reloadData];
        
    }
    else {
        NSLog(@"%@", obj);
        [_loadingAlert stopAnimating];
        [self showAlert:@"Failed To Get Permission List" andContent:nil];
    }
    
    [_loadingAlert stopAnimating];
}

#pragma mark - set Pemission
-(void)setContactPermissionForKey:(NSString *)kid group: (NSArray *)group andFriends: (NSArray *)friend {
    //NSData *keyId = [[UsavFileHeader defaultHeader] getKeyIDFromFile:self.currentFullPath];
    //NSString *keyIdString = [keyId base64EncodedString];
    //NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", //keyIdString, @"\n"];
    
    GDataXMLElement * post= [GDataXMLNode elementWithName:@"params"];
    GDataXMLElement * keyId = [GDataXMLNode elementWithName:@"keyId" stringValue:kid];
    [post addChild:keyId];
    
    for (id g in group) {
        GDataXMLElement * groupP = [GDataXMLNode elementWithName:@"GroupPermission"];
        NSString *gName = (NSString*)[g objectForKey:@"name"];
    
        GDataXMLElement * contact = [GDataXMLNode elementWithName:@"Contact" stringValue:gName];
        //用来对permission格式进行转换
        NSString * permissionString;
        if (![[g objectForKey:@"permission"] isMemberOfClass:[NSString class]]) {
            permissionString = [NSString stringWithFormat:@"%@", [g objectForKey:@"permission"]];
        } else {
            permissionString = [g objectForKey:@"permission"];
        }
        GDataXMLElement * permission = [GDataXMLNode elementWithName:@"Permission" stringValue:permissionString];
        
        [groupP addChild:contact];
        [groupP addChild:permission];
        [post addChild: groupP];
    }
    
    for (id f in friend) {
        GDataXMLElement * groupP = [GDataXMLNode elementWithName:@"FriendPermission"];
        GDataXMLElement * contact = [GDataXMLNode elementWithName:@"Contact" stringValue:[f objectForKey:@"name"]];
        //用来对permission格式进行转换
        NSString * permissionString;
        if (![[f objectForKey:@"permission"] isMemberOfClass:[NSString class]]) {
            permissionString = [NSString stringWithFormat:@"%@", [f objectForKey:@"permission"]];
        } else {
            permissionString = [f objectForKey:@"permission"];
        }
        GDataXMLElement * permission = [GDataXMLNode elementWithName:@"Permission" stringValue:permissionString];
        
        [groupP addChild:contact];
        [groupP addChild:permission];
        [post addChild: groupP];
    }
    
    NSString *md5 = [self md5:[post XMLString]];
    
    NSData *bits_128 = [self CreateDataWithHexString:md5];
    md5 = [bits_128 base64EncodedString];
    
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", md5, @"\n"];
    
    ////NSLog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    ////NSLog(@"signature: %@", signature);
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"content-md5" stringValue:md5];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    paramElement = [GDataXMLNode elementWithName:@"lang" stringValue:NSLocalizedString(@"LanguageCode", @"")];
    [requestElement addChild:paramElement];
    
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    [self showLoadingAlertAt:self.view.window.subviews[0]];
    [client.api setcontactlistpermission:encodedGetParam P:[[post XMLString]  dataUsingEncoding:NSUTF8StringEncoding] target:(id)self selector:@selector(setPermissionCallBack:)];
    
}

#pragma mark set permission call back
- (void)setPermissionCallBack:(NSDictionary*)obj
{
    if (obj == nil) {
        [_loadingAlert stopAnimating];
        [self showAlert:@"Failed To Set Permission" andContent:nil];
        return;
    }
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        [_loadingAlert stopAnimating];
        [self showAlert:@"Time Error" andContent:@"Please check your system time"];
        return;
    }
    
    NSInteger result = [[obj objectForKey:@"rawStringStatus"] integerValue];
    
    if ((obj != nil && result == 0) || result == 2305) {
        
        [_loadingAlert stopAnimating];
        [self showAlert:@"Succeed" andContent:nil];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    } else {
        [_loadingAlert stopAnimating];
        [self showAlert:@"Failed To Set Permission" andContent:nil];
        return;
    }
    
}


#pragma mark md5
- (NSString *)md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}

#pragma mark 16进制转data
- (NSData *)CreateDataWithHexString:(NSString *)inputString
{
    NSUInteger inLength = [inputString length];
    
    unichar *inCharacters = alloca(sizeof(unichar) * inLength);
    [inputString getCharacters:inCharacters range:NSMakeRange(0, inLength)];
    
    UInt8 *outBytes = malloc(sizeof(UInt8) * ((inLength / 2) + 1));
    
    NSInteger i, o = 0;
    UInt8 outByte = 0;
    for (i = 0; i < inLength; i++) {
        UInt8 c = inCharacters[i];
        SInt8 value = -1;
        
        if      (c >= '0' && c <= '9') value =      (c - '0');
        else if (c >= 'A' && c <= 'F') value = 10 + (c - 'A');
        else if (c >= 'a' && c <= 'f') value = 10 + (c - 'a');
        
        if (value >= 0) {
            if (i % 2 == 1) {
                outBytes[o++] = (outByte << 4) | value;
                outByte = 0;
            } else {
                outByte = value;
            }
            
        } else {
            if (o != 0) break;
        }
    }
    
    return [[NSData alloc] initWithBytesNoCopy:outBytes length:o freeWhenDone:YES];
}






#pragma mark - 计时隐藏alert
- (void)showAlert: (NSString *)alertTitle andContent: (NSString *)alertContent {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(alertTitle, nil) message:NSLocalizedString(alertContent, nil) delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerForHideAlert:) userInfo:alert repeats:NO];
    //这个userInfo可以将这个函数里的某个参数，装进timer中，传递给别的函数
    [alert show];
    
}
- (void)timerForHideAlert: (NSTimer *)timer {
    UIAlertView *alert = [timer userInfo];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark loading进度条
- (void)showLoadingAlertAt:(UIView *)view {
    if (_loadingAlert.isAnimating) {
        [_loadingAlert stopAnimating];
        return;
    } else {
        _loadingAlert = [[TYDotIndicatorView alloc] initWithFrame:CGRectMake(30, 260, 260, 50) dotStyle:TYDotIndicatorViewStyleRound dotColor:[UIColor colorWithRed:0.85f green:0.86f blue:0.88f alpha:1.00f] dotSize:CGSizeMake(15, 15) withBackground:YES];
        _loadingAlert.backgroundColor = [UIColor colorWithRed:0.20f green:0.27f blue:0.36f alpha:0.9f];
        _loadingAlert.layer.cornerRadius = 5.0f;
        [view addSubview:_loadingAlert];
        [_loadingAlert startAnimating];
    }
    
}
@end
