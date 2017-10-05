package jp.micin.react.skyway;

public enum SkyWayPeerStatus {
  Disconnected(0),
  Connected(1),
  ;

  private final int status;

  private SkyWayPeerStatus(final int status) {
    this.status = status;
  }

  public int getInt() {
    return this.status;
  }
}
