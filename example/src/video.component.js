import React, { Component } from 'react';
import {
  StyleSheet,
  View,
  Dimensions
} from 'react-native';
import SkyWay from 'react-native-skyway';

export class VideoComponent extends Component {

  constructor(props) {
    super(props);
  }

  render() {
    return (
      <View style={styles.container}>
        <SkyWay.LocalVideo style={styles.localVideo} peer={this.props.peer} />
        <SkyWay.RemoteVideo style={styles.remoteVideo} peer={this.props.peer} />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  localVideo: {
    position: 'absolute',
    width: 100,
    height: 160,
    bottom: 10,
    right: 10,
  },
  remoteVideo: {
    position: 'absolute',
    width: Dimensions.get('window').width,
    height: Dimensions.get('window').height,
    top: 0,
    left: 0,
  },
});