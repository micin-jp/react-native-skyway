import React, { Component } from 'react';
import {
  StyleSheet,
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
    const dataSource = this.dataSource.cloneWithRows(this.props.peers);
    return (
      <View style={styles.container}>
        <Text style={styles.title}>Connected Peers</Text>
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
    color: '#212121'
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
  }

});