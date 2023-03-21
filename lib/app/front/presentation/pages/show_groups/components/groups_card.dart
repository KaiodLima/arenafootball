import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupCards extends StatefulWidget {
  final List<DocumentSnapshot>? groupCompetition;
  final int? index;
  final String? title;

  const GroupCards({ 
    Key? key,
    this.groupCompetition,
    this.index,
    this.title,

  }) : super(key: key);

  @override
  State<GroupCards> createState() => _GroupCardsState();
}

class _GroupCardsState extends State<GroupCards> {
  double fontSizeTeam = 22;
  double fontSizeGroup = 24;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.34,
          width: MediaQuery.of(context).size.width * 0.45, // retorna o tamanho da largura da tela
          decoration: const BoxDecoration(
            color: Colors.green,              
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  alignment: Alignment.topCenter,
                  child: Text(
                    //"GRUPO A",
                    (widget.title!.isNotEmpty)?widget.title.toString():"",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSizeGroup,
                    ),
                  ),
                ),
              ),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.28,
          width: MediaQuery.of(context).size.width * 0.45, // retorna o tamanho da largura da tela
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 4, 110, 7),
            // border: Border.all(
            //   color: Color.fromARGB(255, 4, 110, 7),
            //   width: 2,
            //   style: BorderStyle.solid
            // ),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  //"TIME A",
                  (widget.groupCompetition![widget.index!].get("time1").toString().isNotEmpty)?widget.groupCompetition![widget.index!].get("time1").toString():"",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSizeTeam,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  //"TIME B",
                  (widget.groupCompetition![widget.index!].get("time1").toString().isNotEmpty)?widget.groupCompetition![widget.index!].get("time2").toString():"",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSizeTeam,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  //"TIME C",
                  (widget.groupCompetition![widget.index!].get("time1").toString().isNotEmpty)?widget.groupCompetition![widget.index!].get("time3").toString():"",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSizeTeam,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  //"TIME D",
                  (widget.groupCompetition![widget.index!].get("time1").toString().isNotEmpty)?widget.groupCompetition![widget.index!].get("time4").toString():"",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSizeTeam,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}