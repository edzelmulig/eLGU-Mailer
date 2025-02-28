import 'package:elgumailer/ui/screens/email_sending_screen.dart';
import 'package:elgumailer/widgets/buttons/custom_button.dart';
import 'package:elgumailer/widgets/dialog/custom_alert_dialog.dart';
import 'package:elgumailer/widgets/images/custom_image_display.dart';
import 'package:elgumailer/widgets/loading_indicator/custom_loading_indicator.dart';
import 'package:elgumailer/widgets/text_field/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // CONTROLLERS
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _userEmailController;
  late final TextEditingController _userPasswordController;
  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;

  // INITIALIZATION
  @override
  void initState() {
    super.initState();
    _userEmailController = TextEditingController();
    _userPasswordController = TextEditingController();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  // DISPOSING
  @override
  void dispose() {
    _userEmailController.dispose();
    _userPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // FUNCTION TO AUTHENTICATE LOGIN
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if validation fails
    }

    final email = _userEmailController.text.trim();
    final password = _userPasswordController.text.trim();

    await sendBulkEmails(context, email, password);
  }

  // DOWNLOAD EXCEL TEMPLATE
  Future<void> downloadTemplate(BuildContext context) async {
    try {
      await requestStoragePermission(); // Ensure permissions before proceeding

      // Load the template file from assets
      ByteData data = await rootBundle.load('lib/ui/assets/template.xlsx');
      List<int> bytes = data.buffer.asUint8List();

      // Get the public Downloads directory
      Directory? downloadsDir = Directory('/storage/emulated/0/Download');
      if (!downloadsDir.existsSync()) {
        downloadsDir = await getExternalStorageDirectory();
      }

      if (downloadsDir == null) {
        throw Exception("❌ Unable to access storage directory.");
      }

      String filePath = '${downloadsDir.path}/template.xlsx';
      File file = File(filePath);
      await file.writeAsBytes(bytes);

      // Show success message
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlertDialog(
              message:
                  "Template file has been successfully downloaded. at $file",
              backGroundColor: Colors.white,
              onPressed: () {
                Navigator.pop(context); // Dismiss the dialog
              },
              filePath: "lib/ui/assets/download_successful.gif",
              buttonLabel: 'OK',
            );
          },
        );
      }
    } catch (e) {
      print("❌ Download error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to download template")),
      );
    }
  }

