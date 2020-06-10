import 'dart:convert';

import 'package:form_validation/src/models/producto_model.dart';
import 'package:http/http.dart' as http;

class ProductosProvider {

  final String _url = 'https://flutterproductos-7fd0a.firebaseio.com';

  Future<bool> crearProducto(ProductoModel producto) async{
    final url = '$_url/productos.json';

    final resp = await http.post(url, body: productoModelToJson(producto));

    final decodeData = json.decode(resp.body);

    print(decodeData);

    return true;
  }

  Future<List<ProductoModel>> cargarProductos()async{
    final url = '$_url/productos.json';
    final resp = await http.get(url);

    final Map<String,dynamic> decodeData = json.decode(resp.body);
    final List<ProductoModel> productos = new List();

    if(decodeData ==null) return [];

    decodeData.forEach((id, prod) { 
      final prodTmp = ProductoModel.fromJson(prod);
      prodTmp.id=id;
      productos.add(prodTmp);

    });
    //print(productos);
    return productos;
  }

  Future<int> borrarProducto(String id)async{
    final url = '$_url/productos/$id.json';

    final resp = await http.delete(url);

    print(json.decode(resp.body));

    return 1;
  }
  
}