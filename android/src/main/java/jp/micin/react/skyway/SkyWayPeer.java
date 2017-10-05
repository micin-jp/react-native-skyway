package jp.micin.react.skyway;


import android.content.Context;
import android.util.Log;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableNativeArray;

import org.json.JSONArray;

import java.util.ArrayList;

import io.skyway.Peer.Browser.MediaConstraints;
import io.skyway.Peer.Browser.MediaStream;
import io.skyway.Peer.Browser.Navigator;
import io.skyway.Peer.CallOption;
import io.skyway.Peer.MediaConnection;
import io.skyway.Peer.OnCallback;
import io.skyway.Peer.Peer;
import io.skyway.Peer.PeerError;
import io.skyway.Peer.PeerOption;




public class SkyWayPeer {

  static final String TAG = SkyWayPeer.class.getCanonicalName();

  private String peerId;
  private ReadableMap options;
  private Context context;

  private Peer peer;
  private MediaStream	localStream;
  private MediaStream	remoteStream;
  private MediaConnection	mediaConnection;

  private SkyWayPeerStatus peerStatus;

  private SkyWayMediaConnectionStatus mediaConnectionStatus;


  private ArrayList<SkyWayPeerObserver> observers;


  public String getPeerId() {
    return peerId;
  }

  public Peer getPeer() {
    return peer;
  }

  public MediaStream getLocalStream() {
    return localStream;
  }

  public MediaStream getRemoteStream() {
    return remoteStream;
  }

  public MediaConnection getMediaConnection() {
    return mediaConnection;
  }

  public SkyWayPeerStatus getPeerStatus() {
    return peerStatus;
  }

  public void setPeerStatus(SkyWayPeerStatus peerStatus) {
    if (this.peerStatus != peerStatus) {
      this.peerStatus = peerStatus;
      notifyOnPeerStatusChange();
    }
  }

  public SkyWayMediaConnectionStatus getMediaConnectionStatus() {
    return mediaConnectionStatus;
  }

  public void setMediaConnectionStatus(SkyWayMediaConnectionStatus mediaConnectionStatus) {
    if (this.mediaConnectionStatus != mediaConnectionStatus) {
      this.mediaConnectionStatus = mediaConnectionStatus;
      notifyOnMediaConnectionStatusChange();
    }
  }



  public SkyWayPeer(Context context, String peerId, ReadableMap options) {
    this.context = context;
    this.peerId = peerId;
    this.options = options;

    this.observers = new ArrayList<SkyWayPeerObserver>();
  }

  public void dispose() {
    disconnect();
    observers.removeAll(observers);
  }

  public void connect() {
    disconnect();

    PeerOption option = new PeerOption();
    option.key = options.getString("key");
    option.domain = options.getString("domain");
    option.debug = Peer.DebugLevelEnum.ALL_LOGS;

    peer = new Peer(context, peerId, option);
    peer.on(Peer.PeerEventEnum.OPEN, new OnCallback() {
      @Override
      public void onCallback(Object object) {
        Log.d(TAG, "Peer OnOpen");

        MediaConstraints constraints = new MediaConstraints();
        constraints.maxWidth = 960;
        constraints.maxHeight = 540;
        constraints.cameraPosition = MediaConstraints.CameraPositionEnum.FRONT;

        Navigator.initialize(peer);
        localStream = Navigator.getUserMedia(constraints);

        setPeerStatus(SkyWayPeerStatus.Connected);
        notifyOnPeerOpen();
      }
    });

    peer.on(Peer.PeerEventEnum.DISCONNECTED, new OnCallback() {
      @Override
      public void onCallback(Object object) {
        Log.d(TAG, "Peer OnDisconnected");

        setPeerStatus(SkyWayPeerStatus.Disconnected);
        notifyOnPeerDisconnected();
      }
    });

    peer.on(Peer.PeerEventEnum.CLOSE, new OnCallback()	{
      @Override
      public void onCallback(Object object) {
        Log.d(TAG, "Peer OnClose");

        notifyOnPeerClose();
      }
    });

    peer.on(Peer.PeerEventEnum.ERROR, new OnCallback() {
      @Override
      public void onCallback(Object object) {
        PeerError error = (PeerError) object;
        Log.d(TAG, "Peer OnError: " + error);

        notifyOnPeerError();
      }
    });

    peer.on(Peer.PeerEventEnum.CALL, new OnCallback() {
      @Override
      public void onCallback(Object object) {
        Log.d(TAG, "Peer OnCall");

        if (!(object instanceof MediaConnection)) {
          return;
        }

        mediaConnection = (MediaConnection) object;
        setMediaCallbacks();
        mediaConnection.answer(localStream);

        notifyOnPeerCall();
      }
    });

  }

  public void disconnect() {
    closeMediaConnection();
    closeRemoteStream();
    closeLocalStream();

    if (peer != null) {
      unsetPeerCallback();
      peer.disconnect();
      peer = null;
    }
  }

