import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:particles_flutter/particles_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chatbot_dialog.dart';
import 'email_phishing.dart';
import 'malware.dart';
import 'url.dart';
import 'usb.dart';
import 'login_screen.dart';


class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {

  int selectedIndex = 0;
  bool collapsed = false;
  bool isLoggedIn = false;
  bool scanningOn = false;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  checkLogin() async {

  final prefs = await SharedPreferences.getInstance();

  setState(() {
    isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
  });

}

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Row(

        children: [

          sidebar(),

          Expanded(

            child: Stack(

              children: [

                background(),

                content(),

                aiButton(),

              ],

            ),

          ),

        ],

      ),

    );

  }

  // SIDEBAR

  Widget sidebar(){

    return AnimatedContainer(

      duration: 300.ms,

      width: collapsed ? 80 : 220,

      padding: const EdgeInsets.only(top:20),

      decoration: const BoxDecoration(

        color: Color(0xff020617),

        border: Border(
          right: BorderSide(color: Colors.white10),
        ),

      ),

      child: Column(

        children: [

          Align(

            alignment: Alignment.centerLeft,

            child: IconButton(

              icon: const Icon(Icons.menu,color: Colors.white),

              onPressed: (){

                setState(() {
                  collapsed = !collapsed;
                });

              },

            ),

          ),

          const SizedBox(height:10),

          CircleAvatar(

            radius: collapsed ? 20 : 35,

            backgroundImage: const AssetImage("assets/logo.jpeg"),

          ),

          if(!collapsed)

            Padding(

              padding: const EdgeInsets.only(top:10),

              child: Text(

                "CyberShield",

                style: GoogleFonts.orbitron(

                  color: Colors.greenAccent,

                  fontWeight: FontWeight.bold,

                ),

              ),

            ),

          const SizedBox(height:40),

          menuItem(0,Icons.home,"Home"),
          menuItem(1,Icons.grid_view,"Modules"),
          menuItem(2,Icons.bar_chart,"Analytics"),
          menuItem(3,Icons.email,"Contact"),

          const Spacer(),

          const Divider(color: Colors.white10),

          isLoggedIn
  ? menuItem(4, Icons.person, "Profile")
  : menuItem(4, Icons.login, "Login"),

          const SizedBox(height:20),

        ],

      ),

    );

  }

  Widget menuItem(int index, IconData icon, String text){

    bool active = selectedIndex == index;

    return InkWell(

      onTap: () async {

        if(index == 4){

  if(isLoggedIn){

    // 🔴 LOGOUT
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", false);

    setState(() {
      isLoggedIn = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Logged out")),
    );

  } else {

    // 🔵 LOGIN
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(),
      ),
    ).then((value) {
      if(value == true){
        checkLogin(); // 🔥 IMPORTANT
      }
    });

  }

  return;
}

        setState(() {
          selectedIndex = index;
        });

      },

      child: AnimatedContainer(

        duration: 200.ms,

        margin: const EdgeInsets.symmetric(horizontal:10,vertical:5),

        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(

          color: active
              ? Colors.greenAccent.withOpacity(.12)
              : Colors.transparent,

          borderRadius: BorderRadius.circular(10),

          border: Border.all(

            color: active
                ? Colors.greenAccent
                : Colors.transparent,

          ),

        ),

        child: Row(

          children: [

            Icon(
              icon,
              color: active
                  ? Colors.greenAccent
                  : Colors.white60,
            ),

            if(!collapsed)

              Padding(

                padding: const EdgeInsets.only(left:10),

                child: Text(

                  text,

                  style: TextStyle(

                    color: active
                        ? Colors.greenAccent
                        : Colors.white60,

                  ),

                ),

              ),

          ],

        ),

      ),

    );

  }

  // BACKGROUND

  Widget background(){

    return Stack(

      children: [

        Container(

          decoration: const BoxDecoration(

            gradient: LinearGradient(

              colors: [
                Color(0xff020617),
                Color(0xff031b16),
              ],

              begin: Alignment.topLeft,
              end: Alignment.bottomRight,

            ),

          ),

        ),

        CircularParticle(

          numberOfParticles: 60,
          speedOfParticles: .6,

          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,

          particleColor: Colors.greenAccent,
          maxParticleSize: 6,

          isRandomColor: false,
          connectDots: true,
          awayRadius: 120,

        ),

      ],


    );

  }

  // CONTENT SWITCH

  Widget content(){

    if(selectedIndex == 0) return homeUI();
    if(selectedIndex == 1) return modulesUI();
    if(selectedIndex == 2) return analyticsUI();

    return contactUI();

  }

  // HOME PAGE

  Widget homeUI(){

    return SingleChildScrollView(

      child: Center(

        child: Column(

          children: [

            const SizedBox(height:80),

            Text(

              "AI CYBER SECURITY",

              style: GoogleFonts.orbitron(

                fontSize: 46,

                color: Colors.greenAccent,

                fontWeight: FontWeight.bold,

              ),

            ).animate().fade().slideY(),

            const SizedBox(height:15),

            const Text(
              "Advanced protection for modern threats",
              style: TextStyle(color: Colors.white60),
            ),

            scanningAnimation(),

            moduleGrid(),

            miniGraph(),

            whyChooseUs(),

            const SizedBox(height:80),

          ],

        ),

      ),

    );

  }

  // PREMIUM AI SCANNING RING
  Widget modulesUI(){

  return SingleChildScrollView(

    child: Column(

      children: [

        const SizedBox(height:80),

        Text(

          "Security Modules",

          style: GoogleFonts.orbitron(

            fontSize: 42,

            color: Colors.greenAccent,

          ),

        ),

        const SizedBox(height:40),

        moduleGrid(),

        const SizedBox(height:80),

      ],

    ),

  );

}

  Widget scanningAnimation(){

    return Container(

      margin: const EdgeInsets.symmetric(vertical:40),

      child: Column(

        children: [

          GestureDetector(

            onTap: (){
              setState(() {
                scanningOn = !scanningOn;
              });
            },

            child: Container(

              padding: const EdgeInsets.symmetric(horizontal:18,vertical:8),

              decoration: BoxDecoration(

                borderRadius: BorderRadius.circular(20),

                border: Border.all(
                  color: scanningOn
                      ? Colors.greenAccent
                      : Colors.white24,
                ),

                boxShadow: scanningOn
                    ? [
                        BoxShadow(
                          color: Colors.greenAccent.withOpacity(.5),
                          blurRadius: 15,
                        )
                      ]
                    : [],

              ),

              child: Text(

                scanningOn
                    ? "LIVE SCANNING"
                    : "START SCAN",

                style: GoogleFonts.orbitron(

                  color: scanningOn
                      ? Colors.greenAccent
                      : Colors.white60,

                  letterSpacing: 2,

                ),

              ),

            ),

          ),

          const SizedBox(height:30),

          SizedBox(

            width: 200,
            height: 200,

            child: Stack(

              alignment: Alignment.center,

              children: [

                AnimatedOpacity(

                  duration: 600.ms,

                  opacity: scanningOn ? 1 : .2,

                  child: Container(

                    width: 200,
                    height: 200,

                    decoration: BoxDecoration(

                      shape: BoxShape.circle,

                      gradient: RadialGradient(

                        colors: [

                          Colors.greenAccent.withOpacity(.08),
                          Colors.transparent,

                        ],

                      ),

                    ),

                  ),

                ),

                rotatingRing(180, 2.5, true),
                rotatingRing(130, 1.5, false),

                AnimatedContainer(

                  duration: 500.ms,

                  width: scanningOn ? 85 : 65,
                  height: scanningOn ? 85 : 65,

                  decoration: BoxDecoration(

                    shape: BoxShape.circle,

                    gradient: RadialGradient(

                      colors: [

                        scanningOn
                            ? Colors.greenAccent
                            : Colors.white24,

                        Colors.transparent,

                      ],

                    ),

                    boxShadow: scanningOn
                        ? [

                            BoxShadow(

                              color: Colors.greenAccent.withOpacity(.8),
                              blurRadius: 35,

                            ),

                          ]
                        : [],

                  ),

                )

                .animate(
                  target: scanningOn ? 1 : 0,
                )

                .scale(
                  begin: const Offset(.9,.9),
                  end: const Offset(1.1,1.1),
                  duration: 2.seconds,
                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

  Widget rotatingRing(double size, double stroke, bool clockwise){

  return TweenAnimationBuilder<double>(

    tween: Tween<double>(
      begin: 0,
      end: scanningOn ? 6.28 : 0,
    ),

    duration: Duration(
      seconds: clockwise ? 6 : 8,
    ),

    builder:(context,value,child){

      double angle = clockwise ? value : -value;

      return Transform.rotate(

        angle: angle,

        child: CustomPaint(

          size: Size(size,size),

          painter: RingPainter(

            color: scanningOn
                ? Colors.greenAccent
                : Colors.white24,

            stroke: stroke,

          ),

        ),

      );

    },

    onEnd: (){

      if(scanningOn){

        setState((){});

      }

    },

  );

}

  Widget analyticsUI(){

  return Padding(
    padding: const EdgeInsets.all(20),

    child: Column(

      children: [

        /// TOP STATS
        Row(
          children: [

            Expanded(child: premiumCard("Total Threats", "\$2.48M", Colors.blue)),
            const SizedBox(width: 15),
            Expanded(child: premiumCard("Security Score", "97%", Colors.green)),
            const SizedBox(width: 15),
            Expanded(child: premiumCard("Devices", "1,234", Colors.orange)),

          ],
        ),

        const SizedBox(height: 20),

        /// GRAPH + MAP
        Expanded(
          child: Row(
            children: [

              /// GRAPH
              Expanded(
                flex: 2,
                child: glassBox(
                  child: Column(
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Live Statistics",
                              style: TextStyle(color: Colors.white)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal:10,vertical:4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white10,
                            ),
                            child: const Text("This Week",
                                style: TextStyle(fontSize: 12)),
                          )
                        ],
                      ),

                      const SizedBox(height: 20),

                      Expanded(child: fakeBarChart()),

                    ],
                  ),
                ),
              ),

              const SizedBox(width: 20),

              /// MAP
              Expanded(
                flex: 3,
                child: glassBox(
                  child: Stack(
                    children: [

                      const Center(
                        child: Text("🌍 Global Threat Map",
                            style: TextStyle(color: Colors.white54)),
                      ),

                      /// blinking points
                      Positioned(
                        left: 100,
                        top: 80,
                        child: pulseDot(Colors.red),
                      ),

                      Positioned(
                        right: 120,
                        bottom: 90,
                        child: pulseDot(Colors.blue),
                      ),

                      Positioned(
                        left: 200,
                        bottom: 60,
                        child: pulseDot(Colors.orange),
                      ),

                    ],
                  ),
                ),
              ),

            ],
          ),
        ),

      ],
    ),
  );
}
Widget premiumCard(String title, String value, Color color){
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        colors: [
          const Color(0xff0f172a),
          color.withOpacity(0.3),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(.5),
          blurRadius: 25,
        )
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white60)),
        const SizedBox(height: 10),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
Widget glassBox({required Widget child}){
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: const Color(0xff0f172a).withOpacity(0.7),
      border: Border.all(color: Colors.white10),
    ),
    child: child,
  );
}
Widget fakeBarChart(){
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: List.generate(7, (i){

      double h = 50 + Random().nextInt(120).toDouble();

      return AnimatedContainer(
        duration: Duration(milliseconds: 600 + i*100),
        width: 14,
        height: h,
        decoration: BoxDecoration(
          color: i % 2 == 0
              ? Colors.greenAccent
              : Colors.orangeAccent,
          borderRadius: BorderRadius.circular(6),
        ),
      );

    }),
  );
} 
Widget pulseDot(Color color){
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.5, end: 1.2),
    duration: const Duration(seconds: 1),
    builder: (_, value, __) {
      return Container(
        width: 12 * value,
        height: 12 * value,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.8),
              blurRadius: 20,
            )
          ],
        ),
      );
    },
    onEnd: () {},
  );
}
  Widget contactUI(){

  return Center(

    child: SingleChildScrollView(

      child: Column(

        children: [

          const SizedBox(height: 60),

          Text(
            "Contact & Support",
            style: GoogleFonts.orbitron(
              fontSize: 36,
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "We’re here to help you stay secure 🚀",
            style: TextStyle(color: Colors.white60),
          ),

          const SizedBox(height: 40),

          // 🔥 CARD
          Container(
            width: 500,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  const Color(0xff020617),
                  Colors.greenAccent.withOpacity(.15),
                ],
              ),
              border: Border.all(color: Colors.greenAccent),
              boxShadow: [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(.4),
                  blurRadius: 25,
                )
              ],
            ),

            child: Column(

              children: [

                const Icon(
                  Icons.support_agent,
                  size: 50,
                  color: Colors.greenAccent,
                ),

                const SizedBox(height: 15),

                Text(
                  "CyberShield Support",
                  style: GoogleFonts.orbitron(
                    color: Colors.greenAccent,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 20),

                contactItem(Icons.email, "support@cybershield.ai"),
                contactItem(Icons.phone, "+91 98765 43210"),
                contactItem(Icons.language, "www.cybershield.ai"),

                const SizedBox(height: 25),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 12),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.chat, color: Colors.black),
                  label: const Text(
                    "Live Support",
                    style: TextStyle(color: Colors.black),
                  ),
                ),

              ],

            ),
          ),

          const SizedBox(height: 40),

          // 🔥 EXTRA SECTION
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              socialIcon(Icons.facebook),
              socialIcon(Icons.telegram),
              socialIcon(Icons.linked_camera),
            ],
          ),

          const SizedBox(height: 60),

        ],

      ),

    ),

  );

}
Widget contactItem(IconData icon, String text){
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, color: Colors.greenAccent),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    ),
  );
}

