package jp.micin.react.skyway;


public enum SkyWayMediaConnectionStatus {
  Disconnected(0),
  Connected(1),
  ;

  private final int status;

  private SkyWayMediaConnectionStatus(final int status) {
    this.status = status;
  }

  public int getInt() {
    return this.status;
  }
}
