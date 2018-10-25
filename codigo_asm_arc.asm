.begin
.org 2048

!Almaceno datos en memoria, que posteriormente voy a utilizar como mascaras para correr instrucciones internas auxiliares
mascara_BB: 2 !bit 1
mascara_BP: 1 !bit 0
mascara_V1: 65536
mascara_A1: 131072
mascara_R1: 262144
mascara_V2: 16777216 
mascara_A2: 33554432
mascara_R2: 67108864


botones_luces .equ 0xFFC !Aca va la direccion a donde estan mapeados los botones, y las luces (la del enunciado del TP era demasiado alta, tuvimos que cambiarla a una mas baja). Idem 4092.


!%r1 Contiene los Botones y luces de salida (los volvemos a leer de memoria cada vez que controlamos el boton de bomberos o el del peaton
!%r3 Lo utilizamos como registro auxiliar
!%r4 contiene el numero de estado actual, siendo A = 1, B = 2, ..., I = 9


and %r0,%r0,%r4 ! r4 <-- 0

!Comienza el programa en el estado A
ba estado_A



estado_A:

	ld [botones_luces],%r1 !leo los botones y las luces de memoria

	ld [mascara_V1],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en V1
	ld [mascara_A1],%r3
	or %r3,%r1,%r1 !Fuerza un 1 en A1
	ld [mascara_R1],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en R1
	ld [mascara_V2],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en V2
	ld [mascara_A2],%r3
	or %r3,%r1,%r1 !Fuerza un 1 en A2
	ld [mascara_R2],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en R2

	st %r1, [botones_luces] ! ACTUALIZO LAS LUCES DEL SEMAFORO EN MEMORIA
	add %r0,1,%r4 !Actualizo el numero de estado

	call contar_tiempo !Hace pasar un segundo
	call check_boton_BB !Controla si presionaron el botón BB (bomberos), y si corresponde salta a la secuencia de bomberos
	call check_boton_BP !Controla si presionaron el botón BP (peatón), y si corresponde empieza con la rutina para que cruce el peatón
	ba estado_B !Si no presionaron BB ni BP, pasa al estado B y continúan los semaforos intermitentes



estado_B:

	ld [botones_luces],%r1 !leo los botones y las luces de memoria

	ld [mascara_V1],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en V1
	ld [mascara_A1],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en A1
	ld [mascara_R1],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en R1
	ld [mascara_V2],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en V2
	ld [mascara_A2],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en A2
	ld [mascara_R2],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en R2

	st %r1, [botones_luces] ! ACTUALIZO LAS LUCES DEL SEMAFORO EN MEMORIA
	add %r0,2,%r4 !Actualizo el numero de estado

	call contar_tiempo !Hace pasar un segundo
	call check_boton_BB !Controla si presionaron el botón BB (bomberos), y si corresponde salta a la secuencia de bomberos
	call check_boton_BP !Controla si presionaron el botón BP (peatón), y si corresponde empieza con la rutina para que cruce el peatón
	ba estado_A !Si no presionaron BB ni BP, pasa al estado A y continúan los semaforos intermitentes



estado_C:

	ld [botones_luces],%r1 !leo los botones y las luces de memoria

	ld [mascara_BP],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en el botón BP, ya que ya lo leí y entré en la secuencia

	ld [mascara_V1],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en V1
	ld [mascara_A1],%r3
	or %r3,%r1,%r1 !Fuerza un 1 en A1
	ld [mascara_R1],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en R1
	ld [mascara_V2],%r3
	xnor %r3,%r0,%r3 !Not r3 
	and %r3,%r1,%r1 !Fuerza un 0 en V2
	ld [mascara_A2],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en A2
	ld [mascara_R2],%r3
	or %r3,%r1,%r1 !Fuerza un 1 en R2

	st %r1, [botones_luces] ! ACTUALIZO LAS LUCES DEL SEMAFORO y suelto el botón BP EN MEMORIA
	add %r0,3,%r4!Actualizo el numero de estado

	andcc %r0, %r0, %r27

	seguir_en_C:
		call contar_tiempo !Hace pasar un segundo
		add %r27, 1, %r27 !sumo cada segundo que transcurre, para saber cuando tengo que cambiar de estado
		call check_boton_BB !verifico que no hayan presionado el boton de bomberos, sino debo pasar al estado I
		addcc %r27, -5, %r0 !cuando la suma llega a 5 significa que pasaron 5 segundos
		be estado_D !paso al estado siguiente si ya pasaron los 30 segundos
		ba seguir_en_C !si no pasaron 5 segundos, sigo en el mismo estado contando hasta que pasen 5 segundos


estado_D:

	ld [botones_luces],%r1 !leo los botones y las luces de memoria

	ld [mascara_R1],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en R1
	ld [mascara_A1],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en A1
	ld [mascara_V1],%r3
	or %r3,%r1,%r1 !Fuerza un 1 en V1
	ld [mascara_R2],%r3
	or %r3,%r1,%r1 !Fuerza un 1 en R2
	ld [mascara_A2],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en A2
	ld [mascara_V2],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en V2

	st %r1, [botones_luces] !  ACTUALIZO LAS LUCES DEL SEMAFORO
	add %r0,4,%r4!Actualizo el numero de estado

	andcc %r0, %r0, %r27

	seguir_en_D:
		call contar_tiempo !Hace pasar un segundo
		addcc %r27, 1, %r27 !sumo cada segundo que transcurre, para saber cuando tengo que cambiar de estado
		call check_boton_BB !verifico que no hayan presionado el boton de bomberos, sino debo pasar al estado I
		addcc %r27, -30, %r0  !cuando la suma llega a 30 significa que pasaron 30 segundos
		be estado_E !paso al estado siguiente si ya pasaron los 30 segundos
		ba seguir_en_D !si no pasaron 30 segundos, sigo en el mismo estado contando hasta que pasen 30 segundos



estado_E:

	ld [botones_luces],%r1 !leo los botones y las luces de memoria

	ld [mascara_V1],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en V1
	ld [mascara_A1],%r3
	or %r3,%r1,%r1 !Fuerza un 1 en A1
	ld [mascara_R1],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en R1
	ld [mascara_R2],%r3
	or %r3,%r1,%r1 !Fuerza un 1 en R2
	ld [mascara_A2],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en A2
	ld [mascara_V2],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en V2

	st %r1, [botones_luces] !  ACTUALIZO LAS LUCES DEL SEMAFORO
	add %r0,5,%r4!Actualizo el numero de estado

	andcc %r0, %r0, %r27

	seguir_en_E:
		call contar_tiempo !Hace pasar un segundo
		addcc %r27, 1, %r27  !sumo cada segundo que transcurre, para saber cuando tengo que cambiar de estado
		call check_boton_BB !verifico que no hayan presionado el boton de bomberos, sino debo pasar al estado I
		addcc %r27, -5, %r0  !cuando la suma llega a 5 significa que pasaron 5 segundos
		be estado_F !paso al estado siguiente si ya pasaron los 5 segundos
		ba seguir_en_E  !si no pasaron 5 segundos, sigo en el mismo estado contando hasta que pasen 5 segundos


estado_F:

	ld [botones_luces],%r1 !leo los botones y las luces de memoria

	ld [mascara_R1],%r3
	or %r3,%r1,%r1 !Fuerza un 1 en R1
	ld [mascara_A1],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en A1
	ld [mascara_V1],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en V1
	ld [mascara_V2],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en V2
	ld [mascara_A2],%r3
	or %r3,%r1,%r1 !Fuerza un 1 en A2
	ld [mascara_R2],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en R2

	st %r1, [botones_luces] ! ACTUALIZO LAS LUCES DEL SEMAFORO
	add %r0,6,%r4!Actualizo el numero de estado

	andcc %r0, %r0, %r27

	seguir_en_F:
		call contar_tiempo !Hace pasar un segundo
		addcc %r27, 1, %r27 !sumo cada segundo que transcurre, para saber cuando tengo que cambiar de estado
		call check_boton_BB !verifico que no hayan presionado el boton de bomberos, sino debo pasar al estado I
		addcc %r27, -5, %r0 !cuando la suma llega a 5 significa que pasaron 5 segundos
		be estado_G !paso al estado siguiente si ya pasaron los 5 segundos
		ba seguir_en_F !si no pasaron 5 segundos, sigo en el mismo estado contando hasta que pasen 5 segundos



estado_G:

	ld [botones_luces],%r1 !leo los botones y las luces de memoria

	ld [mascara_R1],%r3
	or %r3,%r1,%r1 !Fuerza un 1 en R1
	ld [mascara_A1],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en A1
	ld [mascara_V1],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en V1
	ld [mascara_R2],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en R2
	ld [mascara_A2],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en A2
	ld [mascara_V2],%r3
	or %r3,%r1,%r1 !Fuerza un 1 en V2

	st %r1, [botones_luces] !  ACTUALIZO LAS LUCES DEL SEMAFORO
	add %r0,7,%r4!Actualizo el numero de estado

	andcc %r0, %r0, %r27

	seguir_en_G:
		call contar_tiempo !Hace pasar un segundo
		addcc %r27, 1, %r27  !sumo cada segundo que transcurre, para saber cuando tengo que cambiar de estado
		call check_boton_BB  !verifico que no hayan presionado el boton de bomberos, sino debo pasar al estado I
		addcc %r27, -30, %r0  !cuando la suma llega a 30 significa que pasaron 30 segundos
		be estado_H  !paso al estado siguiente si ya pasaron los 30 segundos
		ba seguir_en_G  !si no pasaron 30 segundos, sigo en el mismo estado contando hasta que pasen 30 segundos


estado_H:

	ld [botones_luces],%r1 !leo los botones y las luces de memoria

	ld [mascara_R1],%r3
	or %r3,%r1,%r1 !Fuerza un 1 en R1
	ld [mascara_A1],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en A1
	ld [mascara_V1],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en V1
	ld [mascara_V2],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en V2
	ld [mascara_A2],%r3
	or %r3,%r1,%r1 !Fuerza un 1 en A2
	ld [mascara_R2],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en R2

	st %r1, [botones_luces] !  ACTUALIZO LAS LUCES DEL SEMAFORO
	add %r0,8,%r4 !Actualizo el numero de estado

	andcc %r0, %r0, %r27

	seguir_en_H:
		call contar_tiempo !Hace pasar un segundo
		addcc %r27, 1, %r27  !sumo cada segundo que transcurre, para saber cuando tengo que cambiar de estado
		call check_boton_BB  !verifico que no hayan presionado el boton de bomberos, sino debo pasar al estado I
		addcc %r27, -5, %r0 !cuando la suma llega a 5 significa que pasaron 5 segundos
		be volver_a_estado_A !paso al estado siguiente si ya pasaron los 5 segundos
		ba seguir_en_H  !si no pasaron 5 segundos, sigo en el mismo estado contando hasta que pasen 5 segundos



volver_a_estado_A:

	ld [botones_luces],%r1 !leo los botones y las luces de memoria

	ld [mascara_BP],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en el botón BP, hasta que no vuelva al estado inicial, el botón no tiene que tener efecto
	st %r1, [botones_luces] ! Suelto el botón BP EN MEMORIA por si lo presiono durante la secuencia
	and %r0, %r0, %r27 !limpio el registro 27 para no confundir en la simulacion
	ba estado_A !vuelvo al estado A (inicial)



estado_I:

	and %r0, %r0, %r27 !limpio el registro 27 para no confundir en la simulacion
	ld [botones_luces],%r1 !leo los botones y las luces de memoria

	ld [mascara_BB],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en el botón BB, ya que ya lo leí y entré en la secuencia, sino de ahora en más simpre va a estar entrando y saliendo porque se mantiene el botón presionado

	ld [mascara_R1],%r3
	or %r3,%r1,%r1 !Fuerza un 1 en la posicion de R1
	ld [mascara_A1],%r3
	or %r3,%r1,%r1 !Fuerza un 1 en A1
	ld [mascara_R2],%r3
	or %r3,%r1,%r1 !Fuerza un 1 en R2
	ld [mascara_A2],%r3
	or %r3,%r1,%r1 !Fuerza un 1 en A2
	ld [mascara_V1],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en V1
	ld [mascara_V2],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en V2	

	st %r1, [botones_luces] ! ACTUALIZO LAS LUCES DEL SEMAFORO y suelto el botón BB EN MEMORIA
	add %r0,9,%r4! Actualizo el numero de estado

	seguir_en_I:
		call contar_tiempo !Hace pasar un segundo
		call check_boton_BB_salida !controla si volvieron a presionar el boton de bomberos, en cuyo caso debo volver al estado A
		ba seguir_en_I !si no presionaron el botón de bomberos, permanezco en el estado actual



check_boton_BB:

	ld [botones_luces],%r1 !leo los botones y las luces de memoria
	ld [mascara_BB],%r3
	and %r3,%r1,%r3 !Me fijo si esta presionado el boton BB
	addcc %r3, -1, %r0
	bpos estado_I !si está presionado el botón BB, debo saltar al estado I sin importar en que estado estoy
	jmpl %r15+4, %r0 !sino presionaron el botón BB, vuelvo a la subrutina que invocó a esta función



check_boton_BB_salida:

	ld [botones_luces],%r1 !leo los botones y las luces de memoria
	ld [mascara_BB],%r3
	and %r3,%r1,%r3 !Me fijo si esta presionado el boton BB
	addcc %r3, -1, %r0
	bpos reiniciar_botones_BBBP_y_pasar_a_estado_A  !si está presionado el botón BB, debo salir del estado I y volver al estado A (inicial) porque ya salió el camion de bomberos
	jmpl %r15+4, %r0 !sino presionaron el botón BB, vuelvo a la subrutina que invocó a esta función



reiniciar_botones_BBBP_y_pasar_a_estado_A:

	ld [botones_luces],%r1 !leo los botones y las luces de memoria
	ld [mascara_BB],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en el botón BB, sino de ahora en más simpre va a estar entrando y saliendo porque se mantiene el botón presionado
	ld [mascara_BP],%r3
	xnor %r3,%r0,%r3 !Not r3
	and %r3,%r1,%r1 !Fuerza un 0 en el botón BP, para que cuando vuelva al estado A no ingrese directamente a la secuencia del peaton
	st %r1, [botones_luces] ! suelto el botón BB y BP EN MEMORIA
	ba estado_A !regreso al estado A



check_boton_BP:

	ld [botones_luces],%r1 !leo los botones y las luces de memoria
	ld [mascara_BP],%r3
	and %r3,%r1,%r3 !Me fijo si esta presionado el boton BP
	addcc %r3, -1, %r0
	bpos estado_C !si está presionado el boton BP, debo saltar al estado C
	jmpl %r15+4, %r0


ciclosneg .equ -6 ! Esto determina cuantos ciclos internos del timer representan un segundo

contar_tiempo:
	!r16 cuenta la cantidad de ciclos de reloj hasta llegar a 1 segundo

	and %r0, %r0, %r16 !pongo r16 en 0
 
	seguir_sumando:
		add %r16, 1, %r16
		addcc %r16, ciclosneg , %r0 ! considero que ciclosneg es la cantidad de ciclos de reloj que representa 1 segundo
		be paso_un_segundo
		ba seguir_sumando !si llega aca es porque todavia no conto CICLOSNEG ciclos, es decir no llego a 1 segundo

	paso_un_segundo:
		jmpl %r15+4, %r0


.end
