import 'package:flutter/material.dart';

// ignore: must_be_immutable
class QuizCardDetails extends StatefulWidget {
  int index;
  String imageAddress;
  String? placeDetails;

  QuizCardDetails(this.imageAddress, this.index, {super.key});

  @override
  State<StatefulWidget> createState() => QuizCardDetailsState(imageAddress, index);
}

class QuizCardDetailsState extends State<QuizCardDetails> {
  int index;
  String imageAddress;
  late String placeDetails;

  QuizCardDetailsState(this.imageAddress, this.index);

  @override
  void initState() {
    super.initState();
    setState(() {
      getData(index);
    });
  }

  getData(value) {
    switch (value) {
      case 0:
        placeDetails =
        'Mussoorie, located around an hour from Derahdun in Uttarakhand, is a popular weekend destination for north Indians, as well as honeymooners.';
        break;
      case 1:
        placeDetails =
        "Manali, in Himachal Pradesh, is one of the top adventure travel destinations in India.";
        break;
      case 2:
        placeDetails =
        "Sikkim's capital, Gangtok, sits along a cloudy mountain ridge about 5,500 feet above sea level.";
        break;
      case 3:
        placeDetails =
        "Darjeeling is also famous for its lush tea gardens.";
        break;
      case 4:
        placeDetails =
        "The hill station of Nainital, in the Kumaon region of Uttarakhand, was a popular summer retreat for the British.";
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Stack(
            children: <Widget>[
              const SizedBox(
                height: 800.0,
                width: double.infinity,
              ),
              Container(
                padding: const EdgeInsets.all(10.0),
                height: 500.0,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius:const BorderRadius.only(
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(imageAddress),
                      fit: BoxFit.fill,
                    )),
              ),
              Positioned(
                top: 420.0,
                left: 10.0,
                right: 10.0,
                child: Material(
                  elevation: 10.0,
                  borderRadius: BorderRadius.circular(20.0),
                  child: Container(
                    height: 380.0,
                    decoration:const BoxDecoration(),
                    padding:const EdgeInsets.only(
                      left: 20.0,
                      right: 10.0,
                      top: 20.0,
                    ),
                    child: Text(
                      placeDetails,
                      textAlign: TextAlign.left,
                      style: const TextStyle(fontSize: 20.0, fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
