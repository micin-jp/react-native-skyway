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
    if (_peerStatus != status) {
        _peerStatus = status;
        [self notifyPeerStatusChangeDelegate];
    }
}

- (void)setMediaConnectionStatus:(RNSkyWayMediaConnectionStatus)status {
    if (_mediaConnectionStatus != status) {
        _mediaConnectionStatus = status;
        [self notifyMediaConnectionStatusChangeDelegate];
    }
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
        [self notifyPeerOpenDelegate];
    }];

    [self.peer on:SKW_PEER_EVENT_CLOSE callback:^(NSObject* obj) {
        NSLog(@"RNSkyWayPeerManager close");

        [self notifyPeerCloseDelegate];
    }];
    
    [self.peer on:SKW_PEER_EVENT_DISCONNECTED callback:^(NSObject* obj) {
        NSLog(@"RNSkyWayPeerManager disconnected");

        [self disconnect];

        self.peerStatus = RNSkyWayPeerDisconnected;
        [self notifyPeerDisconnectedDelegate];
    }];


    [self.peer on:SKW_PEER_EVENT_ERROR callback:^(NSObject* obj) {
        NSLog(@"RNSkyWayPeerManager error");

        SKWPeerError* error = (SKWPeerError*)obj;
        NSLog(@"%@",error);
        
        [self notifyPeerErrorDelegate];
    }];
    
    [self.peer on:SKW_PEER_EVENT_CALL callback:^(NSObject* obj) {
        NSLog(@"RNSkyWayPeerManager call");

        if (YES == [obj isKindOfClass:[SKWMediaConnection class]]) {
            self.mediaConnection = (SKWMediaConnection *)obj;
            [self setMediaCallbacks];
            
            [self notifyPeerCallDelegate];
        }
    }];
}

- (void)disconnect {
    [self closeRemoteStream];
    [self closeLocalStream];
    [self closeMediaConnection];

    if (self.peer != nil) {
        [self unsetPeerCallbacks];

        if (![self.peer isDisconnected]) {
            [self.peer disconnect];
            [self notifyPeerDisconnectedDelegate];
        }
        [self.peer destroy];
    }
    self.peerStatus = RNSkyWayPeerDisconnected;
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

- (void)answer {
    if (self.peer == nil) {
        return;
    }
    if (self.mediaConnection == nil) {
        return;
    }
    
    if (self.localStream == nil) {
        [self openLocalStream];
    }

    [self.mediaConnection answer:self.localStream];
}

- (void)hangup {
    [self closeRemoteStream];
    [self closeLocalStream];
    [self closeMediaConnection];
}

- (void) openLocalStream {
    if (self.peer == nil) {
        return;
    }
    
    [self closeLocalStream];
    [SKWNavigator initialize:self.peer];
    self.localStream = [SKWNavigator getUserMedia:self.constraints];
    [SKWNavigator terminate];
    
    [self notifyLocalStreamOpenDelegate];
}

- (void) closeLocalStream {
    if(self.localStream == nil) {
        return;
    }
    
    [self notifyLocalStreamWillCloseDelegate];
    
    [self.localStream close];
    self.localStream = nil;
}

- (void) closeRemoteStream {
    if(self.remoteStream == nil) {
        return;
    }
    
    [self notifyRemoteStreamWillCloseDelegate];

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
                [self notifyMediaConnectionOpenDelegate];
                [self notifyRemoteStreamOpenDelegate];
            });
        }
    }];
    
    [_mediaConnection on:SKW_MEDIACONNECTION_EVENT_ERROR callback:^(NSObject* obj) {
        NSLog(@"RNSkyWayPeerManager mediaConnection error");
        
        [self notifyMediaConnectionErrorDelegate];
    }];

    [_mediaConnection on:SKW_MEDIACONNECTION_EVENT_CLOSE callback:^(NSObject* obj) {
        NSLog(@"RNSkyWayPeerManager mediaConnection close");

        [self notifyMediaConnectionCloseDelegate];
    }];

}

