import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'database_helper.dart';
import 'registro_model.dart';

void main() {
  runApp(FormApp());
}

class FormApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Formulario',
      theme: ThemeData(
        primaryColor: Colors.blue[900],
        appBarTheme: AppBarTheme(
          color: Colors.blue[900],
        ),
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('Registro de usuario')),
        body: RegistrationForm(), ///// Este es el Widget principal
      ),
    );
  }
}

class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() =>
      _RegistrationFormState(); //// Estado mutable
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  DatabaseHelper dbHelper = DatabaseHelper();
  List<Registro> registros = [];

/////Controladores
  TextEditingController nombreController = TextEditingController();
  TextEditingController correoController = TextEditingController();
  TextEditingController direccionController = TextEditingController();
  TextEditingController fechaController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  ///Registros de la base de datos existentes
  @override
  void initState() {
    super.initState();
    _loadRegistros();
  }

  Future<void> _loadRegistros() async {
    List<Registro> lista = await dbHelper.getRegistros();
    setState(() {
      registros = lista;
    });
  }

  ///Traer Datos de usuario aleatorio desde API
  Future<void> obtenerDatosDesdeAPI() async {
    final response = await http.get(Uri.parse('https://randomuser.me/api/'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var userData = data['results'][0];

      setState(() {
        nombreController.text =
            '${userData['name']['first']} ${userData['name']['last']}';
        correoController.text = userData['email'];
        direccionController.text = userData['location']['street']['name'];
        fechaController.text = userData['dob']['date'].substring(0, 10);
        passwordController.text = 'password123';
      });
    }
  }

  ///Validacion de campos de formulario para ingresarlos en la BD
  void registrarDatos() async {
    if (_formKey.currentState?.validate() ?? false) {
      Registro registro = Registro(
        nombre: nombreController.text,
        correo: correoController.text,
        direccion: direccionController.text,
        fechaNacimiento: fechaController.text,
        password: passwordController.text,
      );

      await dbHelper.insertRegistro(registro);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Registro Exitoso!')),
      );

      nombreController.clear();
      correoController.clear();
      direccionController.clear();
      fechaController.clear();
      passwordController.clear();

      _loadRegistros();
    }
  }

  /// Boton Extra*** Eliminar un registro
  void _eliminarRegistro(int id) async {
    await dbHelper.deleteRegistro(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registro eliminado')),
    );
    _loadRegistros();
  }

///////////Widgets del formulario y tabla con sus respectivas validaciones
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //////////////////////////////////// Campo de Nombre
                  TextFormField(
                    controller: nombreController,
                    decoration: InputDecoration(labelText: 'Nombre Completo'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo Nombre es obligatorio';
                      }
                      return null;
                    },
                  ),
                  //////////////////////////////////// Campo de Correo
                  TextFormField(
                    controller: correoController,
                    decoration:
                        InputDecoration(labelText: 'Correo Electrónico'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo Correo es obligatorio';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Por favor ingrese un correo válido';
                      }
                      return null;
                    },
                  ),

                  //////////////////////////////////// Campo de Fecha de Nacimiento
                  TextFormField(
                    controller: fechaController,
                    decoration: InputDecoration(
                      labelText: 'Fecha Nacimiento',
                      hintText: 'yyyy-mm-dd',
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          fechaController.text =
                              pickedDate.toString().substring(0, 10);
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo Fecha de Nacimiento es obligatorio';
                      }
                      return null;
                    },
                  ),
                  //////////////////////////////////// Campo de Dirección
                  TextFormField(
                    controller: direccionController,
                    decoration: InputDecoration(labelText: 'Dirección'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo Dirección es obligatorio';
                      }
                      return null;
                    },
                  ),
                  //////////////////////////////////// Campo de Contraseña
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo Contraseña es obligatorio';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  //////////////////////////////////// Botón de Registrar
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue[900],
                      ),
                      onPressed: registrarDatos,
                      child: Text('Registrar'),
                    ),
                  ),
                  SizedBox(height: 10),
                  ////////////////////////////////////Botón de Obtener desde API
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue[900],
                      ),
                      onPressed: obtenerDatosDesdeAPI,
                      child: Text('Obtener desde API'),
                    ),
                  ),
                  SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTableTheme(
                      data: DataTableThemeData(
                        headingRowColor:
                            MaterialStateProperty.all(Colors.blue[900]),
                        headingTextStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ///////////////// Datos ingresados mostrados en la tabla
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('Nombre Completo')),
                          DataColumn(label: Text('Correo Electrónico')),
                          DataColumn(label: Text('Fecha Nacimiento')),
                          DataColumn(label: Text('Dirección')),
                          DataColumn(label: Text('Contraseña')),
                          DataColumn(label: Text('Acciones')),
                        ],
                        /////////////////// Mapeando registros ingresados en la tabla
                        rows: registros.map((registro) {
                          return DataRow(
                            cells: [
                              DataCell(Text(registro.nombre)),
                              DataCell(Text(registro.correo)),
                              DataCell(Text(registro.fechaNacimiento)),
                              DataCell(Text(registro.direccion)),
                              DataCell(Text(registro.password)),
                              DataCell(
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _eliminarRegistro(registro.id!);
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
