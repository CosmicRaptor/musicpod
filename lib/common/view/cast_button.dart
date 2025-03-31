import 'package:cast/device.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../cast/cast_service.dart';
import '../data/audio.dart';

class CastButton extends StatelessWidget {
  CastButton(
      {super.key, required this.active, this.audio, this.color, this.iconSize});
  final bool active;
  final Audio? audio;
  final Color? color;
  final double? iconSize;
  final castService = di<CastService>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CastDevice>>(
      future: castService.searchForDevices(),
      builder: (context, snapshot) {
        return PopupMenuButton<CastDevice>(
          icon: Icon(
            Icons.cast,
            color: color,
            size: iconSize,
          ),
          itemBuilder: (context) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return [
                const PopupMenuItem(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ];
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return [
                const PopupMenuItem(
                  child: Text('No devices found'),
                ),
              ];
            }

            return snapshot.data!
                .map(
                  (device) => PopupMenuItem<CastDevice>(
                    value: device,
                    child: ListTile(
                      leading: const Icon(Icons.tv),
                      title: Text(device.name),
                    ),
                  ),
                )
                .toList();
          },
          onSelected: (device) {
            // Handle device selection
            castService.connectAndPlayMedia(device, audio);
          },
        );
      },
    );
  }
}
