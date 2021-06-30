CREATE TABLE PAIS(  --FALTA DETALLE
    id_pai NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
    bandera_pai BLOB DEFAULT EMPTY_BLOB(),
    nombre_pai varchar(25) NOT NULL,
    continente_pai varchar(3) NOT NULL,
    meta_vac_pai NUMBER NOT NULL,
    covax_pai CHAR NOT NULL,
    tasa_repro_pai NUMBER NOT NULL,
    riqueza_pai NUMBER NOT NULL,
    CONSTRAINT continentes
        CHECK (continente_pai IN ('AME','EUR','OCE','ASI','AFR')), -- AMERICA / EUROPA / OCEANIA / ASIA / AFRICA
    CONSTRAINT bool_covax
        CHECK (covax_pai IN ('Y', 'N')), --SI/NO
    CONSTRAINT limites_riqueza
        CHECK (riqueza_pai >= 1 AND riqueza_pai <= 5)  -- 1 "+POBRE"/ 5 "+RICO"
);

CREATE TABLE GRUPO_ETARIO(
    id_ge NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
    nombre_ge VARCHAR2(50) NOT NULL,
    edad_inferior NUMBER NOT NULL,
    edad_superior NUMBER,
    mortalidad NUMBER NOT NULL
);

CREATE TABLE PAIS_GE(
    cant_hab_pge HABITANTES NOT NULL,
    grupo_etario_pge NUMBER NOT NULL,
    pais_pge NUMBER NOT NULL,
    
    CONSTRAINT fk_ge
        FOREIGN KEY (grupo_etario_pge)
        REFERENCES GRUPO_ETARIO(id_ge),
    CONSTRAINT fk_pais_pge
        FOREIGN KEY (pais_pge)
        REFERENCES PAIS(id_pai),
    CONSTRAINT pk_pais_ge
        PRIMARY KEY (grupo_etario_pge, pais_pge)
);

CREATE TABLE H_HABITANTES(
    fecha_h DATE NOT NULL,
    pais_h NUMBER NOT NULL,
    grupo_etario_h NUMBER NOT NULL,
    hab HABITANTES NOT NULL,

    CONSTRAINT fk_pais_ge_h_hab
        FOREIGN KEY (pais_h,grupo_etario_h)
        REFERENCES PAIS_GE(pais_pge,grupo_etario_pge),
    CONSTRAINT pk_h_habitantes
        PRIMARY KEY (fecha_h,pais_h,grupo_etario_h)
);

CREATE TABLE ESTATUS(
    id_est NUMBER GENERATED BY DEFAULT AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
    nombre_est VARCHAR2(15) NOT NULL,
    descripcion_est VARCHAR(250)
);

CREATE TABLE VACUNA( 
    id_vac NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
    nombre_vac VARCHAR2(15) NOT NULL,
    estatus_vac NUMBER NOT NULL,
    efectividad_vac NUMBER,
    dosis_vac NUMBER NOT NULL,
    covax_vac CHAR NOT NULL,
    temperatura_vac NUMBER NOT NULL,
    instrucciones_vac VARCHAR2(250) NOT NULL,
    suministro_vac NUMBER NOT NULL,
    fechas_vac F_FASES NOT NULL,
    CONSTRAINT fk_estatus
        FOREIGN KEY (estatus_vac)
        REFERENCES ESTATUS(id_est),
    CONSTRAINT bool_covax_vac
        CHECK (covax_vac IN ('Y', 'N'))

);

CREATE TABLE RESTRICCIONES(
    pais_res NUMBER NOT NULL,
    vacuna_res NUMBER NOT NULL,   
    tipo_res VARCHAR2(10) NOT NULL,
    descripcion_res VARCHAR2(250),
    CONSTRAINT fk_pais_res
        FOREIGN KEY (pais_res)
        REFERENCES PAIS(id_pai),
    CONSTRAINT fk_vacuna_res
        FOREIGN KEY (vacuna_res)
        REFERENCES VACUNA(id_vac),
    CONSTRAINT pk_restricciones
        PRIMARY KEY (pais_res,vacuna_res),
    CONSTRAINT check_tipo_res
        CHECK (tipo_res IN ('Restringida','Parcialmente_restringida'))
);

