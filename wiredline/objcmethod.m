//
//  objcmethod.m
//  wiredline
//
//  Created by HiraoKazumasa on 10/19/15.
//  Copyright © 2015 flidap. All rights reserved.
//

#import "objcmethod.h"
#import <CommonCrypto/CommonCrypto.h>
#import <iconv.h>
#import <sys/types.h>
#include <sys/sysctl.h>
#include <mach/machine.h>
#import <sys/socket.h>

//#import "AppDelegate-Swift.h"

#define WISEP 0x20
#define WITERM 0x04
#define WIFILESEP 0x1C
#define SSWIREDSEP 0x128

@implementation objcmethod
-(NSDictionary *)setSSLProperty
{
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                //[NSNumber numberWithBool:NO], kCFStreamSSLAllowsExpiredCertificates,
                                //[NSNumber numberWithBool:YES], kCFStreamSSLCertificates,
                                //[NSNumber numberWithBool:YES], kCFStreamSSLAllowsAnyRoot,
                                [NSNumber numberWithBool:NO], kCFStreamSSLValidatesCertificateChain,
                                kCFNull,kCFStreamSSLPeerName,kCFStreamSocketSecurityLevelTLSv1, kCFStreamSocketSecurityLevelTLSv1,
                                nil
                                ];
    //NSLog(@"%@",properties);
    return(properties);
}
-(void)setstreamproperty:(NSInputStream *)inputStream test:(NSOutputStream *)outputStream dic:(NSDictionary *)properties
{
    if (CFReadStreamSetProperty((CFReadStreamRef)(inputStream), kCFStreamPropertySSLSettings,
                                (CFTypeRef)properties)&&CFReadStreamSetProperty((CFReadStreamRef)(inputStream),
                                                                                kCFStreamPropertySSLSettings,(CFTypeRef)properties) == TRUE){
        
    }
    [inputStream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType];
    [outputStream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType];
    
}

