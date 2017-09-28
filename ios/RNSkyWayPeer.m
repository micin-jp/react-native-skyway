//
//  RNSkyWayPeer.m
//  RNSkyWay
//
//  Created by Daichi Sakai on 2017/10/03.
//  Copyright © 2017年 Micin. All rights reserved.
//

#import <React/RCTConvert.h>
#import "RNSkyWayPeer.h"


@implementation RNSkyWayPeer

- (void)dealloc
{
    [self disconnect];
}

- (instancetype)init
{
    //TODO
    return [self initWithPeerId:nil options:nil];
}

- (instancetype)initWithPeerId:(NSString *)peerId options:(NSDictionary *)options
{
    self = [super init];
    if (self) {
        
        _peerStatus = RNSkyWayPeerDisconnected;
        _mediaConnectionStatus = RNSkyWayMediaConnectionDisconnected;
        
        _peerId = peerId;
        _options = options;
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)setPeerStatus:(RNSkyWayPeerStatus)status {
    _peerStatus = status;
    [self notifyPeerStatusChangeDelegate];
}

- (void)setMediaConnectionStatus:(RNSkyWayMediaConnectionStatus)status {
    _mediaConnectionStatus = status;
    [self notifyMediaConnectionStatusChangeDelegate];
}


- (void)connect {
    //TODO use options
    SKWPeerOption* skOptions = [[SKWPeerOption alloc] init];
    
    skOptions.key = [RCTConvert NSString:self.options[@"key"]];
    skOptions.domain = [RCTConvert NSString:self.options[@"domain"]];
    
    self.peer = [[SKWPeer alloc] initWithId:self.peerId options:skOptions];
    
    [self.peer on:SKW_PEER_EVENT_OPEN callback:^(NSObject* obj) {
        NSLog(@"RNSkyWayPeerManager open");
            
        //TODO use options
        SKWMediaConstraints* constraints = [[SKWMediaConstraints alloc] init];
        constraints.maxWidth = 960;
        constraints.maxHeight = 540;
        constraints.cameraPosition = SKW_CAMERA_POSITION_FRONT;
        
        [SKWNavigator initialize:self.peer];
        self.localStream = [SKWNavigator getUserMedia:constraints];
        
        self.peerStatus = RNSkyWayPeerConnected;
        [self notifyOpenDelegate];
    }];

    [self.peer on:SKW_PEER_EVENT_CLOSE callback:^(NSObject* obj) {
        NSLog(@"RNSkyWayPeerManager close");

        self.peerStatus = RNSkyWayPeerDisconnected;
        [self notifyCloseDelegate];
    }];
    
    [self.peer on:SKW_PEER_EVENT_DISCONNECTED callback:^(NSObject* obj) {
        NSLog(@"RNSkyWayPeerManager disconnected");

        [self notifyDisconnectedDelegate];
    }];


    [self.peer on:SKW_PEER_EVENT_ERROR callback:^(NSObject* obj) {
        NSLog(@"RNSkyWayPeerManager error");

        SKWPeerError* error = (SKWPeerError*)obj;
        NSLog(@"%@",error);
        
        [self notifyErrorDelegate];
    }];
    
    [self.peer on:SKW_PEER_EVENT_CALL callback:^(NSObject* obj) {
        NSLog(@"RNSkyWayPeerManager call");

        if (YES == [obj isKindOfClass:[SKWMediaConnection class]]) {
            self.mediaConnection = (SKWMediaConnection *)obj;
            [self setMediaCallbacks];
            [self.mediaConnection answer:self.localStream];
            
            [self notifyCallDelegate];
        }
    }];
}

- (void)disconnect {
    if (nil == self.peer) {
        return;
    }
    
    [self unsetPeerCallbacks];
    [self unsetMediaCallbacks];
    [self closeLocalStream];
    [self closeRemoteStream];

    [self.peer disconnect];
    self.peer = nil;
}

- (void)call:(NSString *)peerId {
    self.mediaConnection = [_peer callWithId:peerId stream:_localStream];
    [self setMediaCallbacks];
}

- (void)hangup {
    [self closeRemoteStream];
    [self.mediaConnection close];
}

- (void) closeLocalStream {
    if(nil == self.localStream) {
        return;
    }
    
    // TODO: dispose local video view?
    
    [self.localStream close];
    self.localStream = nil;
}

- (void) closeRemoteStream {
    if(nil == self.remoteStream) {
        return;
    }
    
    // TODO: dispose remote video view?
    
    [self.remoteStream close];
    self.remoteStream = nil;
}

- (void)listAllPeers:(RCTResponseSenderBlock) callback {
    [self.peer listAllPeers:^(NSArray* peers){
        callback(@[ [NSNull null], peers ]);
    }];
}

- (void)setMediaCallbacks {
    if (nil == self.mediaConnection) {
        return;
    }
    
    [_mediaConnection on:SKW_MEDIACONNECTION_EVENT_STREAM callback:^(NSObject* obj) {
        if (YES == [obj isKindOfClass:[SKWMediaStream class]]) {
            if (self.mediaConnectionStatus == RNSkyWayMediaConnectionConnected) {
                return;
            }
            
            self.mediaConnectionStatus = RNSkyWayMediaConnectionConnected;
            self.remoteStream = (SKWMediaStream *)obj;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self notifyMediaConnectionDelegate];
            });
            
        }
    }];
    
}

