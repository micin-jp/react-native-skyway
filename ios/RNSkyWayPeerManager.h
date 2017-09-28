
#ifndef RNSkyWayPeerManager_h
#define RNSkyWayPeerManager_h

#import <React/RCTBridgeModule.h>
#import <React/RCTConvert.h>
#import <React/RCTEventEmitter.h>
#import "RNSkyWayPeer.h"

@interface RNSkyWayPeerManager : RCTEventEmitter <RCTBridgeModule, RNSkyWayPeerDelegate>

@property (nonatomic, strong) NSMutableDictionary<NSString *, RNSkyWayPeer *> *peers;

- (RNSkyWayPeer*)peerById:(NSString*)peerId;

@end

#endif /* RNSkyWayPeerManager_h */
