//
//  ViewController.m
//  jdpig
//
//  Created by jr on 2018/5/21.
//  Copyright © 2018年 jr. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "WebViewJavascriptBridge.h"
@interface ViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>
@property (nonatomic, strong)WKWebView    *webView;              /**<#描述#>*/
@property (nonatomic, strong)WebViewJavascriptBridge    *bridge;              /**<#描述#>*/
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, -20, screenWidth, screenHeight+20) configuration:config];
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
//    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://pig.jd.com"]]];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"index" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
    [self.view addSubview:_webView];
    //注册JS 调原生的方法
    [_webView.configuration.userContentController addScriptMessageHandler:self name:@"Camera"];

    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(40,  screenHeight-200, screenWidth-80, 40)];
    [btn setTitle:@"OC 给 js 传参数" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor blueColor];
    [btn addTarget:self action:@selector(OCTJS) forControlEvents:UIControlEventTouchUpInside];
    [self.webView addSubview:btn];
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([message.name isEqualToString:@"Camera"]) {
        //TODO
        NSLog(@"------%@",message.body);
    }
}
//oc 给 js 传值
- (void)OCTJS{
    // 将分享结果返回给js
    NSString *jsStr = [NSString stringWithFormat:@"jsStr('%@')",@"oc 给 js 传值"];
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (!error) { // 成功
            NSLog(@"%@",result);
        } else { // 失败
            NSLog(@"%@",error.localizedDescription);
        }
    }];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //addScriptMessageHandler很容易引起循环引用，导致控制器无法被释放， 因此这里要记得移除handlers
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"Camera"];
}
#pragma WKNavigationDelegate

//页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@"页面开始加载时调用。   2");
}
//内容返回时调用，得到请求内容时调用(内容开始加载) -> view的过渡动画可在此方法中加载
- (void)webView:(WKWebView *)webView didCommitNavigation:( WKNavigation *)navigation
{
    NSLog(@"内容返回时调用，得到请求内容时调用。 4");
}
//页面加载完成时调用
- (void)webView:(WKWebView *)webView didFinishNavigation:( WKNavigation *)navigation
{
    NSLog(@"页面加载完成时调用。 5");
}
//请求失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"error1:%@",error);
}
-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"error2:%@",error);
}
//在请求发送之前，决定是否跳转 -> 该方法如果不实现，系统默认跳转。如果实现该方法，则需要设置允许跳转，不设置则报错。
//该方法执行在加载界面之前
//Terminating app due to uncaught exception ‘NSInternalInconsistencyException‘, reason: ‘Completion handler passed to -[ViewController webView:decidePolicyForNavigationAction:decisionHandler:] was not called‘
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    
    //不允许跳转
    //    decisionHandler(WKNavigationActionPolicyCancel);
    NSLog(@"在请求发送之前，决定是否跳转。  1");
}

//在收到响应后，决定是否跳转（同上）
//该方法执行在内容返回之前
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //    decisionHandler(WKNavigationResponsePolicyCancel);
    NSLog(@"在收到响应后，决定是否跳转。 3");
    
}
//接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@"接收到服务器跳转请求之后调用");
}
-(void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    NSLog(@"webViewWebContentProcessDidTerminate");
}


#pragma WKUIDelegate
//在JS端调用alert函数时，会触发此代理方法。
//警告框
/**
 webView界面中有弹出警告框时调用
 @param webView             web视图调用委托方法
 @param message             警告框提示内容
 @param frame               主窗口
 @param completionHandler   警告框消失调用
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    completionHandler();
    NSLog(@"警告框-->%@",message);
}
//输入框
/**
 web界面中弹出输入框时调用
 @param webView             web视图调用委托方法
 @param prompt              输入消息的显示
 @param defaultText         初始化时显示的输入文本
 @param frame               主窗口
 @param completionHandler   输入结束后调用
 */
-(void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler
{
    NSLog(@"输入框");
    completionHandler(@"http");
}
//确认框
/**
 显示一个JavaScript确认面板
 @param webView             web视图调用委托方法
 @param message             显示的信息
 @param frame               主窗口
 @param completionHandler   确认后完成处理程序调用
 */
-(void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    NSLog(@"确认框");
    completionHandler(YES);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
