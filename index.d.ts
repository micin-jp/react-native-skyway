import { Component } from 'react';

declare namespace SkyWay {

  export type PeerID = string;

  export class PeerOptions {
    key?: string;
    domain?: string;
    host?: string;
    port?: number;
    secure?: boolean;
    turn?: boolean;
    credential?: PeerCredential;
  }

  export class PeerCredential {
    ttl?: number;
    timestamp?: number;
    authToken: string;
  }

  export class MediaConstraints {
    cameraPosition?: CameraPosition;
    maxWidth?: number;
    minWidth?: number;
    maxHeight?: number;
    minHeight?: number;
    maxFrameRate?: number;
    minFrameRate?: number;
  }

  export enum CameraPosition {
    Unspecified = 0,
    Back = 1,
    Front = 2,
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
    constructor(peerId: PeerID, options?: PeerOptions, constraints?: MediaConstraints);
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
    switchCamera(): void;
  }

  interface LocalVideoProps {
    peer?: Peer | null;
    zOrderMediaOverlay?: boolean;
    zOrderOnTop?: boolean;
    style?: any;
  }

  export class LocalVideo extends Component<LocalVideoProps> {
  }

  interface RemoteVideoProps {
    peer?: Peer | null;
    zOrderMediaOverlay?: boolean,
    zOrderOnTop?: boolean,
    style?: any;
  }

  export class RemoteVideo extends Component<RemoteVideoProps> {
  }

}

export = SkyWay;