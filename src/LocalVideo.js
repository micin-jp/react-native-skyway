import React, { Component } from 'react';
import {
  requireNativeComponent
} from 'react-native';


export const RNLocalVideo = requireNativeComponent('RNSkyWayLocalVideo', null);

export class LocalVideo extends Component {

  render() {
    const newProps = {
      peerId: this.props.peer && this.props.peer.peerId,
    };

    return <RNLocalVideo {...newProps} {...this.props} />;
  }
}
