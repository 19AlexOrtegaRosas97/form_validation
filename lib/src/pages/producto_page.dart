import 'dart:io';
import 'package:flutter/material.dart';
import 'package:form_validation/src/models/producto_model.dart';
import 'package:form_validation/src/providers/producto_provider.dart';
import 'package:form_validation/src/utils/utils.dart' as utils;
import 'package:image_picker/image_picker.dart';

class ProductoPage extends StatefulWidget {
  @override
  _ProductoPageState createState() => _ProductoPageState();
}

class _ProductoPageState extends State<ProductoPage> {

  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final productoProvider = new ProductosProvider();

  ProductoModel producto = new ProductoModel();
  bool _guardando = false;
  File foto;
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {

    final ProductoModel prodData = ModalRoute.of(context).settings.arguments;

    if(prodData !=null){
      producto=prodData;
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Producto'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_size_select_actual), 
            onPressed: _selecionarFoto
          ),
          IconButton(
            icon: Icon(Icons.camera_alt), 
            onPressed: _tomarFoto
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                _mostrarFoto(),
                _crearNombre(),
                _crearPrecio(),
                _crearDisponible(),
                _crearBoton(),
              ],
            )
          ),
        ),
      ),
    );
  }

  Widget _crearDisponible(){
    return SwitchListTile(
      value: producto.disponible,
      title: Text('Disponible'), 
      activeColor: Colors.deepPurple,
      onChanged: (value) => setState(() {
        producto.disponible = value;
      }),
    );
  }

  Widget _crearNombre() {
    return TextFormField(
      textCapitalization: TextCapitalization.sentences,
      initialValue: producto.titulo,
      decoration: InputDecoration(labelText: 'Producto'),
      onSaved: (value) => producto.titulo = value,
      validator: (value) {
        if (value.length < 3) {
          return 'Ingrese el nombre del producto';
        } else {
          return null;
        }
      },
    );
  }

  Widget _crearPrecio() {
    return TextFormField(
      keyboardType: TextInputType.number,
      initialValue: producto.valor.toString(),
      decoration: InputDecoration(labelText: 'Precio'),
      onSaved: (value) => producto.valor = double.parse(value),
      validator: (value) {
        if (utils.isNumeric(value)) {
          return null;
        } else {
          return 'Solo Numeros';
        }
      },
    );
  }

  Widget _crearBoton() {
    return RaisedButton.icon(
      label: Text('Guardar'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: Colors.deepPurple,
      textColor: Colors.white,
      icon: Icon(Icons.save),
      onPressed: (_guardando) ? null : _submit,
    );
  }

  void _submit() async{
    if(!formKey.currentState.validate()) return;

    if(formKey.currentState.validate()){
      //Cuando el formulario es valido
      formKey.currentState.save();

      setState(() {_guardando=true;});

      if(foto != null){ 
        producto.fotoUrl = await productoProvider.subirImagen(foto);
      }

      if(producto.id == null){
        productoProvider.crearProducto(producto);
      }else{
        productoProvider.editarProducto(producto);
      }
    }
    
    setState(() {_guardando=false;});
    mostrarSnackbar('Registro Guardado');
    Navigator.pop(context);
  }

  void mostrarSnackbar(String mensaje){
    final snackbar = SnackBar(
      content: Text(mensaje),
      duration: Duration(milliseconds: 1500),
    );

    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  Widget _mostrarFoto(){
    if(producto.fotoUrl != null){
      return FadeInImage(
        placeholder: AssetImage('asset/jar-loading.gif'), 
        image: NetworkImage(producto.fotoUrl),
        height: 300.0,
        fit: BoxFit.contain,
      );
    }else{
      return Image(
        image: AssetImage(foto?.path ?? 'assets/no-image.png'),
        height: 300.0,
        fit: BoxFit.cover,
      );
    }
  }

  _selecionarFoto() async {
    procesarImagen(ImageSource.gallery);
  }
  _tomarFoto()async{
    procesarImagen(ImageSource.camera);
  }

  procesarImagen(ImageSource origen)async{
    final pickedFile = await picker.getImage(source: origen);
    if ( pickedFile != null ) {
      producto.fotoUrl = null;
    }
    foto = File(pickedFile.path);
    setState(() {
    });
  } 

}
