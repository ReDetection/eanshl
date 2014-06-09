//
//  AuthorizeViewController.m
//  eanshl
//
//  Created by sbuglakov on 01/06/14.
//  Copyright (c) 2014 redetection. All rights reserved.
//

#import "AuthorizeViewController.h"

NSString *const redirectURLString = @"http://127.0.0.1/";

@interface AuthorizeViewController () <UIWebViewDelegate, UIBarPositioningDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation AuthorizeViewController


- (IBAction)refreshButton:(id)sender {
    [self tryOpenAuthPage];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self tryOpenAuthPage];
}

- (void)setClientID:(NSString *)clientID {
    _clientID = clientID;
    [self tryOpenAuthPage];
}

- (void)setScope:(NSString *)scope {
    _scope = scope;
    [self tryOpenAuthPage];
}

- (void)tryOpenAuthPage {
    if (self.clientID != nil && self.scope != nil) {
        NSString *encodedRedirect = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)redirectURLString, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
        NSString *encodedScope = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)self.scope, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
        NSString *urlString = [NSString stringWithFormat:@"https://toshl.com/oauth2/authorize?client_id=%@&response_type=code&scope=%@&redirect_uri=%@&state=98765", self.clientID, encodedScope, encodedRedirect];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [_webView loadRequest:request];
    }
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.absoluteString hasPrefix:redirectURLString]) {
        NSArray *pairs = [request.URL.query componentsSeparatedByString:@"&"];
        for (NSString *pair in pairs) {
            NSArray *pairComponents = [pair componentsSeparatedByString:@"="];
            if (pairComponents.count == 2) {
                NSString *key = pairComponents[0];
                NSString *value = pairComponents[1];
                if ([key isEqualToString:@"code"]) {
                    self.completion(value, nil);
                    return NO;
                }
            }
        }
        self.completion(nil, [NSError errorWithDomain:@"Toshl OAuth error" code:1 userInfo:@{@"description": @"can't find auth code", @"request" : request}]);
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.activityIndicator stopAnimating];
    if ([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102) { //102 == WebKitErrorFrameLoadInterruptedByPolicyChange
        //we've interrupted download because of handled code
    } else {
        self.completion(nil, error);
    }
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
