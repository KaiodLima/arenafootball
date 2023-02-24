class Campeonato {
  //atributos
  String _titulo = "";
  String _descricao = "";
  String _urlImagem = "";

  String _premio1 = "";
  String _premio2 = "";
  String _premio3 = "";
  String _premioArtilheiro = "";
  String _premioGoleiro = "";  
  
  String _regras = "";

  //construtor
  Campeonato(this._titulo, this._descricao, this._urlImagem);

  //métodos acessores
  String get titulo => _titulo;

  set titulo(String value) {
    _titulo = value;
  }

  String get descricao => _descricao;

  set descricao(String value) {
    _descricao = value;
  }

  String get urlImagem => _urlImagem;

  set urlImagem(String value) {
    _urlImagem = value;
  }

  String get premio1 => _premio1;

  set premio1(String value) {
    _premio1 = value;
  }

  String get premio2 => _premio2;

  set premio2(String value) {
    _premio2 = value;
  }

  String get premio3 => _premio3;

  set premio3(String value) {
    _premio3 = value;
  }

    String get premioArtilheiro => _premioArtilheiro;

  set premioArtilheiro(String value) {
    _premioArtilheiro = value;
  }

  String get premioGoleiro => _premioGoleiro;

  set premioGoleiro(String value) {
    _premioGoleiro = value;
  }

  String get regras => _regras;

  set regras(String value) {
    _regras = value;
  }

}