import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(MyApp());

class CEP {
  String objectId;
  String cep;
  String logradouro;
  String bairro;
  String cidade;
  String estado;

  CEP({
    required this.objectId,
    required this.cep,
    required this.logradouro,
    required this.bairro,
    required this.cidade,
    required this.estado,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro de CEPs',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ListaCEPs(),
    );
  }
}

class ListaCEPs extends StatefulWidget {
  @override
  _ListaCEPsState createState() => _ListaCEPsState();
}

class _ListaCEPsState extends State<ListaCEPs> {
  final dio = Dio();
  List<CEP> ceps = [];

  @override
  void initState() {
    super.initState();
    _loadCEPs();
  }

  Future<void> _loadCEPs() async {
    try {
      Response response = await dio.get('https://parseapi.back4app.com/classes/CEP',
          options: Options(headers: {
            'X-Parse-Application-Id': 'elAT6iS5sPrqnIBsWoAbL0jVQPH79uBam8Pryww0',
            'X-Parse-REST-API-Key': 'KZyMInMD9enWGCpVjS0D9nZExCqkqXfwdVFTmJzJ',
          }));

      setState(() {
        ceps = (response.data['results'] as List)
            .map((cepData) => CEP(
          objectId: cepData['objectId'],
          cep: cepData['cep'],
          logradouro: cepData['logradouro'],
          bairro: cepData['bairro'],
          cidade: cepData['cidade'],
          estado: cepData['estado'],
        ))
            .toList();
      });
    } catch (error) {
      print('Erro ao carregar CEPs: $error');
    }
  }

  Future<void> _saveCEP(Map<String, dynamic> cepData) async {
    try {
      await dio.post(
        'https://parseapi.back4app.com/classes/CEP',
        data: cepData,
        options: Options(headers: {
          'X-Parse-Application-Id': 'elAT6iS5sPrqnIBsWoAbL0jVQPH79uBam8Pryww0',
          'X-Parse-REST-API-Key': 'KZyMInMD9enWGCpVjS0D9nZExCqkqXfwdVFTmJzJ',
          'Content-Type': 'application/json',
        }),
      );

      Fluttertoast.showToast(msg: 'CEP cadastrado com sucesso.');
      _loadCEPs();
    } catch (error) {
      print('Erro ao cadastrar o CEP: $error');
      Fluttertoast.showToast(msg: 'Erro ao cadastrar o CEP.');
    }
  }

  Future<void> _updateCEP(Map<String, dynamic> cepData, String objectId) async {
    try {
      await dio.put(
        'https://parseapi.back4app.com/classes/CEP/$objectId',
        data: cepData,
        options: Options(headers: {
          'X-Parse-Application-Id': 'elAT6iS5sPrqnIBsWoAbL0jVQPH79uBam8Pryww0',
          'X-Parse-REST-API-Key': 'KZyMInMD9enWGCpVjS0D9nZExCqkqXfwdVFTmJzJ',
          'Content-Type': 'application/json',
        }),
      );

      Fluttertoast.showToast(msg: 'CEP atualizado com sucesso.');
      _loadCEPs();
    } catch (error) {
      print('Erro ao atualizar o CEP: $error');
      Fluttertoast.showToast(msg: 'Erro ao atualizar o CEP.');
    }
  }