  public void listAllPeers(final Callback callback) {
    if (peer == null) {
      callback.invoke("Peer Disconnected", null);
      return;
    }

    peer.listAllPeers(new OnCallback() {
      @Override
      public void onCallback(Object object) {
        if (!(object instanceof JSONArray)) {
          callback.invoke(null, null);
          return;
        }

        JSONArray peersJson = (JSONArray) object;
        WritableArray peers = new WritableNativeArray();

        for (int i = 0; i < peersJson.length();  ++i) {
          try {
            String peerId = peersJson.getString(i);
            peers.pushString(peerId);
          } catch (Exception e) {
            Log.e(TAG, e.toString());
          }
        }

        callback.invoke(null, peers);
      }

    });
  }

  public void call(String targetPeerId) {
    if (peer == null) {
      return;
    }
    if (localStream == null) {
      return;
    }

    hangup();

    CallOption option = new CallOption();
    mediaConnection = peer.call(targetPeerId, localStream, option);
    if (mediaConnection != null) {
      this.setMediaCallbacks();
    }
  }

  public void hangup() {
    closeRemoteStream();
    closeMediaConnection();
  }


  private void closeLocalStream() {
    if (localStream == null) {
      return;
    }

    localStream.close();
    localStream = null;
  }

  private void closeRemoteStream() {
    if (remoteStream == null) {
      return;
    }

    remoteStream.close();
    remoteStream = null;
  }

  private void closeMediaConnection() {
    if (mediaConnection == null) {
      return;
    }

    unsetMediaCallbacks();
    mediaConnection.close();
    mediaConnection = null;
  }



  void setMediaCallbacks() {

    mediaConnection.on(MediaConnection.MediaEventEnum.STREAM, new OnCallback() {
      @Override
      public void onCallback(Object object) {
        Log.d(TAG, "MediaConnection Stream Open");

        remoteStream = (MediaStream) object;

        setMediaConnectionStatus(SkyWayMediaConnectionStatus.Connected);
        notifyOnMediaConnection();
      }
    });

    mediaConnection.on(MediaConnection.MediaEventEnum.ERROR, new OnCallback()	{
      @Override
      public void onCallback(Object object) {
        PeerError error = (PeerError) object;
        Log.d(TAG, "MediaConnection OnError: " + error);
      }
    });

    mediaConnection.on(MediaConnection.MediaEventEnum.CLOSE, new OnCallback() {
      @Override
      public void onCallback(Object o) {
        Log.d(TAG, "MediaConnection Close");
        setMediaConnectionStatus(SkyWayMediaConnectionStatus.Connected);
      }
    });
  }

  void unsetPeerCallback() {
    if(peer == null){
      return;
    }

    peer.on(Peer.PeerEventEnum.OPEN, null);
    peer.on(Peer.PeerEventEnum.CONNECTION, null);
    peer.on(Peer.PeerEventEnum.CALL, null);
    peer.on(Peer.PeerEventEnum.CLOSE, null);
    peer.on(Peer.PeerEventEnum.DISCONNECTED, null);
    peer.on(Peer.PeerEventEnum.ERROR, null);
  }

  void unsetMediaCallbacks() {
    if(null == mediaConnection){
      return;
    }

    mediaConnection.on(MediaConnection.MediaEventEnum.STREAM, null);
    mediaConnection.on(MediaConnection.MediaEventEnum.CLOSE, null);
    mediaConnection.on(MediaConnection.MediaEventEnum.ERROR, null);
  }

  public void addObserver(SkyWayPeerObserver observer) {
    if(!observers.contains(observer)) {
      observers.add(observer);
    }
  }

  public void removeObserver(SkyWayPeerObserver observer) {
    if(observers.contains(observer)) {
      observers.remove(observer);
    }
  }

  private void notifyOnPeerOpen() {
    for (SkyWayPeerObserver observer: observers) {
      observer.onPeerOpen(this);
    }
  }

  private void notifyOnPeerCall() {
    for (SkyWayPeerObserver observer: observers) {
      observer.onPeerCall(this);
    }
  }

  private void notifyOnPeerClose() {
    for (SkyWayPeerObserver observer: observers) {
      observer.onPeerClose(this);
    }
  }

  private void notifyOnPeerDisconnected() {
    for (SkyWayPeerObserver observer: observers) {
      observer.onPeerDisconnected(this);
    }
  }

  private void notifyOnPeerError() {
    for (SkyWayPeerObserver observer: observers) {
      observer.onPeerError(this);
    }
  }

  private void notifyOnMediaConnection() {
    for (SkyWayPeerObserver observer: observers) {
      observer.onMediaConnection(this);
    }
  }

  private void notifyOnPeerStatusChange() {
    for (SkyWayPeerObserver observer: observers) {
      observer.onPeerStatusChange(this);
    }
  }

  private void notifyOnMediaConnectionStatusChange() {
    for (SkyWayPeerObserver observer: observers) {
      observer.onMediaConnectionStatusChange(this);
    }
  }


}
