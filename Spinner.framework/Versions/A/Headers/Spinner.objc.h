// Objective-C API for talking to github.com/jnglco/JnglMobile/spinner Go package.
//   gobind -lang=objc github.com/jnglco/JnglMobile/spinner
//
// File is generated by gobind. Do not edit.

#ifndef __Spinner_H__
#define __Spinner_H__

@import Foundation;
#include "Universe.objc.h"


@class SpinnerClient;
@class SpinnerClientConfig;
@class SpinnerDirEntry;
@class SpinnerUser;

@interface SpinnerClient : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) id _ref;

- (id)initWithRef:(id)ref;
- (NSData*)get:(NSString*)path error:(NSError**)error;
- (SpinnerDirEntry*)glob:(NSString*)pattern error:(NSError**)error;
- (NSString*)put:(NSString*)name data:(NSData*)data error:(NSError**)error;
@end

@interface SpinnerClientConfig : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) id _ref;

- (id)initWithRef:(id)ref;
- (NSString*)userName;
- (void)setUserName:(NSString*)v;
- (NSString*)publicKey;
- (void)setPublicKey:(NSString*)v;
- (NSString*)privateKey;
- (void)setPrivateKey:(NSString*)v;
- (NSString*)keyNetAddr;
- (void)setKeyNetAddr:(NSString*)v;
- (NSString*)storeNetAddr;
- (void)setStoreNetAddr:(NSString*)v;
- (NSString*)dirNetAddr;
- (void)setDirNetAddr:(NSString*)v;
@end

@interface SpinnerDirEntry : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) id _ref;

- (id)initWithRef:(id)ref;
- (NSString*)name;
- (void)setName:(NSString*)v;
- (BOOL)isDir;
- (void)setIsDir:(BOOL)v;
- (int64_t)size;
- (void)setSize:(int64_t)v;
- (int64_t)lastModified;
- (void)setLastModified:(int64_t)v;
- (NSString*)writer;
- (void)setWriter:(NSString*)v;
- (SpinnerDirEntry*)next;
- (void)setNext:(SpinnerDirEntry*)v;
@end

@interface SpinnerUser : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) id _ref;

- (id)initWithRef:(id)ref;
- (NSString*)public;
- (void)setPublic:(NSString*)v;
- (NSString*)private;
- (void)setPrivate:(NSString*)v;
- (NSString*)error;
- (void)setError:(NSString*)v;
@end

FOUNDATION_EXPORT SpinnerUser* SpinnerKeygen(NSString* secretStr, NSError** error);

FOUNDATION_EXPORT SpinnerClient* SpinnerNewClient(SpinnerClientConfig* clientConfig, NSError** error);

FOUNDATION_EXPORT SpinnerClientConfig* SpinnerNewClientConfig();

#endif
