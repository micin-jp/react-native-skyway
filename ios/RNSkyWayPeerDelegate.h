
#ifndef RNSkyWayPeerDelegate_h
#define RNSkyWayPeerDelegate_h

@class RNSkyWayPeer;

@protocol RNSkyWayPeerDelegate <NSObject>
@optional
-(void)onPeerOpen:(RNSkyWayPeer *)peer;
-(void)onPeerCall:(RNSkyWayPeer *)peer;
-(void)onPeerClose:(RNSkyWayPeer *)peer;
-(void)onPeerDisconnected:(RNSkyWayPeer *)peer;
-(void)onPeerError:(RNSkyWayPeer *)peer;
-(void)onLocalStreamOpen:(RNSkyWayPeer *)peer;
-(void)onLocalStreamWillClose:(RNSkyWayPeer *)peer;
-(void)onRemoteStreamOpen:(RNSkyWayPeer *)peer;
-(void)onRemoteStreamWillClose:(RNSkyWayPeer *)peer;
-(void)onMediaConnection:(RNSkyWayPeer *)peer;
-(void)onPeerStatusChange:(RNSkyWayPeer *)peer;
-(void)onMediaConnectionStatusChange:(RNSkyWayPeer *)peer;

@end

#endif /* RNSkyWayPeerDelegate_h */
