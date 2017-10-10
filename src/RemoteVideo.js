import React, { Component } from 'react';
import PropTypes from 'prop-types'
import {
  requireNativeComponent
} from 'react-native';

import { Peer } from './Peer';

const RemoteVideoNative = requireNativeComponent('SkyWayRemoteVideo', null);

export class RemoteVideo extends Component {

  render() {
    const newProps = {
      peerId: this.props.peer && this.props.peer.peerId,
    };

    return <RemoteVideoNative {...newProps} {...this.props} />;
  }
}

RemoteVideo.propTypes = {
  peer: PropTypes.instanceOf(Peer),
  zOrderMediaOverlay: PropTypes.bool,
  zOrderOnTop: PropTypes.bool,
};
