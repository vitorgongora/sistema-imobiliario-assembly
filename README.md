# Descrição dos principais módulos

* Organização em memória do registro de 561 bytes
  * Nome[0]           => 256 bytes
  * Celular[256]      => 16 bytes
  * Tipo[272]         => 16 bytes
  * Endereco[288]     => 256 bytes
  * NumQuartos[544]   => 4 bytes
  * Garagem[548]      => 1 byte
  * Metragem[549]     => 4 bytes
  * Aluguel[553]      => 4 bytes
  * ProxRegistro[557] => 4 bytes

* menuOpcoes
  * <1> Inserir imovel
  * <2> Remover imovel
  * <3> Consultar imoveis  *(Mostra todos que possuem X quartos)*
  * <4> Relatorio geral		*(Mostra todos imóveis cadastrados)*
  * <5> Recuperar registro  *(Mostra o registro na posição X)*
  * <6> Salvar registros		*(Salva os registros atualmente na memória no arquivo db.txt)*
  * <7> Finalizar

* trataOpcoes
  * Responsável por gerenciar as escolhas do usuário e redirecionar para a execução do que foi solicitado.

* carregarArquivoRegistro
  * Carrega a lista com os dados existentes no arquivo “db.txt”. Sempre roda na abertura do programa.

* atualizarArquivoRegistro
  * Salva a lista atualmente carregada no programa no arquivo “db.txt”. O arquivo é sempre apagado e então escrito.

* _inserirImovel
  * Responsável por gerir a inserção de um novo imóvel na lista na posição adequada (número crescente de quartos). Redireciona o código para ler input do usuário e inserir na posição adequada da lista.

* inserirRegistroNaLista
  * Insere o imóvel em uma lista já existente.

* inserirRegistroNaListaLimpa
  * Insere o imóvel na cabeça da lista vazia.

* lerEntradaImovelUsuario
  * Aloca memória e armazena os dados informados pelo usuário usando scanf com destino no espaço alocado.

* _removerImovel
  * Responsável por gerir a remoção do imóvel da lista atualmente carregada no sistema.

* _consultarImovel
  * Responsável por gerir a consulta de todos imóveis com um número X de quartos informado pelo usuário.

* buscarRegistro
  * Função auxiliar que busca pela posição do primeiro registro com um número X de quartos passado como parâmetro, bem como o antecessor desse registro.

* buscarRegistroMaiorQueBuscado
  * Função auxiliar que busca pela posição do primeiro registro com um número maior que X de quartos passado como parâmetro.

* _obterRelatorioGeral
  * Responsável por gerir a exibição de todos imóveis na lista.

* imprimirRegistros
  * Recebe como parâmetro o endereço inicial do primeiro registro e o número de registros que devem ser exibidos. E imprime os dados em tela conforme solicitado.

* _recuperarImovel
  * Exibe ao usuário o imóvel da posição X da lista.

# References
Blum, R. (2005). Professional Assembly Language. Germany: Wiley.
