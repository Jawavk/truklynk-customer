import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:truklynk/common/widgets/cupertino_picker.dart';
import 'package:truklynk/pages/Auth/data/models/auth_model.dart';
import 'package:truklynk/pages/Order/bloc/order_bloc.dart';
import 'package:truklynk/pages/Order/bloc/order_event.dart';
import 'package:truklynk/pages/Order/bloc/order_state.dart';
import 'package:truklynk/pages/Order/data/models/subcategory_model.dart';
import 'package:truklynk/pages/Order/presentation/constants/order_theme.dart';
import 'package:truklynk/pages/Order/data/models/enum.dart';
import 'package:truklynk/pages/Order/providers/order_model.dart';
import 'package:truklynk/pages/Order/providers/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:truklynk/services/token_service.dart';
import 'package:truklynk/utils/helper_functions.dart';

class Pickup extends StatefulWidget {
  const Pickup({super.key});

  @override
  State<Pickup> createState() => _PickupState();
}

extension ContextExtensions on BuildContext {
  OrderDataProvider get orderData =>
      Provider.of<OrderDataProvider>(this, listen: false);
}

class _PickupState extends State<Pickup> {
  List<Enum>? weightList = [];
  String? dropdownValue;
  DateTime defaultDateTime = DateTime.now();
  late DateTime pickDateTime;
  late String pickName;
  late String pickNumber;
  List<Vehicle>? trucks = [];
  OrderBloc orderBloc = OrderBloc();
  int selectedVehicle = 0;
  bool pageIsInvalid = true;
  TokenService tokenService = TokenService();

  static Map<String, dynamic>? _lessThanZero(AbstractControl<dynamic> control) {
    if (control.value != null && control.value <= 0) {
      return {'lessThanZero': true};
    }
    return null;
  }

  final FormGroup form = fb.group({
    'pickupDate': FormControl<DateTime>(
        value: DateTime.now(), validators: [Validators.required]),
    'totalWeight': FormControl<double>(validators: [
      Validators.required,
      Validators.delegate(_lessThanZero),
    ]),
    'weightType': FormControl<String>(validators: [
      Validators.required,
    ]),
    'weightTypeSno': FormControl<String>(validators: [
      Validators.required,
    ]),
    'items': FormControl<String>(
        validators: [Validators.required, Validators.minLength(3)]),
    'vehicleId': FormControl<int>(validators: [Validators.required]),
    'name': FormControl<String>(value: "", validators: [Validators.required]),
    'phoneNumber': FormControl<String>(value: "", validators: [
      Validators.required,
      Validators.minLength(10),
      Validators.maxLength(10)
    ]),
    // 'contactInfo': FormControl<String>(value: "",validators: [Validators.required,Validators.minLength(10)]),
    'notes': FormControl<String>(value: ""),
  });

  @override
  void initState() {
    if (context.orderData.getPickupInfo.items.isNotEmpty) {
      PickUpData existingData = context.orderData.getPickupInfo;
      form.patchValue(existingData.toJson());
      orderBloc.add(CheckPageValid(pageInvalid: form.invalid));
    }
    pickDateTime = form.control('pickupDate').value ?? defaultDateTime;

    orderBloc.add(FetchVehicleEvent(categorySno: 2));
    orderBloc.add(FetchWeightEvent());
    _getUserDetails();
    super.initState();
  }

  Future<void> _getUserDetails() async {
    Createuser? user = await tokenService.getUser();
    print('user ${jsonEncode(user)}');
    form.control('name').value = user?.name;
    form.control('phoneNumber').value = user?.mobileNumber;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => orderBloc,
      child: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is FetchDateState) {
            pickDateTime = state.dateTime;
            form.controls['pickupDate']!.value = pickDateTime;
          }

          if (state is FetchContactState) {
            pickName = state.name;
            pickNumber = state.phoneNumber;
            form.controls['name']!.value = pickName;
            form.controls['phoneNumber']!.value = pickNumber;
          }

