//
//  UnityEditorCallProxy.m
//  Crafty Craft 5
//
//  Created by Vitalii P on 12.07.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UnityEditorCallProxy.h"

@implementation UnityEditorCallProxyApi

id<UnityEditorCallProxyProtocol> api = NULL;

+ (void)registerForCalls:(nonnull id<UnityEditorCallProxyProtocol>)anApi {
    api = anApi;
}

@end

#ifdef __cplusplus
extern "C" {
#endif

    void
    unity_editorSave(const char* state) {
        const NSString *str = @(state);
        [api onUnityEditorSave: str];
    }
    
    void
    unity_editorExit(void) {
        [api onUnityEditorExit];
    }
    
    void
    unity_editorDownload(const char* state) {
        const NSString *str = @(state);
        [api onUnityEditorDownload: str];
    }
    
    void
    unity_editorShare(const char* state) {
        const NSString *str = @(state);
        [api onUnityEditorShare: str];
    }

#ifdef __cplusplus
}
#endif
