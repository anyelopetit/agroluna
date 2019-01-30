require 'rails/generators/rails/resource/resource_generator'
require 'rails/generators/resource_helpers'
module Rails
  module Generators
    # KepplerRelation
    class KepplerRelationGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)
      # Modify models (add has_many and belongs_to relation)
      def modify_models
        inject_into_file(
          "app/models/#{name}.rb",
          "\n  has_many :#{args[0].pluralize}, :dependent => :delete_all",
          after: 'include CloneRecord'
        )
        inject_into_file(
          "app/models/#{args[0]}.rb",
          "\n  belongs_to :#{name}",
          after: 'include CloneRecord'
        )
      end

      # Delete the son module from the sidemenu
      def add_submenu
        gsub_file 'config/menu.yml', sub_menu_deleted(args[0]), "  ##{args[0].camelcase} deleted"
      end

      # Nest routes father_module/son_module and delete the routes generated by the keppler_scaffold command
      def nest_routes
        gsub_file 'config/routes.rb', commented_route(args[0]), '    #Route deleted'
        inject_into_file(
          "config/routes.rb",
          str_route(args[0]),
          after:"    resources :#{name.pluralize} do\n      get '(page/:page)', action: :index, on: :collection, as: ''\n      get '/clone', action: 'clone'\n      delete(\n        action: :destroy_multiple,\n        on: :collection,\n        as: :destroy_multiple\n      )\n"
        )
      end

      # Modify the paths of the view of the son module
      def modify_views_path
        ["_listing", "index", "_form", "show"].each do |view|
          singular_path(name,args[0],view)
          if view == '_listing'
            clone_path(name,args[0],view)
            inject_listing(name, args[0], view)
          end
          inject_variable(name, args[0], view)
        end
      end



      # Add the method in the son controller to find the father :id
      def add_controller_flag
        inject_into_file(
          "app/controllers/admin/#{args[0].pluralize}_controller.rb",
          str_ctrl_method(name,args[0]),
          after: "    private"
        )
      end

      # Add the callback in the son's controller
      def add_callback
        inject_into_file(
          "app/controllers/admin/#{args[0].pluralize}_controller.rb",
          str_callback_ctrl(name),
          after: "    before_action :show_history, only: [:index]"
        )
      end

      # Inject the variables in the simple_form_for of the form partial
      def inject_var_form
        inject_into_file(
          "app/views/admin/#{args[0].pluralize}/_form.html.haml",
          "@#{name}_#{args[0]}, ",
          before: "@#{args[0]}]"
        )
      end

      # Include the button in the father_module _listing
      def nested_button
        inject_into_file(
          "app/views/admin/#{name.pluralize}/_listing.html.haml",
          str_btn(name, args[0]),
          # before: str_last_button(name)
          after: '				.icons.right'
        )
      end

      # Insert params in son's controller within new method
      def new_params
        inject_into_file(
          "app/controllers/admin/#{args[0].pluralize}_controller.rb",
          "(#{name.underscore}_id: params[:#{name.underscore}_id])",
          after: "    def new\n      @#{args[0]} = #{args[0].camelcase}.new"
        )

      end

      # Replace the paths in module_son controller
      def controller_paths
        gsub_file(
          "app/controllers/admin/#{args[0].pluralize}_controller.rb",
          "admin_#{args[0].pluralize}_path",
          "admin_#{name.underscore}_#{args[0].pluralize}_path"
        )
        gsub_file(
          "app/controllers/admin/#{args[0].pluralize}_controller.rb",
          "redirect(@#{args[0].underscore}, params)",
          redirect_path(name, args[0])
        )
      end

      # Replace 'params[:q] to (@category_shop) and add .where to  filter the index of son_module'
      def index_controller
        gsub_file(
          "app/controllers/admin/#{args[0].pluralize}_controller.rb",
          'params[:q]',
          "@#{name.underscore}_#{args[0].underscore}"
        )
        inject_into_file(
          "app/controllers/admin/#{args[0].pluralize}_controller.rb",
          ".where(#{name}_id: @#{name.underscore}_#{args[0].underscore})",
          after: "#{args[0].pluralize} = @q.result(distinct: true)"
        )
      end

      def return_btn
        inject_into_file(
          "app/views/admin/#{args[0].underscore.pluralize}/index.html.haml",
          "\n\t= link_to admin_#{name.underscore.pluralize}_path, class: 'btn-floating btn-flat' do\n\t\t-# = material_icon.md_18.arrow_back.css_class('md-dark')",
          after: '= entries(@total, @objects)'
        )
      end

      private

      # String to delete the menu.yml menu (son_module)
      def sub_menu_deleted(son)
        "  #{son}:\n    name: #{son.split('_').join(" ").pluralize}\n    url_path: /admin/#{son.pluralize}\n    icon: code\n    current: ['admin/#{son.pluralize}']\n    model: #{son.camelcase}"
      end

      #
      def redirect_path(father,son)
        "if params.key?('_add_other')\n          redirect_to new_admin_#{father.underscore}_#{son.underscore}_path, notice: actions_messages(@#{son})\n        else\n          redirect_to admin_#{father.underscore}_#{son.pluralize}_path\n        end"
      end

      def singular_path(father,son,file)
        inject_into_file(
          "app/views/admin/#{son.pluralize}/#{file}.html.haml",
          "_#{father.underscore}",
          before: "_#{son}"
        )
      end

      def clone_path(father,son,file)
        inject_into_file(
          "app/views/admin/#{son.pluralize}/#{file}.html.haml",
          "_#{father.underscore}",
          before: "_#{son}_clone_path"
        )
      end

      # String to know what route comment (son_module)
      def commented_route(path)
        "    resources :#{path.pluralize(2)} do\n      get '(page/:page)', action: :index, on: :collection, as: ''\n      get '/clone', action: 'clone'\n      delete(\n        action: :destroy_multiple,\n        on: :collection,\n        as: :destroy_multiple\n      )\n    end\n"
      end

      # String of new route to nest (son_module)
      def str_route(path)
        "      resources :#{path.pluralize(2)} do\n        get '(page/:page)', action: :index, on: :collection, as: ''\n        get '/clone', action: 'clone'\n        delete(\n          action: :destroy_multiple,\n          on: :collection,\n          as: :destroy_multiple\n        )\n      end\n"
      end

      # string of private method to add within the son_module controller
      def str_ctrl_method(father, son)
        "\n\n    def set_#{father}\n      @#{father}_#{son} = #{father.camelcase}.find_by(id: params[:#{father.underscore}_id])\n    end\n"
      end

      # String of the callback to add within the son_module controller
      def str_callback_ctrl(father)
        "\n    before_action :set_#{father.underscore}\n"
      end

      # Add variables to path of son_module views
      def inject_variable(father, son, file)
        if file.eql?("_form")
          inject_into_file(
            "app/views/admin/#{args[0].pluralize}/#{file}.html.haml",
            "(@#{father.underscore}_#{son.underscore}, @#{son.underscore})",
            after: "admin_#{father.underscore}_#{son.underscore}_path"
          )
        end
        inject_into_file(
          "app/views/admin/#{args[0].pluralize}/#{file}.html.haml",
          "@#{father.underscore}_#{son.underscore}, ",
          before: "@#{son.underscore})"
        )
      end

      # Inject variable to _listing view of son_module
      def inject_listing(father, son, file)
        inject_into_file(
          "app/views/admin/#{args[0].pluralize}/_listing.html.haml",
          "@#{father.underscore}_#{son.underscore},",
          after: "_path("
        )
      end


      # References to add nest button in father_module's listing
      def str_last_button(father)
        " - if can?(#{father.camelcase}).show?"
      end

      #String of the button to add in father_module's listing
      def str_btn(father, son)
        "\n					%li.center\n						= link_to admin_#{father}_#{son.pluralize}_path(#{father}), class: 'btn-floating waves-effect btn-flat tooltipped', title: t('keppler.sidebar-menu.#{son.pluralize}') do\n							-# = material_icon.md_24.add_circle_outline.css_class('md-dark')\n"
      end
    end
  end
end
