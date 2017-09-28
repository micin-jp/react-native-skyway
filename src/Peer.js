import {NativeEventEmitter, NativeModules} from 'react-native';
import EventTarget from 'event-target-shim';


const {RNSkyWayPeerManager} = NativeModules;
const skyWayPeerEventEmitter = new NativeEventEmitter(RNSkyWayPeerManager);

const PeerStatus = {
  Disconnected: 0,
  Connected: 1,
};

const MediaConnectionStatus = {
  Disconnected: 0,
  Connected: 1,
};

export class PeerEvent {
  constructor(type, eventInitDict) {
    this.type = type.toString();
    Object.assign(this, eventInitDict);
  }
}

export class Peer extends EventTarget {

  constructor(peerId, options) {
    super();

    options = options || {};

    this.onPeerOpen = this.onPeerOpen.bind(this);
    this.onPeerCall = this.onPeerCall.bind(this);
    this.onPeerClose = this.onPeerClose.bind(this);
    this.onPeerDisconnected = this.onPeerDisconnected.bind(this);
    this.onPeerError = this.onPeerError.bind(this);
    this.onMediaConnection = this.onMediaConnection.bind(this);

    this._peerId = peerId;
    this._options = options;
    this._peerStatus = PeerStatus.Disconnected;
    this._mediaConnectionStatus = MediaConnectionStatus.Disconnected;
    this._disposed = false;

    this.init();
  }

  get peerId() {
    return this._peerId;
  }

  get options() {
    return this._options;
  }

  get peerStatus() {
    return this._peerStatus;
  }

  get mediaConnectionStatus() {
    return this._mediaConnectionStatus;
  }

  init() {
    RNSkyWayPeerManager.create(this._peerId, this._options);
    this.listen();
  }

  dispose() {
    RNSkyWayPeerManager.dispose(this._peerId);
    this.unlisten();

    this.disposed = true;
  }

  listen() {
    skyWayPeerEventEmitter.addListener('RNSkyWayPeerOpen', this.onPeerOpen);
    skyWayPeerEventEmitter.addListener('RNSkyWayPeerCall', this.onPeerCall);
    skyWayPeerEventEmitter.addListener('RNSkyWayPeerClose', this.onPeerClose);
    skyWayPeerEventEmitter.addListener('RNSkyWayPeerDisconnected', this.onPeerDisconnected);
    skyWayPeerEventEmitter.addListener('RNSkyWayPeerError', this.onPeerError);
    skyWayPeerEventEmitter.addListener('RNSkyWayMediaConnection', this.onMediaConnection);
  }

  unlisten() {
    skyWayPeerEventEmitter.removeListener('RNSkyWayPeerOpen', this.onPeerOpen);
    skyWayPeerEventEmitter.removeListener('RNSkyWayPeerCall', this.onPeerCall);
    skyWayPeerEventEmitter.removeListener('RNSkyWayPeerClose', this.onPeerClose);
    skyWayPeerEventEmitter.removeListener('RNSkyWayPeerDisconnected', this.onPeerDisconnected);
    skyWayPeerEventEmitter.removeListener('RNSkyWayPeerError', this.onPeerError);
    skyWayPeerEventEmitter.removeListener('RNSkyWayMediaConnection', this.onMediaConnection);
  }

  connect() {
    if (this.disposed) {
      return;
    }

    RNSkyWayPeerManager.connect(this.peerId);
  }

  disconnect() {
    if (this.disposed) {
      return;
    }

    RNSkyWayPeerManager.disconnect(this.peerId);
  }

  listAllPeers(callback) {
    if (this.disposed) {
      return;
    }
    RNSkyWayPeerManager.listAllPeers(this.peerId, callback);
  }

  call(targetPeerId) {
    if (this.disposed) {
      return;
    }

    RNSkyWayPeerManager.call(this.peerId, targetPeerId);
  }

  hangup() {
    if (this.disposed) {
      return;
    }

    RNSkyWayPeerManager.hangup(this.peerId);
  }

  onPeerOpen(payload) {
    if (payload.peer.id === this.peerId) {
      this.dispatchEvent(new PeerEvent('peer-open'));
    }
  }

  onPeerCall(payload) {
    if (payload.peer.id === this.peerId) {
      this.dispatchEvent(new PeerEvent('peer-call'));
    }
  }

  onPeerClose(payload) {
    if (payload.peer.id === this.peerId) {
      this.dispatchEvent(new PeerEvent('peer-close'));
    }
  }

  onPeerDisconnected(payload) {
    if (payload.peer.id === this.peerId) {
      this.dispatchEvent(new PeerEvent('peer-disconnected'));
    }
  }

  onPeerError(payload) {
    if (payload.peer.id === this.peerId) {
      this.dispatchEvent(new PeerEvent('peer-error'));
    }
  }

  onMediaConnection(payload) {
    if (payload.peer.id === this.peerId) {
      this.dispatchEvent(new PeerEvent('media-connection'));
    }
  }

  onPeerStatusChange(payload) {
    if (payload.peer.id === this.peerId) {
      this._peerStatus = this.payload.status;
      this.dispatchEvent(new PeerEvent('peer-status-change'));
    }
  }

  onMediaConnectionStatusChange(payload) {
    if (payload.peer.id === this.peerId) {
      this._mediaConnectionStatus = this.payload.status;
      this.dispatchEvent(new PeerEvent('media-connection-status-change'));
    }
  }

}

Peer.PeerStatus = PeerStatus;
Peer.MediaConnectionStatus = MediaConnectionStatus;