- (void)closeMediaConnection {
    if (self.mediaConnection == nil) {
        return;
    };
    
    [self unsetPeerCallbacks];
    if ([self.mediaConnection isOpen]) {
        [self.mediaConnection close];
        [self notifyMediaConnectionCloseDelegate];
    }
    self.mediaConnectionStatus = RNSkyWayMediaConnectionDisconnected;
    self.mediaConnection = nil;
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

- (void) notifyPeerOpenDelegate {
    for (id<RNSkyWayPeerDelegate> delegete in self.delegates) {
        if ([delegete conformsToProtocol:@protocol(RNSkyWayPeerDelegate)]) {
            if ([delegete respondsToSelector:@selector(onPeerOpen:)]) {
                [delegete onPeerOpen:self];
            }
        }
    }
}

- (void) notifyPeerCallDelegate {
    for (id<RNSkyWayPeerDelegate> delegete in self.delegates) {
        if ([delegete conformsToProtocol:@protocol(RNSkyWayPeerDelegate)]) {
            if ([delegete respondsToSelector:@selector(onPeerCall:)]) {
                [delegete onPeerCall:self];
            }
        }
    }
}

- (void) notifyPeerCloseDelegate {
    for (id<RNSkyWayPeerDelegate> delegete in self.delegates) {
        if ([delegete conformsToProtocol:@protocol(RNSkyWayPeerDelegate)]) {
            if ([delegete respondsToSelector:@selector(onPeerClose:)]) {
                [delegete onPeerClose:self];
            }
        }
    }
}

- (void) notifyPeerDisconnectedDelegate {
    for (id<RNSkyWayPeerDelegate> delegete in self.delegates) {
        if ([delegete conformsToProtocol:@protocol(RNSkyWayPeerDelegate)]) {
            if ([delegete respondsToSelector:@selector(onPeerDisconnected:)]) {
                [delegete onPeerDisconnected:self];
            }
        }
    }
}

- (void) notifyPeerErrorDelegate {
    for (id<RNSkyWayPeerDelegate> delegete in self.delegates) {
        if ([delegete conformsToProtocol:@protocol(RNSkyWayPeerDelegate)]) {
            if ([delegete respondsToSelector:@selector(onPeerError:)]) {
                [delegete onPeerError:self];
            }
        }
    }
}

- (void) notifyLocalStreamOpenDelegate {
    for (id<RNSkyWayPeerDelegate> delegete in self.delegates) {
        if ([delegete conformsToProtocol:@protocol(RNSkyWayPeerDelegate)]) {
            if ([delegete respondsToSelector:@selector(onLocalStreamOpen:)]) {
                [delegete onLocalStreamOpen:self];
            }
        }
    }
}

- (void) notifyLocalStreamWillCloseDelegate {
    for (id<RNSkyWayPeerDelegate> delegete in self.delegates) {
        if ([delegete conformsToProtocol:@protocol(RNSkyWayPeerDelegate)]) {
            if ([delegete respondsToSelector:@selector(onLocalStreamWillClose:)]) {
                [delegete onLocalStreamWillClose:self];
            }
        }
    }
}

- (void) notifyRemoteStreamOpenDelegate {
    for (id<RNSkyWayPeerDelegate> delegete in self.delegates) {
        if ([delegete conformsToProtocol:@protocol(RNSkyWayPeerDelegate)]) {
            if ([delegete respondsToSelector:@selector(onRemoteStreamOpen:)]) {
                [delegete onRemoteStreamOpen:self];
            }
        }
    }
}

- (void) notifyRemoteStreamWillCloseDelegate {
    for (id<RNSkyWayPeerDelegate> delegete in self.delegates) {
        if ([delegete conformsToProtocol:@protocol(RNSkyWayPeerDelegate)]) {
            if ([delegete respondsToSelector:@selector(onRemoteStreamWillClose:)]) {
                [delegete onRemoteStreamWillClose:self];
            }
        }
    }
}

- (void) notifyMediaConnectionOpenDelegate {
    for (id<RNSkyWayPeerDelegate> delegete in self.delegates) {
        if ([delegete conformsToProtocol:@protocol(RNSkyWayPeerDelegate)]) {
            if ([delegete respondsToSelector:@selector(onMediaConnectionOpen:)]) {
                [delegete onMediaConnectionOpen:self];
            }
        }
    }
}

- (void) notifyMediaConnectionCloseDelegate {
    for (id<RNSkyWayPeerDelegate> delegete in self.delegates) {
        if ([delegete conformsToProtocol:@protocol(RNSkyWayPeerDelegate)]) {
            if ([delegete respondsToSelector:@selector(onMediaConnectionClose:)]) {
                [delegete onMediaConnectionClose:self];
            }
        }
    }
}

- (void) notifyMediaConnectionErrorDelegate {
    for (id<RNSkyWayPeerDelegate> delegete in self.delegates) {
        if ([delegete conformsToProtocol:@protocol(RNSkyWayPeerDelegate)]) {
            if ([delegete respondsToSelector:@selector(onMediaConnectionError:)]) {
                [delegete onMediaConnectionError:self];
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
