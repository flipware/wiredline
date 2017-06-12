//
//  HLCMethod.h
//  wiredline
//
//  Created by flidap on 11/8/15.
//  Copyright © 2015 flidap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLCMethod : NSObject<NSStreamDelegate>
-(NSData *)HLEncryptedLogin:(NSString *)str;
-(NSData *)HLEncryptedPassword:(NSString *)str;
-(NSData *)pointerIncrement:(NSData *)data length:(NSInteger)len;
-(NSData *)pointerCopy:(NSData *)data length:(NSInteger)len;
- (NSData *)cleanUTF8:(NSData *)data;
-(void)findeof:(NSData *)data;
-(void)setStreamToVoiP:(NSInputStream *)inputStream test:(NSOutputStream *)outputStream;
- (NSData *)cleanSJIS:(NSData *)data;
@end
