import 'package:elgumailer/widgets/buttons/custom_button.dart';
import 'package:elgumailer/widgets/dialog/custom_alert_dialog.dart';
import 'package:elgumailer/widgets/text_field/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:io';

class EmailSendingScreen extends StatefulWidget {
  final String email;
  final String password;
  final SmtpServer smtpServer;
  final List<Map<String, String>> emailsToSend;

  const EmailSendingScreen({
    super.key,
    required this.email,
    required this.password,
    required this.smtpServer,
    required this.emailsToSend,
  });

  @override
  _EmailSendingScreenState createState() => _EmailSendingScreenState();
}

class _EmailSendingScreenState extends State<EmailSendingScreen> {
  int sentCount = 0;
  bool isSending = false;
  String senderName = "eLGU DICT Caraga"; // Default sender name
  final TextEditingController _senderNameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Ensure dialog is shown after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSenderNameDialog();
    });
  }

  void _showSenderNameDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: Colors.white,
          elevation: 10.0,
          title: const Text(""),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Image.asset(
                  "lib/ui/assets/sample_image.png",
                  // Replace with your actual GIF path
                  height: 200,
                  width: 300,
                ),
              ),
              CustomTextField(
                controller: _senderNameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Sender Name";
                  }
                  return null;
                },
                isPassword: false,
                hintText: "e.g. DICT eLGU Caraga",
              ),
            ],
          ),
          actions: [
            Column(
              children: <Widget>[
                CustomButton(
                  buttonLabel: "Confirm",
                  onPressed: () {
                    setState(() {
                      senderName = _senderNameController.text.isNotEmpty
                          ? _senderNameController.text
                          : "eLGU DICT Caraga";
                    });
                    Navigator.pop(context);
                    _sendEmails();
                  },
                  buttonHeight: 50,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  fontColor: Colors.white,
                  borderRadius: 5,
                  gradientColors: const [
                    Color(0xFF434343), Color(0xFF242424),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),
            CustomButton(
              buttonLabel: "Cancel",
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              buttonHeight: 50,
              fontSize: 12,
              fontWeight: FontWeight.normal,
              fontColor: Colors.white,
              borderRadius: 5,
              gradientColors: const [
                Color(0xfff5747f), Color(0xFFf5394b),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Function to Send Emails
  Future<void> _sendEmails() async {
    setState(() {
      isSending = true;
      sentCount = 0;
    });

    for (int i = 0; i < widget.emailsToSend.length; i++) {
      var emailData = widget.emailsToSend[i];
      String recipient = emailData['recipient']!;
      String subject = emailData['subject']!;
      String body = emailData['body']!;
      String attachmentPath = emailData['attachmentPath']!;

      final message = Message()
        ..from = Address(widget.email, senderName) // Use user input
        ..recipients.add(recipient)
        ..subject = subject
        ..text = body;

      if (attachmentPath.isNotEmpty) {
        File attachmentFile = File(attachmentPath);
        if (await attachmentFile.exists()) {
          message.attachments.add(FileAttachment(attachmentFile));
        }
      }

      try {
        await send(message, widget.smtpServer);
        setState(() {
          sentCount = i + 1;
        });
      } catch (e) {
        print('❌ Failed to send email to $recipient: $e');
      }
    }

    setState(() {
      isSending = false;
    });

    // ✅ Show success dialog after sending all emails
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            message: "Emails Sent Successfully!",
            backGroundColor: Colors.white,
            onPressed: () {
              Navigator.pop(context); // Dismiss dialog
              Navigator.pop(context); // Go back to previous screen
            },
            filePath: "lib/ui/assets/email_sent.gif",
            buttonLabel: 'EXIT',
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xff73a8c7), // Light to dark blue gradient
            ],
          ),
        ),
        child: Center(
          child: isSending
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "lib/ui/assets/sending_email.gif",
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Sending email $sentCount / ${widget.emailsToSend.length}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : Container(), // DISPLAY NOTHING
        ),
      ),
    );
  }
}
