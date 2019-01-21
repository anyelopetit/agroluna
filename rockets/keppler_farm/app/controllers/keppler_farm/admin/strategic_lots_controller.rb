# frozen_string_literal: true

require_dependency "keppler_farm/application_controller"
module KepplerFarm
  module Admin
    # StrategicLotsController
    class StrategicLotsController < ::Admin::AdminController
      layout 'keppler_farm/admin/layouts/application'
      before_action :set_strategic_lot, only: %i[show edit update destroy]
      before_action :index_variables
      include ObjectQuery

      # GET /farms
      def index
        respond_to_formats(@strategic_lots)
        redirect_to_index(@objects)
      end

      # GET /farms/1
      def show; end

      # GET /farms/new
      def new
        @strategic_lot = StrategicLot.new
      end

      # GET /farms/1/edit
      def edit; end

      # POST /farms
      def create
        @strategic_lot = StrategicLot.new(strategic_lot_params)

        if @strategic_lot.save
          redirect(@strategic_lot, params)
        else
          render :new
        end
      end

      # PATCH/PUT /farms/1
      def update
        if @strategic_lot.update(strategic_lot_params)
          redirect(@strategic_lot, params)
        else
          render :edit
        end
      end

      def clone
        @strategic_lot = StrategicLot.clone_record params[:strategic_lot_id]
        @strategic_lot.save
        redirect_to_index(@objects)
      end

      # DELETE /farms/1
      def destroy
        @strategic_lot.destroy
        redirect_to_index(@objects)
      end

      def destroy_multiple
        StrategicLot.destroy redefine_ids(params[:multiple_ids])
        redirect_to_index(@objects)
      end

      def upload
        StrategicLot.upload(params[:file])
        redirect_to_index(@objects)
      end

      def reload; end

      def sort
        StrategicLot.sorter(params[:row])
      end

      private

      def index_variables
        @q = StrategicLot.ransack(params[:q])
        @strategic_lots = @q.result(distinct: true)
        @objects = @strategic_lots.page(@current_page).order(position: :desc)
        @total = @strategic_lots.size
        @attributes = StrategicLot.index_attributes
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_strategic_lot
        @strategic_lot = StrategicLot.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def strategic_lot_params
        params.require(:strategic_lot).permit(
          :name, :function, :description, :farm_id
        )
      end
    end
  end
end