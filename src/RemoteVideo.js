import React, { Component } from 'react';
import {
  requireNativeComponent
} from 'react-native';


export const RNRemoteVideo = requireNativeComponent('RNSkyWayRemoteVideo', null);

export class RemoteVideo extends Component {

  render() {
    const newProps = {
      peerId: this.props.peer && this.props.peer.peerId,
    };

    return <RNRemoteVideo {...newProps} {...this.props} />;
  }
}
