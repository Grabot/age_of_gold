import 'package:age_of_gold/age_of_gold.dart';
import 'package:flutter/material.dart';

import '../../../../util/render_objects.dart';
import 'guild_information.dart';


class GuildWindowOverviewNoGuildOverview extends StatefulWidget {

  final AgeOfGold game;
  final bool normalMode;
  final double overviewHeight;
  final double overviewWidth;
  final double fontSize;
  final GuildInformation guildInformation;

  const GuildWindowOverviewNoGuildOverview({
    required Key key,
    required this.game,
    required this.normalMode,
    required this.overviewHeight,
    required this.overviewWidth,
    required this.fontSize,
    required this.guildInformation,
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

  Widget notGuildOverviewTopContentNormal(String guildName) {
    return Row(
      children: [
        guildAvatarBox(
            200,
            225,
            widget.guildInformation.getGuildCrest()
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
    );
  }

  Widget notGuildOverviewTopContentMobile(String guildName) {
    return  Column(
      children: [
        guildAvatarBox(
            200,
            225,
            widget.guildInformation.getGuildCrest()
        ),
        SizedBox(
          height: 50,
          child: Column(
            children: [
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
        ),
      ],
    );
  }

  Widget noGuildOverviewContent() {
    String guildName = "Not part of a guild yet.";
    double remainingHeight = widget.overviewHeight-225;
    return Column(
      children: [
        widget.normalMode
            ? notGuildOverviewTopContentNormal(guildName)
            : notGuildOverviewTopContentMobile(guildName),
        remainingHeight > 0 ? SizedBox(height: widget.overviewHeight-225) : Container(),
      ]
    );
  }

  Widget noGuildOverview() {
    return SizedBox(
        height: widget.overviewHeight,
        width: widget.overviewWidth,
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
