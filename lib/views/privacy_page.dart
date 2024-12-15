import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../util/util.dart';


class PrivacyPage extends StatefulWidget {

  static const String route = '/privacy';

  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                        "Privacy Policy",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 30, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 10),
                    const Text(
                        "Zwaar Developers built the Hex Place app as an Open Source game app. This GAME and SERVICE is provided by Zwaar Developers at no cost and is intended for use as is.",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    const SizedBox(height: 10),
                    const Text(
                        "This page is used to inform visitors regarding our policies with the collection, use, and disclosure of Personal Information if anyone decided to use my Service.",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    const SizedBox(height: 10),
                    const Text(
                        "If you choose to use my Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that We collect is used for providing and improving the Service. I will not use or share your information with anyone except as described in this Privacy Policy.",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    const SizedBox(height: 10),
                    const Text(
                        "The terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which is accessible at Hex Place unless otherwise defined in this Privacy Policy.",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    const SizedBox(height: 30),
                    const Text(
                        "Information Collection and Use",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 24, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 10),
                    const Text(
                        "For a better experience, while using our Service, we may require you to provide us with certain personally identifiable information, this information is an optional email address.",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    const SizedBox(height: 10),
                    const Text(
                        "Link to privacy policy of third party service providers used by the app",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    const SizedBox(height: 30),
                    InkWell(
                        child: const Text(
                            '\t\t ⚈ Google Play Services',
                            style: TextStyle(color: Color(0xff5971dc), fontSize: 16)
                        ),
                        onTap: () {
                          final Uri url = Uri.parse('https://policies.google.com/privacy');
                          _launchUrl(url);
                        }
                    ),
                    const SizedBox(height: 30),
                    const Text(
                        "Log Data",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 24, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 10),
                    const Text(
                        "We want to inform you that whenever you use our games and Services, in a case of an error in the app we collect data and information (through third party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol (\"IP\") address, device name, operating system version, the configuration of the app when utilizing our Games and Services, the time and date of your use of the Game and Service, and other statistics.",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    const SizedBox(height: 30),
                    const Text(
                        "Cookies",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 24, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 10),
                    const Text(
                        "Cookies are files with a small amount of data that are commonly used as anonymous unique identifiers. These are sent to your browser from the websites that you visit and are stored on your device's internal memory.",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    const SizedBox(height: 10),
                    const Text(
                        "This Game and Service does not use these \"cookies\" explicitly. However, the app may use third party code and libraries that use \"cookies\" to collect information and improve their services. You have the option to either accept or refuse these cookies and know when a cookie is being sent to your device. If you choose to refuse our cookies, you may not be able to use some portions of this Service.",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    const SizedBox(height: 30),
                    const Text(
                        "Service Providers",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 24, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 10),
                    const Text(
                        "We may employ third-party companies and individuals due to the following reasons:",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    const SizedBox(height: 20),
                    const Text(
                        "\t\t ⚈ To facilitate our Service;",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    const Text(
                        "\t\t ⚈ To provide the Service on our behalf;",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    const Text(
                        "\t\t ⚈ To perform Service-related services; or",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    const Text(
                        "\t\t ⚈ To assist us in analyzing how our Service is used.",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    const SizedBox(height: 30),
                    const Text(
                        "We want to inform users of this Service that these third parties have access to your Personal Information. The reason is to perform the tasks assigned to them on our behalf. However, they are obligated not to disclose or use the information for any other purpose.",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    const SizedBox(height: 30),
                    const Text(
                        "Security",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 24, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 10),
                    const Text(
                        "We value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and we cannot guarantee its absolute security.",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    const SizedBox(height: 30),
                    const Text(
                        "Children’s Privacy",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 24, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 10),
                    const Text(
                        "These Services do not address anyone under the age of 13. I do not knowingly collect personally identifiable information from children under 13 years of age. In the case we discover that a child under 13 has provided me with personal information, we immediately delete this from our servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact us so that I will be able to do necessary actions.",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    const SizedBox(height: 30),
                    const Text(
                        "Changes to This Privacy Policy",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 24, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 10),
                    const Text(
                        "We may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Privacy Policy on this page.",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    const SizedBox(height: 10),
                    const Text(
                        "This policy is effective as of 06-12-2023",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 16)
                    ),
                    const SizedBox(height: 30),
                    const Text(
                        "Contact Us",
                        style: TextStyle(color: Color(0xfff1f1f1), fontSize: 24, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 10),
                    const Text(
                        "If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at SanderKools@zwaar.dev",
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

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

}

