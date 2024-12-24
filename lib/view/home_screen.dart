import 'package:chatapp/view/all_users_screen.dart';
import 'package:chatapp/view/chat_tab_screen.dart';
import 'package:chatapp/view/profile_tab_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/home/home_bloc.dart';
import '../bloc/home/home_event.dart';
import '../bloc/home/home_state.dart';
import '../di/get_it.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Home',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.green,
          actions: <Widget>[
            BlocBuilder<HomeBloc, HomeState>(
              builder: (BuildContext context, HomeState state) {
                final int currentTabIndex = state is HomeInitial
                    ? state.currentTabIndex
                    : (state as TabChangedState).currentTabIndex;

                if (currentTabIndex == 0) {
                  return InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const AllUsersScreen(),
                      ),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(8.0),
                      child: const Icon(Icons.add),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (BuildContext context, HomeState state) {
                return TabBar(
                  onTap: (int index) =>
                      getIt<HomeBloc>().add(TabChangedEvent(index)),
                  indicatorColor: Colors.white,
                  labelStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  tabs: const <Widget>[
                    Tab(
                      text: 'Chat',
                    ),
                    Tab(
                      text: 'Profile',
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (BuildContext context, HomeState state) {
            final int currentTabIndex = state is HomeInitial
                ? state.currentTabIndex
                : (state as TabChangedState).currentTabIndex;
            return Flexible(
              child: IndexedStack(
                index: currentTabIndex,
                children: <Widget>[
                  ChatTabScreen(),
                  const ProfileTabScreen(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
