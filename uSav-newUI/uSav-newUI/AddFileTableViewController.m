//
//  AddFileTableViewController.m
//  uSav-newUI
//
//  Created by Luca on 8/8/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "AddFileTableViewController.h"

@interface AddFileTableViewController ()

@end

@implementation AddFileTableViewController

- (void)viewDidLoad {
    
    _CellData = [InitiateWithData initiateDataForAddFile];
    
    [super viewDidLoad];
    
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
    tableView.scrollEnabled = NO;
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 0) {
        //NSLog(@"section为0号，返回2");
        return 2;
    } else {
        //NSLog(@"section为1号，返回%zi", [_CellData count]);
        //return [_CellData count];
        //返回有限个
        return 5;
    }
}

//设置Section Title
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"5 Recent Files";
    } else {
        return @"";
    }

}

//设置行高，我们的section0和1要不同
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if (section) {
        return 48;
    } else {
        return 58;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.tableView) {
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        //创建CELL
        AddFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddFileCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        FileDataBase *cellData = _CellData[indexPath.row];

        
        if (cell == nil) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddFileCell"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        //CELL的主体, 在里面分别设置两个section的样式
        switch (section) {
            case 0:
                //cell.FileImage = nil; //暂时
                cell.FileName.font = [UIFont boldSystemFontOfSize:15];
                if (row == 0) {
                    cell.FileName.text = @"Take a Photo";
                    [cell setSeparatorInset:UIEdgeInsetsZero];
                    cell.FileImage.image = [UIImage imageNamed:@"Photo@2x.png"];
                } else {
                    cell.FileName.text = @"Select from Album";
                    cell.FileImage.image = [UIImage imageNamed:@"Album@2x.png"];
                }
                break;
            default:
                //cell.FileImage = nil; //暂时
                cell.FileName.text = cellData.FileName;
                cell.FileName.font = [UIFont systemFontOfSize:14];
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                if ([cellData.TableColor  isEqual: @"#44BBC1"]) {
                    cell.FileImage.image = [UIImage imageNamed:@"Word@2x.png"];
                } else if ([cellData.TableColor  isEqual: @"#ED6F00"]) {
                    cell.FileImage.image = [UIImage imageNamed:@"Powerpoint@2x.png"];
                } else if ([cellData.TableColor  isEqual: @"#A0BD2B"]) {
                    cell.FileImage.image = [UIImage imageNamed:@"Excel@2x.png"];
                } else if ([cellData.TableColor  isEqual: @"#D6006F"]) {
                    cell.FileImage.image = [UIImage imageNamed:@"Multimedia@2x.png"];
                } else {
                    cell.FileImage.image = [UIImage imageNamed:@"Others@2x.png"];
                }
                break;
        }
        return cell;
    }
    return nil;
}

#pragma mark 选中方法(delegate)
//属于delegate，不用写在datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 0 && row == 0) {
        [self openCameraOrAlbum:0];
    } else if (section == 0 && row == 1){
        [self openCameraOrAlbum:1];
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark 打开照相机和相册
- (void)openCameraOrAlbum: (NSInteger)index {
    //打开照相机
    if (index == 0) {
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            //设置照片拍摄后可以被编辑
            picker.allowsEditing = YES;
            picker.sourceType = sourceType;
            [self presentViewController:picker animated:YES completion:nil];
        }
    } else if (index == 1){ //打开相册
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        //选择后可以编辑
        picker.allowsEditing = YES;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        NSLog(@"Open Error.");
    }

}

#pragma mark 照片选择后的操作
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    //NSLog(@"%@",info);  //这里得到的内容相当丰富
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"]) {
        //先把图片转换为NSData
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        NSData *imageData;
        if (UIImagePNGRepresentation(image) == nil) {
            imageData = UIImageJPEGRepresentation(image, 1.0);  //如果PNG无法压缩，就用JPEG压缩，压缩率为1(最小)
        } else {
            imageData = UIImagePNGRepresentation(image);
        }
        
        //图片的保存路径
        //从document目录读文件
        NSArray *PathsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [PathsArray objectAtIndex:0];  //搜索到的是数组，这里得取第0个出来，才是path
        
        //NSString *encryptedFilePath = [NSString stringWithFormat:@"%@/%@", documentPath, @"Encrypted"];
        NSString *decryptedFilePath = [NSString stringWithFormat:@"%@/%@", documentPath, @"Decrypted"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        //把刚才转换成的imageData放入沙盒的decrypted文件夹中，如果不存在则创建
        [fileManager createDirectoryAtPath:decryptedFilePath withIntermediateDirectories:YES attributes:nil error:nil];
        //以时间为文件名
        //先设置时间格式
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd-MM-yyyy hh:mm:ss"];
        NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
        NSString *dateAsFilename = [NSString stringWithFormat:@"/%@.png", dateString];
        [fileManager createFileAtPath:[decryptedFilePath stringByAppendingPathComponent:dateAsFilename] contents:imageData attributes:nil];
        
        if ([info objectForKey:UIImagePickerControllerMediaMetadata]) { //info里面有这行，如果是照的照片的话，根据上面的NSLog看出来的
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
        }   //如果是拍的照片，就存入相册；如果是相册里选的，就不保存（因为已经有了）
        
        //得到沙盒中的完整文件路径
        NSString *filePath = [decryptedFilePath stringByAppendingPathComponent:dateAsFilename];
        //NSLog(@"file selected & store at %@", filePath);
        //关闭相册界面
        [picker dismissViewControllerAnimated:YES completion:nil];
        
    }
    [_fileEncryptedTableViewController readDataFromInitateData];
    [self.navigationController popToRootViewControllerAnimated:YES];

}

//照片选择取消
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    //NSLog(@"selected canceled");
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
