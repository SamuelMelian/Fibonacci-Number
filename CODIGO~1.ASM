	.data
n : 	.space 	4
msg1 : 	.asciiz 	"Introduzca la posicion de la sucesion de Fibonacci que quiere calcular"	
msg2 : 	.asciiz 	"Fibonacci de "
msg3 : 	.asciiz 	" es : "
msg4 : 	.asciiz 	"El numero ha de ser mayor o igual que 0"
	.text
	li 	$v0, 4	# Para mostrar el mensaje 1 por pantalla
	la 	$a0, msg1
	syscall
	li 	$v0, 5	# Para leer un entero por teclado
	syscall
	move 	$a0, $v0	# Copiamos el valor introducido por el usuario en a0
	blt 	$a0, 0, error	# Si a0 es menor que 1 muestra un mensaje de error ya que la menor posicion a la que se puede acceder es la primera
	sw	$a0, n	# Cargamos este valor en memoria, concretamente en la direccion de la etiqueta	# Restamos 1 al numero introducido por el usuario ya que la posicion n de la sucesión de Fibonacci corresponde con Fibonacci(n-1)(Ver enunciado de la practica para aclarar)
	jal	fib	# Saltamos a la subrutina fib, estando en a0 el parametro de entrada y guardamos en $ra la direccion de la siguiente instruccion
	move 	$t0, $v0	# La función fib devuelve el valor en v0, de modo que guardamos este valor en t0
	la	$a0, msg2	# Para mostrar el mensaje 2 por pantalla cargamos en a0 la direccion del mensaje
	li 	$v0, 4
	syscall
	lw	$a0, n	# Cargamos el valor introducido por el usuario en a0 para mostrarlo, pues lo habíamos guardado en n
	li 	$v0, 1	# Para mostrar el entero correspondiente a la posicion a calcular por pantalla
	syscall
	la 	$a0, msg3	# Para mostrar el mensaje 3 por pantalla caragmos en a0 la direccion del mensaje
	li 	$v0, 4
	syscall
	move 	$a0, $t0	# Copiamos en a0 el valor de la subrutina, el cual habáimos guardado en t0, para mostrarlo por pantalla
	li	$v0, 1
	syscall
	li 	$v0, 10	# Finalizamos la ejecución
	syscall
fib : 	addi 	$sp, $sp, -16	# Restamos 16 al puntero de pila para poder almacenar 4 valores (de 32 bits cada uno) (operacion "stack" de la pila"
	sw 	$a0, 0($sp)	# Cargamos en sp con desplazamiento 0 el valor de a0, que corresponde con el valor de la sucesion de fibonacci que vamos a calcular (Para calcular fib(n) este valor guarda n)
	sw 	$ra, 4($sp)	# Guardamos en sp con desplazamiento 4 return adress para volver a la siguiente instrucción que correspondía antes de entrar a la subrutina (ya sea en la primera vez o en los pasos recursivos)
	sw	$s0, 8($sp)	# Guardamos en sp con desplazamiento 8 s0, que corresponde al valor de fib(n-1)
	sw 	$s1, 12($sp)	# Guardamos en sp con desplazamiento 12 s1, que corresponde al valor de fib(n-2)
ifcero : 	bnez	$a0, ifuno	# Si el valor de la sucesion que queremos calcular no es 0 (los casos base son 0 y 1), entonces salta a ifuno
	move 	$v0, $zero	# Como es 0, sabemos que fib(0) = 0 y por tanto devolvemos este valor en v0, que es donde hay que retornar el valor de las subrutinas
	b 	retorno	# Salta a retorno para hacer el "pop" de la pila
ifuno : 	slti 	$t0, $a0, 2	# Si a0 (valor de la sucesion que queremos calcular) es 1 (menor que 2 y mayor que 0 ya que habría entrado en el caso anterior de ser 0) guarda un 1 en t0, en otro caso guarda un 0 en este registro
	beq 	$t0, $zero, else	# Si t0 guarda el valor cero (n no es 1) salta a else (caso recursivo n > 2)
	li 	$v0, 1	# Como n es 1, conocemos fib(1) = 1 y guardamos este valor en v0, que es donde hay que devlver el valor de la subrutina
	b	retorno	# Salta a retorno
else : 	subi 	$a0, $a0, 1	# Este es el caso de n > 2 (recursivo). Guardamos en a0 el valor n - 1 para calcular fib(n-1)
	jal 	fib	# Salta a la funcion fib con n-1 como parametro de entrada (guardado en a0) y guarda en $ra la direccion de la siguiente instruccion	
	move 	$s0, $v0	# Copiamos en s0 el valor de retorno de la funcion (fib(n-1)), que se encuentra en v0
	subi 	$a0, $a0, 1	# Guardamos en a0 el valor n - 2 para calcular fib(n-2)
	jal 	fib	# Salta a la subrutina fib con parametro de entrada n - 2 y guarda en $ra la direccion de la siguiente instruccion
	move 	$s1, $v0	# Copiamos en s1 el valor de retorno de la funcion (fib(n-2)), que se encuentra en v0
	add 	$v0, $s0, $s1	# Sumamos s0 y s1 (fib(n-1) + fib(n-2)) y lo guardamos en v0, que es donde hay que guardar el valor de retorno de la funcion). Esto es así ya que para n > 2; fib(n) = fib(n-1) + fib(n-2)
retorno : 	lw 	$a0, 0($sp)	# La etiqueta retorno hace el "pop" de la pila. Primero cargamos desde memoria en a0 el valor de sp con desplazamiento 0 (el cual guarda n según el stack que habíamos hecho, siendo n el valor de fib que queremos calcular)
	lw  	$ra, 4($sp)	# Cargamos de memoria al registro ra elo que hay en el puntero de pila con desplazamiento 4 (según el stack que hemos hecho aquí se guarda la siguiente direcion de instruccion (ra)) 
	lw 	$s0, 8($sp)	# Cargamos de memoria al registro s0 el valor de fib(n-1) (Que se encuentra en la pila (puntero sp) con desplazamiento 8 segùn el stack que hemos elegido hacer)
	lw 	$s1, 12($sp) 	# Cargamos de memoria al registro s1 el valor de fib(n-2) (Que se encuentra en la pila (puntero sp) con desplazamiento 12 según el stack que hemos elegido hacer)
	addi 	$sp, $sp, 16 	# Aumentamos en 16 el puntero de pila (el sentido de stack es "de abajo hacia arriba" y el pop al revés) 	
	jr	$ra	# Salta a ejecutar la intstrucción cuya direccion esta en $ra (fin de la subrutina fib)
error: 	la 	$a0, msg4	# Para mostrar un mensaje de error en caso de que la posicion que quiere calcular el usuario sea menor que 1
	li 	$v0, 4	
	syscall
	li 	$v0, 10	# Fin de la ejecución del programa
	syscall


				
 
