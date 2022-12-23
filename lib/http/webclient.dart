import 'dart:convert';

import 'package:easycharge/models/clienteApi.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';

import '../models/cliente.dart';

class LoggingInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    debugPrint(data.body);
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    return data;
  }
}

Future<List<ClienteApi>> findAll() async {
  final List<ClienteApi> clientes = [];
  final Client client =
      InterceptedClient.build(interceptors: [LoggingInterceptor()]);
  final Response response =
      await client.get(Uri.http('localhost:8080', '/api/clientes'));
  List<dynamic> decodedJson = jsonDecode('[${response.body}]')[0]['content'];

  for (Map<String, dynamic> elemento in decodedJson) {
    final ClienteApi cliente = ClienteApi(
        elemento['id'],
        elemento['nome'],
        elemento['cpf'],
        elemento['telefone'],
        elemento['local'],
        elemento['renda'],
        elemento['status']);

    clientes.add(cliente);
  }

  return clientes;
}

Future<ClienteApi> cadastroCliente(Cliente cliente) async {
  final Client client =
      InterceptedClient.build(interceptors: [LoggingInterceptor()]);

  final String clienteJson = jsonEncode(cliente.mapJson());

  final Response response = await client.post(
      Uri.http('10.0.3.252:8080', '/api/clientes'),
      headers: {'Content-type': 'application/json'},
      body: clienteJson);

  Map<String, dynamic> json = jsonDecode(response.body);

  debugPrint(response.body);
  return ClienteApi(json['id'], json['nome'], json['cpf'], json['telefone'],
      json['local'], json['renda'], json['status']);
}
