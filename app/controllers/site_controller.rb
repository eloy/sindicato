class SiteController < ApplicationController
  def index
  end


  def export
    uploaded_io = params[:source_file]
    source_file = File.new File.join( Rails.root, 'tmp', 'uploaded.xls'), 'wb'
    source_file.write uploaded_io.read
    source_file.close

    export_params = params[:export]
    export_params[:precio_en_centimos] = export_params[:precio].gsub(',', '.').to_f * 100
    e = SindicatoExporter.new source_file.path, export_params
    buff = e.generate
    File.delete source_file.path
    send_data buff, type: :text, filename: "suma.txt"
  end
end
