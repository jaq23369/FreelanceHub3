FreelanceHub - Base de Datos (Explicación de Versiones)
--------------------------------------------------------
Version 1.0: FreelanceHub3

 Descripción

Este repositorio contiene el script SQL para la creación de la base de datos FreelanceHub, diseñada para gestionar un sistema de contratación de freelancers y emprendedores. La versión 1.0 se enfoca en la estructura fundamental de las tablas y relaciones principales.

Características Principales

Definición de 13 tablas principales.

Uso de FOREIGN KEY para mantener la integridad referencial.

Aplicación de CHECK constraints para validar valores.

Implementación de índices para optimizar las consultas.

Uso de valores por defecto para evitar datos nulos innecesarios.

📁 Estructura de la Base de Datos

La base de datos contiene las siguientes tablas:

1. Tabla Usuario

Guarda la información de los usuarios registrados (freelancers y emprendedores).

Campos: id_usuario, nombre, email, contraseña, tipo_usuario, fecha_registro, telefono.

Restricciones: email es único, tipo_usuario solo acepta freelancer o emprendedor.

2. - 3. Tablas Emprendedor_Maestro y Emprendedor_Detalle

Gestionan la información específica de los emprendedores.

Emprendedor_Maestro: Estado del emprendedor.

Emprendedor_Detalle: Presupuesto, historial de contratos, descripción.

4. - 5. Tablas Freelancer_Maestro y Freelancer_Detalle

Contienen los datos específicos de los freelancers.

Freelancer_Maestro: Estado del freelancer.

Freelancer_Detalle: Habilidades, reputación, certificaciones.

6. - 7. Tablas Proyecto_Maestro y Proyecto_Detalle

Almacenan la información de los proyectos publicados y sus asignaciones.

Proyecto_Maestro: Datos generales del proyecto.

Proyecto_Detalle: Relación entre freelancer y proyecto.

8. Tabla Contrato

Define los contratos entre emprendedores y freelancers.

Estados posibles: pendiente, activo, finalizado, cancelado.

9. - 10. Tablas Pago_Maestro y Pago_Detalle

Gestionan los pagos a los freelancers.

Pago_Maestro: Relacionado con el contrato.

Pago_Detalle: Registra pagos individuales a freelancers.

11. - 12. Tablas Chat y Mensaje

Manejan la comunicación entre usuarios en proyectos.

Chat: Identifica las conversaciones.

Mensaje: Registra mensajes dentro de los chats.

13.  Tabla Notificacion

Guarda alertas de pagos, contratos o mensajes nuevos para los usuarios.

Índices Utilizados

Para mejorar el rendimiento de las consultas, se han creado los siguientes índices:

idx_usuario_email en Usuario.

idx_emprendedor_estado y idx_emprendedor_presupuesto en Emprendedor.

idx_freelancer_estado y idx_freelancer_reputacion en Freelancer.

idx_proyecto_estado y idx_proyecto_presupuesto en Proyecto.

idx_contrato_estado en Contrato.

idx_pago_estado y idx_pago_metodo en Pagos.

idx_chat_fecha en Chat.

idx_notificacion_estado en Notificaciones.

🛠️ Requerimientos

PostgreSQL 13 o superior

Cliente SQL para ejecutar los scripts.

🏆 Próximos Cambios (Versión Mejorada)

-Se agregarán inserts con datos de prueba.

-Mejoras en integridad referencial.

-Nuevos índices de optimización.

------------------------------------------

Versión 2.0: FreelanceHubMejorada

Descripción General
La versión 2.0 incorpora un modelo más normalizado y escalable. Se reorganizan varios campos que antes se almacenaban como texto para pasar a tablas relacionales, haciendo la base de datos más robusta y flexible para futuras extensiones.

Principales Cambios y Mejoras:
1. Separación de Habilidades y Certificaciones
-En la versión anterior, Freelancer_Detalle tenía columnas de texto (habilidades y certificaciones). Ahora se crean tablas dedicadas (Habilidad, Freelancer_Habilidad, Certificacion y Freelancer_Certificacion) para manejar estas relaciones de manera muchos-a-muchos.
-Esto permite agregar, eliminar o modificar habilidades y certificaciones fácilmente sin alterar la estructura.

2. Contrato Más Flexible y Vista de Contrato
-Se ha retirado la columna id_emprendedor de la tabla Contrato. En su lugar, el contrato se vincula únicamente a un id_proyecto, y se usa la tabla Proyecto_Maestro para saber quién es el emprendedor.
-Surge la vista Vista_Contrato, que combina la información de Contrato y Proyecto_Maestro (añadiendo id_emprendedor), simplificando consultas en una sola vista.

3. Tablas Nuevas para Términos y Firmas
-La información de términos se saca de la columna genérica y se maneja en Termino_Contrato, permitiendo multiplicidad de términos por contrato.
-Firma_Contrato registra qué usuarios (pueden ser emprendedor, freelancer u otro) han firmado, junto con la fecha de firma.

4. Pagos Normalizados
-El Pago_Maestro ahora requiere un monto_total > 0 y soporta tres estados: pendiente, completado, cancelado.
-Pago_Detalle emplea una clave primaria compuesta (id_pago, id_freelancer) y permite distribuir pagos parciales a varios freelancers si fuese necesario.

5. Proyectos Más Desglozados
-Se crea Requisito_Proyecto para registrar cada requisito de forma separada (en lugar de un solo campo de texto en Proyecto_Maestro).
-Se agrega una restricción de unicidad en Proyecto_Detalle (no se puede asignar el mismo freelancer dos veces al mismo proyecto).

6. Más CHECKs y Estados
-Se amplían opciones de estado (por ejemplo, cancelado en pagos y contratos).
-Nuevos checks para valores válidos en nivel de habilidad, fecha_emision en certificaciones, etc.

Estructura de la Base de Datos (2.0)
La base pasa a tener 20 tablas (frente a 13 de la versión previa). Además de las tablas originales, se suman:

-Habilidad, Freelancer_Habilidad
-Certificacion, Freelancer_Certificacion
-Requisito_Proyecto
-Termino_Contrato, Firma_Contrato
-Inserción de Datos de Prueba

En el informe se incluyen capturas de los scripts que insertan datos ficticios (generalmente 10 filas por tabla, con 20 en Usuario para cubrir 10 emprendedores y 10 freelancers). Estos inserts facilitan la prueba rápida del modelo y validan la integridad referencial.

Ventajas Frente a Versión 1.0

-Mayor Consistencia: evita guardar listas de “habilidades” o “certificaciones” en campos de texto, rompiendo la dependencia de estructuras no normalizadas.
-Extensibilidad: es más sencillo añadir nuevas habilidades, certificados o estados de contratos sin reformar campos existentes.
-Consultas Más Detalladas: gracias a las tablas específicas, es fácil filtrar, contar o enlazar información sin duplicaciones.

