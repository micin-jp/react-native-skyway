
# react-native-skyway

## Getting started

`$ npm install react-native-skyway --save`

### Mostly automatic installation

`$ react-native link react-native-skyway`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-skyway` and add `RNSkyWay.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNSkyWay.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNSkyWayPackage;` to the imports at the top of the file
  - Add `new RNSkyWayPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-skyway'
  	project(':react-native-skyway').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-skyway/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-skyway')
  	```

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
    return <View style={style.container}>
      <SkyWay.LocalVideo style={styles.localVideo} peer={this.state.peer} />
      <SkyWay.RemoteVideo style={styles.remoteVideo} peer={this.state.peer} />
    </View>
  }
}

const styles = StyleSheet.create({
  ...
});

```


