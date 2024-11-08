import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/country_auto_complete.dart';
import '../../common/view/icons.dart';
import '../../common/view/language_autocomplete.dart';
import '../../common/view/theme.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../settings/settings_model.dart';
import '../search_model.dart';

class PodcastSearchInputPrefix extends StatelessWidget with WatchItMixin {
  const PodcastSearchInputPrefix({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final usePodcastIndex =
        watchPropertyValue((SettingsModel m) => m.usePodcastIndex);
    final l10n = context.l10n;
    return IconButton(
      tooltip: usePodcastIndex ? l10n.language : l10n.country,
      onPressed: () => showDialog(
        context: context,
        builder: (context) => const LocationFilterDialog(),
      ),
      icon: Icon(Iconz.globe),
    );
  }
}

class LocationFilterDialog extends StatelessWidget {
  const LocationFilterDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      content: const LocationFilter(),
    );
  }
}

class LocationFilter extends StatelessWidget with WatchItMixin {
  const LocationFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryModel = di<LibraryModel>();
    final searchModel = di<SearchModel>();
    watchPropertyValue((LibraryModel m) => m.favLanguagesLength);
    watchPropertyValue((LibraryModel m) => m.favCountriesLength);
    final country = watchPropertyValue((SearchModel m) => m.country);

    void setCountry(Country? country) {
      searchModel.setCountry(country);
      if (country?.code != null) {
        libraryModel.setLastCountryCode(country!.code);
      }
    }

    final usePodcastIndex =
        watchPropertyValue((SettingsModel m) => m.usePodcastIndex);
    watchPropertyValue((LibraryModel m) => m.favLanguagesLength);
    watchPropertyValue((LibraryModel m) => m.favCountriesLength);
    final favLanguageCodes =
        watchPropertyValue((LibraryModel m) => m.favLanguageCodes);

    final language = watchPropertyValue((SearchModel m) => m.language);

    const width = 250.0;
    final height = chipHeight;

    return usePodcastIndex
        ? LanguageAutoComplete(
            autofocus: true,
            contentPadding: countryPillPadding,
            filled: language != null,
            isDense: true,
            width: width,
            height: height,
            value: language,
            favs: favLanguageCodes,
            addFav: (language) {
              if (language?.isoCode == null) return;
              libraryModel.addFavLanguageCode(language!.isoCode);
            },
            removeFav: (language) {
              if (language?.isoCode == null) return;
              libraryModel.removeFavLanguageCode(language!.isoCode);
            },
            onSelected: (language) {
              Navigator.of(context).pop();
              searchModel.setLanguage(language);
              if (language?.isoCode != null) {
                libraryModel.setLastLanguage(language!.isoCode);
              }
              searchModel.search();
            },
          )
        : CountryAutoComplete(
            autofocus: true,
            contentPadding: countryPillPadding,
            filled: true,
            isDense: true,
            width: width,
            height: height,
            countries: [
              ...[
                ...Country.values,
              ].where(
                (e) => libraryModel.favCountryCodes.contains(e.code) == true,
              ),
              ...[...Country.values].where(
                (e) => libraryModel.favCountryCodes.contains(e.code) == false,
              ),
            ]..remove(Country.none),
            onSelected: (country) {
              Navigator.of(context).pop();
              setCountry(country);
              searchModel.search();
            },
            value: country,
            addFav: (v) {
              if (country?.code == null) return;
              libraryModel.addFavCountryCode(v!.code);
            },
            removeFav: (v) {
              if (country?.code == null) return;
              libraryModel.removeFavCountryCode(v!.code);
            },
            favs: libraryModel.favCountryCodes,
          );
  }
}
