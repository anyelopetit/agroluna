# frozen_string_literal: true

require_dependency "keppler_farm/application_controller"
module KepplerFarm
  module Admin
    # FarmsController
    class FarmsController < ::Admin::AdminController
      layout 'keppler_farm/admin/layouts/application'
      before_action :set_farm, only: %i[show edit update destroy]
      before_action :index_variables
      include ObjectQuery

      # GET /farms
      def index
        respond_to_formats(@farms)
        redirect_to_index(@objects)
      end

      # GET /farms/1
      def show; end

      # GET /farms/new
      def new
        @farm = Farm.new
      end

      # GET /farms/1/edit
      def edit; end

      # POST /farms
      def create
        @farm = Farm.new(farm_params)

        if @farm.save
          redirect(@farm, params)
        else
          render :new
        end
      end

      # PATCH/PUT /farms/1
      def update
        if @farm.update(farm_params)
          redirect(@farm, params)
        else
          render :edit
        end
      end

      def clone
        @farm = Farm.clone_record params[:farm_id]
        @farm.save
        redirect_to_index(@objects)
      end

      # DELETE /farms/1
      def destroy
        @farm.destroy
        redirect_to_index(@objects)
      end

      def destroy_multiple
        Farm.destroy redefine_ids(params[:multiple_ids])
        redirect_to_index(@objects)
      end

      def upload
        Farm.upload(params[:file])
        redirect_to_index(@objects)
      end

      def reload; end

      def sort
        Farm.sorter(params[:row])
      end

      private

      def index_variables
        @q = Farm.ransack(params[:q])
        @farms = @q.result(distinct: true)
        @objects = @farms.page(@current_page).order(position: :desc)
        @total = @farms.size
        @attributes = Farm.index_attributes
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_farm
        @farm = Farm.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def farm_params
        params.require(:farm).permit(
          :logo, :title, :description, :processes
        )
      end
    end
  end
end