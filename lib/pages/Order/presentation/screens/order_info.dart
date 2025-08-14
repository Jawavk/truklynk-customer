import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truklynk/pages/Auth/data/models/auth_model.dart';
import 'package:truklynk/pages/Order/bloc/order_bloc.dart';
import 'package:truklynk/pages/Order/bloc/order_event.dart';
import 'package:truklynk/pages/Order/bloc/order_state.dart';
import 'package:truklynk/pages/Order/data/models/order_model.dart';
import 'package:truklynk/pages/Order/presentation/constants/order_theme.dart';
import 'package:truklynk/pages/Order/presentation/screens/service_unavailable_screen.dart';
import 'package:truklynk/pages/Order/providers/order_model.dart';
import 'package:truklynk/pages/Order/providers/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:truklynk/services/token_service.dart';
import 'package:truklynk/utils/helper_functions.dart';

class OrderInfoScreen extends StatefulWidget {
  const OrderInfoScreen({super.key});

  @override
  State<OrderInfoScreen> createState() => _OrderInfoScreenState();
}

extension ContextExtensions on BuildContext {
  OrderDataProvider get orderData =>
      Provider.of<OrderDataProvider>(this, listen: false);
}

class _OrderInfoScreenState extends State<OrderInfoScreen> {
  Location pickupLocation = Location();
  Location dropLocation = Location();
  PickUpData pickupInfo = PickUpData(
      pickupDate: DateTime.now(),
      totalWeight: 0,
      weightType: '',
      weightTypeSno: '',
      items: '',
      vehicleId: 0,
      notes: '',
      name: '',
      phoneNumber: '');
  OrderBloc orderBloc = OrderBloc();
  TokenService tokenService = TokenService();
  Createuser? user = Createuser(message: '', code: 0);

  @override
  void initState() {
    getUser();
    pickupLocation = context.orderData.getPickupLocation;
    dropLocation = context.orderData.getDropLocation;
    pickupInfo = context.orderData.getPickupInfo;
    super.initState();
  }

  getUser() async {
    user = await tokenService.getUser();
    print('userss$user');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => orderBloc,
        child: BlocConsumer<OrderBloc, OrderState>(listener: (context, state) {
          if (state is BookVehicleState) {
            printLongText('state.serviceBookingId${state.serviceBookingId}');
            Navigator.pushNamed(
              context,
              '/SearchProviderScreen',
              arguments: {
                'serviceBookingId': state.serviceBookingId,
                'createdOn': state.createdOn, // or any DateTime value
              },
            );
          } else if (state is ServiceUnavailableState) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ServiceUnavailableScreen()),
            );
          } else if (state is Message) {
            toast(message: state.message);
          }
        }, builder: (context, state) {
          return SafeArea(
              child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              surfaceTintColor: Colors.black,
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios), // iOS-style back icon
                onPressed: () {
                  Navigator.pop(context); // Pop the current route
                },
              ),
              title: const Text(
                'Order information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Shipping address',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Image(
                                image:
                                    AssetImage('assets/images/pick-drop.png'),
                                height: 100,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(children: [
                                  Card(
                                      color: OrderTheme.cardBackground,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${pickupLocation.name}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            const Icon(
                                              Icons.edit,
                                              color: OrderTheme.secondaryColor,
                                            ),
                                          ],
                                        ),
                                      )),
                                  const SizedBox(height: 16),
                                  Card(
                                      color: OrderTheme.cardBackground,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${dropLocation.name}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            const Icon(
                                              Icons.edit,
                                              color: OrderTheme.secondaryColor,
                                            ),
                                          ],
                                        ),
                                      ))
                                ]),
                              )
                            ],
                          ),
                          const SizedBox(height: 22),
                          const Text(
                            'Name of goods',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              color: OrderTheme.cardBackground,
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  child: Text(
                                    pickupInfo.items,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              color: OrderTheme.cardBackground,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: Row(
                                  children: [
                                    Text(
                                      pickupInfo.weightType,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Container(
                                        color: OrderTheme
                                            .whiteColor, // Debug color
                                        child: const VerticalDivider(
                                          width: 1,
                                          indent: 20,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${pickupInfo.totalWeight}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Text(
                            'Loading time',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              color: OrderTheme.cardBackground,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                        child: Text(
                                      localDateTimeFormat(
                                          pickupInfo.pickupDate),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )),
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.calendar_month),
                                      color: OrderTheme.secondaryColor,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Location pickup = context.orderData.getPickupLocation;
                          Location drop = context.orderData.getDropLocation;
                          PickUpData pickupInfo =
                              context.orderData.getPickupInfo;

                          // Safely access user properties with null-aware operators
                          String userName = user?.name ?? 'Unknown User';
                          String userProfileSno =
                              user?.userProfileSno?.toString() ?? 'Unknown';

                          orderBloc.add(BookVehicleEvent(
                            pickup: pickup,
                            drop: drop,
                            pickupInfo: pickupInfo,
                            userName: userName,
                            userProfileSno: userProfileSno,
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OrderTheme.whiteColor,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text('Confirm',
                            style: TextStyle(
                                color: OrderTheme.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                      ),
                    ))
              ],
            ),
          ));
        }));
  }
}
