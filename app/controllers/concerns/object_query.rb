# frozen_string_literal: true

# ObjectQuery
module ObjectQuery
  extend ActiveSupport::Concern

  private

  def redirect_to_index(objects)
    return if listing? && (!objects.size.zero? || objects.first_page?)
    redirect_to(
      {
        action: :index,
        page: (@current_page.to_i if params[:page]),
        search: @query
      },
      notice: actions_messages(model.new)
    )
  end

  def send_format_data(objects, extension)
    models = objects.model.to_s.downcase.pluralize
    t_models = t("keppler.models.pluralize.#{models}").humanize
    filename = "#{t_models} - #{I18n.l(Time.now, format: :short)}"
    objects_array = objects.order(:created_at)
    case extension
    when 'csv'
      send_data objects_array.to_csv, filename: "#{filename}.csv"
    when 'xls'
      send_data objects_array.to_a.to_xls, filename: "#{filename}.xls"
    end
  end

  def respond_to_formats(objects)
    respond_to do |format|
      format.html
      format.csv { send_format_data(objects.model.all, 'csv') }
      format.xls { send_format_data(objects.model.all, 'xls') }
      format.json { render json: json_objects(objects) }
      format.pdf do
        render pdf_options
      end
    end
  end

  protected

  def json_objects(objects)
    # if request.url.include?('page')
    objects.page(@current_page).order(position: :desc)
    # else
    #   objects.class.all
    # end
  end

  def pdf_options
    {
      pdf: 'file_name',
      # disposition:                    'attachment',                 # default 'inline'
      # template:                       'things/show',
      # file:                           "#{Rails.root}/files/foo.erb"
      # layout:                         'pdf',                        # for a pdf.pdf.erb file
      # wkhtmltopdf:                    '/usr/local/bin/wkhtmltopdf', # path to binary
      # show_as_html:                   params.key?('debug'),         # allow debugging based on url param
      # orientation:                    'Landscape',                  # default Portrait
      # page_size:                      'A4, Letter, ...',            # default A4
      # page_height:                    NUMBER,
      # page_width:                     NUMBER,
      # save_to_file:                   Rails.root.join('pdfs', "#{filename}.pdf"),
      # save_only:                      false,                        # depends on :save_to_file being set first
      # default_protocol:               'http',
      # proxy:                          'TEXT',
      # basic_auth:                     false                         # when true username & password are automatically sent from session
      # username:                       'TEXT',
      # password:                       'TEXT',
      # title:                          'Alternate Title',            # otherwise first page title is used
      # cover:                          'URL, Pathname, or raw HTML string',
      # dpi:                            'dpi',
      # encoding:                       'TEXT',
      # user_style_sheet:               'URL',
      # cookie:                         ['_session_id SESSION_ID'], # could be an array or a single string in a 'name value' format
      # post:                           ['query QUERY_PARAM'],      # could be an array or a single string in a 'name value' format
      # redirect_delay:                 NUMBER,
      # javascript_delay:               NUMBER,
      # window_status:                  'TEXT',                     # wait to render until some JS sets window.status to the given string
      # image_quality:                  NUMBER,
      # no_pdf_compression:             true,
      # zoom:                           FLOAT,
      # page_offset:                    NUMBER,
      # book:                           true,
      # default_header:                 true,
      # disable_javascript:             false,
      # grayscale:                      true,
      # lowquality:                     true,
      # enable_plugins:                 true,
      # disable_internal_links:         true,
      # disable_external_links:         true,
      # print_media_type:               true,
      # disable_smart_shrinking:        true,
      # use_xserver:                    true,
      # background:                     false,                     # background needs to be true to enable background colors to render
      # no_background:                  true,
      # viewport_size:                  'TEXT',                    # available only with use_xserver or patched QT
      # extra:                          '',                        # directly inserted into the command to wkhtmltopdf
      # raise_on_all_errors:            nil,                       # raise error for any stderr output.  Such as missing media, image assets
      # outline: {   outline:           true,
      #             outline_depth:     LEVEL },
      margin:  {
        top:               5,                     # default 10 (mm)
        bottom:            5,
        left:              5,
        right:             5 
      },
      # header:  {   html: {            template: 'users/header',          # use :template OR :url
      #                                 layout:   'pdf_plain',             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
      #                                 url:      'www.example.com',
      #                                 locals:   { foo: @bar }},
      #             center:            'TEXT',
      #             font_name:         'NAME',
      #             font_size:         SIZE,
      #             left:              'TEXT',
      #             right:             'TEXT',
      #             spacing:           REAL,
      #             line:              true,
      #             content:           'HTML CONTENT ALREADY RENDERED'}, # optionally you can pass plain html already rendered (useful if using pdf_from_string)
      # footer:  {   html: {   template:'shared/footer',         # use :template OR :url
      #                       layout:  'pdf_plain.html',        # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
      #                       url:     'www.example.com',
      #                       locals:  { foo: @bar }},
      #             center:            'TEXT',
      #             font_name:         'NAME',
      #             font_size:         SIZE,
      #             left:              'TEXT',
      #             right:             'TEXT',
      #             spacing:           REAL,
      #             line:              true,
      #             content:           'HTML CONTENT ALREADY RENDERED'}, # optionally you can pass plain html already rendered (useful if using pdf_from_string)
      # toc:     {   font_name:         "NAME",
      #             depth:             LEVEL,
      #             header_text:       "TEXT",
      #             header_fs:         SIZE,
      #             text_size_shrink:  0.8,
      #             l1_font_size:      SIZE,
      #             l2_font_size:      SIZE,
      #             l3_font_size:      SIZE,
      #             l4_font_size:      SIZE,
      #             l5_font_size:      SIZE,
      #             l6_font_size:      SIZE,
      #             l7_font_size:      SIZE,
      #             level_indentation: NUM,
      #             l1_indentation:    NUM,
      #             l2_indentation:    NUM,
      #             l3_indentation:    NUM,
      #             l4_indentation:    NUM,
      #             l5_indentation:    NUM,
      #             l6_indentation:    NUM,
      #             l7_indentation:    NUM,
      #             no_dots:           true,
      #             disable_dotted_lines:  true,
      #             disable_links:     true,
      #             disable_toc_links: true,
      #             disable_back_links:true,
      #             xsl_style_sheet:   'file.xsl'} # optional XSLT stylesheet to use for styling table of contents
    }
  end
end
