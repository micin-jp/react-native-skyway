package jp.micin.react.skyway;


public interface SkyWayPeerObserver {
  void onPeerOpen(SkyWayPeer peer);
  void onPeerCall(SkyWayPeer peer);
  void onPeerClose(SkyWayPeer peer);
  void onPeerDisconnected(SkyWayPeer peer);
  void onPeerError(SkyWayPeer peer);
  void onMediaConnection(SkyWayPeer peer);
  void onPeerStatusChange(SkyWayPeer peer);
  void onMediaConnectionStatusChange(SkyWayPeer peer);
}
