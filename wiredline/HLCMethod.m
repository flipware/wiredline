//
//  HLCMethod.m
//  wiredline
//
//  Created by flidap on 11/8/15.
//  Copyright © 2015 flidap. All rights reserved.
//

#import "HLCMethod.h"
#import <iconv.h>

@implementation HLCMethod
-(void)setStreamToVoiP:(NSInputStream *)inputStream test:(NSOutputStream *)outputStream
{
    [inputStream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType];
    [outputStream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType];
    
}
-(NSData *)HLEncryptedLogin:(NSString *)str
{
    NSUInteger /*plen,*/llen,i;
    NSData *data;
    const char *login;
    char *encrypted_login=NULL;
    
    login=[str UTF8String];
    
    if(login){
        llen=strlen(login);
    }else{
        login="guest";
        llen=strlen(login);
    }
    encrypted_login=(char *)malloc(llen);
    for(i=0;i<llen;i++){
        encrypted_login[i]=0xFF ^ login[i];
    }
    data=[NSData dataWithBytes:encrypted_login length:strlen(encrypted_login)];
    if(llen!=0){
        free(encrypted_login);
    }
    return(data);
}
-(void)findeof:(NSData *)data
{
    const char *ptr;
    unsigned long len;
    ptr=[data bytes];
    len=strlen(ptr);
    if(ptr[len]=='\0'){
        printf("end");
    }else{
        printf("Noooooo");
    }
    
}

-(NSData *)HLEncryptedPassword:(NSString *)str
{
    NSUInteger plen=0,i=0;
    NSData *data;
    const char *passwd;
    char *encrypted_passwd=NULL;
    
    passwd=[str UTF8String];
        if(passwd){
        plen=strlen(passwd);
    }
    if(plen>0){
        encrypted_passwd=(char *)alloca(plen);
    }
    if(plen!=0){
        for(i=0;i<plen;i++){
            encrypted_passwd[i]=0xFF ^  passwd[i];
        }
    }
    data=[NSData dataWithBytes:encrypted_passwd length:plen];
    return(data);
}
-(NSData *)pointerIncrement:(NSData *)data length:(NSInteger)len
{
    char *ptr;
    //char *str;
    memset(&ptr,0,sizeof(ptr));
    ptr=(void *)[data bytes];
    //strncpy(ptr, str, len);
    ptr+=len;
    if(data.length>len){
        data=[NSData dataWithBytes:ptr length:data.length-len];
    }else{
        data=[NSData dataWithBytes:ptr length:data.length];
    }
    return(data);
}
-(NSData *)pointerCopy:(NSData *)data length:(NSInteger)len;
{
    const unsigned char *ptr;
    NSData *ddd;
    ptr=[data bytes];
    ddd=[NSData dataWithBytes:ptr length:data.length-len ];
    return ddd;
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
- (NSData *)cleanSJIS:(NSData *)data {
    // this function is from
    // http://stackoverflow.com/questions/3485190/nsstring-initwithdata-returns-null
    //
    //
    iconv_t cd = iconv_open("SHIFT_JIS", "SHIFT_JIS"); // convert to UTF-8 from UTF-8
    int one = 1;
    //iconvctl(cd, ICONV_SET_DISCARD_ILSEQ, &one); // discard invalid characters
    iconvctl(cd, ICONV_SET_FALLBACKS, &one);
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



@end