          if (state is FetchWeightState) {
            weightList = state.enumModelEnum;
            if (weightList!.isNotEmpty) {
              if (form.controls['weightTypeSno']!.isNull) {
                dropdownValue = weightList!.first.codesDtlSno.toString();
                form.controls['weightTypeSno']!.value =
                    weightList!.first.codesDtlSno.toString();
                form.controls['weightType']!.value =
                    '${weightList!.first.cdValue}';
              } else {
                dropdownValue = form.control('weightTypeSno').value;
              }
            }
          }
          if (state is ChangeWeightState) {
            dropdownValue = state.value;
            Iterable<Enum> result = weightList!.where(
                (Enum weight) => weight.codesDtlSno.toString() == state.value);
            if (result.isNotEmpty) {
              form.controls['weightTypeSno']!.value =
                  result.first.codesDtlSno.toString();
              form.controls['weightType']!.value = result.first.cdValue;
            }
          }
          if (state is FetchVehicleState) {
            trucks = state.vehicleList;
            if (trucks!.isNotEmpty && form.controls['vehicleId']!.isNotNull) {
              int? index = trucks!.indexWhere((truck) =>
                  truck.subcategorySno == form.controls['vehicleId']!.value);
              selectedVehicle = index;
            } else if (trucks!.isNotEmpty &&
                form.controls['vehicleId']!.isNull) {
              form.controls['vehicleId']!.value = trucks![0].subcategorySno;
            }
          }
          if (state is ChangeVehicleState) {
            selectedVehicle = state.index;
          }
          if (state is CheckPageValidState) {
            pageIsInvalid = state.isCheckPageValid;
          }
        },
        builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              surfaceTintColor: OrderTheme.blackColor,
              backgroundColor: OrderTheme.blackColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: const Text(
                'Pickup Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: Container(
                    color: OrderTheme.blackColor,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 16),
                      child: ReactiveForm(
                        formGroup: form,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPickupDateTime(context),
                            _buildWeightInput(context),
                            _buildItemsInput(),
                            _buildTrucksList(),
                            _buildInfoInput(),
                            _buildNotesInput(),
                            const SizedBox(height: 160),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _buildContinueButton(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPickupDateTime(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Pickup Date & Time',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: ' *',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red, // Set the color to red
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            color: OrderTheme.cardBackground,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      localDateTimeFormat(pickDateTime),
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showCustomCupertinoDatePicker(
                        context: context,
                        selctedDateTime: pickDateTime,
                        initialDateTime: defaultDateTime,
                        onDateTimeChanged: (DateTime time) {},
                        onCancel: () {},
                        onConfirm: (value) {
                          orderBloc.add(DatePickEvent(dateTime: value));
                          orderBloc
                              .add(CheckPageValid(pageInvalid: form.invalid));
                        },
                      );
                    },
                    icon: const Icon(Icons.calendar_month),
                    color: OrderTheme.whiteColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Enter Total Weight',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: ' *',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red, // Set the color to red
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            color: OrderTheme.cardBackground,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: ReactiveTextField(
                      textInputAction: TextInputAction.done,
                      formControlName: "totalWeight",
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '00',
                        contentPadding: EdgeInsets.symmetric(vertical: 6.0),
                      ),
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                      onChanged: (value) {
                        orderBloc
                            .add(CheckPageValid(pageInvalid: form.invalid));
                      },
                      showErrors: (control) => false,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    color: OrderTheme.WeightButton,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: dropdownValue,
                      items: weightList!
                          .map<DropdownMenuItem<String>>((Enum value) {
                        return DropdownMenuItem<String>(
                          value: '${value.codesDtlSno}',
                          child: Text('${value.cdValue}'),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        orderBloc.add(ChangeWeightEvent(value: value));
                      },
                      style: const TextStyle(color: OrderTheme.whiteColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ReactiveFormField(
          formControlName: "totalWeight",
          builder: (field) {
            return field.errorText != null
                ? Text(
                    '${field.errorText}',
                    style: const TextStyle(color: Colors.red),
                  )
                : Container(); // or SizedBox.shrink() to take up no space
          },
          validationMessages: {
            'required': (control) => 'Please enter the valid item weight',
            'lessThanZero': (control) => 'Please enter a weight greater than 0',
          },
        )
      ],
    );
  }

  Widget _buildItemsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Add Items',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: ' *',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red, // Set the color to red
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            color: OrderTheme.cardBackground,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ReactiveTextField(
                formControlName: "items",
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'E.g. Apples, Orange',
                  contentPadding: EdgeInsets.symmetric(vertical: 6.0),
                ),
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
                onChanged: (value) {
                  orderBloc.add(CheckPageValid(pageInvalid: form.invalid));
                },
                showErrors: (control) => false,
              ),
            ),
          ),
        ),
        ReactiveFormField(
          formControlName: "items",
          builder: (field) {
            return field.errorText != null
                ? Text(
                    '${field.errorText}',
                    style: const TextStyle(color: Colors.red),
                  )
                : Container(); // or SizedBox.shrink() to take up no space
          },
          validationMessages: {
            //  ValidationMessage.required: (control) => 'Please enter the valid item',
            'required': (control) => 'Please enter the valid item',
            'minLength': (control) => 'Please enter the minmum 3 characters',
          },
        )
      ],
    );
  }

  Widget _buildTrucksList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Type of vehicle service',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: ' *',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red, // Set the color to red
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: SizedBox(
            height: 175,
            child: trucks!.isNotEmpty
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: trucks!.length,
                    itemBuilder: (context, index) {
                      Vehicle truck = trucks![index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            SizedBox(
                              width: 250,
                              child: InkWell(
                                onTap: () {
                                  form.controls['vehicleId']!.value =
                                      trucks![index].subcategorySno;
                                  orderBloc
                                      .add(ChangeVehicleEvent(index: index));
                                  orderBloc.add(CheckPageValid(
                                      pageInvalid: form.invalid));
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  color: selectedVehicle == index
                                      ? OrderTheme.secondaryColor
                                      : OrderTheme.cardBackground,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 13, horizontal: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 50),
                                        Text(
                                          '${truck.subcategoryName}',
                                          style: const TextStyle(
                                            color: OrderTheme.whiteColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          '${truck.description}',
                                          style: const TextStyle(
                                            color: OrderTheme.whiteColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: -10,
                              left: -10,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/images/truck1.png',
                                  // '${truck.media!.isNotEmpty ? truck.media!.first.mediaUrl : 'assets/images/truck1.png'}',
                                  height: 60,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                        'assets/images/truck1.png',
                                        height: 60);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : const Center(child: Text('No trucks available')),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Contact Name ',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: ' *',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red, // Set the color to red
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            color: OrderTheme.cardBackground,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ReactiveTextField(
                textInputAction: TextInputAction.done,
                formControlName: "name",
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter your contact name",
                  contentPadding: EdgeInsets.symmetric(vertical: 6.0),
                ),
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
                onChanged: (value) {
                  final nameValue = form.control('name').value as String?;
                  orderBloc.add(ChangeNameEvent(name: nameValue));
                  orderBloc.add(CheckPageValid(pageInvalid: form.invalid));
                },
                showErrors: (control) => false,
              ),
            ),
          ),
        ),
        ReactiveFormField(
          formControlName: "name",
          builder: (field) {
            return field.errorText != null
                ? Text(
                    '${field.errorText}',
                    style: const TextStyle(color: Colors.red),
                  )
                : Container(); // or SizedBox.shrink() to take up no space
          },
          validationMessages: {
            'required': (control) => 'Please enter your name',
          },
        ),
        const SizedBox(height: 8),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Contact Mobile Number ',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: ' *',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red, // Set the color to red
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            color: OrderTheme.cardBackground,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ReactiveTextField(
                    textInputAction: TextInputAction.done,
                    formControlName: "phoneNumber",
                    keyboardType: TextInputType.number,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter your contact number",
                      contentPadding: EdgeInsets.symmetric(vertical: 6.0),
                    ),
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                    onChanged: (value) {
                      final nameValue =
                          form.control('phoneNumber').value as String?;
                      orderBloc.add(ChangeNumberEvent(phoneNumber: nameValue));
                      orderBloc.add(CheckPageValid(pageInvalid: form.invalid));
                    },
                    showErrors: (control) => false,
                  ),
                ],
              ),
            ),
          ),
        ),
        ReactiveFormField(
          formControlName: "phoneNumber",
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display validation messages if any
                if (field.errorText != null)
                  Text(
                    '${field.errorText}',
                    style: const TextStyle(color: Colors.red),
                  ),
              ],
            );
          },
          validationMessages: {
            'required': (control) => 'Please enter a valid contact number',
            'minLength': (control) => 'Please enter a minimum of 10 digits',
            'maxLength': (control) =>
                'Please enter only 10 digits', // Added max length validation message
          },
        ),
      ],
    );
  }

  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        const Text(
          'Notes',
          style: TextStyle(
              fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            color: OrderTheme.cardBackground,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ReactiveTextField(
                textInputAction: TextInputAction.done,
                formControlName: "notes",
                maxLines: 5,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Notes for vehicle owners",
                  contentPadding: EdgeInsets.symmetric(vertical: 6.0),
                ),
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
                onChanged: (value) {},
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          if (!pageIsInvalid) {
            PickUpData data = PickUpData.fromJson(form.value);
            print('datas${form.value}');
            context.orderData.addPickupInfo(data);
            Navigator.pushNamed(context, '/OrderInfoScreen');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              pageIsInvalid ? OrderTheme.primaryColor : OrderTheme.whiteColor,
          minimumSize: const Size(double.infinity, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Text(
          'Next',
          style: TextStyle(
              color: !pageIsInvalid
                  ? OrderTheme.primaryColor
                  : OrderTheme.whiteColor,
              fontSize: 16,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
