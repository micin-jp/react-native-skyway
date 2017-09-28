#import "RNSkyWayRemoteVideoManager.h"
#import "RNSkyWayPeerManager.h"
#import "RNSkyWayPeer.h"

@interface RNSkyWayRemoteVideoView : UIView <RNSkyWayPeerDelegate>
@property (nonatomic, strong) RNSkyWayPeer *peer;
@property (nonatomic, strong) SKWVideo *remoteView;
@end

@implementation RNSkyWayRemoteVideoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _remoteView = [[SKWVideo alloc] init];
        [self addSubview:_remoteView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.remoteView.frame = self.bounds;
    
    if (self.peer != nil) {
        if (self.peer.peerStatus == RNSkyWayPeerConnected) {
            [self.peer.remoteStream removeVideoRenderer:self.remoteView track:0];
            [self.peer.remoteStream addVideoRenderer:self.remoteView track:0];
        }
    }
}

- (void)setPeer:(RNSkyWayPeer *)peer {
    RNSkyWayPeer *oldPeer = self.peer;
    if (oldPeer != peer) {
        if (oldPeer) {
            [oldPeer.remoteStream removeVideoRenderer:_remoteView track:0];
        }
        
        _peer = peer;
        [_peer addDelegate:self];
        
        [self setNeedsLayout];
    }
}

-(void)onMediaConnection:(RNSkyWayPeer *)peer {
    [self.peer.remoteStream removeVideoRenderer:self.remoteView track:0];
    [self.peer.remoteStream addVideoRenderer:self.remoteView track:0];
}

@end



@implementation RNSkyWayRemoteVideoManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
    return [[RNSkyWayRemoteVideoView alloc] init];
}

RCT_CUSTOM_VIEW_PROPERTY(peerId, NSString, RNSkyWayRemoteVideoView) {
    
    RNSkyWayPeerManager *module = [self.bridge moduleForName:@"RNSkyWayPeerManager"];
    
    NSString* peerId = [RCTConvert NSString:json];
    RNSkyWayPeer *peer = [module peerById:peerId];
    
    view.peer = peer;
}



@end

