import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../constants.dart';
import '../../library/library_model.dart';
import '../../search/search_model.dart';
import '../../search/search_type.dart';
import '../data/audio.dart';
import 'adaptive_container.dart';
import 'audio_page_header.dart';
import 'audio_page_type.dart';
import 'avatar_play_button.dart';
import 'header_bar.dart';
import 'no_search_result_page.dart';
import 'progress.dart';
import 'search_button.dart';
import 'sliver_audio_page_control_panel.dart';
import 'sliver_audio_tile_list.dart';
import 'theme.dart';

class SliverAudioPage extends StatelessWidget {
  const SliverAudioPage({
    super.key,
    required this.pageId,
    this.audios,
    required this.audioPageType,
    this.onPageSubTitleTab,
    this.onPageLabelTab,
    this.pageTitle,
    this.pageSubTitle,
    this.pageLabel,
    this.image,
    this.controlPanel,
    this.noSearchResultMessage,
    this.noSearchResultIcons,
    this.description,
  });

  final String pageId;
  final List<Audio>? audios;
  final AudioPageType audioPageType;

  final String? pageTitle;
  final String? pageSubTitle;
  final String? pageLabel;
  final Widget? image;
  final Widget? description;

  final void Function(String text)? onPageSubTitleTab;
  final void Function(String)? onPageLabelTab;

  final Widget? controlPanel;

  final Widget? noSearchResultMessage;
  final Widget? noSearchResultIcons;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: isMobile ? false : null,
      appBar: HeaderBar(
        adaptive: true,
        actions: [
          Padding(
            padding: appBarSingleActionSpacing,
            child: SearchButton(
              onPressed: () {
                di<LibraryModel>().push(pageId: kSearchPageId);
                final searchModel = di<SearchModel>();
                if (searchModel.audioType != AudioType.local) {
                  searchModel
                    ..setAudioType(AudioType.local)
                    ..setSearchType(SearchType.localTitle)
                    ..setSearchQuery(null)
                    ..search();
                }
              },
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return audios == null
              ? const Center(
                  child: Progress(),
                )
              : audios!.isEmpty
                  ? NoSearchResultPage(
                      message: noSearchResultMessage,
                      icon: noSearchResultIcons,
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: getAdaptiveHorizontalPadding(
                            constraints: constraints,
                            min: 40,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: AudioPageHeader(
                              title: pageTitle ?? pageId,
                              image: image,
                              subTitle: pageSubTitle,
                              label: pageLabel,
                              onLabelTab:
                                  audioPageType == AudioPageType.likedAudio
                                      ? null
                                      : onPageLabelTab,
                              onSubTitleTab: onPageSubTitleTab,
                              description: description,
                            ),
                          ),
                        ),
                        SliverAudioPageControlPanel(
                          controlPanel: controlPanel ??
                              AvatarPlayButton(
                                audios: audios ?? [],
                                pageId: pageId,
                              ),
                        ),
                        if (audios == null)
                          const SliverToBoxAdapter(
                            child: Center(
                              child: Progress(),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: getAdaptiveHorizontalPadding(
                              constraints: constraints,
                            ),
                            sliver: SliverAudioTileList(
                              audioPageType: audioPageType,
                              audios: audios!,
                              pageId: pageId,
                              onSubTitleTab: onPageLabelTab,
                            ),
                          ),
                      ],
                    );
        },
      ),
    );
  }
}
