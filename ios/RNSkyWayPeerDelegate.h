//
//  RNSkyWayPeerDelegate.h
//  RNSkyWay
//
//  Created by Daichi Sakai on 2017/10/03.
//  Copyright © 2017年 Micin. All rights reserved.
//

#ifndef RNSkyWayPeerDelegate_h
#define RNSkyWayPeerDelegate_h

@class RNSkyWayPeer;

@protocol RNSkyWayPeerDelegate <NSObject>
@optional
-(void)onOpen:(RNSkyWayPeer *)peer;
-(void)onCall:(RNSkyWayPeer *)peer;
-(void)onClose:(RNSkyWayPeer *)peer;
-(void)onDisconnected:(RNSkyWayPeer *)peer;
-(void)onError:(RNSkyWayPeer *)peer;
-(void)onMediaConnection:(RNSkyWayPeer *)peer;
-(void)onPeerStatusChange:(RNSkyWayPeer *)peer;
-(void)onMediaConnectionStatusChange:(RNSkyWayPeer *)peer;

@end

#endif /* RNSkyWayPeerDelegate_h */
