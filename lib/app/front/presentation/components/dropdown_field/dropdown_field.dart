import 'package:arena_soccer/app/front/presentation/pages/register_new_destaque/register_new_destaque_controller.dart';
import 'package:arena_soccer/app/front/presentation/pages/register_news/register_new_controller.dart';
import 'package:flutter/material.dart';

class ArenaDropdownField extends StatefulWidget {
  final Icon? icon;
  final Function(String)? onChaged;
  final RegisterNewController? controller;
  final RegisterNewDestaqueController? controllerDestaque;

  ArenaDropdownField({
    Key? key,
    this.icon,
    this.onChaged,
    this.controller,
    this.controllerDestaque
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
                      widget.controllerDestaque?.isShow = "true";
                    }else{
                      widget.controller?.isShow = "false";
                      widget.controllerDestaque?.isShow = "false";
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
  