#import "RNSkyWayRemoteVideoManager.h"
#import "RNSkyWayPeerManager.h"
#import "RNSkyWayPeer.h"

@interface RNSkyWayRemoteVideoView : UIView <RNSkyWayPeerDelegate>
@property (nonatomic, strong) RNSkyWayPeer *peer;
@property (nonatomic, strong) SKWVideo *remoteView;
@property (nonatomic, assign) BOOL rendering;
@end

@implementation RNSkyWayRemoteVideoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _remoteView = [[SKWVideo alloc] init];
        _rendering = NO;
        [self addSubview:_remoteView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.remoteView.frame = self.bounds;
    [self addRendererIfCan];
}

- (void)setPeer:(RNSkyWayPeer *)peer {
    RNSkyWayPeer *oldPeer = self.peer;
    if (oldPeer != peer) {
        if (oldPeer) {
            [oldPeer.remoteStream removeVideoRenderer:_remoteView track:0];
            [oldPeer removeDelegate:self];
            _rendering = NO;
        }
        
        _peer = peer;
        [_peer addDelegate:self];
        
        [self setNeedsLayout];
    }
}

-(void)addRendererIfCan {
    if (self.peer != nil) {
        if (self.peer.remoteStream != nil && !self.rendering) {
            [self.peer.remoteStream addVideoRenderer:self.remoteView track:0];
            _rendering = YES;
        }
    }
}

-(void)onRemoteStreamOpen:(RNSkyWayPeer *)peer {
    [self addRendererIfCan];
}

-(void)onRemoteStreamWillClose:(RNSkyWayPeer *)peer {
    [self.peer.remoteStream removeVideoRenderer:self.remoteView track:0];
    _rendering = NO;
}

@end



@implementation RNSkyWayRemoteVideoManager

RCT_EXPORT_MODULE(SkyWayRemoteVideo)

- (UIView *)view
{
    return [[RNSkyWayRemoteVideoView alloc] init];
}

RCT_CUSTOM_VIEW_PROPERTY(peerId, NSString, RNSkyWayRemoteVideoView) {
    
    RNSkyWayPeerManager *module = [self.bridge moduleForName:@"SkyWayPeerManager"];
    
    NSString* peerId = [RCTConvert NSString:json];
    RNSkyWayPeer *peer = [module peerById:peerId];
    
    view.peer = peer;
}



@end

