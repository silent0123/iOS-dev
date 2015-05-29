//
//  SecondViewController.m
//  CertificateVerify
//
//  Created by Luca on 28/5/15.
//  Copyright (c) 2015 Luca. All rights reserved.
//

#import "SecondViewController.h"
#import "CertificateVerifyLib.h"

@interface SecondViewController ()
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIButton *verifyBtn;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (strong, nonatomic) UITextView *logTextView;

- (IBAction)urlTextFieldDidBeginEditting:(id)sender;

- (IBAction)verifyBtnPressed:(id)sender;
- (IBAction)returnBtnPressed:(id)sender;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.urlTextField.text = @"https://ibsbjstar.ccb.com.cn/app/V5/CN/STY6/login_pbc.jsp";
    self.resultLabel.text = @"Sister 4";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)urlTextFieldDidBeginEditting:(id)sender {
    
    [self.urlTextField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.urlTextField resignFirstResponder];
    return YES;
}

- (IBAction)verifyBtnPressed:(id)sender {
    
    [self verifyConnection];
    
}

- (IBAction)returnBtnPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)closeBtnPressed:(id)sender {
    
    self.resultLabel.text = @"Sister 4";
    [self.logTextView removeFromSuperview];
}

- (void)verifyConnection {
    
    NSURLRequest *urlReq = [NSURLRequest requestWithURL:[NSURL URLWithString:[self.urlTextField text]]];
    NSURLConnection *urlConnection = [NSURLConnection connectionWithRequest:urlReq delegate:self];
    //NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:[self.urlTextField text] port:8443 protocol:@"https" realm:nil authenticationMethod:nil];

    if (urlConnection) {
        self.resultLabel.text = @"Waiting";
        NSLog(@"Connection successful!");
        
    } else {
        self.resultLabel.text = @"C Failed";
        NSLog(@"Connection failed!");
    }
}

#pragma mark - download delegate

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"data received from: %@, byte: %zi", [connection.currentRequest URL], [data length]);
}

#pragma mark - data delegate
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    
    //if server is CCB
    /*
     Host:ibsbjstar.ccb.com.cn, Server:https, Auth-Scheme:NSURLAuthenticationMethodServerTrust, Realm:(null), Port:443, Proxy:NO, Proxy-Type:(null)
     */
    
    NSLog(@"Protection space:%@", protectionSpace);
    NSLog(@"is server trusted: %zi", [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]);
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    //inital the log display view by using code
    self.logTextView = [[UITextView alloc] initWithFrame:self.view.frame];
    self.logTextView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    self.logTextView.textColor = [UIColor whiteColor];
    self.logTextView.font = [UIFont boldSystemFontOfSize:14];
    self.logTextView.contentInset = UIEdgeInsetsMake(30, 6, 0, 6);
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 36)];
    button.center = CGPointMake(self.view.center.x, self.view.frame.size.height - 100);
    button.backgroundColor = self.verifyBtn.backgroundColor;
    [button setTitle:@"Close" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.logTextView addSubview:button];
    [self.view addSubview:self.logTextView];
    NSString *stringOfLog = @"---- certificate analysis tool designed by luca ----\n";
    
    
    // ---- dealing with challenge
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        
        NSLog(@"This host \"%@\" is trusted.", challenge.protectionSpace.host);
        stringOfLog = [NSString stringWithFormat:@"this host \"%@\" is trusted.\n\n", challenge.protectionSpace.host];
        self.logTextView.text = stringOfLog;
        
        NSURLCredential* urlCredential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        [challenge.sender useCredential:urlCredential forAuthenticationChallenge:challenge];
        
        //Code to verify certificate info
        SecTrustRef trustRef = [[challenge protectionSpace] serverTrust];
        CFIndex count = SecTrustGetCertificateCount(trustRef);
        
        for (CFIndex i = 0; i < count; i++)
        {
            SecCertificateRef certRef = SecTrustGetCertificateAtIndex(trustRef, i);
            CFStringRef certSummary = SecCertificateCopySubjectSummary(certRef);
            CFDataRef certData = SecCertificateCopyData(certRef);
            NSLog(@"Certificate summary:%@", (__bridge NSString*) certSummary);
            NSLog(@"Certificate data size:%zi", [(__bridge NSData*) certData length]);
            
            stringOfLog = [stringOfLog stringByAppendingString:[NSString stringWithFormat:@"Certificate summary: %@\nCertificate data size: %zi \n\n", (__bridge NSString*) certSummary,((__bridge NSData*)certData).length]];
            self.logTextView.text = stringOfLog;
            
            
            CFRelease(certData);
        }
        
        
    }
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}


@end
