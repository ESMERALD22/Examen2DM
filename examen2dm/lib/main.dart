import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wrctmoxxgopheccqmkdr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndyY3Rtb3h4Z29waGVjY3Fta2RyIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTYwMDU3NTgsImV4cCI6MjAxMTU4MTc1OH0.XvC9wqk07Z0xDO1OvUulxbph606IpOiyF5Fut_AHjdA', //SUPABASE_ANON_KEY,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _tareasStream =
      Supabase.instance.client.from('tareas').stream(primaryKey: ['id']);
  var newName, newdescripcion;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descripcionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TAREAS'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _tareasStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final tareas = snapshot.data!;

          return ListView.builder(
            itemCount: tareas.length,
            itemBuilder: (context, index) {
              return Container(
                height: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 100,
                      child: Text(tareas[index]['name']),
                    ),
                    Container(
                      width: 100,
                      child: Text(tareas[index]['descripcion']),
                    ),
                    Checkbox(
                      value: tareas[index]['estado'] == true,
                      onChanged: (newValue) async {
                        final updatedState = newValue ?? false;
                        var response = await Supabase.instance.client
                            .from('tareas')
                            .update({'estado': updatedState})
                            .eq('id', tareas[index]['id'])
                            .execute();
                        setState(() {});
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => MyHomePage(),
                          ),
                        );
                      },
                    ),
                    Text(
                      tareas[index]['estado'] == true
                          ? 'Completo'
                          : 'Incompleto',
                      style: TextStyle(
                          // Agrega estilos si es necesario.
                          ),
                    ),
                    IconButton(
                        onPressed: () {
                          _nameController.text = tareas[index]['name'];
                          _descripcionController.text =
                              tareas[index]['descripcion'];
                          newName = tareas[index]['name'];
                          newdescripcion = tareas[index]['descripcion'];
                          showDialog(
                            context: context,
                            builder: ((context) {
                              return SimpleDialog(
                                title: const Text('Actualización de  Tarea'),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                children: [
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      labelText: 'Nombre',
                                    ),
                                    onChanged: (value) async {
                                      newName = value;
                                    },
                                  ),
                                  TextFormField(
                                    controller: _descripcionController,
                                    decoration: InputDecoration(
                                      labelText: 'descripcion',
                                    ),
                                    onChanged: (value) async {
                                      newdescripcion = value;
                                    },
                                  ),
                                  FloatingActionButton(
                                    onPressed: () {
                                      var response = Supabase.instance.client
                                          .from('tareas')
                                          .update({
                                            'name': newName,
                                            'descripcion': newdescripcion
                                          })
                                          .eq('id', tareas[index]['id'])
                                          .execute();
                                      setState(() {});
                                      Navigator.pop(
                                          context); // Cierra el diálogo o modal.
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              MyHomePage(),
                                        ),
                                      );
                                    },
                                    child: Icon(Icons.done),
                                  ),
                                ],
                              );
                            }),
                          );
                          setState(() {});
                        },
                        icon: Icon(Icons.update)),
                    IconButton(
                        onPressed: () {
                          var response = Supabase.instance.client
                              .from('tareas')
                              .delete()
                              .eq('id', tareas[index]['id'])
                              .execute();
                          print(response);
                          setState(() {});

                          // Actualiza la página principal para mostrar la lista actualizada.
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => MyHomePage(),
                            ),
                          );
                        },
                        icon: Icon(Icons.delete)),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: ((context) {
              return SimpleDialog(
                title: const Text('Ingrese una nueva tarea'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Nombre de la tarea',
                    ),
                    onChanged: (value) async {
                      newName = value;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Descripción de la tarea',
                    ),
                    onChanged: (value) async {
                      newdescripcion = value;
                    },
                  ),
                  FloatingActionButton(
                    onPressed: () async {
                      addData(newName, newdescripcion);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => MyHomePage(),
                        ),
                      );
                    },
                    child: Icon(Icons.add),
                  ),
                ],
              );
            }),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  addData(String name, String descripcion) {
    print(name);
    var response = Supabase.instance.client
        .from('tareas')
        .insert({'name': name, 'descripcion': descripcion}).execute();
    print(response);
  }

  readData() async {
    var response = await Supabase.instance.client
        .from('tareas')
        .select()
        .order('id', ascending: true)
        .execute();
    print(response);
    final dataList = response.data as List;
    return dataList;
  }
}
