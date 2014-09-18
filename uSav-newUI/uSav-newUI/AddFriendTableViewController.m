//
//  AddFriendTableViewController.m
//  uSav-newUI
//
//  Created by Luca on 8/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "AddFriendTableViewController.h"

@interface AddFriendTableViewController () {

    InitiateWithData *dataInitiator;
}

@end

@implementation AddFriendTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    dataInitiator = [[InitiateWithData alloc] init];
    dataInitiator.addFriendCaller = self;
    
    _addFriendList = [[NSMutableArray alloc] initWithCapacity:0];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    tableView.scrollEnabled = YES;
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 0) {
        return 3;
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section) {
        return @"";
    } else {
        return @"User ID";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return NSLocalizedString(@"\"Sync from address book\" will synchronize all contacts from your address book, and uSav will never gather any information from your contacts.", nil);
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    AddFirendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddFriendCell"];
    if (cell == nil) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddFriendCell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    switch (section) {
        case 0:
            if (row == 0) {
                //创建一个输入框
                _textFiled = [[UITextField alloc] initWithFrame:CGRectMake(cell.frame.origin.x+16, cell.frame.origin.y + 1, cell.frame.size.width - 16, cell.frame.size.height)];
                [_textFiled setPlaceholder:@"Email"];
                _textFiled.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
                _textFiled.clearsContextBeforeDrawing = YES;  //把周围的context清理，否则可能会出错
                _textFiled.clearButtonMode = 5;
                _textFiled.autocorrectionType = NO;
                _textFiled.returnKeyType = UIReturnKeyGo;
                _textFiled.keyboardType = UIKeyboardTypeEmailAddress;
                [_textFiled setValue:[UIFont systemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
                _textFiled.font = [UIFont systemFontOfSize:14];
                _textFiled.delegate = self; //不是简单在前面声明textField Delegate就行了，记得将每个TextFeild的Delegate绑定好
//#pragma mark for test
//                _textFiled.text = @"Himst.lee@nwstor.com";
                
                cell.TableOption = nil;
                [cell addSubview:_textFiled];
                [_textFiled becomeFirstResponder];
                
            } else if (row == 1){
                cell.TableOption.text = NSLocalizedString(@"Add from address book", nil);
                cell.TableOption.font = [UIFont boldSystemFontOfSize:14];
                cell.TableImage.image = [UIImage imageNamed:@"Address@2x.png"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else {
                cell.TableOption.text = NSLocalizedString(@"Sync from address book", nil);
                cell.TableOption.font = [UIFont boldSystemFontOfSize:14];
                cell.TableImage.image = [UIImage imageNamed:@"SyncAddress@2x.png"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            break;
        default:
            cell.TableOption.text = NSLocalizedString(@"Creat a group", nil);
            cell.TableOption.font = [UIFont boldSystemFontOfSize:14];
            cell.TableImage.image = [UIImage imageNamed:@"CreatGroup@2x.png"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
    }
    
    return cell;
}

#pragma mark 选中方法(delegate)
//属于delegate，不用写在datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 0 && row == 1) {
        [self performSegueWithIdentifier:@"AddressBookSegue" sender:self];
    } else if (section == 1 && row == 0) {
        UIAlertView *comingSoon = [[UIAlertView alloc] initWithTitle:@"uSav" message:@"Coming soon!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [comingSoon show];
    } else {
        UIAlertView *comingSoon = [[UIAlertView alloc] initWithTitle:@"uSav" message:@"Coming soon!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [comingSoon show];
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark 滑动隐藏键盘
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_textFiled resignFirstResponder];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Prepare

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    //这里获取到下一个controller，把delegate指定好
    THContactPickerViewController *pickerController = segue.destinationViewController;
    pickerController.passDelegate = self;
}

#pragma mark - 协议方法
#pragma mark delegate传值接收
- (void)passValue:(NSArray *)value {

    [_addFriendList addObjectsFromArray:value]; //最初的都是THContact类型
    
    //现在由于API限制，只能一个一个添加，每一个用户都要call API
    for (NSInteger i = 0; i < [_addFriendList count]; i ++) {
        THContact *contactToBeAdd = _addFriendList[i];
        [dataInitiator initiateDataForAddContact: contactToBeAdd.email];
    }
    
    //[self.navigationController popViewControllerAnimated:YES];
    
    
//    NSString *stringToDisplay = [NSString stringWithFormat:@"Got %zi contacts, First one is %@", [_addFriendList count], firstContact.email];
    
//    _textFiled.text = stringToDisplay;

}

#pragma mark -
#pragma mark 读取输入的Email值，callAPI
//点击键盘的Go按钮
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [dataInitiator initiateDataForAddContact:textField.text];
    return YES;
}

#pragma mark - 计时隐藏alert
- (void)showAlert: (NSString *)alertTitle andContent: (NSString *)alertContent {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(alertTitle, nil) message:NSLocalizedString(alertContent, nil) delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timerForHideAlert:) userInfo:alert repeats:NO];
    //这个userInfo可以将这个函数里的某个参数，装进timer中，传递给别的函数
    [alert show];
}
- (void)timerForHideAlert: (NSTimer *)timer {
    UIAlertView *alert = [timer userInfo];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

@end
