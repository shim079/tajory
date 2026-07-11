import 'package:flutter/material.dart';
import '../widgets/profile_header.dart';

class IslandScreen extends StatelessWidget {
  const IslandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bsckground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const ProfileHeader(),
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/images/camel.png',
                  width: 350,
                  height: 525,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
