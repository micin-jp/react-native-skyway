package jp.micin.react.skyway;


import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;


public class SkyWayRemoteVideoManager extends SimpleViewManager<SkyWayRemoteVideo> {

  private static final String REACT_CLASS = "SkyWayRemoteVideo";
  private ThemedReactContext mContext;

  @Override
  public String getName() {
    return REACT_CLASS;
  }

  @Override
  public SkyWayRemoteVideo createViewInstance(ThemedReactContext context) {
    mContext = context;
    return new SkyWayRemoteVideo(context);
  }


  @ReactProp(name = "peerId")
  public void setPeerId(SkyWayRemoteVideo view, String peerId) {
    SkyWayPeer peer;
    if (peerId == null) {
      peer = null;
    } else {
      SkyWayPeerManagerModule module = mContext.getNativeModule(SkyWayPeerManagerModule.class);
      peer = module.getPeerById(peerId);
    }

    view.setPeer(peer);
  }


  @ReactProp(name = "zOrderMediaOverlay")
  public void setZOrderMediaOverlay(SkyWayLocalVideo view, boolean isMediaOverlay) {
    view.setZOrderMediaOverlay(isMediaOverlay);
  }

  @ReactProp(name = "zOrderOnTop")
  public void setZOrderOnTop(SkyWayLocalVideo view, boolean onTop) {
    view.setZOrderOnTop(onTop);
  }

}
