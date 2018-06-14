# -*- coding: utf-8 -*-
class SindicatoExporter

  def initialize(source_file, opt={ })
    @source_file = source_file
    @opt = opt
    define_fields
  end

  def define_fields
    field name: :tipo_de_cargo, length: 1, value: 'V'
    field name: :ano_de_cargo, length: 4
    field name: :c_codigo_provincia, length: 2, value: '03'
    field name: :c_codigo_municipio, length: 3, value: '247'
    field name: :codigo_concepto_cargo, length: 2, value: 'D1'
    field name: :emision_del_cargo, length: 2, value: '01'
    field name: :codigo_organismo, length: 1, value: 'C'
    field name: :tipo_valor, length: 1, value: 'R'
    field name: :n_numerovalor, length: 6, type: :number do
      @sec
    end
    field name: :referencia_interna_organismo_emisor, length: 15 do
      ENV['REFERENCIA_INTERNA']
    end
    field name: :tipo_sujeto_pasivo, length: 1
    field name: :nombre_sujeto_pasivo, length: 60
    field name: :tipo_direccion_sujeto_pasivo, length: 2, value: '04'
    field name: :tipo_de_calle, length: 2
    field name: :nombre_de_calle, length: 20
    field name: :numero, length: 5 do |row|
      if row[:numero].is_a? Float
        row[:numero].to_i
      else
        row[:numero]
      end
    end
    field name: :descripcion, length: 7
    field name: :f_cpostal, length: 3 do |row|
      postal = row[:codigo_postal]
      if postal.is_a? String
        postal.slice 2..-1
      else
        # To int, to string and get the 3 last digits, silly.
        postal.to_i.to_s.slice(-3..-1)
      end

    end
    field name: :codigo_municipio, length: 3
    field name: :codigo_provincia, length: 2
    field name: :filler, length: 19, value: ''
    field name: :f_importe, length: 10, type: :number do |row|
      tahullas = row[:total_tahullas].to_f
      total = opt[:precio_en_centimos] * tahullas
      opt[:total_en_centimos] = total.to_i
    end

    field name: :identificador_fiscal_sujeto_pasivo, length: 10
    field name: :tipo_formato_valor, length: 1, value: '3'
    field name: :objeto_tributario, length: 40 do |row|
      "#{row[:total_tahullas]} tah."
    end
    field name: :id_regante, length: 12, type: :number do |row|
      row[:id_regante]
    end
    field name: :ano_ejercicio, length: 4
    field name: :periocidad, length: 1, value: 'A'
    field name: :filler2, length: 4, value: ''
    field name: :descripcion_1, length: 75 do |row|
      precio_tahulla =  '%.2f' % (opt[:precio_en_centimos].to_f / 100)
      "Concepto: #{row[:total_tahullas]} tahullas, a razon de #{precio_tahulla} euros por tahulla."
    end

    field name: :descripcion_2, length: 77 do |row|
      parcelas_str = row[:parcelas].gsub(' ', '').chomp
      if parcelas_str.present?
        "POLÍG/PARC: #{parcelas_str}"
      else
        ""
      end
    end

    field name: :detalle_2, length: 73 do |row|
      opt[:detalle_2]
    end
  end

  def debug_fields
    current = 0;
    fields.each do |f|
      puts "#{f[:name]}\t\t\t\t\t\t\t#{current}:#{current + f[:length]}"
      current += f[:length]
    end
  end

  COLUMNS = [:numero_valor, :nombre_sujeto_pasivo, :tipo_de_calle,
    :nombre_de_calle, :numero, :descripcion,
    :codigo_postal, :codigo_municipio, :municipio,
    :codigo_provincia, :provincia,
    :identificador_fiscal_sujeto_pasivo, :desc_1, :desc_2,
    :total_tahullas, :id_regante, :parcelas, :desc_5,
    :tipo_sujeto_pasivo]


  def generate
    buff = []
    data = read_file
    @sec = 0
    data.each do | d|
      @sec += 1
      l = ""
      fields.each do |f|
        # If has value, use ir
        if f[:value].present?
          if f[:value].is_a? String
            value = f[:value] || ""
          else
            value = f[:value].call(d)
          end


        elsif @opt[f[:name]].present?
          # Look at paramams
          value = @opt[f[:name]]
        elsif d[f[:name]].present?
          # Look at data
          value = d[f[:name]]
        else
          value = ""
        end


        if f[:type] == :number
          value = value.to_s.rjust(f[:length], '0')
        else
          value = value.to_s
          value = value.slice(0, f[:length])
          value = value.to_s.ljust(f[:length])
        end

        l << value
      end


      buff << l.encode('ISO-8859-15')
    end
    output = buff.join "\n"
  end

  def opt
    @opt
  end

  private

  def read_file
    s = Roo::Excel.new(@source_file)
    @data = []
    first = s.first_row + 1
    (first..s.last_row).each do |row|
      l = {}
      COLUMNS.each_with_index do |key, col|
        l[key] = s.cell(row, (col + 1)) || ''
      end
      @data << l
    end
    return @data
  end

  def fields
    @fields ||= []
  end

  def field(field_description, &block)
    field_description[:value] = block if block
    fields << field_description
  end

end
