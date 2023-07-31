import 'package:arena_soccer/app/front/presentation/pages/register_match/CadastrarPartida.dart';
import 'package:arena_soccer/app/front/presentation/pages/register_new_destaque/register_new_destaque.dart';
import 'package:arena_soccer/app/front/presentation/pages/register_new_player/register_new_player_screen.dart';
import 'package:arena_soccer/app/front/presentation/pages/register_news/register_new.dart';
import 'package:arena_soccer/app/front/presentation/pages/register_team/CadastrarTime.dart';
import 'package:arena_soccer/model/Usuario.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class ARENADrawer extends StatefulWidget {
  final bool fromHome;
  final bool disableFunctions;
  final Function()? onTapSecondary;
  final int? initialSelectedMenu;
  final bool showItem;

  final Usuario? user;
  final bool? isAdmin;
  //
  final String? imageDrawer;
  final TextStyle? textStyle;
  final double? iconSize;
  final Color? iconColor;

  const ARENADrawer({
    Key? key,
    this.onTapSecondary,
    this.fromHome = false,
    this.disableFunctions = false,
    this.initialSelectedMenu,
    this.showItem = true,
    this.user,
    this.isAdmin,
    this.imageDrawer,
    this.textStyle,
    this.iconSize,
    this.iconColor,
  }) : super(key: key);

  @override
  State<ARENADrawer> createState() => _ARENADrawerState();
}

class _ARENADrawerState extends State<ARENADrawer> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("TESTE:: "+widget.imageDrawer.toString());
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              // image: widget.imageDrawer == null ? null : DecorationImage(
              //   fit: BoxFit.scaleDown,
              //   alignment: Alignment.centerRight,
              //   image: NetworkImage(widget.imageDrawer!),
              // ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.green, Color.fromARGB(255, 27, 67, 28)],
              ),
              color: Colors.green,
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                CircleAvatar(
                  maxRadius: 40,
                  backgroundColor: const Color.fromARGB(255, 134, 143, 134),                           
                  backgroundImage: widget.imageDrawer == null ? null : NetworkImage(widget.imageDrawer!),
                ),
                Container(
                  // color: Colors.amber,
                  alignment: Alignment.centerRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ''+widget.user!.nome.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 8,),
                      Text(
                        'Torcedor do: '+widget.user!.timeQueTorce.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, size: widget.iconSize, color: widget.iconColor,),
            title: Text('Início'.toUpperCase(), style: widget.textStyle,),
            onTap: () {
              // You can add your navigation logic here
              Navigator.pop(context); // Closes the Drawer
            },
          ),
          Divider(),
          if(widget.isAdmin == true)
            ListTile(
              leading: Icon(Icons.star_rate_rounded, size: widget.iconSize, color: widget.iconColor,),
              title: Text('Cadastrar Destaques'.toUpperCase(), style: widget.textStyle,),
              onTap: () {
                // You can add your navigation logic here
                Navigator.push(
                  context, //abre uma tela sobre outra (o context é o contexto da tela atual, o método build já trás pra gente automaticamente)
                  MaterialPageRoute(
                    builder: (context) => const RegisterDestaque(),
                  ) //o outro parâmetro é a rota
                );

                // Navigator.pop(context); // Closes the Drawer
              },
            ),
          if(widget.isAdmin == true)
            ListTile(
              leading: Icon(Icons.person_add, size: widget.iconSize, color: widget.iconColor,),
              title: Text('Cadastrar Jogador'.toUpperCase(), style: widget.textStyle,),
              onTap: () {
                // You can add your navigation logic here
                Navigator.push(
                  context, //abre uma tela sobre outra (o context é o contexto da tela atual, o método build já trás pra gente automaticamente)
                  MaterialPageRoute(
                    builder: (context) => const RegisterPlayer(),
                  ) //o outro parâmetro é a rota
                );

                // Navigator.pop(context); // Closes the Drawer
              },
            ),
          if(widget.isAdmin == true)
            ListTile(
              leading: Icon(Icons.scoreboard_outlined, size: widget.iconSize, color: widget.iconColor,),
              title: Text('Cadastrar Nova Partida'.toUpperCase(), style: widget.textStyle,),
              onTap: () {
                // You can add your navigation logic here
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CadastrarPartida(),
                  )
                );
                
                // Navigator.pop(context); // Closes the Drawer
              },
            ),
          if(widget.isAdmin == true)
            ListTile(
              leading: Icon(Icons.info, size: widget.iconSize, color: widget.iconColor,),
              title: Text('Cadastrar Notícia'.toUpperCase(), style: widget.textStyle,),
              onTap: () {
                // You can add your navigation logic here
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterNew(), //cadastrar notícia
                  )
                );
                
                // Navigator.pop(context); // Closes the Drawer
              },
            ),
          if(widget.isAdmin == true)
            ListTile(
              leading: Icon(Icons.shield_outlined, size: widget.iconSize, color: widget.iconColor,),
              title: Text('Cadastrar Time'.toUpperCase(), style: widget.textStyle,),
              onTap: () {
                // You can add your navigation logic here
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CadastrarTime(),
                  )
                );
                
                // Navigator.pop(context); // Closes the Drawer
              },
            ),
        ],
      ),
    );
  }

}
