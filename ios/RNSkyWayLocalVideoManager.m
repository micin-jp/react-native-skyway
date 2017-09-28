#import "RNSkyWayLocalVideoManager.h"
#import "RNSkyWayPeerManager.h"
#import "RNSkyWayPeer.h"

@interface RNSkyWayLocalVideoView : UIView <RNSkyWayPeerDelegate>
@property (nonatomic, strong) RNSkyWayPeer *peer;
@property (nonatomic, strong) SKWVideo *localView;
@end

@implementation RNSkyWayLocalVideoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _localView = [[SKWVideo alloc] init];
        [self addSubview:_localView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.localView.frame = self.bounds;

    if (self.peer != nil) {
        if (self.peer.peerStatus == RNSkyWayPeerConnected) {
            [self.peer.localStream removeVideoRenderer:self.localView track:0];
            [self.peer.localStream addVideoRenderer:self.localView track:0];
        }
    }
}

- (void)setPeer:(RNSkyWayPeer *)peer {
    RNSkyWayPeer *oldPeer = self.peer;
    if (oldPeer != peer) {
        if (oldPeer) {
            [oldPeer.localStream removeVideoRenderer:_localView track:0];
        }

        _peer = peer;
        [_peer addDelegate:self];
        
        [self setNeedsLayout];
    }
}

-(void)onOpen:(RNSkyWayPeer *)peer {
    [self.peer.localStream removeVideoRenderer:self.localView track:0];
    [self.peer.localStream addVideoRenderer:self.localView track:0];
}

@end



@implementation RNSkyWayLocalVideoManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
    return [[RNSkyWayLocalVideoView alloc] init];
}

RCT_CUSTOM_VIEW_PROPERTY(peerId, NSString, RNSkyWayLocalVideoView) {
    
    RNSkyWayPeerManager *module = [self.bridge moduleForName:@"RNSkyWayPeerManager"];
    
    NSString* peerId = [RCTConvert NSString:json];
    RNSkyWayPeer *peer = [module peerById:peerId];
    
    view.peer = peer;
}



@end
