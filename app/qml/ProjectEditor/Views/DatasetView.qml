/*
 * Copyright (c) 2020-2024 Alex Spataru <https://github.com/alex-spataru>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import SerialStudio
import "../../Widgets" as Widgets

Widgets.Pane {
  id: root
  implicitWidth: 0
  implicitHeight: 0
  icon: Cpp_Project_Model.selectedIcon
  title: Cpp_Project_Model.selectedText

  //
  // User interface elements
  //
  Page {
    palette.mid: Cpp_ThemeManager.colors["mid"]
    palette.dark: Cpp_ThemeManager.colors["dark"]
    palette.text: Cpp_ThemeManager.colors["text"]
    palette.base: Cpp_ThemeManager.colors["base"]
    palette.link: Cpp_ThemeManager.colors["link"]
    palette.light: Cpp_ThemeManager.colors["light"]
    palette.window: Cpp_ThemeManager.colors["window"]
    palette.shadow: Cpp_ThemeManager.colors["shadow"]
    palette.accent: Cpp_ThemeManager.colors["accent"]
    palette.button: Cpp_ThemeManager.colors["button"]
    palette.midlight: Cpp_ThemeManager.colors["midlight"]
    palette.highlight: Cpp_ThemeManager.colors["highlight"]
    palette.windowText: Cpp_ThemeManager.colors["window_text"]
    palette.brightText: Cpp_ThemeManager.colors["bright_text"]
    palette.buttonText: Cpp_ThemeManager.colors["button_text"]
    palette.toolTipBase: Cpp_ThemeManager.colors["tooltip_base"]
    palette.toolTipText: Cpp_ThemeManager.colors["tooltip_text"]
    palette.linkVisited: Cpp_ThemeManager.colors["link_visited"]
    palette.alternateBase: Cpp_ThemeManager.colors["alternate_base"]
    palette.placeholderText: Cpp_ThemeManager.colors["placeholder_text"]
    palette.highlightedText: Cpp_ThemeManager.colors["highlighted_text"]

    anchors {
      fill: parent
      topMargin: -16
      leftMargin: -9
      rightMargin: -9
      bottomMargin: -10
    }

    //
    // Dataset actions panel
    //
    Rectangle {
      z: 2
      id: header
      height: 64
      color: Cpp_ThemeManager.colors["groupbox_background"]
      anchors {
        top: parent.top
        left: parent.left
        right: parent.right
      }

      //
      // Buttons
      //
      RowLayout {
        spacing: 4

        anchors {
          margins: 8
          left: parent.left
          right: parent.right
          verticalCenter: parent.verticalCenter
        }

        //
        // Add plot
        //
        Widgets.BigButton {
          icon.width: 24
          icon.height: 24
          checkable: true
          text: qsTr("Plot")
          toolbarButton: false
          Layout.alignment: Qt.AlignVCenter
          palette.buttonText: Cpp_ThemeManager.colors["button_text"]
          icon.source: "qrc:/rcc/icons/project-editor/actions/plot.svg"
          checked: Cpp_Project_Model.datasetOptions & ProjectModel.DatasetPlot
          onClicked: {
            const option = ProjectModel.DatasetPlot
            const value = Cpp_Project_Model.datasetOptions & option
            if (checked !== value)
              Cpp_Project_Model.changeDatasetOption(option, checked)
          }
        }

        //
        // Add FFT plot
        //
        Widgets.BigButton {
          icon.width: 24
          icon.height: 24
          checkable: true
          toolbarButton: false
          text: qsTr("FFT Plot")
          Layout.alignment: Qt.AlignVCenter
          palette.buttonText: Cpp_ThemeManager.colors["button_text"]
          icon.source: "qrc:/rcc/icons/project-editor/actions/fft.svg"
          checked: Cpp_Project_Model.datasetOptions & ProjectModel.DatasetFFT
          onClicked: {
            const option = ProjectModel.DatasetFFT
            const value = Cpp_Project_Model.datasetOptions & option
            if (checked !== value)
              Cpp_Project_Model.changeDatasetOption(option, checked)
          }
        }

        //
        // Add bar
        //
        Widgets.BigButton {
          icon.width: 24
          icon.height: 24
          checkable: true
          toolbarButton: false
          text: qsTr("Bar/Level")
          Layout.alignment: Qt.AlignVCenter
          palette.buttonText: Cpp_ThemeManager.colors["button_text"]
          icon.source: "qrc:/rcc/icons/project-editor/actions/bar.svg"
          checked: Cpp_Project_Model.datasetOptions & ProjectModel.DatasetBar
          onClicked: {
            const option = ProjectModel.DatasetBar
            const value = Cpp_Project_Model.datasetOptions & option
            if (checked !== value)
              Cpp_Project_Model.changeDatasetOption(option, checked)
          }
        }

        //
        // Add gauge
        //
        Widgets.BigButton {
          icon.width: 24
          icon.height: 24
          checkable: true
          text: qsTr("Gauge")
          toolbarButton: false
          Layout.alignment: Qt.AlignVCenter
          palette.buttonText: Cpp_ThemeManager.colors["button_text"]
          icon.source: "qrc:/rcc/icons/project-editor/actions/gauge.svg"
          checked: Cpp_Project_Model.datasetOptions & ProjectModel.DatasetGauge
          onClicked: {
            const option = ProjectModel.DatasetGauge
            const value = Cpp_Project_Model.datasetOptions & option
            if (checked !== value)
              Cpp_Project_Model.changeDatasetOption(option, checked)
          }
        }

        //
        // Add compass
        //
        Widgets.BigButton {
          icon.width: 24
          icon.height: 24
          checkable: true
          toolbarButton: false
          text: qsTr("Compass")
          Layout.alignment: Qt.AlignVCenter
          palette.buttonText: Cpp_ThemeManager.colors["button_text"]
          icon.source: "qrc:/rcc/icons/project-editor/actions/compass.svg"
          checked: Cpp_Project_Model.datasetOptions & ProjectModel.DatasetCompass
          onClicked: {
            const option = ProjectModel.DatasetCompass
            const value = Cpp_Project_Model.datasetOptions & option
            if (checked !== value)
              Cpp_Project_Model.changeDatasetOption(option, checked)
          }
        }

        //
        // Spacer
        //
        Item {
          Layout.fillWidth: true
        }

        //
        // Duplicate dataset
        //
        Widgets.BigButton {
          icon.width: 24
          icon.height: 24
          text: qsTr("Duplicate")
          Layout.alignment: Qt.AlignVCenter
          onClicked: Cpp_Project_Model.duplicateCurrentDataset()
          palette.buttonText: Cpp_ThemeManager.colors["button_text"]
          icon.source: "qrc:/rcc/icons/project-editor/actions/duplicate.svg"
        }

        //
        // Change group
        //
        Widgets.BigButton {
          icon.width: 24
          icon.height: 24
          text: qsTr("Change Group")
          Layout.alignment: Qt.AlignVCenter
          onClicked: Cpp_Project_Model.changeDatasetParentGroup()
          palette.buttonText: Cpp_ThemeManager.colors["button_text"]
          icon.source: "qrc:/rcc/icons/project-editor/actions/change-group.svg"
        }

        //
        // Delete dataset
        //
        Widgets.BigButton {
          icon.width: 24
          icon.height: 24
          text: qsTr("Delete")
          Layout.alignment: Qt.AlignVCenter
          onClicked: Cpp_Project_Model.deleteCurrentDataset()
          palette.buttonText: Cpp_ThemeManager.colors["button_text"]
          icon.source: "qrc:/rcc/icons/project-editor/actions/delete.svg"
        }
      }

      //
      // Bottom border
      //
      Rectangle {
        height: 1
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: Cpp_ThemeManager.colors["groupbox_border"]
      }
    }

    //
    // Dataset model editor
    //
    TableDelegate {
      anchors.fill: parent
      anchors.topMargin: header.height
      modelPointer: Cpp_Project_Model.datasetModel
    }
  }
}