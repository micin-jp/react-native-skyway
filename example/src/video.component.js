import React, { Component } from 'react';
import {
  StyleSheet,
  View,
  Image,
  TouchableHighlight,
  StatusBar,
  Dimensions,
} from 'react-native';
import SkyWay from 'react-native-skyway';

export class VideoComponent extends Component {

  constructor(props) {
    super(props);

    this._onClose = this._onClose.bind(this);
  }

  render() {
    return (
      <View style={styles.container}>
        <StatusBar backgroundColor="#03a9f4" barStyle="light-content" />
        <View style={styles.header}>
          <View style={styles.headerLeftButton}>
            <TouchableHighlight underlayColor='rgba(0,0,0,0)' onPress={this._onClose} style={styles.headerLeftButtonTouch}>
              <Image source={require('./icons/ic_close_white.png')} style={styles.headerLeftButtonImage} />
            </TouchableHighlight>
          </View>
        </View>
        <View style={styles.videos}>
          <View style={styles.remoteVideoFrame}>
            <SkyWay.RemoteVideo style={styles.remoteVideo} peer={this.props.peer} />
          </View>
          <View style={styles.localVideoFrame}>
            <SkyWay.LocalVideo style={styles.localVideo} peer={this.props.peer} zOrderOnTop={true}/>
          </View>
        </View>
      </View>
    );
  }

  _onClose() {
    if (this.props.onClose) {
      this.props.onClose();
    }
  }
}


const STATUS_BAR_HEIGHT = 20;
const HEADER_HEIGHT = 56;
const TOUCH_SIZE = 48;
const ICON_SIZE = 24;

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    height: HEADER_HEIGHT + STATUS_BAR_HEIGHT,
    maxHeight: HEADER_HEIGHT + STATUS_BAR_HEIGHT,
    backgroundColor: '#03a9f4',
  },
  headerLeftButton: {
    position: 'absolute',
    top: (HEADER_HEIGHT - TOUCH_SIZE) / 2 + STATUS_BAR_HEIGHT,
    left: 0,
    width: TOUCH_SIZE,
    height: TOUCH_SIZE,
  },
  headerLeftButtonTouch: {
    width: TOUCH_SIZE,
    height: TOUCH_SIZE,
    padding: (TOUCH_SIZE - ICON_SIZE) / 2,
  },
  headerLeftButtonImage: {
    width: ICON_SIZE,
    height: ICON_SIZE,
  },
  videos: {
    flex: 1,
  },
  localVideoFrame: {
    position: 'absolute',
    width: 100,
    height: 100 * 1.3333,
    bottom: 10,
    right: 10,
  },
  localVideo: {
    flex: 1,
  },
  remoteVideoFrame: {
    position: 'absolute',
    width: Dimensions.get('window').width,
    height: Dimensions.get('window').height - (HEADER_HEIGHT + STATUS_BAR_HEIGHT),
    top: 0,
    left: 0,
  },
  remoteVideo: {
    flex: 1,
  },
});