CREATE TABLE CENTRO_VAC(
    id_cen NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
    nombre_cen VARCHAR2(50) NOT NULL,
    capacidad_cen NUMBER NOT NULL,
    pais_cv NUMBER NOT NULL,
    ubicacion UBICACION NOT NULL,
    CONSTRAINT fk_pais_cv
        FOREIGN KEY (pais_cv)
        REFERENCES PAIS(id_pai)
);

CREATE TABLE INVENTARIO_VAC(
    centro_vac_inv NUMBER NOT NULL,
    vacuna_inv NUMBER NOT NULL,
    cantidad_pri_inv NUMBER NOT NULL,
    cantidad_seg_inv NUMBER,
    CONSTRAINT fk_centro_vac_inv_vac
        FOREIGN KEY (centro_vac_inv)
        REFERENCES CENTRO_VAC(id_cen),
    CONSTRAINT fk_vacuna_inv_vac
        FOREIGN KEY (vacuna_inv)
        REFERENCES VACUNA(id_vac),
    CONSTRAINT pk_inv_vac
        PRIMARY KEY (centro_vac_inv,vacuna_inv)
);

CREATE TABLE SUMINISTROS(
    fecha_sum DATE NOT NULL,
    centro_vac_sum NUMBER NOT NULL,   
    cant_jeringas_sum NUMBER NOT NULL,
    cant_par_guantes_sum NUMBER NOT NULL,
    cant_alcohol_sum NUMBER NOT NULL,
    cant_algodon_sum NUMBER NOT NULL,
    CONSTRAINT fk_centro_vac_sum
        FOREIGN KEY (centro_vac_sum)
        REFERENCES CENTRO_VAC(id_cen),
    CONSTRAINT pk_sum
        PRIMARY KEY (fecha_sum,centro_vac_sum)
);

CREATE TABLE JORNADA_VAC(
    fecha_jv DATE NOT NULL,
    cantidad_pri_jv NUMBER NOT NULL,
    cantidad_seg_jv NUMBER,
    centro_vac_jv NUMBER NOT NULL,
    vacuna_jv NUMBER NOT NULL,
    pais_jv NUMBER NOT NULL,
    grupo_etario_jv NUMBER NOT NULL,
    CONSTRAINT fk_centro_vac_jv
        FOREIGN KEY (centro_vac_jv)
        REFERENCES CENTRO_VAC(id_cen),
    CONSTRAINT fk_vac_jv
        FOREIGN KEY (vacuna_jv)
        REFERENCES VACUNA(id_vac),
    CONSTRAINT fk_pais_ge_jv
        FOREIGN KEY (grupo_etario_jv,pais_jv)
        REFERENCES PAIS_GE(grupo_etario_pge, pais_pge),
    CONSTRAINT pk_jv
        PRIMARY KEY (fecha_jv,pais_jv,grupo_etario_jv,centro_vac_jv,vacuna_jv)
);

CREATE TABLE EFECTO_SECUNDARIO(
    id_efe NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
    nombre_efe VARCHAR2(20) NOT NULL,
    descripcion_efe VARCHAR2(250),
    probabilidad_efe NUMBER
);

CREATE TABLE JV_EFEC(
    cantidad_efsec_jv NUMBER NOT NULL,
    vacuna_jve NUMBER NOT NULL,
    centro_vac_jve NUMBER NOT NULL,
    fecha_jve DATE NOT NULL,
    pais_jve NUMBER NOT NULL,
    grupo_etario_jve NUMBER NOT NULL,
    efecto_secundario_jve NUMBER NOT NULL,
    CONSTRAINT fk_jornada_jve
        FOREIGN KEY (fecha_jve,pais_jve,grupo_etario_jve,centro_vac_jve,vacuna_jve)
        REFERENCES  JORNADA_VAC(fecha_jv,pais_jv,grupo_etario_jv,centro_vac_jv,vacuna_jv),
    CONSTRAINT fk_efecto_jve
        FOREIGN KEY (efecto_secundario_jve)
        REFERENCES EFECTO_SECUNDARIO(id_efe)
);

CREATE TABLE VAC_EFEC(
    efecto_secundario_ve NUMBER NOT NULL,
    vacuna_ve NUMBER NOT NULL,
    CONSTRAINT fk_efecto_ve
        FOREIGN KEY (efecto_secundario_ve)
        REFERENCES EFECTO_SECUNDARIO(id_efe),
    CONSTRAINT fk_vacuna_ve
        FOREIGN KEY (vacuna_ve)
        REFERENCES VACUNA(id_vac)
);

