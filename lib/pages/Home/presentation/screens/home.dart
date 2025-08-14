import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truklynk/common/models/header_model.dart';
import 'package:truklynk/common/widgets/custom_list_tile.dart';
import 'package:truklynk/pages/Auth/data/models/auth_model.dart';
import 'package:truklynk/pages/History/data/models/booking_model.dart';
import 'package:truklynk/pages/History/presentation/screens/history_card_header.dart';
import 'package:truklynk/pages/Home/bloc/home_bloc.dart';
import 'package:truklynk/pages/Home/bloc/home_event.dart';
import 'package:truklynk/pages/Home/bloc/home_state.dart';
import 'package:truklynk/pages/Home/presentation/constants/home_theme.dart';
import 'package:truklynk/pages/Order/providers/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:truklynk/services/token_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

extension ContextExtensions on BuildContext {
  OrderDataProvider get orderData =>
      Provider.of<OrderDataProvider>(this, listen: false);
}

class _HomeScreenState extends State<HomeScreen> {
  HomeBloc homeBloc = HomeBloc();
  List<Booking> bookingList = [];
  TokenService tokenService = TokenService();

  @override
  void initState() {
    _getUserDetails();
    super.initState();
  }

  Future<void> _getUserDetails() async {
    Createuser? user = await tokenService.getUser();
    print('user${jsonEncode(user)}');
    homeBloc.add(FetchBooking(
        userProfileSno: user!.userProfileSno!,
        status: 0,
        skip: 0,
        limits: 10)); // default to 0 if null
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> items = [
      {
        'title': 'Refrigerated Trucks ',
        'subtitle': 'For cold storage, amiable with capacity of 5 to 20 tones',
        'image': 'assets/images/trucks.png',
      },
      {
        'title': 'Flatbed Trucks',
        'subtitle':
            'For oversized goods, amiable with capacity of 5 to 20 tones',
        'image': 'assets/images/container.png',
      },
      {
        'title': 'Switch Delivery Van',
        'subtitle': 'For Tankers with capacity of 5 to 20 tones',
        'image': 'assets/images/van.png',
      },
    ];

    return WillPopScope(
      onWillPop: () async {
        // Handle back button press
        // final bool? shouldPop = await showCustomAlertDialog(
        //   dialogBackgroundColor: HomeTheme.whiteColor,
        //   title: 'Exit',
        //   titleColor: Colors.black,
        //   context: context,
        //   contentColor: HomeTheme.textGrey,
        //   content: "Press back again to exit",
        //   onConfirm: () {},
        //   onCancel: () {},
        //   confirmButtonColor: HomeTheme.secondaryColor,
        //   cancelButtonColor: Colors.black,
        // );
        // return shouldPop ?? false;
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            surfaceTintColor: HomeTheme.blackColor,
            backgroundColor: HomeTheme.blackColor,
            automaticallyImplyLeading: false,
            elevation: 0,
            flexibleSpace: Padding(
              padding: const EdgeInsets.only(top: 12.0, left: 12.0),
              child: SafeArea(
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/logo.png', // Replace with your image path
                      fit: BoxFit.cover,
                      width: 150,
                    ),
                  ],
                ),
              ),
            ),
          ),
          resizeToAvoidBottomInset: true,
          body: BlocProvider(
            create: (_) => homeBloc,
            child:
                BlocConsumer<HomeBloc, HomeState>(listener: (context, state) {
              if (state is BookingState) {
                bookingList = state.BookingList;
                print("bookingList${jsonEncode(bookingList)}");
              }
            }, builder: (context, state) {
              return Container(
                color: HomeTheme.blackColor,
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Book & Truck',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                              30.0), // Custom border radius
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(1),
                              spreadRadius: 2,
                              blurRadius: 0,
                              offset: const Offset(0, 0), // Shadow position
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            context.orderData.resetPickupLocations();
                            context.orderData.resetDropupLocations();
                            context.orderData.resetPickupInfo();
                            Navigator.pushNamed(context, '/OrderScreen');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black, // Background color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  30.0), // Custom border radius
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0), // Adjust padding if needed
                            elevation:
                                0, // Set elevation to 0 to match the box shadow style
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.search, color: Colors.white),
                              SizedBox(width: 8.0),
                              Text(
                                'Set Pickup & Drop Locations',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (bookingList.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Booking',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      CarouselSlider(
                        options: CarouselOptions(
                          enableInfiniteScroll: false,
                          height: MediaQuery.of(context).size.height * 0.20,
                        ),
                        items: bookingList.map((Booking booking) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/SearchProviderScreen',
                                  arguments: {
                                    'serviceBookingId':
                                        booking.serviceBookingSno,
                                    'createdOn': DateTime.parse(
                                        booking.createdOn.toString()),
                                  },
                                );
                              },
                              child: Card(
                                color: Colors.black,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color:
                                          const Color.fromARGB(255, 82, 58, 58)
                                              .withOpacity(0.3)),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20)),
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  children: [
                                    HistoryCardHeader(
                                      orderNo: '${booking.serviceBookingSno}',
                                      bookingStatus:
                                          '${booking.bookingStatusName}',
                                    ),
                                    Expanded(
                                      child: CustomListTile(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                bottom: Radius.circular(20)),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 20),
                                        backgroundColor:
                                            HomeTheme.cardBackgroundColor,
                                        leading: HeaderItem(
                                          isExpanded: true,
                                          widget: Text(
                                            booking.pickupLocation?.city
                                                        ?.isNotEmpty ==
                                                    true
                                                ? booking.pickupLocation!.city!
                                                : booking.pickupLocation
                                                        ?.address ??
                                                    'Unknown location',
                                            style: const TextStyle(
                                              color: HomeTheme.whiteColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            maxLines: 1,
                                          ),
                                        ),
                                        title: HeaderItem(
                                          isExpanded: true,
                                          color: HomeTheme.whiteColor,
                                          isCenter: true,
                                          widget: const Icon(
                                            Icons.arrow_forward,
                                            color: HomeTheme.whiteColor,
                                          ),
                                        ),
                                        trailing: HeaderItem(
                                          isExpanded: true,
                                          widget: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              booking.dropLocation?.city
                                                          ?.isNotEmpty ==
                                                      true
                                                  ? booking.dropLocation!.city!
                                                  : booking.dropLocation
                                                          ?.address ??
                                                      'Unknown location',
                                              style: const TextStyle(
                                                color: HomeTheme.whiteColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 5),
                    ],
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Also Check',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Use Expanded to avoid layout errors with ListView
                    Expanded(
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                // Navigator.pushNamed(context, '/OrderScreen');
                              },
                              child: Card(
                                  color: HomeTheme.cardBackgroundColor,
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          // Ensures the text doesn't overflow
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Expanded(
                                                      child: RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: items[index]
                                                              ['title']!,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize:
                                                                12, // You can adjust this as needed
                                                          ),
                                                        ),
                                                        const WidgetSpan(
                                                          child: SizedBox(
                                                              width: 20),
                                                        ),
                                                        const WidgetSpan(
                                                          child: Icon(
                                                              Icons
                                                                  .arrow_forward,
                                                              size: 20,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                                ],
                                              ),
                                              const SizedBox(
                                                  height:
                                                      4), // Optional: add space between title and subtitle
                                              Text(
                                                items[index]['subtitle']!,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                            width:
                                                10), // Add spacing between text and image
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.asset(
                                            items[index]['image']!,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
