.section .data
    abertura:	.asciz	"\nControle de cadastro de imoveis para locacao\n"
	borda:	.asciz	"===================================================="
	menuOp:		.asciz	"\nMenu de Opcoes\n<1> Inserir imovel\n<2> Remover imovel\n<3> Consultar imovel\n<4> Relatorio geral\n<5> Finalizar\nDigite opcao => "
	opcao:		.int	0

	pedeNomeProp:	.asciz	"\nQual o nome do proprietario? => "
	pedeCelProp:	.asciz	"\nQual o celular do proprietario? => "
    pedeTipoImov:	.asciz	"\nQual o tipo do imovel (casa/apartamento)? => "
    pedeEndImov:	.asciz	"\nQual o endereco do imovel? => "
    pedeNumQuartosImov:	.asciz	"\nQual o numero de quartos do imovel? => "
    pedeExisteGaragemImov:	.asciz	"\nO imovel possui garagem (S/N)? => "
    pedeMetragemImov:	.asciz	"\nQual a metragem do imovel? (insira apenas o numero) => "
    pedeValorAluguelImov:	.asciz	"\nQual o valor do aluguel do imovel (R$)? (insira apenas o numero) => "

    mostraSucessoOp:	.asciz	"\nOperacao realizada com sucesso!\n"

    mostraNomeProp:	.asciz	"\nNome do proprietario = %s"
    mostraCelProp:	.asciz	"\nCelular do proprietario = %s"
    mostraTipoImov:	.asciz	"\nTipo do imovel = %s"
    mostraEndImov:	.asciz	"\nEndereco do imovel = %s"
    mostraNumQuartosImov:	.asciz	"\nNumero de quartos do imovel = %d"
    mostraExisteGaragemImov:	.asciz	"\nExiste garagem no imovel = %.1s"
    mostraMetragemImov:	.asciz	"\nMetragem do imovel = %d"
    mostraValorAluguelImov:	.asciz	"\nValor do aluguel do imovel (R$) = %d\n"

    tipoNum:            .asciz 	" %d"
	tipoChar:	        .asciz	" %c"
	tipoStr:	        .asciz	"%s"
    tipoStrComEspaco:   .asciz " %[^\n]"
	newLine: 	.asciz 	"\n"

    nome:       .byte 256
    celular:    .byte 16
    tipo:       .byte 16
    endereco:   .byte 256
    numQuartos: .int 0
    garagem:    .byte 0
    metragem:   .int 0
    aluguel:    .int 0
    cleanScanf: .byte 16

    endNovoRegistro: .int 0
    tamanhoTotalRegistroBytes: .int 561

    # ################################# #
    # Registro          => 557 bytes
    # ################################# #
    #
    # Nome[0]           => 256 bytes
    # Celular[256]      => 16 bytes
    # Tipo[272]         => 16 bytes
    # Endereco[288]     => 256 bytes
    # NumQuartos[544]   => 4 bytes
    # Garagem[548]      => 1 byte
    # Metragem[549]     => 4 bytes
    # Aluguel[553]      => 4 bytes
    # ProxRegistro[557] => 4 bytes
    #
    # ################################# #

    cabecaLista: .int 0
    totalRegistros: .int 0

    endRegistroBuscado: .int 0
    endRegistroAnteriorAoBuscado: .int 0
    endRegistroPosteriorAoBuscado: .int 0

.section .text
.globl _start
_start:
    call    carregarArquivoRegistro

	pushl	$abertura
	call	printf
	addl	$4, %esp

_mostraMenu:	
	call	menuOpcoes

	cmpl	$5, opcao
	je	    _fim

	call	trataOpcoes
	
	jmp	    _start

_fim:
	pushl   $0
	call    exit

menuOpcoes:
	pushl	$menuOp
	call	printf

	pushl	$opcao
	pushl	$tipoNum
	call	scanf

	addl	$12, %esp

	RET

trataOpcoes:
	cmpl	$1, opcao
	je	    _inserirImovel

	cmpl	$2, opcao
	je	    _removerImovel
	
	cmpl	$3, opcao
	je	    _consultarImovel

	cmpl	$4, opcao
	je		_obterRelatorioGeral

	ret

carregarArquivoRegistro:
    ret

atualizarArquivoRegistro:
    ret

_inserirImovel:
    # Le a entrada do usuario e armazena em memoria
    call    lerEntradaImovelUsuario

    # Insere na lista
    cmpl    $0, totalRegistros
    je      inserirRegistroEmListaLimpa
    jne     inserirRegistroNaLista

    _contInserirImovel:
    # Atualiza arquivo dos registros
    call    atualizarArquivoRegistro

    jmp     _mostraMenu

inserirRegistroNaLista:
    movl    endNovoRegistro, %ecx
    movl    544(%ecx), %eax
    movl    %eax, numQuartos

    pushl	$numQuartos
    call    buscarRegistro

    movl    endRegistroAnteriorAoBuscado, %eax
    cmpl    $0, %eax
    jne     _atualizaRegAnterior

    _contInserirRegistroNaLista:
    movl    endRegistroBuscado, %ebx
    cmpl    $0, %ebx
    jne     _atualizaRegPosterior
    je      _fimInserirRegistroNaLista

    _atualizaRegAnterior:
    movl    %ecx, 557(%eax) # reg anterior aponta para o novo
    jmp     _contInserirRegistroNaLista

    _atualizaRegPosterior:
    movl    %ebx, 557(%ecx) # reg novo aponta para o buscado

    _fimInserirRegistroNaLista:
    movl    totalRegistros, %eax
    addl    $1, %eax
    movl    %eax, totalRegistros
    
    jmp     _contInserirImovel

