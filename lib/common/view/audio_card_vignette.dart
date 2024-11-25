import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';
import 'theme.dart';

class AudioCardVignette extends StatelessWidget {
  const AudioCardVignette({
    super.key,
    this.onTap,
    required this.iconData,
  });

  final void Function()? onTap;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    const borderRadius = BorderRadius.only(
      bottomLeft: Radius.circular(kYaruContainerRadius),
      topRight: Radius.circular(kYaruContainerRadius),
    );
    return Tooltip(
      message: context.l10n.unPinAlbum,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.inverseSurface,
            borderRadius: borderRadius,
          ),
          width: audioCardDimension / (isMobile ? 3 : 4),
          height: audioCardDimension / (isMobile ? 3 : 4),
          child: Icon(
            iconData,
            color: colorScheme.onInverseSurface,
          ),
        ),
      ),
    );
  }
}