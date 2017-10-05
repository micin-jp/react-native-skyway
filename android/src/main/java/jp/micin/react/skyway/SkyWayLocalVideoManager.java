package jp.micin.react.skyway;


import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;


public class SkyWayLocalVideoManager extends SimpleViewManager<SkyWayLocalVideo> {

  private static final String REACT_CLASS = "SkyWayLocalVideo";
  private ThemedReactContext mContext;

  @Override
  public String getName() {
    return REACT_CLASS;
  }

  @Override
  public SkyWayLocalVideo createViewInstance(ThemedReactContext context) {
    mContext = context;
    return new SkyWayLocalVideo(context);
  }


  @ReactProp(name = "peerId")
  public void setPeerId(SkyWayLocalVideo view, String peerId) {
    SkyWayPeer peer;
    if (peerId == null) {
      peer = null;
    } else {
      SkyWayPeerManagerModule module = mContext.getNativeModule(SkyWayPeerManagerModule.class);
      peer = module.getPeerById(peerId);
    }

    view.setPeer(peer);
  }

}
