import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/home/party/partyManager.dart';
import 'package:myapp/home/party/screens/SearchSong.dart';
import 'package:myapp/home/party/screens/ShowQRCode.dart';
import 'package:myapp/home/party/screens/SugestedSongs.dart';


class Dropdown extends ConsumerStatefulWidget {
  final bool isAdmin;

  Dropdown(this.isAdmin);

  @override
  ConsumerState<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends ConsumerState<Dropdown> {
  @override
  Widget build(BuildContext context) {
    List<MenuItem> list =
        widget.isAdmin ? MenuItems.adminItems : MenuItems.generalItems;
    double size = widget.isAdmin ? 100 : 62; //change this values
    final theme = Theme.of(context);
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        customButton: Icon(
          Icons.list,
          size: 32,
          color: theme.primaryColor,
        ),
        customItemsIndexes: widget.isAdmin ? [3] : [2],
        customItemsHeight: 8,
        items: [
          ...list.map(
            (item) => DropdownMenuItem<MenuItem>(
              value: item,
              child: MenuItems.buildItem(item),
            ),
          ),
        ],
        onChanged: (value) {
          MenuItems.onChanged(context, value as MenuItem, ref);
        },
        itemHeight: 48,
        itemPadding: const EdgeInsets.only(left: 16, right: 16),
        dropdownWidth: 160,
        dropdownPadding: const EdgeInsets.symmetric(vertical: 6),
        dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: theme.backgroundColor,
        ),
        dropdownElevation: 8,
        offset: const Offset(0, 8),
      ),
    );
  }
}

class MenuItem {
  final String text;
  // final IconData icon;

  const MenuItem({
    @required this.text,
    // @required this.icon,
  });
}

class MenuItems {
  static const List<MenuItem> generalItems = [leave, sugested, search];
  static const List<MenuItem> adminItems = [
    sugested,
    qrcode,
    // finish,
    search,
    leave
  ]; //TODO remove leave from this list

  static const leave = MenuItem(text: 'Leave Party');
  static const sugested = MenuItem(
    text: 'Sugested Songs',
  );

  static const qrcode = MenuItem(
    text: 'Show QRCode',
  );
  static const finish = MenuItem(
    text: 'Finish Party',
  );
  static const search = MenuItem(
    text: 'Search Song',
  );

  static Widget buildItem(MenuItem item) {
    return Text(
      item.text,
      style: const TextStyle(
        color: Colors.white,
      ),
    );
  }

  static onChanged(BuildContext context, MenuItem item, WidgetRef ref) {
    PartyManager partyManager = ref.read(partyManagerProvider);
    switch (item) {
      case MenuItems.leave:
        partyManager.partyStopped();
        break;
      case MenuItems.finish:
        partyManager.stopParty();
        break;
      case MenuItems.sugested:
        Navigator.pushNamed(context, SugestedSongs.route,
            arguments: partyManager.partyBloc.songs);
        break;
      case MenuItems.qrcode:
        Navigator.pushNamed(context, ShowQRCode.route,
            arguments: partyManager.partyBloc.uid);
        break;
      case MenuItems.search:
        Navigator.pushNamed(context, SearchSong.route);
        break;
    }
  }
}
