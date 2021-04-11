import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_appwrite_starter/core/presentation/providers/providers.dart';
import 'package:flutter_appwrite_starter/core/res/data_constants.dart';
import 'package:flutter_appwrite_starter/features/profile/data/model/user.dart';
import 'package:flutter_appwrite_starter/features/profile/data/model/user_field.dart';
import 'package:flutter_appwrite_starter/features/profile/presentation/widgets/avatar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfile extends StatefulWidget {
  final User user;

  const EditProfile({Key key, this.user}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

enum AppState {
  free,
  picked,
  cropped,
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController _nameController;
  bool _processing;
  AppState state;
  File _image;
  String _uploadedFileURL;

  @override
  void initState() {
    super.initState();
    _processing = false;
    state = AppState.free;
    _nameController = TextEditingController(text: widget.user?.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).editProfile),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          //TODO
          Center(
            child: Avatar(
              showButton: true,
              onButtonPressed: _pickImageButtonPressed,
              radius: 50,
              image: state == AppState.cropped && _image != null
                  ? FileImage(_image)
                  : widget.user.prefs.photoUrl != null
                      ? NetworkImage(widget.user.prefs.photoUrl)
                      : null,
            ),
          ),
          const SizedBox(height: 10.0),
          Center(child: Text(widget.user.email)),
          const SizedBox(height: 10.0),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
                labelText: AppLocalizations.of(context).nameFieldLabel),
          ),
          const SizedBox(height: 10.0),
          Center(
            child: ElevatedButton(
              child: _processing
                  ? CircularProgressIndicator()
                  : Text(AppLocalizations.of(context).saveButtonLabel),
              onPressed: _processing
                  ? null
                  : () async {
                      //save name
                      if (_nameController.text.isEmpty &&
                          (_image == null || state != AppState.cropped)) return;
                      setState(() {
                        _processing = true;
                      });
                      /* if (_image != null && state == AppState.cropped) {
                        await uploadImage();
                      } */
                      Map<String, dynamic> data = {};
                      if (_nameController.text.isNotEmpty)
                        data[UserFields.name] = _nameController.text;
                      if (_uploadedFileURL != null)
                        data[UserFields.photoUrl] = _uploadedFileURL;
                      if (data.isNotEmpty) {
                        //update data
                        await context
                            .read(userRepoProvider)
                            .updateProfile(name: _nameController.text);
                      }
                      if (mounted) {
                        setState(() {
                          _processing = false;
                        });
                        Navigator.pop(context);
                      }
                    },
            ),
          )
        ],
      ),
    );
  }

  void _pickImageButtonPressed() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              AppLocalizations.of(context).pickImageDialogTitle,
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ...ListTile.divideTiles(
                  color: Theme.of(context).dividerColor,
                  tiles: [
                    ListTile(
                      onTap: () {
                        getImage(ImageSource.camera);
                      },
                      title: Text(AppLocalizations.of(context)
                          .pickFromCameraButtonLabel),
                    ),
                    ListTile(
                      onTap: () {
                        getImage(ImageSource.gallery);
                      },
                      title: Text(AppLocalizations.of(context)
                          .pickFromGalleryButtonLabel),
                    ),
                  ],
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    AppLocalizations.of(context).cancelButtonLabel,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future getImage(ImageSource source) async {
    var image = await ImagePicker().getImage(source: source);
    if (image == null) return;
    setState(() {
      _image = File(image.path);
      setState(() {
        state = AppState.cropped;
      });
      Navigator.pop(context);
    });
  }
/* 
  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: _image.path,
      maxWidth: 800,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
    );
    if (croppedFile != null) {
      _image = croppedFile;
      setState(() {
        state = AppState.cropped;
      });
    }
  } */

  Future uploadImage() async {
    String path =
        '${AppDBConstants.usersStorageBucket}/${widget.user.id}/${Path.basename(_image.path)}';

    //upload file

    /* setState(() {
      _uploadedFileURL = url;
    }); */
  }
}