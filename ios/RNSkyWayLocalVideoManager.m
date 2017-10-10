#import "RNSkyWayLocalVideoManager.h"
#import "RNSkyWayPeerManager.h"
#import "RNSkyWayPeer.h"

@interface RNSkyWayLocalVideoView : UIView <RNSkyWayPeerDelegate>
@property (nonatomic, strong) RNSkyWayPeer *peer;
@property (nonatomic, strong) SKWVideo *localView;
@property (nonatomic, assign) BOOL rendering;
@property (nonatomic, assign) CGSize videoSize;
@end

@implementation RNSkyWayLocalVideoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _localView = [[SKWVideo alloc] init];
        _rendering = NO;
        [self addSubview:_localView];
        [self setChangeVideoSizeCallback];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.localView.frame = self.bounds;
    // TODO
//    CGFloat width = _videoSize.width, height = _videoSize.height;
//    if (width <= 0 || height <= 0) {
//    } else { // object-fit: cover
//        CGFloat scaleFactor = (width / self.bounds.size.width) * (self.bounds.size.height / height);
//        if (scaleFactor >= 1) {
//            self.localView.transform = CGAffineTransformMakeScale(scaleFactor, 1);
//        } else {
//            self.localView.transform = CGAffineTransformMakeScale(1, 1 / scaleFactor);
//        }
//    }
    
    [self addRendererIfCan];
}

- (void)setChangeVideoSizeCallback {
    __weak RNSkyWayLocalVideoView *weakSelf = self;
    [_localView setDidChangeVideoSizeCallback:^(CGSize size) {
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
    RNSkyWayLocalVideoView *v = [[RNSkyWayLocalVideoView alloc] init];
    v.clipsToBounds = YES;
    return v;
}

RCT_CUSTOM_VIEW_PROPERTY(peerId, NSString, RNSkyWayLocalVideoView) {
    
    RNSkyWayPeerManager *module = [self.bridge moduleForName:@"SkyWayPeerManager"];
    
    NSString* peerId = [RCTConvert NSString:json];
    RNSkyWayPeer *peer = [module peerById:peerId];
    
    view.peer = peer;
}



@end
