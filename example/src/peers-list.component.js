import React, { Component } from 'react';
import {
  StyleSheet,
  Image,
  Text,
  View,
  TouchableHighlight,
  ListView
} from 'react-native';

export class PeersListComponent extends Component {

  constructor(props) {
    super(props);

    this._renderRow = this._renderRow.bind(this);
    this._renderSeparator = this._renderSeparator.bind(this);

    this.dataSource = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
  }

  render() {
    const onReload = () => {
      this.props.onReload && this.props.onReload();
    };

    const dataSource = this.dataSource.cloneWithRows(this.props.peers);
    return (
      <View style={styles.container}>
        <Text style={styles.title}>Connected Peers</Text>
        <TouchableHighlight underlayColor='rgba(0,0,0,0)' onPress={onReload.bind(this)} style={styles.reloadTouch}>
          <Image source={require('./icons/ic_refresh.png')} style={styles.reloadImage} />
        </TouchableHighlight>
        <ListView
          enableEmptySections={true}
          dataSource={dataSource}
          renderRow={this._renderRow}
          renderSeparator={this._renderSeparator}
        />
      </View>
    );
  }

  _renderRow(rowData) {
    return <TouchableHighlight
        underlayColor='rgba(0,0,0,0.1)'
        style={styles.row}
        onPress={() => {
          this.props.onSelectedPeer && this.props.onSelectedPeer(rowData);
        }}>
      <Text style={styles.rowText}>{rowData}</Text>
    </TouchableHighlight>;
  }

  _renderSeparator() {
    return <View style={styles.seperator} />;
  }
}

const TOUCH_SIZE = 48;
const ICON_SIZE = 24;

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 10,
    borderTopColor: '#03a9f4',
    borderTopWidth: 1,
  },
  title: {
    fontWeight: '500',
    fontSize: 12,
    color: '#212121',
    height: TOUCH_SIZE,
    width: 200,
  },
  reloadTouch: {
    position: 'absolute',
    top: 0,
    right: 10,
    width: TOUCH_SIZE,
    height: TOUCH_SIZE,
    padding: (TOUCH_SIZE - ICON_SIZE) / 2,
  },
  reloadImage: {
    width: ICON_SIZE,
    height: ICON_SIZE,
  },
  row: {
    padding: 10,
  },
  rowText: {
    fontSize: 16,
  },
  seperator: {
    borderBottomWidth: 1,
    borderBottomColor: '#bdbdbd',
  },

});