
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
