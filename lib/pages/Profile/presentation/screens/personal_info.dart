import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:truklynk/common/widgets/success_dialog.dart';
import 'package:truklynk/config/theme.dart';
import 'package:truklynk/pages/Auth/data/models/auth_model.dart';
import 'package:truklynk/pages/Profile/bloc/profile_bloc.dart';
import 'package:truklynk/pages/Profile/presentation/constants/profile_theme.dart';
import 'package:truklynk/services/token_service.dart';
import '../../../../services/sockerService.dart';
import '../../bloc/profile_event.dart';
import '../../bloc/profile_state.dart';

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({super.key});

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

extension StringUtils on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty || this == 'null';
}

class _PersonalInfoState extends State<PersonalInfo> {
  ProfileBloc profileBloc = ProfileBloc();
  File? _selectedFile;
  TokenService tokenService = TokenService();
  bool pageIsInvalid = true;

  bool _isSubmitting = false;

  File? _selectedLicense;
  File? _selectedInsurance;
  File? _selectedRc;

  bool _isLicenseUploaded = false;
  bool _isInsuranceUploaded = false;
  bool _isRcUploaded = false;

  Map<String, dynamic>? userProfileData;
  List<Map<String, dynamic>> userDocuments = [];

  final FormGroup form = fb.group({
    'name': FormControl<String>(
        value: "", validators: [Validators.required, Validators.minLength(3)]),
    'email': FormControl<String>(value: "", validators: [Validators.email]),
    'phoneNumber': FormControl<String>(value: "", validators: [
      Validators.required,
      Validators.minLength(10),
      Validators.maxLength(10),
      Validators.number()
    ]),
  });

  Future<void> _pickFile(String documentType) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      // Update the appropriate file based on document type
      setState(() {
        switch (documentType) {
          case 'license':
            _selectedLicense = file;
            break;
          case 'insurance':
            _selectedInsurance = file;
            break;
          case 'rc':
            _selectedRc = file;
            break;
        }
      });

      // Upload the file using the WebSocket service
      final socketService = SocketService();

