import QtQuick 2.0
import QtQml.Models 2.2
import "qrc:/scripts.js" as Scripts

Item {
    property bool check: false

    property int animationLenght: 200

    property bool firstPlacementActive: false
    property bool cellMoving: false
    property bool newCard: false // TODO: předělat na signals&slots
    property int rows: 9
    property int columns: 9
    property int cellHeight: height / rows
    property int cellWidth: width / columns

    property string lastDir: "none"
    property int lastIndex: -1

    property bool canDrop: false

    property bool placeCell: false;

    property int karma: 0

    property bool goodPlace: true


    id: playground
    anchors.fill: parent

    onKarmaChanged: console.log("karma", karma)
    onNewCardChanged: { // tento slot generuje nové karty do deckModel
        if(deckModel.count == 0) {
            // mark another card as added
            // potenciálně nekonečná smyčka
            while(true) {
                var randomIndex = (Math.random() * dataModel.data.length).toFixed(0);
                console.log(randomIndex)
                if(!dataModel.data[randomIndex].added) {
                    dataModel.data[randomIndex].added = true;
                    dataModel.data[randomIndex].hidden = false;
                    deckModel.append(dataModel.getItem(randomIndex))
                    playground.goodPlace = true
                    break;
                }
                else {
                    console.log("conflict detected")
                }
            }
        }
    }

    // nalezne první volnou pozici (hidden atribut je true a dosadí tam tu kartu)
    function setCard(inModel) {
        for(var index = 0; index < inModel.count; index++) {
            if(inModel.get(index).hidden) {
                inModel.set(index, deckModel.get(0));
                deckModel.clear();
                break;
            }
        }
    }

    onPlaceCellChanged: {
        if(lastDir === "right") {
            setCard(rightDeck);
        }
        else if(lastDir === "bottom") {
            setCard(bottomDeck);
        }
        else if(lastDir === "top") {
            setCard(topDeck);
        }
        else if(lastDir === "left") {
            setCard(leftDeck);
        }
        playground.check = !playground.check
    }
    ListModel {
        id: topDeck
    }

    ListModel {
        id: bottomDeck
    }

    ListModel {
        id: leftDeck
    }

    ListModel {
        id: rightDeck
    }

    ListModel {
        id: deckModel
    }
    // DECK
    ListView {
        property int cells: 1

        id: deckView
        x: cellWidth
        y: cellHeight
        width: cellWidth
        height: cellHeight
        interactive: false
        model: deckModel
        delegate: TramCell {
            movable: true
            onPressedChanged: {
                firstPlacementActive = pressed;
                if(!pressed && playground.karma) {
                    playground.placeCell = !playground.placeCell
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.width: 1
            border.color: "#70ff0000"
        }
    }

    // MIDDLE
    ListView {
        property int cells: 1

        ListModel {
            id: middleDeck

            // náhodné vybrání první karty
            Component.onCompleted: {
                var randomIndex = (Math.random() * dataModel.data.length).toFixed(0);//6
                dataModel.data[randomIndex].added = true;
                dataModel.data[randomIndex].hidden = false;
                middleDeck.append(dataModel.data[randomIndex])
            }
        }

        id: middle
        anchors.centerIn: parent
        width: parent.width / playground.columns
        height: parent.height / playground.rows

        interactive: false
        model: middleDeck
        delegate: TramCell {}
    }

    OneDirection {  // TOP
        id: topDir
        anchors.top: parent.top
        anchors.left: middle.left
        anchors.bottom: middle.top
        width: parent.width / playground.columns

        dir: "top"
        layourDir: Qt.LeftToRight
        layoutOrient: Qt.Vertical
        cells: (playground.rows - 1) / 2
        deck: topDeck
        verticalLayout: ListView.BottomToTop
    }

    OneDirection {  // BOTTOM
        id: bottomDir
        anchors.top: middle.bottom
        anchors.left: middle.left
        anchors.bottom: parent.bottom
        width: parent.width/ playground.columns

        dir: "bottom"
        layourDir: Qt.LeftToRight
        layoutOrient: Qt.Vertical
        cells: (playground.rows - 1) / 2
        deck: bottomDeck
    }

    OneDirection {  // LEFT
        id: leftDir
        anchors.top: middle.top
        anchors.right: middle.left
        anchors.left: parent.left
        height: parent.height / playground.rows

        dir: "left"
        layourDir: Qt.RightToLeft
        layoutOrient: Qt.Horizontal
        cells: (playground.columns - 1) / 2
        deck: leftDeck
    }

    OneDirection {  // RIGHT
        id: rightDir
        anchors.top: middle.top
        anchors.left: middle.right
        anchors.right: parent.right
        height: parent.height / playground.rows

        dir: "right"
        layourDir: Qt.LeftToRight
        layoutOrient: Qt.Horizontal
        cells: (playground.columns - 1) / 2
        deck: rightDeck
    }
}

