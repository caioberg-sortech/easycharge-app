import 'package:brasil_fields/brasil_fields.dart';
import 'package:easycharge/http/webclient.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flux_validator_dart/flux_validator_dart.dart';
import 'package:provider/provider.dart';

import 'package:easycharge/components/inputForm.dart';
import '../../models/cliente.dart';
import '../../state/lista_clientes_state.dart';
import '../../state/wizard_cadastro_de_clientes_state.dart';
import 'listagem_clientes.dart';

class FormularioCliente extends StatelessWidget {
  var passoDadosPessoais = _DadosPessoaisForm();
  var passoEndereco = _EnderecoForm();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Easycharge - Cadastro de clientes')),
      body: Consumer<WizardCadastroDeClienteState>(
        builder: (context, wizardState, child) {
          return Stepper(
            controlsBuilder: (context, details) {
              bool ultimoPasso = details.currentStep == 1;
              String rotuloDoUltimoBotao =
                  ultimoPasso ? 'Cadastrar' : 'Avançar';

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: details.onStepCancel,
                    child: Text('Voltar'),
                  ),
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: Text(rotuloDoUltimoBotao),
                  ),
                ],
              );
            },
            type: StepperType.horizontal,
            currentStep: wizardState.passoAtual,
            onStepContinue: () {
              var funcoes = [_salvaPasso1, _salvaPasso2];

              funcoes[wizardState.passoAtual](context);
              // Cliente cliente = Cliente(
              //     'Caio',
              //     '06654939166',
              //     '61995532410',
              //     'caio@gmail.com',
              //     'rua d',
              //     '45',
              //     'jardins',
              //     'brasilia',
              //     'DF',
              //     'programador',
              //     '16551');
              // cadastroCliente(cliente);
            },
            onStepCancel: () => wizardState.volta(),
            steps: [
              Step(
                title: const Text('Dados pessoais'),
                content: passoDadosPessoais,
              ),
              Step(
                title: const Text('Endereco'),
                content: passoEndereco,
              ),
            ],
          );
        },
      ),
    );
  }

  void _salvaPasso1(BuildContext context) {
    if (passoDadosPessoais.isValido()) {
      WizardCadastroDeClienteState state =
          Provider.of<WizardCadastroDeClienteState>(context, listen: false);
      passoDadosPessoais.armazenaDadosNoWizard(state);

      state.avanca();
    }
  }

  void _salvaPasso2(BuildContext context) {
    if (passoEndereco.isValido()) {
      WizardCadastroDeClienteState state =
          Provider.of<WizardCadastroDeClienteState>(context, listen: false);
      passoEndereco.armazenaDadosNoWizard(state);
      Cliente cliente = state.criaCliente();

      cadastroCliente(cliente);
      var listaDeClientes =
          Provider.of<ListaDeClientesState>(context, listen: false);
      listaDeClientes.adicionaCliente(cliente);

      state.volta();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => ListagemClientes()),
          (route) => false);
    }
  }
}

class _DadosPessoaisForm extends StatelessWidget {
  TextEditingController _cpfController = TextEditingController();
  TextEditingController _nomeController = TextEditingController();
  TextEditingController _telefoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _profissaoController = TextEditingController();
  TextEditingController _rendaController = TextEditingController();

  GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Column(
          children: [
            FormInput(
              controller: _nomeController,
              label: 'Nome',
              hint: 'Nome do Cliente',
              maxLenght: 255,
              valid: (value) {
                if (value!.isEmpty) return ' Informe o nome';
              },
              formatters: [],
              keyboardType: TextInputType.text,
            ),
            FormInput(
              controller: _cpfController,
              label: 'CPF',
              hint: '111.222.333.-44',
              maxLenght: 14,
              valid: (value) {
                if (value!.isEmpty) return ' Informe o CPF';
                if (!CPFValidator.isValid(value)) return 'CPF inválido!';
                return null;
              },
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                CpfInputFormatter(),
              ],
              keyboardType: TextInputType.number,
            ),
            FormInput(
              controller: _telefoneController,
              label: 'telefone',
              hint: '(61) 94444-5555',
              maxLenght: 15,
              valid: (value) {
                if (value!.isEmpty) return ' Informe o telefone';
                if (value.length < 15) return 'Telefone inválido!';
                return null;
              },
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                TelefoneInputFormatter()
              ],
              keyboardType: TextInputType.phone,
            ),
            FormInput(
              controller: _emailController,
              label: 'Email',
              hint: 'Email do Cliente',
              maxLenght: 255,
              valid: (value) {
                if (value!.isEmpty) return ' Informe o email';
                if (Validator.email(value)) return 'Email invalido';
                return null;
              },
              formatters: [],
              keyboardType: TextInputType.emailAddress,
            ),
            FormInput(
              controller: _profissaoController,
              label: 'Profissão',
              hint: ' ',
              maxLenght: 255,
              valid: (value) {
                if (value!.isEmpty) return ' Informe a profissão';
                return null;
              },
              formatters: [],
              keyboardType: TextInputType.text,
            ),
            FormInput(
              controller: _rendaController,
              label: 'Renda',
              hint: ' ',
              maxLenght: 255,
              valid: (value) {
                if (value!.isEmpty) return ' Informe a renda';
                return null;
              },
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                CentavosInputFormatter(moeda: true)
              ],
              keyboardType: TextInputType.text,
            ),
          ],
        ),
      ),
    );
  }

  void armazenaDadosNoWizard(state) {
    state.cpf = _cpfController.text;
    state.nome = _nomeController.text;
    state.email = _emailController.text;
    state.profissao = _profissaoController.text;
    state.renda = _rendaController.text;
    state.telefone = _telefoneController.text;
  }

  bool isValido() {
    var currentState = _key.currentState;
    return currentState != null && currentState.validate();
  }
}

class _EnderecoForm extends StatelessWidget {
  TextEditingController _ruaController = TextEditingController();
  TextEditingController _numeroController = TextEditingController();
  TextEditingController _bairroController = TextEditingController();
  TextEditingController _complementoController = TextEditingController();
  TextEditingController _cidadeController = TextEditingController();
  TextEditingController _estadoController = TextEditingController();

  GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FormInput(
              controller: _ruaController,
              label: 'Rua',
              hint: ' ',
              maxLenght: 255,
              valid: (value) {
                if (value!.isEmpty) return ' Informe a rua';
                return null;
              },
              formatters: [],
              keyboardType: TextInputType.text,
            ),
            FormInput(
              controller: _numeroController,
              label: 'Número',
              hint: ' ',
              maxLenght: 255,
              valid: (value) {
                if (value!.isEmpty) return ' Informe o numero do endereço';
                return null;
              },
              formatters: [],
              keyboardType: TextInputType.text,
            ),
            FormInput(
              controller: _complementoController,
              label: 'Complemento',
              hint: ' ',
              maxLenght: 255,
              valid: (value) {
                return null;
              },
              formatters: [],
              keyboardType: TextInputType.text,
            ),
            FormInput(
              controller: _bairroController,
              label: 'Bairro',
              hint: ' ',
              maxLenght: 255,
              valid: (value) {
                if (value!.isEmpty) return ' Informe o bairro';
                return null;
              },
              formatters: [],
              keyboardType: TextInputType.text,
            ),
            FormInput(
              controller: _cidadeController,
              label: 'Cidade',
              hint: ' ',
              maxLenght: 255,
              valid: (value) {
                if (value!.isEmpty) return ' Informe a cidade';
                return null;
              },
              formatters: [],
              keyboardType: TextInputType.text,
            ),
            DropdownButtonFormField(
              hint: Text('Estado'),
              isExpanded: true,
              items: Estados.listaEstadosSigla
                  .map<DropdownMenuItem<String>>((String estado) {
                return DropdownMenuItem<String>(
                  value: estado,
                  child: Text(estado),
                );
              }).toList(),
              onChanged: (String? estadoSelecionado) {
                assert(estadoSelecionado != null);
                _estadoController.text = estadoSelecionado!;
              },
              validator: (value) {
                if (value == null) {
                  return 'Selecione um estado!';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  void armazenaDadosNoWizard(state) {
    state.rua = _ruaController.text;
    state.complemento = _complementoController.text;
    state.bairro = _bairroController.text;
    state.cidade = _cidadeController.text;
    state.estado = _estadoController.text;
    state.numero = _numeroController.text;
  }

  bool isValido() {
    var currentState = _key.currentState;
    return currentState != null && currentState.validate();
  }
}
