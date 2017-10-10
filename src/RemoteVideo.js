import React, { Component } from 'react';
import {
  requireNativeComponent
} from 'react-native';


const RemoteVideoNative = requireNativeComponent('SkyWayRemoteVideo', null);

export class RemoteVideo extends Component {

  render() {
    const newProps = {
      peerId: this.props.peer && this.props.peer.peerId,
    };

    return <RemoteVideoNative {...newProps} {...this.props} />;
  }
}