// REQUEST STORAGE PERMISSION FUNCTION
  Future<void> requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        print("✅ Storage permission granted");
        return;
      }

      if (await Permission.storage.isPermanentlyDenied) {
        print("⚠️ Storage permission permanently denied, opening settings...");
        await openAppSettings();
        return;
      }

      if (await Permission.manageExternalStorage.request().isDenied) {
        print("❌ Manage External Storage permission denied");
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white, // Light Blue
              Color(0xff73a8c7), // Dark Blue
            ],
          ),
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              IconButton(
                                icon: Image.asset(
                                  'lib/ui/assets/excel_icon.png',
                                  // Replace with your image path
                                  width: 50, // Adjust size as needed
                                  height: 50,
                                ),
                                onPressed: () async {
                                  try {
                                    await downloadTemplate(context);
                                  } catch (e, stacktrace) {
                                    print(
                                        "❌ Error on button press: $e\n$stacktrace");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text("❌ An error occurred: $e")),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),

                          // APP LOGO
                          Center(
                            child: CustomImageDisplay(
                              imageSource: "lib/ui/assets/logo_app.png",
                              imageHeight: screenHeight * 0.30,
                              imageWidth: screenWidth * 0.30,
                            ),
                          ),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                const SizedBox(height: 8),

                                // EMAIL TEXT FIELD
                                _EmailTextField(
                                  controller: _userEmailController,
                                  currentFocusNode: _emailFocusNode,
                                  nextFocusNode: _passwordFocusNode,
                                ),

                                const SizedBox(height: 8),

                                // PASSWORD TEXT FIELD
                                _PasswordTextField(
                                  controller: _userPasswordController,
                                  currentFocusNode: _passwordFocusNode,
                                  nextFocusNode: null,
                                ),

                                const SizedBox(height: 18),

                                // Login Button
                                _LoginButton(onPressed: _login),

                                SizedBox(
                                  height:
                                      MediaQuery.of(context).viewInsets.bottom,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // "Powered by eLGU Caraga" at the bottom
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Column(

                  children: <Widget>[
                    Text(
                      "Powered by",
                      style: TextStyle(color: Color(0xFF242424), fontSize: 12),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CustomImageDisplay(
                          imageSource: "lib/ui/assets/eLGU_logo.png",
                          imageHeight: 20,
                          imageWidth: 100,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> sendBulkEmails(
  BuildContext context,
  String email,
  String password,
) async {
  if (email.isEmpty || password.isEmpty) {
    print('❌ Email or password is missing.');
    return;
  }

  // 🔵 Show loading indicator while checking credentials
  showLoadingIndicator(context);

  final smtpServer = SmtpServer(
    'smtp.gmail.com',
    username: email,
    password: password,
    port: 587,
    ignoreBadCertificate: true,
    ssl: false,
    allowInsecure: true,
  );

  try {
    final connection = PersistentConnection(smtpServer);
    await connection.send(
      Message()
        ..from = Address(email, 'Test Validation')
        ..recipients.add(email)
        ..subject = 'SMTP Authentication Test'
        ..text = 'This is a test email to verify SMTP authentication.',
    );
    await connection.close();

    if (context.mounted) {
      Navigator.pop(context); // ✅ Hide loading
    }

    print('✅ Email account is valid. Proceeding...');
  } catch (e) {
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Invalid Email or Password!')),
      );
    }
    print('❌ Invalid email credentials. Aborting...');
    return;
  }

  // 🔽 **Step 2: Proceed with file selection**
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xlsx'],
  );

  if (result == null) {
    print('❌ No file selected.');
    return;
  }

  Uint8List? bytes = result.files.single.bytes;
  if (bytes == null) {
    if (result.files.single.path != null) {
      bytes = await File(result.files.single.path!).readAsBytes();
    } else {
      print('❌ Unable to read file.');
      return;
    }
  }

  print("✅ VALID FILE SELECTED");

  var excel = Excel.decodeBytes(bytes);
  var sheetNames = excel.tables.keys.toList();

  if (sheetNames.isEmpty) {
    print('❌ No sheets found in the Excel file.');
    return;
  }

  var sheet = excel.tables[sheetNames.first];
  if (sheet == null || sheet.rows.isEmpty) {
    print('❌ Excel sheet is empty.');
    return;
  }

  List<Map<String, String>> emailsToSend = [];
  for (int i = 1; i < sheet.rows.length; i++) {
    var row = sheet.rows[i];
    String recipient = row[0]?.value.toString().trim() ?? '';
    String subject = row[1]?.value.toString().trim() ?? '';
    String body = row[2]?.value.toString().trim() ?? '';
    String attachmentPath = row[3]?.value.toString().trim() ?? '';

    if (recipient.isNotEmpty && subject.isNotEmpty && body.isNotEmpty) {
      emailsToSend.add({
        'recipient': recipient,
        'subject': subject,
        'body': body,
        'attachmentPath': attachmentPath,
      });
    }
  }

  if (emailsToSend.isEmpty) {
    print('❌ No valid email data found in the Excel file.');
    return;
  }

  // Navigate to Email Sending Screen
  if (context.mounted) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmailSendingScreen(
          email: email,
          password: password,
          smtpServer: smtpServer,
          emailsToSend: emailsToSend,
        ),
      ),
    );
  }
}

// Private Email Text Field Widget
class _EmailTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode currentFocusNode;
  final FocusNode nextFocusNode;

  const _EmailTextField({
    required this.controller,
    required this.currentFocusNode,
    required this.nextFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.07),
      child: CustomTextField(
        controller: controller,
        currentFocusNode: currentFocusNode,
        nextFocusNode: nextFocusNode,
        inputFormatters: null,
        validator: (value) {
          if (value!.isEmpty) {
            return "Email is required";
          }
          return null;
        },
        isPassword: false,
        hintText: "Email",
        minLines: 1,
        maxLines: 1,
        prefixIcon: const Icon(Icons.email_rounded),
      ),
    );
  }
}

// Private Password Text Field Widget
class _PasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode currentFocusNode;
  final FocusNode? nextFocusNode;

  const _PasswordTextField({
    required this.controller,
    required this.currentFocusNode,
    this.nextFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.07),
      child: CustomTextField(
        controller: controller,
        currentFocusNode: currentFocusNode,
        nextFocusNode: nextFocusNode,
        inputFormatters: null,
        validator: (value) {
          if (value!.isEmpty) {
            return "Password is required";
          }
          return null;
        },
        isPassword: true,
        hintText: "Password",
        minLines: 1,
        maxLines: 1,
        prefixIcon: const Icon(Icons.lock_rounded),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _LoginButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.07),
      child: CustomButton(
        buttonLabel: "Sign In",
        onPressed: onPressed,
        buttonHeight: 55.0,
        fontWeight: FontWeight.bold,
        fontSize: 15,
        fontColor: Colors.white,
        borderRadius: 10,
        gradientColors: const [
          Color(0xFF00a2ff),
          Color(0xFF013dd6),
        ], // Blue gradient
      ),
    );
  }
}
