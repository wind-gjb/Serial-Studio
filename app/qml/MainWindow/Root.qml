/*
 * Copyright (c) 2020-2023 Alex Spataru <https://github.com/alex-spataru>
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

import QtCore
import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls

import "Panes" as Panes
import "../Widgets" as Widgets

Window {
  id: root
  minimumWidth: layout.implicitWidth + 32
  minimumHeight: layout.implicitHeight + 32
  title: qsTr("%1 - %2").arg(documentTitle).arg(Cpp_AppName)

  //
  // Custom properties
  //
  property int appLaunchCount: 0
  property bool isMaximized: false
  property string documentTitle: ""
  property bool firstValidFrame: false
  property bool automaticUpdates: false

  //
  // Global properties
  //
  readonly property bool setupVisible: setup.visible
  readonly property bool consoleVisible: terminal.visible
  readonly property bool dashboardVisible: dashboard.visible

  //
  // Toolbar functions aliases
  //
  function showSetup()     { toolbar.setupClicked()     }
  function showConsole()   { toolbar.consoleClicked()   }
  function showDashboard() { dbTimer.start() }

  //
  // Obtain document title
  //
  function updateDocumentTitle() {
    if (Cpp_JSON_Generator.operationMode == 1)
      documentTitle = qsTr("Device Defined Project")

    else if (Cpp_JSON_Generator.jsonMapFilename.length > 0)
      documentTitle = Cpp_Project_Model.title

    else
      documentTitle = qsTr("Empty Project")
  }

  //
  // Ensure that window is visible
  //
  function displayWindow() {
    if (root.isMaximized)
      root.showMaximized()

    else {
      if (root.x > Screen.desktopAvailableWidth - root.minimumWidth || root.x <= 0)
        root.x = (Screen.desktopAvailableWidth - root.minimumWidth) / 2
      if (root.y > Screen.desktopAvailableHeight - root.minimumHeight || root.y <= 0)
        root.y = (Screen.desktopAvailableHeight - root.minimumHeight) / 2
      if (root.width >= Screen.desktopAvailableWidth - 100)
        root.width = root.minimumWidth
      if (root.height >= Screen.desktopAvailableHeight - 100)
        root.height = root.minimumHeight

      root.showNormal()
    }
  }

  //
  // React to maximize/unmaximize event
  //
  onVisibilityChanged: {
    if (root.visible) {
      if (root.visibility === Window.Maximized)
        root.isMaximized = true

      else if (root.isMaximized && root.visibility !== Window.Minimized) {
        root.isMaximized = false
        root.width = root.minimumWidth
        root.height = root.minimumHeight
        root.x = (Screen.desktopAvailableWidth - root.minimumWidth) / 2
        root.y = (Screen.desktopAvailableHeight - root.minimumHeight) / 2
      }
    }
  }

  //
  // Wait a little before showing the dashboard to avoid UI glitches and/or
  // overloading the rendering engine
  //
  Timer {
    id: dbTimer
    interval: 500
    onTriggered: toolbar.dashboardClicked()
  }

  //
  // Update document title automatically
  //
  Connections {
    target: Cpp_JSON_Generator
    function onOperationModeChanged() {
      updateDocumentTitle()
    }

    function onJsonFileMapChanged() {
      updateDocumentTitle()
    }
  }

  //
  // Show console tab on serial disconnect
  //
  Connections {
    target: Cpp_UI_Dashboard
    function onDataReset() {
      setup.show()
      root.showConsole()
      root.firstValidFrame = false
    }
  }

  //
  // Hide console & device manager when we receive first valid frame
  //
  Connections {
    target: Cpp_UI_Dashboard

    function onUpdated()  {
      if (root.firstValidFrame)
        return

      if ((Cpp_IO_Manager.connected || Cpp_CSV_Player.isOpen) && Cpp_UI_Dashboard.frameValid()) {
        setup.hide()
        root.showDashboard()
        root.firstValidFrame = true
      }

      else {
        setup.show()
        root.showConsole()
        root.firstValidFrame = false
      }
    }
  }

  //
  // Close shortcut
  //
  Shortcut {
    sequences: [StandardKey.Close]
    onActivated: root.close()
  }

  //
  // Quit shortcut
  //
  Shortcut {
    sequences: [StandardKey.Quit]
    onActivated: root.close()
  }

  //
  // Loading code
  //
  Component.onCompleted: {
    // Increment app launch count
    ++appLaunchCount

    // Ensure that window size stays within minimum size
    if (width < minimumWidth)
      width = minimumWidth
    if (height < minimumHeight)
      height = minimumHeight

    // Show donations dialog every 15 launches
    if (root.appLaunchCount % 15 == 0 && !donateDialog.doNotShowAgain)
      donateDialog.showAutomatically()

    // Ask user if he/she wants to enable automatic updates
    if (root.appLaunchCount == 2 && Cpp_UpdaterEnabled) {
      if (Cpp_Misc_Utilities.askAutomaticUpdates()) {
        root.automaticUpdates = true
        Cpp_Updater.checkForUpdates(Cpp_AppUpdaterUrl)
      }

      else
        root.automaticUpdates = false
    }

    // Check for updates (if we are allowed)
    if (root.automaticUpdates && Cpp_UpdaterEnabled)
      Cpp_Updater.checkForUpdates(Cpp_AppUpdaterUrl)

    // Obtain document title from JSON project editor & display the window
    updateDocumentTitle()
    displayWindow()
  }

  //
  // Handle platform-specific window initialization code
  //
  onVisibleChanged: {
    if (visible)
      Cpp_NativeWindow.addWindow(root)
    else
      Cpp_NativeWindow.removeWindow(root)
  }

  //
  // Save settings
  //
  Settings {
    property alias ax: root.x
    property alias ay: root.y
    property alias aw: root.width
    property alias ah: root.height
    property alias am: root.isMaximized
    property alias appStatus: root.appLaunchCount
    property alias autoUpdater: root.automaticUpdates
  }

  //
  // Load user interface component
  //
  Page {
    anchors.fill: parent
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

    ColumnLayout {
      id: layout
      spacing: 0
      anchors.fill: parent

      //
      // Toolbar
      //
      Panes.Toolbar {
        z: 2
        id: toolbar
        Layout.fillWidth: true

        setupChecked: root.setupVisible
        consoleChecked: root.consoleVisible
        dashboardChecked: root.dashboardVisible
        onStructureClicked: dashboard.toggleStructureTree()
        onSetupClicked: setup.visible ? setup.hide() : setup.show()
        structureChecked: dashboard.structureVisible && Cpp_UI_Dashboard.available

        onDashboardClicked: {
          if (Cpp_UI_Dashboard.available) {
            consoleChecked = 0
            dashboardChecked = 1
            if (stack.currentItem != dashboard)
              stack.push(dashboard)
          }

          else
            root.showConsole()
        }

        onConsoleClicked: {
          consoleChecked = 1
          dashboardChecked = 0
          stack.pop()
        }
      }

      //
      // User interface
      //
      RowLayout {
        z: 1
        spacing: 0
        Layout.topMargin: -1
        Layout.minimumWidth: 640 + 344

        //
        // Dashboard + Console view
        //
        StackView {
          id: stack
          clip: true
          initialItem: terminal
          Layout.fillWidth: true
          Layout.fillHeight: true
          Layout.minimumWidth: 640
          Layout.minimumHeight: 480

          data: [
            Panes.Console {
              id: terminal
              visible: false
              width: parent.width
              height: parent.height
            },

            Panes.Dashboard {
              id: dashboard
              visible: false
              width: parent.width
              height: parent.height
            }
          ]
        }

        //
        // Panel border rectangle
        //
        Rectangle {
          z: 2
          width: 1
          visible: setup.visible
          Layout.fillHeight: true
          color: Cpp_ThemeManager.colors["setup_border"]

          Rectangle {
            width: 1
            height: 32
            anchors.top: parent.top
            anchors.left: parent.left
            color: Cpp_ThemeManager.colors["pane_caption_border"]
          }
        }

        //
        // Setup panel
        //
        Panes.Setup {
          id: setup
          Layout.fillHeight: true
          Layout.rightMargin: setupMargin
          Layout.minimumWidth: displayedWidth
          Layout.maximumWidth: displayedWidth
        }
      }
    }

    //
    // JSON project drop area
    //
    Widgets.JSONDropArea {
      anchors.fill: parent
      enabled: !Cpp_IO_Manager.connected
    }
  }
}