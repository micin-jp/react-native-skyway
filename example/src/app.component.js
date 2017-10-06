import React, { Component } from 'react';
import {
  StyleSheet,
  Text,
  TextInput,
  TouchableHighlight, 
  View,
  Modal,
  Dimensions
} from 'react-native';
import SkyWay from 'react-native-skyway';

import config from '../config';
import { VideoComponent } from './video.component';
import { PeersListComponent } from './peers-list.component';

export class AppComponent extends Component {

  constructor(props) {
    super(props);

    this._onPressConnectPeer = this._onPressConnectPeer.bind(this);
    this._onSelectedPeer = this._onSelectedPeer.bind(this);
    this._onPeerOpen = this._onPeerOpen.bind(this);
    this._onPeerError = this._onPeerError.bind(this);
    this._onPeerDisconnected = this._onPeerDisconnected.bind(this);
    this._onPeerCall = this._onPeerCall.bind(this);

    this.state = {
      inputPeerId: '',
      peer: null,
      calling: false,
      otherPeers: [],
      statusText: texts.STATUS_NONE,
    };
  }

  componentWillUnmount() {
    this._disposePeer();
  }

  render() {
    return (
      <View style={styles.container}>
        {this._renderPeerIdInput()}
        {this._renderStatusText()}
        {this._renderPeersList()}
        {this._renderVideoModal()}
      </View>
    );
  }

  _connectPeer(peerId) {
    const options = {
      key: config.skyway.key,
      domain: config.skyway.domain,
      debug: 3
    };

    const peer = new SkyWay.Peer(peerId, options)
    peer.connect();
    peer.addEventListener('peer-open', this._onPeerOpen);
    peer.addEventListener('peer-error', this._onPeerError);
    peer.addEventListener('peer-disconnected', this._onPeerDisconnected);
    peer.addEventListener('peer-call', this._onPeerCall);

    this.setState({ peer });
  }

  _disposePeer() {
    if (this.state.peer) {

      const peer = this.state.peer;
      peer.dispose();

      this.setState({peer: null, otherPeers: []});
    }
  }

  _renderPeerIdInput() {
    return <View style={styles.peerIdInputContainer} key="peer-id-input">
      <TextInput
        editable={true}
        maxLength={40}
        style={styles.peerIdInputText}
        onChangeText={(text) => this.setState({inputPeerId: text})}
        ref="peerIdInput"
        placeholder="PeerId"
      />
      <TouchableHighlight
        underlayColor='rgba(0,0,0,0.1)'
        style={styles.peerIdInputButton}
        onPress={this._onPressConnectPeer}>
        <Text style={styles.peerIdInputButtonText}>Connect</Text>
      </TouchableHighlight>
    </View>
  }

  _renderStatusText() {
    return <Text style={styles.statusText}>{this.state.statusText}</Text>;
  }

  _renderPeersList() {
    return <View style={styles.peersListContainer} key="peers-list">
      <PeersListComponent peers={this.state.otherPeers} onSelectedPeer={this._onSelectedPeer} />
    </View>
  }

  _renderVideoModal() {
    const onClose = () => {
      this.setState({calling: false});
    };
    return <Modal
      animationType="slide"
      transparent={false}
      visible={this.state.calling}
      onRequestClose={onClose.bind(this)}
    >
      <VideoComponent peer={this.state.peer} onClose={onClose.bind(this)} />
    </Modal>;
  }


  _onPressConnectPeer() {
    const peerId = this.state.inputPeerId;
    if (!peerId || peerId.length === 0) {
      return;
    }

    this._disposePeer();
    this._connectPeer(peerId);

    this.refs['peerIdInput'].blur();
    this.setState({statusText: texts.STATUS_CONNECTING});
  }

  _onSelectedPeer(targetPeerId) {
    if (!this.state.peer) {
      return;
    }

    const peer = this.state.peer;
    peer.call(targetPeerId);
    this.setState({calling: true});
  }

  _onPeerOpen() {
    if (!this.state.peer) {
      return;
    }

    const currentPeer = this.state.peer;

    this.setState({statusText: texts.STATUS_FETCHING_PEERS});
    this.state.peer.listAllPeers((err, peers) => {
      if (err) {
        console.error(err);
        this.setState({statusText: texts.STATUS_ERROR});
        return;
      }

      this.setState({statusText: texts.STATUS_CONNECTED});
      this.setState({otherPeers: peers.filter(p => p !== currentPeer.peerId)});
    });
  }

  _onPeerError() {
    this.setState({statusText: texts.STATUS_ERROR});
  }

  _onPeerDisconnected() {
    this.setState({statusText: texts.STATUS_DISCONNECTED});
  }

  _onPeerCall() {
    this.setState({calling: true});
  }

}

const texts = {
  STATUS_NONE: '',
  STATUS_CONNECTED: 'Connected.',
  STATUS_CONNECTING: 'Connecting...',
  STATUS_DISCONNECTED: 'Disconnected.',
  STATUS_FETCHING_PEERS: 'Feching peers list...',
  STATUS_ERROR: 'Error.',
}

const STATUS_BAR_HEIGHT = 20;

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#ffffff',
    paddingTop: STATUS_BAR_HEIGHT,
  },
  statusText: {
    height: 20,
    fontSize: 12,
    paddingLeft: 5,
    paddingRight: 5,
  },
  peerIdInputContainer: {
    height: 60,
    margin: 10,
    flexDirection: 'row',
    alignSelf: 'stretch',
  },
  peerIdInputText: {
    flex: 1,
    borderBottomWidth: 1,
    borderBottomColor: '#bdbdbd',
    paddingLeft: 5,
    paddingRight: 5,
    margin: 5
  },
  peerIdInputButton: {
    width: 100,
    backgroundColor: '#03a9f4',
    borderRadius: 1,
    margin: 5,
  },
  peerIdInputButtonText: {
    flex: 1,
    marginTop: 12,
    fontSize: 18,
    textAlign: 'center',
    color: '#ffffff',
  },
  peersListContainer: {
    flex: 1,
    marginTop: 10,
    alignSelf: 'stretch',
  },
  localVideo: {
    width: 200,
    height: 300,
  }
});