CREATE TABLE EVENTOS_ALEATORIOS(
    id_eve NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
    nombre_eve VARCHAR2(50) NOT NULL,
    tipo_eve VARCHAR2(12) NOT NULL,
    descripcion_eve VARCHAR2(250) NOT NULL,
    efecto_eve VARCHAR2(20),
    probabilidad_eve NUMBER NOT NULL,
    habilitado_eve CHAR NOT NULL,
    rango_efecto_eve NUMBER,
    direc_eve CHAR,
    fecha_ocurrencia_eve DATE,
    pais_eve NUMBER,
    CONSTRAINT fk_pais_eventos_aleatorios
        FOREIGN KEY (pais_eve)
        REFERENCES PAIS(id_pai),
    CONSTRAINT direc_evento_aleatorio
        CHECK (direc_eve IN ('S', 'B')), --subir/bajar
    CONSTRAINT tipo_evento_aleatorio
        CHECK (tipo_eve IN ('MORTALIDAD','TAZA_REPRO','CAMBIO_FECHA','CUARENTENA')),
    CONSTRAINT habilitado_evento_aleatorio_bool
        CHECK (habilitado_eve IN ('Y','N'))
);

CREATE TABLE DISTRIBUIDORA(
    id_dist  NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
    nombre_dist VARCHAR2(25) NOT NULL
);

CREATE TABLE VACUNA_DISTRIBUIDORA(
    vacuna_vd NUMBER NOT NULL,
    distribuidora_vd NUMBER NOT NULL,
    cantidad_vd NUMBER NOT NULL,
    CONSTRAINT fk_vd_vacuna
        FOREIGN KEY (vacuna_vd)
        REFERENCES VACUNA(id_vac),
    CONSTRAINT fk_vd_distribuidora
        FOREIGN KEY (distribuidora_vd)
        REFERENCES DISTRIBUIDORA(id_dist),
    CONSTRAINT pk_vac_dist
        PRIMARY KEY (vacuna_vd,distribuidora_vd)
);

CREATE TABLE ORDEN(
    id_ord  NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
    pais_ord NUMBER NOT NULL,
    distribuidora_ord NUMBER NOT NULL,
    monto_ord NUMBER NOT NULL,
    estatus_ord VARCHAR2(25) NOT NULL, --espera, demorada, entregada, en transito, preparada para despacho, pago pendiente
    f_realizacion_ord DATE NOT NULL,
    f_estimada_ord DATE NOT NULL,
    f_entrega_ord DATE,
    CONSTRAINT fk_distribuidora_orden
        FOREIGN KEY (distribuidora_ord)
        REFERENCES DISTRIBUIDORA(id_dist),
    CONSTRAINT fk_pais_orden
        FOREIGN KEY (pais_ord)
        REFERENCES PAIS(id_pai),
    CONSTRAINT estatus_ordenes
        CHECK (estatus_ord IN ('EN ESPERA', 'DEMORADA','ENTREGADA','EN TRANSITO','PREPARADA PARA DESPACHO','PAGO PENDIENTE'))
);

CREATE TABLE PAGO(
    id_pag  NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
    fecha_pag DATE NOT NULL,
    monto_pag NUMBER NOT NULL,
    n_orden_pag NUMBER NOT NULL,
    CONSTRAINT fk_pago_n_orden
        FOREIGN KEY (n_orden_pag)
        REFERENCES ORDEN(id_ord)
);

CREATE TABLE DISTRIBUCION(
    cantidad_dis NUMBER NOT NULL,
    n_orden_dis NUMBER NOT NULL,
    vacuna_dis NUMBER NOT NULL,
    CONSTRAINT fk_numero_orden
        FOREIGN KEY (n_orden_dis)
        REFERENCES ORDEN(id_ord),
    CONSTRAINT fk_vacuna_distribucion
        FOREIGN KEY (vacuna_dis)
        REFERENCES VACUNA(id_vac),
    CONSTRAINT pk_vac_dis
        PRIMARY KEY (vacuna_dis,n_orden_dis)
);
