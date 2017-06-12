//
//  objcmethod.h
//  wiredline
//
//  Created by HiraoKazumasa on 10/19/15.
//  Copyright © 2015 flidap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iconv.h"
#import <UIKit/UIKit.h>

@interface objcmethod : NSObject<NSStreamDelegate>
-(NSDictionary *)setSSLProperty;
-(void)setstreamproperty:(NSInputStream *)inputstream test:(NSOutputStream *)outputstream dic:(NSDictionary *)properties;
- (NSString*) SHA1:(NSString *)textpasswd;
- (NSData *)cleanUTF8:(NSData *)data;
-(int)checkLastterm:(NSData *)data;
-(UIImage *)bridgeImage:(CGSize)size color:(UIColor *)color;
- (UIImage*)monochromeImageByImage:(UIImage*)image monochromeColor:(UIColor*)monochromeColor;
-(void)releaseCIImage:(CGImageRef *)image;
-(NSData *)ssWiredChat:(NSString *)str;
-(void)setKeepAlive:(NSStream *)stream;


@end
