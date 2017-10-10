import React, { Component } from 'react';
import PropTypes from 'prop-types'
import {
  requireNativeComponent
} from 'react-native';

import { Peer } from './Peer';

const LocalVideoNative = requireNativeComponent('SkyWayLocalVideo', null);

export class LocalVideo extends Component {

  render() {
    const newProps = {
      peerId: this.props.peer && this.props.peer.peerId,
    };

    return <LocalVideoNative {...newProps} {...this.props} />;
  }
}

LocalVideo.propTypes = {
  peer: PropTypes.instanceOf(Peer),
  zOrderMediaOverlay: PropTypes.bool,
  zOrderOnTop: PropTypes.bool,
};