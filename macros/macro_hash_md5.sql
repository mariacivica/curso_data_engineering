--  Macro que genera una clave única (surrogate key, ej: 6doiewnoti564oinsdf4546) a partir de una 
--  lista de nombres de columnas que se pasan como argumento.
--  Se concatenan los valores de esas columnas y luego aplica la función de hash md5 para generar 
--  una clave única (huella digital) que representa esos valores concatenados.
--  

{% macro my_generate_surrogate_key(column_names) %} -- definición de la macro
    md5({% for column_name in column_names %}{{ column_name }}{% if not loop.last %} || {% endif %}{% endfor %}) 
{% endmacro %}
