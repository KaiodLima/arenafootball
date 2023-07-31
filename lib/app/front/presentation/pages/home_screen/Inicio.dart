import 'package:arena_soccer/app/front/presentation/components/arena_drawer/arena_drawer.dart';
import 'package:arena_soccer/app/front/presentation/components/arena_dropdown/arena_dropdown.dart';
import 'package:arena_soccer/app/front/presentation/components/arena_dropdown/arena_dropdown_controller.dart';
import 'package:arena_soccer/app/front/presentation/components/highlights/arena_highlights.dart';
import 'package:arena_soccer/app/front/presentation/pages/home_screen/home_screen_controller.dart';
import 'package:arena_soccer/app/front/presentation/pages/register_new_destaque/register_new_destaque.dart';
import 'package:arena_soccer/app/front/presentation/pages/register_news/register_new.dart';
import 'package:arena_soccer/app/front/presentation/pages/register_match/CadastrarPartida.dart';
import 'package:arena_soccer/app/front/presentation/pages/register_team/CadastrarTime.dart';
import 'package:arena_soccer/app/front/presentation/pages/register_new_player/register_new_player_screen.dart';
import 'package:arena_soccer/app/front/presentation/pages/calculate_votes_best_player/CalcularVotos.dart';
import 'package:arena_soccer/app/front/presentation/pages/login/Login.dart';
import 'package:arena_soccer/abas/AbaCampeonatos.dart';
import 'package:arena_soccer/abas/AbaNoticias.dart';
import 'package:arena_soccer/abas/AbaTabela.dart';
import 'package:arena_soccer/abas/AbaTimes.dart';
import 'package:arena_soccer/app/front/presentation/pages/show_assistance_leader/ExibirAssistencias.dart';
import 'package:arena_soccer/app/front/presentation/pages/show_soccer_scorers/ExibirArtilheiros.dart';
import 'package:arena_soccer/model/Time.dart';
import 'package:arena_soccer/model/Usuario.dart';
import 'package:arena_soccer/presentation/home/components/destaque.dart';
import 'package:arena_soccer/presentation/home/pages/destaque_detalhes_screen.dart';
import 'package:arena_soccer/presentation/home/pages/notificar_gols_screen/notificar_gols_screen.dart';
import 'package:arena_soccer/presentation/home/pages/publicar_anuncio_screen/publicar_anuncio_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Inicio extends StatefulWidget {
  bool? isAuthenticated;
  Usuario? usuario;

  Inicio({Key? key, this.isAuthenticated, this.usuario}) : super(key: key);

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  final HomeScreenController _controllerHome = HomeScreenController(); //utilizo mobX

  //marcador da janela selecionada
  int _selecionado = 0;
  // String _resultado = "";

  //deslogar usuário
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    _chamarTelaLogin();
  }

  //chamar tela de login
  _chamarTelaLogin() {
    //o pushReplacement substitui a rota atual pela próxima, ou seja, não vai haver botão volta no appbar
    Navigator.pushReplacement(
        context, //abre uma tela sobre outra (o context é o contexto da tela atual, o método build já trás pra gente automaticamente)
        MaterialPageRoute(
          builder: (context) => const Login(),
        ) //o outro parâmetro é a rota
        );
    //Navigator.pop(context); //fecha a tela atual e abre uma nova
  }

  _verificarUsuarioAutenticado() async {
    User? usuarioAutenticado = await FirebaseAuth.instance.currentUser;
    // print("Entrou na função: "+usuarioAutenticado!.email.toString());
    print("Entrou na função: "+usuarioAutenticado!.uid.toString());
    if (usuarioAutenticado == null) {
      _logout();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.isAuthenticated == true) {
      _verificarUsuarioAutenticado();
      _controllerHome.getUserData(FirebaseAuth.instance.currentUser!.uid.toString());
    }
    _controllerHome.chamarPreferences();
  }

  List<String> listaMenu = [
    "Cadastrar Destaques",
    "Cadastrar Jogador",
    "Cadastrar Nova Partida",
    "Cadastrar Notícia",
    "Cadastrar Time"
  ];
  // List<String> listaMenu = ["Calcular Votos", "Cadastrar Jogador", "Cadastrar Nova Partida", "Cadastrar Noticia"];
  chamarMenuPop(String selecionado) {
    //print("Item clicado: ${selecionado}");
    switch (selecionado) {
      // case "Calcular Votos":
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => const CalcularVotos(),
      //     )
      //   );
      //   break;
      case "Cadastrar Destaques":
        Navigator.push(
            context, //abre uma tela sobre outra (o context é o contexto da tela atual, o método build já trás pra gente automaticamente)
            MaterialPageRoute(
              builder: (context) => const RegisterDestaque(),
            ) //o outro parâmetro é a rota
            );
        break;
      case "Cadastrar Jogador":
        Navigator.push(
            context, //abre uma tela sobre outra (o context é o contexto da tela atual, o método build já trás pra gente automaticamente)
            MaterialPageRoute(
              builder: (context) => const RegisterPlayer(),
            ) //o outro parâmetro é a rota
            );
        break;
      case "Cadastrar Nova Partida":
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CadastrarPartida(),
            ));
        break;
      case "Cadastrar Notícia":
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RegisterNew(), //cadastrar notícia
            ));
        break;
      case "Cadastrar Time":
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CadastrarTime(),
            ));
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    //lista de telas
    List<Widget> telas = [
      //Inicio(_resultado),
      Observer(builder: (_) {
        return AbaNoticias(
          regiao: _controllerHome.controllerDropDown.selectedItem ?? "Floresta",
          usuario: widget.usuario,
        );
      }),
      Observer(builder: (_) {
        return AbaCampeonatos(
          regiao: _controllerHome.controllerDropDown.selectedItem ?? "Floresta",
          ano: _controllerHome.anoSelecionado,
        );
      }),
      Observer(builder: (_) {
        return AbaTimes(
          regiao: _controllerHome.controllerDropDown.selectedItem ?? "Floresta",
          ano: _controllerHome.anoSelecionado,
          usuario: widget.usuario,
        );
      }),
      Observer(builder: (_) {
        return AbaTabela(
          regiao: _controllerHome.controllerDropDown.selectedItem ?? "Floresta",
          ano: _controllerHome.anoSelecionado,
          usuario: widget.usuario,
        );
      }),
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 27, 67, 28),
      appBar: AppBar(
        //backgroundColor: Colors.green,
        backgroundColor: const Color.fromARGB(255, 27, 67, 28),
        elevation: 0,
        title: Image.asset(
          //"lib/assets/images/ic_logo.png",
          "lib/assets/images/ic_arena.png",
          width: 110,
          height: 40,
        ),
        centerTitle: true,
        // leading: Visibility(
        //   visible: widget.usuario?.getIsAdmin == true,
        //   child: PopupMenuButton<String>(
        //     //MENU DO ADMIN
        //     icon: const Icon(
        //       Icons.menu,
        //       color: Colors.white,
        //     ),
        //     iconSize: 30,
        //     onSelected: chamarMenuPop,
        //     itemBuilder: (context) {
        //       return listaMenu.map((String item) {
        //         return PopupMenuItem<String>(
        //           value: item,
        //           child: Text(item),
        //         );
        //       }).toList();
        //     },
        //   ),
        // ),
        actions: [
          IconButton(
            color: Colors.white,
            iconSize: 25,
            icon: const Icon(Icons.logout),
            onPressed: () {
              //print("Minha Conta Clicado!");
              _logout();
            },
          ),
          /*IconButton(
            icon: Icon(Icons.video_call),
            onPressed: (){
              print("VideoCam Clicado!");
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: (){
              print("Minha Conta Clicado!");
            },
          ),*/
        ],
      ),
      drawer: Observer(
        builder: (context) {
          return ARENADrawer(
            user: _controllerHome.userCurrent,
            isAdmin: widget.usuario?.getIsAdmin,
            imageDrawer: _controllerHome.imageDrawer,
            textStyle: const TextStyle(
              fontSize: 16,
              color: Color.fromARGB(255, 27, 67, 28),
              fontWeight: FontWeight.bold,
            ),
            iconSize: 32,
            iconColor: const Color.fromARGB(255, 27, 67, 28),
          );
        }
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: ARENAHighlights(
                height: height,
                width: width,
              ),
            ), //destaques exibidos na parte superior da tela com os times
            const SizedBox(
              height: 10,
            ),
            if (_selecionado == 0 || _selecionado == 1)
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: ArenaDropdownButton(
                  height: 50,
                  width: width,
                  controller: _controllerHome.controllerDropDown,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: _chamarDropDownAno(),
              ),

            Container(
              width: width,
              height: height * 0.55,
              padding: const EdgeInsets.only(
                  right: 16, left: 16, top: 14, bottom: 4),
              child: telas[_selecionado],
            ),
          ],
        ),
      ),
      bottomNavigationBar: MyBottomNavBar(context),
      // bottomNavigationBar: BottomNavigationBar(
      //   iconSize: 30,
      //   selectedItemColor: Colors.white,
      //   unselectedItemColor: Colors.white24,
      //   currentIndex: _selecionado,
      //   onTap: (index){
      //     setState(() {
      //       _selecionado = index;
      //     });
      //   },
      //   type: BottomNavigationBarType.fixed,
      //   //fixedColor: Colors.white,
      //   backgroundColor: Colors.green,
      //   //backgroundColor: Color.fromARGB(255, 27, 67, 28),
      //   items: const [
      //     BottomNavigationBarItem(
      //       label: "Inicio",
      //       icon: Icon(Icons.home),
      //     ),
      //     BottomNavigationBarItem(
      //       label: "Campeonatos",
      //       icon: Icon(Icons.sports_soccer),
      //     ),
      //     BottomNavigationBarItem(
      //       label: "Times",
      //       icon: Icon(Icons.shield),
      //     ),
      //     BottomNavigationBarItem(
      //       label: "Tabela",
      //       icon: Icon(Icons.stadium),
      //     )
      //   ],
      // ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Visibility(
            visible: widget.usuario?.getIsAdmin == true,
            child: FloatingActionButton.small(
              heroTag: "btnAnuncio",
              onPressed: () {
                Navigator.push(
                    context, //abre uma tela sobre outra (o context é o contexto da tela atual, o método build já trás pra gente automaticamente)
                    MaterialPageRoute(
                      builder: (context) => const PublicarAnuncioScreen(),
                    ) //o outro parâmetro é a rota
                    );
              },
              backgroundColor: Colors.green,
              child: const Icon(
                Icons.stacked_line_chart,
              ),
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Visibility(
            visible: widget.usuario?.getIsAdmin == true,
            child: FloatingActionButton.small(
              heroTag: "btnGol",
              onPressed: () {
                Navigator.push(
                    context, //abre uma tela sobre outra (o context é o contexto da tela atual, o método build já trás pra gente automaticamente)
                    MaterialPageRoute(
                      builder: (context) => const NotificarGolsScreen(),
                    ) //o outro parâmetro é a rota
                    );
              },
              backgroundColor: Colors.green,
              child: const Icon(
                Icons.sports_soccer,
              ),
            ),
          ),
          // Visibility(
          //   visible: _selecionado == 3,
          //   child: FloatingActionButton.small(
          //     heroTag: "btnArtilharia",
          //     onPressed: (){
          //       Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => ExibirArtilheiros(regiao: cidadeSelecionada??"Floresta",),
          //       )
          //     );
          //     },
          //     backgroundColor: Colors.white,
          //     child: const Icon(
          //       Icons.sports_soccer,
          //       color: Colors.green,
          //     ),
          //   ),
          // ),
          // Visibility(
          //   visible: _selecionado == 3,
          //   child: FloatingActionButton.small(
          //     heroTag: "btnAssistencias",
          //     onPressed: (){
          //       Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => ExibirAssistencias(regiao: cidadeSelecionada??"Floresta",),
          //       )
          //     );
          //     },
          //     backgroundColor: Colors.white,
          //     child: const Icon(
          //       Icons.star_border,
          //       color: Colors.green,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  double sizeText = 14;
  Container MyBottomNavBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      height: 60,
      // height: MediaQuery.of(context).size.height * 0.08,
      // width: MediaQuery.of(context).size.width * 1,
      decoration: const BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // IconButton(
              //   enableFeedback: false,
              //   onPressed: () {
              //     setState(() {
              //       _selecionado = 0;
              //     });
              //   },
              //   icon: _selecionado == 0
              //       ? const Icon(
              //           Icons.home_filled,
              //           color: Colors.white,
              //           size: 35,
              //         )
              //       : const Icon(
              //           Icons.home_outlined,
              //           color: Colors.white,
              //           size: 35,
              //         ),
              // ),
              TextButton(
                onPressed: (() {
                  setState(() {
                    _selecionado = 0;
                  });
                }),
                child: _selecionado == 0
                    ? Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            color: Color.fromARGB(255, 27, 67, 28),
                            size: 10,
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Text(
                            "HOME",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: sizeText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        "HOME",
                        style: TextStyle(
                          color: Colors.white24,
                          fontSize: sizeText,
                        ),
                      ),
              ),
              TextButton(
                onPressed: (() {
                  setState(() {
                    _selecionado = 1;
                  });
                }),
                child: _selecionado == 1
                    ? Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            color: Color.fromARGB(255, 27, 67, 28),
                            size: 10,
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Text(
                            "CAMPEONATOS",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: sizeText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        "CAMPEONATOS",
                        style: TextStyle(
                          color: Colors.white24,
                          fontSize: sizeText,
                        ),
                      ),
              ),
              TextButton(
                onPressed: (() {
                  setState(() {
                    _selecionado = 2;
                  });
                }),
                child: _selecionado == 2
                    ? Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            color: Color.fromARGB(255, 27, 67, 28),
                            size: 10,
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Text(
                            "TIMES",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: sizeText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        "TIMES",
                        style: TextStyle(
                          color: Colors.white24,
                          fontSize: sizeText,
                        ),
                      ),
              ),
              TextButton(
                onPressed: (() {
                  setState(() {
                    _selecionado = 3;
                  });
                }),
                child: _selecionado == 3
                    ? Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            color: Color.fromARGB(255, 27, 67, 28),
                            size: 10,
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Text(
                            "TABELAS",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: sizeText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        "TABELAS",
                        style: TextStyle(
                          color: Colors.white24,
                          fontSize: sizeText,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  final List<String> listaAno = ["2022", "2023"];
  
  _chamarDropDownAno() {
    return Container(
      margin: const EdgeInsets.all(4),
      height: MediaQuery.of(context).size.height * 0.06,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(10),
      child: DropdownButton<String>(
        value: _controllerHome.anoSelecionado ?? "2023",
        icon: const Icon(
          Icons.change_circle_outlined,
          color: Colors.white,
        ),
        isExpanded: true,
        borderRadius: BorderRadius.circular(16),
        //elevation: 16,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
        // underline: Container(height: 2, color: Colors.green,),
        underline: Container(),
        alignment: AlignmentDirectional.center,
        dropdownColor: Colors.green,
        onChanged: (String? newValue) async {
          setState(() {
            _controllerHome.anoSelecionado = newValue!;
          });

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('anoEscolhido', _controllerHome.anoSelecionado.toString());
        },

        items: listaAno.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}