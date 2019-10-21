# frozen_string_literal: true

require_dependency "keppler_cattle/application_controller"
module KepplerCattle
  module Admin
    # InventoryCowsController
    class InventoryCowsController < ::Admin::AdminController
      layout 'keppler_cattle/admin/layouts/application'
      before_action :set_inventory_cow, only: %i[show edit update destroy]
      before_action :index_variables
      include ObjectQuery

      # GET /cattles
      def index
        respond_to_formats(@inventory_cows)
        redirect_to_index(@objects)
      end

      # GET /cattles/1
      def show; end

      # GET /cattles/new
      def new
        @inventory_cow = InventoryCow.new
      end

      # GET /cattles/1/edit
      def edit; end

      # POST /cattles
      def create
        @inventory_cow = InventoryCow.new(inventory_cow_params)

        if @inventory_cow.save
          redirect(@inventory_cow, params)
        else
          render :new
        end
      end

      # PATCH/PUT /cattles/1
      def update
        if @inventory_cow.update(inventory_cow_params)
          redirect(@inventory_cow, params)
        else
          render :edit
        end
      end

      def clone
        @inventory_cow = InventoryCow.clone_record params[:inventory_cow_id]
        @inventory_cow.save
        redirect_to_index(@objects)
      end

      # DELETE /cattles/1
      def destroy
        @inventory_cow.destroy
        redirect_to_index(@objects)
      end

      def destroy_multiple
        InventoryCow.destroy redefine_ids(params[:multiple_ids])
        redirect_to_index(@objects)
      end

      def upload
        InventoryCow.upload(params[:file])
        redirect_to_index(@objects)
      end

      def reload; end

      def sort
        InventoryCow.sorter(params[:row])
      end

      private

      def index_variables
        @q = InventoryCow.ransack(params[:q])
        @inventory_cows = @q.result(distinct: true)
        @objects = @inventory_cows.page(@current_page).order(position: :desc)
        @total = @inventory_cows.size
        @attributes = InventoryCow.index_attributes
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_inventory_cow
        @inventory_cow = InventoryCow.find_by(id: params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def inventory_cow_params
        params.require(:inventory_cow).permit(
          :serie_number, :inventory_id, :cow_id
        )
      end
    end
  end
end