import React, { Component } from 'react';
import {
  requireNativeComponent
} from 'react-native';


const LocalVideoNative = requireNativeComponent('SkyWayLocalVideo', null);

export class LocalVideo extends Component {

  render() {
    const newProps = {
      peerId: this.props.peer && this.props.peer.peerId,
    };

    return <LocalVideoNative {...newProps} {...this.props} />;
  }
}
