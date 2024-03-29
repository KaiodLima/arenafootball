import 'package:arena_soccer/app/front/presentation/pages/edit_news/news_edit_screen_controller.dart';
import 'package:arena_soccer/app/front/presentation/pages/register_new_destaque/register_new_destaque_controller.dart';
import 'package:arena_soccer/app/front/presentation/pages/register_news/register_new_controller.dart';
import 'package:arena_soccer/presentation/home/pages/publicar_anuncio_screen/publicar_anuncio_screen_controller.dart';
import 'package:flutter/material.dart';

class ArenaDropdownField extends StatefulWidget {
  final Icon? icon;
  final Function(String)? onChaged;
  final RegisterNewController? controller;
  final RegisterNewDestaqueController? controllerDestaque;
  final NewsEditScreenController? controllerNews;
  final PublicCardScreenController? controllerPublic;
  final bool? initialValue;
  final Color? textColorInactive;

  ArenaDropdownField({
    Key? key,
    this.icon,
    this.onChaged,
    this.controller,
    this.controllerDestaque,
    this.controllerNews,
    this.initialValue,
    this.controllerPublic,
    this.textColorInactive,
    // required this.controller
  }) : super(key: key);

  @override
  State<ArenaDropdownField> createState() => _ArenaDropdownFieldState();
}

class _ArenaDropdownFieldState extends State<ArenaDropdownField> {
  bool isSwitched = false;
  bool keyRead = false;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(keyRead == false){
      isSwitched = widget.initialValue ?? false;
      keyRead = true;
    }
    
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
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isSwitched ? Colors.green : (widget.textColorInactive??Colors.black54),),
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
                      widget.controllerNews?.isShow = "true";
                      widget.controllerPublic?.isShow = "true";
                    }else{
                      widget.controller?.isShow = "false";
                      widget.controllerDestaque?.isShow = "false";
                      widget.controllerNews?.isShow = "false";
                      widget.controllerPublic?.isShow = "false";
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
  