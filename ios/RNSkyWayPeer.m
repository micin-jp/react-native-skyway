#import <React/RCTConvert.h>
#import "RNSkyWayPeer.h"


@implementation RNSkyWayPeer

- (void)dealloc
{
    [self disconnect];
}

- (instancetype)initWithPeerId:(NSString *)peerId options:(NSDictionary *)options constraints: (NSDictionary *)constraints
{
    self = [super init];
    if (self) {
        
        _peerStatus = RNSkyWayPeerDisconnected;
        _mediaConnectionStatus = RNSkyWayMediaConnectionDisconnected;
        
        _peerId = peerId;
        [self setOptionsFromDic:options];
        [self setConstraintsFromDic:constraints];
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

- (void)setOptionsFromDic:(NSDictionary *)dic {
    _options = [[SKWPeerOption alloc] init];
    
    if ([dic objectForKey:@"key"] != nil) {
        _options.key = [RCTConvert NSString:dic[@"key"]];
    }
    if ([dic objectForKey:@"domain"] != nil) {
        _options.domain = [RCTConvert NSString:dic[@"domain"]];
    }
    if ([dic objectForKey:@"host"] != nil) {
        _options.host = [RCTConvert NSString:dic[@"host"]];
    }
    if ([dic objectForKey:@"port"] != nil) {
        _options.port = [RCTConvert NSInteger:dic[@"port"]];
    }
    if ([dic objectForKey:@"secure"] != nil) {
        _options.secure = [RCTConvert BOOL:dic[@"secure"]];
    }
    if ([dic objectForKey:@"turn"] != nil) {
        _options.turn = [RCTConvert BOOL:dic[@"turn"]];
    }
    // TODO: support `config`
}

- (void)setConstraintsFromDic:(NSDictionary *)dic {
    _constraints = [[SKWMediaConstraints alloc] init];
    
    if ([dic objectForKey:@"videoFlag"] != nil) {
        _constraints.videoFlag = [RCTConvert BOOL:dic[@"videoFlag"]];
    }
    if ([dic objectForKey:@"audioFlag"] != nil) {
        _constraints.videoFlag = [RCTConvert BOOL:dic[@"audioFlag"]];
    }
    if ([dic objectForKey:@"cameraPosition"] != nil) {
        _constraints.cameraPosition = [RCTConvert NSInteger:dic[@"cameraPosition"]];
    }
    if ([dic objectForKey:@"maxWidth"] != nil) {
        _constraints.maxWidth = [RCTConvert NSInteger:dic[@"maxWidth"]];
    }
    if ([dic objectForKey:@"minWidth"] != nil) {
        _constraints.minWidth = [RCTConvert NSInteger:dic[@"minWidth"]];
    }
    if ([dic objectForKey:@"maxHeight"] != nil) {
        _constraints.maxHeight = [RCTConvert NSInteger:dic[@"maxHeight"]];
    }
    if ([dic objectForKey:@"minHeight"] != nil) {
        _constraints.minHeight = [RCTConvert NSInteger:dic[@"minHeight"]];
    }
    if ([dic objectForKey:@"maxFrameRate"] != nil) {
        _constraints.maxFrameRate = [RCTConvert NSInteger:dic[@"maxFrameRate"]];
    }
    if ([dic objectForKey:@"minFrameRate"] != nil) {
        _constraints.minFrameRate = [RCTConvert NSInteger:dic[@"minFrameRate"]];
    }
}

- (void)connect {
    
    self.peer = [[SKWPeer alloc] initWithId:self.peerId options:self.options];
    
    [self.peer on:SKW_PEER_EVENT_OPEN callback:^(NSObject* obj) {
        NSLog(@"RNSkyWayPeerManager open");
            
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
            if (nil == self.localStream) {
                [self openLocalStream];
            }
            
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
    if (self.peer == nil) {
        return;
    }
    if (self.localStream == nil) {
        [self openLocalStream];
    }
    
    self.mediaConnection = [self.peer callWithId:peerId stream:self.localStream];
    [self setMediaCallbacks];
}

- (void)hangup {
    [self closeRemoteStream];
    [self.mediaConnection close];
}

- (void) openLocalStream {
    if (self.peer == nil) {
        return;
    }
    
    [self closeLocalStream];
    [SKWNavigator initialize:self.peer];
    self.localStream = [SKWNavigator getUserMedia:self.constraints];
}

- (void) closeLocalStream {
    if(self.localStream == nil) {
        return;
    }
    
    // TODO: dispose local video view?
    
    [self.localStream close];
    self.localStream = nil;
}

- (void) closeRemoteStream {
    if(self.remoteStream == nil) {
        return;
    }
    
    // TODO: dispose remote video view?
    
    [self.remoteStream close];
    self.remoteStream = nil;
}

- (void)listAllPeers:(RCTResponseSenderBlock) callback {
    if (self.peer == nil) {
        callback(@[ @"Peer Disconnected", [NSNull null] ]);
        return;
    }

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
    if (self.peer == nil) {
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
    if(self.mediaConnection == nil) {
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
