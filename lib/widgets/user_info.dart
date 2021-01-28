import 'package:flutter/material.dart';
import 'package:flutter_api_rest/models/user.dart';

class UserInfo extends StatelessWidget {
  final User user;

  const UserInfo({Key key, @required this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (user.avatar != null)
          CircleAvatar(
            backgroundImage: NetworkImage(
              "https://curso-api-flutter.herokuapp.com${user.avatar}",
            ),
            radius: 50,
          ),
        Text(user.id),
        Text(user.username),
        Text(user.email),
        Text(user.createdAt.toIso8601String()),
      ],
    );
  }
}
