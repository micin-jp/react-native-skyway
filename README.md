
# react-native-skyway

## Instrallation

```
npm install react-native-skyway --save
react-native link react-native-skyway
```

### iOS

#### Installing SkyWay Package

Install SkyWay package via CocoaPods.

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

target 'example' do
  pod 'SkyWay'
  inherit! :search_paths
end
```

### Android

#### Installing SkyWay package

Add SkyWay aar package manually. Download the SDK from [SkyWay  Developers site](https://webrtc.ecl.ntt.com/en/android-sdk.html).

1. Open Android Studio.
2. Select `Open Module Settings` from the project view.
3. Add the downloaded SDK(`skyway.aar`) as a new module.

## Usage
```javascript

import React, { Component } from 'react';
import { View } from 'react-native';
import SkyWay from 'react-native-skyway';

class AppComponent extends Component {

  componentDidMount() {
    this._connectPeer();
  }

  componentWillUnmount() {
    this._disposePeer();
  }

  _connectPeer() {

    const peerId = 'PEER_ID_1';
    const targetPeerId = 'PEER_ID_2';

    const options = {
      key: 'YOUR_API_KEY',
      domain: 'YOUR_DOMAIN',
    };

    const peer = new SkyWay.Peer(peerId, options)
    peer.connect();
    peer.addEventListener('peer-open', () => {
      peer.call(targetPeerId);
    });

    this.setState({ peer });
  }

  _disposePeer() {
    if (this.state.peer) {

      const peer = this.state.peer;
      peer.dispose();

      this.setState({peer: null});
    }
  }

  render() {
    return <View style={styles.container}>
      <SkyWay.LocalVideo style={styles.localVideo} peer={this.state.peer} />
      <SkyWay.RemoteVideo style={styles.remoteVideo} peer={this.state.peer} />
    </View>
  }
}

const styles = StyleSheet.create({
  ...
});

```
