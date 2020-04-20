# frozen_string_literal: true

require_dependency "keppler_farm/application_controller"
module KepplerFarm
  module Admin
    # GroundsController
    class GroundsController < ::Admin::AdminController
      layout 'keppler_farm/admin/layouts/application'
      before_action :set_ground, only: %i[show edit update destroy]
      before_action :index_variables
      include ObjectQuery

      # GET /farms
      def index
        respond_to_formats(@grounds)
        redirect_to_index(@objects)
      end

      # GET /farms/1
      def show; end

      # GET /farms/new
      def new
        @ground = Ground.new
      end

      # GET /farms/1/edit
      def edit; end

      # POST /farms
      def create
        @ground = Ground.new(ground_params)

        if @ground.save
          redirect(@ground, params)
        else
          render :new
        end
      end

      # PATCH/PUT /farms/1
      def update
        if @ground.update(ground_params)
          redirect(@ground, params)
        else
          render :edit
        end
      end

      def clone
        @ground = Ground.clone_record params[:ground_id]
        @ground.save
        redirect_to_index(@objects)
      end

      # DELETE /farms/1
      def destroy
        @ground.destroy
        redirect_to_index(@objects)
      end

      def destroy_multiple
        Ground.destroy redefine_ids(params[:multiple_ids])
        redirect_to_index(@objects)
      end

      def upload
        Ground.upload(params[:file])
        redirect_to_index(@objects)
      end

      def reload; end

      def sort
        Ground.sorter(params[:row])
      end

      private

      def index_variables
        @q = Ground.ransack(params[:q])
        @grounds = @q.result(distinct: true)
        @objects = @grounds.page(@current_page).order(position: :desc)
        @total = @grounds.size
        @attributes = Ground.index_attributes
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_ground
        @ground = Ground.find_by(id: params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def ground_params
        params.require(:ground).permit(
          :identifier, :name, :location, :total_area, :used_area, :cultivation, :efficiency, :forage_offer, :description, :rest_days, :busy_days, :fecal_effectiveness, :farm_id
        )
      end
    end
  end
end