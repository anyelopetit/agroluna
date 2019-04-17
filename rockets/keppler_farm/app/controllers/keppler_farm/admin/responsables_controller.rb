# frozen_string_literal: true

require_dependency "keppler_farm/application_controller"
module KepplerFarm
  module Admin
    # ResponsablesController
    class ResponsablesController < ::Admin::AdminController
      layout 'keppler_farm/admin/layouts/application'
      before_action :set_responsable, only: %i[show edit update destroy]
      before_action :index_variables
      include ObjectQuery

      # GET /farms
      def index
        respond_to_formats(@responsables)
        redirect_to_index(@objects)
      end

      # GET /farms/1
      def show; end

      # GET /farms/new
      def new
        @responsable = Responsable.new
      end

      # GET /farms/1/edit
      def edit; end

      # POST /farms
      def create
        @responsable = Responsable.new(responsable_params)

        if @responsable.save
          redirect(@responsable, params)
        else
          render :new
        end
      end

      # PATCH/PUT /farms/1
      def update
        if @responsable.update(responsable_params)
          redirect(@responsable, params)
        else
          render :edit
        end
      end

      def clone
        @responsable = Responsable.clone_record params[:responsable_id]
        @responsable.save
        redirect_to_index(@objects)
      end

      # DELETE /farms/1
      def destroy
        @responsable.destroy
        redirect_to_index(@objects)
      end

      def destroy_multiple
        Responsable.destroy redefine_ids(params[:multiple_ids])
        redirect_to_index(@objects)
      end

      def upload
        Responsable.upload(params[:file])
        redirect_to_index(@objects)
      end

      def reload; end

      def sort
        Responsable.sorter(params[:row])
      end

      private

      def index_variables
        @q = Responsable.ransack(params[:q])
        @responsables = @q.result(distinct: true)
        @objects = @responsables.page(@current_page).order(position: :desc)
        @total = @responsables.size
        @attributes = Responsable.index_attributes
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_responsable
        @responsable = Responsable.find_by(id: params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def responsable_params
        params.require(:responsable).permit(
          :name
        )
      end
    end
  end
end