      try {
        final additionalData = {
          'userId': '12345', // Replace with actual user ID
          'documentType': documentType,
        };

        final List<FileUpload> uploadedFiles = await socketService.send(
          files: [file],
          additionalData: additionalData,
        );

        if (uploadedFiles.isNotEmpty) {
          final uploadedFile = uploadedFiles.first;
          print('File uploaded successfully: ${uploadedFile.mediaUrl}');

          setState(() {
            switch (documentType) {
              case 'license':
                _isLicenseUploaded = true;
                break;
              case 'insurance':
                _isInsuranceUploaded = true;
                break;
              case 'rc':
                _isRcUploaded = true;
                break;
            }
          });
        } else {
          print('No files were uploaded.');
        }
      } catch (e) {
        print('Error uploading file: $e');
        // Handle the error
      }
    }
  }

  Widget _buildProfileInfoSection() {
    if (userProfileData == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    final profile = userProfileData?['profile'] ?? {};
    final documents = userProfileData?['documents'] ?? [];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildProfileHeader(profile),
          const SizedBox(height: 24),
          _buildProfileDetailsCard(profile),
          const SizedBox(height: 24),
          _buildDocumentsSection(documents),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> profile) {
    final String name = profile['name'] ?? 'User';
    final String initials = name.isNotEmpty
        ? name
            .split(' ')
            .where((e) => e.isNotEmpty)
            .map((e) => e[0])
            .take(2)
            .join('')
            .toUpperCase()
        : 'U';

    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ProfileTheme.secondaryColor,
                ProfileTheme.secondaryColor.withOpacity(0.7)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                profile['email'] ?? 'No email provided',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // IconButton(
        //   icon: Container(
        //     padding: const EdgeInsets.all(8),
        //     decoration: BoxDecoration(
        //       color: ProfileTheme.secondaryColor.withOpacity(0.2),
        //       shape: BoxShape.circle,
        //     ),
        //     child: const Icon(
        //       Icons.edit_outlined,
        //       color: ProfileTheme.secondaryColor,
        //       size: 20,
        //     ),
        //   ),
        //   onPressed: () {
        //     // Implement navigation to edit profile
        //   },
        // ),
      ],
    );
  }

  Widget _buildProfileDetailsCard(Map<String, dynamic> profile) {
    return Card(
      elevation: 0,
      color: ProfileTheme.cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailItem(
              icon: Icons.person_outline,
              label: 'Name',
              value: profile['name'] ?? 'Not provided',
            ),
            const Divider(color: Colors.grey, height: 32, thickness: 0.5),
            _buildDetailItem(
              icon: Icons.email_outlined,
              label: 'Email',
              value: profile['email'] ?? 'Not provided',
            ),
            const Divider(color: Colors.grey, height: 32, thickness: 0.5),
            _buildDetailItem(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: profile['phoneNumber'] ?? 'Not provided',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ProfileTheme.secondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: ProfileTheme.secondaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentsSection(List<dynamic> documents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Uploaded Documents',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            // if (documents.isNotEmpty)
            //   TextButton.icon(
            //     onPressed: () {
            //       // Implement action to manage documents
            //     },
            //     icon: const Icon(
            //       Icons.add_circle_outline,
            //       color: ProfileTheme.secondaryColor,
            //       size: 18,
            //     ),
            //     label: Text(
            //       'Add More',
            //       style: TextStyle(
            //         color: ProfileTheme.secondaryColor,
            //         fontSize: 14,
            //         fontWeight: FontWeight.w500,
            //       ),
            //     ),
            //     style: TextButton.styleFrom(
            //       padding: EdgeInsets.zero,
            //       minimumSize: const Size(50, 30),
            //       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            //     ),
            //   ),
          ],
        ),
        const SizedBox(height: 16),
        if (documents.isEmpty)
          Card(
            elevation: 0,
            color: ProfileTheme.cardBackgroundColor.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.file_copy_outlined,
                    color: Colors.white.withOpacity(0.5),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No documents uploaded yet',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your documents to complete your profile',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Implement document upload action
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Documents'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: ProfileTheme.secondaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          _buildDocumentsList(documents),
      ],
    );
  }

  Widget _buildDocumentsList(List<dynamic> documents) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index];
        return _buildDocumentCard(doc);
      },
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> document) {
    final String documentName = document['document_name'] ?? 'Document';
    final String mediaType = document['media_type'] ?? '';
    final String dateString = document['created_on'] ?? '';

    return Card(
      elevation: 2,
      color: ProfileTheme.cardBackgroundColor.withOpacity(0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // Implement document preview
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getDocumentColor(mediaType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getDocumentIcon(mediaType),
                      color: _getDocumentColor(mediaType),
                      size: 24,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: ProfileTheme.cardBackgroundColor,
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility,
                                color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('View', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'download',
                        child: Row(
                          children: [
                            Icon(Icons.download, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Download',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'replace',
                        child: Row(
                          children: [
                            Icon(Icons.replay, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Replace',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      // Handle selection
                    },
                  ),
                ],
              ),
              const Spacer(),
              Text(
                _formatDocumentName(documentName),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.white.withOpacity(0.5),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _formatDate(dateString),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getDocumentIcon(String? mediaType) {
    if (mediaType == 'image') return Icons.image_outlined;
    if (mediaType == 'pdf') return Icons.picture_as_pdf_outlined;
    return Icons.insert_drive_file_outlined;
  }

  Color _getDocumentColor(String? mediaType) {
    if (mediaType == 'image') return Colors.blue;
    if (mediaType == 'pdf') return Colors.red;
    return Colors.amber;
  }

  String _formatDocumentName(String name) {
    if (name.length > 15) {
      return '${name.substring(0, 15)}...';
    }
    return name;
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Upload date unknown';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays < 1) {
        return 'Today';
      } else if (difference.inDays < 2) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Upload date unknown';
    }
  }

  Future<void> _submitProfileAndDocuments() async {
    if (!form.invalid) {
      setState(() {
        _isSubmitting = true; // Set loading state to true
      });

      final socketService = SocketService();
      final user = await tokenService.getUser();

      // Step 1: Prepare profile data
      final profileData = {
        'user_profile_sno': user!.userProfileSno,
        'name': form.control('name').value,
        'email': form.control('email').value,
        'phoneNumber': form.control('phoneNumber').value,
      };

      // Step 2: Prepare documents data with non-null mediaList
      final documents = {
        'mediaSno': null,
        'containerName': null,
        'mediaList': <Map<String, dynamic>>[],
      };

      // Helper function to add document to mediaList
      Future<void> addDocument(File? file, bool isUploaded, String documentType,
          int docTypeCode, String container) async {
        if (file != null && isUploaded) {
          final uploadedFiles = await socketService.send(
            files: [file],
            additionalData: {
              'userId': user.userProfileSno.toString(),
              'documentType': documentType
            },
          );
          if (uploadedFiles.isNotEmpty) {
            final file = uploadedFiles.first;
            documents['mediaList']?.add({
              'documentType': docTypeCode,
              'mediaUrl': file.mediaUrl,
              'contentType': file.contentType,
              'mediaType': file.mediaType,
              'mediaSize': file.mediaSize,
              'azureId': file.azureId,
              'isUploaded': true,
              'containerName': container,
            });
          }
        }
      }

      // Step 3: Add uploaded documents to mediaList
      await addDocument(_selectedLicense, _isLicenseUploaded, 'Driving License',
          58, 'licenceImage');
      await addDocument(_selectedInsurance, _isInsuranceUploaded, 'Insurance',
          97, 'vehicleImage');
      await addDocument(_selectedRc, _isRcUploaded, 'Rc', 98, 'vehicleImage');

      // Step 4: Combine profile and documents into request data
      final requestData = {
        'profile': profileData,
        'documents': documents,
      };

      // Step 5: Send data to backend via BLoC
      profileBloc.add(SubmitProfile(requestData));

      setState(() {
        _isSubmitting = false; // Set loading state to false after submission
      });
    }
  }

  @override
  void initState() {
    getUserDetails();
    loadUserProfile();
    super.initState();
  }

  void loadUserProfile() async {
    Createuser? user = await tokenService.getUser();
    print('user${jsonEncode(user?.userProfileSno)}');
    if (user != null && user.userProfileSno != null) {
      profileBloc.add(GetUserProfile(userProfileSno: user.userProfileSno!));
    }
  }

  getUserDetails() async {
    Createuser? user = await tokenService.getUser();
    form.patchValue({
      "name": user!.name,
      "email": user.email.isNullOrEmpty ? "" : user.email,
      "phoneNumber": user.mobileNumber,
    });
    profileBloc.add(CheckPageValid(pageInvalid: form.invalid));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => profileBloc,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: ProfileTheme.blackColor,
          appBar: AppBar(
            surfaceTintColor: ProfileTheme.blackColor,
            backgroundColor: ProfileTheme.blackColor,
            automaticallyImplyLeading: true,
            iconTheme: const IconThemeData(color: AppTheme.whiteColor),
            title: const Text(
              "Personal information",
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  fontFamily: 'Poppins'),
            ),
            centerTitle: true,
          ),
          body: BlocConsumer<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is CheckPageValidState) {
                pageIsInvalid = state.isCheckPageValid;
              }
              if (state is UserProfileLoadedState) {
                setState(() {
                  userProfileData = state.profileData;
                  // Convert List<dynamic> to List<Map<String, dynamic>>
                  userDocuments =
                      (state.profileData['documents'] as List).map((doc) {
                    return Map<String, dynamic>.from(doc);
                  }).toList();
                });
              }
              if (state is PersonalInfoSubmissionSuccess) {
                showCustomSuccessAlertDialog(
                  dialogBackgroundColor: ProfileTheme.whiteColor,
                  header: Image.asset("assets/images/header-img.png"),
                  title: 'Update successful',
                  titleColor: ProfileTheme.secondaryColor,
                  context: context,
                  content: "Updated personal information successfully",
                  onConfirm: () {
                    Navigator.pop(context);
                  },
                  confirmButtonColor: ProfileTheme.secondaryColor,
                  confirmButtonTextColor: ProfileTheme.whiteColor,
                );
              } else if (state is PersonalInfoSubmissionFailure) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: Text(state.errorMessage),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is LoadingState) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Show profile info if we have data, otherwise show the form
                    if (userProfileData != null && userDocuments.isNotEmpty)
                      _buildProfileInfoSection(),
                    if (userProfileData == null || userDocuments.isEmpty) ...[
                      const SizedBox(height: 24),
                      ReactiveForm(
                        formGroup: form,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              _buildNameInput(context),
                              _buildEmailInput(context),
                              _buildPhoneNoInput(context),
                              _buildIdProofInput(context),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        color: ProfileTheme.blackColor,
                        margin: const EdgeInsets.all(24),
                        width: MediaQuery.sizeOf(context).width,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            foregroundColor: ProfileTheme.whiteColor,
                            backgroundColor: pageIsInvalid
                                ? ProfileTheme.whiteColor.withOpacity(0.5)
                                : ProfileTheme.whiteColor,
                          ),
                          onPressed: pageIsInvalid || _isSubmitting
                              ? null // Disable button when submitting or invalid
                              : () {
                                  _submitProfileAndDocuments();
                                },
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Update',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Avenir',
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNameInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'First ans last name',
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
            color: ProfileTheme.cardBackgroundColor,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: ReactiveTextField(
                      maxLength: 10,
                      textInputAction: TextInputAction.done,
                      formControlName: "name",
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter name',
                        contentPadding: EdgeInsets.symmetric(vertical: 6.0),
                        counterText: '',
                      ),
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w800),
                      onChanged: (value) {
                        profileBloc
                            .add(CheckPageValid(pageInvalid: form.invalid));
                      },
                      showErrors: (control) => false,
                    ),
                  ),
                ),
              ],
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
            'required': (control) => 'Please enter the name',
            'minLength': (control) => 'Please enter the minmum 3 characters',
          },
        )
      ],
    );
  }

  Widget _buildEmailInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Email',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
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
            color: ProfileTheme.cardBackgroundColor,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: ReactiveTextField(
                      textInputAction: TextInputAction.done,
                      formControlName: "email",
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter Email',
                        contentPadding: EdgeInsets.symmetric(vertical: 6.0),
                        counterText: '',
                      ),
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w800),
                      onChanged: (value) {
                        profileBloc
                            .add(CheckPageValid(pageInvalid: form.invalid));
                      },
                      showErrors: (control) => false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ReactiveFormField(
          formControlName: "email",
          builder: (field) {
            return field.errorText != null
                ? Text(
                    '${field.errorText}',
                    style: const TextStyle(color: Colors.red),
                  )
                : Container(); // or SizedBox.shrink() to take up no space
          },
          validationMessages: {
            'email': (control) => 'Please enter the valid email',
          },
        )
      ],
    );
  }

  Widget _buildPhoneNoInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Phone number',
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
            color: ProfileTheme.cardBackgroundColor,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: ReactiveTextField(
                      readOnly: true,
                      maxLength: 10,
                      textInputAction: TextInputAction.done,
                      formControlName: "phoneNumber",
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter phone number',
                        contentPadding: EdgeInsets.symmetric(vertical: 6.0),
                        counterText: '',
                      ),
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w800),
                      onChanged: (value) {},
                      showErrors: (control) => false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ReactiveFormField(
          formControlName: "phoneNumber",
          builder: (field) {
            return field.errorText != null
                ? Text(
                    '${field.errorText}',
                    style: const TextStyle(color: Colors.red),
                  )
                : Container(); // or SizedBox.shrink() to take up no space
          },
          validationMessages: {
            'required': (control) => 'Please enter the email',
          },
        )
      ],
    );
  }

  Widget _buildIdProofInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Text(
          'Documents',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDocumentUploader(
                context: context,
                title: "Driver's License",
                documentType: 'license',
                selectedFile: _selectedLicense,
                isUploaded: _isLicenseUploaded,
              ),
              const SizedBox(height: 16),
              _buildDocumentUploader(
                context: context,
                title: "Insurance Document",
                documentType: 'insurance',
                selectedFile: _selectedInsurance,
                isUploaded: _isInsuranceUploaded,
              ),
              const SizedBox(height: 16),
              _buildDocumentUploader(
                context: context,
                title: "RC Document",
                documentType: 'rc',
                selectedFile: _selectedRc,
                isUploaded: _isRcUploaded,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentUploader({
    required BuildContext context,
    required String title,
    required String documentType,
    required File? selectedFile,
    required bool isUploaded,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickFile(documentType),
          child: Container(
            width: double.infinity,
            height: 150,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[800]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: selectedFile != null
                ? selectedFile.path.endsWith(".pdf")
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.picture_as_pdf,
                            size: 60,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isUploaded ? '$title Uploaded' : 'Uploading...',
                            style: TextStyle(
                              color: isUploaded ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Image.file(
                          selectedFile,
                          fit: BoxFit.contain,
                        ),
                      )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isUploaded
                              ? '$title Uploaded'
                              : 'Tap to upload $title',
                          style: TextStyle(
                            color: isUploaded ? Colors.green : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Image.asset(
                          'assets/images/arrow.png',
                          width: 24,
                          height: 24,
                          color: isUploaded ? Colors.green : Colors.grey,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
