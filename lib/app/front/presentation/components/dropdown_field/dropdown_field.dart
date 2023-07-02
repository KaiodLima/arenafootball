import 'package:arena_soccer/app/front/presentation/pages/register_news/register_new_controller.dart';
import 'package:flutter/material.dart';

class ArenaDropdownField extends StatefulWidget {
  final Icon? icon;
  final Function(String)? onChaged;
  final RegisterNewController? controller;

  ArenaDropdownField({
    Key? key,
    this.icon,
    this.onChaged,
    this.controller
    // required this.controller
  }) : super(key: key);

  @override
  State<ArenaDropdownField> createState() => _ArenaDropdownFieldState();
}

class _ArenaDropdownFieldState extends State<ArenaDropdownField> {
  bool isSwitched = false;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exibir notícia',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isSwitched ? Colors.green : Colors.black54,),
              ),
              const SizedBox(height: 20),
              Switch(
                value: isSwitched,
                onChanged: (value) {
                  setState(() {
                    isSwitched = value;
                    if(isSwitched){
                      widget.controller?.isShow = "true";
                    }else{
                      widget.controller?.isShow = "false";
                    }
                    
                  });
                },
                activeColor: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );

  }

}
  