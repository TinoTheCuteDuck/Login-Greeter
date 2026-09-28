import QtQuick
import MainQML

Item {
    anchors.fill: parent

    Light {
        lightSize: 0.03 * screenScale
        xPosition: 0.1 * parent.width
        yPosition: 0.1 * parent.height
        lightColor: Colors.cyan
    }
    
    Light {
        lightSize: 0.05 * screenScale
        xPosition: 0.12 * parent.width
        yPosition: 0.7 * parent.height
        lightColor: Colors.magenta
    }

    Light {
        lightSize: 0.04 * screenScale
        xPosition: 0.8 * parent.width
        yPosition: 0.4 * parent.height
        lightColor: Colors.cyan
    }

    Light {
        lightSize: 0.04 * screenScale
        xPosition: 0.6 * parent.width
        yPosition: 0.6 * parent.height
        lightColor: Colors.magenta
    }

    Light {
        lightSize: 0.04 * screenScale
        xPosition: 0.6 * parent.width
        yPosition: 0.4 * parent.height
        lightColor: Colors.magenta
    }

    Light {
        lightSize: 0.04 * screenScale
        xPosition: 0.4 * parent.width
        yPosition: 0.4 * parent.height
        lightColor: Colors.cyan
    }
}