.section .data
    abertura:	.asciz	"\n====================================================\nControle de cadastro de imoveis para locacao\n====================================================\n"
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

    mostraPosRegistro: .asciz "\nPos. do registro = %d"
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

    pedeNumDeQuartosFiltro: .asciz "\nPor qual quantia de quartos deseja filtrar? => "
    numQuartosFiltro: .int 0
    nenhumRegistroEncontradoFiltro: .asciz "\nNenhum registro encontrado\n"

    pedePosRemover: .asciz "\nQual a posicao do registro que deseja remover? => "
    posRegRemover:  .int 0
    mostraPosInvalida:	.asciz	"\nPosicao informada invalida\n"

    mostraSucessoOp:	.asciz	"\nOperacao realizada com sucesso!\n"

    endNovoRegistro: .int 0
    tamanhoTotalRegistroBytes: .int 561

    # ################################# #
    # Registro          => 561 bytes
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

    posRegistroBuscado: .int 0
    posRegistroMaiorQueBuscado: .int 0
    endRegistroBuscado: .int 0
    endRegistroAnteriorAoBuscado: .int 0

.section .text
.globl _start
_start:
    call    carregarArquivoRegistro

_mostraMenu:
    pushl	$abertura
	call	printf
	addl	$4, %esp

	call	menuOpcoes

	cmpl	$5, opcao
	je	    _fim

	call	trataOpcoes
	
	jmp	    _mostraMenu

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
    movl    544(%ecx), %eax     # num quartos em %eax

    pushl	%eax    # passa o num de quartos como param
    call    buscarRegistro

    movl    endNovoRegistro, %ecx
    movl    endRegistroAnteriorAoBuscado, %eax
    cmpl    $0, %eax
    jne     _atualizaRegAnterior

    _atualizaCabecaLista:
    movl    %ecx, cabecaLista

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
    addl    $4, %esi      # move para o prox. campo

    # Ponteiro proximo reg
    # default: 0
    movl    $0, (%esi)

    ret

_removerImovel:
    movl    totalRegistros, %eax
    cmpl    $0, %eax
    je      _nenhumRegistroEncontrado

    pushl	$pedePosRemover
	call	printf

    pushl	$posRegRemover
	pushl	$tipoNum
	call	scanf
    addl	$12, %esp

    movl    posRegRemover, %eax
    movl    tamanhoTotalRegistroBytes, %ebx
    dec     %ebx

    cmpl    $0, %eax
    jl      _posicaoInvalida
    cmpl    %ebx, %ebx
    jg      _posicaoInvalida

    jmp     _mostraMenu

    _posicaoInvalida:

    jmp     _mostraMenu

_consultarImovel:
    movl    totalRegistros, %eax
    cmpl    $0, %eax
    je      _nenhumRegistroEncontrado

    pushl	$pedeNumDeQuartosFiltro
	call	printf

	pushl	$numQuartosFiltro    # contem o num de quartos
	pushl	$tipoNum
	call	scanf
    addl	$12, %esp

    pushl   numQuartosFiltro   # passa num quartos como param
    call    buscarRegistro

    pushl   numQuartosFiltro   # passa num quartos como param
    call    buscarRegistroMaiorQueBuscado

    movl    posRegistroMaiorQueBuscado, %edx
    movl    posRegistroBuscado, %eax

    cmpl    %edx, %eax          # se igual ha apenas 1 registro ou nenhum
    jne     _contCalculoReg     # continua calc. se diferente

    movl    endRegistroBuscado, %esi
    cmpl    $0, %esi
    je      _nenhumRegistroEncontrado   # se endRegistroBuscado eh 0 toda lista percorrida sem encontrar

    movl    544(%esi), %esi     # esi contem o numero de quartos

    cmpl    numQuartosFiltro, %esi
    jne     _nenhumRegistroEncontrado   # se o reg. nao possui o num. quartos buscado
                                        # mostra msg de erro
    inc     %edx            # incrementa para subl resultar em 1

    _contCalculoReg:
    subl    %eax, %edx  # edx - eax = num. reg. para mostrar

    movl   endRegistroBuscado, %edi

    pushl   %edi    # end. primeiro registro
    pushl   %edx    # num. registros para mostrar
    pushl   %eax    # pos. inicial da lista
    call    imprimirRegistros

    jmp     _mostraMenu

    _nenhumRegistroEncontrado:
    pushl	$nenhumRegistroEncontradoFiltro
	call	printf

    jmp     _mostraMenu

