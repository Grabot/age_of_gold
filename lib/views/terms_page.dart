import 'package:flutter/material.dart';

import '../util/util.dart';


class TermsPage extends StatefulWidget {

  static const String route = '/terms';

  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Center(
                child: ageOfGoldLogo(width, true)
            ),
            SelectionArea(
              child: Container(
                padding: const EdgeInsets.all(40.0),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text(
                        "End-User License Agreement (EULA) of Age of Gold",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 30, fontWeight: FontWeight.bold)
                    ),
                    SizedBox(height: 10),
                    Text(
                        "This End-User License Agreement (\"EULA\") is a legal agreement between you and Zwaar developers.",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    SizedBox(height: 10),
                    Text(
                        "This EULA agreement governs your acquisition and use of our Age of Gold software (\"Software\") directly from Zwaar developers or indirectly through a Zwaar developers authorized reseller or distributor (a \"Reseller\").",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    SizedBox(height: 10),
                    Text(
                        "Please read this EULA agreement carefully before completing the installation process and using the Age of Gold software. It provides a license to use the Age of Gold software and contains warranty information and liability disclaimers.",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    SizedBox(height: 10),
                    Text(
                        "If you register for a free trial of the Age of Gold software, this EULA agreement will also govern that trial. By clicking \"accept\" or installing and/or using the Age of Gold software, you are confirming your acceptance of the Software and agreeing to become bound by the terms of this EULA agreement.",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    SizedBox(height: 10),
                    Text(
                        "If you are entering into this EULA agreement on behalf of a company or other legal entity, you represent that you have the authority to bind such entity and its affiliates to these terms and conditions. If you do not have such authority or if you do not agree with the terms and conditions of this EULA agreement, do not install or use the Software, and you must not accept this EULA agreement.",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    SizedBox(height: 10),
                    Text(
                        "This EULA agreement shall apply only to the Software supplied by Zwaar developers here with regardless of whether other software is referred to or described herein. The terms also apply to any Zwaar developers updates, supplements, Internet-based services, and support services for the Software, unless other terms accompany those items on delivery. If so, those terms apply",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    SizedBox(height: 30),
                    Text(
                        "License Grant",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 24, fontWeight: FontWeight.bold)
                    ),
                    SizedBox(height: 10),
                    Text(
                        "Zwaar developers hereby grants you a personal, non-transferable, non-exclusive licence to use the Age of Gold software on your devices in accordance with the terms of this EULA agreement.",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    SizedBox(height: 10),
                    Text(
                        "You are permitted to load the Age of Gold software (for example a PC, laptop, mobile or tablet) under your control. You are responsible for ensuring your device meets the minimum requirements of the Age of Gold software.",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    SizedBox(height: 10),
                    Text(
                        "You are not permitted to:",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    SizedBox(height: 20),
                    Text(
                        "\t\t ⚈ Edit, alter, modify, adapt, translate or otherwise change the whole or any part of the Software nor permit the whole or any part of the Software to be combined with or become incorporated in any other software, nor decompile, disassemble or reverse engineer the Software or attempt to do any such things",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    Text(
                        "\t\t ⚈ Reproduce, copy, distribute, resell or otherwise use the Software for any commercial purpose",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    Text(
                        "\t\t ⚈ Allow any third party to use the Software on behalf of or for the benefit of any third party",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    Text(
                        "\t\t ⚈ Use the Software in any way which breaches any applicable local, national or international law",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    Text(
                        "\t\t ⚈ use the Software for any purpose that Zwaar developers considers is a breach of this EULA agreement",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    SizedBox(height: 30),
                    Text(
                        "Intellectual Property and Ownership",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 24, fontWeight: FontWeight.bold)
                    ),
                    SizedBox(height: 10),
                    Text(
                        "Zwaar developers shall at all times retain ownership of the Software as originally downloaded by you and all subsequent downloads of the Software by you. The Software (and the copyright, and other intellectual property rights of whatever nature in the Software, including any modifications made thereto) are and shall remain the property of Zwaar developers.",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    SizedBox(height: 10),
                    Text(
                        "Zwaar developers reserves the right to grant licences to use the Software to third parties.",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    SizedBox(height: 30),
                    Text(
                        "Termination",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 24, fontWeight: FontWeight.bold)
                    ),
                    SizedBox(height: 10),
                    Text(
                        "This EULA agreement is effective from the date you first use the Software and shall continue until terminated. You may terminate it at any time upon written notice to Zwaar developers.",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    SizedBox(height: 10),
                    Text(
                        "It will also terminate immediately if you fail to comply with any term of this EULA agreement. Upon such termination, the licenses granted by this EULA agreement will immediately terminate and you agree to stop all access and use of the Software. The provisions that by their nature continue and survive will survive any termination of this EULA agreement.",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    SizedBox(height: 30),
                    Text(
                        "Governing Law",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 24, fontWeight: FontWeight.bold)
                    ),
                    SizedBox(height: 10),
                    Text(
                        "This EULA agreement, and any dispute arising out of or in connection with this EULA agreement, shall be governed by and construed in accordance with the laws of nl.",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

