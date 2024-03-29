import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_appwrite_starter/src/api_service/api_service.dart';
import 'package:flutter_appwrite_starter/src/api_service/constants.dart';
import 'package:flutter_appwrite_starter/src/components/avatar.dart';
import 'package:flutter_appwrite_starter/src/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import 'edit_profile.dart';

class UserProfile extends StatelessWidget {
  static String name = 'profile';
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final authState = ref.watch(authProvider);
      final authNotifier = ref.read(authProvider.notifier);
      final user = authState.user;
      final prefs = user?.prefs.data ?? {};
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).profilePageTitle),
        ),
        body: ListView(
          padding: const EdgeInsets.all(8.0),
          children: <Widget>[
            if (user != null) ...[
              FutureBuilder(
                  future: prefs['photoId'] != null
                      ? ApiService.instance.getImageAvatar(
                          ApiConstants.profileBucketId, prefs['photoId']!)
                      : ApiService.instance.getAvatar(user.name),
                  builder: (context, AsyncSnapshot<Uint8List> snapshot) {
                    return Center(
                      child: Avatar(
                        onButtonPressed: () {},
                        radius: 50,
                        image: (prefs['photoUrl'] != null
                            ? NetworkImage(prefs['photoUrl']!)
                            : snapshot.hasData
                                ? MemoryImage(snapshot.data!)
                                : null) as ImageProvider<dynamic>?,
                      ),
                    );
                  }),
              const SizedBox(height: 10.0),
              Center(
                child: Text(user.name),
              ),
              const SizedBox(height: 5.0),
              Center(child: Text(user.email)),
            ],
            ...ListTile.divideTiles(
              color: Theme.of(context).dividerColor,
              tiles: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: Text(AppLocalizations.of(context).editProfile),
                  onTap: () => context.goNamed(EditProfile.name),
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: Text(AppLocalizations.of(context).logoutButtonText),
                  onTap: () async {
                    await authNotifier.deleteSession();
                    if (!context.mounted) {
                      return;
                    }
                    context.pop();
                  },
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
