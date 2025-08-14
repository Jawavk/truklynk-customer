import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truklynk/common/widgets/alert_dialog.dart';
import 'package:truklynk/pages/Auth/data/models/auth_model.dart';
import 'package:truklynk/pages/Profile/bloc/profile_bloc.dart';
import 'package:truklynk/pages/Profile/bloc/profile_event.dart';
import 'package:truklynk/pages/Profile/bloc/profile_state.dart';
import 'package:truklynk/pages/Profile/data/models/blocked_service_providers_model.dart';
import 'package:truklynk/pages/Profile/presentation/constants/profile_theme.dart';
import 'package:truklynk/services/token_service.dart';

class BlockedSeviceProviders extends StatefulWidget {
  const BlockedSeviceProviders({super.key});

  @override
  State<BlockedSeviceProviders> createState() => _BlockedSeviceProvidersState();
}

class _BlockedSeviceProvidersState extends State<BlockedSeviceProviders> {
  ProfileBloc profileBloc = ProfileBloc();
  TokenService tokenService = TokenService();
  Createuser? user;

  @override
  void initState() {
    _getUserDetails();
    super.initState();
  }

  Future<void> _getUserDetails() async {
    user = await tokenService.getUser();
    profileBloc.add(GetBlockedServiceProvider(userSno: user!.usersSno));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              surfaceTintColor: ProfileTheme.blackColor,
              backgroundColor: ProfileTheme.blackColor,
              elevation: 0,
              title: const Text('Blocker Service Providers'),
            ),
            resizeToAvoidBottomInset: true,
            body: BlocProvider(
              create: (_) => profileBloc,
              child: BlocConsumer<ProfileBloc, ProfileState>(
                listener: (context, state) {},
                builder: (context, state) {
                  if (state is LoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is GetBlockedServiceProviderState) {
                    final List<BlockedServiceProviders>
                        blockedServiceProviders = state.blockedServiceProviders;
                    if (blockedServiceProviders.isNotEmpty) {
                      return ListView.builder(
                        itemCount: blockedServiceProviders.length,
                        itemBuilder: (context, index) {
                          final provider = blockedServiceProviders[index];
                          return ListTile(
                            leading: provider.photo?.isNotEmpty == true &&
                                    provider.photo![0].mediaUrl != null
                                ? Image.network(
                                    provider.photo![0].mediaUrl!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/images/profile2.png',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ); // Fallback icon on error
                                    },
                                  )
                                : Image.asset(
                                    'assets/images/profile2.png',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                            title:
                                Text(provider.companyName ?? 'No Company Name'),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
                              onPressed: () {
                                showCustomAlertDialog(
                                  dialogBackgroundColor:
                                      ProfileTheme.whiteColor,
                                  title: 'Notice',
                                  titleColor: Colors.black,
                                  context: context,
                                  contentColor: ProfileTheme.textGrey,
                                  content:
                                      "Are you sure you want to remove this service provider?",
                                  cancelText: 'No',
                                  onConfirm: () {
                                    profileBloc.add(
                                        RemoveBlockedServiceProvider(
                                            userSno: user!.usersSno,
                                            blockServiceProvidersSno: provider
                                                .blockServiceProvidersSno));
                                  },
                                  onCancel: () {},
                                  confirmButtonColor:
                                      ProfileTheme.secondaryColor,
                                  cancelButtonColor: Colors.black,
                                  confirmText: "Yes",
                                );
                              },
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(
                          child: Text(
                        'No blocked service providers were found.',
                        style: TextStyle(color: ProfileTheme.whiteColor),
                      ));
                    }
                  } else {
                    return const Center(
                        child: Text(
                      'No blocked service providers were found.',
                      style: TextStyle(color: ProfileTheme.whiteColor),
                    ));
                  }
                },
              ),
            )));
  }
}
