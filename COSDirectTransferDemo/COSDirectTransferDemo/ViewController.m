//
//  ViewController.m
//  COSDirectTransferDemo
//
//  Created by garenwang on 2023/5/25.
//

#import "ViewController.h"

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,NSURLSessionDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *labelProgress;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UIButton *buttonStart;

@property (strong, nonatomic) NSData * body;
@property (strong, nonatomic) NSString * ext;
@property (weak, nonatomic) IBOutlet UITextView *tvResult;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.backgroundColor = UIColor.lightGrayColor;
    self.progress.progress = 0;
    self.labelProgress.text = @"请选择文件";
}

- (IBAction)actionStart:(UIButton *)sender {
    
    self.progress.progress = 0;
    self.tvResult.text = @"";
    self.labelProgress.text = @"";
    
    if(!self.body){
        self.labelProgress.text = @"请选择文件";
        return;
    }
    
    NSDictionary * params = [self getStsDirectSign:self.ext];
    
    if(!params){
        return;
    }
    self.labelProgress.text = @"开始上传";
    NSString * cosHost = [params objectForKey:@"cosHost"];
    NSString * cosKey = [params objectForKey:@"cosKey"];
    NSString * authorization = [params objectForKey:@"authorization"];
    NSString * securityToken = [params objectForKey:@"securityToken"];
    
    NSURL * stsURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/%@",cosHost,cosKey]];
    NSMutableURLRequest * stsRequest = [NSMutableURLRequest requestWithURL:stsURL];
    [stsRequest setHTTPMethod:@"PUT"];
    [stsRequest setAllHTTPHeaderFields:@{
        @"Content-Type":@"application/octet-stream",
        @"Content-Length":@(self.body.length).stringValue,
        @"Authorization":authorization,
        @"x-cos-security-token":securityToken,
        @"Host":cosHost
    }];
    
    NSURLSession * session = [NSURLSession sessionWithConfiguration: [NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];

    NSURLSessionDataTask * task = [session uploadTaskWithRequest:stsRequest fromData:self.body completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.labelProgress.text = @"上传失败";
                self.tvResult.text = [NSString stringWithFormat:@"error = %@",error];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.labelProgress.text = @"上传成功";
                self.tvResult.text = [NSString stringWithFormat:@"response = %@",response];
            });
        }
    }];
    [task resume];
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(totalBytesExpectedToSend > 0){
            self.progress.progress = (double)(totalBytesSent / (totalBytesExpectedToSend * 1.0));
        }
    });
}

- (IBAction)selectImage:(UIButton *)sender {
    UIImagePickerController* picker = [UIImagePickerController new];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
    
}

-(NSDictionary *)getStsDirectSign:(NSString *)ext{
    self.labelProgress.text = @"始获取签名";
    __block NSDictionary * params;
    dispatch_semaphore_t semp = dispatch_semaphore_create(0);
    
    //直传签名业务服务端url（正式环境 请替换成正式的直传签名业务url）
    NSURL * stsURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://127.0.0.1:3000/sts-direct-sign?ext=%@",[ext lowercaseString]]];
    NSMutableURLRequest * stsRequest = [NSMutableURLRequest requestWithURL:stsURL];
    [stsRequest setHTTPMethod:@"GET"];
    NSURLSession * session = [NSURLSession sharedSession];
    NSURLSessionDataTask * task = [session dataTaskWithRequest:stsRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if([dic[@"code"] integerValue] != 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.labelProgress.text = @"获取签名错误";
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.labelProgress.text = @"获取签名成功";
            });
            params = dic[@"data"];
        }
        dispatch_semaphore_signal(semp);
    }];
    [task resume];
    
    dispatch_semaphore_wait(semp, DISPATCH_TIME_FOREVER);
    return params;
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSURL * imageUrl = info[UIImagePickerControllerReferenceURL];
        self.ext = [[[imageUrl query] componentsSeparatedByString:@"ext="] lastObject];
        NSURL * imageDataURL = info[UIImagePickerControllerImageURL];
        self.body = [NSData dataWithContentsOfURL:imageDataURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = image;
            self.labelProgress.text = [NSString stringWithFormat:@"文件大小：%ld;  文件格式：%@;",self.body.length,self.ext];
            self.progress.progress = 0;
            self.tvResult.text = @"";
        });
        
    });
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
