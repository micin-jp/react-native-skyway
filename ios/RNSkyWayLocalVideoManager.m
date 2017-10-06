#import "RNSkyWayLocalVideoManager.h"
#import "RNSkyWayPeerManager.h"
#import "RNSkyWayPeer.h"

@interface RNSkyWayLocalVideoView : UIView <RNSkyWayPeerDelegate>
@property (nonatomic, strong) RNSkyWayPeer *peer;
@property (nonatomic, strong) SKWVideo *localView;
@property (nonatomic, assign) BOOL rendering;

@end

@implementation RNSkyWayLocalVideoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _localView = [[SKWVideo alloc] init];
        _rendering = NO;
        [self addSubview:_localView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.localView.frame = self.bounds;
    [self addRendererIfCan];
}

- (void)setPeer:(RNSkyWayPeer *)peer {
    RNSkyWayPeer *oldPeer = self.peer;
    if (oldPeer != peer) {
        if (oldPeer) {
            [oldPeer.localStream removeVideoRenderer:_localView track:0];
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
        if (self.peer.localStream != nil && !self.rendering) {
            [self.peer.localStream addVideoRenderer:self.localView track:0];
            _rendering = YES;
        }
    }
}

-(void)onLocalStreamOpen:(RNSkyWayPeer *)peer {
    [self addRendererIfCan];
}

-(void)onLocalStreamWillClose:(RNSkyWayPeer *)peer {
    [self.peer.localStream removeVideoRenderer:self.localView track:0];
    _rendering = NO;
}

@end



@implementation RNSkyWayLocalVideoManager

RCT_EXPORT_MODULE(SkyWayLocalVideo)

- (UIView *)view
{
    return [[RNSkyWayLocalVideoView alloc] init];
}

RCT_CUSTOM_VIEW_PROPERTY(peerId, NSString, RNSkyWayLocalVideoView) {
    
    RNSkyWayPeerManager *module = [self.bridge moduleForName:@"SkyWayPeerManager"];
    
    NSString* peerId = [RCTConvert NSString:json];
    RNSkyWayPeer *peer = [module peerById:peerId];
    
    view.peer = peer;
}



@end