- (NSString*) SHA1:(NSString *)textpasswd
{
    const char *cStr = [textpasswd UTF8String];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cStr, (int)strlen(cStr), result);
    NSString *s = [NSString  stringWithFormat:
                   @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                   result[0],  result[1],  result[2],
                   result[3],  result[4],  result[5],
                   result[6],  result[7],  result[8],
                   result[9],  result[10], result[11],
                   result[12], result[13], result[14],
                   result[15], result[16], result[17],
                   result[18], result[19]];
    return [s lowercaseString];
}
- (NSData *)cleanUTF8:(NSData *)data {
    // this function is from
    // http://stackoverflow.com/questions/3485190/nsstring-initwithdata-returns-null
    //
    //
    iconv_t cd = iconv_open("UTF-8", "UTF-8"); // convert to UTF-8 from UTF-8
    int one = 1;
    iconvctl(cd, ICONV_SET_DISCARD_ILSEQ, &one); // discard invalid characters
    size_t inbytesleft, outbytesleft;
    inbytesleft = outbytesleft = data.length;
    char *inbuf  = (char *)data.bytes;
    char *outbuf = malloc(sizeof(char) * data.length);
    char *outptr = outbuf;
    if (iconv(cd, &inbuf, &inbytesleft, &outptr, &outbytesleft)
        == (size_t)-1) {
        NSLog(@"this should not happen, seriously");
        return nil;
    }
    NSData *result = [NSData dataWithBytes:outbuf length:data.length - outbytesleft];
    iconv_close(cd);
    free(outbuf);
    return result;
}
-(UIImage *)bridgeImage:(CGSize)size color:(UIColor *)color
{
    UIImage *image=[[UIImage alloc]init];
    image=[self monochromeImageByImage:image monochromeColor:color];
    return(image);
}
-(int)checkLastterm:(NSData *)data
{
    const char *str;
    char *ret;
    //int result=0;
    int c='\04';
    unsigned long len=0;
    str=[data bytes];
    int i,count=0;
    len=strlen(str);
    for(i=0;i<len;i++){
        if(str[i]=='\04'){
            count++;
        }
    }
    ret=strrchr(str, c);
    printf("ret=%s\n",ret);
    if(len==count){
        printf("yes   len=%lu,count=%d\n",len,count);
        return(1);
    }
     printf("no   len=%lu,count=%d\n",len,count);
    return(0);
}
- (UIImage*)monochromeImageByImage:(UIImage*)image monochromeColor:(UIColor*)monochromeColor
{
    //@autoreleasepool {
        UIImage* monochromeImage;
        
        // UIImage と UIColor を Core Image のデータ形式に変換します。
        CIImage* ciImage = [[CIImage alloc] initWithImage:image];
        CIColor* ciColor = [[CIColor alloc] initWithColor:monochromeColor];
        NSNumber* nsIntensity = @0.6f;
        
        // コンテキストとモノトーンフィルタを作成して、そこに画像を通すことで、単調化された画像を取得できます。
        CIContext* ciContext = [CIContext contextWithOptions:nil];
        CIFilter* ciMonochromeFilter = [CIFilter filterWithName:@"CIColorMonochrome" keysAndValues:kCIInputImageKey, ciImage, @"inputColor", ciColor, @"inputIntensity", nsIntensity, nil];
        
        // 単調化された画像をいったん CGImageRef に変換して、それを UIImage に変換します。
        CGImageRef cgMonochromeImage = [ciContext createCGImage:ciMonochromeFilter.outputImage fromRect:[ciMonochromeFilter.outputImage extent]];
        monochromeImage = [UIImage imageWithCGImage:cgMonochromeImage scale:image.scale orientation:UIImageOrientationUp];
    
        CGImageRelease(cgMonochromeImage);
        
        // これで、単調化された画像を UIImage で取得することができました。
        return (monochromeImage);
    //}
}
-(void)releaseCIImage:(CGImageRef *)image
{
    CGImageRelease(*image);
}
-(NSData *)ssWiredChat:(NSString *)str
{
    char buf[261345];
    NSData *data;
    NSData *imgdata;
    imgdata=[str dataUsingEncoding:NSUTF8StringEncoding];
    const char *databuf=imgdata.bytes;
    snprintf(buf, 261345, "%s%c%s%c%c%s%c","SAY",WISEP,"1",WIFILESEP,128,databuf,WITERM);
    //printf("buf=%s\n",buf);
    data=[NSData dataWithBytes:(const char *)buf length:strlen(buf)];
    
    return(data);
}
-(void)setKeepAlive:(NSStream *)stream
{
#if DEBUG
    printf("setKeepAlive:ok");
#endif
    int sock = -1;
    NSData *sockObj = [stream propertyForKey:
                       (__bridge NSString *)kCFStreamPropertySocketNativeHandle];
    if ([sockObj isKindOfClass:[NSData class]] &&
        ([sockObj length] == sizeof(int)) ) {
        const int *sockptr = (const int *)[sockObj bytes];
        sock = *sockptr;
    }
    int on=1;
    if (setsockopt(sock, SOL_SOCKET, SO_KEEPALIVE, &on, sizeof(on)) == -1) {
        NSLog(@"setsockopt failed: %s", strerror(errno));
    }
    }
@end

@interface UIImage (CommonImplement)
- (UIImage *) makeThumbnailOfSize:(CGSize)size;
@end

@implementation UIImage (CommonImplement)
- (UIImage *) makeThumbnailOfSize:(CGSize)size;
{
    UIGraphicsBeginImageContext(size);
    // draw scaled image into thumbnail context
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();
    // pop the context
    UIGraphicsEndImageContext();
    if(newThumbnail == nil)
        NSLog(@"could not scale image");
    return newThumbnail;
}

/*char *utftosjis(char utfstr[1024*5])
{
    //fprintf(stderr,"utftosjis():ok\n");
    char sjisstr[1024*5];
    iconv_t cd;
    size_t sleft,dleft,status;
    char *sp,*dp,*pp;
    
    if((cd=iconv_open("SHIFT_JIS","UTF8"))==(iconv_t*)-1){
        perror("iconv_open");
        return((char *)-1);
    }
    sleft=strlen(utfstr);
    dleft=sizeof(sjisstr)-1;
    for(sp=utfstr,dp=sjisstr;*sp!='\0';){
        status=iconv(cd,&sp,&sleft,&dp,&dleft);
        //fprintf(stderr,"[%d]\n",status);
    }
    iconv_close(cd);
    *dp='\0';
    pp=sjisstr;
    return(pp);
}*/

@end

