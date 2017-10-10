#import "RNSkyWayRemoteVideoManager.h"
#import "RNSkyWayPeerManager.h"
#import "RNSkyWayPeer.h"

@interface RNSkyWayRemoteVideoView : UIView <RNSkyWayPeerDelegate>
@property (nonatomic, strong) RNSkyWayPeer *peer;
@property (nonatomic, strong) SKWVideo *remoteView;
@property (nonatomic, assign) BOOL rendering;
@property (nonatomic, assign) CGSize videoSize;
@end

@implementation RNSkyWayRemoteVideoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _remoteView = [[SKWVideo alloc] init];
        _rendering = NO;
        [self addSubview:_remoteView];
        [self setChangeVideoSizeCallback];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.remoteView.frame = self.bounds;
    
    CGFloat width = _videoSize.width, height = _videoSize.height;
    if (width <= 0 || height <= 0) {
    } else { // object-fit: cover
        CGFloat scaleFactor = (width / self.bounds.size.width) * (self.bounds.size.height / height);
        if (scaleFactor >= 1) {
            self.remoteView.transform = CGAffineTransformMakeScale(scaleFactor, 1);
        } else {
            self.remoteView.transform = CGAffineTransformMakeScale(1, 1 / scaleFactor);
        }
    }
    //TODO: object-fit: contain

    [self addRendererIfCan];
}

- (void)setChangeVideoSizeCallback {
    __weak RNSkyWayRemoteVideoView *weakSelf = self;
    [_remoteView setDidChangeVideoSizeCallback:^(CGSize size) {
        weakSelf.videoSize = size;
        [weakSelf dispatchAsyncSetNeedsLayout];
    }];
}

- (void)dispatchAsyncSetNeedsLayout {
    __weak UIView *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *strongSelf = weakSelf;
        [strongSelf setNeedsLayout];
    });
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
    RNSkyWayRemoteVideoView *v = [[RNSkyWayRemoteVideoView alloc] init];
    v.clipsToBounds = YES;
    return v;
}

RCT_CUSTOM_VIEW_PROPERTY(peerId, NSString, RNSkyWayRemoteVideoView) {
    
    RNSkyWayPeerManager *module = [self.bridge moduleForName:@"SkyWayPeerManager"];
    
    NSString* peerId = [RCTConvert NSString:json];
    RNSkyWayPeer *peer = [module peerById:peerId];
    
    view.peer = peer;
}



@end