inserirRegistroEmListaLimpa:
    movl    endNovoRegistro, %eax
    movl    %eax, cabecaLista
    movl    $1, totalRegistros

    jmp     _contInserirImovel

lerEntradaImovelUsuario:
    # Armazena os dados informados pelo usuario
    
	pushl	tamanhoTotalRegistroBytes
	call	malloc
    movl    %eax, endNovoRegistro
    movl    endNovoRegistro, %esi
	addl	$4,	%esp

    # Nome prop
    pushl	$pedeNomeProp
	call	printf

	pushl	%esi
	pushl	$tipoStrComEspaco
	call	scanf
	addl	$12, %esp
    addl    $256, %esi      # move para o prox. campo

    # Cel prop
    pushl	$pedeCelProp
	call	printf

	pushl	%esi
	pushl	$tipoStr
	call	scanf
	addl	$12, %esp
    addl    $16, %esi      # move para o prox. campo

    # Tipo imov
    pushl	$pedeTipoImov
	call	printf

	pushl	%esi
	pushl	$tipoStr
	call	scanf
	addl	$12, %esp
    addl    $16, %esi      # move para o prox. campo

    # Endereco imov
    pushl	$pedeEndImov
	call	printf

	pushl	%esi
	pushl	$tipoStrComEspaco
	call	scanf
	addl	$12, %esp
    addl    $256, %esi      # move para o prox. campo

    # Numero quartos imov
    pushl	$pedeNumQuartosImov
	call	printf

	pushl	%esi
	pushl	$tipoNum
	call	scanf
	addl	$12, %esp
    addl    $4, %esi      # move para o prox. campo

    # Existe garagem imov
    pushl	$pedeExisteGaragemImov
	call	printf

	pushl	%esi
	pushl	$tipoStr
	call	scanf
	addl	$12, %esp
    addl    $1, %esi      # move para o prox. campo

    # Metragem imov
    pushl	$pedeMetragemImov
	call	printf

	pushl	%esi
	pushl	$tipoNum
	call	scanf
	addl	$12, %esp
    addl    $4, %esi      # move para o prox. campo

    # Valor aluguel imov
    pushl	$pedeValorAluguelImov
	call	printf

	pushl	%esi
	pushl	$tipoNum
	call	scanf
	addl	$12, %esp

    ret

_removerImovel:
    jmp     _mostraMenu

_consultarImovel:
    jmp     _mostraMenu

buscarRegistro:
    # Busca pelo primeiro registro com o numero X de quartos
    # e salva o endereco dele, seu anterior e posterior em memoria

    # Espera-se que X (int) esteja armazenado no topo da pilha antes
    # da chamada a essa funcao

    subl    $4, %esp    # desce no stack para nao pegar o end de retorno
    popl    %ebx        # ebx contem o numero X de quartos

    movl    totalRegistros, %ecx
    movl    cabecaLista, %edx

    movl    $0, endRegistroAnteriorAoBuscado
    movl    %edx, endRegistroBuscado
    movl    $0, endRegistroPosteriorAoBuscado

    _loopBuscarRegistro:
    movl    544(%edx), %eax     # eax contem o numero de quartos do reg atual
    cmpl    %ebx, %eax          
    jge     _fimBuscarRegistro

    movl    %edx, endRegistroAnteriorAoBuscado
    movl    557(%edx), %eax
    movl    %eax, endRegistroBuscado
    
    movl    557(%edx), %esi
    movl    557(%esi), %eax
    movl    %eax, endRegistroPosteriorAoBuscado

    loop _loopBuscarRegistro

    _fimBuscarRegistro:
    ret

_obterRelatorioGeral:
    call imprimirRegistro

    jmp     _mostraMenu

imprimirRegistro:
    # Imprime o registro lido em memoria
    movl    cabecaLista, %esi
    
    # Nome prop
    pushl   %esi
    pushl   $mostraNomeProp
	call	printf
    addl 	$8, %esp
    addl    $256, %esi

    # Cel prop
    pushl   %esi
    pushl   $mostraCelProp
	call	printf
    addl 	$8, %esp
    addl    $16, %esi

    # Tipo imov
    pushl   %esi
    pushl   $mostraTipoImov
	call	printf
    addl 	$8, %esp
    addl    $16, %esi

    # Endereco imov
    pushl   %esi
    pushl   $mostraEndImov
	call	printf
    addl 	$8, %esp
    addl    $256, %esi

    # Num quartos imov
    movl    (%esi), %ebx
    pushl   %ebx
    pushl   $mostraNumQuartosImov
	call	printf
    addl 	$8, %esp
    addl    $4, %esi

    # Existe garagem imov
    pushl   %esi
    pushl   $mostraExisteGaragemImov
	call	printf
    addl 	$8, %esp
    addl    $1, %esi

    # Metragem imov
    movl    (%esi), %ebx
    pushl   %ebx
    pushl   $mostraMetragemImov
	call	printf
    addl 	$8, %esp
    addl    $4, %esi

    # Valor alugel imov
    movl    (%esi), %ebx
    pushl   %ebx
    pushl   $mostraValorAluguelImov
	call	printf
    addl 	$8, %esp
    addl    $4, %esi

    ret
