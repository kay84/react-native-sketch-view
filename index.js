
import React, { Component } from 'react'
import { PropTypes } from 'prop-types'
import {
  requireNativeComponent,
  ViewPropTypes,
  UIManager,
  findNodeHandle,
  DeviceEventEmitter,
  ColorPropType
} from 'react-native'

class SketchView extends Component {
  constructor (props) {
    super(props)
  }

  _onSketchViewEdited = (event) => {
    if (!this.props.onSketchViewEdited) {
      return
    }
    this.props.onSketchViewEdited(event.nativeEvent.edited)
  }

  _onExportSketch = (event) => {
    if (!this.props.onExportSketch) {
      return
    }
    this.props.onExportSketch({
      base64Encoded: event.nativeEvent.base64Encoded
    })
  }

  _onSaveSketch = (event) => {
    if (!this.props.onSaveSketch) {
      return
    }
    this.props.onSaveSketch({
      localFilePath: event.nativeEvent.localFilePath,
      imageWidth: event.nativeEvent.imageWidth,
      imageHeight: event.nativeEvent.imageHeight
    })
  }

  render () {
    return (
      <RNSketchView
        {... this.props}
        onSketchViewEdited={this._onSketchViewEdited}
        onSaveSketch={this._onSaveSketch}
        onExportSketch={this._onExportSketch}
        />
    )
  }

  clearSketch () {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      UIManager.RNSketchView.Commands.clearSketch,
      []
    )
  }

  loadSketch (path) {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      UIManager.RNSketchView.Commands.loadSketch,
      [path]
    )
  }

  saveSketch () {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      UIManager.RNSketchView.Commands.saveSketch,
      []
    )
  }

  exportSketch () {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      UIManager.RNSketchView.Commands.exportSketch,
      []
    )
  }

  changeTool (toolId) {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      UIManager.RNSketchView.Commands.changeTool,
      [toolId]
    )
  }

  setEdited (edited) {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      UIManager.RNSketchView.Commands.setEdited,
      [edited]
    )
  }
}

SketchView.constants = {
  toolType: {
    pen: {
      id: 0,
      name: 'Pen'
    },
    eraser: {
      id: 1,
      name: 'Eraser'
    }
  }
}

SketchView.propTypes = {
  ...ViewPropTypes, // include the default view properties
  selectedTool: PropTypes.number,
  toolColor: ColorPropType,
  toolThickness: PropTypes.number,
  localSourceImagePath: PropTypes.string
}

let RNSketchView = requireNativeComponent('RNSketchView', SketchView)

export default SketchView
