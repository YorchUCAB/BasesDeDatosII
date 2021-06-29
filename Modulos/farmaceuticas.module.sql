CREATE OR REPLACE PROCEDURE farmaceuticas(fecha_actual DATE) IS
    
    
    DECLARE
        VACUNAS CURSOR;
        REGISTRO_VAC VACUNA%ROWTYPE;
        covax BOOLEAN := covax_existe;
BEGIN
    VACUNAS := get_vacunas;
    OPEN VACUNAS;
    FETCH VACUNAS INTO REGISTRO_VAC;
    WHILE VACUNAS%FOUND
        LOOP 
            if ((rango_fecha(fecha_actual, REGISTRO_VAC.fechas_vac.fecha_f2)) AND (REGISTRO_VAC.covax_vac = 'Y') AND (NOT(covax))) THEN
                EXECUTE creacion_covax;
                covax := TRUE;
                DBMS_OUTPUT.PUT_LINE('El ' || REGISTRO_VAC.fechas_vac.fecha_f2 || ' la vacuna ' || REGISTRO_VAC.nombre_vac || 'es la primera en entrar en fase 2.');
                  
            else if (rango_fecha(fecha_actual, REGISTRO_VAC.fechas_vac.fecha_f4)) THEN
                    if (REGISTRO_VAC.covax_vac = 'Y') THEN
                        EXECUTE asignacion_vacunas_covax(REGISTRO_VAC.id_vac);    --asigna 30% a COVAX y el 70% restante se lo queda el laboratorio creador. 
                    end if;
                    DBMS_OUTPUT.PUT_LINE('El ' || REGISTRO_VAC.fechas_vac.fecha_f2 || ' la vacuna' || REGISTRO_VAC.nombre_vac || ' entro en fase 4.');
                end if;
            end if;`
        END LOOP;
    CLOSE VACUNAS;  
END;