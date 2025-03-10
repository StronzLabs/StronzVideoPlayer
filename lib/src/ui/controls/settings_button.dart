import 'package:flutter/material.dart';
import 'package:stronz_video_player/src/ui/controls/stronz_player_control.dart';
import 'package:stronz_video_player/src/data/player_preferences.dart';
import 'package:stronz_video_player/src/data/tracks.dart';
import 'package:stronz_video_player/src/logic/controller/stronz_player_controller.dart';

class SettingsButton extends StatefulWidget {
    final double iconSize;
    final void Function()? onOpened;
    final void Function()? onClosed;
    final void Function()? onFocus;
    final void Function()? onFocusLost;

    const SettingsButton({
        super.key,
        this.iconSize = 28,
        this.onOpened,
        this.onClosed,
        this.onFocus,
        this.onFocusLost,
    });

    @override
    State<SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<SettingsButton> with StronzPlayerControl {

    late final StronzPlayerController _controller = super.controller(super.context);
    final FocusNode _focusNode = FocusNode();

    @override
    void initState() {
        super.initState();
        this._focusNode.addListener(() {
            if (this._focusNode.hasFocus)
                super.widget.onFocus?.call();
            else
                super.widget.onFocusLost?.call();
        });
    }

    @override
    void setState(VoidCallback fn) {
        if (this.mounted)
            super.setState(fn);
    }

    @override
    Widget build(BuildContext context) {
        if(!this._controller.tracks.hasOptions)
            return const SizedBox.shrink();

        return IconButton(
            focusNode: this._focusNode,
            onPressed: () {
                super.widget.onOpened?.call();
                showDialog(
                    context: context,
                    barrierColor: Colors.transparent,
                    builder: (context) => Dialog(
                        backgroundColor: Colors.transparent,
                        alignment: Alignment.bottomRight,
                        insetPadding: const EdgeInsets.only(
                            right: 65,
                            bottom: 65,
                        ),
                        child: _SettingsMenu(
                            controller: this._controller,
                        ),
                    )
                ).then((value) => super.widget.onClosed?.call());
            },
            iconSize: super.widget.iconSize,
            icon: const Icon(Icons.settings),
        );
    }
}

class _SettingsMenu extends StatefulWidget {
    final StronzPlayerController controller;

    const _SettingsMenu({
        required this.controller,
    });

    @override
    State<_SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<_SettingsMenu> {

    int _activeSettingPage = 0;
    late final Map<int, Widget> _pages = {
        0: this._buildMainPage(),
        if(super.widget.controller.tracks.hasVideoTrackOptions)
            1: this._buildQualityPage(),
        if(super.widget.controller.tracks.hasAudioTrackOptions)
            2: this._buildLanguagePage(),
        if(super.widget.controller.tracks.hasCaptionsTrackOptions)
            3: this._buildCaptionPage(),
    };

    Widget _buildNavigationButton(String text, int id, [bool isBack = false]) {
        List<Widget> children = [
            Text(text),
            Icon(
                isBack ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                size: 17
            )
        ];
        return ListTile(
            title: Row(
                mainAxisAlignment: isBack ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
                children: isBack ? children.reversed.toList() : children,
            ),
            onTap: () => super.setState(() => this._activeSettingPage = id),
        );
    }

    Widget _buildOptionButton(String text, bool selected, void Function() onTap) {
        return ListTile(
            title: Row(
                children: [
                    Icon(Icons.check, size: 17, color: selected ? Colors.white : Colors.transparent),
                    const SizedBox(width: 10),
                    Text(text),
                ],
            ),
            onTap: () {
                onTap();
                Navigator.of(super.context).pop();
            },
        );
    }

    Widget _buildMainPage() {
        return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                const ListTile(title: Text("Impostazioni")),
                const Divider(),
                if (super.widget.controller.tracks.hasVideoTrackOptions)
                    this._buildNavigationButton("Qualità", 1),
                if (super.widget.controller.tracks.hasAudioTrackOptions)
                    this._buildNavigationButton("Lingua", 2),
                if (super.widget.controller.tracks.hasCaptionsTrackOptions)
                    this._buildNavigationButton("Sottotitoli", 3),
            ]
        );
    }

    Widget _buildQualityPage() {
        List<VideoTrack> tracks = (super.widget.controller.tracks as HLSTracks).video;

        return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                this._buildNavigationButton("Qualità", 0, true),
                const Divider(),
                for (VideoTrack track in tracks)
                    this._buildOptionButton("${track.quality}p", track == super.widget.controller.videoTrack,
                        () {
                            super.widget.controller.setVideoTrack(track);
                            PlayerPreferences.videoTrack = track.quality;
                            PlayerPreferences.instance.serialize();
                        }
                    )
            ]
        );
    }

    Widget _buildLanguagePage() {
        List<AudioTrack> tracks = (super.widget.controller.tracks as HLSTracks).audio;

        return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                this._buildNavigationButton("Lingua", 0, true),
                const Divider(),
                for (AudioTrack track in tracks)
                    this._buildOptionButton(track.language, track == super.widget.controller.audioTrack,
                        () {
                            super.widget.controller.setAudioTrack(track);
                            PlayerPreferences.audioTrack = track.language;
                            PlayerPreferences.instance.serialize();
                        } 
                    ),
            ],
        );
    }

    Widget _buildCaptionPage() {
        List<CaptionTrack> tracks = (super.widget.controller.tracks as HLSTracks).caption;

        return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                this._buildNavigationButton("Sottotitoli", 0, true),
                const Divider(),
                for (CaptionTrack track in tracks)
                    this._buildOptionButton(track.language, track == super.widget.controller.captionTrack,
                        () {
                            super.widget.controller.setCaptionTrack(track);
                            PlayerPreferences.captionTrack = track.language;
                            PlayerPreferences.instance.serialize();
                        }
                    ),
                this._buildOptionButton("Nessuno", null == super.widget.controller.captionTrack,
                    () {
                        super.widget.controller.setCaptionTrack(null);
                        PlayerPreferences.captionTrack = "Nessuno";
                        PlayerPreferences.instance.serialize();
                    }
                )
            ]
        );
    }

    @override
    Widget build(BuildContext context) {
        return Container(
            width: 200,
            decoration: BoxDecoration(
                color: const Color.fromARGB(200, 0, 0, 0),
                borderRadius: BorderRadius.circular(10),
            ),
            // TODO: maybe scroll just the inner content and not the title as well
            child: SingleChildScrollView(
                child: this._pages[this._activeSettingPage]
            )
        );
    }
}
