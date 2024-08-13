import '../../extensions/build_context_x.dart';
import 'icons.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';
import 'theme.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({super.key, this.onPressed, this.active, this.icon});

  final void Function()? onPressed;
  final bool? active;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return yaruStyled
        ? YaruSearchButton(
            searchActive: active,
            onPressed: onPressed,
            icon: icon,
            selectedIcon: icon,
          )
        : IconButton(
            isSelected: active,
            onPressed: onPressed,
            selectedIcon: icon ??
                Icon(
                  Iconz().search,
                  color: context.t.colorScheme.primary,
                ),
            icon: icon ?? Icon(Iconz().search),
          );
  }
}