//
//  ViewController.m
//  第一个天气软件
//
//  Created by Luca on 23/7/14.
//  Copyright (c) 2014年 Luca. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.weatherDisplay.numberOfLines = 0;
    [self.progressBar setProgress:0 animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ButtonOnClick:(id)sender {
    
    NSString *urlStr = @"http://m.weather.com.cn/data/101320101.html";
    NSURL *url = [[NSURL alloc] initWithString:urlStr];
    
#pragma mark 建立连接
    //初始化请求
    NSURLRequest *urlRequest = [[NSURLRequest alloc]
                                initWithURL: url
                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                timeoutInterval:30.0];
    
    //建立连接
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    if (urlConnection) {
        if (!_weatherData) {
            self.weatherData = [NSMutableData data];
        }
        else {
            self.weatherDisplay.text = [NSString stringWithFormat:@"Connection failed."];
        }
    }
    
    //当服务器提供了足够客户程序创建NSURLResponse对象的信息时，代理对象(self)会收到 -- 也就是说，收到这个信息，就说明数据开始下载
    //一个connection：didReceiveResponse：消息，在消息内可以检查NSURLResponse
    //对象和确定数据的预期长途，mime类型，文件名以及其他服务器提供的元信息
    
    //要注意，一个简单的连接也可能会收到多个connection：didReceiveResponse：消息
    //当服务器连接重置或者一些罕见的原因（比如多组mime文档），代理都会收到该消息
    //这时候应该重置进度指示，丢弃之前接收的数据
}

- (void)connection:connection didReceiveResponse: (NSURLResponse *)response {
    [self.weatherData setLength:0];
    [self.progressBar setProgress:0 animated:NO];
    //得到可能的最大长度
    _expectedLength = [response expectedContentLength];
}

- (void)connection: connection didReceiveData:(NSData *)data {
    [self.weatherData appendData:data];
    
    float progress = self.weatherData.length/_expectedLength;
    [self.progressBar setProgress:progress animated:YES];
}

- (void)connectionDidFinishLoading: (NSURLConnection *) connection{
    [self readJsonData];
}
- (void)connection: connection didFailWithError:(NSError *)error {
    self.weatherDisplay.text = [NSString stringWithFormat:@"Data Receiving Error: [%@]", [error localizedDescription]];
}

- (void)readJsonData {
    // NSJSONSerialization提供了将JSON数据转换为Foundation对象（一般都是NSDictionary和NSArray）
    //和Foundation对象转换为JSON数据（可以通过调用isValidJSONObject来判断Foundation对象是否可以转换为JSON数据）
    NSError *error;
    NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:self.weatherData options:NSJSONReadingMutableContainers error:&error];
    NSDictionary *weatherInfo = [weatherDic objectForKey:@"weatherinfo"];
    NSLog(@"%@", weatherInfo);
    self.weatherDisplay.text = [NSString stringWithFormat:@"%@ %@ %@",[weatherInfo objectForKey:@"city"], [weatherInfo objectForKey:@"weather1"], [weatherInfo objectForKey:@"temp1"]];
    
}

@end
