/// Screen to display a full list of channels for a specific category
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/design_tokens.dart';
import '../../data/models/channel.dart';
import '../browse/widgets/channel_card.dart';
import '../player/player_screen.dart';

class CategoryScreen extends StatelessWidget {
  final String title;
  final List<Channel> channels;

  const CategoryScreen({
    super.key,
    required this.title,
    required this.channels,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.surface,
        scrolledUnderElevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columns for mobile, maybe more for tablet?
          childAspectRatio: 160 / 180, // Match typical card ratio
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: channels.length,
        itemBuilder: (context, index) {
          final channel = channels[index];
          return ChannelCard(
            channel: channel,
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PlayerScreen(channel: channel),
                  ),
                ).then((_) {
                  // Force portrait mode when returning
                  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
                  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                });
            },
          );
        },
      ),
    );
  }
}
