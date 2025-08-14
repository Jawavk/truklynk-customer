import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truklynk/common/models/header_model.dart';
import 'package:truklynk/common/widgets/alert_dialog.dart';
import 'package:truklynk/common/widgets/custom_list_tile.dart';
import 'package:truklynk/pages/Auth/data/models/auth_model.dart';
import 'package:truklynk/pages/Profile/bloc/profile_bloc.dart';
import 'package:truklynk/pages/Profile/bloc/profile_event.dart';
import 'package:truklynk/pages/Profile/bloc/profile_state.dart';
import 'package:truklynk/pages/Profile/presentation/constants/profile_theme.dart';
import 'package:truklynk/pages/Profile/presentation/screens/business_info.dart';
import 'package:truklynk/pages/Profile/presentation/screens/personal_info.dart';
import 'package:truklynk/services/token_service.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List optionsList = [
    {"src": 'assets/images/settings.png', "title": "Settings"},
    {"src": 'assets/images/faq.png', "title": "Frequently Asked Questions"},
    {"src": 'assets/images/lock.png', "title": "Terms"},
    {"src": 'assets/images/Headset.png', "title": "Contact support"},
    {"src": 'assets/images/logout.png', "title": "Log out"}
  ];

  TokenService tokenService = TokenService();
  ProfileBloc profileBloc = ProfileBloc();

  Future<Createuser?> getUser() async {
    return await tokenService.getUser();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => profileBloc,
      child: WillPopScope(
        onWillPop: () async {
          // Navigator.pushReplacementNamed(context, '/HomeScreen');
          return true; // Allows the back action
        },
        child: SafeArea(
          child: Scaffold(
              appBar: AppBar(
                surfaceTintColor: ProfileTheme.blackColor,
                backgroundColor: ProfileTheme.blackColor,
                automaticallyImplyLeading: true,
                title: const Center(
                  child: Text(
                    "Account",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                ),
              ),
              body: BlocConsumer<ProfileBloc, ProfileState>(
                  listener: (context, state) {
                if (state is LogOutState) {
                  Navigator.pushReplacementNamed(context, '/LoginScreen');
                }
              }, builder: (context, state) {
                return FutureBuilder<Createuser?>(
                  future: getUser(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData) {
                      return const Center(child: Text('No data found'));
                    }
                    final user = snapshot.data!;
                    return SingleChildScrollView(
                      child: Container(
                        color: ProfileTheme.blackColor,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Card(
                              margin: const EdgeInsets.symmetric(vertical: 16),
                              color: ProfileTheme.cardBackgroundColor,
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: CustomListTile(
                                padding: const EdgeInsets.all(16),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                                leading: HeaderItem(
                                  isExpanded: false,
                                  color: ProfileTheme.whiteColor,
                                  isCenter: false,
                                  widget: Image.asset("assets/images/Oval.png",
                                      width: 80),
                                ),
                                title: HeaderItem(
                                  isExpanded: true,
                                  isCenter: false,
                                  backgroundColor: Colors.transparent,
                                  margin: const EdgeInsets.all(12),
                                  widget: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${user.name}',
                                        style: const TextStyle(
                                            color: ProfileTheme.textGrey,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                            fontFamily: 'Avenir'),
                                        textAlign: TextAlign.left,
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Image.asset(
                                            "assets/images/smartphone.png",
                                            width: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${user.mobileNumber}',
                                            style: const TextStyle(
                                                color:
                                                    ProfileTheme.secondaryColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Card(
                              color: ProfileTheme.cardBackgroundColor,
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: CustomListTile(
                                padding: const EdgeInsets.all(16),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PersonalInfo(),
                                      ));
                                },
                                title: HeaderItem(
                                  isExpanded: true,
                                  widget: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Personal information",
                                        style: TextStyle(
                                            color: ProfileTheme.textLight,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800),
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Your name, ID card, email, address",
                                            style: TextStyle(
                                                color: ProfileTheme.textGrey,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Icon(Icons.arrow_forward_ios,
                                              color: ProfileTheme.textGrey,
                                              size: 16)
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Card(
                            //   margin: const EdgeInsets.symmetric(vertical: 16),
                            //   color: ProfileTheme.cardBackgroundColor,
                            //   shape: const RoundedRectangleBorder(
                            //     borderRadius:
                            //         BorderRadius.all(Radius.circular(20)),
                            //   ),
                            //   child: CustomListTile(
                            //     padding: const EdgeInsets.all(16),
                            //     onTap: () {
                            //       Navigator.push(
                            //           context,
                            //           MaterialPageRoute(
                            //             builder: (context) =>
                            //                 const BusinessInfo(),
                            //           ));
                            //     },
                            //     title: HeaderItem(
                            //       isExpanded: true,
                            //       widget: const Column(
                            //         crossAxisAlignment:
                            //             CrossAxisAlignment.start,
                            //         children: [
                            //           Text(
                            //             "Business information",
                            //             style: TextStyle(
                            //                 color: ProfileTheme.textLight,
                            //                 fontSize: 16,
                            //                 fontWeight: FontWeight.w800),
                            //           ),
                            //           SizedBox(height: 10),
                            //           Row(
                            //             mainAxisAlignment:
                            //                 MainAxisAlignment.spaceBetween,
                            //             children: [
                            //               Text(
                            //                 "Company's name, address",
                            //                 style: TextStyle(
                            //                     color: ProfileTheme.textGrey,
                            //                     fontSize: 16,
                            //                     fontWeight: FontWeight.w500),
                            //               ),
                            //               Icon(Icons.arrow_forward_ios,
                            //                   color: ProfileTheme.textGrey,
                            //                   size: 16)
                            //             ],
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            Card(
                              color: ProfileTheme.cardBackgroundColor,
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    CustomListTile(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/BlockedSeviceProviders');
                                      },
                                      borderBottom: const BorderSide(
                                        color: Colors.grey,
                                        width: 0.5,
                                      ),
                                      leading: HeaderItem(
                                        isExpanded: false,
                                        widget: const Icon(Icons.block),
                                      ),
                                      title: HeaderItem(
                                        isExpanded: true,
                                        padding: const EdgeInsets.all(18),
                                        widget: const Text(
                                          "Blocked Service Providers",
                                          style: TextStyle(
                                              color: ProfileTheme.textLight,
                                              fontSize: 14,
                                              fontFamily: 'Poppins'),
                                        ),
                                      ),
                                      trailing: HeaderItem(
                                        isExpanded: false,
                                        widget: const Icon(
                                            Icons.arrow_forward_ios,
                                            color: ProfileTheme.textGrey,
                                            size: 16),
                                      ),
                                    ),
                                    for (int i = 0; i < optionsList.length; i++)
                                      CustomListTile(
                                        onTap: () {
                                          if (optionsList[i]['title'] ==
                                              'Settings') {
                                          } else if (optionsList[i]['title'] ==
                                              'Frequently Asked Questions') {
                                          } else if (optionsList[i]['title'] ==
                                              'Terms') {
                                          } else if (optionsList[i]['title'] ==
                                              'Contact support') {
                                          } else {
                                            showCustomAlertDialog(
                                              dialogBackgroundColor:
                                                  ProfileTheme.whiteColor,
                                              title: 'Notice',
                                              titleColor: Colors.black,
                                              context: context,
                                              contentColor:
                                                  ProfileTheme.textGrey,
                                              content:
                                                  "Are you sure you want to log out?",
                                              confirmButtonColor:
                                                  ProfileTheme.secondaryColor,
                                              cancelButtonColor: Colors.black,
                                              confirmText: "Yes",
                                              cancelText: 'No',
                                              onConfirm: () {
                                                profileBloc.add(LogOutEvent(
                                                    signinconfigsno:
                                                        user.signinconfigSno ??
                                                            0,
                                                    status: 0));
                                              },
                                              onCancel: () {},
                                            );
                                          }
                                        },
                                        borderBottom: const BorderSide(
                                          color: Colors.grey,
                                          width: 0.5,
                                        ),
                                        leading: HeaderItem(
                                          isExpanded: false,
                                          widget: Image.asset(
                                            "${optionsList[i]['src']}",
                                            width: 20,
                                          ),
                                        ),
                                        title: HeaderItem(
                                          isExpanded: true,
                                          padding: const EdgeInsets.all(18),
                                          widget: Text(
                                            "${optionsList[i]['title']}",
                                            style: const TextStyle(
                                                color: ProfileTheme.textLight,
                                                fontSize: 14,
                                                fontFamily: 'Poppins'),
                                          ),
                                        ),
                                        trailing: HeaderItem(
                                          isExpanded: false,
                                          widget: const Icon(
                                              Icons.arrow_forward_ios,
                                              color: ProfileTheme.textGrey,
                                              size: 16),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              })),
        ),
      ),
    );
  }
}
