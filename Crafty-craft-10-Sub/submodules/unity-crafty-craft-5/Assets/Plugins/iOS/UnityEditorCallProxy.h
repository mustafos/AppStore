//
//  UnityEditorCallProxy.h
//  Crafty Craft 5
//
//  Created by Vitalii P on 12.07.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol UnityEditorCallProxyProtocol
@required

- (void)onUnityEditorSave:(const NSString *)name;

- (void)onUnityEditorExit;

- (void)onUnityEditorDownload:(const NSString *)name;

- (void)onUnityEditorShare:(const NSString *)name;

// other methods
@end

__attribute__ ((visibility("default")))
@interface UnityEditorCallProxyApi: NSObject

+ (void)registerForCalls:(id<UnityEditorCallProxyProtocol>)anApi;

@end

NS_ASSUME_NONNULL_END


