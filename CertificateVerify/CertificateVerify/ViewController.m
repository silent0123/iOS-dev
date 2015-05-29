//
//  ViewController.m
//  CertificateVerify
//
//  Created by Luca on 28/5/15.
//  Copyright (c) 2015年 Luca. All rights reserved.
//

#import "ViewController.h"
#import "CertificateVerifyLib.h"

@interface ViewController ()

//result view
@property (weak, nonatomic) IBOutlet UIView *resultView;
@property (weak, nonatomic) IBOutlet UILabel *identityLabel;
@property (weak, nonatomic) IBOutlet UILabel *trustLabel;

//big result
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

- (IBAction)verifyBtnPressed:(id)sender;
- (IBAction)moreInfoBtnPressed:(id)sender;


@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.resultView setAlpha:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (IBAction)verifyBtnPressed:(id)sender {
    
    CertificateVerifyLib *certVerifyLibInstance = [[CertificateVerifyLib alloc] init];
    NSString *certificateFilename = @"server.p12";
    
    //copy certificate file from bundle to document
    [self loadCertFile:[certificateFilename stringByDeletingPathExtension] extension:[certificateFilename pathExtension] fromBundle:[NSBundle mainBundle]];
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory =[paths objectAtIndex:0];
    
    //we can use this to load certificate from a particular URL
    NSString *pathOfCertificateInDocuments = [documentsDirectory stringByAppendingPathComponent:certificateFilename];
    NSData *certData = [certVerifyLibInstance loadPKCS12CertificateDataFromURL: [NSURL fileURLWithPath:pathOfCertificateInDocuments]];
    
    if (certData == nil) {
        self.resultLabel.text = @"Failed";
        self.resultLabel.textColor = [UIColor colorWithRed:232.0/255.0 green:37.0/255.0 blue:30.0/255.0 alpha:1];
        NSLog(@"Failed to load certificate data from URL:%@", [NSURL fileURLWithPath:pathOfCertificateInDocuments]);
    }
    //get items (identity & trust) from certificate
    SecIdentityRef identity = NULL;
    SecTrustRef trust = NULL;
    BOOL isSuccessful = [CertificateVerifyLib getIndentity:&identity andTrust:&trust fromPKCS12Data:certData withPassword:CFSTR("subserverpassword")];
    
    
    if (isSuccessful) {
        
        self.resultLabel.text = @"Successful";
        self.resultLabel.textColor = [UIColor colorWithRed:160.0/255.0 green:189.0/255.0 blue:43.0/255.0 alpha:1];
        
        //display content to detail text field
        self.identityLabel.text = [NSString stringWithFormat:@"Identity Pointer: \n%@", identity];
        self.trustLabel.text = [NSString stringWithFormat:@"CA(trust) Pointer: \n%@", trust];
        NSLog(@"=== SUCCESSFUL:%@,%@", identity, trust);
        [self moreInfoBtnPressed:nil];
        
    } else {
        self.resultLabel.text = @"Failed";
        self.resultLabel.textColor = [UIColor colorWithRed:232.0/255.0 green:37.0/255.0 blue:30.0/255.0 alpha:1];
        
        self.identityLabel.text = [NSString stringWithFormat:@"Load identity failed"];
        self.trustLabel.text = [NSString stringWithFormat:@"Load CA failed"];
        
    }
}

- (IBAction)moreInfoBtnPressed:(id)sender {
    
    if ([self.resultView alpha] == 1) {
        [UIView animateWithDuration:0.8f animations:^(void){
        [self.resultView setAlpha:0];
        }];
    } else {
        [UIView animateWithDuration:0.8f animations:^(void){
        [self.resultView setAlpha:1];
        }];
    }
}

//load certificate file to DocumentPath
- (void)loadCertFile: (NSString *)certFileName extension: (NSString *)ext fromBundle: (NSBundle *)bundle {

    NSFileManager *fileManager =[NSFileManager defaultManager];
    NSError *error;
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory =[paths objectAtIndex:0];
    
    NSString *documentCertPath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", certFileName, ext]];
    
    if([fileManager fileExistsAtPath:documentCertPath]== NO){
        
        NSString*resourcePath =[[NSBundle mainBundle] pathForResource:certFileName ofType:ext];
        [fileManager copyItemAtPath:resourcePath toPath:documentCertPath error:&error];
        
        NSLog(@"Ceritificate has been loaded to %@", documentCertPath);
        
    } else {
        NSLog(@"Ceritificate %@ exists", documentCertPath);
    }
    
}
@end
