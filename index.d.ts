import { Component } from 'react';

declare namespace SkyWay {

  export type PeerID = string;

  export class PeerOptions {
  }

  export class MediaConstraints {
  }

  export class PeerEvent extends Event {
  }

  export enum PeerStatus {
    Disconnected = 0,
    Connected = 1,
  }

  export enum MediaConnectionStatus {
    Disconnected = 0,
    Connected = 1,
  }

  export class Peer extends EventTarget {
    constructor(peerId: PeerID, options: PeerOptions, constraints: MediaConstraints);
    get peerId(): PeerID;
    get options(): PeerOptions;
    get constraints(): MediaConstraints;
    get peerStatus(): PeerStatus;
    get mediaConnectionStatus(): MediaConnectionStatus;
    dispose(): void;
    connect(): void;
    disconnect(): void;
    listAllPeers(callback: (peers: PeerID[]) => void): void;
    call(receiverPeerId: PeerID): void;
    answer(): void;
    hangup(): void;
  }

  interface LocalVideoProps {
    peer: Peer
    zOrderMediaOverlay: boolean,
    zOrderOnTop: boolean,
  }

  export class LocalVideo extends Component<LocalVideoProps> {
  }

  interface RemoteVideoProps {
    peer: Peer
    zOrderMediaOverlay: boolean,
    zOrderOnTop: boolean,
  }

  export class RemoteVideo extends Component<RemoteVideoProps> {
  }

}

export = SkyWay;