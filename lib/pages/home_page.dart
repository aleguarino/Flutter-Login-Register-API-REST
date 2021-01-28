import 'package:flutter/material.dart';
import 'package:flutter_api_rest/api/account_api.dart';
import 'package:flutter_api_rest/data/authentication_client.dart';
import 'package:flutter_api_rest/models/user.dart';
import 'package:flutter_api_rest/pages/login_page.dart';
import 'package:flutter_api_rest/widgets/user_info.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class HomePage extends StatefulWidget {
  static const routeName = 'home';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authenticationClient = GetIt.instance<AuthenticationClient>();
  final _accountAPI = GetIt.instance<AccountAPI>();
  User user;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUser());
  }

  Future<void> _loadUser() async {
    final response = await _accountAPI.userInfo;
    if (response.data != null) {
      setState(() {
        user = response.data;
      });
    }
  }

  Future<void> _signOut() async {
    await _authenticationClient.signOut();
    Navigator.pushNamedAndRemoveUntil(
        context, LoginPage.routeName, (route) => false);
  }

  Future<void> _pickImage() async {
    final ImagePicker imagePicker = ImagePicker();
    final PickedFile pickedFile =
        await imagePicker.getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final filename = path.basename(pickedFile.path);
      final response = await _accountAPI.updateAvatar(bytes, filename);
      if (response.data != null) {
        final String imageUrl =
            'https://curso-api-flutter.herokuapp.com${response.data}';
        setState(() => user = user.copyWith(avatar: imageUrl));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          FlatButton(onPressed: _signOut, child: Icon(Icons.logout)),
        ],
      ),
      body: Center(
        child: user == null
            ? CircularProgressIndicator()
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                UserInfo(user: user),
                FlatButton(
                  onPressed: _pickImage,
                  child: Icon(Icons.file_upload),
                ),
              ]),
      ),
    );
  }
}