  Future<void> _deleteCEP(String objectId) async {
    try {
      await dio.delete(
        'https://parseapi.back4app.com/classes/CEP/$objectId',
        options: Options(headers: {
          'X-Parse-Application-Id': 'elAT6iS5sPrqnIBsWoAbL0jVQPH79uBam8Pryww0',
          'X-Parse-REST-API-Key': 'KZyMInMD9enWGCpVjS0D9nZExCqkqXfwdVFTmJzJ',
        }),
      );

      Fluttertoast.showToast(msg: 'CEP excluído com sucesso.');
      _loadCEPs();
    } catch (error) {
      print('Erro ao excluir o CEP: $error');
      Fluttertoast.showToast(msg: 'Erro ao excluir o CEP.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de CEPs'),
      ),
      body: ListView.builder(
        itemCount: ceps.length,
        itemBuilder: (context, index) {
          final cep = ceps[index];
          return ListTile(
            title: Text(cep.cep),
            subtitle: Text('${cep.logradouro}, ${cep.bairro}, ${cep.cidade}, ${cep.estado}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditarCEPScreen(cep, _updateCEP)),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteCEP(cep.objectId);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdicionarCEPScreen(_saveCEP)),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AdicionarCEPScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  AdicionarCEPScreen(this.onSave);

  @override
  _AdicionarCEPScreenState createState() => _AdicionarCEPScreenState();
}

class _AdicionarCEPScreenState extends State<AdicionarCEPScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cepController = TextEditingController();
  final Map<String, dynamic> _cepData = {
    'cep': '',
    'logradouro': '',
    'bairro': '',
    'cidade': '',
    'estado': '',
  };

  Future<void> _fetchCEP(String cep) async {
    try {
      final response = await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _cepData['cep'] = data['cep'];
          _cepData['logradouro'] = data['logradouro'];
          _cepData['bairro'] = data['bairro'];
          _cepData['cidade'] = data['localidade'];
          _cepData['estado'] = data['uf'];
        });
      } else {
        Fluttertoast.showToast(msg: 'CEP não encontrado.');
      }
    } catch (error) {
      Fluttertoast.showToast(msg: 'Erro ao buscar CEP.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar CEP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _cepController,
                decoration: InputDecoration(labelText: 'CEP'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o CEP';
                  }
                  return null;
                },
                onSaved: (value) {
                  _cepData['cep'] = value!;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _fetchCEP(_cepData['cep']);
                  }
                },
                child: Text('Buscar CEP Online'),
              ),
              SizedBox(height: 20),
              if (_cepData['cep'].isNotEmpty) ...[
                Text('CEP Encontrado: ${_cepData['cep']}'),
                TextFormField(
                  initialValue: _cepData['logradouro'],
                  decoration: InputDecoration(labelText: 'Logradouro'),
                  validator: (value) {
                    // Adicione validações se necessário
                    return null;
                  },
                  onSaved: (value) {
                    _cepData['logradouro'] = value!;
                  },
                ),
                // Repita para outros campos (bairro, cidade, estado) se necessário
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      widget.onSave(_cepData);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Adicionar CEP'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


class EditarCEPScreen extends StatefulWidget {
  final CEP cep;
  final Function(Map<String, dynamic>, String) onUpdate;

  EditarCEPScreen(this.cep, this.onUpdate);

  @override
  _EditarCEPScreenState createState() => _EditarCEPScreenState();
}

class _EditarCEPScreenState extends State<EditarCEPScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _cepData = {
    'cep': '',
    'logradouro': '',
    'bairro': '',
    'cidade': '',
    'estado': '',
  };

  @override
  void initState() {
    super.initState();
    _cepData['cep'] = widget.cep.cep;
    _cepData['logradouro'] = widget.cep.logradouro;
    _cepData['bairro'] = widget.cep.bairro;
    _cepData['cidade'] = widget.cep.cidade;
    _cepData['estado'] = widget.cep.estado;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar CEP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: widget.cep.cep,
                decoration: InputDecoration(labelText: 'CEP'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o CEP';
                  }
                  return null;
                },
                onSaved: (value) {
                  _cepData['cep'] = value!;
                },
              ),
              TextFormField(
                initialValue: widget.cep.logradouro,
                decoration: InputDecoration(labelText: 'Logradouro'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o logradouro';
                  }
                  return null;
                },
                onSaved: (value) {
                  _cepData['logradouro'] = value!;
                },
              ),
              TextFormField(
                initialValue: widget.cep.bairro,
                decoration: InputDecoration(labelText: 'Bairro'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o bairro';
                  }
                  return null;
                },
                onSaved: (value) {
                  _cepData['bairro'] = value!;
                },
              ),
              TextFormField(
                initialValue: widget.cep.cidade,
                decoration: InputDecoration(labelText: 'Cidade'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite a cidade';
                  }
                  return null;
                },
                onSaved: (value) {
                  _cepData['cidade'] = value!;
                },
              ),
              TextFormField(
                initialValue: widget.cep.estado,
                decoration: InputDecoration(labelText: 'Estado'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o estado';
                  }
                  return null;
                },
                onSaved: (value) {
                  _cepData['estado'] = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    widget.onUpdate(_cepData, widget.cep.objectId);
                    Navigator.pop(context);
                  }
                },
                child: Text('Atualizar CEP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
