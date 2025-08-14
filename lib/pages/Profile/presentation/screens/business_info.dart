import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truklynk/pages/Profile/bloc/profile_event.dart';

import '../../../../config/theme.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_state.dart';
import '../constants/profile_theme.dart';

class BusinessInfo extends StatefulWidget {
  const BusinessInfo({super.key});

  @override
  State<BusinessInfo> createState() => _BusinessInfoState();
}

class _BusinessInfoState extends State<BusinessInfo> {
  ProfileBloc profileBloc = ProfileBloc();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _taxIdNumber = TextEditingController();
  final TextEditingController _businessName = TextEditingController();
  final TextEditingController _registeredAddress = TextEditingController();

  File? _selectedFile;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        profileBloc.add(PickFile(_selectedFile!));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => profileBloc,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            iconTheme: const IconThemeData(color: AppTheme.whiteColor),
            title: const Text(
              "Business information",
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  fontFamily: 'Poppins'),
            ),
            centerTitle: true,
          ),
          body: BlocConsumer<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is BusinessInfoSubmissionSuccess) {
                print(_taxIdNumber.text);
                print(_businessName.text);
                print(_registeredAddress.text);
              } else if (state is BusinessInfoSubmissionFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage)),
                );
              }
            },
            builder: (context, state) {
              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextFormField(
                              label: "Tax identification number",
                              hintText: "Enter tax identification number",
                              controller: _taxIdNumber,
                              onChanged: (value) => profileBloc.add(
                                  BusinessInfoChangedEvent(taxIdNumber: value)),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a GST number';
                                }
                                if (state is BusinessInfoValid &&
                                    !state.isTaxNumberValid) {
                                  return 'Invalid GST number';
                                }
                                return null;
                              },
                            ),
                            Container(padding: const EdgeInsets.only(bottom: 28),child: const Text("Enter the correct tax code for the system to automatically retrieve information about the company", style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: ProfileTheme.hintTextColor,
                            ),),),
                            _buildTextFormField(
                              label: "Business name",
                              hintText: "Enter business name",
                              controller: _businessName,
                              onChanged: (value) => profileBloc.add(
                                  BusinessInfoChangedEvent(
                                      businessName: value)),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the business name';
                                }
                                return null;
                              },
                            ),

                            _buildTextFormField(
                              label: "Registered address",
                              hintText: "Enter registered address",
                              controller: _registeredAddress,
                              onChanged: (value) => profileBloc.add(
                                  BusinessInfoChangedEvent(
                                      registeredAddress: value)),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the registered address';
                                }
                                return null;
                              },
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Id proof',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: ProfileTheme
                                        .cardTextColor, // Adjust to your theme
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Card(
                                        color: ProfileTheme.cardBackgroundColor,
                                        child: InkWell(
                                          onTap:
                                              _pickFile, // Trigger file picker when card is tapped
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                right: 0,
                                                top: 0,
                                                child: Image.asset(
                                                    "assets/images/upload-ico.png"),
                                              ),
                                              Column(
                                                children: [
                                                  Align(
                                                    alignment: Alignment.center,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 52.0,
                                                              top: 36.0,
                                                              right: 54.0,
                                                              bottom: 36),
                                                      child: Column(
                                                        children: [
                                                          if (_selectedFile !=
                                                              null)
                                                            _selectedFile!.path
                                                                    .endsWith(
                                                                        ".pdf")
                                                                ? const Icon(
                                                                    Icons
                                                                        .picture_as_pdf,
                                                                    size: 80,
                                                                    color: Colors
                                                                        .red)
                                                                : Image.file(
                                                                    _selectedFile!,
                                                                    height: 150,
                                                                    width: 150)
                                                          else
                                                            Image.asset(
                                                                "assets/images/front.png"),
                                                          const SizedBox(
                                                              height: 8),
                                                          const Text(
                                                            "Front",
                                                            style: TextStyle(
                                                                color: ProfileTheme
                                                                    .cardTextColor,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Card(
                                        color: ProfileTheme.cardBackgroundColor,
                                        child: InkWell(
                                          onTap:
                                              _pickFile, // Trigger file picker when card is tapped
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                right: 0,
                                                top: 0,
                                                child: Image.asset("assets/images/upload-ico.png"),
                                              ),
                                              Align(
                                                alignment: Alignment.center, // Center the column in the stack
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                    left: 52.0,
                                                    top: 36.0,
                                                    right: 54.0,
                                                    bottom: 36,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      if (_selectedFile != null)
                                                        _selectedFile!.path.endsWith(".pdf")
                                                            ? const Icon(
                                                          Icons.picture_as_pdf,
                                                          size: 80,
                                                          color: Colors.red,
                                                        )
                                                            : Image.file(
                                                          _selectedFile!,
                                                          height: 150,
                                                          width: 150,
                                                        )
                                                      else
                                                        Image.asset("assets/images/back.png"),
                                                      const SizedBox(height: 8),
                                                      const Text(
                                                        "Backside",
                                                        style: TextStyle(
                                                          color: ProfileTheme.cardTextColor,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w800,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, state) {
                        final isBusinessInfoFormValid = state is BusinessInfoValid &&
                            state
                                .isBusinessInfoFormValid; // Check form validity from state
                        return Container(
                          margin: const EdgeInsets.all(24),
                          width: MediaQuery.sizeOf(context).width,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              padding: const EdgeInsets.all(20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              foregroundColor: Colors.white,
                              backgroundColor: isBusinessInfoFormValid
                                  ? Colors.white
                                  : Colors.grey.shade400,
                            ),
                            onPressed: isBusinessInfoFormValid
                                ? () {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      profileBloc.add(SubmitBusinessInfo(
                                          taxIdNumber: _taxIdNumber.text,
                                          businessName: _businessName.text,
                                          registeredAddress:
                                              _registeredAddress.text));
                                    }
                                  }
                                : null,
                            child: const Text(
                              'Uploaded',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Avenir',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required Function(String) onChanged,
    String? Function(String?)?
        validator, // Updated to match FormFieldValidator<String>
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: ProfileTheme.textLight,
            ),
          ),
          const SizedBox(height: 11),
          TextFormField(
            style: const TextStyle(color: Colors.white),
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: ProfileTheme.cardBackgroundColor,
              hintText: hintText,
              hintStyle: const TextStyle(
                  color: ProfileTheme.textGrey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide(color: ProfileTheme.inputBorderColor),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide(color: ProfileTheme.whiteColor),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            ),
            onChanged: onChanged,
            validator: validator, // Use the validator passed in
          ),
        ],
      ),
    );
  }
}
