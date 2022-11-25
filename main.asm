#    █████╗ ██████╗  █████╗  ██████╗     ███████╗    ███████╗██╗   ██╗ █████╗                                             
#   ██╔══██╗██╔══██╗██╔══██╗██╔═══██╗    ██╔════╝    ██╔════╝██║   ██║██╔══██╗                                            
#   ███████║██║  ██║███████║██║   ██║    █████╗      █████╗  ██║   ██║███████║                                            
#   ██╔══██║██║  ██║██╔══██║██║   ██║    ██╔══╝      ██╔══╝  ╚██╗ ██╔╝██╔══██║                                            
#   ██║  ██║██████╔╝██║  ██║╚██████╔╝    ███████╗    ███████╗ ╚████╔╝ ██║  ██║                                            
#   ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝     ╚══════╝    ╚══════╝  ╚═══╝  ╚═╝  ╚═╝                                            
#                                                                                                                         
#    ██████╗     ██████╗ ██████╗ ██╗███╗   ███╗███████╗██╗██████╗  ██████╗     ███████╗██████╗ ██╗   ██╗████████╗ ██████╗ 
#   ██╔═══██╗    ██╔══██╗██╔══██╗██║████╗ ████║██╔════╝██║██╔══██╗██╔═══██╗    ██╔════╝██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗
#   ██║   ██║    ██████╔╝██████╔╝██║██╔████╔██║█████╗  ██║██████╔╝██║   ██║    █████╗  ██████╔╝██║   ██║   ██║   ██║   ██║
#   ██║   ██║    ██╔═══╝ ██╔══██╗██║██║╚██╔╝██║██╔══╝  ██║██╔══██╗██║   ██║    ██╔══╝  ██╔══██╗██║   ██║   ██║   ██║   ██║
#   ╚██████╔╝    ██║     ██║  ██║██║██║ ╚═╝ ██║███████╗██║██║  ██║╚██████╔╝    ██║     ██║  ██║╚██████╔╝   ██║   ╚██████╔╝
#    ╚═════╝     ╚═╝     ╚═╝  ╚═╝╚═╝╚═╝     ╚═╝╚══════╝╚═╝╚═╝  ╚═╝ ╚═════╝     ╚═╝     ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝ 
#                                                                                                                       

# O jogador que comer 5 frutinhas primeiro vence o jogo.

#   __   __        ___    __        __        __   __   ___  __      __   __              __   __  
#  /  ` /  \ |\ | |__  | / _` |  | |__)  /\  /  ` /  \ |__  /__`    |  \ /  \     |\/| | |__) /__` 
#  \__, \__/ | \| |    | \__> \__/ |  \ /~~\ \__, \__/ |___ .__/    |__/ \__/     |  | | |    .__/ 
#                                                                                                  

# BITMAP DISPLAY ######################################
#                                                     #
#  Unit width      16px                               #
#  Unit height     16px                               #
#  Display width   512px                              #
#  Display height  512px                              #
#  Base address    (static data)                      #
#                                                     #
# #####################################################

# KEYBOARD SIMULATOR ##################################
#                                                     #
# Utilizar o simulador de teclado para interagir      #
#                                                     #
#  P1  ^         P2  ^                                #
#      W             I                                #
#  < A S D >     < J K L >                            #
#                                                     #
# #####################################################


.data

  frameBuffer: .space 0x01000         # ((32x32) * 4) px

  # Mensagens de vitória
  vitoriaJogadorUm:   .asciiz "\n ** O jogador 1 venceu ** \n\n"
  vitoriaJogadorDois: .asciiz "\n ** O jogador 2 venceu ** \n\n"

.text

main:
  lui $t0, 0xFFFF                     # $t0 = 0xFFFF0000

  li    $s5, 0                        # Pontuacao jogador 1
  li    $s6, 0                        # Pontuacao jogador 2
  la    $s3, frameBuffer              # posicao do jogador 1
  la    $s7, frameBuffer              # posicao do jogador 2

  la    $s4, frameBuffer              # posicao da fruta
  addi  $s3, $s3, 3836  
  addi  $s7, $s7, 3832  
  jal   getFruitPosition  

defColors:  
  li    $t2, 0x0000FF00               # $t1 = verde      -- Fundo
  li    $t3, 0x000000FF               # $t2 = azul       -- Jogador
  li    $t4, 0x00FF0000               # $t3 = vermelho   -- Fruta

