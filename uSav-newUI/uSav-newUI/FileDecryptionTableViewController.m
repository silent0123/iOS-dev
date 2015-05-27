//
//  FileDecryptionTableViewController.m
//  uSav-newUI
//
//  Created by Luca on 7/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "FileDecryptionTableViewController.h"

@interface FileDecryptionTableViewController (){
    
}

@end

@implementation FileDecryptionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark FileTable操作相关
//------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    //NSLog(@"数据已经初始化，获取section的数目为2");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    return [_CellData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"进入Cell创建");
    //创建CELL
    FileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileCell"];
    
#pragma warning 这里需要之后修改
    
    //创建数据对象，用之前定义了的_CellData初始化
    NSDictionary *cellData = _CellData[indexPath.row];
    
    //cell.TableImage.image = nil;
    cell.FileName.text = [NSString stringWithFormat:@"%@", [cellData objectForKey:@"Filename"]]; //人工usav结尾
    cell.FileName.font = [UIFont boldSystemFontOfSize:14];
    
    cell.Bytes.text = [NSString stringWithFormat:@"%d KBytes", ([[cellData objectForKey:@"NSFileSize"] integerValue]/1024)];
    cell.Bytes.font = [UIFont systemFontOfSize:10];
    cell.Bytes.textColor = [ColorFromHex getColorFromHex:@"#929292"];
    //先设置时间格式
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy hh:mm:ss"];
    NSString *dateString = [dateFormat stringFromDate:[cellData objectForKey:@"NSFileModificationDate"]];
    cell.ReceiveTime.text = dateString;
    

    [self compareExtension:cell withDictionary:cellData];
    
    //高亮状态
    //cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    //cell.selectedBackgroundView.backgroundColor = [ColorFromHex getColorFromHex:@"#E4E4E4"];
    // Configure the cell...

    return cell;
}

//cell编辑/删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 有数据才可以编辑，没有就不可以
    if ([_CellData count] > 0) {
        return YES;//可以编辑
    } else {
        return NO;
    }
}
// 删除行，是datasource方法
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        //从document目录删除文件
        NSArray *PathsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [PathsArray objectAtIndex:0];  //搜索到的是数组，这里得取第0个出来，才是path
        NSString *deleteFilePath = [NSString stringWithFormat:@"%@/%@/%@", documentPath, @"Decrypted", [_CellData[indexPath.row] objectForKey:@"Filename"]];
        //NSString *decryptedFilePath = [NSString stringWithFormat:@"%@/%@", documentPath, @"Decrypted"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:deleteFilePath error:nil];

        [_CellData removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        NSLog(@"现在的第%zi行已经被移除, 还剩下%zi",indexPath.row,[_CellData count]);
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (NSString *)compareExtension: (FileTableViewCell *)cell withDictionary: (NSDictionary *)cellData {
    
    NSString *fileExtension = [[cellData objectForKey:@"FilePath"] pathExtension];
    
    //Image不用在数据类中加，直接在这里加，注意，caseInsensitive的对比，0为符合
    if (![fileExtension caseInsensitiveCompare:@"doc"] || ![fileExtension caseInsensitiveCompare:@"docx"]) {
        cell.TableColor.backgroundColor = [ColorFromHex getColorFromHex:@"#44BBC1"];
        cell.TableImage.image = [UIImage imageNamed:@"Word@2x.png"];
        return @"#44BBC1";
    } else if (![fileExtension caseInsensitiveCompare:@"ppt"] || ![fileExtension caseInsensitiveCompare:@"pptx"]) {
        cell.TableColor.backgroundColor = [ColorFromHex getColorFromHex:@"#ED6F00"];
        cell.TableImage.image = [UIImage imageNamed:@"Powerpoint@2x.png"];
        return @"#ED6F00";
    } else if (![fileExtension caseInsensitiveCompare:@"xls"] || ![fileExtension caseInsensitiveCompare:@"xlsx"]) {
        cell.TableColor.backgroundColor = [ColorFromHex getColorFromHex:@"#A0BD2B"];
        cell.TableImage.image = [UIImage imageNamed:@"Excel@2x.png"];
        return @"#A0BD2B";
    } else if (![fileExtension caseInsensitiveCompare:@"jpeg"] || ![fileExtension caseInsensitiveCompare:@"png"] || ![fileExtension caseInsensitiveCompare:@"jpg"] ||![fileExtension caseInsensitiveCompare:@"gif"] || ![fileExtension caseInsensitiveCompare:@"mov"] || ![fileExtension caseInsensitiveCompare:@"mp4"] || ![fileExtension caseInsensitiveCompare:@"3gp"] || ![fileExtension caseInsensitiveCompare:@"rmvb"] || ![fileExtension caseInsensitiveCompare:@"avc"] || ![fileExtension caseInsensitiveCompare:@"avi"] || ![fileExtension caseInsensitiveCompare:@"mpeg-4"] || ![fileExtension caseInsensitiveCompare:@"mp3"] || ![fileExtension caseInsensitiveCompare:@"aac"] || ![fileExtension caseInsensitiveCompare:@"amr"] || ![fileExtension caseInsensitiveCompare:@"wav"] || ![fileExtension caseInsensitiveCompare:@"mid"]) {
        //这里是支持的多媒体格式，前面是图片，后面是视频
        cell.TableColor.backgroundColor = [ColorFromHex getColorFromHex:@"#D6006F"];
        cell.TableImage.image = [UIImage imageNamed:@"Multimedia@2x.png"];
        return @"#D6006F";
    } else if (![fileExtension isEqualToString:@"pdf"]){
        cell.TableColor.backgroundColor = [ColorFromHex getColorFromHex:@"#E8251E"];
        cell.TableImage.image = [UIImage imageNamed:@"Pdf@2x.png"];
        return @"#E8251E";
    } else {
        cell.TableImage.image = [UIImage imageNamed:@"Others@2x.png"];
    }
    return @"Others";
}

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
