package jp.micin.react.skyway;

import android.content.Context;
import android.view.View;

import io.skyway.Peer.Browser.Canvas;

public class SkyWayRemoteVideo extends Canvas implements SkyWayPeerObserver {

  private SkyWayPeer peer;
  private boolean rendering;

  public SkyWayRemoteVideo(Context context) {
    super(context);

    rendering = false;
  }

  public void setPeer(SkyWayPeer peer) {
    SkyWayPeer oldPeer = this.peer;
    if (oldPeer != peer) {
      if (oldPeer != null ) {
        if (oldPeer.getRemoteStream() != null) {
          oldPeer.getRemoteStream().removeVideoRenderer(this, 0);
          rendering = false;
        }
        oldPeer.removeObserver(this);
      }

      this.peer = peer;
      this.peer.addObserver(this);

      addRendererIfCan();
    }
  }

  @Override
  protected void onDetachedFromWindow() {
    if (peer != null ) {
      if (peer.getRemoteStream() != null) {
        peer.getRemoteStream().removeVideoRenderer(this, 0);
        rendering = false;
      }
      peer.removeObserver(this);
    }

    super.onDetachedFromWindow();
  }

  @Override
  public void onRemoteStreamOpen(SkyWayPeer peer) {
    addRendererIfCan();
    relayout();
  }

  @Override
  public void onRemoteStreamWillClose(SkyWayPeer _peer) {
    if (peer != null && peer.getRemoteStream() != null) {
      peer.getRemoteStream().removeVideoRenderer(this, 0);
      rendering = false;
    }
  }

  private void addRendererIfCan() {
    if (!rendering && peer != null && peer.getRemoteStream() != null) {
      peer.getRemoteStream().addVideoRenderer(this, 0);
      rendering = true;
    }
  }

  private void relayout() {
    measure(
            View.MeasureSpec.makeMeasureSpec(getMeasuredWidth(), View.MeasureSpec.EXACTLY),
            View.MeasureSpec.makeMeasureSpec(getMeasuredHeight(), View.MeasureSpec.EXACTLY));
    layout(this.getLeft(), this.getTop(), this.getRight(), this.getBottom());
  }

  @Override
  public void onPeerOpen(SkyWayPeer peer) {}
  @Override
  public void onPeerCall(SkyWayPeer peer) {}
  @Override
  public void onPeerClose(SkyWayPeer peer) {}
  @Override
  public void onPeerDisconnected(SkyWayPeer peer) {}
  @Override
  public void onPeerError(SkyWayPeer peer) {}

  @Override
  public void onLocalStreamOpen(SkyWayPeer peer) {}
  @Override
  public void onLocalStreamWillClose(SkyWayPeer peer) {}

  @Override
  public void onMediaConnection(SkyWayPeer peer) {}

  @Override
  public void onPeerStatusChange(SkyWayPeer peer) {}
  @Override
  public void onMediaConnectionStatusChange(SkyWayPeer peer) {}

}