updateScreen: 
  jal verificarPontuacao  

  defVariablesLoop: 
    la    $t1, frameBuffer  
    li    $s0, 1024                   # Quantidade total de pixels
    li    $s1, 0                      # contador de pixels
    li    $s2, 0  

  screenPrintLoop:  
    jal printBackground 
    beq   $t1, $s3, printPlayer       # Mostrar jogador 1
    beq   $t1, $s7, printPlayer       # Mostrar jogador 2
    beq   $t1, $s4, printFruit        # Mostrar frutinha

    j     screenPrintLoop             # else goto background

commandListener:  
  lw    $t9, 0($t0)                   # load control byte
  andi  $t9, $t9, 0x0001              # check to see if new data is there
  beq   $t9, $zero, commandListener   # loop if not
  lw    $a0, 4($t0)                   # load data byte

  # Verificar movimentos do jogador 1
  beq   $a0, 119, p1moverCima         # tecla w
  beq   $a0, 97,  p1moverEsquerda     # tecla a
  beq   $a0, 115, p1moverBaixo        # tecla s
  beq   $a0, 100, p1moverDireita      # tecla d

  # Verificar movimentos do jogador 2
  beq   $a0, 105, p2moverCima         # tecla i
  beq   $a0, 106, p2moverEsquerda     # tecla j
  beq   $a0, 107, p2moverBaixo        # tecla k
  beq   $a0, 108, p2moverDireita      # tecla l

  j commandListener


exit:
  li    $v0, 10                       # Finalizar aplicacao
  syscall
 
printBackground:
  sw    $t2, 0     ($t1)
  j incrementPixelOnScreenPosition

printPlayer:
  sw    $t3, 0     ($t1)
  j incrementPixelOnScreenPosition

printFruit:
  sw    $t4, 0     ($t1)
  j incrementPixelOnScreenPosition

incrementPixelOnScreenPosition:
  addi  $t1, $t1,     4               # Enviar para o proximo endereco
  addi  $s1, $s1,     1               # Atualizar posição do pixel atual
  beq   $s1, $s0, commandListener     # Se estiver no final da tela aguardar um comando dos jogadores
  jr    $ra


p1moverDireita:
  addi  $s3, $s3,     4               # andar para direita
  j updateScreen        

p1moverEsquerda:        
  addi  $s3, $s3,     -4              # andar para esquerda
  j updateScreen        

p1moverCima:        
  addi  $s3, $s3,     -128            # andar para cima
  j updateScreen        

p1moverBaixo:       
  addi  $s3, $s3,     128             # andar para baixo
  j updateScreen        

p2moverDireita:       
  addi  $s7, $s7,     4               # andar para direita
  j updateScreen        

p2moverEsquerda:        
  addi  $s7, $s7,     -4              # andar para cima
  j updateScreen        

p2moverCima:        
  addi  $s7, $s7,     -128            # andar para cima
  j updateScreen        

p2moverBaixo:       
  addi  $s7, $s7,     128             # andar para baixo
  j updateScreen

getFruitPosition:
  li $v0, 42 
  li $a1, 959                         # definir valor maximo para o numero aleatorio
  syscall                             # Valor aletorio armazenado em $a0

  li $v0, 1
  syscall
  
  li $s2, 0
  la $s4, frameBuffer

  loopFrutinha:                       # Multiplicação
    beq $s2, $a0, fimLoop
    addi $s4, $s4, 4
    addi $s2, $s2, 1

  j loopFrutinha
  fimLoop:
    jr $ra

verificarPontuacao:
  beq $s3, $s4, somarPontuacaoP1
  beq $s7, $s4, somarPontuacaoP2
  jr  $ra
    
  somarPontuacaoP1:
    addi $s5, $s5, 1
    beq $s5, 5, anunciarVencedor1
    j getFruitPosition

  somarPontuacaoP2:
    addi  $s6, $s6, 1
    beq   $s6, 5, anunciarVencedor2
    j     getFruitPosition
  
  anunciarVencedor1:
    li  $v0,4 # print string
    la  $a0, vitoriaJogadorUm
    syscall
    j   exit
  
  anunciarVencedor2:
    li  $v0,4 # print string
    la  $a0, vitoriaJogadorDois
    syscall
    j   exit
