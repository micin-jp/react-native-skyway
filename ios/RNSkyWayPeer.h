//
//  RNSkyWayPeer.h
//  RNSkyWay
//
//  Created by Daichi Sakai on 2017/10/03.
//  Copyright © 2017年 Micin. All rights reserved.
//


#ifndef RNSkyWayPeer_h
#define RNSkyWayPeer_h

#import <React/RCTBridgeModule.h>
#import <SkyWay/SKWPeer.h>
#import "RNSkyWayPeerDelegate.h"

typedef NS_ENUM (NSUInteger, RNSkyWayPeerStatus) {
    RNSkyWayPeerDisconnected,
    RNSkyWayPeerConnected
};

typedef NS_ENUM (NSUInteger, RNSkyWayMediaConnectionStatus) {
    RNSkyWayMediaConnectionDisconnected,
    RNSkyWayMediaConnectionConnected
};


@interface RNSkyWayPeer : NSObject

@property (nonatomic, strong) NSString *peerId;
@property (nonatomic, strong) NSDictionary *options;

@property (nonatomic, strong) SKWPeer *peer;
@property (nonatomic, strong) SKWMediaStream *localStream;
@property (nonatomic, strong) SKWMediaStream *remoteStream;
@property (nonatomic, strong) SKWMediaConnection *mediaConnection;
@property (nonatomic, assign) RNSkyWayPeerStatus peerStatus;
@property (nonatomic, assign) RNSkyWayMediaConnectionStatus mediaConnectionStatus;

@property (nonatomic, strong) NSHashTable *delegates;


- (instancetype) initWithPeerId:(NSString *)peerId options: (NSDictionary *)options;
- (void) connect;
- (void) disconnect;
- (void) listAllPeers: (RCTResponseSenderBlock) callback;
- (void) call:(NSString *)peerId;
- (void) hangup;
- (void) addDelegate: (id<RNSkyWayPeerDelegate>) delegate;
- (void) removeDelegate: (id<RNSkyWayPeerDelegate>) delegate;

@end


#endif /* RNSkyWayPeer_h */
