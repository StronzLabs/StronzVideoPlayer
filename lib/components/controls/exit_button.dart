import 'package:flutter/material.dart';
import 'package:sutils/utils.dart';

class ExitButton extends StatelessWidget {
    final double iconSize;

    const ExitButton({
        super.key,
        this.iconSize = 28,
    });

    @override
    Widget build(BuildContext context) {
        return IconButton(
            icon: const Icon(Icons.arrow_back),
            iconSize: this.iconSize,
            onPressed: () async {
                if(await FullScreen.check())
                    await FullScreen.set(false);
                if (context.mounted)
                    Navigator.of(context).pop();
            },
        );
    }
}
