import QtQuick 2.0
import CMPlayerCore 1.0

Item {
	id: wrapper
	x: fontSize*0.5
	y: x
	width:box.width+x*2
	height:box.height+x*2
	property string fontFamily: Util.monospace
	readonly property int fontSize: parent.height*0.03;
	property var player
	property alias show: wrapper.visible
	onPlayerChanged: {
		if (player) {
			player.audioChanged.connect(audioinfo.update)
			player.videoChanged.connect(videoinfo.update)
			audioinfo.update(); videoinfo.update()
		}
	}
	onVisibleChanged: if (visible) bringIn.start()
	NumberAnimation {
		id: bringIn; target: view; properties: "scale"; running: false
		from: 0.0;	 to: 1.0; easing {type: Easing.OutBack; overshoot: 1.1}
	}
	visible: false
	Timer {
		id: timer
		running: (parent.visible && player)
		interval: 1000
		repeat: true
		onTriggered: { if (player) {timeinfo.update(); resources.update();} }
	}
	Rectangle {
		id: view
		anchors.fill: parent
		color: "darkgray"
		radius: fontSize*0.5
		opacity: 0.5
		Item {
			id: box
			anchors.top: parent.top
			anchors.left: parent.left
			anchors.topMargin: fontSize*0.5
			anchors.leftMargin: fontSize*0.5
			width: childrenRect.width
			height: childrenRect.height
			Text {
				id: medianame
				anchors.top: parent.top
				anchors.left: parent.left
				width: contentWidth
				height: contentHeight
				font.pixelSize: wrapper.fontSize
				font.family: wrapper.fontFamily
				color: "yellow"
				style: Text.Outline
				styleColor: "black"
				text: player ? player.media.name : ""
			}
			Text {
				id: timeinfo
				anchors.top: medianame.bottom
				anchors.left: parent.left
				width: contentWidth
				height: contentHeight
				font.pixelSize: wrapper.fontSize
				font.family: wrapper.fontFamily
				function update() {
					text = "[%1]%2/%3(%4%)"
					.arg(player.stateText)
					.arg(Util.msecToString(player.time))
					.arg(Util.msecToString(player.endTime))
					.arg((player.relativePosition*100.0).toFixed(1));
				}
				color: "yellow"
				style: Text.Outline
				styleColor: "black"
			}
			Text {
				id: speed
				anchors.top: timeinfo.bottom
				anchors.left: parent.left
				width: contentWidth
				height: contentHeight
				font.pixelSize: wrapper.fontSize
				font.family: wrapper.fontFamily
				color: "yellow"
				style: Text.Outline
				styleColor: "black"
				text: qsTr("Playback Speed: ×%1").arg((player ? player.speed : 1.0).toFixed(2));
			}
			Text {
				id: resources
				anchors.top: speed.bottom
				anchors.left: parent.left
				anchors.topMargin: wrapper.fontSize
				width: contentWidth
				height: contentHeight
				font.pixelSize: wrapper.fontSize
				font.family: wrapper.fontFamily
				function update() {
					var cpu = Util.cpu; var mem = Util.memory; var fps = player.avgfps;
					var txt = qsTr("CPU Usage: %1%(avg. %2%/core)")
						.arg(cpu.toFixed(1))
						.arg((cpu/Util.cores).toFixed(1));
					txt += '\n';
					txt += qsTr("RAM Usage: %3MB(%4% of %5GB)")
						.arg(mem.toFixed(1))
						.arg((mem/Util.totalMemory*100.0).toFixed(1))
						.arg((Util.totalMemory/1024.0).toFixed(2));
					txt += '\n';
					txt += qsTr("Audio/Video Sync: %6ms").arg(player.avgsync.toFixed(1));
					txt += '\n';
					txt += qsTr("Avg. Frame Rate: %7fps(%8MB/s)")
						.arg(fps.toFixed(3)).arg((player.bps(fps)/(8*1024*1024)).toFixed(2));
					txt += '\n';
					txt += qsTr("Volume Normalizer: %1")
						.arg(player.volumeNormalizerActivated ? ((player.volumeNormalizer*100.0).toFixed(1) + "%") : qsTr("Inactivated"));
					text = txt;
				}
				color: "yellow"
				style: Text.Outline
				styleColor: "black"
			}
			Text {
				id: videoinfo
				anchors.top: resources.bottom
				anchors.left: parent.left
				anchors.topMargin: wrapper.fontSize
				width: contentWidth
				height: contentHeight
				font.pixelSize: wrapper.fontSize
				font.family: wrapper.fontFamily
				function update() {
					var txt = qsTr("Video Codec: %1").arg(player.video.codec);
					txt += '\n';
					txt += qsTr("Input : %1 %2x%3 %4fps(%5MB/s)")
						.arg(player.video.input.type)
						.arg(player.video.input.size.width)
						.arg(player.video.input.size.height)
						.arg(player.video.input.fps.toFixed(3))
						.arg((player.video.input.bps/(8*1024*1024)).toFixed(2));
					txt += '\n';
					txt += qsTr("Output: %1 %2x%3 %4fps(%5MB/s)")
						.arg(player.video.output.type)
						.arg(player.video.output.size.width)
						.arg(player.video.output.size.height)
						.arg(player.video.output.fps.toFixed(3))
						.arg((player.video.output.bps/(8*1024*1024)).toFixed(2));
					txt += '\n';
					txt += qsTr("Hardware Acceleration: %1").arg(player.video.hardwareAccelerationText);
					text = txt
				}
				color: "yellow"
				style: Text.Outline
				styleColor: "black"
			}

			Text {
				id: audioinfo
				anchors.top: videoinfo.bottom
				anchors.left: parent.left
				anchors.topMargin: wrapper.fontSize
				width: contentWidth
				height: contentHeight
				font.pixelSize: wrapper.fontSize
				font.family: wrapper.fontFamily
				function update() {
					var txt = qsTr("Audio Codec: %1").arg(player.audio.codec);
					txt += '\n';
					txt += qsTr("Input : %1 %2kbps %3kHz %4ch %5bits")
						.arg(player.audio.input.type)
						.arg((player.audio.input.bps*1e-3).toFixed(0))
						.arg(player.audio.input.samplerate)
						.arg(player.audio.input.channels)
						.arg(player.audio.input.bits);
					txt += '\n';
					txt += qsTr("Output: %1 %2kbps %3kHz %4ch %5bits")
						.arg(player.audio.output.type)
						.arg((player.audio.output.bps*1e-3).toFixed(0))
						.arg(player.audio.output.samplerate)
						.arg(player.audio.output.channels)
						.arg(player.audio.output.bits);
                    txt += '\n';
                    txt += qsTr("Output Driver: %1").arg(player.audio.audioDriverText);
					text = txt
				}
				color: "yellow"
				style: Text.Outline
				styleColor: "black"
			}
		}
	}
}
