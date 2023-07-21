import 'package:age_of_gold/age_of_gold.dart';
import 'package:age_of_gold/util/render_objects.dart';
import 'package:age_of_gold/views/user_interface/ui_views/change_guild_crest_box/change_guild_crest_change_notifier.dart';
import 'package:flutter/material.dart';


class GuildWindowOverviewNoGuildOverview extends StatefulWidget {

  final AgeOfGold game;
  final bool normalMode;
  final double overviewHeight;
  final double overviewWidth;
  final double fontSize;
  final ChangeGuildCrestChangeNotifier changeGuildCrestChangeNotifier;

  const GuildWindowOverviewNoGuildOverview({
    required Key key,
    required this.game,
    required this.normalMode,
    required this.overviewHeight,
    required this.overviewWidth,
    required this.fontSize,
    required this.changeGuildCrestChangeNotifier,
  }) : super(key: key);

  @override
  GuildWindowOverviewNoGuildOverviewState createState() => GuildWindowOverviewNoGuildOverviewState();
}

class GuildWindowOverviewNoGuildOverviewState extends State<GuildWindowOverviewNoGuildOverview> {

  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
  }

  Widget noGuildOverviewContent() {
    String guildName = "Not part of a guild yet.";
    double remainingHeight = widget.overviewHeight-225;
    return Column(
      children: [
        Row(
          children: [
            guildAvatarBox(
                200,
                225,
                widget.changeGuildCrestChangeNotifier.getGuildCrest()
            ),
            Expanded(
              child: RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                      children: [
                        TextSpan(
                            text: guildName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold
                            )
                        )
                      ]
                  )
              ),
            ),
          ],
        ),
        remainingHeight > 0 ? SizedBox(height: widget.overviewHeight-225) : Container(),
      ]
    );
  }

  Widget noGuildOverview() {
    return SizedBox(
        height: widget.overviewHeight,
        child: SingleChildScrollView(
          child: noGuildOverviewContent(),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.center,
      child: noGuildOverview(),
    );
  }
}