buscarRegistro:
    # Busca pelo primeiro registro com o numero X de quartos
    # e salva o endereco dele e seu anterior em memoria

    # Espera-se que X (int) esteja armazenado no topo da pilha antes
    # da chamada a essa funcao

    popl    %ecx        # salva end de ret em ecx
    popl    %ebx        # ebx contem o numero X de quartos
    pushl   %ecx        # adiciona end de ret na pilha novamente

    movl    totalRegistros, %ecx
    movl    cabecaLista, %edx
    movl    $-1, %edi    # posicao do registro buscado

    movl    $0, endRegistroAnteriorAoBuscado
    movl    %edx, endRegistroBuscado

    _loopBuscarRegistro:
    inc     %edi                # incrementa posicao do registro buscado
    movl    %edi, posRegistroBuscado
    movl    544(%edx), %eax     # eax contem o numero de quartos do reg atual
    cmpl    %ebx, %eax          
    jge     _fimBuscarRegistro  # eax >= ebx

    movl    %edx, endRegistroAnteriorAoBuscado
    movl    557(%edx), %eax
    movl    %eax, endRegistroBuscado
    movl    %eax, %edx

    loop _loopBuscarRegistro

    _fimBuscarRegistro:
    ret

buscarRegistroMaiorQueBuscado:
    # Busca pelo primeiro registro com o numero maior que X de quartos
    # e salva o endereco dele e seu anterior em memoria

    # Espera-se que X (int) esteja armazenado no topo da pilha antes
    # da chamada a essa funcao

    popl    %ecx        # salva end de ret em ecx
    popl    %ebx        # ebx contem o numero X de quartos
    pushl   %ecx        # adiciona end de ret na pilha novamente

    movl    totalRegistros, %ecx
    movl    cabecaLista, %edx
    movl    $-1, %edi    # posicao do registro buscado
    movl    $0, posRegistroMaiorQueBuscado

    # movl    %edx, endRegistroBuscado

    _loopBuscarRegistroMaiorQueBuscado:
    inc     %edi                # incrementa posicao do registro buscado
    movl    %edi, posRegistroMaiorQueBuscado
    movl    544(%edx), %eax     # eax contem o numero de quartos do reg atual
    cmpl    %ebx, %eax          
    jg     _fimBuscarRegistroMaiorQueBuscado  # eax > ebx

    # movl    %edx, endRegistroAnteriorAoBuscado
    movl    557(%edx), %eax
    # movl    %eax, endRegistroBuscado
    movl    %eax, %edx

    loop _loopBuscarRegistroMaiorQueBuscado

    _fimBuscarRegistroMaiorQueBuscado:
    ret

_obterRelatorioGeral:
    movl    totalRegistros, %eax
    cmpl    $0, %eax
    je      _nenhumRegistroEncontrado
    
    pushl   cabecaLista
    pushl   totalRegistros
    pushl   $0
    call    imprimirRegistros

    jmp     _mostraMenu

imprimirRegistros:
    # Imprime os registros de acordo com variaveis
    # passadas para a funcao via pilha

    # edi = numero de registros
    # esi = end do primeiro registro

    addl    $4, %esp    # move o stack para nao pegar o end de retorno
    popl    %ebp        # ebp contem a pos. do primeiro registro
    popl    %edi        # edi contem o numero de registros
    popl    %esi        # esi contem o end do primeiro registro

    # movl   posRegistroBuscado, %ebp
    
    _loopImprimirRegistros:
    # Posicao do registro
    pushl   %ebp
    pushl   $mostraPosRegistro
	call	printf
    addl 	$8, %esp
    inc     %ebp    # incrementa a posicao do registro para o prox.

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

    # Move para o proximo registro
    movl    (%esi), %eax
    movl    %eax, %esi

    # Loop manual, label out of range para instr. loop
    dec     %edi
    cmpl    $0, %edi
    jne     _loopImprimirRegistros

    ret