- (void)unsetPeerCallbacks {
    if (nil == self.peer) {
        return;
    }
    
    [_peer on:SKW_PEER_EVENT_OPEN callback:nil];
    [_peer on:SKW_PEER_EVENT_CONNECTION callback:nil];
    [_peer on:SKW_PEER_EVENT_CALL callback:nil];
    [_peer on:SKW_PEER_EVENT_CLOSE callback:nil];
    [_peer on:SKW_PEER_EVENT_DISCONNECTED callback:nil];
    [_peer on:SKW_PEER_EVENT_ERROR callback:nil];
}

- (void)unsetMediaCallbacks {
    if(nil == self.mediaConnection) {
        return;
    }
    
    [self.mediaConnection on:SKW_MEDIACONNECTION_EVENT_STREAM callback:nil];
    [self.mediaConnection on:SKW_MEDIACONNECTION_EVENT_CLOSE callback:nil];
    [self.mediaConnection on:SKW_MEDIACONNECTION_EVENT_ERROR callback:nil];
}


- (void) addDelegate: (id<RNSkyWayPeerDelegate>) delegate
{
    [self.delegates addObject: delegate];
}

- (void) removeDelegate: (id<RNSkyWayPeerDelegate>) delegate
{
    [self.delegates removeObject: delegate];
}

- (void) notifyOpenDelegate {
    for (id<RNSkyWayPeerDelegate> delegete in self.delegates) {
        if ([delegete conformsToProtocol:@protocol(RNSkyWayPeerDelegate)]) {
            if ([delegete respondsToSelector:@selector(onOpen:)]) {
                [delegete onOpen:self];
            }
        }
    }
}

- (void) notifyCallDelegate {
    for (id<RNSkyWayPeerDelegate> delegete in self.delegates) {
        if ([delegete conformsToProtocol:@protocol(RNSkyWayPeerDelegate)]) {
            if ([delegete respondsToSelector:@selector(onCall:)]) {
                [delegete onCall:self];
            }
        }
    }
}

- (void) notifyCloseDelegate {
    for (id<RNSkyWayPeerDelegate> delegete in self.delegates) {
        if ([delegete conformsToProtocol:@protocol(RNSkyWayPeerDelegate)]) {
            if ([delegete respondsToSelector:@selector(onClose:)]) {
                [delegete onClose:self];
            }
        }
    }
}

- (void) notifyDisconnectedDelegate {
    for (id<RNSkyWayPeerDelegate> delegete in self.delegates) {
        if ([delegete conformsToProtocol:@protocol(RNSkyWayPeerDelegate)]) {
            if ([delegete respondsToSelector:@selector(onDisconnected:)]) {
                [delegete onDisconnected:self];
            }
        }
    }
}

- (void) notifyErrorDelegate {
    for (id<RNSkyWayPeerDelegate> delegete in self.delegates) {
        if ([delegete conformsToProtocol:@protocol(RNSkyWayPeerDelegate)]) {
            if ([delegete respondsToSelector:@selector(onError:)]) {
                [delegete onError:self];
            }
        }
    }
}

- (void) notifyMediaConnectionDelegate {
    for (id<RNSkyWayPeerDelegate> delegete in self.delegates) {
        if ([delegete conformsToProtocol:@protocol(RNSkyWayPeerDelegate)]) {
            if ([delegete respondsToSelector:@selector(onMediaConnection:)]) {
                [delegete onMediaConnection:self];
            }
        }
    }
}

- (void) notifyPeerStatusChangeDelegate {
    for (id<RNSkyWayPeerDelegate> delegete in self.delegates) {
        if ([delegete conformsToProtocol:@protocol(RNSkyWayPeerDelegate)]) {
            if ([delegete respondsToSelector:@selector(onPeerStatusChange:)]) {
                [delegete onPeerStatusChange:self];
            }
        }
    }
}

- (void) notifyMediaConnectionStatusChangeDelegate {
    for (id<RNSkyWayPeerDelegate> delegete in self.delegates) {
        if ([delegete conformsToProtocol:@protocol(RNSkyWayPeerDelegate)]) {
            if ([delegete respondsToSelector:@selector(onMediaConnectionStatusChange:)]) {
                [delegete onMediaConnectionStatusChange:self];
            }
        }
    }
}



@end