Widget socialIcon(IconData icon){
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: CircleAvatar(
      backgroundColor: Colors.white10,
      child: Icon(icon, color: Colors.greenAccent),
    ),
  );
}

  Widget moduleGrid(){

    return SizedBox(

      width: 900,

      child: Wrap(

        alignment: WrapAlignment.center,

        spacing: 25,
        runSpacing: 25,

        children: [

          moduleCard(Icons.email,"Email",Colors.orange,EmailPhishingPage()),
          moduleCard(Icons.security,"Malware",Colors.red,MalwareDetectionPage()),
          moduleCard(Icons.link,"URL",Colors.blue,UrlScannerPage()),
          moduleCard(Icons.usb,"USB",Colors.green,UsbAuthPage()),

        ],

      ),

    );

  }

  Widget moduleCard(icon,title,color,page){

    return GestureDetector(

      onTap: (){

        showDialog(

          context: context,

          builder: (_){

            return AlertDialog(

              backgroundColor: const Color(0xff020617),

              title: Text(title),

              content: Text(moduleDescription(title)),

              actions: [

                TextButton(

                  onPressed: ()=>Navigator.pop(context),

                  child: const Text("Close"),

                ),

                ElevatedButton(

  onPressed: () async {

    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;

    if(!isLoggedIn){

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⚠️ Please login first"),
          backgroundColor: Colors.red,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );

      return;
    }

    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );

  },

  child: const Text("Open Module"),

)

              ],

            );

          },

        );

      },

      child: AnimatedContainer(

        duration: 400.ms,

        width: 190,
        height: 190,

        decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(22),

          gradient: LinearGradient(

            colors: [

              const Color(0xff020617),
              color.withOpacity(.25),

            ],

          ),

          border: Border.all(color: color,width:1.2),

          boxShadow: [

            BoxShadow(
              color: color.withOpacity(.5),
              blurRadius: 35,
            ),

          ],

        ),

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(icon,size:40,color:color),

            const SizedBox(height:15),

            Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),

          ],

        ),

      ).animate().fade().scale(),

    );

  }

  String moduleDescription(name){

    switch(name){

      case "Email":
        return "AI scans emails to detect phishing threats.";

      case "Malware":
        return "Detect harmful files using ML.";

      case "URL":
        return "Check websites for security risks.";

      case "USB":
        return "Prevent infected USB attacks.";

      default:
        return "";

    }

  }

  Widget miniGraph(){

    final Random random = Random();

    return Container(

      margin: const EdgeInsets.symmetric(vertical:40),

      child: Wrap(

        alignment: WrapAlignment.center,

        spacing: 8,

        children: List.generate(8,(i){

          double h = 40 + random.nextInt(60).toDouble();

          return Container(

            width: 12,
            height: h,

            decoration: BoxDecoration(

              color: Colors.greenAccent,

              borderRadius: BorderRadius.circular(6),

              boxShadow: [

                BoxShadow(
                  color: Colors.greenAccent.withOpacity(.4),
                  blurRadius: 10,
                )

              ],

            ),

          ).animate().fade().scale();

        }),

      ),

    );

  }

  Widget whyChooseUs(){

    return Wrap(

      alignment: WrapAlignment.center,

      spacing: 20,

      children: [

        feature("AI Detection"),
        feature("Realtime"),
        feature("Privacy"),

      ],

    );

  }

  Widget feature(text){

    return Container(

      width:150,

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: Colors.white24),

      ),

      child: Column(

        children: [

          const Icon(Icons.security,color: Colors.greenAccent),

          const SizedBox(height:10),

          Text(text),

        ],

      ),

    );

  }

  Widget aiButton(){

  return Positioned(

    bottom: 30,
    right: 30,

    child: FloatingActionButton(

      backgroundColor: Colors.greenAccent,

      child: const Icon(Icons.smart_toy, color: Colors.black),

      onPressed: () {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => const ChatbotDialog(),
  );
}

    ),

  );

}

}

// CUSTOM ARC RING

class RingPainter extends CustomPainter {

  final Color color;
  final double stroke;

  RingPainter({
    required this.color,
    required this.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()

      ..color = color

      ..style = PaintingStyle.stroke

      ..strokeWidth = stroke

      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final rect = Rect.fromLTWH(0,0,size.width,size.height);

    canvas.drawArc(
      rect,
      0,
      4.8,
      false,
      paint,
    );

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

}