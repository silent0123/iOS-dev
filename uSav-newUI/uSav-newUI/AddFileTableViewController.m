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
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 0) {
        //NSLog(@"section为0号，返回2");
        return 2;
    } else {
        //NSLog(@"section为1号，返回%zi", [_CellData count]);
        return [_CellData count];
    }
}

//设置Section Title
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"Recent Files";
    } else {
        return @"";
    }

}

//设置行高，我们的section0和1要不同
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if (section) {
        return 46;
    } else {
        return 54;
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
                cell.FileImage = nil; //暂时
                cell.FileName.font = [UIFont boldSystemFontOfSize:15];
                if (row == 0) {
                    cell.FileName.text = @"Take a Photo";
                    [cell setSeparatorInset:UIEdgeInsetsZero];
                } else {
                    cell.FileName.text = @"Select in Album";
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
                    cell.FileImage.image = [UIImage imageNamed:@"Mutimedia@2x.png"];
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
    
    NSLog(@"%@",info);
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"]) {
        //先把图片转换为NSData
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        NSData *imageData;
        if (UIImagePNGRepresentation(image) == nil) {
            imageData = UIImageJPEGRepresentation(image, 1.0);
        } else {
            imageData = UIImagePNGRepresentation(image);
        }
        
        //图片的保存路径
        //这里的图片放在沙盒的documents文件夹中
        NSString *documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        
        //文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        //把刚才转换成的imageData放入沙盒中
        [fileManager createDirectoryAtPath:documentPath withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createFileAtPath:[documentPath stringByAppendingPathComponent:@"/image.png"] contents:imageData attributes:nil];//注意，这里的文件名是唯一的，可能会产生覆盖效果，以后会用相应的文件名来代替
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil); //顺便存入相册, 这里还有一个BUG, 无论什么来源的照片他都会存到相册，不管是照的还是从相册里选的
        
        //得到沙盒中的完整文件路径
        NSString *filePath = [[NSString alloc] initWithFormat:@"%@%@", documentPath, @"/image.png"];
        NSLog(@"file selected & store at %@", filePath);
        //关闭相册界面
        [picker dismissViewControllerAnimated:YES completion:nil];
    }

}

//照片选择取消
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    //NSLog(@"selected canceled");
    [picker dismissViewControllerAnimated:YES completion:nil];
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
